import 'package:flutter/material.dart';
import 'package:camera_scanner_kit/camera_scanner_kit.dart';

class BarcodeScreen extends StatefulWidget {
  static const name = 'barcode';

  const BarcodeScreen({super.key});

  @override
  State<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final BarcodeScannerController _scannerController = BarcodeScannerController();
  final List<String> _scannedItems = [];

  void _onScanned(String barcode) {
    setState(() {
      _scannedItems.insert(0, barcode); // Add to top of list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BarcodeScannerView(
          borderRadius: BorderRadius.zero,
          controller: _scannerController,
          showToggleButton: true,
          onBarcodeScanned: _onScanned,
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
