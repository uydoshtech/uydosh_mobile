// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subway_stations_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SubwayStationsEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubwayStationsEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubwayStationsEvent()';
}


}

/// @nodoc
class $SubwayStationsEventCopyWith<$Res>  {
$SubwayStationsEventCopyWith(SubwayStationsEvent _, $Res Function(SubwayStationsEvent) __);
}


/// Adds pattern-matching-related methods to [SubwayStationsEvent].
extension SubwayStationsEventPatterns on SubwayStationsEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FetchSubwayStations value)?  fetchSubwayStations,TResult Function( _FetchSubwayStationsByLine value)?  fetchSubwayStationsByLine,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FetchSubwayStations() when fetchSubwayStations != null:
return fetchSubwayStations(_that);case _FetchSubwayStationsByLine() when fetchSubwayStationsByLine != null:
return fetchSubwayStationsByLine(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FetchSubwayStations value)  fetchSubwayStations,required TResult Function( _FetchSubwayStationsByLine value)  fetchSubwayStationsByLine,}){
final _that = this;
switch (_that) {
case _FetchSubwayStations():
return fetchSubwayStations(_that);case _FetchSubwayStationsByLine():
return fetchSubwayStationsByLine(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FetchSubwayStations value)?  fetchSubwayStations,TResult? Function( _FetchSubwayStationsByLine value)?  fetchSubwayStationsByLine,}){
final _that = this;
switch (_that) {
case _FetchSubwayStations() when fetchSubwayStations != null:
return fetchSubwayStations(_that);case _FetchSubwayStationsByLine() when fetchSubwayStationsByLine != null:
return fetchSubwayStationsByLine(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  fetchSubwayStations,TResult Function( int line)?  fetchSubwayStationsByLine,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FetchSubwayStations() when fetchSubwayStations != null:
return fetchSubwayStations();case _FetchSubwayStationsByLine() when fetchSubwayStationsByLine != null:
return fetchSubwayStationsByLine(_that.line);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  fetchSubwayStations,required TResult Function( int line)  fetchSubwayStationsByLine,}) {final _that = this;
switch (_that) {
case _FetchSubwayStations():
return fetchSubwayStations();case _FetchSubwayStationsByLine():
return fetchSubwayStationsByLine(_that.line);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  fetchSubwayStations,TResult? Function( int line)?  fetchSubwayStationsByLine,}) {final _that = this;
switch (_that) {
case _FetchSubwayStations() when fetchSubwayStations != null:
return fetchSubwayStations();case _FetchSubwayStationsByLine() when fetchSubwayStationsByLine != null:
return fetchSubwayStationsByLine(_that.line);case _:
  return null;

}
}

}

/// @nodoc


class _FetchSubwayStations implements SubwayStationsEvent {
  const _FetchSubwayStations();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchSubwayStations);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubwayStationsEvent.fetchSubwayStations()';
}


}




/// @nodoc


class _FetchSubwayStationsByLine implements SubwayStationsEvent {
  const _FetchSubwayStationsByLine({required this.line});
  

 final  int line;

/// Create a copy of SubwayStationsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchSubwayStationsByLineCopyWith<_FetchSubwayStationsByLine> get copyWith => __$FetchSubwayStationsByLineCopyWithImpl<_FetchSubwayStationsByLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchSubwayStationsByLine&&(identical(other.line, line) || other.line == line));
}


@override
int get hashCode => Object.hash(runtimeType,line);

@override
String toString() {
  return 'SubwayStationsEvent.fetchSubwayStationsByLine(line: $line)';
}


}

/// @nodoc
abstract mixin class _$FetchSubwayStationsByLineCopyWith<$Res> implements $SubwayStationsEventCopyWith<$Res> {
  factory _$FetchSubwayStationsByLineCopyWith(_FetchSubwayStationsByLine value, $Res Function(_FetchSubwayStationsByLine) _then) = __$FetchSubwayStationsByLineCopyWithImpl;
@useResult
$Res call({
 int line
});




}
/// @nodoc
class __$FetchSubwayStationsByLineCopyWithImpl<$Res>
    implements _$FetchSubwayStationsByLineCopyWith<$Res> {
  __$FetchSubwayStationsByLineCopyWithImpl(this._self, this._then);

  final _FetchSubwayStationsByLine _self;
  final $Res Function(_FetchSubwayStationsByLine) _then;

/// Create a copy of SubwayStationsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? line = null,}) {
  return _then(_FetchSubwayStationsByLine(
line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$SubwayStationsState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubwayStationsState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubwayStationsState()';
}


}

/// @nodoc
class $SubwayStationsStateCopyWith<$Res>  {
$SubwayStationsStateCopyWith(SubwayStationsState _, $Res Function(SubwayStationsState) __);
}


/// Adds pattern-matching-related methods to [SubwayStationsState].
extension SubwayStationsStatePatterns on SubwayStationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<SubwayStation> stations)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.stations);case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<SubwayStation> stations)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.stations);case _Error():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<SubwayStation> stations)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.stations);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements SubwayStationsState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubwayStationsState.initial()';
}


}




/// @nodoc


class _Loading implements SubwayStationsState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'SubwayStationsState.loading()';
}


}




/// @nodoc


class _Loaded implements SubwayStationsState {
  const _Loaded({required final  List<SubwayStation> stations}): _stations = stations;
  

 final  List<SubwayStation> _stations;
 List<SubwayStation> get stations {
  if (_stations is EqualUnmodifiableListView) return _stations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stations);
}


/// Create a copy of SubwayStationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._stations, _stations));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_stations));

@override
String toString() {
  return 'SubwayStationsState.loaded(stations: $stations)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $SubwayStationsStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<SubwayStation> stations
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of SubwayStationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? stations = null,}) {
  return _then(_Loaded(
stations: null == stations ? _self._stations : stations // ignore: cast_nullable_to_non_nullable
as List<SubwayStation>,
  ));
}


}

/// @nodoc


class _Error implements SubwayStationsState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of SubwayStationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'SubwayStationsState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $SubwayStationsStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of SubwayStationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
