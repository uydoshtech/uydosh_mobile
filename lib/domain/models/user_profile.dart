import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:uy_dosh/base/api/converter/nullable_int_converter.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson,
    )
    required int id,
    @JsonKey(name: 'user_id') required int userId,
    String? name,
    int? gender,
    @JsonKey(name: 'is_verified') bool? isVerified,
    @JsonKey(name: 'region_id') int? regionId,
    @JsonKey(name: 'university_id') int? universityId,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? telegram,
    double? rating,
    @JsonKey(name: 'about_me') String? aboutMe,
    bool? employed,
    int? cleanliness,
    @JsonKey(name: 'noise_level') int? noiseLevel,
    int? sociability,
    @JsonKey(name: 'guests_allowed') bool? guestsAllowed,
    @JsonKey(name: 'smoking_preference') String? smokingPreference,
    @JsonKey(name: 'alcohol_preference') String? alcoholPreference,
    @JsonKey(name: 'cooking_habits') bool? cookingHabits,
    @JsonKey(name: 'pets_preference') bool? petsPreference,
    @JsonKey(name: 'wakeup_time') String? wakeupTime,
    @JsonKey(name: 'sleep_time') String? sleepTime,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    UserProfileRegion? region,
    UserProfileUniversity? university,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class UserProfileRegion with _$UserProfileRegion {
  const factory UserProfileRegion({
    @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson,
    )
    required int id,
    @JsonKey(name: 'name_uz') String? nameUz,
    @JsonKey(name: 'name_ru') String? nameRu,
    @JsonKey(name: 'name_en') String? nameEn,
    @JsonKey(name: 'short_name_uz') String? shortNameUz,
    @JsonKey(name: 'short_name_ru') String? shortNameRu,
    @JsonKey(name: 'short_name_en') String? shortNameEn,
  }) = _UserProfileRegion;

  factory UserProfileRegion.fromJson(Map<String, dynamic> json) =>
      _$UserProfileRegionFromJson(json);
}

@freezed
class UserProfileUniversity with _$UserProfileUniversity {
  const factory UserProfileUniversity({
    @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson,
    )
    required int id,
    @JsonKey(name: 'name_uz') String? nameUz,
    @JsonKey(name: 'name_ru') String? nameRu,
    @JsonKey(name: 'name_en') String? nameEn,
    @JsonKey(name: 'short_name_uz') String? shortNameUz,
    @JsonKey(name: 'short_name_ru') String? shortNameRu,
    @JsonKey(name: 'short_name_en') String? shortNameEn,
    String? address,
    String? website,
  }) = _UserProfileUniversity;

  factory UserProfileUniversity.fromJson(Map<String, dynamic> json) =>
      _$UserProfileUniversityFromJson(json);
}

/// Extension methods for UserProfileUniversity to provide language-aware functionality
extension UserProfileUniversityLocalization on UserProfileUniversity {
  /// Get language-aware university name
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case "en":
        return nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? "Unknown";
      case "uz":
        return nameUz ?? "Unknown";
      default:
        return nameEn ?? "Unknown";
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
        .split(' ')
        .map(
          (word) =>
              word.isEmpty
                  ? word
                  : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  /// Get language-aware university short name
  String getLocalizedShortName(String languageCode) {
    switch (languageCode) {
      case "en":
        return shortNameEn ?? "";
      case "ru":
        return shortNameRu ?? "";
      case "uz":
        return shortNameUz ?? "";
      default:
        return shortNameEn ?? "";
    }
  }
}
