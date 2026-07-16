// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amenity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Amenity _$AmenityFromJson(Map<String, dynamic> json) => _Amenity(
  id: (json['id'] as num).toInt(),
  nameEn: json['name_en'] as String,
  nameRu: json['name_ru'] as String,
  nameUz: json['name_uz'] as String,
  code: json['code'] as String?,
  icon: json['icon'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$AmenityToJson(_Amenity instance) => <String, dynamic>{
  'id': instance.id,
  'name_en': instance.nameEn,
  'name_ru': instance.nameRu,
  'name_uz': instance.nameUz,
  'code': instance.code,
  'icon': instance.icon,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
