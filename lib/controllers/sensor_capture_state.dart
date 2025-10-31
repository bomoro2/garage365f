// lib/controllers/sensor_capture_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sensor_capture_state.freezed.dart';

@freezed
class SensorCaptureState with _$SensorCaptureState {
  const factory SensorCaptureState({
    @Default(false) bool isRecording,
    @Default(<double>[]) List<double> waveform,
    @Default(<double>[]) List<double> spectrum,
    @Default(<double>[]) List<double> accelMagnitude,
  }) = _SensorCaptureState;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
