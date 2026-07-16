// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateProfileRequest _$CreateProfileRequestFromJson(
  Map<String, dynamic> json,
) => CreateProfileRequest(
  userId: (json['userId'] as num).toInt(),
  name: json['name'] as String,
  gender: (json['gender'] as num).toInt(),
  universityId: (json['universityId'] as num?)?.toInt(),
  regionId: (json['regionId'] as num?)?.toInt(),
  role: json['role'] as String?,
  preferredLanguage: json['preferredLanguage'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
);

Map<String, dynamic> _$CreateProfileRequestToJson(
  CreateProfileRequest instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'name': instance.name,
  'gender': instance.gender,
  'universityId': instance.universityId,
  'regionId': instance.regionId,
  'role': instance.role,
  'preferredLanguage': instance.preferredLanguage,
  'avatarUrl': ?instance.avatarUrl,
};
