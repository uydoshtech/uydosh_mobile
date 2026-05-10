import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/models/photo.dart";

part "listing_detail.freezed.dart";
part "listing_detail.g.dart";

@freezed
class ListingDetail with _$ListingDetail {
  const factory ListingDetail({
    required int id,
    @JsonKey(name: "user_id") required int userId,
    required String title,
    @JsonKey(name: "listing_type_id") required int listingTypeId,
    @JsonKey(name: "price") required int price,
    @JsonKey(name: "is_active") required bool isActive, @JsonKey(name: "created_at") required String createdAt, @JsonKey(name: "updated_at") required String updatedAt, required UserDetail user, @JsonKey(name: "listing_type") required ListingTypeDetail listingType, String? description,
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
    @JsonKey(name: "contact_phone") String? contactPhone,
    @JsonKey(name: "contact_telegram") String? contactTelegram,
    @JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,
    LocationDetail? location,
    List<Amenity>? amenities,
    List<Photo>? photos,
    @JsonKey(name: "area_price_stats") AreaPriceStats? areaPriceStats,
  }) = _ListingDetail;

  factory ListingDetail.fromJson(Map<String, dynamic> json) =>
      _$ListingDetailFromJson(json);
}

@freezed
class UserDetail with _$UserDetail {
  const factory UserDetail({
    required int id,
    @JsonKey(name: "created_at") required String createdAt, String? email, // Add email field from API response
    String? phone, // Make phone optional since it was removed from database
  }) = _UserDetail;

  factory UserDetail.fromJson(Map<String, dynamic> json) =>
      _$UserDetailFromJson(json);
}

@freezed
class ListingTypeDetail with _$ListingTypeDetail {
  const factory ListingTypeDetail({
    required int id,
    @JsonKey(name: "name_uz") required String nameUz,
    @JsonKey(name: "name_ru") required String nameRu,
    @JsonKey(name: "name_en") required String nameEn,
    required String code,
  }) = _ListingTypeDetail;

  factory ListingTypeDetail.fromJson(Map<String, dynamic> json) =>
      _$ListingTypeDetailFromJson(json);
}

@freezed
class SubwayStationDetail with _$SubwayStationDetail {
  const factory SubwayStationDetail({
    required int id,
    @JsonKey(name: "name_uz") required String nameUz,
    @JsonKey(name: "name_ru") required String nameRu,
    @JsonKey(name: "name_en") required String nameEn,
    required int line,
  }) = _SubwayStationDetail;

  factory SubwayStationDetail.fromJson(Map<String, dynamic> json) =>
      _$SubwayStationDetailFromJson(json);
}

@freezed
class LocationDetail with _$LocationDetail {
  const factory LocationDetail({
    required int id,
    @JsonKey(name: "name_uz") required String nameUz,
    @JsonKey(name: "name_ru") required String nameRu,
    @JsonKey(name: "name_en") required String nameEn,
    @JsonKey(name: "short_name_uz") required String shortNameUz,
    @JsonKey(name: "short_name_ru") required String shortNameRu,
    @JsonKey(name: "short_name_en") required String shortNameEn,
  }) = _LocationDetail;

  factory LocationDetail.fromJson(Map<String, dynamic> json) =>
      _$LocationDetailFromJson(json);
}

@freezed
class AreaPriceStats with _$AreaPriceStats {
  const factory AreaPriceStats({
    @JsonKey(name: "subway_station") AreaPriceBenchmark? subwayStation,
    @JsonKey(name: "location") AreaPriceBenchmark? location,
  }) = _AreaPriceStats;

  factory AreaPriceStats.fromJson(Map<String, dynamic> json) =>
      _$AreaPriceStatsFromJson(json);
}

@freezed
class AreaPriceBenchmark with _$AreaPriceBenchmark {
  const factory AreaPriceBenchmark({
    required int mean,
    required int median,
    @JsonKey(name: "sample_count") required int sampleCount,
  }) = _AreaPriceBenchmark;

  factory AreaPriceBenchmark.fromJson(Map<String, dynamic> json) =>
      _$AreaPriceBenchmarkFromJson(json);
}
