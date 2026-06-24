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
      price: (json['price'] as num).toInt(),
      minPrice: (json['min_price'] as num?)?.toInt(),
      maxPrice: (json['max_price'] as num?)?.toInt(),
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      user: UserDetail.fromJson(json['user'] as Map<String, dynamic>),
      listingType: ListingTypeDetail.fromJson(
          json['listing_type'] as Map<String, dynamic>),
      description: json['description'] as String?,
      cityId: (json['city_id'] as num?)?.toInt(),
      descriptionRu: json['description_ru'] as String?,
      descriptionEn: json['description_en'] as String?,
      descriptionUz: json['description_uz'] as String?,
      subwayStationId: (json['subway_station_id'] as num?)?.toInt(),
      subwayLineId: (json['subway_line_id'] as num?)?.toInt(),
      locationId: (json['location_id'] as num?)?.toInt(),
      gender: (json['gender'] as num?)?.toInt(),
      featuredAt: json['featured_at'] as String?,
      moveInDate: json['move_in_date'] as String?,
      privateRoom: json['private_room'] as bool?,
      pointCloudUrl: json['point_cloud_url'] as String?,
      roomScanFloorLongM: (json['room_scan_floor_long_m'] as num?)?.toDouble(),
      roomScanFloorShortM:
          (json['room_scan_floor_short_m'] as num?)?.toDouble(),
      roomScanHeightM: (json['room_scan_height_m'] as num?)?.toDouble(),
      roomScanFloorAreaM2:
          (json['room_scan_floor_area_m2'] as num?)?.toDouble(),
      roomScanWorldPlusXBearingDeg:
          (json['room_scan_world_plus_x_bearing_deg'] as num?)?.toDouble(),
      roomScanNorthCorrectionDeg:
          (json['room_scan_north_correction_deg'] as num?)?.toDouble(),
      contactPhone: json['contact_phone'] as String?,
      contactTelegram: json['contact_telegram'] as String?,
      subwayStation: json['subway_station'] == null
          ? null
          : SubwayStationDetail.fromJson(
              json['subway_station'] as Map<String, dynamic>),
      searchSubwayStations: (json['search_subway_stations'] as List<dynamic>?)
          ?.map((e) => SubwayStationDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      location: json['location'] == null
          ? null
          : LocationDetail.fromJson(json['location'] as Map<String, dynamic>),
      searchLocations: (json['search_locations'] as List<dynamic>?)
          ?.map((e) => LocationDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => Amenity.fromJson(e as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
          .toList(),
      areaPriceStats: json['area_price_stats'] == null
          ? null
          : AreaPriceStats.fromJson(
              json['area_price_stats'] as Map<String, dynamic>),
      groupSizeTarget: (json['group_size_target'] as num?)?.toInt(),
      groupFormingStatus: json['group_forming_status'] as String?,
      groupCompatibilityReport: json['group_compatibility_report'] as String?,
    );

Map<String, dynamic> _$$ListingDetailImplToJson(_$ListingDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'title': instance.title,
      'listing_type_id': instance.listingTypeId,
      'price': instance.price,
      'min_price': instance.minPrice,
      'max_price': instance.maxPrice,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'user': instance.user,
      'listing_type': instance.listingType,
      'description': instance.description,
      'city_id': instance.cityId,
      'description_ru': instance.descriptionRu,
      'description_en': instance.descriptionEn,
      'description_uz': instance.descriptionUz,
      'subway_station_id': instance.subwayStationId,
      'subway_line_id': instance.subwayLineId,
      'location_id': instance.locationId,
      'gender': instance.gender,
      'featured_at': instance.featuredAt,
      'move_in_date': instance.moveInDate,
      'private_room': instance.privateRoom,
      'point_cloud_url': instance.pointCloudUrl,
      'room_scan_floor_long_m': instance.roomScanFloorLongM,
      'room_scan_floor_short_m': instance.roomScanFloorShortM,
      'room_scan_height_m': instance.roomScanHeightM,
      'room_scan_floor_area_m2': instance.roomScanFloorAreaM2,
      'room_scan_world_plus_x_bearing_deg':
          instance.roomScanWorldPlusXBearingDeg,
      'room_scan_north_correction_deg': instance.roomScanNorthCorrectionDeg,
      'contact_phone': instance.contactPhone,
      'contact_telegram': instance.contactTelegram,
      'subway_station': instance.subwayStation,
      'search_subway_stations': instance.searchSubwayStations,
      'location': instance.location,
      'search_locations': instance.searchLocations,
      'amenities': instance.amenities,
      'photos': instance.photos,
      'area_price_stats': instance.areaPriceStats,
      'group_size_target': instance.groupSizeTarget,
      'group_forming_status': instance.groupFormingStatus,
      'group_compatibility_report': instance.groupCompatibilityReport,
    };

_$UserDetailImpl _$$UserDetailImplFromJson(Map<String, dynamic> json) =>
    _$UserDetailImpl(
      id: (json['id'] as num).toInt(),
      createdAt: json['created_at'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$$UserDetailImplToJson(_$UserDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'created_at': instance.createdAt,
      'email': instance.email,
      'phone': instance.phone,
    };

_$ListingTypeDetailImpl _$$ListingTypeDetailImplFromJson(
        Map<String, dynamic> json) =>
    _$ListingTypeDetailImpl(
      id: (json['id'] as num).toInt(),
      nameUz: json['name_uz'] as String,
      nameRu: json['name_ru'] as String,
      nameEn: json['name_en'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$$ListingTypeDetailImplToJson(
        _$ListingTypeDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_uz': instance.nameUz,
      'name_ru': instance.nameRu,
      'name_en': instance.nameEn,
      'code': instance.code,
    };

_$SubwayStationDetailImpl _$$SubwayStationDetailImplFromJson(
        Map<String, dynamic> json) =>
    _$SubwayStationDetailImpl(
      id: (json['id'] as num).toInt(),
      nameUz: json['name_uz'] as String,
      nameRu: json['name_ru'] as String,
      nameEn: json['name_en'] as String,
      line: (json['line'] as num).toInt(),
    );

Map<String, dynamic> _$$SubwayStationDetailImplToJson(
        _$SubwayStationDetailImpl instance) =>
    <String, dynamic>{
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
        _$LocationDetailImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name_uz': instance.nameUz,
      'name_ru': instance.nameRu,
      'name_en': instance.nameEn,
      'short_name_uz': instance.shortNameUz,
      'short_name_ru': instance.shortNameRu,
      'short_name_en': instance.shortNameEn,
    };

_$AreaPriceStatsImpl _$$AreaPriceStatsImplFromJson(Map<String, dynamic> json) =>
    _$AreaPriceStatsImpl(
      subwayStation: json['subway_station'] == null
          ? null
          : AreaPriceBenchmark.fromJson(
              json['subway_station'] as Map<String, dynamic>),
      location: json['location'] == null
          ? null
          : AreaPriceBenchmark.fromJson(
              json['location'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AreaPriceStatsImplToJson(
        _$AreaPriceStatsImpl instance) =>
    <String, dynamic>{
      'subway_station': instance.subwayStation,
      'location': instance.location,
    };

_$AreaPriceBenchmarkImpl _$$AreaPriceBenchmarkImplFromJson(
        Map<String, dynamic> json) =>
    _$AreaPriceBenchmarkImpl(
      mean: (json['mean'] as num).toInt(),
      median: (json['median'] as num).toInt(),
      sampleCount: (json['sample_count'] as num).toInt(),
    );

Map<String, dynamic> _$$AreaPriceBenchmarkImplToJson(
        _$AreaPriceBenchmarkImpl instance) =>
    <String, dynamic>{
      'mean': instance.mean,
      'median': instance.median,
      'sample_count': instance.sampleCount,
    };
