// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'university.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$University {

@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertFromJson) int get id;@JsonKey(name: "name") String? get name;@JsonKey(name: "name_en") String? get nameEn;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "short_name") String? get shortName;@JsonKey(name: "short_name_en") String? get shortNameEn;@JsonKey(name: "short_name_ru") String? get shortNameRu;@JsonKey(name: "short_name_uz") String? get shortNameUz;@JsonKey(name: "latitude") String? get latitude;@JsonKey(name: "longitude") String? get longitude;@JsonKey(name: "location_id") int? get locationId;@JsonKey(name: "created_at") String? get createdAt;@JsonKey(name: "updated_at") String? get updatedAt;@JsonKey(name: "location") Map<String, dynamic>? get location;
/// Create a copy of University
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UniversityCopyWith<University> get copyWith => _$UniversityCopyWithImpl<University>(this as University, _$identity);

  /// Serializes this University to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is University&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.location, location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nameEn,nameRu,nameUz,shortName,shortNameEn,shortNameRu,shortNameUz,latitude,longitude,locationId,createdAt,updatedAt,const DeepCollectionEquality().hash(location));

@override
String toString() {
  return 'University(id: $id, name: $name, nameEn: $nameEn, nameRu: $nameRu, nameUz: $nameUz, shortName: $shortName, shortNameEn: $shortNameEn, shortNameRu: $shortNameRu, shortNameUz: $shortNameUz, latitude: $latitude, longitude: $longitude, locationId: $locationId, createdAt: $createdAt, updatedAt: $updatedAt, location: $location)';
}


}

/// @nodoc
abstract mixin class $UniversityCopyWith<$Res>  {
  factory $UniversityCopyWith(University value, $Res Function(University) _then) = _$UniversityCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertFromJson) int id,@JsonKey(name: "name") String? name,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "short_name") String? shortName,@JsonKey(name: "short_name_en") String? shortNameEn,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "latitude") String? latitude,@JsonKey(name: "longitude") String? longitude,@JsonKey(name: "location_id") int? locationId,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt,@JsonKey(name: "location") Map<String, dynamic>? location
});




}
/// @nodoc
class _$UniversityCopyWithImpl<$Res>
    implements $UniversityCopyWith<$Res> {
  _$UniversityCopyWithImpl(this._self, this._then);

  final University _self;
  final $Res Function(University) _then;

/// Create a copy of University
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = freezed,Object? nameEn = freezed,Object? nameRu = freezed,Object? nameUz = freezed,Object? shortName = freezed,Object? shortNameEn = freezed,Object? shortNameRu = freezed,Object? shortNameUz = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? location = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [University].
extension UniversityPatterns on University {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _University value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _University() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _University value)  $default,){
final _that = this;
switch (_that) {
case _University():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _University value)?  $default,){
final _that = this;
switch (_that) {
case _University() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertFromJson)  int id, @JsonKey(name: "name")  String? name, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "short_name")  String? shortName, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt, @JsonKey(name: "location")  Map<String, dynamic>? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _University() when $default != null:
return $default(_that.id,_that.name,_that.nameEn,_that.nameRu,_that.nameUz,_that.shortName,_that.shortNameEn,_that.shortNameRu,_that.shortNameUz,_that.latitude,_that.longitude,_that.locationId,_that.createdAt,_that.updatedAt,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertFromJson)  int id, @JsonKey(name: "name")  String? name, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "short_name")  String? shortName, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt, @JsonKey(name: "location")  Map<String, dynamic>? location)  $default,) {final _that = this;
switch (_that) {
case _University():
return $default(_that.id,_that.name,_that.nameEn,_that.nameRu,_that.nameUz,_that.shortName,_that.shortNameEn,_that.shortNameRu,_that.shortNameUz,_that.latitude,_that.longitude,_that.locationId,_that.createdAt,_that.updatedAt,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertFromJson)  int id, @JsonKey(name: "name")  String? name, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "short_name")  String? shortName, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt, @JsonKey(name: "location")  Map<String, dynamic>? location)?  $default,) {final _that = this;
switch (_that) {
case _University() when $default != null:
return $default(_that.id,_that.name,_that.nameEn,_that.nameRu,_that.nameUz,_that.shortName,_that.shortNameEn,_that.shortNameRu,_that.shortNameUz,_that.latitude,_that.longitude,_that.locationId,_that.createdAt,_that.updatedAt,_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _University implements University {
  const _University({@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertFromJson) required this.id, @JsonKey(name: "name") this.name, @JsonKey(name: "name_en") this.nameEn, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "short_name") this.shortName, @JsonKey(name: "short_name_en") this.shortNameEn, @JsonKey(name: "short_name_ru") this.shortNameRu, @JsonKey(name: "short_name_uz") this.shortNameUz, @JsonKey(name: "latitude") this.latitude, @JsonKey(name: "longitude") this.longitude, @JsonKey(name: "location_id") this.locationId, @JsonKey(name: "created_at") this.createdAt, @JsonKey(name: "updated_at") this.updatedAt, @JsonKey(name: "location") final  Map<String, dynamic>? location}): _location = location;
  factory _University.fromJson(Map<String, dynamic> json) => _$UniversityFromJson(json);

@override@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertFromJson) final  int id;
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
@override@JsonKey(name: "location_id") final  int? locationId;
@override@JsonKey(name: "created_at") final  String? createdAt;
@override@JsonKey(name: "updated_at") final  String? updatedAt;
 final  Map<String, dynamic>? _location;
@override@JsonKey(name: "location") Map<String, dynamic>? get location {
  final value = _location;
  if (value == null) return null;
  if (_location is EqualUnmodifiableMapView) return _location;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of University
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UniversityCopyWith<_University> get copyWith => __$UniversityCopyWithImpl<_University>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UniversityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _University&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._location, _location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,nameEn,nameRu,nameUz,shortName,shortNameEn,shortNameRu,shortNameUz,latitude,longitude,locationId,createdAt,updatedAt,const DeepCollectionEquality().hash(_location));

@override
String toString() {
  return 'University(id: $id, name: $name, nameEn: $nameEn, nameRu: $nameRu, nameUz: $nameUz, shortName: $shortName, shortNameEn: $shortNameEn, shortNameRu: $shortNameRu, shortNameUz: $shortNameUz, latitude: $latitude, longitude: $longitude, locationId: $locationId, createdAt: $createdAt, updatedAt: $updatedAt, location: $location)';
}


}

/// @nodoc
abstract mixin class _$UniversityCopyWith<$Res> implements $UniversityCopyWith<$Res> {
  factory _$UniversityCopyWith(_University value, $Res Function(_University) _then) = __$UniversityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertFromJson) int id,@JsonKey(name: "name") String? name,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "short_name") String? shortName,@JsonKey(name: "short_name_en") String? shortNameEn,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "latitude") String? latitude,@JsonKey(name: "longitude") String? longitude,@JsonKey(name: "location_id") int? locationId,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt,@JsonKey(name: "location") Map<String, dynamic>? location
});




}
/// @nodoc
class __$UniversityCopyWithImpl<$Res>
    implements _$UniversityCopyWith<$Res> {
  __$UniversityCopyWithImpl(this._self, this._then);

  final _University _self;
  final $Res Function(_University) _then;

/// Create a copy of University
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = freezed,Object? nameEn = freezed,Object? nameRu = freezed,Object? nameUz = freezed,Object? shortName = freezed,Object? shortNameEn = freezed,Object? shortNameRu = freezed,Object? shortNameUz = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? location = freezed,}) {
  return _then(_University(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self._location : location // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
