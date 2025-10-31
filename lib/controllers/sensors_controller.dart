import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sensor_capture_state.dart';        // <--- nuevo nombre
import '../repositories/sensors_repository.dart';

final sensorsRepositoryProvider = Provider((_) => SensorsRepository());

final sensorsControllerProvider =
    StateNotifierProvider<SensorsController, SensorCaptureState>(
  (ref) => SensorsController(ref),
);

class SensorsController extends StateNotifier<SensorCaptureState> {
  final Ref _ref;
  SensorsRepository? _repo;
  StreamSubscription<Uint8List>? _micSub;
  StreamSubscription? _accSub;

  SensorsController(this._ref) : super(const SensorCaptureState());

  Future<void> start() async {
    if (state.isRecording) return;

    _repo ??= _ref.read(sensorsRepositoryProvider);
    await _repo!.init();

    _accSub = _repo!.accelStream?.listen((e) {
      final mag = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      final list = List<double>.from(state.accelMagnitude)..add(mag);
      if (list.length > 300) list.removeAt(0);
      state = state.copyWith(accelMagnitude: list);
    });

    _micSub = _repo!.micStream?.listen((bytes) {
      final int16 = Int16List.view(bytes.buffer);
      final list = List<double>.from(state.waveform);
      for (final s in int16) {
        list.add(s / 32768.0);
        if (list.length > 22050) list.removeAt(0);
      }
      state = state.copyWith(waveform: list);
    });

    state = state.copyWith(isRecording: true);
  }

  Future<void> stop() async {
    await _micSub?.cancel();
    await _accSub?.cancel();
    _micSub = null;
    _accSub = null;
    state = state.copyWith(isRecording: false);
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
