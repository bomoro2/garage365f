// lib/controllers/sensors_controller.dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../repositories/sensors_repository.dart';

/// Provider que usa TU repository real
final sensorsControllerProvider =
    StateNotifierProvider<SensorsController, SensorsState>((ref) {
      final repo = SensorsRepository();
      final controller = SensorsController(repo);
      return controller;
    });

/// Estado igual que antes: la vista ya lo conocía
class SensorsState {
  final bool isRecording;
  final List<double> spectrum; // [accelRms, audioRms]
  final List<double> accelMagnitude; // historial p/ painter verde
  final List<double> waveform; // audio normalizado p/ painter violeta

  const SensorsState({
    this.isRecording = false,
    this.spectrum = const <double>[],
    this.accelMagnitude = const <double>[],
    this.waveform = const <double>[],
  });

  SensorsState copyWith({
    bool? isRecording,
    List<double>? spectrum,
    List<double>? accelMagnitude,
    List<double>? waveform,
  }) {
    return SensorsState(
      isRecording: isRecording ?? this.isRecording,
      spectrum: spectrum ?? this.spectrum,
      accelMagnitude: accelMagnitude ?? this.accelMagnitude,
      waveform: waveform ?? this.waveform,
    );
  }
}

class SensorsController extends StateNotifier<SensorsState> {
  SensorsController(this._repo) : super(const SensorsState()) {
    _init();
  }

  final SensorsRepository _repo;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<Uint8List>? _micSub;

  // ===================================================================
  // INIT
  // ===================================================================
  Future<void> _init() async {
    // inicializamos el repo → esto crea el stream de acelerómetro
    await _repo.init();
    _listenAccel();
  }

  // ===================================================================
  // ACELERÓMETRO
  // ===================================================================
  void _listenAccel() {
    _accelSub?.cancel();

    final accelStream = _repo.accelStream;
    if (accelStream == null) {
      return;
    }

    _accelSub = accelStream.listen((event) {
      // magnitud en g
      final mag = math.sqrt(
        (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
      );

      // armamos historial como anoche
      final next = List<double>.from(state.accelMagnitude)..add(mag);
      if (next.length > 200) {
        next.removeAt(0);
      }

      state = state.copyWith(
        isRecording: true,
        accelMagnitude: next,
        spectrum: <double>[
          mag, // slot 0 → vibración
          state.spectrum.length > 1 ? state.spectrum[1] : 0.0,
        ],
      );
    });
  }

  /// lo llamabas con el botón play/stop
  void start() {
    // en este diseño, el accel ya está escuchando,
    // pero dejamos este método por compatibilidad
    if (_accelSub == null) {
      _listenAccel();
    } else {
      state = state.copyWith(isRecording: true);
    }
  }

  void stop() {
    _accelSub?.cancel();
    _accelSub = null;
    state = state.copyWith(isRecording: false);
  }

  // ===================================================================
  // MIC
  // ===================================================================
  Future<void> startMic() async {
    if (_micSub != null) return;

    await _repo.initMic(); // abre el EventChannel
    final micStream = _repo.micStream;
    if (micStream == null) return;

    _micSub = micStream.listen(
      _onMicData,
      onError: (e) {
        // no rompemos la app si viene algo raro
      },
    );
  }

  void _onMicData(Uint8List data) {
    // anoche vimos que te venía con header de 5 bytes 👇
    const headerBytes = 5;
    final aligned = headerBytes.isOdd ? headerBytes + 1 : headerBytes;

    if (data.lengthInBytes <= aligned) {
      return;
    }

    // ahora sí podemos leer como Int16List
    final samples = data.buffer.asInt16List(
      aligned,
      (data.lengthInBytes - aligned) ~/ 2,
    );

    // normalizamos a [-1, 1] para pintarlo
    final waveform = <double>[];
    for (final s in samples) {
      waveform.add(s / 32768.0);
    }

    // RMS de audio
    double audioRms = 0.0;
    if (waveform.isNotEmpty) {
      double acc = 0;
      for (final w in waveform) {
        acc += w * w;
      }
      audioRms = math.sqrt(acc / waveform.length);
    }

    state = state.copyWith(
      waveform: waveform,
      spectrum: <double>[
        // mantenemos vibración
        state.spectrum.isNotEmpty ? state.spectrum[0] : 0.0,
        // actualizamos audio
        audioRms,
      ],
    );
  }

  void stopMic() {
    _micSub?.cancel();
    _micSub = null;
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _micSub?.cancel();
    super.dispose();
  }
}
