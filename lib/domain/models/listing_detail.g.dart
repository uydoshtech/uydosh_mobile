// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ListingDetailImpl _$$ListingDetailImplFromJson(Map<String, dynamic> json) =>
    _$ListingDetailImpl(
      id: (json['id'] as num).toInt(),
      userId: (json['user_id'] as num).toInt(),
      title: json['title'] as String,
      listingTypeId: (json['listing_type_id'] as num).toInt(),
      minPrice: (json['min_price'] as num).toInt(),
      maxPrice: (json['max_price'] as num).toInt(),
      description: json['description'] as String?,
      subwayStationId: (json['subway_station_id'] as num?)?.toInt(),
      subwayLineId: (json['subway_line_id'] as num?)?.toInt(),
      locationId: (json['location_id'] as num?)?.toInt(),
      gender: (json['gender'] as num?)?.toInt(),
      isActive: json['is_active'] as bool,
      featuredAt: json['featured_at'] as String?,
      moveInDate: json['move_in_date'] as String?,
      privateRoom: json['private_room'] as bool?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      user: UserDetail.fromJson(json['user'] as Map<String, dynamic>),
      listingType: ListingTypeDetail.fromJson(
        json['listing_type'] as Map<String, dynamic>,
      ),
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
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => Amenity.fromJson(e as Map<String, dynamic>))
              .toList(),
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$$ListingDetailImplToJson(_$ListingDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'listing_type_id': instance.listingTypeId,
      'min_price': instance.minPrice,
      'max_price': instance.maxPrice,
      'description': instance.description,
      'subway_station_id': instance.subwayStationId,
      'subway_line_id': instance.subwayLineId,
      'location_id': instance.locationId,
      'gender': instance.gender,
      'is_active': instance.isActive,
      'featured_at': instance.featuredAt,
      'move_in_date': instance.moveInDate,
      'private_room': instance.privateRoom,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'user': instance.user,
      'listing_type': instance.listingType,
      'subway_station': instance.subwayStation,
      'location': instance.location,
      'amenities': instance.amenities,
      'photos': instance.photos,
    };

_$UserDetailImpl _$$UserDetailImplFromJson(Map<String, dynamic> json) =>
    _$UserDetailImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$$UserDetailImplToJson(_$UserDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'created_at': instance.createdAt,
    };

_$ListingTypeDetailImpl _$$ListingTypeDetailImplFromJson(
  Map<String, dynamic> json,
) => _$ListingTypeDetailImpl(
  id: (json['id'] as num).toInt(),
  nameUz: json['name_uz'] as String,
  nameRu: json['name_ru'] as String,
  nameEn: json['name_en'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$$ListingTypeDetailImplToJson(
  _$ListingTypeDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_uz': instance.nameUz,
  'name_ru': instance.nameRu,
  'name_en': instance.nameEn,
  'code': instance.code,
};

_$SubwayStationDetailImpl _$$SubwayStationDetailImplFromJson(
  Map<String, dynamic> json,
) => _$SubwayStationDetailImpl(
  id: (json['id'] as num).toInt(),
  nameUz: json['name_uz'] as String,
  nameRu: json['name_ru'] as String,
  nameEn: json['name_en'] as String,
  line: (json['line'] as num).toInt(),
);

Map<String, dynamic> _$$SubwayStationDetailImplToJson(
  _$SubwayStationDetailImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name_uz': instance.nameUz,
  'name_ru': instance.nameRu,
  'name_en': instance.nameEn,
  'line': instance.line,
};

_$LocationDetailImpl _$$LocationDetailImplFromJson(Map<String, dynamic> json) =>
    _$LocationDetailImpl(
      id: (json['id'] as num).toInt(),
      nameUz: json['name_uz'] as String,
      nameRu: json['name_ru'] as String,
      nameEn: json['name_en'] as String,
      shortNameUz: json['short_name_uz'] as String,
      shortNameRu: json['short_name_ru'] as String,
      shortNameEn: json['short_name_en'] as String,
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
