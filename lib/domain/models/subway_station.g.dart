// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subway_station.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubwayStation _$SubwayStationFromJson(Map<String, dynamic> json) =>
    _SubwayStation(
      id: (json['id'] as num).toInt(),
      line: (json['line'] as num).toInt(),
      ordinal: (json['ordinal'] as num).toInt(),
      nameUz: json['name_uz'] as String?,
      nameRu: json['name_ru'] as String?,
      nameEn: json['name_en'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationId: (json['location_id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$SubwayStationToJson(_SubwayStation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'line': instance.line,
      'ordinal': instance.ordinal,
      'name_uz': instance.nameUz,
      'name_ru': instance.nameRu,
      'name_en': instance.nameEn,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'location_id': instance.locationId,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
