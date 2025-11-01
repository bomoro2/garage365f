// lib/data/audio/native_mic_stream.dart
import 'dart:typed_data';
import 'package:flutter/services.dart';

class NativeMicStream {
  static const _channel = EventChannel('garage365/audio');

  Stream<Uint8List> get stream =>
      _channel.receiveBroadcastStream().cast<Uint8List>();
}
