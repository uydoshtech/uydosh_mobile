// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ListingImpl _$$ListingImplFromJson(Map<String, dynamic> json) =>
    _$ListingImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      title: json['title'] as String,
      listingTypeId: (json['listing_type_id'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      description: json['description'] as String?,
      subwayStationId: (json['subway_station_id'] as num?)?.toInt(),
      subwayLineId: (json['subway_line_id'] as num?)?.toInt(),
      locationId: (json['location_id'] as num?)?.toInt(),
      gender: (json['gender'] as num?)?.toInt(),
      featuredAt: json['featured_at'] as String?,
      moveInDate: json['move_in_date'] as String?,
      privateRoom: json['private_room'] as bool?,
      subwayStation:
          json['subway_station'] == null
              ? null
              : SubwayStationDetail.fromJson(
                json['subway_station'] as Map<String, dynamic>,
              ),
      location:
          json['location'] == null
              ? null
              : LocationDetail.fromJson(
                json['location'] as Map<String, dynamic>,
              ),
      listingType:
          json['listing_type'] == null
              ? null
              : ListingTypeDetail.fromJson(
                json['listing_type'] as Map<String, dynamic>,
              ),
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => Amenity.fromJson(e as Map<String, dynamic>))
              .toList(),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$ListingImplToJson(_$ListingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'listing_type_id': instance.listingTypeId,
      'price': instance.price,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'description': instance.description,
      'subway_station_id': instance.subwayStationId,
      'subway_line_id': instance.subwayLineId,
      'location_id': instance.locationId,
      'gender': instance.gender,
      'featured_at': instance.featuredAt,
      'move_in_date': instance.moveInDate,
      'private_room': instance.privateRoom,
      'subway_station': instance.subwayStation,
      'location': instance.location,
      'listing_type': instance.listingType,
      'amenities': instance.amenities,
      'photos': instance.photos,
    };

_$SubwayStationDetailImpl _$$SubwayStationDetailImplFromJson(
  Map<String, dynamic> json,
) => _$SubwayStationDetailImpl(
  id: (json['id'] as num).toInt(),
  line: (json['line'] as num).toInt(),
  nameUz: json['name_uz'] as String?,
  nameRu: json['name_ru'] as String?,
  nameEn: json['name_en'] as String?,
);

Map<String, dynamic> _$$SubwayStationDetailImplToJson(
  _$SubwayStationDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'line': instance.line,
  'name_uz': instance.nameUz,
  'name_ru': instance.nameRu,
  'name_en': instance.nameEn,
};

_$LocationDetailImpl _$$LocationDetailImplFromJson(Map<String, dynamic> json) =>
    _$LocationDetailImpl(
      id: (json['id'] as num).toInt(),
      nameUz: json['name_uz'] as String?,
      nameRu: json['name_ru'] as String?,
      nameEn: json['name_en'] as String?,
      shortNameUz: json['short_name_uz'] as String?,
      shortNameRu: json['short_name_ru'] as String?,
      shortNameEn: json['short_name_en'] as String?,
    );

Map<String, dynamic> _$$LocationDetailImplToJson(
  _$LocationDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_uz': instance.nameUz,
  'name_ru': instance.nameRu,
  'name_en': instance.nameEn,
  'short_name_uz': instance.shortNameUz,
  'short_name_ru': instance.shortNameRu,
  'short_name_en': instance.shortNameEn,
};

_$ListingTypeDetailImpl _$$ListingTypeDetailImplFromJson(
  Map<String, dynamic> json,
) => _$ListingTypeDetailImpl(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  nameUz: json['name_uz'] as String?,
  nameRu: json['name_ru'] as String?,
  nameEn: json['name_en'] as String?,
);

Map<String, dynamic> _$$ListingTypeDetailImplToJson(
  _$ListingTypeDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name_uz': instance.nameUz,
  'name_ru': instance.nameRu,
  'name_en': instance.nameEn,
};
