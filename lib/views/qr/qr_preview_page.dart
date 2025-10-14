import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrPreviewPage extends StatefulWidget {
  final String assetId;
  final String assetCode;
  const QrPreviewPage({
    super.key,
    required this.assetId,
    required this.assetCode,
  });

  @override
  State<QrPreviewPage> createState() => _QrPreviewPageState();
}

class _QrPreviewPageState extends State<QrPreviewPage> {
  final _controller = ScreenshotController();
  bool _saving = false;

  Future<void> _sharePng() async {
    setState(() => _saving = true);
    try {
      final bytes = await _controller.capture();
      if (bytes == null) return;
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/qr_${widget.assetCode}.png');
      await file.writeAsBytes(bytes);

      if (!mounted) return; // evita use_build_context_synchronously

      // share_plus estable para tu versión:
      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'QR de equipo ${widget.assetCode}',
        subject: 'QR ${widget.assetCode}',
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR ${widget.assetCode}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: _saving ? null : _sharePng,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.share),
          ),
        ],
      ),
      body: Center(
        child: Screenshot(
          controller: _controller,
          child: _QrCard(assetCode: widget.assetCode),
        ),
      ),
    );
  }
}

class _QrCard extends StatelessWidget {
  final String assetCode;
  const _QrCard({required this.assetCode});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Equipo: $assetCode', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            QrImageView(data: assetCode, size: 200, version: QrVersions.auto),
          ],
        ),
      ),
    );
  }
}
