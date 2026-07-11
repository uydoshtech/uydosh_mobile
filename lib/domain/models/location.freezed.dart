// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Location {

 int get id;@JsonKey(name: "created_at") String get createdAt;@JsonKey(name: "updated_at") String get updatedAt;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_en") String? get nameEn;@JsonKey(name: "short_name_uz") String? get shortNameUz;@JsonKey(name: "short_name_ru") String? get shortNameRu;@JsonKey(name: "short_name_en") String? get shortNameEn;@JsonKey(name: "short_name") String? get shortName; double? get latitude; double? get longitude;
/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationCopyWith<Location> get copyWith => _$LocationCopyWithImpl<Location>(this as Location, _$identity);

  /// Serializes this Location to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Location&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,nameUz,nameRu,nameEn,shortNameUz,shortNameRu,shortNameEn,shortName,latitude,longitude);

@override
String toString() {
  return 'Location(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn, shortName: $shortName, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $LocationCopyWith<$Res>  {
  factory $LocationCopyWith(Location value, $Res Function(Location) _then) = _$LocationCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_en") String? shortNameEn,@JsonKey(name: "short_name") String? shortName, double? latitude, double? longitude
});




}
/// @nodoc
class _$LocationCopyWithImpl<$Res>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._self, this._then);

  final Location _self;
  final $Res Function(Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? shortNameUz = freezed,Object? shortNameRu = freezed,Object? shortNameEn = freezed,Object? shortName = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [Location].
extension LocationPatterns on Location {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Location value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Location() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Location value)  $default,){
final _that = this;
switch (_that) {
case _Location():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Location value)?  $default,){
final _that = this;
switch (_that) {
case _Location() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name")  String? shortName,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn,_that.shortName,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name")  String? shortName,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _Location():
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn,_that.shortName,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn, @JsonKey(name: "short_name")  String? shortName,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _Location() when $default != null:
return $default(_that.id,_that.createdAt,_that.updatedAt,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn,_that.shortName,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Location implements Location {
  const _Location({required this.id, @JsonKey(name: "created_at") required this.createdAt, @JsonKey(name: "updated_at") required this.updatedAt, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_en") this.nameEn, @JsonKey(name: "short_name_uz") this.shortNameUz, @JsonKey(name: "short_name_ru") this.shortNameRu, @JsonKey(name: "short_name_en") this.shortNameEn, @JsonKey(name: "short_name") this.shortName, this.latitude, this.longitude});
  factory _Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);

@override final  int id;
@override@JsonKey(name: "created_at") final  String createdAt;
@override@JsonKey(name: "updated_at") final  String updatedAt;
@override@JsonKey(name: "name_uz") final  String? nameUz;
@override@JsonKey(name: "name_ru") final  String? nameRu;
@override@JsonKey(name: "name_en") final  String? nameEn;
@override@JsonKey(name: "short_name_uz") final  String? shortNameUz;
@override@JsonKey(name: "short_name_ru") final  String? shortNameRu;
@override@JsonKey(name: "short_name_en") final  String? shortNameEn;
@override@JsonKey(name: "short_name") final  String? shortName;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationCopyWith<_Location> get copyWith => __$LocationCopyWithImpl<_Location>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Location&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn)&&(identical(other.shortName, shortName) || other.shortName == shortName)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,updatedAt,nameUz,nameRu,nameEn,shortNameUz,shortNameRu,shortNameEn,shortName,latitude,longitude);

@override
String toString() {
  return 'Location(id: $id, createdAt: $createdAt, updatedAt: $updatedAt, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn, shortName: $shortName, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$LocationCopyWith<$Res> implements $LocationCopyWith<$Res> {
  factory _$LocationCopyWith(_Location value, $Res Function(_Location) _then) = __$LocationCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_en") String? shortNameEn,@JsonKey(name: "short_name") String? shortName, double? latitude, double? longitude
});




}
/// @nodoc
class __$LocationCopyWithImpl<$Res>
    implements _$LocationCopyWith<$Res> {
  __$LocationCopyWithImpl(this._self, this._then);

  final _Location _self;
  final $Res Function(_Location) _then;

/// Create a copy of Location
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? updatedAt = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? shortNameUz = freezed,Object? shortNameRu = freezed,Object? shortNameEn = freezed,Object? shortName = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_Location(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,shortName: freezed == shortName ? _self.shortName : shortName // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
