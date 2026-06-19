import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/pets_preference_strings.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/utils/profile_match_scoring.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// A lifestyle field where every participant agrees.
class GroupCompatibilityFullMatch {
  const GroupCompatibilityFullMatch({
    required this.labelKey,
    required this.label,
    required this.value,
  });

  final String labelKey;
  final String label;
  final String value;
}

/// A lifestyle field where some but not all participants align.
class GroupCompatibilityPartialMatch {
  const GroupCompatibilityPartialMatch({
    required this.labelKey,
    required this.label,
    required this.value,
    required this.agreeCount,
    required this.totalCount,
  });

  final String labelKey;
  final String label;
  final String value;
  final int agreeCount;
  final int totalCount;
}

/// A lifestyle field with meaningful disagreement worth discussing.
class GroupCompatibilityDiscussItem {
  const GroupCompatibilityDiscussItem({
    required this.labelKey,
    required this.label,
    required this.summary,
  });

  final String labelKey;
  final String label;
  final String summary;
}

class GroupCompatibilityResult {
  const GroupCompatibilityResult({
    required this.percent,
    required this.scoredFieldCount,
    required this.totalFieldCount,
    required this.fullMatches,
    required this.partialMatches,
    required this.discussItems,
  });

  final int? percent;
  final int scoredFieldCount;
  final int totalFieldCount;
  final List<GroupCompatibilityFullMatch> fullMatches;
  final List<GroupCompatibilityPartialMatch> partialMatches;
  final List<GroupCompatibilityDiscussItem> discussItems;
}

class _GroupFieldSpec {
  const _GroupFieldSpec({
    required this.labelKey,
    required this.pairScore,
    required this.displayText,
    this.isDealbreakerPair,
  });

  final String labelKey;
  final double? Function(UserProfile a, UserProfile b) pairScore;
  final String? Function(UserProfile profile) displayText;
  final bool Function(UserProfile a, UserProfile b)? isDealbreakerPair;
}

/// Computes multi-member compatibility for `group_forming` listings.
class ListingDetailGroupCompatibilityHelper {
  ListingDetailGroupCompatibilityHelper._();

  static GroupCompatibilityResult calculate(List<UserProfile> participants) {
    if (participants.length < 2) {
      return const GroupCompatibilityResult(
        percent: null,
        scoredFieldCount: 0,
        totalFieldCount: 0,
        fullMatches: [],
        partialMatches: [],
        discussItems: [],
      );
    }

    final fullMatches = <GroupCompatibilityFullMatch>[];
    final partialMatches = <GroupCompatibilityPartialMatch>[];
    final discussItems = <GroupCompatibilityDiscussItem>[];

    final specs = _fieldSpecs();
    var scoredFieldCount = 0;
    const totalFieldCount = 12;

    for (final spec in specs) {
      final analysis = _analyzeField(participants, spec);
      if (analysis == null) continue;
      scoredFieldCount++;

      switch (analysis.category) {
        case _FieldCategory.full:
          fullMatches.add(
            GroupCompatibilityFullMatch(
              labelKey: spec.labelKey,
              label: L10n.get(spec.labelKey),
              value: analysis.displayValue!,
            ),
          );
        case _FieldCategory.partial:
          partialMatches.add(
            GroupCompatibilityPartialMatch(
              labelKey: spec.labelKey,
              label: L10n.get(spec.labelKey),
              value: analysis.displayValue!,
              agreeCount: analysis.largestClusterSize!,
              totalCount: participants.length,
            ),
          );
        case _FieldCategory.discuss:
          discussItems.add(
            GroupCompatibilityDiscussItem(
              labelKey: spec.labelKey,
              label: L10n.get(spec.labelKey),
              summary: analysis.summary!,
            ),
          );
      }
    }

    final percent = _overallPercent(participants);

    return GroupCompatibilityResult(
      percent: percent,
      scoredFieldCount: scoredFieldCount,
      totalFieldCount: totalFieldCount,
      fullMatches: fullMatches,
      partialMatches: partialMatches,
      discussItems: discussItems,
    );
  }

  static int? _overallPercent(List<UserProfile> participants) {
    if (participants.length < 2) return null;

    var pairCount = 0;
    var scoreSum = 0;
    for (var i = 0; i < participants.length; i++) {
      for (var j = i + 1; j < participants.length; j++) {
        final analysis = computeProfileCompatibility(
          participants[i],
          participants[j],
        );
        if (analysis.scoredFieldCount == 0) continue;
        pairCount++;
        scoreSum += analysis.percent;
      }
    }

    if (pairCount == 0) return null;
    return (scoreSum / pairCount).round();
  }

  static List<_GroupFieldSpec> _fieldSpecs() {
    return [
      _GroupFieldSpec(
        labelKey: "wakeup_time",
        pairScore: (a, b) => dayPhaseSlotScore(a.wakeupTime, b.wakeupTime),
        displayText: (p) => _formatDay(p.wakeupTime),
      ),
      _GroupFieldSpec(
        labelKey: "sleep_time",
        pairScore: (a, b) => dayPhaseSlotScore(a.sleepTime, b.sleepTime),
        displayText: (p) => _formatDay(p.sleepTime),
      ),
      _GroupFieldSpec(
        labelKey: "smoking_preference",
        pairScore: (a, b) => smokingCompatibility(
          a.smokingPreference,
          b.smokingPreference,
        )?.score,
        displayText: (p) => _formatSmoking(p.smokingPreference),
        isDealbreakerPair: (a, b) =>
            smokingCompatibility(a.smokingPreference, b.smokingPreference)
                ?.isDealbreaker ==
            true,
      ),
      _GroupFieldSpec(
        labelKey: "pets_preference",
        pairScore: (a, b) =>
            petsCompatibility(a.petsPreference, b.petsPreference)?.score,
        displayText: (p) {
          final pref = p.petsPreference;
          if (pref == null || pref.isEmpty) return null;
          return localizedPetsPreference(pref);
        },
        isDealbreakerPair: (a, b) =>
            petsCompatibility(a.petsPreference, b.petsPreference)?.isDealbreaker ==
            true,
      ),
      _GroupFieldSpec(
        labelKey: "cleanliness",
        pairScore: (a, b) => scaleCompatibility(a.cleanliness, b.cleanliness),
        displayText: (p) => _formatCleanliness(p.cleanliness),
      ),
      _GroupFieldSpec(
        labelKey: "noise_level",
        pairScore: (a, b) => scaleCompatibility(a.noiseLevel, b.noiseLevel),
        displayText: (p) => _formatNoise(p.noiseLevel),
      ),
      _GroupFieldSpec(
        labelKey: "sociability",
        pairScore: (a, b) => scaleCompatibility(a.sociability, b.sociability),
        displayText: (p) => _formatSociability(p.sociability),
      ),
      _GroupFieldSpec(
        labelKey: "alcohol_preference",
        pairScore: (a, b) => preferenceBinaryScore(
          a.alcoholPreference,
          b.alcoholPreference,
        ),
        displayText: (p) => _formatAlcohol(p.alcoholPreference),
      ),
      _GroupFieldSpec(
        labelKey: "guests",
        pairScore: (a, b) =>
            preferenceBinaryScore(a.guestsAllowed, b.guestsAllowed),
        displayText: (p) => _formatBool(p.guestsAllowed),
      ),
      _GroupFieldSpec(
        labelKey: "cooking_habits",
        pairScore: (a, b) =>
            preferenceBinaryScore(a.cookingHabits, b.cookingHabits),
        displayText: (p) => _formatCooking(p.cookingHabits),
      ),
      _GroupFieldSpec(
        labelKey: "language",
        pairScore: (a, b) => preferenceBinaryScore(
          a.preferredLanguage,
          b.preferredLanguage,
        ),
        displayText: (p) {
          final lang = p.preferredLanguage;
          if (lang == null || lang.isEmpty) return null;
          return LanguageDisplayHelper.getLocalizedLanguageName(lang);
        },
      ),
    ];
  }

  static _FieldAnalysis? _analyzeField(
    List<UserProfile> participants,
    _GroupFieldSpec spec,
  ) {
    final active = participants
        .where((p) => spec.displayText(p) != null)
        .toList(growable: false);
    if (active.length < 2) return null;

    final hasDealbreaker = _hasDealbreaker(active, spec);
    final clusters = _buildClusters(active, spec);
    if (clusters.isEmpty) return null;

    final sortedClusters = clusters.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final largest = sortedClusters.first;

    if (hasDealbreaker) {
      return _FieldAnalysis.discuss(
        _clusterSummary(sortedClusters, spec),
      );
    }

    if (sortedClusters.length == 1 && largest.length == active.length) {
      return _FieldAnalysis.full(_dominantDisplay(largest, spec));
    }

    if (largest.length == active.length) {
      return _FieldAnalysis.full(_dominantDisplay(largest, spec));
    }

    if (largest.length >= 2) {
      return _FieldAnalysis.partial(
        _combinedDisplay(sortedClusters, spec),
        largest.length,
      );
    }

    return _FieldAnalysis.discuss(_clusterSummary(sortedClusters, spec));
  }

  static bool _hasDealbreaker(
    List<UserProfile> profiles,
    _GroupFieldSpec spec,
  ) {
    final check = spec.isDealbreakerPair;
    if (check == null) return false;
    for (var i = 0; i < profiles.length; i++) {
      for (var j = i + 1; j < profiles.length; j++) {
        if (check(profiles[i], profiles[j])) return true;
      }
    }
    return false;
  }

  static List<List<UserProfile>> _buildClusters(
    List<UserProfile> profiles,
    _GroupFieldSpec spec,
  ) {
    final clusters = <List<UserProfile>>[];

    bool compatible(UserProfile a, UserProfile b) {
      final score = spec.pairScore(a, b);
      return score != null && score >= 0.75;
    }

    for (final profile in profiles) {
      var placed = false;
      for (final cluster in clusters) {
        if (compatible(profile, cluster.first)) {
          cluster.add(profile);
          placed = true;
          break;
        }
      }
      if (!placed) {
        clusters.add([profile]);
      }
    }

    return clusters;
  }

  static String _dominantDisplay(
    List<UserProfile> cluster,
    _GroupFieldSpec spec,
  ) {
    final counts = <String, int>{};
    for (final profile in cluster) {
      final text = spec.displayText(profile)!;
      counts[text] = (counts[text] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  static String _combinedDisplay(
    List<List<UserProfile>> clusters,
    _GroupFieldSpec spec,
  ) {
    final values = <String>{};
    for (final cluster in clusters) {
      values.add(_dominantDisplay(cluster, spec));
    }
    return values.join(" / ");
  }

  static String _clusterSummary(
    List<List<UserProfile>> clusters,
    _GroupFieldSpec spec,
  ) {
    final parts = <({int count, String text})>[];
    for (final cluster in clusters) {
      parts.add((
        count: cluster.length,
        text: L10n.getWithParams(
          "group_compatibility_value_count",
          params: {
            "count": cluster.length.toString(),
            "value": _dominantDisplay(cluster, spec),
          },
        ),
      ));
    }
    parts.sort((a, b) => b.count.compareTo(a.count));
    return parts.map((p) => p.text).join(" · ");
  }

  static String? _formatDay(String? value) {
    if (value == null) return null;
    switch (value) {
      case "morning":
      case "evening":
      case "night":
        return L10n.get(value);
      default:
        return value;
    }
  }

  static String? _formatSmoking(String? value) {
    if (value == null) return null;
    const map = {
      "non-smoker": "non_smoker",
      "occasional": "occasional_smoker",
      "regular": "regular_smoker",
    };
    final key = map[value];
    return key == null ? value : L10n.get(key);
  }

  static String? _formatAlcohol(String? value) {
    if (value == null) return null;
    const map = {
      "non-drinker": "non_drinker",
      "occasional": "occasional_drinker",
      "regular": "regular_drinker",
    };
    final key = map[value];
    return key == null ? value : L10n.get(key);
  }

  static String? _formatBool(bool? value) {
    if (value == null) return null;
    return L10n.get(value ? "yes" : "no");
  }

  static String? _formatCooking(bool? value) {
    if (value == null) return null;
    return L10n.get(value ? "cook" : "dont_cook");
  }

  static String? _formatCleanliness(int? value) {
    if (value == null) return null;
    const keys = ["very_messy", "messy", "average", "clean", "very_clean"];
    final index = (value - 1).clamp(0, keys.length - 1);
    return L10n.get(keys[index]);
  }

  static String? _formatNoise(int? value) {
    if (value == null) return null;
    const keys = ["very_quiet", "quiet", "average", "loud", "very_loud"];
    final index = (value - 1).clamp(0, keys.length - 1);
    return L10n.get(keys[index]);
  }

  static String? _formatSociability(int? value) {
    if (value == null) return null;
    const keys = [
      "very_introverted",
      "introverted",
      "balanced",
      "extroverted",
      "very_extroverted",
    ];
    final index = (value - 1).clamp(0, keys.length - 1);
    return L10n.get(keys[index]);
  }
}

enum _FieldCategory { full, partial, discuss }

class _FieldAnalysis {
  const _FieldAnalysis._({
    required this.category,
    this.displayValue,
    this.largestClusterSize,
    this.summary,
  });

  factory _FieldAnalysis.full(String displayValue) => _FieldAnalysis._(
        category: _FieldCategory.full,
        displayValue: displayValue,
      );

  factory _FieldAnalysis.partial(String displayValue, int clusterSize) =>
      _FieldAnalysis._(
        category: _FieldCategory.partial,
        displayValue: displayValue,
        largestClusterSize: clusterSize,
      );

  factory _FieldAnalysis.discuss(String summary) => _FieldAnalysis._(
        category: _FieldCategory.discuss,
        summary: summary,
      );

  final _FieldCategory category;
  final String? displayValue;
  final int? largestClusterSize;
  final String? summary;
}
