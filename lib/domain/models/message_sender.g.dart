// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_sender.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageSender _$MessageSenderFromJson(Map<String, dynamic> json) =>
    _MessageSender(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String?,
      firebaseUid: json['firebase_uid'] as String?,
      telegramId: json['telegram_id'] as String?,
      phoneNumber: json['phone_number'] as String?,
      profile: json['profile'] == null
          ? null
          : MessageSenderProfile.fromJson(
              json['profile'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$MessageSenderToJson(_MessageSender instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firebase_uid': instance.firebaseUid,
      'telegram_id': instance.telegramId,
      'phone_number': instance.phoneNumber,
      'profile': instance.profile,
    };

_MessageSenderProfile _$MessageSenderProfileFromJson(
  Map<String, dynamic> json,
) => _MessageSenderProfile(
  name: json['name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$MessageSenderProfileToJson(
  _MessageSenderProfile instance,
) => <String, dynamic>{'name': instance.name, 'avatar_url': instance.avatarUrl};
