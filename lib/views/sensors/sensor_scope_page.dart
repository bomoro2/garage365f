import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/sensors_controller.dart';
import 'dart:math' as math;               // 👈 agregar esto arriba


class SensorScopePage extends ConsumerWidget {
  const SensorScopePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sensorsControllerProvider);
    final vm = ref.read(sensorsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SensorScope (Audio + Acelerómetro)'),
        actions: [
          IconButton(
            icon: Icon(state.isRecording ? Icons.stop : Icons.mic),
            onPressed: state.isRecording ? vm.stop : vm.start,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _Section(
              title: 'Waveform (audio)',
              child: SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: _WaveformPainter(state.waveform),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Acelerómetro (magnitud | g)',
              child: SizedBox(
                height: 120,
                child: CustomPaint(
                  painter: _LineSeriesPainter(state.accelMagnitude, yLabel: 'g'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
        ],
      ),
    );
  }
}

/// ---------- Painters ----------

class _WaveformPainter extends CustomPainter {
  final List<double> samples; // [-1,1]
  _WaveformPainter(this.samples);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, bg);

    final midY = size.height / 2;
    final line = Paint()
      ..color = Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // línea media
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      Paint()..color = Colors.white24,
    );

    if (samples.isEmpty) return;

    // cuántas muestras salto por pixel
    final totalPoints = samples.length;
    final pixels = size.width;
    final step =
        math.max(1, (totalPoints / pixels).floor()); // 👈 ahora es int seguro

    final path = Path();
    int j = 0;
    for (int i = 0; i < totalPoints; i += step) {
      final x =
          j * (size.width / ((totalPoints / step) - 1).clamp(1, 1e9).toDouble());
      final y = midY - samples[i] * (size.height * 0.45);
      if (j == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      j++;
    }

    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) => true;
}

class _LineSeriesPainter extends CustomPainter {
  final List<double> values;
  final String yLabel;
  _LineSeriesPainter(this.values, {this.yLabel = ''});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = Colors.white12
      ..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    double minV = values.first, maxV = values.first;
    for (final v in values) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final span = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * (size.width / (values.length - 1).clamp(1, 1e9));
      final y = size.height - ((values[i] - minV) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white70;

    canvas.drawPath(path, line);

    final tp = TextPainter(
      text: TextSpan(text: yLabel, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width);
    tp.paint(canvas, const Offset(4, 4));
  }

  @override
  bool shouldRepaint(covariant _LineSeriesPainter oldDelegate) => true;
}
