// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComplaintCategory {

@JsonKey(name: "name_uz") String get nameUz;@JsonKey(name: "name_ru") String get nameRu;@JsonKey(name: "name_en") String get nameEn; int? get id;@JsonKey(name: "created_at") String? get createdAt;@JsonKey(name: "updated_at") String? get updatedAt;
/// Create a copy of ComplaintCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintCategoryCopyWith<ComplaintCategory> get copyWith => _$ComplaintCategoryCopyWithImpl<ComplaintCategory>(this as ComplaintCategory, _$identity);

  /// Serializes this ComplaintCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintCategory&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameUz,nameRu,nameEn,id,createdAt,updatedAt);

@override
String toString() {
  return 'ComplaintCategory(nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, id: $id, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ComplaintCategoryCopyWith<$Res>  {
  factory $ComplaintCategoryCopyWith(ComplaintCategory value, $Res Function(ComplaintCategory) _then) = _$ComplaintCategoryCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "name_uz") String nameUz,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_en") String nameEn, int? id,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});




}
/// @nodoc
class _$ComplaintCategoryCopyWithImpl<$Res>
    implements $ComplaintCategoryCopyWith<$Res> {
  _$ComplaintCategoryCopyWithImpl(this._self, this._then);

  final ComplaintCategory _self;
  final $Res Function(ComplaintCategory) _then;

/// Create a copy of ComplaintCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nameUz = null,Object? nameRu = null,Object? nameEn = null,Object? id = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplaintCategory].
extension ComplaintCategoryPatterns on ComplaintCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintCategory value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintCategory value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  int? id, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintCategory() when $default != null:
return $default(_that.nameUz,_that.nameRu,_that.nameEn,_that.id,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  int? id, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ComplaintCategory():
return $default(_that.nameUz,_that.nameRu,_that.nameEn,_that.id,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  int? id, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintCategory() when $default != null:
return $default(_that.nameUz,_that.nameRu,_that.nameEn,_that.id,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintCategory implements ComplaintCategory {
  const _ComplaintCategory({@JsonKey(name: "name_uz") required this.nameUz, @JsonKey(name: "name_ru") required this.nameRu, @JsonKey(name: "name_en") required this.nameEn, this.id, @JsonKey(name: "created_at") this.createdAt, @JsonKey(name: "updated_at") this.updatedAt});
  factory _ComplaintCategory.fromJson(Map<String, dynamic> json) => _$ComplaintCategoryFromJson(json);

@override@JsonKey(name: "name_uz") final  String nameUz;
@override@JsonKey(name: "name_ru") final  String nameRu;
@override@JsonKey(name: "name_en") final  String nameEn;
@override final  int? id;
@override@JsonKey(name: "created_at") final  String? createdAt;
@override@JsonKey(name: "updated_at") final  String? updatedAt;

/// Create a copy of ComplaintCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintCategoryCopyWith<_ComplaintCategory> get copyWith => __$ComplaintCategoryCopyWithImpl<_ComplaintCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintCategory&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameUz,nameRu,nameEn,id,createdAt,updatedAt);

@override
String toString() {
  return 'ComplaintCategory(nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, id: $id, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ComplaintCategoryCopyWith<$Res> implements $ComplaintCategoryCopyWith<$Res> {
  factory _$ComplaintCategoryCopyWith(_ComplaintCategory value, $Res Function(_ComplaintCategory) _then) = __$ComplaintCategoryCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "name_uz") String nameUz,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_en") String nameEn, int? id,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});




}
/// @nodoc
class __$ComplaintCategoryCopyWithImpl<$Res>
    implements _$ComplaintCategoryCopyWith<$Res> {
  __$ComplaintCategoryCopyWithImpl(this._self, this._then);

  final _ComplaintCategory _self;
  final $Res Function(_ComplaintCategory) _then;

/// Create a copy of ComplaintCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nameUz = null,Object? nameRu = null,Object? nameEn = null,Object? id = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ComplaintCategory(
nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
