// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sensor_capture_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SensorCaptureState {

 bool get isRecording; List<double> get waveform; List<double> get spectrum; List<double> get accelMagnitude;
/// Create a copy of SensorCaptureState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SensorCaptureStateCopyWith<SensorCaptureState> get copyWith => _$SensorCaptureStateCopyWithImpl<SensorCaptureState>(this as SensorCaptureState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SensorCaptureState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&const DeepCollectionEquality().equals(other.waveform, waveform)&&const DeepCollectionEquality().equals(other.spectrum, spectrum)&&const DeepCollectionEquality().equals(other.accelMagnitude, accelMagnitude));
}


@override
int get hashCode => Object.hash(runtimeType,isRecording,const DeepCollectionEquality().hash(waveform),const DeepCollectionEquality().hash(spectrum),const DeepCollectionEquality().hash(accelMagnitude));

@override
String toString() {
  return 'SensorCaptureState(isRecording: $isRecording, waveform: $waveform, spectrum: $spectrum, accelMagnitude: $accelMagnitude)';
}


}

/// @nodoc
abstract mixin class $SensorCaptureStateCopyWith<$Res>  {
  factory $SensorCaptureStateCopyWith(SensorCaptureState value, $Res Function(SensorCaptureState) _then) = _$SensorCaptureStateCopyWithImpl;
@useResult
$Res call({
 bool isRecording, List<double> waveform, List<double> spectrum, List<double> accelMagnitude
});




}
/// @nodoc
class _$SensorCaptureStateCopyWithImpl<$Res>
    implements $SensorCaptureStateCopyWith<$Res> {
  _$SensorCaptureStateCopyWithImpl(this._self, this._then);

  final SensorCaptureState _self;
  final $Res Function(SensorCaptureState) _then;

/// Create a copy of SensorCaptureState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRecording = null,Object? waveform = null,Object? spectrum = null,Object? accelMagnitude = null,}) {
  return _then(_self.copyWith(
isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,waveform: null == waveform ? _self.waveform : waveform // ignore: cast_nullable_to_non_nullable
as List<double>,spectrum: null == spectrum ? _self.spectrum : spectrum // ignore: cast_nullable_to_non_nullable
as List<double>,accelMagnitude: null == accelMagnitude ? _self.accelMagnitude : accelMagnitude // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}

}


/// Adds pattern-matching-related methods to [SensorCaptureState].
extension SensorCaptureStatePatterns on SensorCaptureState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SensorCaptureState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SensorCaptureState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SensorCaptureState value)  $default,){
final _that = this;
switch (_that) {
case _SensorCaptureState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SensorCaptureState value)?  $default,){
final _that = this;
switch (_that) {
case _SensorCaptureState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRecording,  List<double> waveform,  List<double> spectrum,  List<double> accelMagnitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SensorCaptureState() when $default != null:
return $default(_that.isRecording,_that.waveform,_that.spectrum,_that.accelMagnitude);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRecording,  List<double> waveform,  List<double> spectrum,  List<double> accelMagnitude)  $default,) {final _that = this;
switch (_that) {
case _SensorCaptureState():
return $default(_that.isRecording,_that.waveform,_that.spectrum,_that.accelMagnitude);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRecording,  List<double> waveform,  List<double> spectrum,  List<double> accelMagnitude)?  $default,) {final _that = this;
switch (_that) {
case _SensorCaptureState() when $default != null:
return $default(_that.isRecording,_that.waveform,_that.spectrum,_that.accelMagnitude);case _:
  return null;

}
}

}

/// @nodoc


class _SensorCaptureState implements SensorCaptureState {
  const _SensorCaptureState({this.isRecording = false, final  List<double> waveform = const <double>[], final  List<double> spectrum = const <double>[], final  List<double> accelMagnitude = const <double>[]}): _waveform = waveform,_spectrum = spectrum,_accelMagnitude = accelMagnitude;
  

@override@JsonKey() final  bool isRecording;
 final  List<double> _waveform;
@override@JsonKey() List<double> get waveform {
  if (_waveform is EqualUnmodifiableListView) return _waveform;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waveform);
}

 final  List<double> _spectrum;
@override@JsonKey() List<double> get spectrum {
  if (_spectrum is EqualUnmodifiableListView) return _spectrum;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_spectrum);
}

 final  List<double> _accelMagnitude;
@override@JsonKey() List<double> get accelMagnitude {
  if (_accelMagnitude is EqualUnmodifiableListView) return _accelMagnitude;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_accelMagnitude);
}


/// Create a copy of SensorCaptureState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SensorCaptureStateCopyWith<_SensorCaptureState> get copyWith => __$SensorCaptureStateCopyWithImpl<_SensorCaptureState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SensorCaptureState&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&const DeepCollectionEquality().equals(other._waveform, _waveform)&&const DeepCollectionEquality().equals(other._spectrum, _spectrum)&&const DeepCollectionEquality().equals(other._accelMagnitude, _accelMagnitude));
}


@override
int get hashCode => Object.hash(runtimeType,isRecording,const DeepCollectionEquality().hash(_waveform),const DeepCollectionEquality().hash(_spectrum),const DeepCollectionEquality().hash(_accelMagnitude));

@override
String toString() {
  return 'SensorCaptureState(isRecording: $isRecording, waveform: $waveform, spectrum: $spectrum, accelMagnitude: $accelMagnitude)';
}


}

/// @nodoc
abstract mixin class _$SensorCaptureStateCopyWith<$Res> implements $SensorCaptureStateCopyWith<$Res> {
  factory _$SensorCaptureStateCopyWith(_SensorCaptureState value, $Res Function(_SensorCaptureState) _then) = __$SensorCaptureStateCopyWithImpl;
@override @useResult
$Res call({
 bool isRecording, List<double> waveform, List<double> spectrum, List<double> accelMagnitude
});




}
/// @nodoc
class __$SensorCaptureStateCopyWithImpl<$Res>
    implements _$SensorCaptureStateCopyWith<$Res> {
  __$SensorCaptureStateCopyWithImpl(this._self, this._then);

  final _SensorCaptureState _self;
  final $Res Function(_SensorCaptureState) _then;

/// Create a copy of SensorCaptureState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRecording = null,Object? waveform = null,Object? spectrum = null,Object? accelMagnitude = null,}) {
  return _then(_SensorCaptureState(
isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,waveform: null == waveform ? _self._waveform : waveform // ignore: cast_nullable_to_non_nullable
as List<double>,spectrum: null == spectrum ? _self._spectrum : spectrum // ignore: cast_nullable_to_non_nullable
as List<double>,accelMagnitude: null == accelMagnitude ? _self._accelMagnitude : accelMagnitude // ignore: cast_nullable_to_non_nullable
as List<double>,
  ));
}


}

// dart format on
