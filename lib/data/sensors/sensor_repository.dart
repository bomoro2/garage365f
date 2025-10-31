// lib/data/sensors/sensor_repository.dart
import 'dart:typed_data';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:mic_stream/mic_stream.dart';

class SensorRepository {
  // Streams crudos (mic en bytes PCM16; acelerómetro en eventos)
  Stream<Uint8List>? micStream;
  Stream<AccelerometerEvent>? accelStream;

  // Parámetros por defecto
  final int sampleRate;
  final ChannelConfig channelConfig;
  final AudioFormat audioFormat;

  SensorRepository({
    this.sampleRate = 44100,
    this.channelConfig = ChannelConfig.CHANNEL_IN_MONO,
    this.audioFormat = AudioFormat.ENCODING_PCM_16BIT,
  });

  /// Inicializa las fuentes de datos
  Future<void> init() async {
    // Micrófono: devuelve Stream<Uint8List> (PCM16)
    micStream = MicStream.microphone(
      sampleRate: sampleRate,
      audioSource: AudioSource.MIC,
      channelConfig: channelConfig,
      audioFormat: audioFormat,
    );

    // Acelerómetro: stream de events (x,y,z)
    accelStream = accelerometerEventStream();
  }
}
