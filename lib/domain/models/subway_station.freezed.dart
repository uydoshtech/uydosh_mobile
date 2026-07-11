// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subway_station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SubwayStation {

 int get id; int get line; int get ordinal;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_en") String? get nameEn;@JsonKey(name: "latitude") double? get latitude;@JsonKey(name: "longitude") double? get longitude;@JsonKey(name: "location_id") int? get locationId;@JsonKey(name: "created_at") String? get createdAt;@JsonKey(name: "updated_at") String? get updatedAt;
/// Create a copy of SubwayStation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubwayStationCopyWith<SubwayStation> get copyWith => _$SubwayStationCopyWithImpl<SubwayStation>(this as SubwayStation, _$identity);

  /// Serializes this SubwayStation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubwayStation&&(identical(other.id, id) || other.id == id)&&(identical(other.line, line) || other.line == line)&&(identical(other.ordinal, ordinal) || other.ordinal == ordinal)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,line,ordinal,nameUz,nameRu,nameEn,latitude,longitude,locationId,createdAt,updatedAt);

@override
String toString() {
  return 'SubwayStation(id: $id, line: $line, ordinal: $ordinal, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, latitude: $latitude, longitude: $longitude, locationId: $locationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $SubwayStationCopyWith<$Res>  {
  factory $SubwayStationCopyWith(SubwayStation value, $Res Function(SubwayStation) _then) = _$SubwayStationCopyWithImpl;
@useResult
$Res call({
 int id, int line, int ordinal,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "latitude") double? latitude,@JsonKey(name: "longitude") double? longitude,@JsonKey(name: "location_id") int? locationId,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});




}
/// @nodoc
class _$SubwayStationCopyWithImpl<$Res>
    implements $SubwayStationCopyWith<$Res> {
  _$SubwayStationCopyWithImpl(this._self, this._then);

  final SubwayStation _self;
  final $Res Function(SubwayStation) _then;

/// Create a copy of SubwayStation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? line = null,Object? ordinal = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,ordinal: null == ordinal ? _self.ordinal : ordinal // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubwayStation].
extension SubwayStationPatterns on SubwayStation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubwayStation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubwayStation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubwayStation value)  $default,){
final _that = this;
switch (_that) {
case _SubwayStation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubwayStation value)?  $default,){
final _that = this;
switch (_that) {
case _SubwayStation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int line,  int ordinal, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "latitude")  double? latitude, @JsonKey(name: "longitude")  double? longitude, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubwayStation() when $default != null:
return $default(_that.id,_that.line,_that.ordinal,_that.nameUz,_that.nameRu,_that.nameEn,_that.latitude,_that.longitude,_that.locationId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int line,  int ordinal, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "latitude")  double? latitude, @JsonKey(name: "longitude")  double? longitude, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _SubwayStation():
return $default(_that.id,_that.line,_that.ordinal,_that.nameUz,_that.nameRu,_that.nameEn,_that.latitude,_that.longitude,_that.locationId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int line,  int ordinal, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "latitude")  double? latitude, @JsonKey(name: "longitude")  double? longitude, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _SubwayStation() when $default != null:
return $default(_that.id,_that.line,_that.ordinal,_that.nameUz,_that.nameRu,_that.nameEn,_that.latitude,_that.longitude,_that.locationId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubwayStation implements SubwayStation {
  const _SubwayStation({required this.id, required this.line, required this.ordinal, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_en") this.nameEn, @JsonKey(name: "latitude") this.latitude, @JsonKey(name: "longitude") this.longitude, @JsonKey(name: "location_id") this.locationId, @JsonKey(name: "created_at") this.createdAt, @JsonKey(name: "updated_at") this.updatedAt});
  factory _SubwayStation.fromJson(Map<String, dynamic> json) => _$SubwayStationFromJson(json);

@override final  int id;
@override final  int line;
@override final  int ordinal;
@override@JsonKey(name: "name_uz") final  String? nameUz;
@override@JsonKey(name: "name_ru") final  String? nameRu;
@override@JsonKey(name: "name_en") final  String? nameEn;
@override@JsonKey(name: "latitude") final  double? latitude;
@override@JsonKey(name: "longitude") final  double? longitude;
@override@JsonKey(name: "location_id") final  int? locationId;
@override@JsonKey(name: "created_at") final  String? createdAt;
@override@JsonKey(name: "updated_at") final  String? updatedAt;

/// Create a copy of SubwayStation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubwayStationCopyWith<_SubwayStation> get copyWith => __$SubwayStationCopyWithImpl<_SubwayStation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubwayStationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubwayStation&&(identical(other.id, id) || other.id == id)&&(identical(other.line, line) || other.line == line)&&(identical(other.ordinal, ordinal) || other.ordinal == ordinal)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,line,ordinal,nameUz,nameRu,nameEn,latitude,longitude,locationId,createdAt,updatedAt);

@override
String toString() {
  return 'SubwayStation(id: $id, line: $line, ordinal: $ordinal, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, latitude: $latitude, longitude: $longitude, locationId: $locationId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$SubwayStationCopyWith<$Res> implements $SubwayStationCopyWith<$Res> {
  factory _$SubwayStationCopyWith(_SubwayStation value, $Res Function(_SubwayStation) _then) = __$SubwayStationCopyWithImpl;
@override @useResult
$Res call({
 int id, int line, int ordinal,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "latitude") double? latitude,@JsonKey(name: "longitude") double? longitude,@JsonKey(name: "location_id") int? locationId,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});




}
/// @nodoc
class __$SubwayStationCopyWithImpl<$Res>
    implements _$SubwayStationCopyWith<$Res> {
  __$SubwayStationCopyWithImpl(this._self, this._then);

  final _SubwayStation _self;
  final $Res Function(_SubwayStation) _then;

/// Create a copy of SubwayStation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? line = null,Object? ordinal = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_SubwayStation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,ordinal: null == ordinal ? _self.ordinal : ordinal // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
