import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/models/photo.dart";

part "listing.freezed.dart";
part "listing.g.dart";

int? _nullableListingIntFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

@freezed
class Listing with _$Listing {
  const factory Listing({
    required int id,
    @JsonKey(name: "user_id") required int userId,
    @JsonKey(name: "title") required String title,
    @JsonKey(name: "listing_type_id") required int listingTypeId,
    @JsonKey(name: "price") required int price,
    @JsonKey(name: "min_price") int? minPrice,
    @JsonKey(name: "max_price") int? maxPrice,
    @JsonKey(name: "is_active") required bool isActive,
    @JsonKey(name: "created_at") required String createdAt,
    @JsonKey(name: "updated_at") required String updatedAt,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "city_id") int? cityId,
    @JsonKey(name: "subway_station_id") int? subwayStationId,
    @JsonKey(name: "subway_line_id") int? subwayLineId,
    @JsonKey(name: "location_id") int? locationId,
    @JsonKey(name: "gender") int? gender,
    @JsonKey(name: "featured_at") String? featuredAt,
    @JsonKey(name: "move_in_date") String? moveInDate,
    @JsonKey(name: "private_room") bool? privateRoom,
    @JsonKey(name: "host_resident") bool? hostResident,
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
    @JsonKey(name: "search_subway_stations")
    List<SubwayStationDetail>? searchSubwayStations,
    @JsonKey(name: "location") LocationDetail? location,
    @JsonKey(name: "search_locations") List<LocationDetail>? searchLocations,
    @JsonKey(name: "listing_type") ListingTypeDetail? listingType,
    @JsonKey(name: "amenities") List<Amenity>? amenities,
    List<Photo>? photos,
    @JsonKey(name: "isFavorited") bool? isFavorited,
    @JsonKey(name: "group_size_target", fromJson: _nullableListingIntFromJson)
    int? groupSizeTarget,
    @JsonKey(name: "group_member_count", fromJson: _nullableListingIntFromJson)
    int? groupMemberCount,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);
}

@freezed
class SubwayStationDetail with _$SubwayStationDetail {
  const factory SubwayStationDetail({
    required int id,
    required int line,
    @JsonKey(name: "name_uz") String? nameUz,
    @JsonKey(name: "name_ru") String? nameRu,
    @JsonKey(name: "name_en") String? nameEn,
  }) = _SubwayStationDetail;

  factory SubwayStationDetail.fromJson(Map<String, dynamic> json) =>
      _$SubwayStationDetailFromJson(json);
}

@freezed
class LocationDetail with _$LocationDetail {
  const factory LocationDetail({
    required int id,
    @JsonKey(name: "name_uz") String? nameUz,
    @JsonKey(name: "name_ru") String? nameRu,
    @JsonKey(name: "name_en") String? nameEn,
    @JsonKey(name: "short_name_uz") String? shortNameUz,
    @JsonKey(name: "short_name_ru") String? shortNameRu,
    @JsonKey(name: "short_name_en") String? shortNameEn,
  }) = _LocationDetail;

  factory LocationDetail.fromJson(Map<String, dynamic> json) =>
      _$LocationDetailFromJson(json);
}

@freezed
class ListingTypeDetail with _$ListingTypeDetail {
  const factory ListingTypeDetail({
    required int id,
    required String code,
    @JsonKey(name: "name_uz") String? nameUz,
    @JsonKey(name: "name_ru") String? nameRu,
    @JsonKey(name: "name_en") String? nameEn,
  }) = _ListingTypeDetail;

  factory ListingTypeDetail.fromJson(Map<String, dynamic> json) =>
      _$ListingTypeDetailFromJson(json);
}
