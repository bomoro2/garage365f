// lib/repositories/sensors_repository.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorsRepository {
  // accel
  Stream<AccelerometerEvent>? accelStream;

  // audio
  EventChannel? _audioChannel;
  Stream<Uint8List>? micStream;

  Future<void> init() async {
    // 👇 SOLO acel acá
    accelStream = accelerometerEventStream();
  }

  Future<void> initMic() async {
    // 👇 recién acá tocamos el canal nativo
    _audioChannel ??= const EventChannel('garage365/audio');
    micStream = _audioChannel!.receiveBroadcastStream().cast<Uint8List>();
  }
}
