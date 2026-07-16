// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'region.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Region {

 int get id;@JsonKey(name: "country_id") int? get countryId;@JsonKey(name: "name") String? get name;@JsonKey(name: "name_en") String? get nameEn;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "short_name") String? get shortName;@JsonKey(name: "short_name_en") String? get shortNameEn;@JsonKey(name: "short_name_ru") String? get shortNameRu;@JsonKey(name: "short_name_uz") String? get shortNameUz;@JsonKey(name: "latitude") String? get latitude;@JsonKey(name: "longitude") String? get longitude;@JsonKey(name: "created_at") String? get createdAt;@JsonKey(name: "updated_at") String? get updatedAt;
/// Create a copy of Region
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RegionCopyWith<Region> get copyWith => _$RegionCopyWithImpl<Region>(this as Region, _$identity);

  /// Serializes this Region to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Region&&(identical(other.id, id) || other.id == id)&&(identical(other.countryId, countryId) || other.countryId == countryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,countryId,name,nameEn,nameRu,nameUz,shortName,shortNameEn,shortNameRu,shortNameUz,latitude,longitude,createdAt,updatedAt);

@override
String toString() {
  return 'Region(id: $id, countryId: $countryId, name: $name, nameEn: $nameEn, nameRu: $nameRu, nameUz: $nameUz, shortName: $shortName, shortNameEn: $shortNameEn, shortNameRu: $shortNameRu, shortNameUz: $shortNameUz, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RegionCopyWith<$Res>  {
  factory $RegionCopyWith(Region value, $Res Function(Region) _then) = _$RegionCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "country_id") int? countryId,@JsonKey(name: "name") String? name,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "short_name") String? shortName,@JsonKey(name: "short_name_en") String? shortNameEn,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "latitude") String? latitude,@JsonKey(name: "longitude") String? longitude,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});




}
/// @nodoc
class _$RegionCopyWithImpl<$Res>
    implements $RegionCopyWith<$Res> {
  _$RegionCopyWithImpl(this._self, this._then);

  final Region _self;
  final $Res Function(Region) _then;

/// Create a copy of Region
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? countryId = freezed,Object? name = freezed,Object? nameEn = freezed,Object? nameRu = freezed,Object? nameUz = freezed,Object? shortName = freezed,Object? shortNameEn = freezed,Object? shortNameRu = freezed,Object? shortNameUz = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,countryId: freezed == countryId ? _self.countryId : countryId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Region].
extension RegionPatterns on Region {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Region value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Region() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Region value)  $default,){
final _that = this;
switch (_that) {
case _Region():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Region value)?  $default,){
final _that = this;
switch (_that) {
case _Region() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "country_id")  int? countryId, @JsonKey(name: "name")  String? name, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "short_name")  String? shortName, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Region() when $default != null:
return $default(_that.id,_that.countryId,_that.name,_that.nameEn,_that.nameRu,_that.nameUz,_that.shortName,_that.shortNameEn,_that.shortNameRu,_that.shortNameUz,_that.latitude,_that.longitude,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "country_id")  int? countryId, @JsonKey(name: "name")  String? name, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "short_name")  String? shortName, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Region():
return $default(_that.id,_that.countryId,_that.name,_that.nameEn,_that.nameRu,_that.nameUz,_that.shortName,_that.shortNameEn,_that.shortNameRu,_that.shortNameUz,_that.latitude,_that.longitude,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "country_id")  int? countryId, @JsonKey(name: "name")  String? name, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "short_name")  String? shortName, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Region() when $default != null:
return $default(_that.id,_that.countryId,_that.name,_that.nameEn,_that.nameRu,_that.nameUz,_that.shortName,_that.shortNameEn,_that.shortNameRu,_that.shortNameUz,_that.latitude,_that.longitude,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Region implements Region {
  const _Region({required this.id, @JsonKey(name: "country_id") this.countryId, @JsonKey(name: "name") this.name, @JsonKey(name: "name_en") this.nameEn, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "short_name") this.shortName, @JsonKey(name: "short_name_en") this.shortNameEn, @JsonKey(name: "short_name_ru") this.shortNameRu, @JsonKey(name: "short_name_uz") this.shortNameUz, @JsonKey(name: "latitude") this.latitude, @JsonKey(name: "longitude") this.longitude, @JsonKey(name: "created_at") this.createdAt, @JsonKey(name: "updated_at") this.updatedAt});
  factory _Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);

@override final  int id;
@override@JsonKey(name: "country_id") final  int? countryId;
@override@JsonKey(name: "name") final  String? name;
@override@JsonKey(name: "name_en") final  String? nameEn;
@override@JsonKey(name: "name_ru") final  String? nameRu;
@override@JsonKey(name: "name_uz") final  String? nameUz;
@override@JsonKey(name: "short_name") final  String? shortName;
@override@JsonKey(name: "short_name_en") final  String? shortNameEn;
@override@JsonKey(name: "short_name_ru") final  String? shortNameRu;
@override@JsonKey(name: "short_name_uz") final  String? shortNameUz;
@override@JsonKey(name: "latitude") final  String? latitude;
@override@JsonKey(name: "longitude") final  String? longitude;
@override@JsonKey(name: "created_at") final  String? createdAt;
@override@JsonKey(name: "updated_at") final  String? updatedAt;

/// Create a copy of Region
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RegionCopyWith<_Region> get copyWith => __$RegionCopyWithImpl<_Region>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RegionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Region&&(identical(other.id, id) || other.id == id)&&(identical(other.countryId, countryId) || other.countryId == countryId)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,countryId,name,nameEn,nameRu,nameUz,shortName,shortNameEn,shortNameRu,shortNameUz,latitude,longitude,createdAt,updatedAt);

@override
String toString() {
  return 'Region(id: $id, countryId: $countryId, name: $name, nameEn: $nameEn, nameRu: $nameRu, nameUz: $nameUz, shortName: $shortName, shortNameEn: $shortNameEn, shortNameRu: $shortNameRu, shortNameUz: $shortNameUz, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RegionCopyWith<$Res> implements $RegionCopyWith<$Res> {
  factory _$RegionCopyWith(_Region value, $Res Function(_Region) _then) = __$RegionCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "country_id") int? countryId,@JsonKey(name: "name") String? name,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "short_name") String? shortName,@JsonKey(name: "short_name_en") String? shortNameEn,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "latitude") String? latitude,@JsonKey(name: "longitude") String? longitude,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});




}
/// @nodoc
class __$RegionCopyWithImpl<$Res>
    implements _$RegionCopyWith<$Res> {
  __$RegionCopyWithImpl(this._self, this._then);

  final _Region _self;
  final $Res Function(_Region) _then;

/// Create a copy of Region
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? countryId = freezed,Object? name = freezed,Object? nameEn = freezed,Object? nameRu = freezed,Object? nameUz = freezed,Object? shortName = freezed,Object? shortNameEn = freezed,Object? shortNameRu = freezed,Object? shortNameUz = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Region(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,countryId: freezed == countryId ? _self.countryId : countryId // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
