// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OtpCode _$OtpCodeFromJson(Map<String, dynamic> json) {
  return _OtpCode.fromJson(json);
}

/// @nodoc
mixin _$OtpCode {
  int get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError; // 4-digit code
  String get type =>
      throw _privateConstructorUsedError; // 'email_verification', 'password_reset', 'login'
  @JsonKey(name: "is_used")
  bool get isUsed => throw _privateConstructorUsedError;
  @JsonKey(name: "expires_at")
  String get expiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this OtpCode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OtpCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OtpCodeCopyWith<OtpCode> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpCodeCopyWith<$Res> {
  factory $OtpCodeCopyWith(OtpCode value, $Res Function(OtpCode) then) =
      _$OtpCodeCopyWithImpl<$Res, OtpCode>;
  @useResult
  $Res call({
    int id,
    String email,
    String code,
    String type,
    @JsonKey(name: "is_used") bool isUsed,
    @JsonKey(name: "expires_at") String expiresAt,
    @JsonKey(name: "created_at") String createdAt,
    @JsonKey(name: "updated_at") String updatedAt,
  });
}

/// @nodoc
class _$OtpCodeCopyWithImpl<$Res, $Val extends OtpCode>
    implements $OtpCodeCopyWith<$Res> {
  _$OtpCodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OtpCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? code = null,
    Object? type = null,
    Object? isUsed = null,
    Object? expiresAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            code:
                null == code
                    ? _value.code
                    : code // ignore: cast_nullable_to_non_nullable
                        as String,
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            isUsed:
                null == isUsed
                    ? _value.isUsed
                    : isUsed // ignore: cast_nullable_to_non_nullable
                        as bool,
            expiresAt:
                null == expiresAt
                    ? _value.expiresAt
                    : expiresAt // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as String,
            updatedAt:
                null == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OtpCodeImplCopyWith<$Res> implements $OtpCodeCopyWith<$Res> {
  factory _$$OtpCodeImplCopyWith(
    _$OtpCodeImpl value,
    $Res Function(_$OtpCodeImpl) then,
  ) = __$$OtpCodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String email,
    String code,
    String type,
    @JsonKey(name: "is_used") bool isUsed,
    @JsonKey(name: "expires_at") String expiresAt,
    @JsonKey(name: "created_at") String createdAt,
    @JsonKey(name: "updated_at") String updatedAt,
  });
}

/// @nodoc
class __$$OtpCodeImplCopyWithImpl<$Res>
    extends _$OtpCodeCopyWithImpl<$Res, _$OtpCodeImpl>
    implements _$$OtpCodeImplCopyWith<$Res> {
  __$$OtpCodeImplCopyWithImpl(
    _$OtpCodeImpl _value,
    $Res Function(_$OtpCodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OtpCode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? code = null,
    Object? type = null,
    Object? isUsed = null,
    Object? expiresAt = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$OtpCodeImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        code:
            null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                    as String,
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        isUsed:
            null == isUsed
                ? _value.isUsed
                : isUsed // ignore: cast_nullable_to_non_nullable
                    as bool,
        expiresAt:
            null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as String,
        updatedAt:
            null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OtpCodeImpl implements _OtpCode {
  const _$OtpCodeImpl({
    required this.id,
    required this.email,
    required this.code,
    required this.type,
    @JsonKey(name: "is_used") required this.isUsed,
    @JsonKey(name: "expires_at") required this.expiresAt,
    @JsonKey(name: "created_at") required this.createdAt,
    @JsonKey(name: "updated_at") required this.updatedAt,
  });

  factory _$OtpCodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtpCodeImplFromJson(json);

  @override
  final int id;
  @override
  final String email;
  @override
  final String code;
  // 4-digit code
  @override
  final String type;
  // 'email_verification', 'password_reset', 'login'
  @override
  @JsonKey(name: "is_used")
  final bool isUsed;
  @override
  @JsonKey(name: "expires_at")
  final String expiresAt;
  @override
  @JsonKey(name: "created_at")
  final String createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String updatedAt;

  @override
  String toString() {
    return 'OtpCode(id: $id, email: $email, code: $code, type: $type, isUsed: $isUsed, expiresAt: $expiresAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpCodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isUsed, isUsed) || other.isUsed == isUsed) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    code,
    type,
    isUsed,
    expiresAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of OtpCode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpCodeImplCopyWith<_$OtpCodeImpl> get copyWith =>
      __$$OtpCodeImplCopyWithImpl<_$OtpCodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OtpCodeImplToJson(this);
  }
}

abstract class _OtpCode implements OtpCode {
  const factory _OtpCode({
    required final int id,
    required final String email,
    required final String code,
    required final String type,
    @JsonKey(name: "is_used") required final bool isUsed,
    @JsonKey(name: "expires_at") required final String expiresAt,
    @JsonKey(name: "created_at") required final String createdAt,
    @JsonKey(name: "updated_at") required final String updatedAt,
  }) = _$OtpCodeImpl;

  factory _OtpCode.fromJson(Map<String, dynamic> json) = _$OtpCodeImpl.fromJson;

  @override
  int get id;
  @override
  String get email;
  @override
  String get code; // 4-digit code
  @override
  String get type; // 'email_verification', 'password_reset', 'login'
  @override
  @JsonKey(name: "is_used")
  bool get isUsed;
  @override
  @JsonKey(name: "expires_at")
  String get expiresAt;
  @override
  @JsonKey(name: "created_at")
  String get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String get updatedAt;

  /// Create a copy of OtpCode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OtpCodeImplCopyWith<_$OtpCodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
