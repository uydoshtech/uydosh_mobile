// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Listing {

 int get id;@JsonKey(name: "user_id") int get userId;@JsonKey(name: "title") String get title;@JsonKey(name: "listing_type_id") int get listingTypeId;@JsonKey(name: "price") int get price;@JsonKey(name: "min_price") int? get minPrice;@JsonKey(name: "max_price") int? get maxPrice;@JsonKey(name: "is_active") bool get isActive;@JsonKey(name: "created_at") String get createdAt;@JsonKey(name: "updated_at") String get updatedAt;@JsonKey(name: "description") String? get description;@JsonKey(name: "city_id") int? get cityId;@JsonKey(name: "subway_station_id") int? get subwayStationId;@JsonKey(name: "subway_line_id") int? get subwayLineId;@JsonKey(name: "location_id") int? get locationId;@JsonKey(name: "gender") int? get gender;@JsonKey(name: "location_precision") String? get locationPrecision;@JsonKey(name: "display_lat") double? get displayLat;@JsonKey(name: "display_lng") double? get displayLng;@JsonKey(name: "accuracy_radius_m") int? get accuracyRadiusM;@JsonKey(name: "is_approximate_location") bool? get isApproximateLocation;@JsonKey(name: "featured_at") String? get featuredAt;@JsonKey(name: "renewed_at") String? get renewedAt;@JsonKey(name: "next_renewal_at") String? get nextRenewalAt;@JsonKey(name: "move_in_date") String? get moveInDate;@JsonKey(name: "private_room") bool? get privateRoom;@JsonKey(name: "host_resident") bool? get hostResident;@JsonKey(name: "point_cloud_url") String? get pointCloudUrl;@JsonKey(name: "room_scan_glb_url") String? get roomScanGlbUrl;@JsonKey(name: "textured_glb_url") String? get texturedGlbUrl;@JsonKey(name: "photogrammetry_status") String? get photogrammetryStatus;@JsonKey(name: "room_scan_floor_long_m") double? get roomScanFloorLongM;@JsonKey(name: "room_scan_floor_short_m") double? get roomScanFloorShortM;@JsonKey(name: "room_scan_height_m") double? get roomScanHeightM;@JsonKey(name: "room_scan_floor_area_m2") double? get roomScanFloorAreaM2;@JsonKey(name: "room_scan_world_plus_x_bearing_deg") double? get roomScanWorldPlusXBearingDeg;@JsonKey(name: "room_scan_north_correction_deg") double? get roomScanNorthCorrectionDeg;@JsonKey(name: "subway_station") SubwayStationDetail? get subwayStation;@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? get searchSubwayStations;@JsonKey(name: "location") LocationDetail? get location;@JsonKey(name: "search_locations") List<LocationDetail>? get searchLocations;@JsonKey(name: "listing_type") ListingTypeDetail? get listingType;@JsonKey(name: "amenities") List<Amenity>? get amenities; List<Photo>? get photos;@JsonKey(name: "isFavorited") bool? get isFavorited;@JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson) int? get groupSizeTarget;@JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson) int? get groupMemberCount;
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCopyWith<Listing> get copyWith => _$ListingCopyWithImpl<Listing>(this as Listing, _$identity);

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.listingTypeId, listingTypeId) || other.listingTypeId == listingTypeId)&&(identical(other.price, price) || other.price == price)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.subwayStationId, subwayStationId) || other.subwayStationId == subwayStationId)&&(identical(other.subwayLineId, subwayLineId) || other.subwayLineId == subwayLineId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.locationPrecision, locationPrecision) || other.locationPrecision == locationPrecision)&&(identical(other.displayLat, displayLat) || other.displayLat == displayLat)&&(identical(other.displayLng, displayLng) || other.displayLng == displayLng)&&(identical(other.accuracyRadiusM, accuracyRadiusM) || other.accuracyRadiusM == accuracyRadiusM)&&(identical(other.isApproximateLocation, isApproximateLocation) || other.isApproximateLocation == isApproximateLocation)&&(identical(other.featuredAt, featuredAt) || other.featuredAt == featuredAt)&&(identical(other.renewedAt, renewedAt) || other.renewedAt == renewedAt)&&(identical(other.nextRenewalAt, nextRenewalAt) || other.nextRenewalAt == nextRenewalAt)&&(identical(other.moveInDate, moveInDate) || other.moveInDate == moveInDate)&&(identical(other.privateRoom, privateRoom) || other.privateRoom == privateRoom)&&(identical(other.hostResident, hostResident) || other.hostResident == hostResident)&&(identical(other.pointCloudUrl, pointCloudUrl) || other.pointCloudUrl == pointCloudUrl)&&(identical(other.roomScanGlbUrl, roomScanGlbUrl) || other.roomScanGlbUrl == roomScanGlbUrl)&&(identical(other.texturedGlbUrl, texturedGlbUrl) || other.texturedGlbUrl == texturedGlbUrl)&&(identical(other.photogrammetryStatus, photogrammetryStatus) || other.photogrammetryStatus == photogrammetryStatus)&&(identical(other.roomScanFloorLongM, roomScanFloorLongM) || other.roomScanFloorLongM == roomScanFloorLongM)&&(identical(other.roomScanFloorShortM, roomScanFloorShortM) || other.roomScanFloorShortM == roomScanFloorShortM)&&(identical(other.roomScanHeightM, roomScanHeightM) || other.roomScanHeightM == roomScanHeightM)&&(identical(other.roomScanFloorAreaM2, roomScanFloorAreaM2) || other.roomScanFloorAreaM2 == roomScanFloorAreaM2)&&(identical(other.roomScanWorldPlusXBearingDeg, roomScanWorldPlusXBearingDeg) || other.roomScanWorldPlusXBearingDeg == roomScanWorldPlusXBearingDeg)&&(identical(other.roomScanNorthCorrectionDeg, roomScanNorthCorrectionDeg) || other.roomScanNorthCorrectionDeg == roomScanNorthCorrectionDeg)&&(identical(other.subwayStation, subwayStation) || other.subwayStation == subwayStation)&&const DeepCollectionEquality().equals(other.searchSubwayStations, searchSubwayStations)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.searchLocations, searchLocations)&&(identical(other.listingType, listingType) || other.listingType == listingType)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited)&&(identical(other.groupSizeTarget, groupSizeTarget) || other.groupSizeTarget == groupSizeTarget)&&(identical(other.groupMemberCount, groupMemberCount) || other.groupMemberCount == groupMemberCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,title,listingTypeId,price,minPrice,maxPrice,isActive,createdAt,updatedAt,description,cityId,subwayStationId,subwayLineId,locationId,gender,locationPrecision,displayLat,displayLng,accuracyRadiusM,isApproximateLocation,featuredAt,renewedAt,nextRenewalAt,moveInDate,privateRoom,hostResident,pointCloudUrl,roomScanGlbUrl,texturedGlbUrl,photogrammetryStatus,roomScanFloorLongM,roomScanFloorShortM,roomScanHeightM,roomScanFloorAreaM2,roomScanWorldPlusXBearingDeg,roomScanNorthCorrectionDeg,subwayStation,const DeepCollectionEquality().hash(searchSubwayStations),location,const DeepCollectionEquality().hash(searchLocations),listingType,const DeepCollectionEquality().hash(amenities),const DeepCollectionEquality().hash(photos),isFavorited,groupSizeTarget,groupMemberCount]);

@override
String toString() {
  return 'Listing(id: $id, userId: $userId, title: $title, listingTypeId: $listingTypeId, price: $price, minPrice: $minPrice, maxPrice: $maxPrice, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, cityId: $cityId, subwayStationId: $subwayStationId, subwayLineId: $subwayLineId, locationId: $locationId, gender: $gender, locationPrecision: $locationPrecision, displayLat: $displayLat, displayLng: $displayLng, accuracyRadiusM: $accuracyRadiusM, isApproximateLocation: $isApproximateLocation, featuredAt: $featuredAt, renewedAt: $renewedAt, nextRenewalAt: $nextRenewalAt, moveInDate: $moveInDate, privateRoom: $privateRoom, hostResident: $hostResident, pointCloudUrl: $pointCloudUrl, roomScanGlbUrl: $roomScanGlbUrl, texturedGlbUrl: $texturedGlbUrl, photogrammetryStatus: $photogrammetryStatus, roomScanFloorLongM: $roomScanFloorLongM, roomScanFloorShortM: $roomScanFloorShortM, roomScanHeightM: $roomScanHeightM, roomScanFloorAreaM2: $roomScanFloorAreaM2, roomScanWorldPlusXBearingDeg: $roomScanWorldPlusXBearingDeg, roomScanNorthCorrectionDeg: $roomScanNorthCorrectionDeg, subwayStation: $subwayStation, searchSubwayStations: $searchSubwayStations, location: $location, searchLocations: $searchLocations, listingType: $listingType, amenities: $amenities, photos: $photos, isFavorited: $isFavorited, groupSizeTarget: $groupSizeTarget, groupMemberCount: $groupMemberCount)';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "user_id") int userId,@JsonKey(name: "title") String title,@JsonKey(name: "listing_type_id") int listingTypeId,@JsonKey(name: "price") int price,@JsonKey(name: "min_price") int? minPrice,@JsonKey(name: "max_price") int? maxPrice,@JsonKey(name: "is_active") bool isActive,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "description") String? description,@JsonKey(name: "city_id") int? cityId,@JsonKey(name: "subway_station_id") int? subwayStationId,@JsonKey(name: "subway_line_id") int? subwayLineId,@JsonKey(name: "location_id") int? locationId,@JsonKey(name: "gender") int? gender,@JsonKey(name: "location_precision") String? locationPrecision,@JsonKey(name: "display_lat") double? displayLat,@JsonKey(name: "display_lng") double? displayLng,@JsonKey(name: "accuracy_radius_m") int? accuracyRadiusM,@JsonKey(name: "is_approximate_location") bool? isApproximateLocation,@JsonKey(name: "featured_at") String? featuredAt,@JsonKey(name: "renewed_at") String? renewedAt,@JsonKey(name: "next_renewal_at") String? nextRenewalAt,@JsonKey(name: "move_in_date") String? moveInDate,@JsonKey(name: "private_room") bool? privateRoom,@JsonKey(name: "host_resident") bool? hostResident,@JsonKey(name: "point_cloud_url") String? pointCloudUrl,@JsonKey(name: "room_scan_glb_url") String? roomScanGlbUrl,@JsonKey(name: "textured_glb_url") String? texturedGlbUrl,@JsonKey(name: "photogrammetry_status") String? photogrammetryStatus,@JsonKey(name: "room_scan_floor_long_m") double? roomScanFloorLongM,@JsonKey(name: "room_scan_floor_short_m") double? roomScanFloorShortM,@JsonKey(name: "room_scan_height_m") double? roomScanHeightM,@JsonKey(name: "room_scan_floor_area_m2") double? roomScanFloorAreaM2,@JsonKey(name: "room_scan_world_plus_x_bearing_deg") double? roomScanWorldPlusXBearingDeg,@JsonKey(name: "room_scan_north_correction_deg") double? roomScanNorthCorrectionDeg,@JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? searchSubwayStations,@JsonKey(name: "location") LocationDetail? location,@JsonKey(name: "search_locations") List<LocationDetail>? searchLocations,@JsonKey(name: "listing_type") ListingTypeDetail? listingType,@JsonKey(name: "amenities") List<Amenity>? amenities, List<Photo>? photos,@JsonKey(name: "isFavorited") bool? isFavorited,@JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson) int? groupSizeTarget,@JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson) int? groupMemberCount
});


$SubwayStationDetailCopyWith<$Res>? get subwayStation;$LocationDetailCopyWith<$Res>? get location;$ListingTypeDetailCopyWith<$Res>? get listingType;

}
/// @nodoc
class _$ListingCopyWithImpl<$Res>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._self, this._then);

  final Listing _self;
  final $Res Function(Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? listingTypeId = null,Object? price = null,Object? minPrice = freezed,Object? maxPrice = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? cityId = freezed,Object? subwayStationId = freezed,Object? subwayLineId = freezed,Object? locationId = freezed,Object? gender = freezed,Object? locationPrecision = freezed,Object? displayLat = freezed,Object? displayLng = freezed,Object? accuracyRadiusM = freezed,Object? isApproximateLocation = freezed,Object? featuredAt = freezed,Object? renewedAt = freezed,Object? nextRenewalAt = freezed,Object? moveInDate = freezed,Object? privateRoom = freezed,Object? hostResident = freezed,Object? pointCloudUrl = freezed,Object? roomScanGlbUrl = freezed,Object? texturedGlbUrl = freezed,Object? photogrammetryStatus = freezed,Object? roomScanFloorLongM = freezed,Object? roomScanFloorShortM = freezed,Object? roomScanHeightM = freezed,Object? roomScanFloorAreaM2 = freezed,Object? roomScanWorldPlusXBearingDeg = freezed,Object? roomScanNorthCorrectionDeg = freezed,Object? subwayStation = freezed,Object? searchSubwayStations = freezed,Object? location = freezed,Object? searchLocations = freezed,Object? listingType = freezed,Object? amenities = freezed,Object? photos = freezed,Object? isFavorited = freezed,Object? groupSizeTarget = freezed,Object? groupMemberCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,listingTypeId: null == listingTypeId ? _self.listingTypeId : listingTypeId // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as int?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,subwayStationId: freezed == subwayStationId ? _self.subwayStationId : subwayStationId // ignore: cast_nullable_to_non_nullable
as int?,subwayLineId: freezed == subwayLineId ? _self.subwayLineId : subwayLineId // ignore: cast_nullable_to_non_nullable
as int?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,locationPrecision: freezed == locationPrecision ? _self.locationPrecision : locationPrecision // ignore: cast_nullable_to_non_nullable
as String?,displayLat: freezed == displayLat ? _self.displayLat : displayLat // ignore: cast_nullable_to_non_nullable
as double?,displayLng: freezed == displayLng ? _self.displayLng : displayLng // ignore: cast_nullable_to_non_nullable
as double?,accuracyRadiusM: freezed == accuracyRadiusM ? _self.accuracyRadiusM : accuracyRadiusM // ignore: cast_nullable_to_non_nullable
as int?,isApproximateLocation: freezed == isApproximateLocation ? _self.isApproximateLocation : isApproximateLocation // ignore: cast_nullable_to_non_nullable
as bool?,featuredAt: freezed == featuredAt ? _self.featuredAt : featuredAt // ignore: cast_nullable_to_non_nullable
as String?,renewedAt: freezed == renewedAt ? _self.renewedAt : renewedAt // ignore: cast_nullable_to_non_nullable
as String?,nextRenewalAt: freezed == nextRenewalAt ? _self.nextRenewalAt : nextRenewalAt // ignore: cast_nullable_to_non_nullable
as String?,moveInDate: freezed == moveInDate ? _self.moveInDate : moveInDate // ignore: cast_nullable_to_non_nullable
as String?,privateRoom: freezed == privateRoom ? _self.privateRoom : privateRoom // ignore: cast_nullable_to_non_nullable
as bool?,hostResident: freezed == hostResident ? _self.hostResident : hostResident // ignore: cast_nullable_to_non_nullable
as bool?,pointCloudUrl: freezed == pointCloudUrl ? _self.pointCloudUrl : pointCloudUrl // ignore: cast_nullable_to_non_nullable
as String?,roomScanGlbUrl: freezed == roomScanGlbUrl ? _self.roomScanGlbUrl : roomScanGlbUrl // ignore: cast_nullable_to_non_nullable
as String?,texturedGlbUrl: freezed == texturedGlbUrl ? _self.texturedGlbUrl : texturedGlbUrl // ignore: cast_nullable_to_non_nullable
as String?,photogrammetryStatus: freezed == photogrammetryStatus ? _self.photogrammetryStatus : photogrammetryStatus // ignore: cast_nullable_to_non_nullable
as String?,roomScanFloorLongM: freezed == roomScanFloorLongM ? _self.roomScanFloorLongM : roomScanFloorLongM // ignore: cast_nullable_to_non_nullable
as double?,roomScanFloorShortM: freezed == roomScanFloorShortM ? _self.roomScanFloorShortM : roomScanFloorShortM // ignore: cast_nullable_to_non_nullable
as double?,roomScanHeightM: freezed == roomScanHeightM ? _self.roomScanHeightM : roomScanHeightM // ignore: cast_nullable_to_non_nullable
as double?,roomScanFloorAreaM2: freezed == roomScanFloorAreaM2 ? _self.roomScanFloorAreaM2 : roomScanFloorAreaM2 // ignore: cast_nullable_to_non_nullable
as double?,roomScanWorldPlusXBearingDeg: freezed == roomScanWorldPlusXBearingDeg ? _self.roomScanWorldPlusXBearingDeg : roomScanWorldPlusXBearingDeg // ignore: cast_nullable_to_non_nullable
as double?,roomScanNorthCorrectionDeg: freezed == roomScanNorthCorrectionDeg ? _self.roomScanNorthCorrectionDeg : roomScanNorthCorrectionDeg // ignore: cast_nullable_to_non_nullable
as double?,subwayStation: freezed == subwayStation ? _self.subwayStation : subwayStation // ignore: cast_nullable_to_non_nullable
as SubwayStationDetail?,searchSubwayStations: freezed == searchSubwayStations ? _self.searchSubwayStations : searchSubwayStations // ignore: cast_nullable_to_non_nullable
as List<SubwayStationDetail>?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationDetail?,searchLocations: freezed == searchLocations ? _self.searchLocations : searchLocations // ignore: cast_nullable_to_non_nullable
as List<LocationDetail>?,listingType: freezed == listingType ? _self.listingType : listingType // ignore: cast_nullable_to_non_nullable
as ListingTypeDetail?,amenities: freezed == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<Amenity>?,photos: freezed == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<Photo>?,isFavorited: freezed == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool?,groupSizeTarget: freezed == groupSizeTarget ? _self.groupSizeTarget : groupSizeTarget // ignore: cast_nullable_to_non_nullable
as int?,groupMemberCount: freezed == groupMemberCount ? _self.groupMemberCount : groupMemberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubwayStationDetailCopyWith<$Res>? get subwayStation {
    if (_self.subwayStation == null) {
    return null;
  }

  return $SubwayStationDetailCopyWith<$Res>(_self.subwayStation!, (value) {
    return _then(_self.copyWith(subwayStation: value));
  });
}/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationDetailCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationDetailCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingTypeDetailCopyWith<$Res>? get listingType {
    if (_self.listingType == null) {
    return null;
  }

  return $ListingTypeDetailCopyWith<$Res>(_self.listingType!, (value) {
    return _then(_self.copyWith(listingType: value));
  });
}
}


/// Adds pattern-matching-related methods to [Listing].
extension ListingPatterns on Listing {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Listing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Listing value)  $default,){
final _that = this;
switch (_that) {
case _Listing():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Listing value)?  $default,){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "user_id")  int userId, @JsonKey(name: "title")  String title, @JsonKey(name: "listing_type_id")  int listingTypeId, @JsonKey(name: "price")  int price, @JsonKey(name: "min_price")  int? minPrice, @JsonKey(name: "max_price")  int? maxPrice, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "description")  String? description, @JsonKey(name: "city_id")  int? cityId, @JsonKey(name: "subway_station_id")  int? subwayStationId, @JsonKey(name: "subway_line_id")  int? subwayLineId, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "gender")  int? gender, @JsonKey(name: "location_precision")  String? locationPrecision, @JsonKey(name: "display_lat")  double? displayLat, @JsonKey(name: "display_lng")  double? displayLng, @JsonKey(name: "accuracy_radius_m")  int? accuracyRadiusM, @JsonKey(name: "is_approximate_location")  bool? isApproximateLocation, @JsonKey(name: "featured_at")  String? featuredAt, @JsonKey(name: "renewed_at")  String? renewedAt, @JsonKey(name: "next_renewal_at")  String? nextRenewalAt, @JsonKey(name: "move_in_date")  String? moveInDate, @JsonKey(name: "private_room")  bool? privateRoom, @JsonKey(name: "host_resident")  bool? hostResident, @JsonKey(name: "point_cloud_url")  String? pointCloudUrl, @JsonKey(name: "room_scan_glb_url")  String? roomScanGlbUrl, @JsonKey(name: "textured_glb_url")  String? texturedGlbUrl, @JsonKey(name: "photogrammetry_status")  String? photogrammetryStatus, @JsonKey(name: "room_scan_floor_long_m")  double? roomScanFloorLongM, @JsonKey(name: "room_scan_floor_short_m")  double? roomScanFloorShortM, @JsonKey(name: "room_scan_height_m")  double? roomScanHeightM, @JsonKey(name: "room_scan_floor_area_m2")  double? roomScanFloorAreaM2, @JsonKey(name: "room_scan_world_plus_x_bearing_deg")  double? roomScanWorldPlusXBearingDeg, @JsonKey(name: "room_scan_north_correction_deg")  double? roomScanNorthCorrectionDeg, @JsonKey(name: "subway_station")  SubwayStationDetail? subwayStation, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations, @JsonKey(name: "location")  LocationDetail? location, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations, @JsonKey(name: "listing_type")  ListingTypeDetail? listingType, @JsonKey(name: "amenities")  List<Amenity>? amenities,  List<Photo>? photos, @JsonKey(name: "isFavorited")  bool? isFavorited, @JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson)  int? groupSizeTarget, @JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson)  int? groupMemberCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.listingTypeId,_that.price,_that.minPrice,_that.maxPrice,_that.isActive,_that.createdAt,_that.updatedAt,_that.description,_that.cityId,_that.subwayStationId,_that.subwayLineId,_that.locationId,_that.gender,_that.locationPrecision,_that.displayLat,_that.displayLng,_that.accuracyRadiusM,_that.isApproximateLocation,_that.featuredAt,_that.renewedAt,_that.nextRenewalAt,_that.moveInDate,_that.privateRoom,_that.hostResident,_that.pointCloudUrl,_that.roomScanGlbUrl,_that.texturedGlbUrl,_that.photogrammetryStatus,_that.roomScanFloorLongM,_that.roomScanFloorShortM,_that.roomScanHeightM,_that.roomScanFloorAreaM2,_that.roomScanWorldPlusXBearingDeg,_that.roomScanNorthCorrectionDeg,_that.subwayStation,_that.searchSubwayStations,_that.location,_that.searchLocations,_that.listingType,_that.amenities,_that.photos,_that.isFavorited,_that.groupSizeTarget,_that.groupMemberCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "user_id")  int userId, @JsonKey(name: "title")  String title, @JsonKey(name: "listing_type_id")  int listingTypeId, @JsonKey(name: "price")  int price, @JsonKey(name: "min_price")  int? minPrice, @JsonKey(name: "max_price")  int? maxPrice, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "description")  String? description, @JsonKey(name: "city_id")  int? cityId, @JsonKey(name: "subway_station_id")  int? subwayStationId, @JsonKey(name: "subway_line_id")  int? subwayLineId, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "gender")  int? gender, @JsonKey(name: "location_precision")  String? locationPrecision, @JsonKey(name: "display_lat")  double? displayLat, @JsonKey(name: "display_lng")  double? displayLng, @JsonKey(name: "accuracy_radius_m")  int? accuracyRadiusM, @JsonKey(name: "is_approximate_location")  bool? isApproximateLocation, @JsonKey(name: "featured_at")  String? featuredAt, @JsonKey(name: "renewed_at")  String? renewedAt, @JsonKey(name: "next_renewal_at")  String? nextRenewalAt, @JsonKey(name: "move_in_date")  String? moveInDate, @JsonKey(name: "private_room")  bool? privateRoom, @JsonKey(name: "host_resident")  bool? hostResident, @JsonKey(name: "point_cloud_url")  String? pointCloudUrl, @JsonKey(name: "room_scan_glb_url")  String? roomScanGlbUrl, @JsonKey(name: "textured_glb_url")  String? texturedGlbUrl, @JsonKey(name: "photogrammetry_status")  String? photogrammetryStatus, @JsonKey(name: "room_scan_floor_long_m")  double? roomScanFloorLongM, @JsonKey(name: "room_scan_floor_short_m")  double? roomScanFloorShortM, @JsonKey(name: "room_scan_height_m")  double? roomScanHeightM, @JsonKey(name: "room_scan_floor_area_m2")  double? roomScanFloorAreaM2, @JsonKey(name: "room_scan_world_plus_x_bearing_deg")  double? roomScanWorldPlusXBearingDeg, @JsonKey(name: "room_scan_north_correction_deg")  double? roomScanNorthCorrectionDeg, @JsonKey(name: "subway_station")  SubwayStationDetail? subwayStation, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations, @JsonKey(name: "location")  LocationDetail? location, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations, @JsonKey(name: "listing_type")  ListingTypeDetail? listingType, @JsonKey(name: "amenities")  List<Amenity>? amenities,  List<Photo>? photos, @JsonKey(name: "isFavorited")  bool? isFavorited, @JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson)  int? groupSizeTarget, @JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson)  int? groupMemberCount)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.userId,_that.title,_that.listingTypeId,_that.price,_that.minPrice,_that.maxPrice,_that.isActive,_that.createdAt,_that.updatedAt,_that.description,_that.cityId,_that.subwayStationId,_that.subwayLineId,_that.locationId,_that.gender,_that.locationPrecision,_that.displayLat,_that.displayLng,_that.accuracyRadiusM,_that.isApproximateLocation,_that.featuredAt,_that.renewedAt,_that.nextRenewalAt,_that.moveInDate,_that.privateRoom,_that.hostResident,_that.pointCloudUrl,_that.roomScanGlbUrl,_that.texturedGlbUrl,_that.photogrammetryStatus,_that.roomScanFloorLongM,_that.roomScanFloorShortM,_that.roomScanHeightM,_that.roomScanFloorAreaM2,_that.roomScanWorldPlusXBearingDeg,_that.roomScanNorthCorrectionDeg,_that.subwayStation,_that.searchSubwayStations,_that.location,_that.searchLocations,_that.listingType,_that.amenities,_that.photos,_that.isFavorited,_that.groupSizeTarget,_that.groupMemberCount);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "user_id")  int userId, @JsonKey(name: "title")  String title, @JsonKey(name: "listing_type_id")  int listingTypeId, @JsonKey(name: "price")  int price, @JsonKey(name: "min_price")  int? minPrice, @JsonKey(name: "max_price")  int? maxPrice, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "description")  String? description, @JsonKey(name: "city_id")  int? cityId, @JsonKey(name: "subway_station_id")  int? subwayStationId, @JsonKey(name: "subway_line_id")  int? subwayLineId, @JsonKey(name: "location_id")  int? locationId, @JsonKey(name: "gender")  int? gender, @JsonKey(name: "location_precision")  String? locationPrecision, @JsonKey(name: "display_lat")  double? displayLat, @JsonKey(name: "display_lng")  double? displayLng, @JsonKey(name: "accuracy_radius_m")  int? accuracyRadiusM, @JsonKey(name: "is_approximate_location")  bool? isApproximateLocation, @JsonKey(name: "featured_at")  String? featuredAt, @JsonKey(name: "renewed_at")  String? renewedAt, @JsonKey(name: "next_renewal_at")  String? nextRenewalAt, @JsonKey(name: "move_in_date")  String? moveInDate, @JsonKey(name: "private_room")  bool? privateRoom, @JsonKey(name: "host_resident")  bool? hostResident, @JsonKey(name: "point_cloud_url")  String? pointCloudUrl, @JsonKey(name: "room_scan_glb_url")  String? roomScanGlbUrl, @JsonKey(name: "textured_glb_url")  String? texturedGlbUrl, @JsonKey(name: "photogrammetry_status")  String? photogrammetryStatus, @JsonKey(name: "room_scan_floor_long_m")  double? roomScanFloorLongM, @JsonKey(name: "room_scan_floor_short_m")  double? roomScanFloorShortM, @JsonKey(name: "room_scan_height_m")  double? roomScanHeightM, @JsonKey(name: "room_scan_floor_area_m2")  double? roomScanFloorAreaM2, @JsonKey(name: "room_scan_world_plus_x_bearing_deg")  double? roomScanWorldPlusXBearingDeg, @JsonKey(name: "room_scan_north_correction_deg")  double? roomScanNorthCorrectionDeg, @JsonKey(name: "subway_station")  SubwayStationDetail? subwayStation, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations, @JsonKey(name: "location")  LocationDetail? location, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations, @JsonKey(name: "listing_type")  ListingTypeDetail? listingType, @JsonKey(name: "amenities")  List<Amenity>? amenities,  List<Photo>? photos, @JsonKey(name: "isFavorited")  bool? isFavorited, @JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson)  int? groupSizeTarget, @JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson)  int? groupMemberCount)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.listingTypeId,_that.price,_that.minPrice,_that.maxPrice,_that.isActive,_that.createdAt,_that.updatedAt,_that.description,_that.cityId,_that.subwayStationId,_that.subwayLineId,_that.locationId,_that.gender,_that.locationPrecision,_that.displayLat,_that.displayLng,_that.accuracyRadiusM,_that.isApproximateLocation,_that.featuredAt,_that.renewedAt,_that.nextRenewalAt,_that.moveInDate,_that.privateRoom,_that.hostResident,_that.pointCloudUrl,_that.roomScanGlbUrl,_that.texturedGlbUrl,_that.photogrammetryStatus,_that.roomScanFloorLongM,_that.roomScanFloorShortM,_that.roomScanHeightM,_that.roomScanFloorAreaM2,_that.roomScanWorldPlusXBearingDeg,_that.roomScanNorthCorrectionDeg,_that.subwayStation,_that.searchSubwayStations,_that.location,_that.searchLocations,_that.listingType,_that.amenities,_that.photos,_that.isFavorited,_that.groupSizeTarget,_that.groupMemberCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Listing implements Listing {
  const _Listing({required this.id, @JsonKey(name: "user_id") required this.userId, @JsonKey(name: "title") required this.title, @JsonKey(name: "listing_type_id") required this.listingTypeId, @JsonKey(name: "price") required this.price, @JsonKey(name: "min_price") this.minPrice, @JsonKey(name: "max_price") this.maxPrice, @JsonKey(name: "is_active") required this.isActive, @JsonKey(name: "created_at") required this.createdAt, @JsonKey(name: "updated_at") required this.updatedAt, @JsonKey(name: "description") this.description, @JsonKey(name: "city_id") this.cityId, @JsonKey(name: "subway_station_id") this.subwayStationId, @JsonKey(name: "subway_line_id") this.subwayLineId, @JsonKey(name: "location_id") this.locationId, @JsonKey(name: "gender") this.gender, @JsonKey(name: "location_precision") this.locationPrecision, @JsonKey(name: "display_lat") this.displayLat, @JsonKey(name: "display_lng") this.displayLng, @JsonKey(name: "accuracy_radius_m") this.accuracyRadiusM, @JsonKey(name: "is_approximate_location") this.isApproximateLocation, @JsonKey(name: "featured_at") this.featuredAt, @JsonKey(name: "renewed_at") this.renewedAt, @JsonKey(name: "next_renewal_at") this.nextRenewalAt, @JsonKey(name: "move_in_date") this.moveInDate, @JsonKey(name: "private_room") this.privateRoom, @JsonKey(name: "host_resident") this.hostResident, @JsonKey(name: "point_cloud_url") this.pointCloudUrl, @JsonKey(name: "room_scan_glb_url") this.roomScanGlbUrl, @JsonKey(name: "textured_glb_url") this.texturedGlbUrl, @JsonKey(name: "photogrammetry_status") this.photogrammetryStatus, @JsonKey(name: "room_scan_floor_long_m") this.roomScanFloorLongM, @JsonKey(name: "room_scan_floor_short_m") this.roomScanFloorShortM, @JsonKey(name: "room_scan_height_m") this.roomScanHeightM, @JsonKey(name: "room_scan_floor_area_m2") this.roomScanFloorAreaM2, @JsonKey(name: "room_scan_world_plus_x_bearing_deg") this.roomScanWorldPlusXBearingDeg, @JsonKey(name: "room_scan_north_correction_deg") this.roomScanNorthCorrectionDeg, @JsonKey(name: "subway_station") this.subwayStation, @JsonKey(name: "search_subway_stations") final  List<SubwayStationDetail>? searchSubwayStations, @JsonKey(name: "location") this.location, @JsonKey(name: "search_locations") final  List<LocationDetail>? searchLocations, @JsonKey(name: "listing_type") this.listingType, @JsonKey(name: "amenities") final  List<Amenity>? amenities, final  List<Photo>? photos, @JsonKey(name: "isFavorited") this.isFavorited, @JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson) this.groupSizeTarget, @JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson) this.groupMemberCount}): _searchSubwayStations = searchSubwayStations,_searchLocations = searchLocations,_amenities = amenities,_photos = photos;
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  int id;
@override@JsonKey(name: "user_id") final  int userId;
@override@JsonKey(name: "title") final  String title;
@override@JsonKey(name: "listing_type_id") final  int listingTypeId;
@override@JsonKey(name: "price") final  int price;
@override@JsonKey(name: "min_price") final  int? minPrice;
@override@JsonKey(name: "max_price") final  int? maxPrice;
@override@JsonKey(name: "is_active") final  bool isActive;
@override@JsonKey(name: "created_at") final  String createdAt;
@override@JsonKey(name: "updated_at") final  String updatedAt;
@override@JsonKey(name: "description") final  String? description;
@override@JsonKey(name: "city_id") final  int? cityId;
@override@JsonKey(name: "subway_station_id") final  int? subwayStationId;
@override@JsonKey(name: "subway_line_id") final  int? subwayLineId;
@override@JsonKey(name: "location_id") final  int? locationId;
@override@JsonKey(name: "gender") final  int? gender;
@override@JsonKey(name: "location_precision") final  String? locationPrecision;
@override@JsonKey(name: "display_lat") final  double? displayLat;
@override@JsonKey(name: "display_lng") final  double? displayLng;
@override@JsonKey(name: "accuracy_radius_m") final  int? accuracyRadiusM;
@override@JsonKey(name: "is_approximate_location") final  bool? isApproximateLocation;
@override@JsonKey(name: "featured_at") final  String? featuredAt;
@override@JsonKey(name: "renewed_at") final  String? renewedAt;
@override@JsonKey(name: "next_renewal_at") final  String? nextRenewalAt;
@override@JsonKey(name: "move_in_date") final  String? moveInDate;
@override@JsonKey(name: "private_room") final  bool? privateRoom;
@override@JsonKey(name: "host_resident") final  bool? hostResident;
@override@JsonKey(name: "point_cloud_url") final  String? pointCloudUrl;
@override@JsonKey(name: "room_scan_glb_url") final  String? roomScanGlbUrl;
@override@JsonKey(name: "textured_glb_url") final  String? texturedGlbUrl;
@override@JsonKey(name: "photogrammetry_status") final  String? photogrammetryStatus;
@override@JsonKey(name: "room_scan_floor_long_m") final  double? roomScanFloorLongM;
@override@JsonKey(name: "room_scan_floor_short_m") final  double? roomScanFloorShortM;
@override@JsonKey(name: "room_scan_height_m") final  double? roomScanHeightM;
@override@JsonKey(name: "room_scan_floor_area_m2") final  double? roomScanFloorAreaM2;
@override@JsonKey(name: "room_scan_world_plus_x_bearing_deg") final  double? roomScanWorldPlusXBearingDeg;
@override@JsonKey(name: "room_scan_north_correction_deg") final  double? roomScanNorthCorrectionDeg;
@override@JsonKey(name: "subway_station") final  SubwayStationDetail? subwayStation;
 final  List<SubwayStationDetail>? _searchSubwayStations;
@override@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? get searchSubwayStations {
  final value = _searchSubwayStations;
  if (value == null) return null;
  if (_searchSubwayStations is EqualUnmodifiableListView) return _searchSubwayStations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: "location") final  LocationDetail? location;
 final  List<LocationDetail>? _searchLocations;
@override@JsonKey(name: "search_locations") List<LocationDetail>? get searchLocations {
  final value = _searchLocations;
  if (value == null) return null;
  if (_searchLocations is EqualUnmodifiableListView) return _searchLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: "listing_type") final  ListingTypeDetail? listingType;
 final  List<Amenity>? _amenities;
@override@JsonKey(name: "amenities") List<Amenity>? get amenities {
  final value = _amenities;
  if (value == null) return null;
  if (_amenities is EqualUnmodifiableListView) return _amenities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Photo>? _photos;
@override List<Photo>? get photos {
  final value = _photos;
  if (value == null) return null;
  if (_photos is EqualUnmodifiableListView) return _photos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: "isFavorited") final  bool? isFavorited;
@override@JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson) final  int? groupSizeTarget;
@override@JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson) final  int? groupMemberCount;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCopyWith<_Listing> get copyWith => __$ListingCopyWithImpl<_Listing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.listingTypeId, listingTypeId) || other.listingTypeId == listingTypeId)&&(identical(other.price, price) || other.price == price)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.subwayStationId, subwayStationId) || other.subwayStationId == subwayStationId)&&(identical(other.subwayLineId, subwayLineId) || other.subwayLineId == subwayLineId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.locationPrecision, locationPrecision) || other.locationPrecision == locationPrecision)&&(identical(other.displayLat, displayLat) || other.displayLat == displayLat)&&(identical(other.displayLng, displayLng) || other.displayLng == displayLng)&&(identical(other.accuracyRadiusM, accuracyRadiusM) || other.accuracyRadiusM == accuracyRadiusM)&&(identical(other.isApproximateLocation, isApproximateLocation) || other.isApproximateLocation == isApproximateLocation)&&(identical(other.featuredAt, featuredAt) || other.featuredAt == featuredAt)&&(identical(other.renewedAt, renewedAt) || other.renewedAt == renewedAt)&&(identical(other.nextRenewalAt, nextRenewalAt) || other.nextRenewalAt == nextRenewalAt)&&(identical(other.moveInDate, moveInDate) || other.moveInDate == moveInDate)&&(identical(other.privateRoom, privateRoom) || other.privateRoom == privateRoom)&&(identical(other.hostResident, hostResident) || other.hostResident == hostResident)&&(identical(other.pointCloudUrl, pointCloudUrl) || other.pointCloudUrl == pointCloudUrl)&&(identical(other.roomScanGlbUrl, roomScanGlbUrl) || other.roomScanGlbUrl == roomScanGlbUrl)&&(identical(other.texturedGlbUrl, texturedGlbUrl) || other.texturedGlbUrl == texturedGlbUrl)&&(identical(other.photogrammetryStatus, photogrammetryStatus) || other.photogrammetryStatus == photogrammetryStatus)&&(identical(other.roomScanFloorLongM, roomScanFloorLongM) || other.roomScanFloorLongM == roomScanFloorLongM)&&(identical(other.roomScanFloorShortM, roomScanFloorShortM) || other.roomScanFloorShortM == roomScanFloorShortM)&&(identical(other.roomScanHeightM, roomScanHeightM) || other.roomScanHeightM == roomScanHeightM)&&(identical(other.roomScanFloorAreaM2, roomScanFloorAreaM2) || other.roomScanFloorAreaM2 == roomScanFloorAreaM2)&&(identical(other.roomScanWorldPlusXBearingDeg, roomScanWorldPlusXBearingDeg) || other.roomScanWorldPlusXBearingDeg == roomScanWorldPlusXBearingDeg)&&(identical(other.roomScanNorthCorrectionDeg, roomScanNorthCorrectionDeg) || other.roomScanNorthCorrectionDeg == roomScanNorthCorrectionDeg)&&(identical(other.subwayStation, subwayStation) || other.subwayStation == subwayStation)&&const DeepCollectionEquality().equals(other._searchSubwayStations, _searchSubwayStations)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._searchLocations, _searchLocations)&&(identical(other.listingType, listingType) || other.listingType == listingType)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.isFavorited, isFavorited) || other.isFavorited == isFavorited)&&(identical(other.groupSizeTarget, groupSizeTarget) || other.groupSizeTarget == groupSizeTarget)&&(identical(other.groupMemberCount, groupMemberCount) || other.groupMemberCount == groupMemberCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,title,listingTypeId,price,minPrice,maxPrice,isActive,createdAt,updatedAt,description,cityId,subwayStationId,subwayLineId,locationId,gender,locationPrecision,displayLat,displayLng,accuracyRadiusM,isApproximateLocation,featuredAt,renewedAt,nextRenewalAt,moveInDate,privateRoom,hostResident,pointCloudUrl,roomScanGlbUrl,texturedGlbUrl,photogrammetryStatus,roomScanFloorLongM,roomScanFloorShortM,roomScanHeightM,roomScanFloorAreaM2,roomScanWorldPlusXBearingDeg,roomScanNorthCorrectionDeg,subwayStation,const DeepCollectionEquality().hash(_searchSubwayStations),location,const DeepCollectionEquality().hash(_searchLocations),listingType,const DeepCollectionEquality().hash(_amenities),const DeepCollectionEquality().hash(_photos),isFavorited,groupSizeTarget,groupMemberCount]);

@override
String toString() {
  return 'Listing(id: $id, userId: $userId, title: $title, listingTypeId: $listingTypeId, price: $price, minPrice: $minPrice, maxPrice: $maxPrice, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, cityId: $cityId, subwayStationId: $subwayStationId, subwayLineId: $subwayLineId, locationId: $locationId, gender: $gender, locationPrecision: $locationPrecision, displayLat: $displayLat, displayLng: $displayLng, accuracyRadiusM: $accuracyRadiusM, isApproximateLocation: $isApproximateLocation, featuredAt: $featuredAt, renewedAt: $renewedAt, nextRenewalAt: $nextRenewalAt, moveInDate: $moveInDate, privateRoom: $privateRoom, hostResident: $hostResident, pointCloudUrl: $pointCloudUrl, roomScanGlbUrl: $roomScanGlbUrl, texturedGlbUrl: $texturedGlbUrl, photogrammetryStatus: $photogrammetryStatus, roomScanFloorLongM: $roomScanFloorLongM, roomScanFloorShortM: $roomScanFloorShortM, roomScanHeightM: $roomScanHeightM, roomScanFloorAreaM2: $roomScanFloorAreaM2, roomScanWorldPlusXBearingDeg: $roomScanWorldPlusXBearingDeg, roomScanNorthCorrectionDeg: $roomScanNorthCorrectionDeg, subwayStation: $subwayStation, searchSubwayStations: $searchSubwayStations, location: $location, searchLocations: $searchLocations, listingType: $listingType, amenities: $amenities, photos: $photos, isFavorited: $isFavorited, groupSizeTarget: $groupSizeTarget, groupMemberCount: $groupMemberCount)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "user_id") int userId,@JsonKey(name: "title") String title,@JsonKey(name: "listing_type_id") int listingTypeId,@JsonKey(name: "price") int price,@JsonKey(name: "min_price") int? minPrice,@JsonKey(name: "max_price") int? maxPrice,@JsonKey(name: "is_active") bool isActive,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "description") String? description,@JsonKey(name: "city_id") int? cityId,@JsonKey(name: "subway_station_id") int? subwayStationId,@JsonKey(name: "subway_line_id") int? subwayLineId,@JsonKey(name: "location_id") int? locationId,@JsonKey(name: "gender") int? gender,@JsonKey(name: "location_precision") String? locationPrecision,@JsonKey(name: "display_lat") double? displayLat,@JsonKey(name: "display_lng") double? displayLng,@JsonKey(name: "accuracy_radius_m") int? accuracyRadiusM,@JsonKey(name: "is_approximate_location") bool? isApproximateLocation,@JsonKey(name: "featured_at") String? featuredAt,@JsonKey(name: "renewed_at") String? renewedAt,@JsonKey(name: "next_renewal_at") String? nextRenewalAt,@JsonKey(name: "move_in_date") String? moveInDate,@JsonKey(name: "private_room") bool? privateRoom,@JsonKey(name: "host_resident") bool? hostResident,@JsonKey(name: "point_cloud_url") String? pointCloudUrl,@JsonKey(name: "room_scan_glb_url") String? roomScanGlbUrl,@JsonKey(name: "textured_glb_url") String? texturedGlbUrl,@JsonKey(name: "photogrammetry_status") String? photogrammetryStatus,@JsonKey(name: "room_scan_floor_long_m") double? roomScanFloorLongM,@JsonKey(name: "room_scan_floor_short_m") double? roomScanFloorShortM,@JsonKey(name: "room_scan_height_m") double? roomScanHeightM,@JsonKey(name: "room_scan_floor_area_m2") double? roomScanFloorAreaM2,@JsonKey(name: "room_scan_world_plus_x_bearing_deg") double? roomScanWorldPlusXBearingDeg,@JsonKey(name: "room_scan_north_correction_deg") double? roomScanNorthCorrectionDeg,@JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? searchSubwayStations,@JsonKey(name: "location") LocationDetail? location,@JsonKey(name: "search_locations") List<LocationDetail>? searchLocations,@JsonKey(name: "listing_type") ListingTypeDetail? listingType,@JsonKey(name: "amenities") List<Amenity>? amenities, List<Photo>? photos,@JsonKey(name: "isFavorited") bool? isFavorited,@JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson) int? groupSizeTarget,@JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson) int? groupMemberCount
});


@override $SubwayStationDetailCopyWith<$Res>? get subwayStation;@override $LocationDetailCopyWith<$Res>? get location;@override $ListingTypeDetailCopyWith<$Res>? get listingType;

}
/// @nodoc
class __$ListingCopyWithImpl<$Res>
    implements _$ListingCopyWith<$Res> {
  __$ListingCopyWithImpl(this._self, this._then);

  final _Listing _self;
  final $Res Function(_Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? listingTypeId = null,Object? price = null,Object? minPrice = freezed,Object? maxPrice = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? description = freezed,Object? cityId = freezed,Object? subwayStationId = freezed,Object? subwayLineId = freezed,Object? locationId = freezed,Object? gender = freezed,Object? locationPrecision = freezed,Object? displayLat = freezed,Object? displayLng = freezed,Object? accuracyRadiusM = freezed,Object? isApproximateLocation = freezed,Object? featuredAt = freezed,Object? renewedAt = freezed,Object? nextRenewalAt = freezed,Object? moveInDate = freezed,Object? privateRoom = freezed,Object? hostResident = freezed,Object? pointCloudUrl = freezed,Object? roomScanGlbUrl = freezed,Object? texturedGlbUrl = freezed,Object? photogrammetryStatus = freezed,Object? roomScanFloorLongM = freezed,Object? roomScanFloorShortM = freezed,Object? roomScanHeightM = freezed,Object? roomScanFloorAreaM2 = freezed,Object? roomScanWorldPlusXBearingDeg = freezed,Object? roomScanNorthCorrectionDeg = freezed,Object? subwayStation = freezed,Object? searchSubwayStations = freezed,Object? location = freezed,Object? searchLocations = freezed,Object? listingType = freezed,Object? amenities = freezed,Object? photos = freezed,Object? isFavorited = freezed,Object? groupSizeTarget = freezed,Object? groupMemberCount = freezed,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,listingTypeId: null == listingTypeId ? _self.listingTypeId : listingTypeId // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as int?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,subwayStationId: freezed == subwayStationId ? _self.subwayStationId : subwayStationId // ignore: cast_nullable_to_non_nullable
as int?,subwayLineId: freezed == subwayLineId ? _self.subwayLineId : subwayLineId // ignore: cast_nullable_to_non_nullable
as int?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,locationPrecision: freezed == locationPrecision ? _self.locationPrecision : locationPrecision // ignore: cast_nullable_to_non_nullable
as String?,displayLat: freezed == displayLat ? _self.displayLat : displayLat // ignore: cast_nullable_to_non_nullable
as double?,displayLng: freezed == displayLng ? _self.displayLng : displayLng // ignore: cast_nullable_to_non_nullable
as double?,accuracyRadiusM: freezed == accuracyRadiusM ? _self.accuracyRadiusM : accuracyRadiusM // ignore: cast_nullable_to_non_nullable
as int?,isApproximateLocation: freezed == isApproximateLocation ? _self.isApproximateLocation : isApproximateLocation // ignore: cast_nullable_to_non_nullable
as bool?,featuredAt: freezed == featuredAt ? _self.featuredAt : featuredAt // ignore: cast_nullable_to_non_nullable
as String?,renewedAt: freezed == renewedAt ? _self.renewedAt : renewedAt // ignore: cast_nullable_to_non_nullable
as String?,nextRenewalAt: freezed == nextRenewalAt ? _self.nextRenewalAt : nextRenewalAt // ignore: cast_nullable_to_non_nullable
as String?,moveInDate: freezed == moveInDate ? _self.moveInDate : moveInDate // ignore: cast_nullable_to_non_nullable
as String?,privateRoom: freezed == privateRoom ? _self.privateRoom : privateRoom // ignore: cast_nullable_to_non_nullable
as bool?,hostResident: freezed == hostResident ? _self.hostResident : hostResident // ignore: cast_nullable_to_non_nullable
as bool?,pointCloudUrl: freezed == pointCloudUrl ? _self.pointCloudUrl : pointCloudUrl // ignore: cast_nullable_to_non_nullable
as String?,roomScanGlbUrl: freezed == roomScanGlbUrl ? _self.roomScanGlbUrl : roomScanGlbUrl // ignore: cast_nullable_to_non_nullable
as String?,texturedGlbUrl: freezed == texturedGlbUrl ? _self.texturedGlbUrl : texturedGlbUrl // ignore: cast_nullable_to_non_nullable
as String?,photogrammetryStatus: freezed == photogrammetryStatus ? _self.photogrammetryStatus : photogrammetryStatus // ignore: cast_nullable_to_non_nullable
as String?,roomScanFloorLongM: freezed == roomScanFloorLongM ? _self.roomScanFloorLongM : roomScanFloorLongM // ignore: cast_nullable_to_non_nullable
as double?,roomScanFloorShortM: freezed == roomScanFloorShortM ? _self.roomScanFloorShortM : roomScanFloorShortM // ignore: cast_nullable_to_non_nullable
as double?,roomScanHeightM: freezed == roomScanHeightM ? _self.roomScanHeightM : roomScanHeightM // ignore: cast_nullable_to_non_nullable
as double?,roomScanFloorAreaM2: freezed == roomScanFloorAreaM2 ? _self.roomScanFloorAreaM2 : roomScanFloorAreaM2 // ignore: cast_nullable_to_non_nullable
as double?,roomScanWorldPlusXBearingDeg: freezed == roomScanWorldPlusXBearingDeg ? _self.roomScanWorldPlusXBearingDeg : roomScanWorldPlusXBearingDeg // ignore: cast_nullable_to_non_nullable
as double?,roomScanNorthCorrectionDeg: freezed == roomScanNorthCorrectionDeg ? _self.roomScanNorthCorrectionDeg : roomScanNorthCorrectionDeg // ignore: cast_nullable_to_non_nullable
as double?,subwayStation: freezed == subwayStation ? _self.subwayStation : subwayStation // ignore: cast_nullable_to_non_nullable
as SubwayStationDetail?,searchSubwayStations: freezed == searchSubwayStations ? _self._searchSubwayStations : searchSubwayStations // ignore: cast_nullable_to_non_nullable
as List<SubwayStationDetail>?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationDetail?,searchLocations: freezed == searchLocations ? _self._searchLocations : searchLocations // ignore: cast_nullable_to_non_nullable
as List<LocationDetail>?,listingType: freezed == listingType ? _self.listingType : listingType // ignore: cast_nullable_to_non_nullable
as ListingTypeDetail?,amenities: freezed == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<Amenity>?,photos: freezed == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<Photo>?,isFavorited: freezed == isFavorited ? _self.isFavorited : isFavorited // ignore: cast_nullable_to_non_nullable
as bool?,groupSizeTarget: freezed == groupSizeTarget ? _self.groupSizeTarget : groupSizeTarget // ignore: cast_nullable_to_non_nullable
as int?,groupMemberCount: freezed == groupMemberCount ? _self.groupMemberCount : groupMemberCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubwayStationDetailCopyWith<$Res>? get subwayStation {
    if (_self.subwayStation == null) {
    return null;
  }

  return $SubwayStationDetailCopyWith<$Res>(_self.subwayStation!, (value) {
    return _then(_self.copyWith(subwayStation: value));
  });
}/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationDetailCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationDetailCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingTypeDetailCopyWith<$Res>? get listingType {
    if (_self.listingType == null) {
    return null;
  }

  return $ListingTypeDetailCopyWith<$Res>(_self.listingType!, (value) {
    return _then(_self.copyWith(listingType: value));
  });
}
}


/// @nodoc
mixin _$SubwayStationDetail {

 int get id; int get line;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_en") String? get nameEn;
/// Create a copy of SubwayStationDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubwayStationDetailCopyWith<SubwayStationDetail> get copyWith => _$SubwayStationDetailCopyWithImpl<SubwayStationDetail>(this as SubwayStationDetail, _$identity);

  /// Serializes this SubwayStationDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubwayStationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.line, line) || other.line == line)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,line,nameUz,nameRu,nameEn);

@override
String toString() {
  return 'SubwayStationDetail(id: $id, line: $line, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn)';
}


}

/// @nodoc
abstract mixin class $SubwayStationDetailCopyWith<$Res>  {
  factory $SubwayStationDetailCopyWith(SubwayStationDetail value, $Res Function(SubwayStationDetail) _then) = _$SubwayStationDetailCopyWithImpl;
@useResult
$Res call({
 int id, int line,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn
});




}
/// @nodoc
class _$SubwayStationDetailCopyWithImpl<$Res>
    implements $SubwayStationDetailCopyWith<$Res> {
  _$SubwayStationDetailCopyWithImpl(this._self, this._then);

  final SubwayStationDetail _self;
  final $Res Function(SubwayStationDetail) _then;

/// Create a copy of SubwayStationDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? line = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SubwayStationDetail].
extension SubwayStationDetailPatterns on SubwayStationDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubwayStationDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubwayStationDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubwayStationDetail value)  $default,){
final _that = this;
switch (_that) {
case _SubwayStationDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubwayStationDetail value)?  $default,){
final _that = this;
switch (_that) {
case _SubwayStationDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int line, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubwayStationDetail() when $default != null:
return $default(_that.id,_that.line,_that.nameUz,_that.nameRu,_that.nameEn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int line, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn)  $default,) {final _that = this;
switch (_that) {
case _SubwayStationDetail():
return $default(_that.id,_that.line,_that.nameUz,_that.nameRu,_that.nameEn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int line, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn)?  $default,) {final _that = this;
switch (_that) {
case _SubwayStationDetail() when $default != null:
return $default(_that.id,_that.line,_that.nameUz,_that.nameRu,_that.nameEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubwayStationDetail implements SubwayStationDetail {
  const _SubwayStationDetail({required this.id, required this.line, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_en") this.nameEn});
  factory _SubwayStationDetail.fromJson(Map<String, dynamic> json) => _$SubwayStationDetailFromJson(json);

@override final  int id;
@override final  int line;
@override@JsonKey(name: "name_uz") final  String? nameUz;
@override@JsonKey(name: "name_ru") final  String? nameRu;
@override@JsonKey(name: "name_en") final  String? nameEn;

/// Create a copy of SubwayStationDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubwayStationDetailCopyWith<_SubwayStationDetail> get copyWith => __$SubwayStationDetailCopyWithImpl<_SubwayStationDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubwayStationDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubwayStationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.line, line) || other.line == line)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,line,nameUz,nameRu,nameEn);

@override
String toString() {
  return 'SubwayStationDetail(id: $id, line: $line, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn)';
}


}

/// @nodoc
abstract mixin class _$SubwayStationDetailCopyWith<$Res> implements $SubwayStationDetailCopyWith<$Res> {
  factory _$SubwayStationDetailCopyWith(_SubwayStationDetail value, $Res Function(_SubwayStationDetail) _then) = __$SubwayStationDetailCopyWithImpl;
@override @useResult
$Res call({
 int id, int line,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn
});




}
/// @nodoc
class __$SubwayStationDetailCopyWithImpl<$Res>
    implements _$SubwayStationDetailCopyWith<$Res> {
  __$SubwayStationDetailCopyWithImpl(this._self, this._then);

  final _SubwayStationDetail _self;
  final $Res Function(_SubwayStationDetail) _then;

/// Create a copy of SubwayStationDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? line = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,}) {
  return _then(_SubwayStationDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LocationDetail {

 int get id;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_en") String? get nameEn;@JsonKey(name: "short_name_uz") String? get shortNameUz;@JsonKey(name: "short_name_ru") String? get shortNameRu;@JsonKey(name: "short_name_en") String? get shortNameEn;
/// Create a copy of LocationDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationDetailCopyWith<LocationDetail> get copyWith => _$LocationDetailCopyWithImpl<LocationDetail>(this as LocationDetail, _$identity);

  /// Serializes this LocationDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,shortNameUz,shortNameRu,shortNameEn);

@override
String toString() {
  return 'LocationDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn)';
}


}

/// @nodoc
abstract mixin class $LocationDetailCopyWith<$Res>  {
  factory $LocationDetailCopyWith(LocationDetail value, $Res Function(LocationDetail) _then) = _$LocationDetailCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_en") String? shortNameEn
});




}
/// @nodoc
class _$LocationDetailCopyWithImpl<$Res>
    implements $LocationDetailCopyWith<$Res> {
  _$LocationDetailCopyWithImpl(this._self, this._then);

  final LocationDetail _self;
  final $Res Function(LocationDetail) _then;

/// Create a copy of LocationDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? shortNameUz = freezed,Object? shortNameRu = freezed,Object? shortNameEn = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationDetail].
extension LocationDetailPatterns on LocationDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationDetail value)  $default,){
final _that = this;
switch (_that) {
case _LocationDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationDetail value)?  $default,){
final _that = this;
switch (_that) {
case _LocationDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationDetail() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn)  $default,) {final _that = this;
switch (_that) {
case _LocationDetail():
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn)?  $default,) {final _that = this;
switch (_that) {
case _LocationDetail() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationDetail implements LocationDetail {
  const _LocationDetail({required this.id, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_en") this.nameEn, @JsonKey(name: "short_name_uz") this.shortNameUz, @JsonKey(name: "short_name_ru") this.shortNameRu, @JsonKey(name: "short_name_en") this.shortNameEn});
  factory _LocationDetail.fromJson(Map<String, dynamic> json) => _$LocationDetailFromJson(json);

@override final  int id;
@override@JsonKey(name: "name_uz") final  String? nameUz;
@override@JsonKey(name: "name_ru") final  String? nameRu;
@override@JsonKey(name: "name_en") final  String? nameEn;
@override@JsonKey(name: "short_name_uz") final  String? shortNameUz;
@override@JsonKey(name: "short_name_ru") final  String? shortNameRu;
@override@JsonKey(name: "short_name_en") final  String? shortNameEn;

/// Create a copy of LocationDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationDetailCopyWith<_LocationDetail> get copyWith => __$LocationDetailCopyWithImpl<_LocationDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,shortNameUz,shortNameRu,shortNameEn);

@override
String toString() {
  return 'LocationDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn)';
}


}

/// @nodoc
abstract mixin class _$LocationDetailCopyWith<$Res> implements $LocationDetailCopyWith<$Res> {
  factory _$LocationDetailCopyWith(_LocationDetail value, $Res Function(_LocationDetail) _then) = __$LocationDetailCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_en") String? shortNameEn
});




}
/// @nodoc
class __$LocationDetailCopyWithImpl<$Res>
    implements _$LocationDetailCopyWith<$Res> {
  __$LocationDetailCopyWithImpl(this._self, this._then);

  final _LocationDetail _self;
  final $Res Function(_LocationDetail) _then;

/// Create a copy of LocationDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? shortNameUz = freezed,Object? shortNameRu = freezed,Object? shortNameEn = freezed,}) {
  return _then(_LocationDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ListingTypeDetail {

 int get id; String get code;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_en") String? get nameEn;
/// Create a copy of ListingTypeDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingTypeDetailCopyWith<ListingTypeDetail> get copyWith => _$ListingTypeDetailCopyWithImpl<ListingTypeDetail>(this as ListingTypeDetail, _$identity);

  /// Serializes this ListingTypeDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingTypeDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,nameUz,nameRu,nameEn);

@override
String toString() {
  return 'ListingTypeDetail(id: $id, code: $code, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn)';
}


}

/// @nodoc
abstract mixin class $ListingTypeDetailCopyWith<$Res>  {
  factory $ListingTypeDetailCopyWith(ListingTypeDetail value, $Res Function(ListingTypeDetail) _then) = _$ListingTypeDetailCopyWithImpl;
@useResult
$Res call({
 int id, String code,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn
});




}
/// @nodoc
class _$ListingTypeDetailCopyWithImpl<$Res>
    implements $ListingTypeDetailCopyWith<$Res> {
  _$ListingTypeDetailCopyWithImpl(this._self, this._then);

  final ListingTypeDetail _self;
  final $Res Function(ListingTypeDetail) _then;

/// Create a copy of ListingTypeDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingTypeDetail].
extension ListingTypeDetailPatterns on ListingTypeDetail {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingTypeDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingTypeDetail() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingTypeDetail value)  $default,){
final _that = this;
switch (_that) {
case _ListingTypeDetail():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingTypeDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ListingTypeDetail() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String code, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingTypeDetail() when $default != null:
return $default(_that.id,_that.code,_that.nameUz,_that.nameRu,_that.nameEn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String code, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn)  $default,) {final _that = this;
switch (_that) {
case _ListingTypeDetail():
return $default(_that.id,_that.code,_that.nameUz,_that.nameRu,_that.nameEn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String code, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn)?  $default,) {final _that = this;
switch (_that) {
case _ListingTypeDetail() when $default != null:
return $default(_that.id,_that.code,_that.nameUz,_that.nameRu,_that.nameEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingTypeDetail implements ListingTypeDetail {
  const _ListingTypeDetail({required this.id, required this.code, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_en") this.nameEn});
  factory _ListingTypeDetail.fromJson(Map<String, dynamic> json) => _$ListingTypeDetailFromJson(json);

@override final  int id;
@override final  String code;
@override@JsonKey(name: "name_uz") final  String? nameUz;
@override@JsonKey(name: "name_ru") final  String? nameRu;
@override@JsonKey(name: "name_en") final  String? nameEn;

/// Create a copy of ListingTypeDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingTypeDetailCopyWith<_ListingTypeDetail> get copyWith => __$ListingTypeDetailCopyWithImpl<_ListingTypeDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingTypeDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingTypeDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,nameUz,nameRu,nameEn);

@override
String toString() {
  return 'ListingTypeDetail(id: $id, code: $code, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn)';
}


}

/// @nodoc
abstract mixin class _$ListingTypeDetailCopyWith<$Res> implements $ListingTypeDetailCopyWith<$Res> {
  factory _$ListingTypeDetailCopyWith(_ListingTypeDetail value, $Res Function(_ListingTypeDetail) _then) = __$ListingTypeDetailCopyWithImpl;
@override @useResult
$Res call({
 int id, String code,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn
});




}
/// @nodoc
class __$ListingTypeDetailCopyWithImpl<$Res>
    implements _$ListingTypeDetailCopyWith<$Res> {
  __$ListingTypeDetailCopyWithImpl(this._self, this._then);

  final _ListingTypeDetail _self;
  final $Res Function(_ListingTypeDetail) _then;

/// Create a copy of ListingTypeDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,}) {
  return _then(_ListingTypeDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
