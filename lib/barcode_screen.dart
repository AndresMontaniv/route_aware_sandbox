import 'package:flutter/material.dart';
import 'package:camera_scanner_kit/camera_scanner_kit.dart';
import 'package:go_router/go_router.dart';

class BarcodeScreen extends StatefulWidget {
  static const name = 'barcode';

  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final BarcodeScannerController _scannerController = BarcodeScannerController();
  final ValueNotifier<bool> _isScannerMounted = ValueNotifier<bool>(true);
  final List<String> _scannedItems = [];
  RouterDelegate<Object>? _routerDelegate;

  void _onScanned(String barcode) {
    setState(() {
      _scannedItems.insert(0, barcode);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_routerDelegate == null) {
      _routerDelegate = GoRouter.of(context).routerDelegate;
      _routerDelegate?.addListener(_onRouteChanged);
    }
  }

  void _onRouteChanged() {
    if (!mounted) return;

    String? topRouteName;
    if (_routerDelegate is GoRouterDelegate) {
      final config = (_routerDelegate as GoRouterDelegate).currentConfiguration;
      if (config.isNotEmpty) {
        topRouteName = config.last.route.name;
      }
    }

    debugPrint('[BarcodeScreen] _onRouteChanged - top route: $topRouteName');

    if (topRouteName == BarcodeScreen.name) {
      if (!_isScannerMounted.value) {
        _isScannerMounted.value = true;
        debugPrint('[BarcodeScreen] Route active - Remounted Scanner View.');
      }
      try {
        _scannerController.stop();
        debugPrint('[BarcodeScreen] Camera explicitly stopped for manual resume.');
      } catch (e) {
        debugPrint('[BarcodeScreen] Could not stop camera on remount: $e');
      }
    } else {
      _scannerController.stop();
      if (_isScannerMounted.value) {
        _isScannerMounted.value = false;
        debugPrint('[BarcodeScreen] Route inactive - Unmounted Scanner View to free Singleton.');
      }
    }
  }

  @override
  void dispose() {
    _routerDelegate?.removeListener(_onRouteChanged);
    _scannerController.dispose();
    _isScannerMounted.dispose();
    super.dispose();
  }

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
