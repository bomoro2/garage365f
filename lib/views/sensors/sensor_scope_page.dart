// lib/views/sensors/sensor_scope_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/sensors_controller.dart';

class SensorScopePage extends ConsumerStatefulWidget {
  const SensorScopePage({super.key});

  @override
  ConsumerState<SensorScopePage> createState() => _SensorScopePageState();
}

class _SensorScopePageState extends ConsumerState<SensorScopePage> {
  @override
  void initState() {
    super.initState();
    // arrancamos el accel
    Future.microtask(() {
      ref.read(sensorsControllerProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sensorsControllerProvider);
    final vm = ref.read(sensorsControllerProvider.notifier);

    final accelRms = state.spectrum.isNotEmpty ? state.spectrum[0] : 0.0;
    final audioRms = state.spectrum.length > 1 ? state.spectrum[1] : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SensorScope'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              vm.startMic();
            },
          ),
          IconButton(
            icon: Icon(state.isRecording ? Icons.stop : Icons.play_arrow),
            onPressed: state.isRecording ? vm.stop : vm.start,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Vibración (g)',
                    value: accelRms.toStringAsFixed(3),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricCard(
                    title: 'Audio (RMS)',
                    value: audioRms.toStringAsFixed(3),
                    color: Colors.purpleAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // gráfico verde
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: CustomPaint(
                  painter: _AccelPainter(state.accelMagnitude),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // gráfico violeta
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: CustomPaint(
                  painter: _AudioWaveformPainter(state.waveform),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- painters ----------

class _AccelPainter extends CustomPainter {
  final List<double> values;
  _AccelPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, bg);

    if (values.isEmpty) {
      final mid = size.height / 2;
      canvas.drawLine(
        Offset(0, mid),
        Offset(size.width, mid),
        Paint()
          ..color = Colors.white24
          ..strokeWidth = 1,
      );
      return;
    }

    double minV = values.first, maxV = values.first;
    for (final v in values) {
      if (v < minV) minV = v;
      if (v > maxV) maxV = v;
    }
    final span = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final path = Path();
    final divider = (values.length - 1).clamp(1, 100000);
    for (int i = 0; i < values.length; i++) {
      final x = i * (size.width / divider);
      final norm = (values[i] - minV) / span;
      final y = size.height - norm * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final line = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _AccelPainter oldDelegate) => true;
}

class _AudioWaveformPainter extends CustomPainter {
  final List<double> samples;
  _AudioWaveformPainter(this.samples);

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.black;
    canvas.drawRect(Offset.zero & size, bg);

    final midY = size.height / 2;
    canvas.drawLine(
      Offset(0, midY),
      Offset(size.width, midY),
      Paint()
        ..color = Colors.white24
        ..strokeWidth = 1,
    );

    if (samples.isEmpty) return;

    final total = samples.length;
    final step = (total / size.width).ceil().clamp(1, 999999);

    final path = Path();
    int drawIndex = 0;
    for (int i = 0; i < total; i += step) {
      final x =
          drawIndex * (size.width / (total / step).clamp(1, 1e9).toDouble());
      final s = samples[i].clamp(-1.0, 1.0);
      final y = midY - s * (size.height * 0.45);

      if (drawIndex == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      drawIndex++;
    }

    final line = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _AudioWaveformPainter oldDelegate) => true;
}
