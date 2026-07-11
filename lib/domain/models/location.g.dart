// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Location _$LocationFromJson(Map<String, dynamic> json) => _Location(
  id: (json['id'] as num).toInt(),
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
  nameUz: json['name_uz'] as String?,
  nameRu: json['name_ru'] as String?,
  nameEn: json['name_en'] as String?,
  shortNameUz: json['short_name_uz'] as String?,
  shortNameRu: json['short_name_ru'] as String?,
  shortNameEn: json['short_name_en'] as String?,
  shortName: json['short_name'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LocationToJson(_Location instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'name_uz': instance.nameUz,
  'name_ru': instance.nameRu,
  'name_en': instance.nameEn,
  'short_name_uz': instance.shortNameUz,
  'short_name_ru': instance.shortNameRu,
  'short_name_en': instance.shortNameEn,
  'short_name': instance.shortName,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
