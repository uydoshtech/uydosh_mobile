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
    @JsonKey(name: "min_price") required int minPrice,
    @JsonKey(name: "max_price") required int maxPrice,
    @JsonKey(name: "is_active") required bool isActive, @JsonKey(name: "created_at") required String createdAt, @JsonKey(name: "updated_at") required String updatedAt, required UserDetail user, @JsonKey(name: "listing_type") required ListingTypeDetail listingType, String? description,
    @JsonKey(name: "subway_station_id") int? subwayStationId,
    @JsonKey(name: "subway_line_id") int? subwayLineId,
    @JsonKey(name: "location_id") int? locationId,
    int? gender,
    @JsonKey(name: "featured_at") String? featuredAt,
    @JsonKey(name: "move_in_date") String? moveInDate,
    @JsonKey(name: "private_room") bool? privateRoom,
    @JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,
    LocationDetail? location,
    List<Amenity>? amenities,
    List<Photo>? photos,
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
