// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComplaintCategoryImpl _$$ComplaintCategoryImplFromJson(
        Map<String, dynamic> json) =>
    _$ComplaintCategoryImpl(
      nameUz: json['name_uz'] as String,
      nameRu: json['name_ru'] as String,
      nameEn: json['name_en'] as String,
      id: (json['id'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ComplaintCategoryImplToJson(
        _$ComplaintCategoryImpl instance) =>
    <String, dynamic>{
      'name_uz': instance.nameUz,
      'name_ru': instance.nameRu,
      'name_en': instance.nameEn,
      'id': instance.id,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
