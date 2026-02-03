// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      message: json['message'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      sessionToken: json['sessionToken'] as String,
      requiresOTP: json['requiresOTP'] as bool,
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
      'sessionToken': instance.sessionToken,
      'requiresOTP': instance.requiresOTP,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: (json['id'] as num).toInt(),
  email: json['email'] as String,
  role: json['role'] as String?,
  createdAt: json['created_at'] as String,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'role': instance.role,
      'created_at': instance.createdAt,
    };
