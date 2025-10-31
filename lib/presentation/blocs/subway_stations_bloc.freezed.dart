// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subway_stations_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SubwayStationsEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() fetchSubwayStations,
    required TResult Function(int line) fetchSubwayStationsByLine,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? fetchSubwayStations,
    TResult? Function(int line)? fetchSubwayStationsByLine,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? fetchSubwayStations,
    TResult Function(int line)? fetchSubwayStationsByLine,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchSubwayStations value) fetchSubwayStations,
    required TResult Function(_FetchSubwayStationsByLine value)
    fetchSubwayStationsByLine,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchSubwayStations value)? fetchSubwayStations,
    TResult? Function(_FetchSubwayStationsByLine value)?
    fetchSubwayStationsByLine,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchSubwayStations value)? fetchSubwayStations,
    TResult Function(_FetchSubwayStationsByLine value)?
    fetchSubwayStationsByLine,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubwayStationsEventCopyWith<$Res> {
  factory $SubwayStationsEventCopyWith(
    SubwayStationsEvent value,
    $Res Function(SubwayStationsEvent) then,
  ) = _$SubwayStationsEventCopyWithImpl<$Res, SubwayStationsEvent>;
}

/// @nodoc
class _$SubwayStationsEventCopyWithImpl<$Res, $Val extends SubwayStationsEvent>
    implements $SubwayStationsEventCopyWith<$Res> {
  _$SubwayStationsEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubwayStationsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FetchSubwayStationsImplCopyWith<$Res> {
  factory _$$FetchSubwayStationsImplCopyWith(
    _$FetchSubwayStationsImpl value,
    $Res Function(_$FetchSubwayStationsImpl) then,
  ) = __$$FetchSubwayStationsImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FetchSubwayStationsImplCopyWithImpl<$Res>
    extends _$SubwayStationsEventCopyWithImpl<$Res, _$FetchSubwayStationsImpl>
    implements _$$FetchSubwayStationsImplCopyWith<$Res> {
  __$$FetchSubwayStationsImplCopyWithImpl(
    _$FetchSubwayStationsImpl _value,
    $Res Function(_$FetchSubwayStationsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubwayStationsEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FetchSubwayStationsImpl implements _FetchSubwayStations {
  const _$FetchSubwayStationsImpl();

  @override
  String toString() {
    return 'SubwayStationsEvent.fetchSubwayStations()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchSubwayStationsImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() fetchSubwayStations,
    required TResult Function(int line) fetchSubwayStationsByLine,
  }) {
    return fetchSubwayStations();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? fetchSubwayStations,
    TResult? Function(int line)? fetchSubwayStationsByLine,
  }) {
    return fetchSubwayStations?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? fetchSubwayStations,
    TResult Function(int line)? fetchSubwayStationsByLine,
    required TResult orElse(),
  }) {
    if (fetchSubwayStations != null) {
      return fetchSubwayStations();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchSubwayStations value) fetchSubwayStations,
    required TResult Function(_FetchSubwayStationsByLine value)
    fetchSubwayStationsByLine,
  }) {
    return fetchSubwayStations(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchSubwayStations value)? fetchSubwayStations,
    TResult? Function(_FetchSubwayStationsByLine value)?
    fetchSubwayStationsByLine,
  }) {
    return fetchSubwayStations?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchSubwayStations value)? fetchSubwayStations,
    TResult Function(_FetchSubwayStationsByLine value)?
    fetchSubwayStationsByLine,
    required TResult orElse(),
  }) {
    if (fetchSubwayStations != null) {
      return fetchSubwayStations(this);
    }
    return orElse();
  }
}

abstract class _FetchSubwayStations implements SubwayStationsEvent {
  const factory _FetchSubwayStations() = _$FetchSubwayStationsImpl;
}

/// @nodoc
abstract class _$$FetchSubwayStationsByLineImplCopyWith<$Res> {
  factory _$$FetchSubwayStationsByLineImplCopyWith(
    _$FetchSubwayStationsByLineImpl value,
    $Res Function(_$FetchSubwayStationsByLineImpl) then,
  ) = __$$FetchSubwayStationsByLineImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int line});
}

/// @nodoc
class __$$FetchSubwayStationsByLineImplCopyWithImpl<$Res>
    extends
        _$SubwayStationsEventCopyWithImpl<$Res, _$FetchSubwayStationsByLineImpl>
    implements _$$FetchSubwayStationsByLineImplCopyWith<$Res> {
  __$$FetchSubwayStationsByLineImplCopyWithImpl(
    _$FetchSubwayStationsByLineImpl _value,
    $Res Function(_$FetchSubwayStationsByLineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubwayStationsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? line = null}) {
    return _then(
      _$FetchSubwayStationsByLineImpl(
        line:
            null == line
                ? _value.line
                : line // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc

class _$FetchSubwayStationsByLineImpl implements _FetchSubwayStationsByLine {
  const _$FetchSubwayStationsByLineImpl({required this.line});

  @override
  final int line;

  @override
  String toString() {
    return 'SubwayStationsEvent.fetchSubwayStationsByLine(line: $line)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchSubwayStationsByLineImpl &&
            (identical(other.line, line) || other.line == line));
  }

  @override
  int get hashCode => Object.hash(runtimeType, line);

  /// Create a copy of SubwayStationsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchSubwayStationsByLineImplCopyWith<_$FetchSubwayStationsByLineImpl>
  get copyWith => __$$FetchSubwayStationsByLineImplCopyWithImpl<
    _$FetchSubwayStationsByLineImpl
  >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() fetchSubwayStations,
    required TResult Function(int line) fetchSubwayStationsByLine,
  }) {
    return fetchSubwayStationsByLine(line);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? fetchSubwayStations,
    TResult? Function(int line)? fetchSubwayStationsByLine,
  }) {
    return fetchSubwayStationsByLine?.call(line);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? fetchSubwayStations,
    TResult Function(int line)? fetchSubwayStationsByLine,
    required TResult orElse(),
  }) {
    if (fetchSubwayStationsByLine != null) {
      return fetchSubwayStationsByLine(line);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchSubwayStations value) fetchSubwayStations,
    required TResult Function(_FetchSubwayStationsByLine value)
    fetchSubwayStationsByLine,
  }) {
    return fetchSubwayStationsByLine(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchSubwayStations value)? fetchSubwayStations,
    TResult? Function(_FetchSubwayStationsByLine value)?
    fetchSubwayStationsByLine,
  }) {
    return fetchSubwayStationsByLine?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchSubwayStations value)? fetchSubwayStations,
    TResult Function(_FetchSubwayStationsByLine value)?
    fetchSubwayStationsByLine,
    required TResult orElse(),
  }) {
    if (fetchSubwayStationsByLine != null) {
      return fetchSubwayStationsByLine(this);
    }
    return orElse();
  }
}

abstract class _FetchSubwayStationsByLine implements SubwayStationsEvent {
  const factory _FetchSubwayStationsByLine({required final int line}) =
      _$FetchSubwayStationsByLineImpl;

  int get line;

  /// Create a copy of SubwayStationsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FetchSubwayStationsByLineImplCopyWith<_$FetchSubwayStationsByLineImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SubwayStationsState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SubwayStation> stations) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SubwayStation> stations)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SubwayStation> stations)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubwayStationsStateCopyWith<$Res> {
  factory $SubwayStationsStateCopyWith(
    SubwayStationsState value,
    $Res Function(SubwayStationsState) then,
  ) = _$SubwayStationsStateCopyWithImpl<$Res, SubwayStationsState>;
}

/// @nodoc
class _$SubwayStationsStateCopyWithImpl<$Res, $Val extends SubwayStationsState>
    implements $SubwayStationsStateCopyWith<$Res> {
  _$SubwayStationsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
    _$InitialImpl value,
    $Res Function(_$InitialImpl) then,
  ) = __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$SubwayStationsStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
    _$InitialImpl _value,
    $Res Function(_$InitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'SubwayStationsState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SubwayStation> stations) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SubwayStation> stations)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SubwayStation> stations)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements SubwayStationsState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$SubwayStationsStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'SubwayStationsState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SubwayStation> stations) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SubwayStation> stations)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SubwayStation> stations)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements SubwayStationsState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
    _$LoadedImpl value,
    $Res Function(_$LoadedImpl) then,
  ) = __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<SubwayStation> stations});
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$SubwayStationsStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
    _$LoadedImpl _value,
    $Res Function(_$LoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stations = null}) {
    return _then(
      _$LoadedImpl(
        stations:
            null == stations
                ? _value._stations
                : stations // ignore: cast_nullable_to_non_nullable
                    as List<SubwayStation>,
      ),
    );
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl({required final List<SubwayStation> stations})
    : _stations = stations;

  final List<SubwayStation> _stations;
  @override
  List<SubwayStation> get stations {
    if (_stations is EqualUnmodifiableListView) return _stations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stations);
  }

  @override
  String toString() {
    return 'SubwayStationsState.loaded(stations: $stations)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            const DeepCollectionEquality().equals(other._stations, _stations));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_stations));

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SubwayStation> stations) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(stations);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SubwayStation> stations)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(stations);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SubwayStation> stations)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(stations);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements SubwayStationsState {
  const factory _Loaded({required final List<SubwayStation> stations}) =
      _$LoadedImpl;

  List<SubwayStation> get stations;

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$SubwayStationsStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        message:
            null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'SubwayStationsState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<SubwayStation> stations) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<SubwayStation> stations)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<SubwayStation> stations)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements SubwayStationsState {
  const factory _Error({required final String message}) = _$ErrorImpl;

  String get message;

  /// Create a copy of SubwayStationsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
