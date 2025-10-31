// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'university.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UniversityImpl _$$UniversityImplFromJson(Map<String, dynamic> json) =>
    _$UniversityImpl(
      id: NullableIntConverter.convertFromJson(json['id']),
      name: json['name'] as String?,
      nameEn: json['name_en'] as String?,
      nameRu: json['name_ru'] as String?,
      nameUz: json['name_uz'] as String?,
      shortName: json['short_name'] as String?,
      shortNameEn: json['short_name_en'] as String?,
      shortNameRu: json['short_name_ru'] as String?,
      shortNameUz: json['short_name_uz'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      locationId: (json['location_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      location: json['location'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$UniversityImplToJson(_$UniversityImpl instance) =>
    <String, dynamic>{
      'id': NullableIntConverter.convertFromJson(instance.id),
      'name': instance.name,
      'name_en': instance.nameEn,
      'name_ru': instance.nameRu,
      'name_uz': instance.nameUz,
      'short_name': instance.shortName,
      'short_name_en': instance.shortNameEn,
      'short_name_ru': instance.shortNameRu,
      'short_name_uz': instance.shortNameUz,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'location_id': instance.locationId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'location': instance.location,
    };
