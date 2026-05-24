import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/pets_preference_strings.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/utils/profile_match_scoring.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_compatibility_section.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Computes compatibility between current user and listing owner.
/// Uses [computeProfileCompatibility] as the single scoring source of truth.
class ListingDetailCompatibilityHelper {
  ListingDetailCompatibilityHelper._();

  static CompatibilityResult calculate(
    UserProfile currentProfile,
    UserProfile ownerProfile,
  ) {
    final analysis = computeProfileCompatibility(currentProfile, ownerProfile);
    final matches = <CompatibilityMatch>[];
    final differences = <CompatibilityDifference>[];
    final dealbreakers = <CompatibilityDifference>[];

    void addMatch(String labelKey, String label, String value) {
      matches.add(CompatibilityMatch(
        labelKey: labelKey,
        label: label,
        value: value,
      ));
    }

    void addDifference(String labelKey, String label, String currentText,
        String ownerText,) {
      differences.add(CompatibilityDifference(
        labelKey: labelKey,
        label: label,
        currentText: currentText,
        ownerText: ownerText,
      ));
    }

    void addDealbreaker(String labelKey, String label, String currentText,
        String ownerText,) {
      dealbreakers.add(CompatibilityDifference(
        labelKey: labelKey,
        label: label,
        currentText: currentText,
        ownerText: ownerText,
      ));
    }

    for (final field in analysis.fields) {
      switch (field.labelKey) {
        case "sleep_schedule":
          _addSleepRows(
            currentProfile,
            ownerProfile,
            addMatch,
            addDifference,
          );
        case "university":
          _addUniversityRow(
            currentProfile,
            ownerProfile,
            field.status,
            addMatch,
            addDifference,
            addDealbreaker,
          );
        case "region":
          _addRegionRow(
            currentProfile,
            ownerProfile,
            field.status,
            addMatch,
            addDifference,
            addDealbreaker,
          );
        default:
          _addStandardRow(
            currentProfile,
            ownerProfile,
            field,
            addMatch,
            addDifference,
            addDealbreaker,
          );
      }
    }

    return CompatibilityResult(
      percent: analysis.scoredFieldCount == 0 ? null : analysis.percent,
      scoredFieldCount: analysis.scoredFieldCount,
      totalFieldCount: analysis.totalFieldCount,
      matches: matches,
      differences: differences,
      dealbreakers: dealbreakers,
      hasDealbreaker: analysis.hasDealbreaker,
    );
  }

  static void _addSleepRows(
    UserProfile current,
    UserProfile owner,
    void Function(String, String, String) addMatch,
    void Function(String, String, String, String) addDifference,
  ) {
    void compareSlot(String labelKey, String? a, String? b) {
      if (a == null || b == null) return;
      final label = L10n.get(labelKey);
      final currentText = _formatDayPreference(a);
      final ownerText = _formatDayPreference(b);
      final slotScore = dayPhaseSlotScore(a, b);
      final isMatch = slotScore != null && slotScore >= 0.75;
      if (isMatch) {
        addMatch(labelKey, label, currentText);
      } else {
        addDifference(labelKey, label, currentText, ownerText);
      }
    }

    compareSlot("wakeup_time", current.wakeupTime, owner.wakeupTime);
    compareSlot("sleep_time", current.sleepTime, owner.sleepTime);
  }

  static void _addUniversityRow(
    UserProfile current,
    UserProfile owner,
    ProfileMatchFieldStatus status,
    void Function(String, String, String) addMatch,
    void Function(String, String, String, String) addDifference,
    void Function(String, String, String, String) addDealbreaker,
  ) {
    if (current.universityId == null || owner.universityId == null) return;

    final currentLang = LanguageState().currentLanguage;
    final currentText = current.university != null
        ? current.university!.getLocalizedNameCapitalized(currentLang)
        : "";
    final ownerText = owner.university != null
        ? owner.university!.getLocalizedNameCapitalized(currentLang)
        : "";

    if (current.universityId == owner.universityId) {
      addMatch(
        "same_university",
        L10n.get("same_university"),
        currentText.isNotEmpty ? currentText : ownerText,
      );
    } else if (status == ProfileMatchFieldStatus.match ||
        status == ProfileMatchFieldStatus.difference) {
      addMatch(
        "both_students",
        L10n.get("both_students"),
        "$currentText ↔ $ownerText",
      );
    }
  }

  static void _addRegionRow(
    UserProfile current,
    UserProfile owner,
    ProfileMatchFieldStatus status,
    void Function(String, String, String) addMatch,
    void Function(String, String, String, String) addDifference,
    void Function(String, String, String, String) addDealbreaker,
  ) {
    if (current.regionId == null || owner.regionId == null) return;

    final currentText = current.region != null
        ? _getLocalizedRegionName(current.region!)
        : "";
    final ownerText =
        owner.region != null ? _getLocalizedRegionName(owner.region!) : "";

    if (status == ProfileMatchFieldStatus.match) {
      addMatch(
        "same_region",
        L10n.get("same_region"),
        currentText.isNotEmpty ? currentText : ownerText,
      );
    } else if (status == ProfileMatchFieldStatus.dealbreaker) {
      addDealbreaker(
        "region",
        L10n.get("region"),
        currentText.isNotEmpty ? currentText : L10n.get("unknown"),
        ownerText.isNotEmpty ? ownerText : L10n.get("unknown"),
      );
    } else {
      addDifference(
        "region",
        L10n.get("region"),
        currentText.isNotEmpty ? currentText : L10n.get("unknown"),
        ownerText.isNotEmpty ? ownerText : L10n.get("unknown"),
      );
    }
  }

  static void _addStandardRow(
    UserProfile current,
    UserProfile owner,
    ProfileMatchFieldResult field,
    void Function(String, String, String) addMatch,
    void Function(String, String, String, String) addDifference,
    void Function(String, String, String, String) addDealbreaker,
  ) {
    if (field.status == ProfileMatchFieldStatus.incomplete) return;

    final labelKey = field.labelKey;
    final label = L10n.get(labelKey);
    final currentText = _formatField(current, labelKey);
    final ownerText = _formatField(owner, labelKey);

    switch (field.status) {
      case ProfileMatchFieldStatus.match:
        addMatch(labelKey, label, currentText);
      case ProfileMatchFieldStatus.dealbreaker:
        addDealbreaker(labelKey, label, currentText, ownerText);
      case ProfileMatchFieldStatus.difference:
        addDifference(labelKey, label, currentText, ownerText);
      case ProfileMatchFieldStatus.incomplete:
        break;
    }
  }

  static String _formatField(UserProfile profile, String labelKey) {
    switch (labelKey) {
      case "language":
        return LanguageDisplayHelper.getLocalizedLanguageName(
          profile.preferredLanguage ?? "",
        );
      case "cleanliness":
        return _formatCleanlinessLevel(profile.cleanliness ?? 1);
      case "noise_level":
        return _formatNoiseLevel(profile.noiseLevel ?? 1);
      case "sociability":
        return _formatSociabilityLevel(profile.sociability ?? 1);
      case "guests":
        return _formatBooleanPreference(profile.guestsAllowed ?? false);
      case "smoking_preference":
        return _formatSmokingPreference(profile.smokingPreference ?? "");
      case "alcohol_preference":
        return _formatAlcoholPreference(profile.alcoholPreference ?? "");
      case "cooking_habits":
        return _formatCookingHabits(profile.cookingHabits ?? false);
      case "pets_preference":
        return _formatPetsPreference(profile.petsPreference ?? "");
      default:
        return "";
    }
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
    required this.scoredFieldCount,
    required this.totalFieldCount,
    required this.matches,
    required this.differences,
    required this.dealbreakers,
    required this.hasDealbreaker,
  });

  final int? percent;
  final int scoredFieldCount;
  final int totalFieldCount;
  final List<CompatibilityMatch> matches;
  final List<CompatibilityDifference> differences;
  final List<CompatibilityDifference> dealbreakers;
  final bool hasDealbreaker;
}
