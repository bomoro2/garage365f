import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/qr/qr_service.dart';

class QrPreviewPage extends StatelessWidget {
  final String assetCode; // visible (GRP07-001)
  final String assetId; // interno (a1)

  const QrPreviewPage({
    super.key,
    required this.assetCode,
    required this.assetId,
  });

  @override
  Widget build(BuildContext context) {
    final link = QrService.buildDeepLink(assetId);
    return Scaffold(
      appBar: AppBar(title: const Text('Etiqueta QR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: link,
                    version: QrVersions.auto,
                    size: 220,
                    gapless: false,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                assetCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: $assetId',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              SelectableText(link, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
