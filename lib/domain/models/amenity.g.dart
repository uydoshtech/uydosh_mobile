// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amenity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AmenityImpl _$$AmenityImplFromJson(Map<String, dynamic> json) =>
    _$AmenityImpl(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String?,
      nameEn: json['name_en'] as String,
      nameRu: json['name_ru'] as String,
      nameUz: json['name_uz'] as String,
      icon: json['icon'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$AmenityImplToJson(_$AmenityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name_en': instance.nameEn,
      'name_ru': instance.nameRu,
      'name_uz': instance.nameUz,
      'icon': instance.icon,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
