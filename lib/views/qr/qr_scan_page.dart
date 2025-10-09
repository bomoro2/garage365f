import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../core/qr/qr_service.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  bool _handled = false;

  void _onDetect(BarcodeCapture cap) {
    if (_handled) return;
    final codes = cap.barcodes
        .where((b) => (b.rawValue ?? '').isNotEmpty)
        .toList();
    if (codes.isEmpty) return;
    final raw = codes.first.rawValue!;
    final assetId = QrService.extractAssetId(raw);

    if (assetId != null && assetId.isNotEmpty) {
      setState(() => _handled = true);
      // Navega directo a la FDU (dummy)
      context.go('/fdu/$assetId');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('QR no reconocido')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: _onDetect,
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.noDuplicates,
              facing: CameraFacing.back,
              torchEnabled: false,
            ),
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
