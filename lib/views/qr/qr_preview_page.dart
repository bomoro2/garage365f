import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/qr/qr_service.dart';

class QrPreviewPage extends StatefulWidget {
  final String assetCode; // visible (GRP07-001)
  final String assetId; // interno (a1)

  const QrPreviewPage({
    super.key,
    required this.assetCode,
    required this.assetId,
  });

  @override
  State<QrPreviewPage> createState() => _QrPreviewPageState();
}

class _QrPreviewPageState extends State<QrPreviewPage> {
  final _shot = ScreenshotController();

  Future<void> _shareLabel() async {
    try {
      final png = await _shot.capture(pixelRatio: 3.0);
      if (png == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo generar la etiqueta')),
        );
        return;
      }
      final name = 'garage365_${widget.assetCode.replaceAll(" ", "_")}.png';
      await Share.shareXFiles([
        XFile.fromData(png, mimeType: 'image/png', name: name),
      ], text: 'Etiqueta QR ${widget.assetCode}');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al compartir: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = QrService.buildDeepLink(widget.assetId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etiqueta QR'),
        actions: [
          IconButton(
            tooltip: 'Compartir etiqueta',
            onPressed: _shareLabel,
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Screenshot(
            controller: _shot,
            child: _LabelCard(
              assetCode: widget.assetCode,
              assetId: widget.assetId,
              deepLink: link,
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelCard extends StatelessWidget {
  final String assetCode;
  final String assetId;
  final String deepLink;

  const _LabelCard({
    required this.assetCode,
    required this.assetId,
    required this.deepLink,
  });

  @override
  Widget build(BuildContext context) {
    // Tarjeta “imprimible/compartible”
    return Container(
      width: 320,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // QR grande
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: QrImageView(
                data: deepLink,
                version: QrVersions.auto,
                size: 220,
                gapless: false,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Código visible grande
          Text(
            assetCode,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          // Línea técnica pequeña
          Text(
            'ID: $assetId',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          // Link (seleccionable fuera de la captura)
          SelectableText(
            deepLink,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
