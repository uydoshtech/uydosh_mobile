// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OtpCodeImpl _$$OtpCodeImplFromJson(Map<String, dynamic> json) =>
    _$OtpCodeImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      isUsed: json['is_used'] as bool,
      expiresAt: json['expires_at'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );

Map<String, dynamic> _$$OtpCodeImplToJson(_$OtpCodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'code': instance.code,
      'type': instance.type,
      'is_used': instance.isUsed,
      'expires_at': instance.expiresAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
