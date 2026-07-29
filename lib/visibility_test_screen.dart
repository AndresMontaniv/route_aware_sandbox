import 'package:flutter/material.dart';
import 'package:camera_scanner_kit/camera_scanner_kit.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VisibilityTestScreen extends StatefulWidget {
  static const name = 'visibility-test';

  const VisibilityTestScreen({super.key});

  @override
  State<VisibilityTestScreen> createState() => _VisibilityTestScreenState();
}

class _VisibilityTestScreenState extends State<VisibilityTestScreen> {
  final BarcodeScannerController _scannerController = BarcodeScannerController();
  final List<String> _scannedItems = [];

  void _onScanned(String barcode) {
    setState(() {
      _scannedItems.insert(0, barcode);
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VisibilityDetector(
          key: const Key('scanner-visibility'),
          onVisibilityChanged: (info) {
            debugPrint('Visibility changed: ${info.visibleFraction}');
            if (info.visibleFraction < 0.1) {
              if (_scannerController.isCameraActive) {
                debugPrint('[VisibilityTest] - Turning Camera OFF');
                _scannerController.stop();
              }
            }
          },
          child: BarcodeScannerView(
            controller: _scannerController,
            showToggleButton: true,
            useDarkModeButtonTheme: true,
            borderRadius: BorderRadius.zero,
            onBarcodeScanned: (barcode) => _onScanned(barcode),
          ),
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
