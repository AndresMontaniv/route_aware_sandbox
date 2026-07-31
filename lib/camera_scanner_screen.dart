import 'package:flutter/material.dart';
import 'package:camera_scanner_kit/camera_scanner_kit.dart';

import 'top_route_aware_mixin.dart';

class CameraScannerScreen extends StatefulWidget {
  static const name = 'camera-scanner';

  const CameraScannerScreen({super.key});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> with TopRouteAwareMixin {
  final BarcodeScannerController _scannerController = BarcodeScannerController();
  final ValueNotifier<bool> _isScannerMounted = ValueNotifier<bool>(true);
  final List<String> _scannedItems = [];

  // ---------------------------------------------------------------------------
  // TopRouteAwareMixin
  // ---------------------------------------------------------------------------

  @override
  String get routeAwareName => CameraScannerScreen.name;

  @override
  void onTopRouteGained() {
    if (!_isScannerMounted.value) {
      _isScannerMounted.value = true;
      debugPrint('[CameraScannerScreen] Route active - Remounted Scanner View.');
    }
    if (_scannerController.isCameraActive) {
      try {
        _scannerController.stop();
        debugPrint('[CameraScannerScreen] Camera explicitly stopped for manual resume.');
      } catch (e) {
        debugPrint('[CameraScannerScreen] Could not stop camera on remount: $e');
      }
    }
  }

  @override
  void onTopRouteLost() {
    if (_scannerController.isCameraActive) {
      _scannerController.stop();
    }
    if (_isScannerMounted.value) {
      _isScannerMounted.value = false;
      debugPrint('[CameraScannerScreen] Route inactive - Unmounted Scanner View to free Singleton.');
    }
  }

  // ---------------------------------------------------------------------------
  // Scanned items
  // ---------------------------------------------------------------------------

  void _onScanned(String barcode) {
    _scannedItems.insert(0, barcode);
    if (mounted) {
      setState(() {});
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _scannerController.dispose();
    _isScannerMounted.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _isScannerMounted,
          builder: (_, isMounted, _) {
            if (isMounted) {
              return BarcodeScannerView(
                controller: _scannerController,
                showToggleButton: true,
                useDarkModeButtonTheme: true,
                borderRadius: BorderRadius.zero,
                onBarcodeScanned: (barcode) => _onScanned(barcode),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const Divider(height: 40),

        Text(
          'Scanned Codes: ${_scannedItems.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _scannedItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: Text(_scannedItems[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}
