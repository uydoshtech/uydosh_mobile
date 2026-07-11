import "package:freezed_annotation/freezed_annotation.dart";

part "subway_station.freezed.dart";
part "subway_station.g.dart";

@freezed
abstract class SubwayStation with _$SubwayStation {
  const factory SubwayStation({
    required int id,
    required int line,
    required int ordinal,
    @JsonKey(name: "name_uz") String? nameUz,
    @JsonKey(name: "name_ru") String? nameRu,
    @JsonKey(name: "name_en") String? nameEn,
    @JsonKey(name: "latitude") double? latitude,
    @JsonKey(name: "longitude") double? longitude,
    @JsonKey(name: "location_id") int? locationId,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  }) = _SubwayStation;

  factory SubwayStation.fromJson(Map<String, dynamic> json) =>
      _$SubwayStationFromJson(json);
}
