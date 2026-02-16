import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/converter/nullable_int_converter.dart";

part "university.freezed.dart";
part "university.g.dart";

@freezed
class University with _$University implements IJsonEncodable {
  const factory University({
    @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertFromJson,
    )
    required int id,
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
    @JsonKey(name: "location_id") int? locationId,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
    @JsonKey(name: "location") Map<String, dynamic>? location,
  }) = _University;

  factory University.fromJson(Map<String, dynamic> json) =>
      _$UniversityFromJson(json);
}

/// Extension methods for University to provide language-aware functionality
extension UniversityLocalization on University {
  /// Get language-aware university name
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case "en":
        return nameEn ?? name ?? "Unknown";
      case "ru":
        return nameRu ?? name ?? "Unknown";
      case "uz":
        return nameUz ?? name ?? "Unknown";
      default:
        return name ?? "Unknown";
    }
  }

  /// Get language-aware university name with proper capitalization (only first letter of each word)
  String getLocalizedNameCapitalized(String languageCode) {
    final name = getLocalizedName(languageCode);
    return _capitalizeWords(name);
  }

  /// Capitalize only the first letter of each word
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .split(" ")
        .map(
          (word) =>
              word.isEmpty
                  ? word
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(" ");
  }

  /// Get language-aware university short name
  String getLocalizedShortName(String languageCode) {
    switch (languageCode) {
      case "en":
        return shortNameEn ?? shortName ?? "";
      case "ru":
        return shortNameRu ?? shortName ?? "";
      case "uz":
        return shortNameUz ?? shortName ?? "";
      default:
        return shortName ?? "";
    }
  }
}
