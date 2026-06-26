// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ListingDetail _$ListingDetailFromJson(Map<String, dynamic> json) {
  return _ListingDetail.fromJson(json);
}

/// @nodoc
mixin _$ListingDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "user_id")
  int get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_type_id")
  int get listingTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: "price")
  int get price => throw _privateConstructorUsedError;
  @JsonKey(name: "min_price")
  int? get minPrice => throw _privateConstructorUsedError;
  @JsonKey(name: "max_price")
  int? get maxPrice => throw _privateConstructorUsedError;
  @JsonKey(name: "is_active")
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String get updatedAt => throw _privateConstructorUsedError;
  UserDetail get user => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_type")
  ListingTypeDetail get listingType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: "city_id")
  int? get cityId => throw _privateConstructorUsedError;
  @JsonKey(name: "description_ru")
  String? get descriptionRu => throw _privateConstructorUsedError;
  @JsonKey(name: "description_en")
  String? get descriptionEn => throw _privateConstructorUsedError;
  @JsonKey(name: "description_uz")
  String? get descriptionUz => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station_id")
  int? get subwayStationId => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_line_id")
  int? get subwayLineId => throw _privateConstructorUsedError;
  @JsonKey(name: "location_id")
  int? get locationId => throw _privateConstructorUsedError;
  int? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: "featured_at")
  String? get featuredAt => throw _privateConstructorUsedError;
  @JsonKey(name: "move_in_date")
  String? get moveInDate => throw _privateConstructorUsedError;
  @JsonKey(name: "private_room")
  bool? get privateRoom => throw _privateConstructorUsedError;
  @JsonKey(name: "point_cloud_url")
  String? get pointCloudUrl => throw _privateConstructorUsedError;
  @JsonKey(name: "room_scan_floor_long_m")
  double? get roomScanFloorLongM => throw _privateConstructorUsedError;
  @JsonKey(name: "room_scan_floor_short_m")
  double? get roomScanFloorShortM => throw _privateConstructorUsedError;
  @JsonKey(name: "room_scan_height_m")
  double? get roomScanHeightM => throw _privateConstructorUsedError;
  @JsonKey(name: "room_scan_floor_area_m2")
  double? get roomScanFloorAreaM2 => throw _privateConstructorUsedError;
  @JsonKey(name: "room_scan_world_plus_x_bearing_deg")
  double? get roomScanWorldPlusXBearingDeg =>
      throw _privateConstructorUsedError;
  @JsonKey(name: "room_scan_north_correction_deg")
  double? get roomScanNorthCorrectionDeg => throw _privateConstructorUsedError;
  @JsonKey(name: "contact_phone")
  String? get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: "contact_telegram")
  String? get contactTelegram => throw _privateConstructorUsedError;
  @JsonKey(name: "address_latitude")
  double? get addressLatitude => throw _privateConstructorUsedError;
  @JsonKey(name: "address_longitude")
  double? get addressLongitude => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station")
  SubwayStationDetail? get subwayStation => throw _privateConstructorUsedError;
  @JsonKey(name: "search_subway_stations")
  List<SubwayStationDetail>? get searchSubwayStations =>
      throw _privateConstructorUsedError;
  LocationDetail? get location => throw _privateConstructorUsedError;
  @JsonKey(name: "search_locations")
  List<LocationDetail>? get searchLocations =>
      throw _privateConstructorUsedError;
  List<Amenity>? get amenities => throw _privateConstructorUsedError;
  List<Photo>? get photos => throw _privateConstructorUsedError;
  @JsonKey(name: "area_price_stats")
  AreaPriceStats? get areaPriceStats => throw _privateConstructorUsedError;
  @JsonKey(name: "nearby_stores")
  List<ListingNearbyStore>? get nearbyStores =>
      throw _privateConstructorUsedError;
  @JsonKey(name: "group_size_target")
  int? get groupSizeTarget => throw _privateConstructorUsedError;
  @JsonKey(name: "group_forming_status")
  String? get groupFormingStatus => throw _privateConstructorUsedError;
  @JsonKey(name: "group_compatibility_report")
  String? get groupCompatibilityReport => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  ListingGroupContext? get groupContext => throw _privateConstructorUsedError;

  /// Serializes this ListingDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingDetailCopyWith<ListingDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingDetailCopyWith<$Res> {
  factory $ListingDetailCopyWith(
          ListingDetail value, $Res Function(ListingDetail) then) =
      _$ListingDetailCopyWithImpl<$Res, ListingDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "user_id") int userId,
      String title,
      @JsonKey(name: "listing_type_id") int listingTypeId,
      @JsonKey(name: "price") int price,
      @JsonKey(name: "min_price") int? minPrice,
      @JsonKey(name: "max_price") int? maxPrice,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      UserDetail user,
      @JsonKey(name: "listing_type") ListingTypeDetail listingType,
      String? description,
      @JsonKey(name: "city_id") int? cityId,
      @JsonKey(name: "description_ru") String? descriptionRu,
      @JsonKey(name: "description_en") String? descriptionEn,
      @JsonKey(name: "description_uz") String? descriptionUz,
      @JsonKey(name: "subway_station_id") int? subwayStationId,
      @JsonKey(name: "subway_line_id") int? subwayLineId,
      @JsonKey(name: "location_id") int? locationId,
      int? gender,
      @JsonKey(name: "featured_at") String? featuredAt,
      @JsonKey(name: "move_in_date") String? moveInDate,
      @JsonKey(name: "private_room") bool? privateRoom,
      @JsonKey(name: "point_cloud_url") String? pointCloudUrl,
      @JsonKey(name: "room_scan_floor_long_m") double? roomScanFloorLongM,
      @JsonKey(name: "room_scan_floor_short_m") double? roomScanFloorShortM,
      @JsonKey(name: "room_scan_height_m") double? roomScanHeightM,
      @JsonKey(name: "room_scan_floor_area_m2") double? roomScanFloorAreaM2,
      @JsonKey(name: "room_scan_world_plus_x_bearing_deg")
      double? roomScanWorldPlusXBearingDeg,
      @JsonKey(name: "room_scan_north_correction_deg")
      double? roomScanNorthCorrectionDeg,
      @JsonKey(name: "contact_phone") String? contactPhone,
      @JsonKey(name: "contact_telegram") String? contactTelegram,
      @JsonKey(name: "address_latitude") double? addressLatitude,
      @JsonKey(name: "address_longitude") double? addressLongitude,
      @JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,
      @JsonKey(name: "search_subway_stations")
      List<SubwayStationDetail>? searchSubwayStations,
      LocationDetail? location,
      @JsonKey(name: "search_locations") List<LocationDetail>? searchLocations,
      List<Amenity>? amenities,
      List<Photo>? photos,
      @JsonKey(name: "area_price_stats") AreaPriceStats? areaPriceStats,
      @JsonKey(name: "nearby_stores") List<ListingNearbyStore>? nearbyStores,
      @JsonKey(name: "group_size_target") int? groupSizeTarget,
      @JsonKey(name: "group_forming_status") String? groupFormingStatus,
      @JsonKey(name: "group_compatibility_report")
      String? groupCompatibilityReport,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ListingGroupContext? groupContext});

  $UserDetailCopyWith<$Res> get user;
  $ListingTypeDetailCopyWith<$Res> get listingType;
  $SubwayStationDetailCopyWith<$Res>? get subwayStation;
  $LocationDetailCopyWith<$Res>? get location;
  $AreaPriceStatsCopyWith<$Res>? get areaPriceStats;
}

/// @nodoc
class _$ListingDetailCopyWithImpl<$Res, $Val extends ListingDetail>
    implements $ListingDetailCopyWith<$Res> {
  _$ListingDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? listingTypeId = null,
    Object? price = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? user = null,
    Object? listingType = null,
    Object? description = freezed,
    Object? cityId = freezed,
    Object? descriptionRu = freezed,
    Object? descriptionEn = freezed,
    Object? descriptionUz = freezed,
    Object? subwayStationId = freezed,
    Object? subwayLineId = freezed,
    Object? locationId = freezed,
    Object? gender = freezed,
    Object? featuredAt = freezed,
    Object? moveInDate = freezed,
    Object? privateRoom = freezed,
    Object? pointCloudUrl = freezed,
    Object? roomScanFloorLongM = freezed,
    Object? roomScanFloorShortM = freezed,
    Object? roomScanHeightM = freezed,
    Object? roomScanFloorAreaM2 = freezed,
    Object? roomScanWorldPlusXBearingDeg = freezed,
    Object? roomScanNorthCorrectionDeg = freezed,
    Object? contactPhone = freezed,
    Object? contactTelegram = freezed,
    Object? addressLatitude = freezed,
    Object? addressLongitude = freezed,
    Object? subwayStation = freezed,
    Object? searchSubwayStations = freezed,
    Object? location = freezed,
    Object? searchLocations = freezed,
    Object? amenities = freezed,
    Object? photos = freezed,
    Object? areaPriceStats = freezed,
    Object? nearbyStores = freezed,
    Object? groupSizeTarget = freezed,
    Object? groupFormingStatus = freezed,
    Object? groupCompatibilityReport = freezed,
    Object? groupContext = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      listingTypeId: null == listingTypeId
          ? _value.listingTypeId
          : listingTypeId // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserDetail,
      listingType: null == listingType
          ? _value.listingType
          : listingType // ignore: cast_nullable_to_non_nullable
              as ListingTypeDetail,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
      descriptionRu: freezed == descriptionRu
          ? _value.descriptionRu
          : descriptionRu // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionEn: freezed == descriptionEn
          ? _value.descriptionEn
          : descriptionEn // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionUz: freezed == descriptionUz
          ? _value.descriptionUz
          : descriptionUz // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationId: freezed == subwayStationId
          ? _value.subwayStationId
          : subwayStationId // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayLineId: freezed == subwayLineId
          ? _value.subwayLineId
          : subwayLineId // ignore: cast_nullable_to_non_nullable
              as int?,
      locationId: freezed == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      featuredAt: freezed == featuredAt
          ? _value.featuredAt
          : featuredAt // ignore: cast_nullable_to_non_nullable
              as String?,
      moveInDate: freezed == moveInDate
          ? _value.moveInDate
          : moveInDate // ignore: cast_nullable_to_non_nullable
              as String?,
      privateRoom: freezed == privateRoom
          ? _value.privateRoom
          : privateRoom // ignore: cast_nullable_to_non_nullable
              as bool?,
      pointCloudUrl: freezed == pointCloudUrl
          ? _value.pointCloudUrl
          : pointCloudUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      roomScanFloorLongM: freezed == roomScanFloorLongM
          ? _value.roomScanFloorLongM
          : roomScanFloorLongM // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanFloorShortM: freezed == roomScanFloorShortM
          ? _value.roomScanFloorShortM
          : roomScanFloorShortM // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanHeightM: freezed == roomScanHeightM
          ? _value.roomScanHeightM
          : roomScanHeightM // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanFloorAreaM2: freezed == roomScanFloorAreaM2
          ? _value.roomScanFloorAreaM2
          : roomScanFloorAreaM2 // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanWorldPlusXBearingDeg: freezed == roomScanWorldPlusXBearingDeg
          ? _value.roomScanWorldPlusXBearingDeg
          : roomScanWorldPlusXBearingDeg // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanNorthCorrectionDeg: freezed == roomScanNorthCorrectionDeg
          ? _value.roomScanNorthCorrectionDeg
          : roomScanNorthCorrectionDeg // ignore: cast_nullable_to_non_nullable
              as double?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactTelegram: freezed == contactTelegram
          ? _value.contactTelegram
          : contactTelegram // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLatitude: freezed == addressLatitude
          ? _value.addressLatitude
          : addressLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      addressLongitude: freezed == addressLongitude
          ? _value.addressLongitude
          : addressLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      subwayStation: freezed == subwayStation
          ? _value.subwayStation
          : subwayStation // ignore: cast_nullable_to_non_nullable
              as SubwayStationDetail?,
      searchSubwayStations: freezed == searchSubwayStations
          ? _value.searchSubwayStations
          : searchSubwayStations // ignore: cast_nullable_to_non_nullable
              as List<SubwayStationDetail>?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDetail?,
      searchLocations: freezed == searchLocations
          ? _value.searchLocations
          : searchLocations // ignore: cast_nullable_to_non_nullable
              as List<LocationDetail>?,
      amenities: freezed == amenities
          ? _value.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<Amenity>?,
      photos: freezed == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>?,
      areaPriceStats: freezed == areaPriceStats
          ? _value.areaPriceStats
          : areaPriceStats // ignore: cast_nullable_to_non_nullable
              as AreaPriceStats?,
      nearbyStores: freezed == nearbyStores
          ? _value.nearbyStores
          : nearbyStores // ignore: cast_nullable_to_non_nullable
              as List<ListingNearbyStore>?,
      groupSizeTarget: freezed == groupSizeTarget
          ? _value.groupSizeTarget
          : groupSizeTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      groupFormingStatus: freezed == groupFormingStatus
          ? _value.groupFormingStatus
          : groupFormingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      groupCompatibilityReport: freezed == groupCompatibilityReport
          ? _value.groupCompatibilityReport
          : groupCompatibilityReport // ignore: cast_nullable_to_non_nullable
              as String?,
      groupContext: freezed == groupContext
          ? _value.groupContext
          : groupContext // ignore: cast_nullable_to_non_nullable
              as ListingGroupContext?,
    ) as $Val);
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDetailCopyWith<$Res> get user {
    return $UserDetailCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListingTypeDetailCopyWith<$Res> get listingType {
    return $ListingTypeDetailCopyWith<$Res>(_value.listingType, (value) {
      return _then(_value.copyWith(listingType: value) as $Val);
    });
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubwayStationDetailCopyWith<$Res>? get subwayStation {
    if (_value.subwayStation == null) {
      return null;
    }

    return $SubwayStationDetailCopyWith<$Res>(_value.subwayStation!, (value) {
      return _then(_value.copyWith(subwayStation: value) as $Val);
    });
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationDetailCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationDetailCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AreaPriceStatsCopyWith<$Res>? get areaPriceStats {
    if (_value.areaPriceStats == null) {
      return null;
    }

    return $AreaPriceStatsCopyWith<$Res>(_value.areaPriceStats!, (value) {
      return _then(_value.copyWith(areaPriceStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ListingDetailImplCopyWith<$Res>
    implements $ListingDetailCopyWith<$Res> {
  factory _$$ListingDetailImplCopyWith(
          _$ListingDetailImpl value, $Res Function(_$ListingDetailImpl) then) =
      __$$ListingDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "user_id") int userId,
      String title,
      @JsonKey(name: "listing_type_id") int listingTypeId,
      @JsonKey(name: "price") int price,
      @JsonKey(name: "min_price") int? minPrice,
      @JsonKey(name: "max_price") int? maxPrice,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      UserDetail user,
      @JsonKey(name: "listing_type") ListingTypeDetail listingType,
      String? description,
      @JsonKey(name: "city_id") int? cityId,
      @JsonKey(name: "description_ru") String? descriptionRu,
      @JsonKey(name: "description_en") String? descriptionEn,
      @JsonKey(name: "description_uz") String? descriptionUz,
      @JsonKey(name: "subway_station_id") int? subwayStationId,
      @JsonKey(name: "subway_line_id") int? subwayLineId,
      @JsonKey(name: "location_id") int? locationId,
      int? gender,
      @JsonKey(name: "featured_at") String? featuredAt,
      @JsonKey(name: "move_in_date") String? moveInDate,
      @JsonKey(name: "private_room") bool? privateRoom,
      @JsonKey(name: "point_cloud_url") String? pointCloudUrl,
      @JsonKey(name: "room_scan_floor_long_m") double? roomScanFloorLongM,
      @JsonKey(name: "room_scan_floor_short_m") double? roomScanFloorShortM,
      @JsonKey(name: "room_scan_height_m") double? roomScanHeightM,
      @JsonKey(name: "room_scan_floor_area_m2") double? roomScanFloorAreaM2,
      @JsonKey(name: "room_scan_world_plus_x_bearing_deg")
      double? roomScanWorldPlusXBearingDeg,
      @JsonKey(name: "room_scan_north_correction_deg")
      double? roomScanNorthCorrectionDeg,
      @JsonKey(name: "contact_phone") String? contactPhone,
      @JsonKey(name: "contact_telegram") String? contactTelegram,
      @JsonKey(name: "address_latitude") double? addressLatitude,
      @JsonKey(name: "address_longitude") double? addressLongitude,
      @JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,
      @JsonKey(name: "search_subway_stations")
      List<SubwayStationDetail>? searchSubwayStations,
      LocationDetail? location,
      @JsonKey(name: "search_locations") List<LocationDetail>? searchLocations,
      List<Amenity>? amenities,
      List<Photo>? photos,
      @JsonKey(name: "area_price_stats") AreaPriceStats? areaPriceStats,
      @JsonKey(name: "nearby_stores") List<ListingNearbyStore>? nearbyStores,
      @JsonKey(name: "group_size_target") int? groupSizeTarget,
      @JsonKey(name: "group_forming_status") String? groupFormingStatus,
      @JsonKey(name: "group_compatibility_report")
      String? groupCompatibilityReport,
      @JsonKey(includeFromJson: false, includeToJson: false)
      ListingGroupContext? groupContext});

  @override
  $UserDetailCopyWith<$Res> get user;
  @override
  $ListingTypeDetailCopyWith<$Res> get listingType;
  @override
  $SubwayStationDetailCopyWith<$Res>? get subwayStation;
  @override
  $LocationDetailCopyWith<$Res>? get location;
  @override
  $AreaPriceStatsCopyWith<$Res>? get areaPriceStats;
}

/// @nodoc
class __$$ListingDetailImplCopyWithImpl<$Res>
    extends _$ListingDetailCopyWithImpl<$Res, _$ListingDetailImpl>
    implements _$$ListingDetailImplCopyWith<$Res> {
  __$$ListingDetailImplCopyWithImpl(
      _$ListingDetailImpl _value, $Res Function(_$ListingDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? listingTypeId = null,
    Object? price = null,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? user = null,
    Object? listingType = null,
    Object? description = freezed,
    Object? cityId = freezed,
    Object? descriptionRu = freezed,
    Object? descriptionEn = freezed,
    Object? descriptionUz = freezed,
    Object? subwayStationId = freezed,
    Object? subwayLineId = freezed,
    Object? locationId = freezed,
    Object? gender = freezed,
    Object? featuredAt = freezed,
    Object? moveInDate = freezed,
    Object? privateRoom = freezed,
    Object? pointCloudUrl = freezed,
    Object? roomScanFloorLongM = freezed,
    Object? roomScanFloorShortM = freezed,
    Object? roomScanHeightM = freezed,
    Object? roomScanFloorAreaM2 = freezed,
    Object? roomScanWorldPlusXBearingDeg = freezed,
    Object? roomScanNorthCorrectionDeg = freezed,
    Object? contactPhone = freezed,
    Object? contactTelegram = freezed,
    Object? addressLatitude = freezed,
    Object? addressLongitude = freezed,
    Object? subwayStation = freezed,
    Object? searchSubwayStations = freezed,
    Object? location = freezed,
    Object? searchLocations = freezed,
    Object? amenities = freezed,
    Object? photos = freezed,
    Object? areaPriceStats = freezed,
    Object? nearbyStores = freezed,
    Object? groupSizeTarget = freezed,
    Object? groupFormingStatus = freezed,
    Object? groupCompatibilityReport = freezed,
    Object? groupContext = freezed,
  }) {
    return _then(_$ListingDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      listingTypeId: null == listingTypeId
          ? _value.listingTypeId
          : listingTypeId // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserDetail,
      listingType: null == listingType
          ? _value.listingType
          : listingType // ignore: cast_nullable_to_non_nullable
              as ListingTypeDetail,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
      descriptionRu: freezed == descriptionRu
          ? _value.descriptionRu
          : descriptionRu // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionEn: freezed == descriptionEn
          ? _value.descriptionEn
          : descriptionEn // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionUz: freezed == descriptionUz
          ? _value.descriptionUz
          : descriptionUz // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationId: freezed == subwayStationId
          ? _value.subwayStationId
          : subwayStationId // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayLineId: freezed == subwayLineId
          ? _value.subwayLineId
          : subwayLineId // ignore: cast_nullable_to_non_nullable
              as int?,
      locationId: freezed == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      featuredAt: freezed == featuredAt
          ? _value.featuredAt
          : featuredAt // ignore: cast_nullable_to_non_nullable
              as String?,
      moveInDate: freezed == moveInDate
          ? _value.moveInDate
          : moveInDate // ignore: cast_nullable_to_non_nullable
              as String?,
      privateRoom: freezed == privateRoom
          ? _value.privateRoom
          : privateRoom // ignore: cast_nullable_to_non_nullable
              as bool?,
      pointCloudUrl: freezed == pointCloudUrl
          ? _value.pointCloudUrl
          : pointCloudUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      roomScanFloorLongM: freezed == roomScanFloorLongM
          ? _value.roomScanFloorLongM
          : roomScanFloorLongM // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanFloorShortM: freezed == roomScanFloorShortM
          ? _value.roomScanFloorShortM
          : roomScanFloorShortM // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanHeightM: freezed == roomScanHeightM
          ? _value.roomScanHeightM
          : roomScanHeightM // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanFloorAreaM2: freezed == roomScanFloorAreaM2
          ? _value.roomScanFloorAreaM2
          : roomScanFloorAreaM2 // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanWorldPlusXBearingDeg: freezed == roomScanWorldPlusXBearingDeg
          ? _value.roomScanWorldPlusXBearingDeg
          : roomScanWorldPlusXBearingDeg // ignore: cast_nullable_to_non_nullable
              as double?,
      roomScanNorthCorrectionDeg: freezed == roomScanNorthCorrectionDeg
          ? _value.roomScanNorthCorrectionDeg
          : roomScanNorthCorrectionDeg // ignore: cast_nullable_to_non_nullable
              as double?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactTelegram: freezed == contactTelegram
          ? _value.contactTelegram
          : contactTelegram // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLatitude: freezed == addressLatitude
          ? _value.addressLatitude
          : addressLatitude // ignore: cast_nullable_to_non_nullable
              as double?,
      addressLongitude: freezed == addressLongitude
          ? _value.addressLongitude
          : addressLongitude // ignore: cast_nullable_to_non_nullable
              as double?,
      subwayStation: freezed == subwayStation
          ? _value.subwayStation
          : subwayStation // ignore: cast_nullable_to_non_nullable
              as SubwayStationDetail?,
      searchSubwayStations: freezed == searchSubwayStations
          ? _value._searchSubwayStations
          : searchSubwayStations // ignore: cast_nullable_to_non_nullable
              as List<SubwayStationDetail>?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDetail?,
      searchLocations: freezed == searchLocations
          ? _value._searchLocations
          : searchLocations // ignore: cast_nullable_to_non_nullable
              as List<LocationDetail>?,
      amenities: freezed == amenities
          ? _value._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<Amenity>?,
      photos: freezed == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>?,
      areaPriceStats: freezed == areaPriceStats
          ? _value.areaPriceStats
          : areaPriceStats // ignore: cast_nullable_to_non_nullable
              as AreaPriceStats?,
      nearbyStores: freezed == nearbyStores
          ? _value.nearbyStores
          : nearbyStores // ignore: cast_nullable_to_non_nullable
              as List<ListingNearbyStore>?,
      groupSizeTarget: freezed == groupSizeTarget
          ? _value.groupSizeTarget
          : groupSizeTarget // ignore: cast_nullable_to_non_nullable
              as int?,
      groupFormingStatus: freezed == groupFormingStatus
          ? _value.groupFormingStatus
          : groupFormingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      groupCompatibilityReport: freezed == groupCompatibilityReport
          ? _value.groupCompatibilityReport
          : groupCompatibilityReport // ignore: cast_nullable_to_non_nullable
              as String?,
      groupContext: freezed == groupContext
          ? _value.groupContext
          : groupContext // ignore: cast_nullable_to_non_nullable
              as ListingGroupContext?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingDetailImpl implements _ListingDetail {
  const _$ListingDetailImpl(
      {required this.id,
      @JsonKey(name: "user_id") required this.userId,
      required this.title,
      @JsonKey(name: "listing_type_id") required this.listingTypeId,
      @JsonKey(name: "price") required this.price,
      @JsonKey(name: "min_price") this.minPrice,
      @JsonKey(name: "max_price") this.maxPrice,
      @JsonKey(name: "is_active") required this.isActive,
      @JsonKey(name: "created_at") required this.createdAt,
      @JsonKey(name: "updated_at") required this.updatedAt,
      required this.user,
      @JsonKey(name: "listing_type") required this.listingType,
      this.description,
      @JsonKey(name: "city_id") this.cityId,
      @JsonKey(name: "description_ru") this.descriptionRu,
      @JsonKey(name: "description_en") this.descriptionEn,
      @JsonKey(name: "description_uz") this.descriptionUz,
      @JsonKey(name: "subway_station_id") this.subwayStationId,
      @JsonKey(name: "subway_line_id") this.subwayLineId,
      @JsonKey(name: "location_id") this.locationId,
      this.gender,
      @JsonKey(name: "featured_at") this.featuredAt,
      @JsonKey(name: "move_in_date") this.moveInDate,
      @JsonKey(name: "private_room") this.privateRoom,
      @JsonKey(name: "point_cloud_url") this.pointCloudUrl,
      @JsonKey(name: "room_scan_floor_long_m") this.roomScanFloorLongM,
      @JsonKey(name: "room_scan_floor_short_m") this.roomScanFloorShortM,
      @JsonKey(name: "room_scan_height_m") this.roomScanHeightM,
      @JsonKey(name: "room_scan_floor_area_m2") this.roomScanFloorAreaM2,
      @JsonKey(name: "room_scan_world_plus_x_bearing_deg")
      this.roomScanWorldPlusXBearingDeg,
      @JsonKey(name: "room_scan_north_correction_deg")
      this.roomScanNorthCorrectionDeg,
      @JsonKey(name: "contact_phone") this.contactPhone,
      @JsonKey(name: "contact_telegram") this.contactTelegram,
      @JsonKey(name: "address_latitude") this.addressLatitude,
      @JsonKey(name: "address_longitude") this.addressLongitude,
      @JsonKey(name: "subway_station") this.subwayStation,
      @JsonKey(name: "search_subway_stations")
      final List<SubwayStationDetail>? searchSubwayStations,
      this.location,
      @JsonKey(name: "search_locations")
      final List<LocationDetail>? searchLocations,
      final List<Amenity>? amenities,
      final List<Photo>? photos,
      @JsonKey(name: "area_price_stats") this.areaPriceStats,
      @JsonKey(name: "nearby_stores")
      final List<ListingNearbyStore>? nearbyStores,
      @JsonKey(name: "group_size_target") this.groupSizeTarget,
      @JsonKey(name: "group_forming_status") this.groupFormingStatus,
      @JsonKey(name: "group_compatibility_report")
      this.groupCompatibilityReport,
      @JsonKey(includeFromJson: false, includeToJson: false) this.groupContext})
      : _searchSubwayStations = searchSubwayStations,
        _searchLocations = searchLocations,
        _amenities = amenities,
        _photos = photos,
        _nearbyStores = nearbyStores;

  factory _$ListingDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "user_id")
  final int userId;
  @override
  final String title;
  @override
  @JsonKey(name: "listing_type_id")
  final int listingTypeId;
  @override
  @JsonKey(name: "price")
  final int price;
  @override
  @JsonKey(name: "min_price")
  final int? minPrice;
  @override
  @JsonKey(name: "max_price")
  final int? maxPrice;
  @override
  @JsonKey(name: "is_active")
  final bool isActive;
  @override
  @JsonKey(name: "created_at")
  final String createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String updatedAt;
  @override
  final UserDetail user;
  @override
  @JsonKey(name: "listing_type")
  final ListingTypeDetail listingType;
  @override
  final String? description;
  @override
  @JsonKey(name: "city_id")
  final int? cityId;
  @override
  @JsonKey(name: "description_ru")
  final String? descriptionRu;
  @override
  @JsonKey(name: "description_en")
  final String? descriptionEn;
  @override
  @JsonKey(name: "description_uz")
  final String? descriptionUz;
  @override
  @JsonKey(name: "subway_station_id")
  final int? subwayStationId;
  @override
  @JsonKey(name: "subway_line_id")
  final int? subwayLineId;
  @override
  @JsonKey(name: "location_id")
  final int? locationId;
  @override
  final int? gender;
  @override
  @JsonKey(name: "featured_at")
  final String? featuredAt;
  @override
  @JsonKey(name: "move_in_date")
  final String? moveInDate;
  @override
  @JsonKey(name: "private_room")
  final bool? privateRoom;
  @override
  @JsonKey(name: "point_cloud_url")
  final String? pointCloudUrl;
  @override
  @JsonKey(name: "room_scan_floor_long_m")
  final double? roomScanFloorLongM;
  @override
  @JsonKey(name: "room_scan_floor_short_m")
  final double? roomScanFloorShortM;
  @override
  @JsonKey(name: "room_scan_height_m")
  final double? roomScanHeightM;
  @override
  @JsonKey(name: "room_scan_floor_area_m2")
  final double? roomScanFloorAreaM2;
  @override
  @JsonKey(name: "room_scan_world_plus_x_bearing_deg")
  final double? roomScanWorldPlusXBearingDeg;
  @override
  @JsonKey(name: "room_scan_north_correction_deg")
  final double? roomScanNorthCorrectionDeg;
  @override
  @JsonKey(name: "contact_phone")
  final String? contactPhone;
  @override
  @JsonKey(name: "contact_telegram")
  final String? contactTelegram;
  @override
  @JsonKey(name: "address_latitude")
  final double? addressLatitude;
  @override
  @JsonKey(name: "address_longitude")
  final double? addressLongitude;
  @override
  @JsonKey(name: "subway_station")
  final SubwayStationDetail? subwayStation;
  final List<SubwayStationDetail>? _searchSubwayStations;
  @override
  @JsonKey(name: "search_subway_stations")
  List<SubwayStationDetail>? get searchSubwayStations {
    final value = _searchSubwayStations;
    if (value == null) return null;
    if (_searchSubwayStations is EqualUnmodifiableListView) {
      return _searchSubwayStations;
    }
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final LocationDetail? location;
  final List<LocationDetail>? _searchLocations;
  @override
  @JsonKey(name: "search_locations")
  List<LocationDetail>? get searchLocations {
    final value = _searchLocations;
    if (value == null) return null;
    if (_searchLocations is EqualUnmodifiableListView) {
      return _searchLocations;
    }
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Amenity>? _amenities;
  @override
  List<Amenity>? get amenities {
    final value = _amenities;
    if (value == null) return null;
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Photo>? _photos;
  @override
  List<Photo>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "area_price_stats")
  final AreaPriceStats? areaPriceStats;
  final List<ListingNearbyStore>? _nearbyStores;
  @override
  @JsonKey(name: "nearby_stores")
  List<ListingNearbyStore>? get nearbyStores {
    final value = _nearbyStores;
    if (value == null) return null;
    if (_nearbyStores is EqualUnmodifiableListView) return _nearbyStores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "group_size_target")
  final int? groupSizeTarget;
  @override
  @JsonKey(name: "group_forming_status")
  final String? groupFormingStatus;
  @override
  @JsonKey(name: "group_compatibility_report")
  final String? groupCompatibilityReport;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final ListingGroupContext? groupContext;

  @override
  String toString() {
    return 'ListingDetail(id: $id, userId: $userId, title: $title, listingTypeId: $listingTypeId, price: $price, minPrice: $minPrice, maxPrice: $maxPrice, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, user: $user, listingType: $listingType, description: $description, cityId: $cityId, descriptionRu: $descriptionRu, descriptionEn: $descriptionEn, descriptionUz: $descriptionUz, subwayStationId: $subwayStationId, subwayLineId: $subwayLineId, locationId: $locationId, gender: $gender, featuredAt: $featuredAt, moveInDate: $moveInDate, privateRoom: $privateRoom, pointCloudUrl: $pointCloudUrl, roomScanFloorLongM: $roomScanFloorLongM, roomScanFloorShortM: $roomScanFloorShortM, roomScanHeightM: $roomScanHeightM, roomScanFloorAreaM2: $roomScanFloorAreaM2, roomScanWorldPlusXBearingDeg: $roomScanWorldPlusXBearingDeg, roomScanNorthCorrectionDeg: $roomScanNorthCorrectionDeg, contactPhone: $contactPhone, contactTelegram: $contactTelegram, addressLatitude: $addressLatitude, addressLongitude: $addressLongitude, subwayStation: $subwayStation, searchSubwayStations: $searchSubwayStations, location: $location, searchLocations: $searchLocations, amenities: $amenities, photos: $photos, areaPriceStats: $areaPriceStats, nearbyStores: $nearbyStores, groupSizeTarget: $groupSizeTarget, groupFormingStatus: $groupFormingStatus, groupCompatibilityReport: $groupCompatibilityReport, groupContext: $groupContext)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.listingTypeId, listingTypeId) ||
                other.listingTypeId == listingTypeId) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.listingType, listingType) ||
                other.listingType == listingType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
            (identical(other.descriptionRu, descriptionRu) ||
                other.descriptionRu == descriptionRu) &&
            (identical(other.descriptionEn, descriptionEn) ||
                other.descriptionEn == descriptionEn) &&
            (identical(other.descriptionUz, descriptionUz) ||
                other.descriptionUz == descriptionUz) &&
            (identical(other.subwayStationId, subwayStationId) ||
                other.subwayStationId == subwayStationId) &&
            (identical(other.subwayLineId, subwayLineId) ||
                other.subwayLineId == subwayLineId) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.featuredAt, featuredAt) ||
                other.featuredAt == featuredAt) &&
            (identical(other.moveInDate, moveInDate) ||
                other.moveInDate == moveInDate) &&
            (identical(other.privateRoom, privateRoom) ||
                other.privateRoom == privateRoom) &&
            (identical(other.pointCloudUrl, pointCloudUrl) ||
                other.pointCloudUrl == pointCloudUrl) &&
            (identical(other.roomScanFloorLongM, roomScanFloorLongM) ||
                other.roomScanFloorLongM == roomScanFloorLongM) &&
            (identical(other.roomScanFloorShortM, roomScanFloorShortM) ||
                other.roomScanFloorShortM == roomScanFloorShortM) &&
            (identical(other.roomScanHeightM, roomScanHeightM) ||
                other.roomScanHeightM == roomScanHeightM) &&
            (identical(other.roomScanFloorAreaM2, roomScanFloorAreaM2) ||
                other.roomScanFloorAreaM2 == roomScanFloorAreaM2) &&
            (identical(other.roomScanWorldPlusXBearingDeg, roomScanWorldPlusXBearingDeg) ||
                other.roomScanWorldPlusXBearingDeg ==
                    roomScanWorldPlusXBearingDeg) &&
            (identical(other.roomScanNorthCorrectionDeg, roomScanNorthCorrectionDeg) ||
                other.roomScanNorthCorrectionDeg ==
                    roomScanNorthCorrectionDeg) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactTelegram, contactTelegram) ||
                other.contactTelegram == contactTelegram) &&
            (identical(other.addressLatitude, addressLatitude) ||
                other.addressLatitude == addressLatitude) &&
            (identical(other.addressLongitude, addressLongitude) ||
                other.addressLongitude == addressLongitude) &&
            (identical(other.subwayStation, subwayStation) ||
                other.subwayStation == subwayStation) &&
            const DeepCollectionEquality()
                .equals(other._searchSubwayStations, _searchSubwayStations) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._searchLocations, _searchLocations) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.areaPriceStats, areaPriceStats) ||
                other.areaPriceStats == areaPriceStats) &&
            const DeepCollectionEquality()
                .equals(other._nearbyStores, _nearbyStores) &&
            (identical(other.groupSizeTarget, groupSizeTarget) ||
                other.groupSizeTarget == groupSizeTarget) &&
            (identical(other.groupFormingStatus, groupFormingStatus) ||
                other.groupFormingStatus == groupFormingStatus) &&
            (identical(
                    other.groupCompatibilityReport, groupCompatibilityReport) ||
                other.groupCompatibilityReport == groupCompatibilityReport) &&
            (identical(other.groupContext, groupContext) ||
                other.groupContext == groupContext));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        title,
        listingTypeId,
        price,
        minPrice,
        maxPrice,
        isActive,
        createdAt,
        updatedAt,
        user,
        listingType,
        description,
        cityId,
        descriptionRu,
        descriptionEn,
        descriptionUz,
        subwayStationId,
        subwayLineId,
        locationId,
        gender,
        featuredAt,
        moveInDate,
        privateRoom,
        pointCloudUrl,
        roomScanFloorLongM,
        roomScanFloorShortM,
        roomScanHeightM,
        roomScanFloorAreaM2,
        roomScanWorldPlusXBearingDeg,
        roomScanNorthCorrectionDeg,
        contactPhone,
        contactTelegram,
        addressLatitude,
        addressLongitude,
        subwayStation,
        const DeepCollectionEquality().hash(_searchSubwayStations),
        location,
        const DeepCollectionEquality().hash(_searchLocations),
        const DeepCollectionEquality().hash(_amenities),
        const DeepCollectionEquality().hash(_photos),
        areaPriceStats,
        const DeepCollectionEquality().hash(_nearbyStores),
        groupSizeTarget,
        groupFormingStatus,
        groupCompatibilityReport,
        groupContext
      ]);

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingDetailImplCopyWith<_$ListingDetailImpl> get copyWith =>
      __$$ListingDetailImplCopyWithImpl<_$ListingDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingDetailImplToJson(
      this,
    );
  }
}

abstract class _ListingDetail implements ListingDetail {
  const factory _ListingDetail(
      {required final int id,
      @JsonKey(name: "user_id") required final int userId,
      required final String title,
      @JsonKey(name: "listing_type_id") required final int listingTypeId,
      @JsonKey(name: "price") required final int price,
      @JsonKey(name: "min_price") final int? minPrice,
      @JsonKey(name: "max_price") final int? maxPrice,
      @JsonKey(name: "is_active") required final bool isActive,
      @JsonKey(name: "created_at") required final String createdAt,
      @JsonKey(name: "updated_at") required final String updatedAt,
      required final UserDetail user,
      @JsonKey(name: "listing_type")
      required final ListingTypeDetail listingType,
      final String? description,
      @JsonKey(name: "city_id") final int? cityId,
      @JsonKey(name: "description_ru") final String? descriptionRu,
      @JsonKey(name: "description_en") final String? descriptionEn,
      @JsonKey(name: "description_uz") final String? descriptionUz,
      @JsonKey(name: "subway_station_id") final int? subwayStationId,
      @JsonKey(name: "subway_line_id") final int? subwayLineId,
      @JsonKey(name: "location_id") final int? locationId,
      final int? gender,
      @JsonKey(name: "featured_at") final String? featuredAt,
      @JsonKey(name: "move_in_date") final String? moveInDate,
      @JsonKey(name: "private_room") final bool? privateRoom,
      @JsonKey(name: "point_cloud_url") final String? pointCloudUrl,
      @JsonKey(name: "room_scan_floor_long_m") final double? roomScanFloorLongM,
      @JsonKey(name: "room_scan_floor_short_m")
      final double? roomScanFloorShortM,
      @JsonKey(name: "room_scan_height_m") final double? roomScanHeightM,
      @JsonKey(name: "room_scan_floor_area_m2")
      final double? roomScanFloorAreaM2,
      @JsonKey(name: "room_scan_world_plus_x_bearing_deg")
      final double? roomScanWorldPlusXBearingDeg,
      @JsonKey(name: "room_scan_north_correction_deg")
      final double? roomScanNorthCorrectionDeg,
      @JsonKey(name: "contact_phone") final String? contactPhone,
      @JsonKey(name: "contact_telegram") final String? contactTelegram,
      @JsonKey(name: "address_latitude") final double? addressLatitude,
      @JsonKey(name: "address_longitude") final double? addressLongitude,
      @JsonKey(name: "subway_station") final SubwayStationDetail? subwayStation,
      @JsonKey(name: "search_subway_stations")
      final List<SubwayStationDetail>? searchSubwayStations,
      final LocationDetail? location,
      @JsonKey(name: "search_locations")
      final List<LocationDetail>? searchLocations,
      final List<Amenity>? amenities,
      final List<Photo>? photos,
      @JsonKey(name: "area_price_stats") final AreaPriceStats? areaPriceStats,
      @JsonKey(name: "nearby_stores")
      final List<ListingNearbyStore>? nearbyStores,
      @JsonKey(name: "group_size_target") final int? groupSizeTarget,
      @JsonKey(name: "group_forming_status") final String? groupFormingStatus,
      @JsonKey(name: "group_compatibility_report")
      final String? groupCompatibilityReport,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final ListingGroupContext? groupContext}) = _$ListingDetailImpl;

  factory _ListingDetail.fromJson(Map<String, dynamic> json) =
      _$ListingDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "user_id")
  int get userId;
  @override
  String get title;
  @override
  @JsonKey(name: "listing_type_id")
  int get listingTypeId;
  @override
  @JsonKey(name: "price")
  int get price;
  @override
  @JsonKey(name: "min_price")
  int? get minPrice;
  @override
  @JsonKey(name: "max_price")
  int? get maxPrice;
  @override
  @JsonKey(name: "is_active")
  bool get isActive;
  @override
  @JsonKey(name: "created_at")
  String get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String get updatedAt;
  @override
  UserDetail get user;
  @override
  @JsonKey(name: "listing_type")
  ListingTypeDetail get listingType;
  @override
  String? get description;
  @override
  @JsonKey(name: "city_id")
  int? get cityId;
  @override
  @JsonKey(name: "description_ru")
  String? get descriptionRu;
  @override
  @JsonKey(name: "description_en")
  String? get descriptionEn;
  @override
  @JsonKey(name: "description_uz")
  String? get descriptionUz;
  @override
  @JsonKey(name: "subway_station_id")
  int? get subwayStationId;
  @override
  @JsonKey(name: "subway_line_id")
  int? get subwayLineId;
  @override
  @JsonKey(name: "location_id")
  int? get locationId;
  @override
  int? get gender;
  @override
  @JsonKey(name: "featured_at")
  String? get featuredAt;
  @override
  @JsonKey(name: "move_in_date")
  String? get moveInDate;
  @override
  @JsonKey(name: "private_room")
  bool? get privateRoom;
  @override
  @JsonKey(name: "point_cloud_url")
  String? get pointCloudUrl;
  @override
  @JsonKey(name: "room_scan_floor_long_m")
  double? get roomScanFloorLongM;
  @override
  @JsonKey(name: "room_scan_floor_short_m")
  double? get roomScanFloorShortM;
  @override
  @JsonKey(name: "room_scan_height_m")
  double? get roomScanHeightM;
  @override
  @JsonKey(name: "room_scan_floor_area_m2")
  double? get roomScanFloorAreaM2;
  @override
  @JsonKey(name: "room_scan_world_plus_x_bearing_deg")
  double? get roomScanWorldPlusXBearingDeg;
  @override
  @JsonKey(name: "room_scan_north_correction_deg")
  double? get roomScanNorthCorrectionDeg;
  @override
  @JsonKey(name: "contact_phone")
  String? get contactPhone;
  @override
  @JsonKey(name: "contact_telegram")
  String? get contactTelegram;
  @override
  @JsonKey(name: "address_latitude")
  double? get addressLatitude;
  @override
  @JsonKey(name: "address_longitude")
  double? get addressLongitude;
  @override
  @JsonKey(name: "subway_station")
  SubwayStationDetail? get subwayStation;
  @override
  @JsonKey(name: "search_subway_stations")
  List<SubwayStationDetail>? get searchSubwayStations;
  @override
  LocationDetail? get location;
  @override
  @JsonKey(name: "search_locations")
  List<LocationDetail>? get searchLocations;
  @override
  List<Amenity>? get amenities;
  @override
  List<Photo>? get photos;
  @override
  @JsonKey(name: "area_price_stats")
  AreaPriceStats? get areaPriceStats;
  @override
  @JsonKey(name: "nearby_stores")
  List<ListingNearbyStore>? get nearbyStores;
  @override
  @JsonKey(name: "group_size_target")
  int? get groupSizeTarget;
  @override
  @JsonKey(name: "group_forming_status")
  String? get groupFormingStatus;
  @override
  @JsonKey(name: "group_compatibility_report")
  String? get groupCompatibilityReport;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  ListingGroupContext? get groupContext;

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingDetailImplCopyWith<_$ListingDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserDetail _$UserDetailFromJson(Map<String, dynamic> json) {
  return _UserDetail.fromJson(json);
}

/// @nodoc
mixin _$UserDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String get createdAt => throw _privateConstructorUsedError;
  String? get email =>
      throw _privateConstructorUsedError; // Add email field from API response
  String? get phone => throw _privateConstructorUsedError;

  /// Serializes this UserDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDetailCopyWith<UserDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDetailCopyWith<$Res> {
  factory $UserDetailCopyWith(
          UserDetail value, $Res Function(UserDetail) then) =
      _$UserDetailCopyWithImpl<$Res, UserDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "created_at") String createdAt,
      String? email,
      String? phone});
}

/// @nodoc
class _$UserDetailCopyWithImpl<$Res, $Val extends UserDetail>
    implements $UserDetailCopyWith<$Res> {
  _$UserDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserDetailImplCopyWith<$Res>
    implements $UserDetailCopyWith<$Res> {
  factory _$$UserDetailImplCopyWith(
          _$UserDetailImpl value, $Res Function(_$UserDetailImpl) then) =
      __$$UserDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "created_at") String createdAt,
      String? email,
      String? phone});
}

/// @nodoc
class __$$UserDetailImplCopyWithImpl<$Res>
    extends _$UserDetailCopyWithImpl<$Res, _$UserDetailImpl>
    implements _$$UserDetailImplCopyWith<$Res> {
  __$$UserDetailImplCopyWithImpl(
      _$UserDetailImpl _value, $Res Function(_$UserDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(_$UserDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDetailImpl implements _UserDetail {
  const _$UserDetailImpl(
      {required this.id,
      @JsonKey(name: "created_at") required this.createdAt,
      this.email,
      this.phone});

  factory _$UserDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "created_at")
  final String createdAt;
  @override
  final String? email;
// Add email field from API response
  @override
  final String? phone;

  @override
  String toString() {
    return 'UserDetail(id: $id, createdAt: $createdAt, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, email, phone);

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDetailImplCopyWith<_$UserDetailImpl> get copyWith =>
      __$$UserDetailImplCopyWithImpl<_$UserDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDetailImplToJson(
      this,
    );
  }
}

abstract class _UserDetail implements UserDetail {
  const factory _UserDetail(
      {required final int id,
      @JsonKey(name: "created_at") required final String createdAt,
      final String? email,
      final String? phone}) = _$UserDetailImpl;

  factory _UserDetail.fromJson(Map<String, dynamic> json) =
      _$UserDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "created_at")
  String get createdAt;
  @override
  String? get email; // Add email field from API response
  @override
  String? get phone;

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDetailImplCopyWith<_$UserDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingTypeDetail _$ListingTypeDetailFromJson(Map<String, dynamic> json) {
  return _ListingTypeDetail.fromJson(json);
}

/// @nodoc
mixin _$ListingTypeDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String get nameEn => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;

  /// Serializes this ListingTypeDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingTypeDetailCopyWith<ListingTypeDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingTypeDetailCopyWith<$Res> {
  factory $ListingTypeDetailCopyWith(
          ListingTypeDetail value, $Res Function(ListingTypeDetail) then) =
      _$ListingTypeDetailCopyWithImpl<$Res, ListingTypeDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      String code});
}

/// @nodoc
class _$ListingTypeDetailCopyWithImpl<$Res, $Val extends ListingTypeDetail>
    implements $ListingTypeDetailCopyWith<$Res> {
  _$ListingTypeDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? code = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListingTypeDetailImplCopyWith<$Res>
    implements $ListingTypeDetailCopyWith<$Res> {
  factory _$$ListingTypeDetailImplCopyWith(_$ListingTypeDetailImpl value,
          $Res Function(_$ListingTypeDetailImpl) then) =
      __$$ListingTypeDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      String code});
}

/// @nodoc
class __$$ListingTypeDetailImplCopyWithImpl<$Res>
    extends _$ListingTypeDetailCopyWithImpl<$Res, _$ListingTypeDetailImpl>
    implements _$$ListingTypeDetailImplCopyWith<$Res> {
  __$$ListingTypeDetailImplCopyWithImpl(_$ListingTypeDetailImpl _value,
      $Res Function(_$ListingTypeDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? code = null,
  }) {
    return _then(_$ListingTypeDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingTypeDetailImpl implements _ListingTypeDetail {
  const _$ListingTypeDetailImpl(
      {required this.id,
      @JsonKey(name: "name_uz") required this.nameUz,
      @JsonKey(name: "name_ru") required this.nameRu,
      @JsonKey(name: "name_en") required this.nameEn,
      required this.code});

  factory _$ListingTypeDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingTypeDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String nameRu;
  @override
  @JsonKey(name: "name_en")
  final String nameEn;
  @override
  final String code;

  @override
  String toString() {
    return 'ListingTypeDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingTypeDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nameUz, nameRu, nameEn, code);

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingTypeDetailImplCopyWith<_$ListingTypeDetailImpl> get copyWith =>
      __$$ListingTypeDetailImplCopyWithImpl<_$ListingTypeDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingTypeDetailImplToJson(
      this,
    );
  }
}

abstract class _ListingTypeDetail implements ListingTypeDetail {
  const factory _ListingTypeDetail(
      {required final int id,
      @JsonKey(name: "name_uz") required final String nameUz,
      @JsonKey(name: "name_ru") required final String nameRu,
      @JsonKey(name: "name_en") required final String nameEn,
      required final String code}) = _$ListingTypeDetailImpl;

  factory _ListingTypeDetail.fromJson(Map<String, dynamic> json) =
      _$ListingTypeDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String get nameRu;
  @override
  @JsonKey(name: "name_en")
  String get nameEn;
  @override
  String get code;

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingTypeDetailImplCopyWith<_$ListingTypeDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubwayStationDetail _$SubwayStationDetailFromJson(Map<String, dynamic> json) {
  return _SubwayStationDetail.fromJson(json);
}

/// @nodoc
mixin _$SubwayStationDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String get nameEn => throw _privateConstructorUsedError;
  int get line => throw _privateConstructorUsedError;

  /// Serializes this SubwayStationDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubwayStationDetailCopyWith<SubwayStationDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubwayStationDetailCopyWith<$Res> {
  factory $SubwayStationDetailCopyWith(
          SubwayStationDetail value, $Res Function(SubwayStationDetail) then) =
      _$SubwayStationDetailCopyWithImpl<$Res, SubwayStationDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      int line});
}

/// @nodoc
class _$SubwayStationDetailCopyWithImpl<$Res, $Val extends SubwayStationDetail>
    implements $SubwayStationDetailCopyWith<$Res> {
  _$SubwayStationDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? line = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubwayStationDetailImplCopyWith<$Res>
    implements $SubwayStationDetailCopyWith<$Res> {
  factory _$$SubwayStationDetailImplCopyWith(_$SubwayStationDetailImpl value,
          $Res Function(_$SubwayStationDetailImpl) then) =
      __$$SubwayStationDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      int line});
}

/// @nodoc
class __$$SubwayStationDetailImplCopyWithImpl<$Res>
    extends _$SubwayStationDetailCopyWithImpl<$Res, _$SubwayStationDetailImpl>
    implements _$$SubwayStationDetailImplCopyWith<$Res> {
  __$$SubwayStationDetailImplCopyWithImpl(_$SubwayStationDetailImpl _value,
      $Res Function(_$SubwayStationDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? line = null,
  }) {
    return _then(_$SubwayStationDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubwayStationDetailImpl implements _SubwayStationDetail {
  const _$SubwayStationDetailImpl(
      {required this.id,
      @JsonKey(name: "name_uz") required this.nameUz,
      @JsonKey(name: "name_ru") required this.nameRu,
      @JsonKey(name: "name_en") required this.nameEn,
      required this.line});

  factory _$SubwayStationDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubwayStationDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String nameRu;
  @override
  @JsonKey(name: "name_en")
  final String nameEn;
  @override
  final int line;

  @override
  String toString() {
    return 'SubwayStationDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, line: $line)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubwayStationDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.line, line) || other.line == line));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nameUz, nameRu, nameEn, line);

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubwayStationDetailImplCopyWith<_$SubwayStationDetailImpl> get copyWith =>
      __$$SubwayStationDetailImplCopyWithImpl<_$SubwayStationDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubwayStationDetailImplToJson(
      this,
    );
  }
}

abstract class _SubwayStationDetail implements SubwayStationDetail {
  const factory _SubwayStationDetail(
      {required final int id,
      @JsonKey(name: "name_uz") required final String nameUz,
      @JsonKey(name: "name_ru") required final String nameRu,
      @JsonKey(name: "name_en") required final String nameEn,
      required final int line}) = _$SubwayStationDetailImpl;

  factory _SubwayStationDetail.fromJson(Map<String, dynamic> json) =
      _$SubwayStationDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String get nameRu;
  @override
  @JsonKey(name: "name_en")
  String get nameEn;
  @override
  int get line;

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubwayStationDetailImplCopyWith<_$SubwayStationDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocationDetail _$LocationDetailFromJson(Map<String, dynamic> json) {
  return _LocationDetail.fromJson(json);
}

/// @nodoc
mixin _$LocationDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_uz")
  String get shortNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_ru")
  String get shortNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_en")
  String get shortNameEn => throw _privateConstructorUsedError;

  /// Serializes this LocationDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationDetailCopyWith<LocationDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationDetailCopyWith<$Res> {
  factory $LocationDetailCopyWith(
          LocationDetail value, $Res Function(LocationDetail) then) =
      _$LocationDetailCopyWithImpl<$Res, LocationDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      @JsonKey(name: "short_name_uz") String shortNameUz,
      @JsonKey(name: "short_name_ru") String shortNameRu,
      @JsonKey(name: "short_name_en") String shortNameEn});
}

/// @nodoc
class _$LocationDetailCopyWithImpl<$Res, $Val extends LocationDetail>
    implements $LocationDetailCopyWith<$Res> {
  _$LocationDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? shortNameUz = null,
    Object? shortNameRu = null,
    Object? shortNameEn = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameUz: null == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameRu: null == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameEn: null == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationDetailImplCopyWith<$Res>
    implements $LocationDetailCopyWith<$Res> {
  factory _$$LocationDetailImplCopyWith(_$LocationDetailImpl value,
          $Res Function(_$LocationDetailImpl) then) =
      __$$LocationDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      @JsonKey(name: "short_name_uz") String shortNameUz,
      @JsonKey(name: "short_name_ru") String shortNameRu,
      @JsonKey(name: "short_name_en") String shortNameEn});
}

/// @nodoc
class __$$LocationDetailImplCopyWithImpl<$Res>
    extends _$LocationDetailCopyWithImpl<$Res, _$LocationDetailImpl>
    implements _$$LocationDetailImplCopyWith<$Res> {
  __$$LocationDetailImplCopyWithImpl(
      _$LocationDetailImpl _value, $Res Function(_$LocationDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? shortNameUz = null,
    Object? shortNameRu = null,
    Object? shortNameEn = null,
  }) {
    return _then(_$LocationDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameUz: null == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameRu: null == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameEn: null == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationDetailImpl implements _LocationDetail {
  const _$LocationDetailImpl(
      {required this.id,
      @JsonKey(name: "name_uz") required this.nameUz,
      @JsonKey(name: "name_ru") required this.nameRu,
      @JsonKey(name: "name_en") required this.nameEn,
      @JsonKey(name: "short_name_uz") required this.shortNameUz,
      @JsonKey(name: "short_name_ru") required this.shortNameRu,
      @JsonKey(name: "short_name_en") required this.shortNameEn});

  factory _$LocationDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String nameRu;
  @override
  @JsonKey(name: "name_en")
  final String nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  final String shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  final String shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  final String shortNameEn;

  @override
  String toString() {
    return 'LocationDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.shortNameUz, shortNameUz) ||
                other.shortNameUz == shortNameUz) &&
            (identical(other.shortNameRu, shortNameRu) ||
                other.shortNameRu == shortNameRu) &&
            (identical(other.shortNameEn, shortNameEn) ||
                other.shortNameEn == shortNameEn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameUz, nameRu, nameEn,
      shortNameUz, shortNameRu, shortNameEn);

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationDetailImplCopyWith<_$LocationDetailImpl> get copyWith =>
      __$$LocationDetailImplCopyWithImpl<_$LocationDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationDetailImplToJson(
      this,
    );
  }
}

abstract class _LocationDetail implements LocationDetail {
  const factory _LocationDetail(
          {required final int id,
          @JsonKey(name: "name_uz") required final String nameUz,
          @JsonKey(name: "name_ru") required final String nameRu,
          @JsonKey(name: "name_en") required final String nameEn,
          @JsonKey(name: "short_name_uz") required final String shortNameUz,
          @JsonKey(name: "short_name_ru") required final String shortNameRu,
          @JsonKey(name: "short_name_en") required final String shortNameEn}) =
      _$LocationDetailImpl;

  factory _LocationDetail.fromJson(Map<String, dynamic> json) =
      _$LocationDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String get nameRu;
  @override
  @JsonKey(name: "name_en")
  String get nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  String get shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  String get shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  String get shortNameEn;

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationDetailImplCopyWith<_$LocationDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AreaPriceStats _$AreaPriceStatsFromJson(Map<String, dynamic> json) {
  return _AreaPriceStats.fromJson(json);
}

/// @nodoc
mixin _$AreaPriceStats {
  @JsonKey(name: "subway_station")
  AreaPriceBenchmark? get subwayStation => throw _privateConstructorUsedError;
  @JsonKey(name: "location")
  AreaPriceBenchmark? get location => throw _privateConstructorUsedError;

  /// Serializes this AreaPriceStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AreaPriceStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AreaPriceStatsCopyWith<AreaPriceStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AreaPriceStatsCopyWith<$Res> {
  factory $AreaPriceStatsCopyWith(
          AreaPriceStats value, $Res Function(AreaPriceStats) then) =
      _$AreaPriceStatsCopyWithImpl<$Res, AreaPriceStats>;
  @useResult
  $Res call(
      {@JsonKey(name: "subway_station") AreaPriceBenchmark? subwayStation,
      @JsonKey(name: "location") AreaPriceBenchmark? location});

  $AreaPriceBenchmarkCopyWith<$Res>? get subwayStation;
  $AreaPriceBenchmarkCopyWith<$Res>? get location;
}

/// @nodoc
class _$AreaPriceStatsCopyWithImpl<$Res, $Val extends AreaPriceStats>
    implements $AreaPriceStatsCopyWith<$Res> {
  _$AreaPriceStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AreaPriceStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subwayStation = freezed,
    Object? location = freezed,
  }) {
    return _then(_value.copyWith(
      subwayStation: freezed == subwayStation
          ? _value.subwayStation
          : subwayStation // ignore: cast_nullable_to_non_nullable
              as AreaPriceBenchmark?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as AreaPriceBenchmark?,
    ) as $Val);
  }

  /// Create a copy of AreaPriceStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AreaPriceBenchmarkCopyWith<$Res>? get subwayStation {
    if (_value.subwayStation == null) {
      return null;
    }

    return $AreaPriceBenchmarkCopyWith<$Res>(_value.subwayStation!, (value) {
      return _then(_value.copyWith(subwayStation: value) as $Val);
    });
  }

  /// Create a copy of AreaPriceStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AreaPriceBenchmarkCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $AreaPriceBenchmarkCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AreaPriceStatsImplCopyWith<$Res>
    implements $AreaPriceStatsCopyWith<$Res> {
  factory _$$AreaPriceStatsImplCopyWith(_$AreaPriceStatsImpl value,
          $Res Function(_$AreaPriceStatsImpl) then) =
      __$$AreaPriceStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: "subway_station") AreaPriceBenchmark? subwayStation,
      @JsonKey(name: "location") AreaPriceBenchmark? location});

  @override
  $AreaPriceBenchmarkCopyWith<$Res>? get subwayStation;
  @override
  $AreaPriceBenchmarkCopyWith<$Res>? get location;
}

/// @nodoc
class __$$AreaPriceStatsImplCopyWithImpl<$Res>
    extends _$AreaPriceStatsCopyWithImpl<$Res, _$AreaPriceStatsImpl>
    implements _$$AreaPriceStatsImplCopyWith<$Res> {
  __$$AreaPriceStatsImplCopyWithImpl(
      _$AreaPriceStatsImpl _value, $Res Function(_$AreaPriceStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of AreaPriceStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subwayStation = freezed,
    Object? location = freezed,
  }) {
    return _then(_$AreaPriceStatsImpl(
      subwayStation: freezed == subwayStation
          ? _value.subwayStation
          : subwayStation // ignore: cast_nullable_to_non_nullable
              as AreaPriceBenchmark?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as AreaPriceBenchmark?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AreaPriceStatsImpl implements _AreaPriceStats {
  const _$AreaPriceStatsImpl(
      {@JsonKey(name: "subway_station") this.subwayStation,
      @JsonKey(name: "location") this.location});

  factory _$AreaPriceStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AreaPriceStatsImplFromJson(json);

  @override
  @JsonKey(name: "subway_station")
  final AreaPriceBenchmark? subwayStation;
  @override
  @JsonKey(name: "location")
  final AreaPriceBenchmark? location;

  @override
  String toString() {
    return 'AreaPriceStats(subwayStation: $subwayStation, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AreaPriceStatsImpl &&
            (identical(other.subwayStation, subwayStation) ||
                other.subwayStation == subwayStation) &&
            (identical(other.location, location) ||
                other.location == location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, subwayStation, location);

  /// Create a copy of AreaPriceStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AreaPriceStatsImplCopyWith<_$AreaPriceStatsImpl> get copyWith =>
      __$$AreaPriceStatsImplCopyWithImpl<_$AreaPriceStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AreaPriceStatsImplToJson(
      this,
    );
  }
}

abstract class _AreaPriceStats implements AreaPriceStats {
  const factory _AreaPriceStats(
      {@JsonKey(name: "subway_station") final AreaPriceBenchmark? subwayStation,
      @JsonKey(name: "location")
      final AreaPriceBenchmark? location}) = _$AreaPriceStatsImpl;

  factory _AreaPriceStats.fromJson(Map<String, dynamic> json) =
      _$AreaPriceStatsImpl.fromJson;

  @override
  @JsonKey(name: "subway_station")
  AreaPriceBenchmark? get subwayStation;
  @override
  @JsonKey(name: "location")
  AreaPriceBenchmark? get location;

  /// Create a copy of AreaPriceStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AreaPriceStatsImplCopyWith<_$AreaPriceStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AreaPriceBenchmark _$AreaPriceBenchmarkFromJson(Map<String, dynamic> json) {
  return _AreaPriceBenchmark.fromJson(json);
}

/// @nodoc
mixin _$AreaPriceBenchmark {
  int get mean => throw _privateConstructorUsedError;
  int get median => throw _privateConstructorUsedError;
  @JsonKey(name: "sample_count")
  int get sampleCount => throw _privateConstructorUsedError;

  /// Serializes this AreaPriceBenchmark to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AreaPriceBenchmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AreaPriceBenchmarkCopyWith<AreaPriceBenchmark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AreaPriceBenchmarkCopyWith<$Res> {
  factory $AreaPriceBenchmarkCopyWith(
          AreaPriceBenchmark value, $Res Function(AreaPriceBenchmark) then) =
      _$AreaPriceBenchmarkCopyWithImpl<$Res, AreaPriceBenchmark>;
  @useResult
  $Res call(
      {int mean, int median, @JsonKey(name: "sample_count") int sampleCount});
}

/// @nodoc
class _$AreaPriceBenchmarkCopyWithImpl<$Res, $Val extends AreaPriceBenchmark>
    implements $AreaPriceBenchmarkCopyWith<$Res> {
  _$AreaPriceBenchmarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AreaPriceBenchmark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mean = null,
    Object? median = null,
    Object? sampleCount = null,
  }) {
    return _then(_value.copyWith(
      mean: null == mean
          ? _value.mean
          : mean // ignore: cast_nullable_to_non_nullable
              as int,
      median: null == median
          ? _value.median
          : median // ignore: cast_nullable_to_non_nullable
              as int,
      sampleCount: null == sampleCount
          ? _value.sampleCount
          : sampleCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AreaPriceBenchmarkImplCopyWith<$Res>
    implements $AreaPriceBenchmarkCopyWith<$Res> {
  factory _$$AreaPriceBenchmarkImplCopyWith(_$AreaPriceBenchmarkImpl value,
          $Res Function(_$AreaPriceBenchmarkImpl) then) =
      __$$AreaPriceBenchmarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int mean, int median, @JsonKey(name: "sample_count") int sampleCount});
}

/// @nodoc
class __$$AreaPriceBenchmarkImplCopyWithImpl<$Res>
    extends _$AreaPriceBenchmarkCopyWithImpl<$Res, _$AreaPriceBenchmarkImpl>
    implements _$$AreaPriceBenchmarkImplCopyWith<$Res> {
  __$$AreaPriceBenchmarkImplCopyWithImpl(_$AreaPriceBenchmarkImpl _value,
      $Res Function(_$AreaPriceBenchmarkImpl) _then)
      : super(_value, _then);

  /// Create a copy of AreaPriceBenchmark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mean = null,
    Object? median = null,
    Object? sampleCount = null,
  }) {
    return _then(_$AreaPriceBenchmarkImpl(
      mean: null == mean
          ? _value.mean
          : mean // ignore: cast_nullable_to_non_nullable
              as int,
      median: null == median
          ? _value.median
          : median // ignore: cast_nullable_to_non_nullable
              as int,
      sampleCount: null == sampleCount
          ? _value.sampleCount
          : sampleCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AreaPriceBenchmarkImpl implements _AreaPriceBenchmark {
  const _$AreaPriceBenchmarkImpl(
      {required this.mean,
      required this.median,
      @JsonKey(name: "sample_count") required this.sampleCount});

  factory _$AreaPriceBenchmarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$AreaPriceBenchmarkImplFromJson(json);

  @override
  final int mean;
  @override
  final int median;
  @override
  @JsonKey(name: "sample_count")
  final int sampleCount;

  @override
  String toString() {
    return 'AreaPriceBenchmark(mean: $mean, median: $median, sampleCount: $sampleCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AreaPriceBenchmarkImpl &&
            (identical(other.mean, mean) || other.mean == mean) &&
            (identical(other.median, median) || other.median == median) &&
            (identical(other.sampleCount, sampleCount) ||
                other.sampleCount == sampleCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, mean, median, sampleCount);

  /// Create a copy of AreaPriceBenchmark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AreaPriceBenchmarkImplCopyWith<_$AreaPriceBenchmarkImpl> get copyWith =>
      __$$AreaPriceBenchmarkImplCopyWithImpl<_$AreaPriceBenchmarkImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AreaPriceBenchmarkImplToJson(
      this,
    );
  }
}

abstract class _AreaPriceBenchmark implements AreaPriceBenchmark {
  const factory _AreaPriceBenchmark(
          {required final int mean,
          required final int median,
          @JsonKey(name: "sample_count") required final int sampleCount}) =
      _$AreaPriceBenchmarkImpl;

  factory _AreaPriceBenchmark.fromJson(Map<String, dynamic> json) =
      _$AreaPriceBenchmarkImpl.fromJson;

  @override
  int get mean;
  @override
  int get median;
  @override
  @JsonKey(name: "sample_count")
  int get sampleCount;

  /// Create a copy of AreaPriceBenchmark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AreaPriceBenchmarkImplCopyWith<_$AreaPriceBenchmarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
