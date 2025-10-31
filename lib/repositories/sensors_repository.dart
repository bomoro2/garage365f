import 'dart:typed_data';
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sensors_plus/sensors_plus.dart';
// import 'package:mic_stream/mic_stream.dart';

class SensorsRepository {
  Stream<Uint8List>? micStream;
  Stream<AccelerometerEvent>? accelStream;

  final int sampleRate;
  // final ChannelConfig channelConfig;
  // final AudioFormat audioFormat;

  SensorsRepository({
    this.sampleRate = 44100,
    // this.channelConfig = ChannelConfig.CHANNEL_IN_MONO,
    // this.audioFormat = AudioFormat.ENCODING_PCM_16BIT,
  });

  Future<void> init() async {
  //   // ⚠️ en web NO intentamos abrir mic_stream
  //   if (!kIsWeb) {
  //     micStream = await MicStream.microphone(
  //       sampleRate: sampleRate,
  //       audioSource: AudioSource.MIC,
  //       channelConfig: channelConfig,
  //       audioFormat: audioFormat,
  //     );
  //   } else {
  //     micStream = null;
  //   }

    // esto sí es seguro
    accelStream = accelerometerEventStream();
  }
}
