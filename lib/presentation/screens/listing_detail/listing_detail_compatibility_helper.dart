import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/pets_preference_strings.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/utils/profile_match_scoring.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_compatibility_section.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Computes compatibility between current user and listing owner.
/// Moved out of build to avoid heavy logic and .map().toList() in build.
class ListingDetailCompatibilityHelper {
  ListingDetailCompatibilityHelper._();

  static CompatibilityResult calculate(
    UserProfile currentProfile,
    UserProfile ownerProfile,
  ) {
    final matches = <CompatibilityMatch>[];
    final differences = <CompatibilityDifference>[];

    void compare<T>({
      required String labelKey,
      required T? currentValue,
      required T? ownerValue,
      required bool Function(T a, T b) isMatch,
      required String Function(T value) formatValue,
    }) {
      if (currentValue == null || ownerValue == null) return;
      final label = L10n.get(labelKey);
      final currentText = formatValue(currentValue);
      final ownerText = formatValue(ownerValue);

      if (isMatch(currentValue, ownerValue)) {
        matches.add(CompatibilityMatch(
          labelKey: labelKey,
          label: label,
          value: currentText,
        ));
      } else {
        differences.add(CompatibilityDifference(
          labelKey: labelKey,
          label: label,
          currentText: currentText,
          ownerText: ownerText,
        ));
      }
    }

    // University
    if (currentProfile.universityId != null &&
        ownerProfile.universityId != null) {
      final currentLang = LanguageState().currentLanguage;
      final currentText = currentProfile.university != null
          ? currentProfile.university!.getLocalizedNameCapitalized(currentLang)
          : "";
      final ownerText = ownerProfile.university != null
          ? ownerProfile.university!.getLocalizedNameCapitalized(currentLang)
          : "";

      if (currentProfile.universityId == ownerProfile.universityId) {
        matches.insert(
          0,
          CompatibilityMatch(
            labelKey: "same_university",
            label: L10n.get("same_university"),
            value: currentText.isNotEmpty ? currentText : ownerText,
          ),
        );
      } else {
        matches.insert(
          0,
          CompatibilityMatch(
            labelKey: "both_students",
            label: L10n.get("both_students"),
            value: "$currentText ↔ $ownerText",
          ),
        );
      }
    }

    // Region
    if (currentProfile.regionId != null && ownerProfile.regionId != null) {
      const labelKey = "region";
      final label = L10n.get(labelKey);
      final currentText = currentProfile.region != null
          ? _getLocalizedRegionName(currentProfile.region!)
          : "";
      final ownerText = ownerProfile.region != null
          ? _getLocalizedRegionName(ownerProfile.region!)
          : "";

      if (currentProfile.regionId == ownerProfile.regionId) {
        matches.add(CompatibilityMatch(
          labelKey: "same_region",
          label: L10n.get("same_region"),
          value: currentText.isNotEmpty ? currentText : ownerText,
        ));
      } else {
        differences.add(CompatibilityDifference(
          labelKey: labelKey,
          label: label,
          currentText: currentText.isNotEmpty ? currentText : L10n.get("unknown"),
          ownerText: ownerText.isNotEmpty ? ownerText : L10n.get("unknown"),
        ));
      }
    }

    compare<String>(
      labelKey: "language",
      currentValue: currentProfile.preferredLanguage,
      ownerValue: ownerProfile.preferredLanguage,
      isMatch: (a, b) => a == b,
      formatValue: LanguageDisplayHelper.getLanguageDisplayName,
    );

    compare<int>(
      labelKey: "cleanliness",
      currentValue: currentProfile.cleanliness,
      ownerValue: ownerProfile.cleanliness,
      isMatch: (a, b) => (a - b).abs() <= 1,
      formatValue: _formatCleanlinessLevel,
    );

    compare<int>(
      labelKey: "noise_level",
      currentValue: currentProfile.noiseLevel,
      ownerValue: ownerProfile.noiseLevel,
      isMatch: (a, b) => (a - b).abs() <= 1,
      formatValue: _formatNoiseLevel,
    );

    compare<int>(
      labelKey: "sociability",
      currentValue: currentProfile.sociability,
      ownerValue: ownerProfile.sociability,
      isMatch: (a, b) => (a - b).abs() <= 1,
      formatValue: _formatSociabilityLevel,
    );

    compare<bool>(
      labelKey: "guests_allowed",
      currentValue: currentProfile.guestsAllowed,
      ownerValue: ownerProfile.guestsAllowed,
      isMatch: (a, b) => a == b,
      formatValue: _formatBooleanPreference,
    );

    compare<String>(
      labelKey: "smoking_preference",
      currentValue: currentProfile.smokingPreference,
      ownerValue: ownerProfile.smokingPreference,
      isMatch: (a, b) => a == b,
      formatValue: _formatSmokingPreference,
    );

    compare<String>(
      labelKey: "alcohol_preference",
      currentValue: currentProfile.alcoholPreference,
      ownerValue: ownerProfile.alcoholPreference,
      isMatch: (a, b) => a == b,
      formatValue: _formatAlcoholPreference,
    );

    compare<bool>(
      labelKey: "cooking_habits",
      currentValue: currentProfile.cookingHabits,
      ownerValue: ownerProfile.cookingHabits,
      isMatch: (a, b) => a == b,
      formatValue: _formatCookingHabits,
    );

    compare<String>(
      labelKey: "pets_preference",
      currentValue: currentProfile.petsPreference,
      ownerValue: ownerProfile.petsPreference,
      isMatch: (a, b) => a == b,
      formatValue: _formatPetsPreference,
    );

    compare<String>(
      labelKey: "wakeup_time",
      currentValue: currentProfile.wakeupTime,
      ownerValue: ownerProfile.wakeupTime,
      isMatch: (a, b) => a == b,
      formatValue: _formatDayPreference,
    );

    compare<String>(
      labelKey: "sleep_time",
      currentValue: currentProfile.sleepTime,
      ownerValue: ownerProfile.sleepTime,
      isMatch: (a, b) => a == b,
      formatValue: _formatDayPreference,
    );

    compare<bool>(
      labelKey: "employed",
      currentValue: currentProfile.employed,
      ownerValue: ownerProfile.employed,
      isMatch: (a, b) => a == b,
      formatValue: _formatBooleanPreference,
    );

    // Weighted score (sleep, smoking, drinking, university, hobbies) — not plain field counts.
    final weighted = computeProfileMatchScore(currentProfile, ownerProfile);
    final percent = (weighted * 100).round();
    return CompatibilityResult(
      percent: percent,
      matches: matches,
      differences: differences,
    );
  }

  static String _getLocalizedRegionName(UserProfileRegion region) {
    final lang = LanguageState().currentLanguage;
    switch (lang) {
      case "ru":
        return region.shortNameRu ?? region.nameRu ?? "Unknown";
      case "uz":
        return region.shortNameUz ?? region.nameUz ?? "Unknown";
      case "en":
      default:
        return region.shortNameEn ?? region.nameEn ?? "Unknown";
    }
  }

  static String _formatBooleanPreference(bool value) =>
      L10n.get(value ? "yes" : "no");

  static String _formatCookingHabits(bool value) =>
      L10n.get(value ? "cook" : "dont_cook");

  static String _formatPetsPreference(String value) =>
      localizedPetsPreference(value);

  static String _formatDayPreference(String value) {
    switch (value) {
      case "morning":
      case "evening":
      case "night":
        return L10n.get(value);
      default:
        return value;
    }
  }

  static String _formatSmokingPreference(String value) {
    const map = {
      "non-smoker": "non_smoker",
      "occasional": "occasional_smoker",
      "regular": "regular_smoker",
    };
    final key = map[value];
    return key == null ? value : L10n.get(key);
  }

  static String _formatAlcoholPreference(String value) {
    const map = {
      "non-drinker": "non_drinker",
      "occasional": "occasional_drinker",
      "regular": "regular_drinker",
    };
    final key = map[value];
    return key == null ? value : L10n.get(key);
  }

  static String _formatCleanlinessLevel(int value) {
    const keys = [
      "very_messy", "messy", "average", "clean", "very_clean",
    ];
    final index = (value - 1).clamp(0, keys.length - 1);
    return L10n.get(keys[index]);
  }

  static String _formatNoiseLevel(int value) {
    const keys = [
      "very_quiet", "quiet", "average", "loud", "very_loud",
    ];
    final index = (value - 1).clamp(0, keys.length - 1);
    return L10n.get(keys[index]);
  }

  static String _formatSociabilityLevel(int value) {
    const keys = [
      "very_introverted", "introverted", "balanced",
      "extroverted", "very_extroverted",
    ];
    final index = (value - 1).clamp(0, keys.length - 1);
    return L10n.get(keys[index]);
  }
}

class CompatibilityResult {
  const CompatibilityResult({
    required this.percent,
    required this.matches,
    required this.differences,
  });
  final int? percent;
  final List<CompatibilityMatch> matches;
  final List<CompatibilityDifference> differences;
}
