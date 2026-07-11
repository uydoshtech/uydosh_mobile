// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingDetail {

 int get id;@JsonKey(name: "user_id") int get userId; String get title;@JsonKey(name: "listing_type_id") int get listingTypeId;@JsonKey(name: "price") int get price;@JsonKey(name: "min_price") int? get minPrice;@JsonKey(name: "max_price") int? get maxPrice;@JsonKey(name: "is_active") bool get isActive;@JsonKey(name: "created_at") String get createdAt;@JsonKey(name: "updated_at") String get updatedAt; UserDetail get user;@JsonKey(name: "listing_type") ListingTypeDetail get listingType; String? get description;@JsonKey(name: "city_id") int? get cityId;@JsonKey(name: "description_ru") String? get descriptionRu;@JsonKey(name: "description_en") String? get descriptionEn;@JsonKey(name: "description_uz") String? get descriptionUz;@JsonKey(name: "subway_station_id") int? get subwayStationId;@JsonKey(name: "subway_line_id") int? get subwayLineId;@JsonKey(name: "location_id") int? get locationId; int? get gender;@JsonKey(name: "featured_at") String? get featuredAt;@JsonKey(name: "move_in_date") String? get moveInDate;@JsonKey(name: "private_room") bool? get privateRoom;@JsonKey(name: "host_resident") bool? get hostResident;@JsonKey(name: "point_cloud_url") String? get pointCloudUrl;@JsonKey(name: "room_scan_glb_url") String? get roomScanGlbUrl;@JsonKey(name: "room_scan_floor_long_m") double? get roomScanFloorLongM;@JsonKey(name: "room_scan_floor_short_m") double? get roomScanFloorShortM;@JsonKey(name: "room_scan_height_m") double? get roomScanHeightM;@JsonKey(name: "room_scan_floor_area_m2") double? get roomScanFloorAreaM2;@JsonKey(name: "room_scan_world_plus_x_bearing_deg") double? get roomScanWorldPlusXBearingDeg;@JsonKey(name: "room_scan_north_correction_deg") double? get roomScanNorthCorrectionDeg;@JsonKey(name: "contact_phone") String? get contactPhone;@JsonKey(name: "contact_telegram") String? get contactTelegram;@JsonKey(name: "address_latitude", fromJson: numericStringToDouble) double? get addressLatitude;@JsonKey(name: "address_longitude", fromJson: numericStringToDouble) double? get addressLongitude;@JsonKey(name: "subway_station") SubwayStationDetail? get subwayStation;@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? get searchSubwayStations; LocationDetail? get location;@JsonKey(name: "search_locations") List<LocationDetail>? get searchLocations; List<Amenity>? get amenities; List<Photo>? get photos;@JsonKey(name: "area_price_stats") AreaPriceStats? get areaPriceStats;@JsonKey(name: "nearby_stores") List<ListingNearbyStore>? get nearbyStores;@JsonKey(name: "group_size_target") int? get groupSizeTarget;@JsonKey(name: "group_forming_status") String? get groupFormingStatus;@JsonKey(name: "group_compatibility_report") String? get groupCompatibilityReport;@JsonKey(includeFromJson: false, includeToJson: false) ListingGroupContext? get groupContext;
/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingDetailCopyWith<ListingDetail> get copyWith => _$ListingDetailCopyWithImpl<ListingDetail>(this as ListingDetail, _$identity);

  /// Serializes this ListingDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.listingTypeId, listingTypeId) || other.listingTypeId == listingTypeId)&&(identical(other.price, price) || other.price == price)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.listingType, listingType) || other.listingType == listingType)&&(identical(other.description, description) || other.description == description)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.descriptionRu, descriptionRu) || other.descriptionRu == descriptionRu)&&(identical(other.descriptionEn, descriptionEn) || other.descriptionEn == descriptionEn)&&(identical(other.descriptionUz, descriptionUz) || other.descriptionUz == descriptionUz)&&(identical(other.subwayStationId, subwayStationId) || other.subwayStationId == subwayStationId)&&(identical(other.subwayLineId, subwayLineId) || other.subwayLineId == subwayLineId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.featuredAt, featuredAt) || other.featuredAt == featuredAt)&&(identical(other.moveInDate, moveInDate) || other.moveInDate == moveInDate)&&(identical(other.privateRoom, privateRoom) || other.privateRoom == privateRoom)&&(identical(other.hostResident, hostResident) || other.hostResident == hostResident)&&(identical(other.pointCloudUrl, pointCloudUrl) || other.pointCloudUrl == pointCloudUrl)&&(identical(other.roomScanGlbUrl, roomScanGlbUrl) || other.roomScanGlbUrl == roomScanGlbUrl)&&(identical(other.roomScanFloorLongM, roomScanFloorLongM) || other.roomScanFloorLongM == roomScanFloorLongM)&&(identical(other.roomScanFloorShortM, roomScanFloorShortM) || other.roomScanFloorShortM == roomScanFloorShortM)&&(identical(other.roomScanHeightM, roomScanHeightM) || other.roomScanHeightM == roomScanHeightM)&&(identical(other.roomScanFloorAreaM2, roomScanFloorAreaM2) || other.roomScanFloorAreaM2 == roomScanFloorAreaM2)&&(identical(other.roomScanWorldPlusXBearingDeg, roomScanWorldPlusXBearingDeg) || other.roomScanWorldPlusXBearingDeg == roomScanWorldPlusXBearingDeg)&&(identical(other.roomScanNorthCorrectionDeg, roomScanNorthCorrectionDeg) || other.roomScanNorthCorrectionDeg == roomScanNorthCorrectionDeg)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.contactTelegram, contactTelegram) || other.contactTelegram == contactTelegram)&&(identical(other.addressLatitude, addressLatitude) || other.addressLatitude == addressLatitude)&&(identical(other.addressLongitude, addressLongitude) || other.addressLongitude == addressLongitude)&&(identical(other.subwayStation, subwayStation) || other.subwayStation == subwayStation)&&const DeepCollectionEquality().equals(other.searchSubwayStations, searchSubwayStations)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.searchLocations, searchLocations)&&const DeepCollectionEquality().equals(other.amenities, amenities)&&const DeepCollectionEquality().equals(other.photos, photos)&&(identical(other.areaPriceStats, areaPriceStats) || other.areaPriceStats == areaPriceStats)&&const DeepCollectionEquality().equals(other.nearbyStores, nearbyStores)&&(identical(other.groupSizeTarget, groupSizeTarget) || other.groupSizeTarget == groupSizeTarget)&&(identical(other.groupFormingStatus, groupFormingStatus) || other.groupFormingStatus == groupFormingStatus)&&(identical(other.groupCompatibilityReport, groupCompatibilityReport) || other.groupCompatibilityReport == groupCompatibilityReport)&&(identical(other.groupContext, groupContext) || other.groupContext == groupContext));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,title,listingTypeId,price,minPrice,maxPrice,isActive,createdAt,updatedAt,user,listingType,description,cityId,descriptionRu,descriptionEn,descriptionUz,subwayStationId,subwayLineId,locationId,gender,featuredAt,moveInDate,privateRoom,hostResident,pointCloudUrl,roomScanGlbUrl,roomScanFloorLongM,roomScanFloorShortM,roomScanHeightM,roomScanFloorAreaM2,roomScanWorldPlusXBearingDeg,roomScanNorthCorrectionDeg,contactPhone,contactTelegram,addressLatitude,addressLongitude,subwayStation,const DeepCollectionEquality().hash(searchSubwayStations),location,const DeepCollectionEquality().hash(searchLocations),const DeepCollectionEquality().hash(amenities),const DeepCollectionEquality().hash(photos),areaPriceStats,const DeepCollectionEquality().hash(nearbyStores),groupSizeTarget,groupFormingStatus,groupCompatibilityReport,groupContext]);

@override
String toString() {
  return 'ListingDetail(id: $id, userId: $userId, title: $title, listingTypeId: $listingTypeId, price: $price, minPrice: $minPrice, maxPrice: $maxPrice, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, user: $user, listingType: $listingType, description: $description, cityId: $cityId, descriptionRu: $descriptionRu, descriptionEn: $descriptionEn, descriptionUz: $descriptionUz, subwayStationId: $subwayStationId, subwayLineId: $subwayLineId, locationId: $locationId, gender: $gender, featuredAt: $featuredAt, moveInDate: $moveInDate, privateRoom: $privateRoom, hostResident: $hostResident, pointCloudUrl: $pointCloudUrl, roomScanGlbUrl: $roomScanGlbUrl, roomScanFloorLongM: $roomScanFloorLongM, roomScanFloorShortM: $roomScanFloorShortM, roomScanHeightM: $roomScanHeightM, roomScanFloorAreaM2: $roomScanFloorAreaM2, roomScanWorldPlusXBearingDeg: $roomScanWorldPlusXBearingDeg, roomScanNorthCorrectionDeg: $roomScanNorthCorrectionDeg, contactPhone: $contactPhone, contactTelegram: $contactTelegram, addressLatitude: $addressLatitude, addressLongitude: $addressLongitude, subwayStation: $subwayStation, searchSubwayStations: $searchSubwayStations, location: $location, searchLocations: $searchLocations, amenities: $amenities, photos: $photos, areaPriceStats: $areaPriceStats, nearbyStores: $nearbyStores, groupSizeTarget: $groupSizeTarget, groupFormingStatus: $groupFormingStatus, groupCompatibilityReport: $groupCompatibilityReport, groupContext: $groupContext)';
}


}

/// @nodoc
abstract mixin class $ListingDetailCopyWith<$Res>  {
  factory $ListingDetailCopyWith(ListingDetail value, $Res Function(ListingDetail) _then) = _$ListingDetailCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "user_id") int userId, String title,@JsonKey(name: "listing_type_id") int listingTypeId,@JsonKey(name: "price") int price,@JsonKey(name: "min_price") int? minPrice,@JsonKey(name: "max_price") int? maxPrice,@JsonKey(name: "is_active") bool isActive,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt, UserDetail user,@JsonKey(name: "listing_type") ListingTypeDetail listingType, String? description,@JsonKey(name: "city_id") int? cityId,@JsonKey(name: "description_ru") String? descriptionRu,@JsonKey(name: "description_en") String? descriptionEn,@JsonKey(name: "description_uz") String? descriptionUz,@JsonKey(name: "subway_station_id") int? subwayStationId,@JsonKey(name: "subway_line_id") int? subwayLineId,@JsonKey(name: "location_id") int? locationId, int? gender,@JsonKey(name: "featured_at") String? featuredAt,@JsonKey(name: "move_in_date") String? moveInDate,@JsonKey(name: "private_room") bool? privateRoom,@JsonKey(name: "host_resident") bool? hostResident,@JsonKey(name: "point_cloud_url") String? pointCloudUrl,@JsonKey(name: "room_scan_glb_url") String? roomScanGlbUrl,@JsonKey(name: "room_scan_floor_long_m") double? roomScanFloorLongM,@JsonKey(name: "room_scan_floor_short_m") double? roomScanFloorShortM,@JsonKey(name: "room_scan_height_m") double? roomScanHeightM,@JsonKey(name: "room_scan_floor_area_m2") double? roomScanFloorAreaM2,@JsonKey(name: "room_scan_world_plus_x_bearing_deg") double? roomScanWorldPlusXBearingDeg,@JsonKey(name: "room_scan_north_correction_deg") double? roomScanNorthCorrectionDeg,@JsonKey(name: "contact_phone") String? contactPhone,@JsonKey(name: "contact_telegram") String? contactTelegram,@JsonKey(name: "address_latitude", fromJson: numericStringToDouble) double? addressLatitude,@JsonKey(name: "address_longitude", fromJson: numericStringToDouble) double? addressLongitude,@JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? searchSubwayStations, LocationDetail? location,@JsonKey(name: "search_locations") List<LocationDetail>? searchLocations, List<Amenity>? amenities, List<Photo>? photos,@JsonKey(name: "area_price_stats") AreaPriceStats? areaPriceStats,@JsonKey(name: "nearby_stores") List<ListingNearbyStore>? nearbyStores,@JsonKey(name: "group_size_target") int? groupSizeTarget,@JsonKey(name: "group_forming_status") String? groupFormingStatus,@JsonKey(name: "group_compatibility_report") String? groupCompatibilityReport,@JsonKey(includeFromJson: false, includeToJson: false) ListingGroupContext? groupContext
});


$UserDetailCopyWith<$Res> get user;$ListingTypeDetailCopyWith<$Res> get listingType;$SubwayStationDetailCopyWith<$Res>? get subwayStation;$LocationDetailCopyWith<$Res>? get location;$AreaPriceStatsCopyWith<$Res>? get areaPriceStats;

}
/// @nodoc
class _$ListingDetailCopyWithImpl<$Res>
    implements $ListingDetailCopyWith<$Res> {
  _$ListingDetailCopyWithImpl(this._self, this._then);

  final ListingDetail _self;
  final $Res Function(ListingDetail) _then;

/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? listingTypeId = null,Object? price = null,Object? minPrice = freezed,Object? maxPrice = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? user = null,Object? listingType = null,Object? description = freezed,Object? cityId = freezed,Object? descriptionRu = freezed,Object? descriptionEn = freezed,Object? descriptionUz = freezed,Object? subwayStationId = freezed,Object? subwayLineId = freezed,Object? locationId = freezed,Object? gender = freezed,Object? featuredAt = freezed,Object? moveInDate = freezed,Object? privateRoom = freezed,Object? hostResident = freezed,Object? pointCloudUrl = freezed,Object? roomScanGlbUrl = freezed,Object? roomScanFloorLongM = freezed,Object? roomScanFloorShortM = freezed,Object? roomScanHeightM = freezed,Object? roomScanFloorAreaM2 = freezed,Object? roomScanWorldPlusXBearingDeg = freezed,Object? roomScanNorthCorrectionDeg = freezed,Object? contactPhone = freezed,Object? contactTelegram = freezed,Object? addressLatitude = freezed,Object? addressLongitude = freezed,Object? subwayStation = freezed,Object? searchSubwayStations = freezed,Object? location = freezed,Object? searchLocations = freezed,Object? amenities = freezed,Object? photos = freezed,Object? areaPriceStats = freezed,Object? nearbyStores = freezed,Object? groupSizeTarget = freezed,Object? groupFormingStatus = freezed,Object? groupCompatibilityReport = freezed,Object? groupContext = freezed,}) {
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
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDetail,listingType: null == listingType ? _self.listingType : listingType // ignore: cast_nullable_to_non_nullable
as ListingTypeDetail,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,descriptionRu: freezed == descriptionRu ? _self.descriptionRu : descriptionRu // ignore: cast_nullable_to_non_nullable
as String?,descriptionEn: freezed == descriptionEn ? _self.descriptionEn : descriptionEn // ignore: cast_nullable_to_non_nullable
as String?,descriptionUz: freezed == descriptionUz ? _self.descriptionUz : descriptionUz // ignore: cast_nullable_to_non_nullable
as String?,subwayStationId: freezed == subwayStationId ? _self.subwayStationId : subwayStationId // ignore: cast_nullable_to_non_nullable
as int?,subwayLineId: freezed == subwayLineId ? _self.subwayLineId : subwayLineId // ignore: cast_nullable_to_non_nullable
as int?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,featuredAt: freezed == featuredAt ? _self.featuredAt : featuredAt // ignore: cast_nullable_to_non_nullable
as String?,moveInDate: freezed == moveInDate ? _self.moveInDate : moveInDate // ignore: cast_nullable_to_non_nullable
as String?,privateRoom: freezed == privateRoom ? _self.privateRoom : privateRoom // ignore: cast_nullable_to_non_nullable
as bool?,hostResident: freezed == hostResident ? _self.hostResident : hostResident // ignore: cast_nullable_to_non_nullable
as bool?,pointCloudUrl: freezed == pointCloudUrl ? _self.pointCloudUrl : pointCloudUrl // ignore: cast_nullable_to_non_nullable
as String?,roomScanGlbUrl: freezed == roomScanGlbUrl ? _self.roomScanGlbUrl : roomScanGlbUrl // ignore: cast_nullable_to_non_nullable
as String?,roomScanFloorLongM: freezed == roomScanFloorLongM ? _self.roomScanFloorLongM : roomScanFloorLongM // ignore: cast_nullable_to_non_nullable
as double?,roomScanFloorShortM: freezed == roomScanFloorShortM ? _self.roomScanFloorShortM : roomScanFloorShortM // ignore: cast_nullable_to_non_nullable
as double?,roomScanHeightM: freezed == roomScanHeightM ? _self.roomScanHeightM : roomScanHeightM // ignore: cast_nullable_to_non_nullable
as double?,roomScanFloorAreaM2: freezed == roomScanFloorAreaM2 ? _self.roomScanFloorAreaM2 : roomScanFloorAreaM2 // ignore: cast_nullable_to_non_nullable
as double?,roomScanWorldPlusXBearingDeg: freezed == roomScanWorldPlusXBearingDeg ? _self.roomScanWorldPlusXBearingDeg : roomScanWorldPlusXBearingDeg // ignore: cast_nullable_to_non_nullable
as double?,roomScanNorthCorrectionDeg: freezed == roomScanNorthCorrectionDeg ? _self.roomScanNorthCorrectionDeg : roomScanNorthCorrectionDeg // ignore: cast_nullable_to_non_nullable
as double?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,contactTelegram: freezed == contactTelegram ? _self.contactTelegram : contactTelegram // ignore: cast_nullable_to_non_nullable
as String?,addressLatitude: freezed == addressLatitude ? _self.addressLatitude : addressLatitude // ignore: cast_nullable_to_non_nullable
as double?,addressLongitude: freezed == addressLongitude ? _self.addressLongitude : addressLongitude // ignore: cast_nullable_to_non_nullable
as double?,subwayStation: freezed == subwayStation ? _self.subwayStation : subwayStation // ignore: cast_nullable_to_non_nullable
as SubwayStationDetail?,searchSubwayStations: freezed == searchSubwayStations ? _self.searchSubwayStations : searchSubwayStations // ignore: cast_nullable_to_non_nullable
as List<SubwayStationDetail>?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationDetail?,searchLocations: freezed == searchLocations ? _self.searchLocations : searchLocations // ignore: cast_nullable_to_non_nullable
as List<LocationDetail>?,amenities: freezed == amenities ? _self.amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<Amenity>?,photos: freezed == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<Photo>?,areaPriceStats: freezed == areaPriceStats ? _self.areaPriceStats : areaPriceStats // ignore: cast_nullable_to_non_nullable
as AreaPriceStats?,nearbyStores: freezed == nearbyStores ? _self.nearbyStores : nearbyStores // ignore: cast_nullable_to_non_nullable
as List<ListingNearbyStore>?,groupSizeTarget: freezed == groupSizeTarget ? _self.groupSizeTarget : groupSizeTarget // ignore: cast_nullable_to_non_nullable
as int?,groupFormingStatus: freezed == groupFormingStatus ? _self.groupFormingStatus : groupFormingStatus // ignore: cast_nullable_to_non_nullable
as String?,groupCompatibilityReport: freezed == groupCompatibilityReport ? _self.groupCompatibilityReport : groupCompatibilityReport // ignore: cast_nullable_to_non_nullable
as String?,groupContext: freezed == groupContext ? _self.groupContext : groupContext // ignore: cast_nullable_to_non_nullable
as ListingGroupContext?,
  ));
}
/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDetailCopyWith<$Res> get user {
  
  return $UserDetailCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingTypeDetailCopyWith<$Res> get listingType {
  
  return $ListingTypeDetailCopyWith<$Res>(_self.listingType, (value) {
    return _then(_self.copyWith(listingType: value));
  });
}/// Create a copy of ListingDetail
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
}/// Create a copy of ListingDetail
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
}/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AreaPriceStatsCopyWith<$Res>? get areaPriceStats {
    if (_self.areaPriceStats == null) {
    return null;
  }

  return $AreaPriceStatsCopyWith<$Res>(_self.areaPriceStats!, (value) {
    return _then(_self.copyWith(areaPriceStats: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListingDetail].
extension ListingDetailPatterns on ListingDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingDetail value)  $default,){
final _that = this;
switch (_that) {
case _ListingDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingDetail value)?  $default,){
final _that = this;
switch (_that) {
case _ListingDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "user_id")  int userId,  String title, @JsonKey(name: "listing_type_id")  int listingTypeId, @JsonKey(name: "price")  int price, @JsonKey(name: "min_price")  int? minPrice, @JsonKey(name: "max_price")  int? maxPrice, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt,  UserDetail user, @JsonKey(name: "listing_type")  ListingTypeDetail listingType,  String? description, @JsonKey(name: "city_id")  int? cityId, @JsonKey(name: "description_ru")  String? descriptionRu, @JsonKey(name: "description_en")  String? descriptionEn, @JsonKey(name: "description_uz")  String? descriptionUz, @JsonKey(name: "subway_station_id")  int? subwayStationId, @JsonKey(name: "subway_line_id")  int? subwayLineId, @JsonKey(name: "location_id")  int? locationId,  int? gender, @JsonKey(name: "featured_at")  String? featuredAt, @JsonKey(name: "move_in_date")  String? moveInDate, @JsonKey(name: "private_room")  bool? privateRoom, @JsonKey(name: "host_resident")  bool? hostResident, @JsonKey(name: "point_cloud_url")  String? pointCloudUrl, @JsonKey(name: "room_scan_glb_url")  String? roomScanGlbUrl, @JsonKey(name: "room_scan_floor_long_m")  double? roomScanFloorLongM, @JsonKey(name: "room_scan_floor_short_m")  double? roomScanFloorShortM, @JsonKey(name: "room_scan_height_m")  double? roomScanHeightM, @JsonKey(name: "room_scan_floor_area_m2")  double? roomScanFloorAreaM2, @JsonKey(name: "room_scan_world_plus_x_bearing_deg")  double? roomScanWorldPlusXBearingDeg, @JsonKey(name: "room_scan_north_correction_deg")  double? roomScanNorthCorrectionDeg, @JsonKey(name: "contact_phone")  String? contactPhone, @JsonKey(name: "contact_telegram")  String? contactTelegram, @JsonKey(name: "address_latitude", fromJson: numericStringToDouble)  double? addressLatitude, @JsonKey(name: "address_longitude", fromJson: numericStringToDouble)  double? addressLongitude, @JsonKey(name: "subway_station")  SubwayStationDetail? subwayStation, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations,  LocationDetail? location, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations,  List<Amenity>? amenities,  List<Photo>? photos, @JsonKey(name: "area_price_stats")  AreaPriceStats? areaPriceStats, @JsonKey(name: "nearby_stores")  List<ListingNearbyStore>? nearbyStores, @JsonKey(name: "group_size_target")  int? groupSizeTarget, @JsonKey(name: "group_forming_status")  String? groupFormingStatus, @JsonKey(name: "group_compatibility_report")  String? groupCompatibilityReport, @JsonKey(includeFromJson: false, includeToJson: false)  ListingGroupContext? groupContext)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingDetail() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.listingTypeId,_that.price,_that.minPrice,_that.maxPrice,_that.isActive,_that.createdAt,_that.updatedAt,_that.user,_that.listingType,_that.description,_that.cityId,_that.descriptionRu,_that.descriptionEn,_that.descriptionUz,_that.subwayStationId,_that.subwayLineId,_that.locationId,_that.gender,_that.featuredAt,_that.moveInDate,_that.privateRoom,_that.hostResident,_that.pointCloudUrl,_that.roomScanGlbUrl,_that.roomScanFloorLongM,_that.roomScanFloorShortM,_that.roomScanHeightM,_that.roomScanFloorAreaM2,_that.roomScanWorldPlusXBearingDeg,_that.roomScanNorthCorrectionDeg,_that.contactPhone,_that.contactTelegram,_that.addressLatitude,_that.addressLongitude,_that.subwayStation,_that.searchSubwayStations,_that.location,_that.searchLocations,_that.amenities,_that.photos,_that.areaPriceStats,_that.nearbyStores,_that.groupSizeTarget,_that.groupFormingStatus,_that.groupCompatibilityReport,_that.groupContext);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "user_id")  int userId,  String title, @JsonKey(name: "listing_type_id")  int listingTypeId, @JsonKey(name: "price")  int price, @JsonKey(name: "min_price")  int? minPrice, @JsonKey(name: "max_price")  int? maxPrice, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt,  UserDetail user, @JsonKey(name: "listing_type")  ListingTypeDetail listingType,  String? description, @JsonKey(name: "city_id")  int? cityId, @JsonKey(name: "description_ru")  String? descriptionRu, @JsonKey(name: "description_en")  String? descriptionEn, @JsonKey(name: "description_uz")  String? descriptionUz, @JsonKey(name: "subway_station_id")  int? subwayStationId, @JsonKey(name: "subway_line_id")  int? subwayLineId, @JsonKey(name: "location_id")  int? locationId,  int? gender, @JsonKey(name: "featured_at")  String? featuredAt, @JsonKey(name: "move_in_date")  String? moveInDate, @JsonKey(name: "private_room")  bool? privateRoom, @JsonKey(name: "host_resident")  bool? hostResident, @JsonKey(name: "point_cloud_url")  String? pointCloudUrl, @JsonKey(name: "room_scan_glb_url")  String? roomScanGlbUrl, @JsonKey(name: "room_scan_floor_long_m")  double? roomScanFloorLongM, @JsonKey(name: "room_scan_floor_short_m")  double? roomScanFloorShortM, @JsonKey(name: "room_scan_height_m")  double? roomScanHeightM, @JsonKey(name: "room_scan_floor_area_m2")  double? roomScanFloorAreaM2, @JsonKey(name: "room_scan_world_plus_x_bearing_deg")  double? roomScanWorldPlusXBearingDeg, @JsonKey(name: "room_scan_north_correction_deg")  double? roomScanNorthCorrectionDeg, @JsonKey(name: "contact_phone")  String? contactPhone, @JsonKey(name: "contact_telegram")  String? contactTelegram, @JsonKey(name: "address_latitude", fromJson: numericStringToDouble)  double? addressLatitude, @JsonKey(name: "address_longitude", fromJson: numericStringToDouble)  double? addressLongitude, @JsonKey(name: "subway_station")  SubwayStationDetail? subwayStation, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations,  LocationDetail? location, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations,  List<Amenity>? amenities,  List<Photo>? photos, @JsonKey(name: "area_price_stats")  AreaPriceStats? areaPriceStats, @JsonKey(name: "nearby_stores")  List<ListingNearbyStore>? nearbyStores, @JsonKey(name: "group_size_target")  int? groupSizeTarget, @JsonKey(name: "group_forming_status")  String? groupFormingStatus, @JsonKey(name: "group_compatibility_report")  String? groupCompatibilityReport, @JsonKey(includeFromJson: false, includeToJson: false)  ListingGroupContext? groupContext)  $default,) {final _that = this;
switch (_that) {
case _ListingDetail():
return $default(_that.id,_that.userId,_that.title,_that.listingTypeId,_that.price,_that.minPrice,_that.maxPrice,_that.isActive,_that.createdAt,_that.updatedAt,_that.user,_that.listingType,_that.description,_that.cityId,_that.descriptionRu,_that.descriptionEn,_that.descriptionUz,_that.subwayStationId,_that.subwayLineId,_that.locationId,_that.gender,_that.featuredAt,_that.moveInDate,_that.privateRoom,_that.hostResident,_that.pointCloudUrl,_that.roomScanGlbUrl,_that.roomScanFloorLongM,_that.roomScanFloorShortM,_that.roomScanHeightM,_that.roomScanFloorAreaM2,_that.roomScanWorldPlusXBearingDeg,_that.roomScanNorthCorrectionDeg,_that.contactPhone,_that.contactTelegram,_that.addressLatitude,_that.addressLongitude,_that.subwayStation,_that.searchSubwayStations,_that.location,_that.searchLocations,_that.amenities,_that.photos,_that.areaPriceStats,_that.nearbyStores,_that.groupSizeTarget,_that.groupFormingStatus,_that.groupCompatibilityReport,_that.groupContext);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "user_id")  int userId,  String title, @JsonKey(name: "listing_type_id")  int listingTypeId, @JsonKey(name: "price")  int price, @JsonKey(name: "min_price")  int? minPrice, @JsonKey(name: "max_price")  int? maxPrice, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt,  UserDetail user, @JsonKey(name: "listing_type")  ListingTypeDetail listingType,  String? description, @JsonKey(name: "city_id")  int? cityId, @JsonKey(name: "description_ru")  String? descriptionRu, @JsonKey(name: "description_en")  String? descriptionEn, @JsonKey(name: "description_uz")  String? descriptionUz, @JsonKey(name: "subway_station_id")  int? subwayStationId, @JsonKey(name: "subway_line_id")  int? subwayLineId, @JsonKey(name: "location_id")  int? locationId,  int? gender, @JsonKey(name: "featured_at")  String? featuredAt, @JsonKey(name: "move_in_date")  String? moveInDate, @JsonKey(name: "private_room")  bool? privateRoom, @JsonKey(name: "host_resident")  bool? hostResident, @JsonKey(name: "point_cloud_url")  String? pointCloudUrl, @JsonKey(name: "room_scan_glb_url")  String? roomScanGlbUrl, @JsonKey(name: "room_scan_floor_long_m")  double? roomScanFloorLongM, @JsonKey(name: "room_scan_floor_short_m")  double? roomScanFloorShortM, @JsonKey(name: "room_scan_height_m")  double? roomScanHeightM, @JsonKey(name: "room_scan_floor_area_m2")  double? roomScanFloorAreaM2, @JsonKey(name: "room_scan_world_plus_x_bearing_deg")  double? roomScanWorldPlusXBearingDeg, @JsonKey(name: "room_scan_north_correction_deg")  double? roomScanNorthCorrectionDeg, @JsonKey(name: "contact_phone")  String? contactPhone, @JsonKey(name: "contact_telegram")  String? contactTelegram, @JsonKey(name: "address_latitude", fromJson: numericStringToDouble)  double? addressLatitude, @JsonKey(name: "address_longitude", fromJson: numericStringToDouble)  double? addressLongitude, @JsonKey(name: "subway_station")  SubwayStationDetail? subwayStation, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations,  LocationDetail? location, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations,  List<Amenity>? amenities,  List<Photo>? photos, @JsonKey(name: "area_price_stats")  AreaPriceStats? areaPriceStats, @JsonKey(name: "nearby_stores")  List<ListingNearbyStore>? nearbyStores, @JsonKey(name: "group_size_target")  int? groupSizeTarget, @JsonKey(name: "group_forming_status")  String? groupFormingStatus, @JsonKey(name: "group_compatibility_report")  String? groupCompatibilityReport, @JsonKey(includeFromJson: false, includeToJson: false)  ListingGroupContext? groupContext)?  $default,) {final _that = this;
switch (_that) {
case _ListingDetail() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.listingTypeId,_that.price,_that.minPrice,_that.maxPrice,_that.isActive,_that.createdAt,_that.updatedAt,_that.user,_that.listingType,_that.description,_that.cityId,_that.descriptionRu,_that.descriptionEn,_that.descriptionUz,_that.subwayStationId,_that.subwayLineId,_that.locationId,_that.gender,_that.featuredAt,_that.moveInDate,_that.privateRoom,_that.hostResident,_that.pointCloudUrl,_that.roomScanGlbUrl,_that.roomScanFloorLongM,_that.roomScanFloorShortM,_that.roomScanHeightM,_that.roomScanFloorAreaM2,_that.roomScanWorldPlusXBearingDeg,_that.roomScanNorthCorrectionDeg,_that.contactPhone,_that.contactTelegram,_that.addressLatitude,_that.addressLongitude,_that.subwayStation,_that.searchSubwayStations,_that.location,_that.searchLocations,_that.amenities,_that.photos,_that.areaPriceStats,_that.nearbyStores,_that.groupSizeTarget,_that.groupFormingStatus,_that.groupCompatibilityReport,_that.groupContext);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingDetail implements ListingDetail {
  const _ListingDetail({required this.id, @JsonKey(name: "user_id") required this.userId, required this.title, @JsonKey(name: "listing_type_id") required this.listingTypeId, @JsonKey(name: "price") required this.price, @JsonKey(name: "min_price") this.minPrice, @JsonKey(name: "max_price") this.maxPrice, @JsonKey(name: "is_active") required this.isActive, @JsonKey(name: "created_at") required this.createdAt, @JsonKey(name: "updated_at") required this.updatedAt, required this.user, @JsonKey(name: "listing_type") required this.listingType, this.description, @JsonKey(name: "city_id") this.cityId, @JsonKey(name: "description_ru") this.descriptionRu, @JsonKey(name: "description_en") this.descriptionEn, @JsonKey(name: "description_uz") this.descriptionUz, @JsonKey(name: "subway_station_id") this.subwayStationId, @JsonKey(name: "subway_line_id") this.subwayLineId, @JsonKey(name: "location_id") this.locationId, this.gender, @JsonKey(name: "featured_at") this.featuredAt, @JsonKey(name: "move_in_date") this.moveInDate, @JsonKey(name: "private_room") this.privateRoom, @JsonKey(name: "host_resident") this.hostResident, @JsonKey(name: "point_cloud_url") this.pointCloudUrl, @JsonKey(name: "room_scan_glb_url") this.roomScanGlbUrl, @JsonKey(name: "room_scan_floor_long_m") this.roomScanFloorLongM, @JsonKey(name: "room_scan_floor_short_m") this.roomScanFloorShortM, @JsonKey(name: "room_scan_height_m") this.roomScanHeightM, @JsonKey(name: "room_scan_floor_area_m2") this.roomScanFloorAreaM2, @JsonKey(name: "room_scan_world_plus_x_bearing_deg") this.roomScanWorldPlusXBearingDeg, @JsonKey(name: "room_scan_north_correction_deg") this.roomScanNorthCorrectionDeg, @JsonKey(name: "contact_phone") this.contactPhone, @JsonKey(name: "contact_telegram") this.contactTelegram, @JsonKey(name: "address_latitude", fromJson: numericStringToDouble) this.addressLatitude, @JsonKey(name: "address_longitude", fromJson: numericStringToDouble) this.addressLongitude, @JsonKey(name: "subway_station") this.subwayStation, @JsonKey(name: "search_subway_stations") final  List<SubwayStationDetail>? searchSubwayStations, this.location, @JsonKey(name: "search_locations") final  List<LocationDetail>? searchLocations, final  List<Amenity>? amenities, final  List<Photo>? photos, @JsonKey(name: "area_price_stats") this.areaPriceStats, @JsonKey(name: "nearby_stores") final  List<ListingNearbyStore>? nearbyStores, @JsonKey(name: "group_size_target") this.groupSizeTarget, @JsonKey(name: "group_forming_status") this.groupFormingStatus, @JsonKey(name: "group_compatibility_report") this.groupCompatibilityReport, @JsonKey(includeFromJson: false, includeToJson: false) this.groupContext}): _searchSubwayStations = searchSubwayStations,_searchLocations = searchLocations,_amenities = amenities,_photos = photos,_nearbyStores = nearbyStores;
  factory _ListingDetail.fromJson(Map<String, dynamic> json) => _$ListingDetailFromJson(json);

@override final  int id;
@override@JsonKey(name: "user_id") final  int userId;
@override final  String title;
@override@JsonKey(name: "listing_type_id") final  int listingTypeId;
@override@JsonKey(name: "price") final  int price;
@override@JsonKey(name: "min_price") final  int? minPrice;
@override@JsonKey(name: "max_price") final  int? maxPrice;
@override@JsonKey(name: "is_active") final  bool isActive;
@override@JsonKey(name: "created_at") final  String createdAt;
@override@JsonKey(name: "updated_at") final  String updatedAt;
@override final  UserDetail user;
@override@JsonKey(name: "listing_type") final  ListingTypeDetail listingType;
@override final  String? description;
@override@JsonKey(name: "city_id") final  int? cityId;
@override@JsonKey(name: "description_ru") final  String? descriptionRu;
@override@JsonKey(name: "description_en") final  String? descriptionEn;
@override@JsonKey(name: "description_uz") final  String? descriptionUz;
@override@JsonKey(name: "subway_station_id") final  int? subwayStationId;
@override@JsonKey(name: "subway_line_id") final  int? subwayLineId;
@override@JsonKey(name: "location_id") final  int? locationId;
@override final  int? gender;
@override@JsonKey(name: "featured_at") final  String? featuredAt;
@override@JsonKey(name: "move_in_date") final  String? moveInDate;
@override@JsonKey(name: "private_room") final  bool? privateRoom;
@override@JsonKey(name: "host_resident") final  bool? hostResident;
@override@JsonKey(name: "point_cloud_url") final  String? pointCloudUrl;
@override@JsonKey(name: "room_scan_glb_url") final  String? roomScanGlbUrl;
@override@JsonKey(name: "room_scan_floor_long_m") final  double? roomScanFloorLongM;
@override@JsonKey(name: "room_scan_floor_short_m") final  double? roomScanFloorShortM;
@override@JsonKey(name: "room_scan_height_m") final  double? roomScanHeightM;
@override@JsonKey(name: "room_scan_floor_area_m2") final  double? roomScanFloorAreaM2;
@override@JsonKey(name: "room_scan_world_plus_x_bearing_deg") final  double? roomScanWorldPlusXBearingDeg;
@override@JsonKey(name: "room_scan_north_correction_deg") final  double? roomScanNorthCorrectionDeg;
@override@JsonKey(name: "contact_phone") final  String? contactPhone;
@override@JsonKey(name: "contact_telegram") final  String? contactTelegram;
@override@JsonKey(name: "address_latitude", fromJson: numericStringToDouble) final  double? addressLatitude;
@override@JsonKey(name: "address_longitude", fromJson: numericStringToDouble) final  double? addressLongitude;
@override@JsonKey(name: "subway_station") final  SubwayStationDetail? subwayStation;
 final  List<SubwayStationDetail>? _searchSubwayStations;
@override@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? get searchSubwayStations {
  final value = _searchSubwayStations;
  if (value == null) return null;
  if (_searchSubwayStations is EqualUnmodifiableListView) return _searchSubwayStations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  LocationDetail? location;
 final  List<LocationDetail>? _searchLocations;
@override@JsonKey(name: "search_locations") List<LocationDetail>? get searchLocations {
  final value = _searchLocations;
  if (value == null) return null;
  if (_searchLocations is EqualUnmodifiableListView) return _searchLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Amenity>? _amenities;
@override List<Amenity>? get amenities {
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

@override@JsonKey(name: "area_price_stats") final  AreaPriceStats? areaPriceStats;
 final  List<ListingNearbyStore>? _nearbyStores;
@override@JsonKey(name: "nearby_stores") List<ListingNearbyStore>? get nearbyStores {
  final value = _nearbyStores;
  if (value == null) return null;
  if (_nearbyStores is EqualUnmodifiableListView) return _nearbyStores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: "group_size_target") final  int? groupSizeTarget;
@override@JsonKey(name: "group_forming_status") final  String? groupFormingStatus;
@override@JsonKey(name: "group_compatibility_report") final  String? groupCompatibilityReport;
@override@JsonKey(includeFromJson: false, includeToJson: false) final  ListingGroupContext? groupContext;

/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingDetailCopyWith<_ListingDetail> get copyWith => __$ListingDetailCopyWithImpl<_ListingDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.listingTypeId, listingTypeId) || other.listingTypeId == listingTypeId)&&(identical(other.price, price) || other.price == price)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.listingType, listingType) || other.listingType == listingType)&&(identical(other.description, description) || other.description == description)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.descriptionRu, descriptionRu) || other.descriptionRu == descriptionRu)&&(identical(other.descriptionEn, descriptionEn) || other.descriptionEn == descriptionEn)&&(identical(other.descriptionUz, descriptionUz) || other.descriptionUz == descriptionUz)&&(identical(other.subwayStationId, subwayStationId) || other.subwayStationId == subwayStationId)&&(identical(other.subwayLineId, subwayLineId) || other.subwayLineId == subwayLineId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.featuredAt, featuredAt) || other.featuredAt == featuredAt)&&(identical(other.moveInDate, moveInDate) || other.moveInDate == moveInDate)&&(identical(other.privateRoom, privateRoom) || other.privateRoom == privateRoom)&&(identical(other.hostResident, hostResident) || other.hostResident == hostResident)&&(identical(other.pointCloudUrl, pointCloudUrl) || other.pointCloudUrl == pointCloudUrl)&&(identical(other.roomScanGlbUrl, roomScanGlbUrl) || other.roomScanGlbUrl == roomScanGlbUrl)&&(identical(other.roomScanFloorLongM, roomScanFloorLongM) || other.roomScanFloorLongM == roomScanFloorLongM)&&(identical(other.roomScanFloorShortM, roomScanFloorShortM) || other.roomScanFloorShortM == roomScanFloorShortM)&&(identical(other.roomScanHeightM, roomScanHeightM) || other.roomScanHeightM == roomScanHeightM)&&(identical(other.roomScanFloorAreaM2, roomScanFloorAreaM2) || other.roomScanFloorAreaM2 == roomScanFloorAreaM2)&&(identical(other.roomScanWorldPlusXBearingDeg, roomScanWorldPlusXBearingDeg) || other.roomScanWorldPlusXBearingDeg == roomScanWorldPlusXBearingDeg)&&(identical(other.roomScanNorthCorrectionDeg, roomScanNorthCorrectionDeg) || other.roomScanNorthCorrectionDeg == roomScanNorthCorrectionDeg)&&(identical(other.contactPhone, contactPhone) || other.contactPhone == contactPhone)&&(identical(other.contactTelegram, contactTelegram) || other.contactTelegram == contactTelegram)&&(identical(other.addressLatitude, addressLatitude) || other.addressLatitude == addressLatitude)&&(identical(other.addressLongitude, addressLongitude) || other.addressLongitude == addressLongitude)&&(identical(other.subwayStation, subwayStation) || other.subwayStation == subwayStation)&&const DeepCollectionEquality().equals(other._searchSubwayStations, _searchSubwayStations)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._searchLocations, _searchLocations)&&const DeepCollectionEquality().equals(other._amenities, _amenities)&&const DeepCollectionEquality().equals(other._photos, _photos)&&(identical(other.areaPriceStats, areaPriceStats) || other.areaPriceStats == areaPriceStats)&&const DeepCollectionEquality().equals(other._nearbyStores, _nearbyStores)&&(identical(other.groupSizeTarget, groupSizeTarget) || other.groupSizeTarget == groupSizeTarget)&&(identical(other.groupFormingStatus, groupFormingStatus) || other.groupFormingStatus == groupFormingStatus)&&(identical(other.groupCompatibilityReport, groupCompatibilityReport) || other.groupCompatibilityReport == groupCompatibilityReport)&&(identical(other.groupContext, groupContext) || other.groupContext == groupContext));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,title,listingTypeId,price,minPrice,maxPrice,isActive,createdAt,updatedAt,user,listingType,description,cityId,descriptionRu,descriptionEn,descriptionUz,subwayStationId,subwayLineId,locationId,gender,featuredAt,moveInDate,privateRoom,hostResident,pointCloudUrl,roomScanGlbUrl,roomScanFloorLongM,roomScanFloorShortM,roomScanHeightM,roomScanFloorAreaM2,roomScanWorldPlusXBearingDeg,roomScanNorthCorrectionDeg,contactPhone,contactTelegram,addressLatitude,addressLongitude,subwayStation,const DeepCollectionEquality().hash(_searchSubwayStations),location,const DeepCollectionEquality().hash(_searchLocations),const DeepCollectionEquality().hash(_amenities),const DeepCollectionEquality().hash(_photos),areaPriceStats,const DeepCollectionEquality().hash(_nearbyStores),groupSizeTarget,groupFormingStatus,groupCompatibilityReport,groupContext]);

@override
String toString() {
  return 'ListingDetail(id: $id, userId: $userId, title: $title, listingTypeId: $listingTypeId, price: $price, minPrice: $minPrice, maxPrice: $maxPrice, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, user: $user, listingType: $listingType, description: $description, cityId: $cityId, descriptionRu: $descriptionRu, descriptionEn: $descriptionEn, descriptionUz: $descriptionUz, subwayStationId: $subwayStationId, subwayLineId: $subwayLineId, locationId: $locationId, gender: $gender, featuredAt: $featuredAt, moveInDate: $moveInDate, privateRoom: $privateRoom, hostResident: $hostResident, pointCloudUrl: $pointCloudUrl, roomScanGlbUrl: $roomScanGlbUrl, roomScanFloorLongM: $roomScanFloorLongM, roomScanFloorShortM: $roomScanFloorShortM, roomScanHeightM: $roomScanHeightM, roomScanFloorAreaM2: $roomScanFloorAreaM2, roomScanWorldPlusXBearingDeg: $roomScanWorldPlusXBearingDeg, roomScanNorthCorrectionDeg: $roomScanNorthCorrectionDeg, contactPhone: $contactPhone, contactTelegram: $contactTelegram, addressLatitude: $addressLatitude, addressLongitude: $addressLongitude, subwayStation: $subwayStation, searchSubwayStations: $searchSubwayStations, location: $location, searchLocations: $searchLocations, amenities: $amenities, photos: $photos, areaPriceStats: $areaPriceStats, nearbyStores: $nearbyStores, groupSizeTarget: $groupSizeTarget, groupFormingStatus: $groupFormingStatus, groupCompatibilityReport: $groupCompatibilityReport, groupContext: $groupContext)';
}


}

/// @nodoc
abstract mixin class _$ListingDetailCopyWith<$Res> implements $ListingDetailCopyWith<$Res> {
  factory _$ListingDetailCopyWith(_ListingDetail value, $Res Function(_ListingDetail) _then) = __$ListingDetailCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "user_id") int userId, String title,@JsonKey(name: "listing_type_id") int listingTypeId,@JsonKey(name: "price") int price,@JsonKey(name: "min_price") int? minPrice,@JsonKey(name: "max_price") int? maxPrice,@JsonKey(name: "is_active") bool isActive,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt, UserDetail user,@JsonKey(name: "listing_type") ListingTypeDetail listingType, String? description,@JsonKey(name: "city_id") int? cityId,@JsonKey(name: "description_ru") String? descriptionRu,@JsonKey(name: "description_en") String? descriptionEn,@JsonKey(name: "description_uz") String? descriptionUz,@JsonKey(name: "subway_station_id") int? subwayStationId,@JsonKey(name: "subway_line_id") int? subwayLineId,@JsonKey(name: "location_id") int? locationId, int? gender,@JsonKey(name: "featured_at") String? featuredAt,@JsonKey(name: "move_in_date") String? moveInDate,@JsonKey(name: "private_room") bool? privateRoom,@JsonKey(name: "host_resident") bool? hostResident,@JsonKey(name: "point_cloud_url") String? pointCloudUrl,@JsonKey(name: "room_scan_glb_url") String? roomScanGlbUrl,@JsonKey(name: "room_scan_floor_long_m") double? roomScanFloorLongM,@JsonKey(name: "room_scan_floor_short_m") double? roomScanFloorShortM,@JsonKey(name: "room_scan_height_m") double? roomScanHeightM,@JsonKey(name: "room_scan_floor_area_m2") double? roomScanFloorAreaM2,@JsonKey(name: "room_scan_world_plus_x_bearing_deg") double? roomScanWorldPlusXBearingDeg,@JsonKey(name: "room_scan_north_correction_deg") double? roomScanNorthCorrectionDeg,@JsonKey(name: "contact_phone") String? contactPhone,@JsonKey(name: "contact_telegram") String? contactTelegram,@JsonKey(name: "address_latitude", fromJson: numericStringToDouble) double? addressLatitude,@JsonKey(name: "address_longitude", fromJson: numericStringToDouble) double? addressLongitude,@JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? searchSubwayStations, LocationDetail? location,@JsonKey(name: "search_locations") List<LocationDetail>? searchLocations, List<Amenity>? amenities, List<Photo>? photos,@JsonKey(name: "area_price_stats") AreaPriceStats? areaPriceStats,@JsonKey(name: "nearby_stores") List<ListingNearbyStore>? nearbyStores,@JsonKey(name: "group_size_target") int? groupSizeTarget,@JsonKey(name: "group_forming_status") String? groupFormingStatus,@JsonKey(name: "group_compatibility_report") String? groupCompatibilityReport,@JsonKey(includeFromJson: false, includeToJson: false) ListingGroupContext? groupContext
});


@override $UserDetailCopyWith<$Res> get user;@override $ListingTypeDetailCopyWith<$Res> get listingType;@override $SubwayStationDetailCopyWith<$Res>? get subwayStation;@override $LocationDetailCopyWith<$Res>? get location;@override $AreaPriceStatsCopyWith<$Res>? get areaPriceStats;

}
/// @nodoc
class __$ListingDetailCopyWithImpl<$Res>
    implements _$ListingDetailCopyWith<$Res> {
  __$ListingDetailCopyWithImpl(this._self, this._then);

  final _ListingDetail _self;
  final $Res Function(_ListingDetail) _then;

/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? listingTypeId = null,Object? price = null,Object? minPrice = freezed,Object? maxPrice = freezed,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? user = null,Object? listingType = null,Object? description = freezed,Object? cityId = freezed,Object? descriptionRu = freezed,Object? descriptionEn = freezed,Object? descriptionUz = freezed,Object? subwayStationId = freezed,Object? subwayLineId = freezed,Object? locationId = freezed,Object? gender = freezed,Object? featuredAt = freezed,Object? moveInDate = freezed,Object? privateRoom = freezed,Object? hostResident = freezed,Object? pointCloudUrl = freezed,Object? roomScanGlbUrl = freezed,Object? roomScanFloorLongM = freezed,Object? roomScanFloorShortM = freezed,Object? roomScanHeightM = freezed,Object? roomScanFloorAreaM2 = freezed,Object? roomScanWorldPlusXBearingDeg = freezed,Object? roomScanNorthCorrectionDeg = freezed,Object? contactPhone = freezed,Object? contactTelegram = freezed,Object? addressLatitude = freezed,Object? addressLongitude = freezed,Object? subwayStation = freezed,Object? searchSubwayStations = freezed,Object? location = freezed,Object? searchLocations = freezed,Object? amenities = freezed,Object? photos = freezed,Object? areaPriceStats = freezed,Object? nearbyStores = freezed,Object? groupSizeTarget = freezed,Object? groupFormingStatus = freezed,Object? groupCompatibilityReport = freezed,Object? groupContext = freezed,}) {
  return _then(_ListingDetail(
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
as String,user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserDetail,listingType: null == listingType ? _self.listingType : listingType // ignore: cast_nullable_to_non_nullable
as ListingTypeDetail,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as int?,descriptionRu: freezed == descriptionRu ? _self.descriptionRu : descriptionRu // ignore: cast_nullable_to_non_nullable
as String?,descriptionEn: freezed == descriptionEn ? _self.descriptionEn : descriptionEn // ignore: cast_nullable_to_non_nullable
as String?,descriptionUz: freezed == descriptionUz ? _self.descriptionUz : descriptionUz // ignore: cast_nullable_to_non_nullable
as String?,subwayStationId: freezed == subwayStationId ? _self.subwayStationId : subwayStationId // ignore: cast_nullable_to_non_nullable
as int?,subwayLineId: freezed == subwayLineId ? _self.subwayLineId : subwayLineId // ignore: cast_nullable_to_non_nullable
as int?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,featuredAt: freezed == featuredAt ? _self.featuredAt : featuredAt // ignore: cast_nullable_to_non_nullable
as String?,moveInDate: freezed == moveInDate ? _self.moveInDate : moveInDate // ignore: cast_nullable_to_non_nullable
as String?,privateRoom: freezed == privateRoom ? _self.privateRoom : privateRoom // ignore: cast_nullable_to_non_nullable
as bool?,hostResident: freezed == hostResident ? _self.hostResident : hostResident // ignore: cast_nullable_to_non_nullable
as bool?,pointCloudUrl: freezed == pointCloudUrl ? _self.pointCloudUrl : pointCloudUrl // ignore: cast_nullable_to_non_nullable
as String?,roomScanGlbUrl: freezed == roomScanGlbUrl ? _self.roomScanGlbUrl : roomScanGlbUrl // ignore: cast_nullable_to_non_nullable
as String?,roomScanFloorLongM: freezed == roomScanFloorLongM ? _self.roomScanFloorLongM : roomScanFloorLongM // ignore: cast_nullable_to_non_nullable
as double?,roomScanFloorShortM: freezed == roomScanFloorShortM ? _self.roomScanFloorShortM : roomScanFloorShortM // ignore: cast_nullable_to_non_nullable
as double?,roomScanHeightM: freezed == roomScanHeightM ? _self.roomScanHeightM : roomScanHeightM // ignore: cast_nullable_to_non_nullable
as double?,roomScanFloorAreaM2: freezed == roomScanFloorAreaM2 ? _self.roomScanFloorAreaM2 : roomScanFloorAreaM2 // ignore: cast_nullable_to_non_nullable
as double?,roomScanWorldPlusXBearingDeg: freezed == roomScanWorldPlusXBearingDeg ? _self.roomScanWorldPlusXBearingDeg : roomScanWorldPlusXBearingDeg // ignore: cast_nullable_to_non_nullable
as double?,roomScanNorthCorrectionDeg: freezed == roomScanNorthCorrectionDeg ? _self.roomScanNorthCorrectionDeg : roomScanNorthCorrectionDeg // ignore: cast_nullable_to_non_nullable
as double?,contactPhone: freezed == contactPhone ? _self.contactPhone : contactPhone // ignore: cast_nullable_to_non_nullable
as String?,contactTelegram: freezed == contactTelegram ? _self.contactTelegram : contactTelegram // ignore: cast_nullable_to_non_nullable
as String?,addressLatitude: freezed == addressLatitude ? _self.addressLatitude : addressLatitude // ignore: cast_nullable_to_non_nullable
as double?,addressLongitude: freezed == addressLongitude ? _self.addressLongitude : addressLongitude // ignore: cast_nullable_to_non_nullable
as double?,subwayStation: freezed == subwayStation ? _self.subwayStation : subwayStation // ignore: cast_nullable_to_non_nullable
as SubwayStationDetail?,searchSubwayStations: freezed == searchSubwayStations ? _self._searchSubwayStations : searchSubwayStations // ignore: cast_nullable_to_non_nullable
as List<SubwayStationDetail>?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LocationDetail?,searchLocations: freezed == searchLocations ? _self._searchLocations : searchLocations // ignore: cast_nullable_to_non_nullable
as List<LocationDetail>?,amenities: freezed == amenities ? _self._amenities : amenities // ignore: cast_nullable_to_non_nullable
as List<Amenity>?,photos: freezed == photos ? _self._photos : photos // ignore: cast_nullable_to_non_nullable
as List<Photo>?,areaPriceStats: freezed == areaPriceStats ? _self.areaPriceStats : areaPriceStats // ignore: cast_nullable_to_non_nullable
as AreaPriceStats?,nearbyStores: freezed == nearbyStores ? _self._nearbyStores : nearbyStores // ignore: cast_nullable_to_non_nullable
as List<ListingNearbyStore>?,groupSizeTarget: freezed == groupSizeTarget ? _self.groupSizeTarget : groupSizeTarget // ignore: cast_nullable_to_non_nullable
as int?,groupFormingStatus: freezed == groupFormingStatus ? _self.groupFormingStatus : groupFormingStatus // ignore: cast_nullable_to_non_nullable
as String?,groupCompatibilityReport: freezed == groupCompatibilityReport ? _self.groupCompatibilityReport : groupCompatibilityReport // ignore: cast_nullable_to_non_nullable
as String?,groupContext: freezed == groupContext ? _self.groupContext : groupContext // ignore: cast_nullable_to_non_nullable
as ListingGroupContext?,
  ));
}

/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserDetailCopyWith<$Res> get user {
  
  return $UserDetailCopyWith<$Res>(_self.user, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingTypeDetailCopyWith<$Res> get listingType {
  
  return $ListingTypeDetailCopyWith<$Res>(_self.listingType, (value) {
    return _then(_self.copyWith(listingType: value));
  });
}/// Create a copy of ListingDetail
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
}/// Create a copy of ListingDetail
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
}/// Create a copy of ListingDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AreaPriceStatsCopyWith<$Res>? get areaPriceStats {
    if (_self.areaPriceStats == null) {
    return null;
  }

  return $AreaPriceStatsCopyWith<$Res>(_self.areaPriceStats!, (value) {
    return _then(_self.copyWith(areaPriceStats: value));
  });
}
}


/// @nodoc
mixin _$UserDetail {

 int get id;@JsonKey(name: "created_at") String get createdAt; String? get email;// Add email field from API response
 String? get phone;
/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserDetailCopyWith<UserDetail> get copyWith => _$UserDetailCopyWithImpl<UserDetail>(this as UserDetail, _$identity);

  /// Serializes this UserDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,email,phone);

@override
String toString() {
  return 'UserDetail(id: $id, createdAt: $createdAt, email: $email, phone: $phone)';
}


}

/// @nodoc
abstract mixin class $UserDetailCopyWith<$Res>  {
  factory $UserDetailCopyWith(UserDetail value, $Res Function(UserDetail) _then) = _$UserDetailCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "created_at") String createdAt, String? email, String? phone
});




}
/// @nodoc
class _$UserDetailCopyWithImpl<$Res>
    implements $UserDetailCopyWith<$Res> {
  _$UserDetailCopyWithImpl(this._self, this._then);

  final UserDetail _self;
  final $Res Function(UserDetail) _then;

/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? createdAt = null,Object? email = freezed,Object? phone = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserDetail].
extension UserDetailPatterns on UserDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserDetail value)  $default,){
final _that = this;
switch (_that) {
case _UserDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserDetail value)?  $default,){
final _that = this;
switch (_that) {
case _UserDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "created_at")  String createdAt,  String? email,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserDetail() when $default != null:
return $default(_that.id,_that.createdAt,_that.email,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "created_at")  String createdAt,  String? email,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _UserDetail():
return $default(_that.id,_that.createdAt,_that.email,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "created_at")  String createdAt,  String? email,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _UserDetail() when $default != null:
return $default(_that.id,_that.createdAt,_that.email,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserDetail implements UserDetail {
  const _UserDetail({required this.id, @JsonKey(name: "created_at") required this.createdAt, this.email, this.phone});
  factory _UserDetail.fromJson(Map<String, dynamic> json) => _$UserDetailFromJson(json);

@override final  int id;
@override@JsonKey(name: "created_at") final  String createdAt;
@override final  String? email;
// Add email field from API response
@override final  String? phone;

/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserDetailCopyWith<_UserDetail> get copyWith => __$UserDetailCopyWithImpl<_UserDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.email, email) || other.email == email)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,createdAt,email,phone);

@override
String toString() {
  return 'UserDetail(id: $id, createdAt: $createdAt, email: $email, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$UserDetailCopyWith<$Res> implements $UserDetailCopyWith<$Res> {
  factory _$UserDetailCopyWith(_UserDetail value, $Res Function(_UserDetail) _then) = __$UserDetailCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "created_at") String createdAt, String? email, String? phone
});




}
/// @nodoc
class __$UserDetailCopyWithImpl<$Res>
    implements _$UserDetailCopyWith<$Res> {
  __$UserDetailCopyWithImpl(this._self, this._then);

  final _UserDetail _self;
  final $Res Function(_UserDetail) _then;

/// Create a copy of UserDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? createdAt = null,Object? email = freezed,Object? phone = freezed,}) {
  return _then(_UserDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ListingTypeDetail {

 int get id;@JsonKey(name: "name_uz") String get nameUz;@JsonKey(name: "name_ru") String get nameRu;@JsonKey(name: "name_en") String get nameEn; String get code;
/// Create a copy of ListingTypeDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingTypeDetailCopyWith<ListingTypeDetail> get copyWith => _$ListingTypeDetailCopyWithImpl<ListingTypeDetail>(this as ListingTypeDetail, _$identity);

  /// Serializes this ListingTypeDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingTypeDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,code);

@override
String toString() {
  return 'ListingTypeDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, code: $code)';
}


}

/// @nodoc
abstract mixin class $ListingTypeDetailCopyWith<$Res>  {
  factory $ListingTypeDetailCopyWith(ListingTypeDetail value, $Res Function(ListingTypeDetail) _then) = _$ListingTypeDetailCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "name_uz") String nameUz,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_en") String nameEn, String code
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameUz = null,Object? nameRu = null,Object? nameEn = null,Object? code = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  String code)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingTypeDetail() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.code);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  String code)  $default,) {final _that = this;
switch (_that) {
case _ListingTypeDetail():
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.code);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  String code)?  $default,) {final _that = this;
switch (_that) {
case _ListingTypeDetail() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.code);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingTypeDetail implements ListingTypeDetail {
  const _ListingTypeDetail({required this.id, @JsonKey(name: "name_uz") required this.nameUz, @JsonKey(name: "name_ru") required this.nameRu, @JsonKey(name: "name_en") required this.nameEn, required this.code});
  factory _ListingTypeDetail.fromJson(Map<String, dynamic> json) => _$ListingTypeDetailFromJson(json);

@override final  int id;
@override@JsonKey(name: "name_uz") final  String nameUz;
@override@JsonKey(name: "name_ru") final  String nameRu;
@override@JsonKey(name: "name_en") final  String nameEn;
@override final  String code;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingTypeDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.code, code) || other.code == code));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,code);

@override
String toString() {
  return 'ListingTypeDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, code: $code)';
}


}

/// @nodoc
abstract mixin class _$ListingTypeDetailCopyWith<$Res> implements $ListingTypeDetailCopyWith<$Res> {
  factory _$ListingTypeDetailCopyWith(_ListingTypeDetail value, $Res Function(_ListingTypeDetail) _then) = __$ListingTypeDetailCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "name_uz") String nameUz,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_en") String nameEn, String code
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameUz = null,Object? nameRu = null,Object? nameEn = null,Object? code = null,}) {
  return _then(_ListingTypeDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$SubwayStationDetail {

 int get id;@JsonKey(name: "name_uz") String get nameUz;@JsonKey(name: "name_ru") String get nameRu;@JsonKey(name: "name_en") String get nameEn; int get line;
/// Create a copy of SubwayStationDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubwayStationDetailCopyWith<SubwayStationDetail> get copyWith => _$SubwayStationDetailCopyWithImpl<SubwayStationDetail>(this as SubwayStationDetail, _$identity);

  /// Serializes this SubwayStationDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubwayStationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.line, line) || other.line == line));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,line);

@override
String toString() {
  return 'SubwayStationDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, line: $line)';
}


}

/// @nodoc
abstract mixin class $SubwayStationDetailCopyWith<$Res>  {
  factory $SubwayStationDetailCopyWith(SubwayStationDetail value, $Res Function(SubwayStationDetail) _then) = _$SubwayStationDetailCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "name_uz") String nameUz,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_en") String nameEn, int line
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameUz = null,Object? nameRu = null,Object? nameEn = null,Object? line = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  int line)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubwayStationDetail() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.line);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  int line)  $default,) {final _that = this;
switch (_that) {
case _SubwayStationDetail():
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.line);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn,  int line)?  $default,) {final _that = this;
switch (_that) {
case _SubwayStationDetail() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.line);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubwayStationDetail implements SubwayStationDetail {
  const _SubwayStationDetail({required this.id, @JsonKey(name: "name_uz") required this.nameUz, @JsonKey(name: "name_ru") required this.nameRu, @JsonKey(name: "name_en") required this.nameEn, required this.line});
  factory _SubwayStationDetail.fromJson(Map<String, dynamic> json) => _$SubwayStationDetailFromJson(json);

@override final  int id;
@override@JsonKey(name: "name_uz") final  String nameUz;
@override@JsonKey(name: "name_ru") final  String nameRu;
@override@JsonKey(name: "name_en") final  String nameEn;
@override final  int line;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubwayStationDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.line, line) || other.line == line));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,line);

@override
String toString() {
  return 'SubwayStationDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, line: $line)';
}


}

/// @nodoc
abstract mixin class _$SubwayStationDetailCopyWith<$Res> implements $SubwayStationDetailCopyWith<$Res> {
  factory _$SubwayStationDetailCopyWith(_SubwayStationDetail value, $Res Function(_SubwayStationDetail) _then) = __$SubwayStationDetailCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "name_uz") String nameUz,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_en") String nameEn, int line
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameUz = null,Object? nameRu = null,Object? nameEn = null,Object? line = null,}) {
  return _then(_SubwayStationDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,line: null == line ? _self.line : line // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$LocationDetail {

 int get id;@JsonKey(name: "name_uz") String get nameUz;@JsonKey(name: "name_ru") String get nameRu;@JsonKey(name: "name_en") String get nameEn;@JsonKey(name: "short_name_uz") String get shortNameUz;@JsonKey(name: "short_name_ru") String get shortNameRu;@JsonKey(name: "short_name_en") String get shortNameEn;
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
 int id,@JsonKey(name: "name_uz") String nameUz,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_en") String nameEn,@JsonKey(name: "short_name_uz") String shortNameUz,@JsonKey(name: "short_name_ru") String shortNameRu,@JsonKey(name: "short_name_en") String shortNameEn
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameUz = null,Object? nameRu = null,Object? nameEn = null,Object? shortNameUz = null,Object? shortNameRu = null,Object? shortNameEn = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,shortNameUz: null == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String,shortNameRu: null == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String,shortNameEn: null == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn, @JsonKey(name: "short_name_uz")  String shortNameUz, @JsonKey(name: "short_name_ru")  String shortNameRu, @JsonKey(name: "short_name_en")  String shortNameEn)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn, @JsonKey(name: "short_name_uz")  String shortNameUz, @JsonKey(name: "short_name_ru")  String shortNameRu, @JsonKey(name: "short_name_en")  String shortNameEn)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "name_uz")  String nameUz, @JsonKey(name: "name_ru")  String nameRu, @JsonKey(name: "name_en")  String nameEn, @JsonKey(name: "short_name_uz")  String shortNameUz, @JsonKey(name: "short_name_ru")  String shortNameRu, @JsonKey(name: "short_name_en")  String shortNameEn)?  $default,) {final _that = this;
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
  const _LocationDetail({required this.id, @JsonKey(name: "name_uz") required this.nameUz, @JsonKey(name: "name_ru") required this.nameRu, @JsonKey(name: "name_en") required this.nameEn, @JsonKey(name: "short_name_uz") required this.shortNameUz, @JsonKey(name: "short_name_ru") required this.shortNameRu, @JsonKey(name: "short_name_en") required this.shortNameEn});
  factory _LocationDetail.fromJson(Map<String, dynamic> json) => _$LocationDetailFromJson(json);

@override final  int id;
@override@JsonKey(name: "name_uz") final  String nameUz;
@override@JsonKey(name: "name_ru") final  String nameRu;
@override@JsonKey(name: "name_en") final  String nameEn;
@override@JsonKey(name: "short_name_uz") final  String shortNameUz;
@override@JsonKey(name: "short_name_ru") final  String shortNameRu;
@override@JsonKey(name: "short_name_en") final  String shortNameEn;

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
 int id,@JsonKey(name: "name_uz") String nameUz,@JsonKey(name: "name_ru") String nameRu,@JsonKey(name: "name_en") String nameEn,@JsonKey(name: "short_name_uz") String shortNameUz,@JsonKey(name: "short_name_ru") String shortNameRu,@JsonKey(name: "short_name_en") String shortNameEn
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameUz = null,Object? nameRu = null,Object? nameEn = null,Object? shortNameUz = null,Object? shortNameRu = null,Object? shortNameEn = null,}) {
  return _then(_LocationDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: null == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String,nameRu: null == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String,nameEn: null == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String,shortNameUz: null == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String,shortNameRu: null == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String,shortNameEn: null == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AreaPriceStats {

@JsonKey(name: "subway_station") AreaPriceBenchmark? get subwayStation;@JsonKey(name: "location") AreaPriceBenchmark? get location;
/// Create a copy of AreaPriceStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaPriceStatsCopyWith<AreaPriceStats> get copyWith => _$AreaPriceStatsCopyWithImpl<AreaPriceStats>(this as AreaPriceStats, _$identity);

  /// Serializes this AreaPriceStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AreaPriceStats&&(identical(other.subwayStation, subwayStation) || other.subwayStation == subwayStation)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subwayStation,location);

@override
String toString() {
  return 'AreaPriceStats(subwayStation: $subwayStation, location: $location)';
}


}

/// @nodoc
abstract mixin class $AreaPriceStatsCopyWith<$Res>  {
  factory $AreaPriceStatsCopyWith(AreaPriceStats value, $Res Function(AreaPriceStats) _then) = _$AreaPriceStatsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "subway_station") AreaPriceBenchmark? subwayStation,@JsonKey(name: "location") AreaPriceBenchmark? location
});


$AreaPriceBenchmarkCopyWith<$Res>? get subwayStation;$AreaPriceBenchmarkCopyWith<$Res>? get location;

}
/// @nodoc
class _$AreaPriceStatsCopyWithImpl<$Res>
    implements $AreaPriceStatsCopyWith<$Res> {
  _$AreaPriceStatsCopyWithImpl(this._self, this._then);

  final AreaPriceStats _self;
  final $Res Function(AreaPriceStats) _then;

/// Create a copy of AreaPriceStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subwayStation = freezed,Object? location = freezed,}) {
  return _then(_self.copyWith(
subwayStation: freezed == subwayStation ? _self.subwayStation : subwayStation // ignore: cast_nullable_to_non_nullable
as AreaPriceBenchmark?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AreaPriceBenchmark?,
  ));
}
/// Create a copy of AreaPriceStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AreaPriceBenchmarkCopyWith<$Res>? get subwayStation {
    if (_self.subwayStation == null) {
    return null;
  }

  return $AreaPriceBenchmarkCopyWith<$Res>(_self.subwayStation!, (value) {
    return _then(_self.copyWith(subwayStation: value));
  });
}/// Create a copy of AreaPriceStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AreaPriceBenchmarkCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $AreaPriceBenchmarkCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// Adds pattern-matching-related methods to [AreaPriceStats].
extension AreaPriceStatsPatterns on AreaPriceStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AreaPriceStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AreaPriceStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AreaPriceStats value)  $default,){
final _that = this;
switch (_that) {
case _AreaPriceStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AreaPriceStats value)?  $default,){
final _that = this;
switch (_that) {
case _AreaPriceStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "subway_station")  AreaPriceBenchmark? subwayStation, @JsonKey(name: "location")  AreaPriceBenchmark? location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AreaPriceStats() when $default != null:
return $default(_that.subwayStation,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "subway_station")  AreaPriceBenchmark? subwayStation, @JsonKey(name: "location")  AreaPriceBenchmark? location)  $default,) {final _that = this;
switch (_that) {
case _AreaPriceStats():
return $default(_that.subwayStation,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "subway_station")  AreaPriceBenchmark? subwayStation, @JsonKey(name: "location")  AreaPriceBenchmark? location)?  $default,) {final _that = this;
switch (_that) {
case _AreaPriceStats() when $default != null:
return $default(_that.subwayStation,_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AreaPriceStats implements AreaPriceStats {
  const _AreaPriceStats({@JsonKey(name: "subway_station") this.subwayStation, @JsonKey(name: "location") this.location});
  factory _AreaPriceStats.fromJson(Map<String, dynamic> json) => _$AreaPriceStatsFromJson(json);

@override@JsonKey(name: "subway_station") final  AreaPriceBenchmark? subwayStation;
@override@JsonKey(name: "location") final  AreaPriceBenchmark? location;

/// Create a copy of AreaPriceStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AreaPriceStatsCopyWith<_AreaPriceStats> get copyWith => __$AreaPriceStatsCopyWithImpl<_AreaPriceStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AreaPriceStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AreaPriceStats&&(identical(other.subwayStation, subwayStation) || other.subwayStation == subwayStation)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,subwayStation,location);

@override
String toString() {
  return 'AreaPriceStats(subwayStation: $subwayStation, location: $location)';
}


}

/// @nodoc
abstract mixin class _$AreaPriceStatsCopyWith<$Res> implements $AreaPriceStatsCopyWith<$Res> {
  factory _$AreaPriceStatsCopyWith(_AreaPriceStats value, $Res Function(_AreaPriceStats) _then) = __$AreaPriceStatsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "subway_station") AreaPriceBenchmark? subwayStation,@JsonKey(name: "location") AreaPriceBenchmark? location
});


@override $AreaPriceBenchmarkCopyWith<$Res>? get subwayStation;@override $AreaPriceBenchmarkCopyWith<$Res>? get location;

}
/// @nodoc
class __$AreaPriceStatsCopyWithImpl<$Res>
    implements _$AreaPriceStatsCopyWith<$Res> {
  __$AreaPriceStatsCopyWithImpl(this._self, this._then);

  final _AreaPriceStats _self;
  final $Res Function(_AreaPriceStats) _then;

/// Create a copy of AreaPriceStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subwayStation = freezed,Object? location = freezed,}) {
  return _then(_AreaPriceStats(
subwayStation: freezed == subwayStation ? _self.subwayStation : subwayStation // ignore: cast_nullable_to_non_nullable
as AreaPriceBenchmark?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as AreaPriceBenchmark?,
  ));
}

/// Create a copy of AreaPriceStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AreaPriceBenchmarkCopyWith<$Res>? get subwayStation {
    if (_self.subwayStation == null) {
    return null;
  }

  return $AreaPriceBenchmarkCopyWith<$Res>(_self.subwayStation!, (value) {
    return _then(_self.copyWith(subwayStation: value));
  });
}/// Create a copy of AreaPriceStats
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AreaPriceBenchmarkCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $AreaPriceBenchmarkCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}
}


/// @nodoc
mixin _$AreaPriceBenchmark {

 int get mean; int get median;@JsonKey(name: "sample_count") int get sampleCount;
/// Create a copy of AreaPriceBenchmark
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AreaPriceBenchmarkCopyWith<AreaPriceBenchmark> get copyWith => _$AreaPriceBenchmarkCopyWithImpl<AreaPriceBenchmark>(this as AreaPriceBenchmark, _$identity);

  /// Serializes this AreaPriceBenchmark to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AreaPriceBenchmark&&(identical(other.mean, mean) || other.mean == mean)&&(identical(other.median, median) || other.median == median)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mean,median,sampleCount);

@override
String toString() {
  return 'AreaPriceBenchmark(mean: $mean, median: $median, sampleCount: $sampleCount)';
}


}

/// @nodoc
abstract mixin class $AreaPriceBenchmarkCopyWith<$Res>  {
  factory $AreaPriceBenchmarkCopyWith(AreaPriceBenchmark value, $Res Function(AreaPriceBenchmark) _then) = _$AreaPriceBenchmarkCopyWithImpl;
@useResult
$Res call({
 int mean, int median,@JsonKey(name: "sample_count") int sampleCount
});




}
/// @nodoc
class _$AreaPriceBenchmarkCopyWithImpl<$Res>
    implements $AreaPriceBenchmarkCopyWith<$Res> {
  _$AreaPriceBenchmarkCopyWithImpl(this._self, this._then);

  final AreaPriceBenchmark _self;
  final $Res Function(AreaPriceBenchmark) _then;

/// Create a copy of AreaPriceBenchmark
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mean = null,Object? median = null,Object? sampleCount = null,}) {
  return _then(_self.copyWith(
mean: null == mean ? _self.mean : mean // ignore: cast_nullable_to_non_nullable
as int,median: null == median ? _self.median : median // ignore: cast_nullable_to_non_nullable
as int,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AreaPriceBenchmark].
extension AreaPriceBenchmarkPatterns on AreaPriceBenchmark {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AreaPriceBenchmark value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AreaPriceBenchmark() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AreaPriceBenchmark value)  $default,){
final _that = this;
switch (_that) {
case _AreaPriceBenchmark():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AreaPriceBenchmark value)?  $default,){
final _that = this;
switch (_that) {
case _AreaPriceBenchmark() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int mean,  int median, @JsonKey(name: "sample_count")  int sampleCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AreaPriceBenchmark() when $default != null:
return $default(_that.mean,_that.median,_that.sampleCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int mean,  int median, @JsonKey(name: "sample_count")  int sampleCount)  $default,) {final _that = this;
switch (_that) {
case _AreaPriceBenchmark():
return $default(_that.mean,_that.median,_that.sampleCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int mean,  int median, @JsonKey(name: "sample_count")  int sampleCount)?  $default,) {final _that = this;
switch (_that) {
case _AreaPriceBenchmark() when $default != null:
return $default(_that.mean,_that.median,_that.sampleCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AreaPriceBenchmark implements AreaPriceBenchmark {
  const _AreaPriceBenchmark({required this.mean, required this.median, @JsonKey(name: "sample_count") required this.sampleCount});
  factory _AreaPriceBenchmark.fromJson(Map<String, dynamic> json) => _$AreaPriceBenchmarkFromJson(json);

@override final  int mean;
@override final  int median;
@override@JsonKey(name: "sample_count") final  int sampleCount;

/// Create a copy of AreaPriceBenchmark
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AreaPriceBenchmarkCopyWith<_AreaPriceBenchmark> get copyWith => __$AreaPriceBenchmarkCopyWithImpl<_AreaPriceBenchmark>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AreaPriceBenchmarkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AreaPriceBenchmark&&(identical(other.mean, mean) || other.mean == mean)&&(identical(other.median, median) || other.median == median)&&(identical(other.sampleCount, sampleCount) || other.sampleCount == sampleCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mean,median,sampleCount);

@override
String toString() {
  return 'AreaPriceBenchmark(mean: $mean, median: $median, sampleCount: $sampleCount)';
}


}

/// @nodoc
abstract mixin class _$AreaPriceBenchmarkCopyWith<$Res> implements $AreaPriceBenchmarkCopyWith<$Res> {
  factory _$AreaPriceBenchmarkCopyWith(_AreaPriceBenchmark value, $Res Function(_AreaPriceBenchmark) _then) = __$AreaPriceBenchmarkCopyWithImpl;
@override @useResult
$Res call({
 int mean, int median,@JsonKey(name: "sample_count") int sampleCount
});




}
/// @nodoc
class __$AreaPriceBenchmarkCopyWithImpl<$Res>
    implements _$AreaPriceBenchmarkCopyWith<$Res> {
  __$AreaPriceBenchmarkCopyWithImpl(this._self, this._then);

  final _AreaPriceBenchmark _self;
  final $Res Function(_AreaPriceBenchmark) _then;

/// Create a copy of AreaPriceBenchmark
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mean = null,Object? median = null,Object? sampleCount = null,}) {
  return _then(_AreaPriceBenchmark(
mean: null == mean ? _self.mean : mean // ignore: cast_nullable_to_non_nullable
as int,median: null == median ? _self.median : median // ignore: cast_nullable_to_non_nullable
as int,sampleCount: null == sampleCount ? _self.sampleCount : sampleCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
