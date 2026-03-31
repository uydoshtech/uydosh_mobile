// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_sender.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageSender _$MessageSenderFromJson(Map<String, dynamic> json) {
  return _MessageSender.fromJson(json);
}

/// @nodoc
mixin _$MessageSender {
  int get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  @JsonKey(name: "firebase_uid")
  String get firebaseUid => throw _privateConstructorUsedError;
  @JsonKey(name: "telegram_id")
  String? get telegramId => throw _privateConstructorUsedError;
  MessageSenderProfile? get profile => throw _privateConstructorUsedError;

  /// Serializes this MessageSender to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageSenderCopyWith<MessageSender> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageSenderCopyWith<$Res> {
  factory $MessageSenderCopyWith(
          MessageSender value, $Res Function(MessageSender) then) =
      _$MessageSenderCopyWithImpl<$Res, MessageSender>;
  @useResult
  $Res call(
      {int id,
      String email,
      @JsonKey(name: "firebase_uid") String firebaseUid,
      @JsonKey(name: "telegram_id") String? telegramId,
      MessageSenderProfile? profile});

  $MessageSenderProfileCopyWith<$Res>? get profile;
}

/// @nodoc
class _$MessageSenderCopyWithImpl<$Res, $Val extends MessageSender>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firebaseUid = null,
    Object? telegramId = freezed,
    Object? profile = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firebaseUid: null == firebaseUid
          ? _value.firebaseUid
          : firebaseUid // ignore: cast_nullable_to_non_nullable
              as String,
      telegramId: freezed == telegramId
          ? _value.telegramId
          : telegramId // ignore: cast_nullable_to_non_nullable
              as String?,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as MessageSenderProfile?,
    ) as $Val);
  }

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageSenderProfileCopyWith<$Res>? get profile {
    if (_value.profile == null) {
      return null;
    }

    return $MessageSenderProfileCopyWith<$Res>(_value.profile!, (value) {
      return _then(_value.copyWith(profile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageSenderImplCopyWith<$Res>
    implements $MessageSenderCopyWith<$Res> {
  factory _$$MessageSenderImplCopyWith(
          _$MessageSenderImpl value, $Res Function(_$MessageSenderImpl) then) =
      __$$MessageSenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String email,
      @JsonKey(name: "firebase_uid") String firebaseUid,
      @JsonKey(name: "telegram_id") String? telegramId,
      MessageSenderProfile? profile});

  @override
  $MessageSenderProfileCopyWith<$Res>? get profile;
}

/// @nodoc
class __$$MessageSenderImplCopyWithImpl<$Res>
    extends _$MessageSenderCopyWithImpl<$Res, _$MessageSenderImpl>
    implements _$$MessageSenderImplCopyWith<$Res> {
  __$$MessageSenderImplCopyWithImpl(
      _$MessageSenderImpl _value, $Res Function(_$MessageSenderImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? firebaseUid = null,
    Object? telegramId = freezed,
    Object? profile = freezed,
  }) {
    return _then(_$MessageSenderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      firebaseUid: null == firebaseUid
          ? _value.firebaseUid
          : firebaseUid // ignore: cast_nullable_to_non_nullable
              as String,
      telegramId: freezed == telegramId
          ? _value.telegramId
          : telegramId // ignore: cast_nullable_to_non_nullable
              as String?,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as MessageSenderProfile?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageSenderImpl implements _MessageSender {
  const _$MessageSenderImpl(
      {required this.id,
      required this.email,
      @JsonKey(name: "firebase_uid") required this.firebaseUid,
      @JsonKey(name: "telegram_id") this.telegramId,
      this.profile});

  factory _$MessageSenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageSenderImplFromJson(json);

  @override
  final int id;
  @override
  final String email;
  @override
  @JsonKey(name: "firebase_uid")
  final String firebaseUid;
  @override
  @JsonKey(name: "telegram_id")
  final String? telegramId;
  @override
  final MessageSenderProfile? profile;

  @override
  String toString() {
    return 'MessageSender(id: $id, email: $email, firebaseUid: $firebaseUid, telegramId: $telegramId, profile: $profile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSenderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.firebaseUid, firebaseUid) ||
                other.firebaseUid == firebaseUid) &&
            (identical(other.telegramId, telegramId) ||
                other.telegramId == telegramId) &&
            (identical(other.profile, profile) || other.profile == profile));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, email, firebaseUid, telegramId, profile);

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSenderImplCopyWith<_$MessageSenderImpl> get copyWith =>
      __$$MessageSenderImplCopyWithImpl<_$MessageSenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageSenderImplToJson(
      this,
    );
  }
}

abstract class _MessageSender implements MessageSender {
  const factory _MessageSender(
      {required final int id,
      required final String email,
      @JsonKey(name: "firebase_uid") required final String firebaseUid,
      @JsonKey(name: "telegram_id") final String? telegramId,
      final MessageSenderProfile? profile}) = _$MessageSenderImpl;

  factory _MessageSender.fromJson(Map<String, dynamic> json) =
      _$MessageSenderImpl.fromJson;

  @override
  int get id;
  @override
  String get email;
  @override
  @JsonKey(name: "firebase_uid")
  String get firebaseUid;
  @override
  @JsonKey(name: "telegram_id")
  String? get telegramId;
  @override
  MessageSenderProfile? get profile;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageSenderImplCopyWith<_$MessageSenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageSenderProfile _$MessageSenderProfileFromJson(Map<String, dynamic> json) {
  return _MessageSenderProfile.fromJson(json);
}

/// @nodoc
mixin _$MessageSenderProfile {
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "avatar_url")
  String? get avatarUrl => throw _privateConstructorUsedError;

  /// Serializes this MessageSenderProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageSenderProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageSenderProfileCopyWith<MessageSenderProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageSenderProfileCopyWith<$Res> {
  factory $MessageSenderProfileCopyWith(MessageSenderProfile value,
          $Res Function(MessageSenderProfile) then) =
      _$MessageSenderProfileCopyWithImpl<$Res, MessageSenderProfile>;
  @useResult
  $Res call({String? name, @JsonKey(name: "avatar_url") String? avatarUrl});
}

/// @nodoc
class _$MessageSenderProfileCopyWithImpl<$Res,
        $Val extends MessageSenderProfile>
    implements $MessageSenderProfileCopyWith<$Res> {
  _$MessageSenderProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageSenderProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageSenderProfileImplCopyWith<$Res>
    implements $MessageSenderProfileCopyWith<$Res> {
  factory _$$MessageSenderProfileImplCopyWith(_$MessageSenderProfileImpl value,
          $Res Function(_$MessageSenderProfileImpl) then) =
      __$$MessageSenderProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? name, @JsonKey(name: "avatar_url") String? avatarUrl});
}

/// @nodoc
class __$$MessageSenderProfileImplCopyWithImpl<$Res>
    extends _$MessageSenderProfileCopyWithImpl<$Res, _$MessageSenderProfileImpl>
    implements _$$MessageSenderProfileImplCopyWith<$Res> {
  __$$MessageSenderProfileImplCopyWithImpl(_$MessageSenderProfileImpl _value,
      $Res Function(_$MessageSenderProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageSenderProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? avatarUrl = freezed,
  }) {
    return _then(_$MessageSenderProfileImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageSenderProfileImpl implements _MessageSenderProfile {
  const _$MessageSenderProfileImpl(
      {this.name, @JsonKey(name: "avatar_url") this.avatarUrl});

  factory _$MessageSenderProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageSenderProfileImplFromJson(json);

  @override
  final String? name;
  @override
  @JsonKey(name: "avatar_url")
  final String? avatarUrl;

  @override
  String toString() {
    return 'MessageSenderProfile(name: $name, avatarUrl: $avatarUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSenderProfileImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, avatarUrl);

  /// Create a copy of MessageSenderProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSenderProfileImplCopyWith<_$MessageSenderProfileImpl>
      get copyWith =>
          __$$MessageSenderProfileImplCopyWithImpl<_$MessageSenderProfileImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageSenderProfileImplToJson(
      this,
    );
  }
}

abstract class _MessageSenderProfile implements MessageSenderProfile {
  const factory _MessageSenderProfile(
          {final String? name,
          @JsonKey(name: "avatar_url") final String? avatarUrl}) =
      _$MessageSenderProfileImpl;

  factory _MessageSenderProfile.fromJson(Map<String, dynamic> json) =
      _$MessageSenderProfileImpl.fromJson;

  @override
  String? get name;
  @override
  @JsonKey(name: "avatar_url")
  String? get avatarUrl;

  /// Create a copy of MessageSenderProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageSenderProfileImplCopyWith<_$MessageSenderProfileImpl>
      get copyWith => throw _privateConstructorUsedError;
}
