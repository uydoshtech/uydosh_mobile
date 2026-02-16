import "package:freezed_annotation/freezed_annotation.dart";

part "location.freezed.dart";
part "location.g.dart";

@freezed
class Location with _$Location {
  const factory Location({
    required int id,
    @JsonKey(name: "created_at") required String createdAt, @JsonKey(name: "updated_at") required String updatedAt, @JsonKey(name: "name_uz") String? nameUz,
    @JsonKey(name: "name_ru") String? nameRu,
    @JsonKey(name: "name_en") String? nameEn,
    @JsonKey(name: "short_name_uz") String? shortNameUz,
    @JsonKey(name: "short_name_ru") String? shortNameRu,
    @JsonKey(name: "short_name_en") String? shortNameEn,
    @JsonKey(name: "short_name") String? shortName,
    double? latitude,
    double? longitude,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}
