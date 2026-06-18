// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Listing _$ListingFromJson(Map<String, dynamic> json) {
  return _Listing.fromJson(json);
}

/// @nodoc
mixin _$Listing {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "user_id")
  int get userId => throw _privateConstructorUsedError;
  @JsonKey(name: "title")
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
  @JsonKey(name: "description")
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: "city_id")
  int? get cityId => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station_id")
  int? get subwayStationId => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_line_id")
  int? get subwayLineId => throw _privateConstructorUsedError;
  @JsonKey(name: "location_id")
  int? get locationId => throw _privateConstructorUsedError;
  @JsonKey(name: "gender")
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
  @JsonKey(name: "subway_station")
  SubwayStationDetail? get subwayStation => throw _privateConstructorUsedError;
  @JsonKey(name: "location")
  LocationDetail? get location => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_type")
  ListingTypeDetail? get listingType => throw _privateConstructorUsedError;
  @JsonKey(name: "amenities")
  List<Amenity>? get amenities => throw _privateConstructorUsedError;
  List<Photo>? get photos => throw _privateConstructorUsedError;
  @JsonKey(name: "isFavorited")
  bool? get isFavorited => throw _privateConstructorUsedError;

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingCopyWith<Listing> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingCopyWith<$Res> {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) then) =
      _$ListingCopyWithImpl<$Res, Listing>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "user_id") int userId,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "listing_type_id") int listingTypeId,
      @JsonKey(name: "price") int price,
      @JsonKey(name: "min_price") int? minPrice,
      @JsonKey(name: "max_price") int? maxPrice,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      @JsonKey(name: "description") String? description,
      @JsonKey(name: "city_id") int? cityId,
      @JsonKey(name: "subway_station_id") int? subwayStationId,
      @JsonKey(name: "subway_line_id") int? subwayLineId,
      @JsonKey(name: "location_id") int? locationId,
      @JsonKey(name: "gender") int? gender,
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
      @JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,
      @JsonKey(name: "location") LocationDetail? location,
      @JsonKey(name: "listing_type") ListingTypeDetail? listingType,
      @JsonKey(name: "amenities") List<Amenity>? amenities,
      List<Photo>? photos,
      @JsonKey(name: "isFavorited") bool? isFavorited});

  $SubwayStationDetailCopyWith<$Res>? get subwayStation;
  $LocationDetailCopyWith<$Res>? get location;
  $ListingTypeDetailCopyWith<$Res>? get listingType;
}

/// @nodoc
class _$ListingCopyWithImpl<$Res, $Val extends Listing>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Listing
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
    Object? description = freezed,
    Object? cityId = freezed,
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
    Object? subwayStation = freezed,
    Object? location = freezed,
    Object? listingType = freezed,
    Object? amenities = freezed,
    Object? photos = freezed,
    Object? isFavorited = freezed,
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
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
      subwayStation: freezed == subwayStation
          ? _value.subwayStation
          : subwayStation // ignore: cast_nullable_to_non_nullable
              as SubwayStationDetail?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDetail?,
      listingType: freezed == listingType
          ? _value.listingType
          : listingType // ignore: cast_nullable_to_non_nullable
              as ListingTypeDetail?,
      amenities: freezed == amenities
          ? _value.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<Amenity>?,
      photos: freezed == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>?,
      isFavorited: freezed == isFavorited
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }

  /// Create a copy of Listing
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

  /// Create a copy of Listing
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

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListingTypeDetailCopyWith<$Res>? get listingType {
    if (_value.listingType == null) {
      return null;
    }

    return $ListingTypeDetailCopyWith<$Res>(_value.listingType!, (value) {
      return _then(_value.copyWith(listingType: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ListingImplCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$$ListingImplCopyWith(
          _$ListingImpl value, $Res Function(_$ListingImpl) then) =
      __$$ListingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "user_id") int userId,
      @JsonKey(name: "title") String title,
      @JsonKey(name: "listing_type_id") int listingTypeId,
      @JsonKey(name: "price") int price,
      @JsonKey(name: "min_price") int? minPrice,
      @JsonKey(name: "max_price") int? maxPrice,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      @JsonKey(name: "description") String? description,
      @JsonKey(name: "city_id") int? cityId,
      @JsonKey(name: "subway_station_id") int? subwayStationId,
      @JsonKey(name: "subway_line_id") int? subwayLineId,
      @JsonKey(name: "location_id") int? locationId,
      @JsonKey(name: "gender") int? gender,
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
      @JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,
      @JsonKey(name: "location") LocationDetail? location,
      @JsonKey(name: "listing_type") ListingTypeDetail? listingType,
      @JsonKey(name: "amenities") List<Amenity>? amenities,
      List<Photo>? photos,
      @JsonKey(name: "isFavorited") bool? isFavorited});

  @override
  $SubwayStationDetailCopyWith<$Res>? get subwayStation;
  @override
  $LocationDetailCopyWith<$Res>? get location;
  @override
  $ListingTypeDetailCopyWith<$Res>? get listingType;
}

/// @nodoc
class __$$ListingImplCopyWithImpl<$Res>
    extends _$ListingCopyWithImpl<$Res, _$ListingImpl>
    implements _$$ListingImplCopyWith<$Res> {
  __$$ListingImplCopyWithImpl(
      _$ListingImpl _value, $Res Function(_$ListingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Listing
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
    Object? description = freezed,
    Object? cityId = freezed,
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
    Object? subwayStation = freezed,
    Object? location = freezed,
    Object? listingType = freezed,
    Object? amenities = freezed,
    Object? photos = freezed,
    Object? isFavorited = freezed,
  }) {
    return _then(_$ListingImpl(
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      cityId: freezed == cityId
          ? _value.cityId
          : cityId // ignore: cast_nullable_to_non_nullable
              as int?,
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
      subwayStation: freezed == subwayStation
          ? _value.subwayStation
          : subwayStation // ignore: cast_nullable_to_non_nullable
              as SubwayStationDetail?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDetail?,
      listingType: freezed == listingType
          ? _value.listingType
          : listingType // ignore: cast_nullable_to_non_nullable
              as ListingTypeDetail?,
      amenities: freezed == amenities
          ? _value._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<Amenity>?,
      photos: freezed == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>?,
      isFavorited: freezed == isFavorited
          ? _value.isFavorited
          : isFavorited // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingImpl implements _Listing {
  const _$ListingImpl(
      {required this.id,
      @JsonKey(name: "user_id") required this.userId,
      @JsonKey(name: "title") required this.title,
      @JsonKey(name: "listing_type_id") required this.listingTypeId,
      @JsonKey(name: "price") required this.price,
      @JsonKey(name: "min_price") this.minPrice,
      @JsonKey(name: "max_price") this.maxPrice,
      @JsonKey(name: "is_active") required this.isActive,
      @JsonKey(name: "created_at") required this.createdAt,
      @JsonKey(name: "updated_at") required this.updatedAt,
      @JsonKey(name: "description") this.description,
      @JsonKey(name: "city_id") this.cityId,
      @JsonKey(name: "subway_station_id") this.subwayStationId,
      @JsonKey(name: "subway_line_id") this.subwayLineId,
      @JsonKey(name: "location_id") this.locationId,
      @JsonKey(name: "gender") this.gender,
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
      @JsonKey(name: "subway_station") this.subwayStation,
      @JsonKey(name: "location") this.location,
      @JsonKey(name: "listing_type") this.listingType,
      @JsonKey(name: "amenities") final List<Amenity>? amenities,
      final List<Photo>? photos,
      @JsonKey(name: "isFavorited") this.isFavorited})
      : _amenities = amenities,
        _photos = photos;

  factory _$ListingImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "user_id")
  final int userId;
  @override
  @JsonKey(name: "title")
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
  @JsonKey(name: "description")
  final String? description;
  @override
  @JsonKey(name: "city_id")
  final int? cityId;
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
  @JsonKey(name: "gender")
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
  @JsonKey(name: "subway_station")
  final SubwayStationDetail? subwayStation;
  @override
  @JsonKey(name: "location")
  final LocationDetail? location;
  @override
  @JsonKey(name: "listing_type")
  final ListingTypeDetail? listingType;
  final List<Amenity>? _amenities;
  @override
  @JsonKey(name: "amenities")
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
  @JsonKey(name: "isFavorited")
  final bool? isFavorited;

  @override
  String toString() {
    return 'Listing(id: $id, userId: $userId, title: $title, listingTypeId: $listingTypeId, price: $price, minPrice: $minPrice, maxPrice: $maxPrice, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, cityId: $cityId, subwayStationId: $subwayStationId, subwayLineId: $subwayLineId, locationId: $locationId, gender: $gender, featuredAt: $featuredAt, moveInDate: $moveInDate, privateRoom: $privateRoom, pointCloudUrl: $pointCloudUrl, roomScanFloorLongM: $roomScanFloorLongM, roomScanFloorShortM: $roomScanFloorShortM, roomScanHeightM: $roomScanHeightM, roomScanFloorAreaM2: $roomScanFloorAreaM2, roomScanWorldPlusXBearingDeg: $roomScanWorldPlusXBearingDeg, roomScanNorthCorrectionDeg: $roomScanNorthCorrectionDeg, subwayStation: $subwayStation, location: $location, listingType: $listingType, amenities: $amenities, photos: $photos, isFavorited: $isFavorited)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingImpl &&
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
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.cityId, cityId) || other.cityId == cityId) &&
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
            (identical(other.roomScanWorldPlusXBearingDeg,
                    roomScanWorldPlusXBearingDeg) ||
                other.roomScanWorldPlusXBearingDeg ==
                    roomScanWorldPlusXBearingDeg) &&
            (identical(other.roomScanNorthCorrectionDeg,
                    roomScanNorthCorrectionDeg) ||
                other.roomScanNorthCorrectionDeg ==
                    roomScanNorthCorrectionDeg) &&
            (identical(other.subwayStation, subwayStation) ||
                other.subwayStation == subwayStation) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.listingType, listingType) ||
                other.listingType == listingType) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.isFavorited, isFavorited) ||
                other.isFavorited == isFavorited));
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
        description,
        cityId,
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
        subwayStation,
        location,
        listingType,
        const DeepCollectionEquality().hash(_amenities),
        const DeepCollectionEquality().hash(_photos),
        isFavorited
      ]);

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingImplCopyWith<_$ListingImpl> get copyWith =>
      __$$ListingImplCopyWithImpl<_$ListingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingImplToJson(
      this,
    );
  }
}

abstract class _Listing implements Listing {
  const factory _Listing(
      {required final int id,
      @JsonKey(name: "user_id") required final int userId,
      @JsonKey(name: "title") required final String title,
      @JsonKey(name: "listing_type_id") required final int listingTypeId,
      @JsonKey(name: "price") required final int price,
      @JsonKey(name: "min_price") final int? minPrice,
      @JsonKey(name: "max_price") final int? maxPrice,
      @JsonKey(name: "is_active") required final bool isActive,
      @JsonKey(name: "created_at") required final String createdAt,
      @JsonKey(name: "updated_at") required final String updatedAt,
      @JsonKey(name: "description") final String? description,
      @JsonKey(name: "city_id") final int? cityId,
      @JsonKey(name: "subway_station_id") final int? subwayStationId,
      @JsonKey(name: "subway_line_id") final int? subwayLineId,
      @JsonKey(name: "location_id") final int? locationId,
      @JsonKey(name: "gender") final int? gender,
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
      @JsonKey(name: "subway_station") final SubwayStationDetail? subwayStation,
      @JsonKey(name: "location") final LocationDetail? location,
      @JsonKey(name: "listing_type") final ListingTypeDetail? listingType,
      @JsonKey(name: "amenities") final List<Amenity>? amenities,
      final List<Photo>? photos,
      @JsonKey(name: "isFavorited") final bool? isFavorited}) = _$ListingImpl;

  factory _Listing.fromJson(Map<String, dynamic> json) = _$ListingImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "user_id")
  int get userId;
  @override
  @JsonKey(name: "title")
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
  @JsonKey(name: "description")
  String? get description;
  @override
  @JsonKey(name: "city_id")
  int? get cityId;
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
  @JsonKey(name: "gender")
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
  @JsonKey(name: "subway_station")
  SubwayStationDetail? get subwayStation;
  @override
  @JsonKey(name: "location")
  LocationDetail? get location;
  @override
  @JsonKey(name: "listing_type")
  ListingTypeDetail? get listingType;
  @override
  @JsonKey(name: "amenities")
  List<Amenity>? get amenities;
  @override
  List<Photo>? get photos;
  @override
  @JsonKey(name: "isFavorited")
  bool? get isFavorited;

  /// Create a copy of Listing
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingImplCopyWith<_$ListingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubwayStationDetail _$SubwayStationDetailFromJson(Map<String, dynamic> json) {
  return _SubwayStationDetail.fromJson(json);
}

/// @nodoc
mixin _$SubwayStationDetail {
  int get id => throw _privateConstructorUsedError;
  int get line => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String? get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String? get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String? get nameEn => throw _privateConstructorUsedError;

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
      int line,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn});
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
    Object? line = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
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
      int line,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn});
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
    Object? line = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
  }) {
    return _then(_$SubwayStationDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubwayStationDetailImpl implements _SubwayStationDetail {
  const _$SubwayStationDetailImpl(
      {required this.id,
      required this.line,
      @JsonKey(name: "name_uz") this.nameUz,
      @JsonKey(name: "name_ru") this.nameRu,
      @JsonKey(name: "name_en") this.nameEn});

  factory _$SubwayStationDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubwayStationDetailImplFromJson(json);

  @override
  final int id;
  @override
  final int line;
  @override
  @JsonKey(name: "name_uz")
  final String? nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String? nameRu;
  @override
  @JsonKey(name: "name_en")
  final String? nameEn;

  @override
  String toString() {
    return 'SubwayStationDetail(id: $id, line: $line, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubwayStationDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.line, line) || other.line == line) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, line, nameUz, nameRu, nameEn);

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
          required final int line,
          @JsonKey(name: "name_uz") final String? nameUz,
          @JsonKey(name: "name_ru") final String? nameRu,
          @JsonKey(name: "name_en") final String? nameEn}) =
      _$SubwayStationDetailImpl;

  factory _SubwayStationDetail.fromJson(Map<String, dynamic> json) =
      _$SubwayStationDetailImpl.fromJson;

  @override
  int get id;
  @override
  int get line;
  @override
  @JsonKey(name: "name_uz")
  String? get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String? get nameRu;
  @override
  @JsonKey(name: "name_en")
  String? get nameEn;

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
  String? get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String? get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String? get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_uz")
  String? get shortNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_ru")
  String? get shortNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_en")
  String? get shortNameEn => throw _privateConstructorUsedError;

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
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn,
      @JsonKey(name: "short_name_uz") String? shortNameUz,
      @JsonKey(name: "short_name_ru") String? shortNameRu,
      @JsonKey(name: "short_name_en") String? shortNameEn});
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
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
    Object? shortNameUz = freezed,
    Object? shortNameRu = freezed,
    Object? shortNameEn = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameUz: freezed == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameRu: freezed == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameEn: freezed == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
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
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn,
      @JsonKey(name: "short_name_uz") String? shortNameUz,
      @JsonKey(name: "short_name_ru") String? shortNameRu,
      @JsonKey(name: "short_name_en") String? shortNameEn});
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
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
    Object? shortNameUz = freezed,
    Object? shortNameRu = freezed,
    Object? shortNameEn = freezed,
  }) {
    return _then(_$LocationDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameUz: freezed == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameRu: freezed == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameEn: freezed == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationDetailImpl implements _LocationDetail {
  const _$LocationDetailImpl(
      {required this.id,
      @JsonKey(name: "name_uz") this.nameUz,
      @JsonKey(name: "name_ru") this.nameRu,
      @JsonKey(name: "name_en") this.nameEn,
      @JsonKey(name: "short_name_uz") this.shortNameUz,
      @JsonKey(name: "short_name_ru") this.shortNameRu,
      @JsonKey(name: "short_name_en") this.shortNameEn});

  factory _$LocationDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String? nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String? nameRu;
  @override
  @JsonKey(name: "name_en")
  final String? nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  final String? shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  final String? shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  final String? shortNameEn;

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
          @JsonKey(name: "name_uz") final String? nameUz,
          @JsonKey(name: "name_ru") final String? nameRu,
          @JsonKey(name: "name_en") final String? nameEn,
          @JsonKey(name: "short_name_uz") final String? shortNameUz,
          @JsonKey(name: "short_name_ru") final String? shortNameRu,
          @JsonKey(name: "short_name_en") final String? shortNameEn}) =
      _$LocationDetailImpl;

  factory _LocationDetail.fromJson(Map<String, dynamic> json) =
      _$LocationDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String? get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String? get nameRu;
  @override
  @JsonKey(name: "name_en")
  String? get nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  String? get shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  String? get shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  String? get shortNameEn;

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationDetailImplCopyWith<_$LocationDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingTypeDetail _$ListingTypeDetailFromJson(Map<String, dynamic> json) {
  return _ListingTypeDetail.fromJson(json);
}

/// @nodoc
mixin _$ListingTypeDetail {
  int get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String? get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String? get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String? get nameEn => throw _privateConstructorUsedError;

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
      String code,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn});
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
    Object? code = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
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
      String code,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn});
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
    Object? code = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
  }) {
    return _then(_$ListingTypeDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingTypeDetailImpl implements _ListingTypeDetail {
  const _$ListingTypeDetailImpl(
      {required this.id,
      required this.code,
      @JsonKey(name: "name_uz") this.nameUz,
      @JsonKey(name: "name_ru") this.nameRu,
      @JsonKey(name: "name_en") this.nameEn});

  factory _$ListingTypeDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingTypeDetailImplFromJson(json);

  @override
  final int id;
  @override
  final String code;
  @override
  @JsonKey(name: "name_uz")
  final String? nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String? nameRu;
  @override
  @JsonKey(name: "name_en")
  final String? nameEn;

  @override
  String toString() {
    return 'ListingTypeDetail(id: $id, code: $code, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingTypeDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, code, nameUz, nameRu, nameEn);

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
          required final String code,
          @JsonKey(name: "name_uz") final String? nameUz,
          @JsonKey(name: "name_ru") final String? nameRu,
          @JsonKey(name: "name_en") final String? nameEn}) =
      _$ListingTypeDetailImpl;

  factory _ListingTypeDetail.fromJson(Map<String, dynamic> json) =
      _$ListingTypeDetailImpl.fromJson;

  @override
  int get id;
  @override
  String get code;
  @override
  @JsonKey(name: "name_uz")
  String? get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String? get nameRu;
  @override
  @JsonKey(name: "name_en")
  String? get nameEn;

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingTypeDetailImplCopyWith<_$ListingTypeDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
