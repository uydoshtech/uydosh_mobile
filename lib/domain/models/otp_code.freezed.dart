// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$OtpCode {

 int get id; String get email; String get code;// 4-digit code
 String get type;// 'email_verification', 'password_reset', 'login'
@JsonKey(name: "is_used") bool get isUsed;@JsonKey(name: "expires_at") String get expiresAt;@JsonKey(name: "created_at") String get createdAt;@JsonKey(name: "updated_at") String get updatedAt;
/// Create a copy of OtpCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OtpCodeCopyWith<OtpCode> get copyWith => _$OtpCodeCopyWithImpl<OtpCode>(this as OtpCode, _$identity);

  /// Serializes this OtpCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OtpCode&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.isUsed, isUsed) || other.isUsed == isUsed)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,code,type,isUsed,expiresAt,createdAt,updatedAt);

@override
String toString() {
  return 'OtpCode(id: $id, email: $email, code: $code, type: $type, isUsed: $isUsed, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OtpCodeCopyWith<$Res>  {
  factory $OtpCodeCopyWith(OtpCode value, $Res Function(OtpCode) _then) = _$OtpCodeCopyWithImpl;
@useResult
$Res call({
 int id, String email, String code, String type,@JsonKey(name: "is_used") bool isUsed,@JsonKey(name: "expires_at") String expiresAt,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt
});




}
/// @nodoc
class _$OtpCodeCopyWithImpl<$Res>
    implements $OtpCodeCopyWith<$Res> {
  _$OtpCodeCopyWithImpl(this._self, this._then);

  final OtpCode _self;
  final $Res Function(OtpCode) _then;

/// Create a copy of OtpCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? code = null,Object? type = null,Object? isUsed = null,Object? expiresAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isUsed: null == isUsed ? _self.isUsed : isUsed // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OtpCode].
extension OtpCodePatterns on OtpCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OtpCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OtpCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OtpCode value)  $default,){
final _that = this;
switch (_that) {
case _OtpCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OtpCode value)?  $default,){
final _that = this;
switch (_that) {
case _OtpCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String email,  String code,  String type, @JsonKey(name: "is_used")  bool isUsed, @JsonKey(name: "expires_at")  String expiresAt, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OtpCode() when $default != null:
return $default(_that.id,_that.email,_that.code,_that.type,_that.isUsed,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String email,  String code,  String type, @JsonKey(name: "is_used")  bool isUsed, @JsonKey(name: "expires_at")  String expiresAt, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt)  $default,) {final _that = this;
switch (_that) {
case _OtpCode():
return $default(_that.id,_that.email,_that.code,_that.type,_that.isUsed,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String email,  String code,  String type, @JsonKey(name: "is_used")  bool isUsed, @JsonKey(name: "expires_at")  String expiresAt, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _OtpCode() when $default != null:
return $default(_that.id,_that.email,_that.code,_that.type,_that.isUsed,_that.expiresAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OtpCode implements OtpCode {
  const _OtpCode({required this.id, required this.email, required this.code, required this.type, @JsonKey(name: "is_used") required this.isUsed, @JsonKey(name: "expires_at") required this.expiresAt, @JsonKey(name: "created_at") required this.createdAt, @JsonKey(name: "updated_at") required this.updatedAt});
  factory _OtpCode.fromJson(Map<String, dynamic> json) => _$OtpCodeFromJson(json);

@override final  int id;
@override final  String email;
@override final  String code;
// 4-digit code
@override final  String type;
// 'email_verification', 'password_reset', 'login'
@override@JsonKey(name: "is_used") final  bool isUsed;
@override@JsonKey(name: "expires_at") final  String expiresAt;
@override@JsonKey(name: "created_at") final  String createdAt;
@override@JsonKey(name: "updated_at") final  String updatedAt;

/// Create a copy of OtpCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OtpCodeCopyWith<_OtpCode> get copyWith => __$OtpCodeCopyWithImpl<_OtpCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OtpCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OtpCode&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.code, code) || other.code == code)&&(identical(other.type, type) || other.type == type)&&(identical(other.isUsed, isUsed) || other.isUsed == isUsed)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,code,type,isUsed,expiresAt,createdAt,updatedAt);

@override
String toString() {
  return 'OtpCode(id: $id, email: $email, code: $code, type: $type, isUsed: $isUsed, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OtpCodeCopyWith<$Res> implements $OtpCodeCopyWith<$Res> {
  factory _$OtpCodeCopyWith(_OtpCode value, $Res Function(_OtpCode) _then) = __$OtpCodeCopyWithImpl;
@override @useResult
$Res call({
 int id, String email, String code, String type,@JsonKey(name: "is_used") bool isUsed,@JsonKey(name: "expires_at") String expiresAt,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt
});




}
/// @nodoc
class __$OtpCodeCopyWithImpl<$Res>
    implements _$OtpCodeCopyWith<$Res> {
  __$OtpCodeCopyWithImpl(this._self, this._then);

  final _OtpCode _self;
  final $Res Function(_OtpCode) _then;

/// Create a copy of OtpCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? code = null,Object? type = null,Object? isUsed = null,Object? expiresAt = null,Object? createdAt = null,Object? updatedAt = null,}) {
  return _then(_OtpCode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,isUsed: null == isUsed ? _self.isUsed : isUsed // ignore: cast_nullable_to_non_nullable
as bool,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
