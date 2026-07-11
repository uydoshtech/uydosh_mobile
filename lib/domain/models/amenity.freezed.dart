// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'amenity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Amenity {

 int get id;@JsonKey(name: "name_en") String get nameEn;@JsonKey(name: "name_ru") String get nameRu;@JsonKey(name: "name_uz") String get nameUz; String? get code;// Made optional since backend doesn't always provide it
 String? get icon;// Added icon field from backend response
@JsonKey(name: "created_at") String? get createdAt;@JsonKey(name: "updated_at") String? get updatedAt;
/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AmenityCopyWith<Amenity> get copyWith => _$AmenityCopyWithImpl<Amenity>(this as Amenity, _$identity);

  /// Serializes this Amenity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Amenity&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.code, code) || other.code == code)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEn,nameRu,nameUz,code,icon,createdAt,updatedAt);

@override
String toString() {
  return 'Amenity(id: $id, nameEn: $nameEn, nameRu: $nameRu, nameUz: $nameUz, code: $code, icon: $icon, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AmenityCopyWith<$Res>  {
  factory $AmenityCopyWith(Amenity value, $Res Function(Amenity) _then) = _$AmenityCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "name_en") String nameEn,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_uz") String nameUz, String? code, String? icon,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});




}
/// @nodoc
class _$AmenityCopyWithImpl<$Res>
    implements $AmenityCopyWith<$Res> {
  _$AmenityCopyWithImpl(this._self, this._then);

  final Amenity _self;
  final $Res Function(Amenity) _then;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameEn = null,Object? nameRu = null,Object? nameUz = null,Object? code = freezed,Object? icon = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Amenity].
extension AmenityPatterns on Amenity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Amenity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Amenity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Amenity value)  $default,){
final _that = this;
switch (_that) {
case _Amenity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Amenity value)?  $default,){
final _that = this;
switch (_that) {
case _Amenity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_en")  String nameEn, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_uz")  String nameUz,  String? code,  String? icon, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Amenity() when $default != null:
return $default(_that.id,_that.nameEn,_that.nameRu,_that.nameUz,_that.code,_that.icon,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_en")  String nameEn, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_uz")  String nameUz,  String? code,  String? icon, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Amenity():
return $default(_that.id,_that.nameEn,_that.nameRu,_that.nameUz,_that.code,_that.icon,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "name_en")  String nameEn, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_uz")  String nameUz,  String? code,  String? icon, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Amenity() when $default != null:
return $default(_that.id,_that.nameEn,_that.nameRu,_that.nameUz,_that.code,_that.icon,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Amenity implements Amenity {
  const _Amenity({required this.id, @JsonKey(name: "name_en") required this.nameEn, @JsonKey(name: "name_ru") required this.nameRu, @JsonKey(name: "name_uz") required this.nameUz, this.code, this.icon, @JsonKey(name: "created_at") this.createdAt, @JsonKey(name: "updated_at") this.updatedAt});
  factory _Amenity.fromJson(Map<String, dynamic> json) => _$AmenityFromJson(json);

@override final  int id;
@override@JsonKey(name: "name_en") final  String nameEn;
@override@JsonKey(name: "name_ru") final  String nameRu;
@override@JsonKey(name: "name_uz") final  String nameUz;
@override final  String? code;
// Made optional since backend doesn't always provide it
@override final  String? icon;
// Added icon field from backend response
@override@JsonKey(name: "created_at") final  String? createdAt;
@override@JsonKey(name: "updated_at") final  String? updatedAt;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AmenityCopyWith<_Amenity> get copyWith => __$AmenityCopyWithImpl<_Amenity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AmenityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Amenity&&(identical(other.id, id) || other.id == id)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.code, code) || other.code == code)&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameEn,nameRu,nameUz,code,icon,createdAt,updatedAt);

@override
String toString() {
  return 'Amenity(id: $id, nameEn: $nameEn, nameRu: $nameRu, nameUz: $nameUz, code: $code, icon: $icon, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AmenityCopyWith<$Res> implements $AmenityCopyWith<$Res> {
  factory _$AmenityCopyWith(_Amenity value, $Res Function(_Amenity) _then) = __$AmenityCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "name_en") String nameEn,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_uz") String nameUz, String? code, String? icon,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});




}
/// @nodoc
class __$AmenityCopyWithImpl<$Res>
    implements _$AmenityCopyWith<$Res> {
  __$AmenityCopyWithImpl(this._self, this._then);

  final _Amenity _self;
  final $Res Function(_Amenity) _then;

/// Create a copy of Amenity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameEn = null,Object? nameRu = null,Object? nameUz = null,Object? code = freezed,Object? icon = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Amenity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,icon: freezed == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
