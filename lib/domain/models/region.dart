import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";

part "region.freezed.dart";
part "region.g.dart";

@freezed
abstract class Region with _$Region implements IJsonEncodable {
  const factory Region({
    required int id,
    @JsonKey(name: "country_id") int? countryId,
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "name_en") String? nameEn,
    @JsonKey(name: "name_ru") String? nameRu,
    @JsonKey(name: "name_uz") String? nameUz,
    @JsonKey(name: "short_name") String? shortName,
    @JsonKey(name: "short_name_en") String? shortNameEn,
    @JsonKey(name: "short_name_ru") String? shortNameRu,
    @JsonKey(name: "short_name_uz") String? shortNameUz,
    @JsonKey(name: "latitude") String? latitude,
    @JsonKey(name: "longitude") String? longitude,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  }) = _Region;

  factory Region.fromJson(Map<String, dynamic> json) => _$RegionFromJson(json);
}

extension RegionLocalization on Region {
  /// Get localized name based on language code
  String getLocalizedName(String language) {
    switch (language) {
      case "en":
        return nameEn ?? name ?? "Unknown Region";
      case "ru":
        return nameRu ?? name ?? "Unknown Region";
      case "uz":
        return nameUz ?? name ?? "Unknown Region";
      default:
        return name ?? "Unknown Region";
    }
  }

  /// Get localized short name based on language code
  String getLocalizedShortName(String language) {
    switch (language) {
      case "en":
        return shortNameEn ?? shortName ?? "Unknown";
      case "ru":
        return shortNameRu ?? shortName ?? "Unknown";
      case "uz":
        return shortNameUz ?? shortName ?? "Unknown";
      default:
        return shortName ?? "Unknown";
    }
  }
}
