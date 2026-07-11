// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_exception.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiException _$ApiExceptionFromJson(Map<String, dynamic> json) => ApiException(
  status: json['status'] as String,
  message: json['message'] as String,
  traceId: json['traceId'] as String,
);

Map<String, dynamic> _$ApiExceptionToJson(ApiException instance) =>
    <String, dynamic>{
      'status': instance.status,
      'message': instance.message,
      'traceId': instance.traceId,
    };
