// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_sender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageSenderImpl _$$MessageSenderImplFromJson(Map<String, dynamic> json) =>
    _$MessageSenderImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      firebaseUid: json['firebase_uid'] as String,
      telegramId: json['telegram_id'] as String?,
      profile: json['profile'] == null
          ? null
          : MessageSenderProfile.fromJson(
              json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MessageSenderImplToJson(_$MessageSenderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firebase_uid': instance.firebaseUid,
      'telegram_id': instance.telegramId,
      'profile': instance.profile,
    };

_$MessageSenderProfileImpl _$$MessageSenderProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$MessageSenderProfileImpl(
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$$MessageSenderProfileImplToJson(
        _$MessageSenderProfileImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'avatar_url': instance.avatarUrl,
    };
