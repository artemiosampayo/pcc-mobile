/// ===========================================================
/// PCC Mobile Framework
/// Archivo: barcode_scanner_screen.dart
/// Carpeta: lib/screens/scanner/
/// Sprint: SPR-001
/// Descripción:
/// Pantalla reutilizable para escaneo de códigos de barras.
/// ===========================================================

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _processing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    _processing = true;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear guía'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Coloque el código de barras dentro del recuadro',
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
