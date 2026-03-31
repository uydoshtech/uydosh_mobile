// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoImpl _$$PhotoImplFromJson(Map<String, dynamic> json) => _$PhotoImpl(
      id: (json['id'] as num).toInt(),
      photoUrl: json['photo_url'] as String,
      photoOrder: (json['photo_order'] as num).toInt(),
      isPrimary: json['is_primary'] as bool,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$PhotoImplToJson(_$PhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'photo_url': instance.photoUrl,
      'photo_order': instance.photoOrder,
      'is_primary': instance.isPrimary,
      'created_at': instance.createdAt,
    };
