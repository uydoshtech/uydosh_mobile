import "dart:math" as math;

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

class GroupPreferenceMatrixCell {
  const GroupPreferenceMatrixCell({
    required this.userId,
    required this.value,
    required this.status,
    this.valueIconKey,
  });

  final int userId;
  final String value;
  final GroupPreferenceMatrixCellStatus status;
  final String? valueIconKey;

  @override
  bool operator ==(Object other) {
    return other is GroupPreferenceMatrixCell &&
        other.userId == userId &&
        other.value == value &&
        other.status == status &&
        other.valueIconKey == valueIconKey;
  }

  @override
  int get hashCode => Object.hash(userId, value, status, valueIconKey);
}

enum GroupPreferenceMatrixCellStatus {
  fullMatch,
  partialMatch,
  mismatch,
  conflict,
  missing,
}

class GroupPreferenceMatrixRow {
  const GroupPreferenceMatrixRow({
    required this.labelKey,
    required this.label,
    required this.alignmentSummary,
    required this.cells,
  });

  final String labelKey;
  final String label;
  final String? alignmentSummary;
  final List<GroupPreferenceMatrixCell> cells;

  @override
  bool operator ==(Object other) {
    return other is GroupPreferenceMatrixRow &&
        other.labelKey == labelKey &&
        other.label == label &&
        other.alignmentSummary == alignmentSummary &&
        _listEquals(other.cells, cells);
  }

  @override
  int get hashCode => Object.hash(
        labelKey,
        label,
        alignmentSummary,
        Object.hashAll(cells),
      );
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

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _GroupFieldSpec {
  const _GroupFieldSpec({
    required this.labelKey,
    required this.slug,
    required this.pairScore,
    required this.displayText,
    this.displayIconKey,
    this.isDealbreakerPair,
  });

  final String labelKey;

  /// Matching dimension slug ([UserProfile.dealbreakers]) this field maps to.
  final String slug;
  final double? Function(UserProfile a, UserProfile b) pairScore;
  final String? Function(UserProfile profile) displayText;
  final String? Function(UserProfile profile)? displayIconKey;

  /// Built-in hard conflict for this pair, independent of either user's
  /// configured dealbreaker list (e.g. non-smoker vs regular smoker).
  final bool Function(UserProfile a, UserProfile b)? isDealbreakerPair;
}

/// Computes multi-member compatibility for `group_forming` listings.
class ListingDetailGroupCompatibilityHelper {
  ListingDetailGroupCompatibilityHelper._();

  static List<GroupPreferenceMatrixRow> buildPreferenceMatrix(
    List<UserProfile> participants,
  ) {
    if (participants.length < 3) return const [];

    final specs = _fieldSpecs();
    return specs
        .map(
          (spec) => GroupPreferenceMatrixRow(
            labelKey: spec.labelKey,
            label: L10n.get(spec.labelKey),
            alignmentSummary: _preferenceAlignmentSummary(participants, spec),
            cells: _preferenceMatrixCells(participants, spec),
          ),
        )
        .toList();
  }

  static List<GroupPreferenceMatrixCell> _preferenceMatrixCells(
    List<UserProfile> participants,
    _GroupFieldSpec spec,
  ) {
    final active = participants
        .where((p) => spec.displayText(p) != null)
        .toList(growable: false);
    final clusters = active.length < 2
        ? <List<UserProfile>>[]
        : _buildClusters(active, spec);
    final sortedClusters = clusters.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final largest = sortedClusters.firstOrNull;

    return participants
        .map(
          (profile) => GroupPreferenceMatrixCell(
            userId: profile.userId,
            value: spec.displayText(profile) ?? L10n.get("not_specified"),
            status: _preferenceCellStatus(
              profile: profile,
              displayText: spec.displayText(profile),
              sortedClusters: sortedClusters,
              largestCluster: largest,
              // Only flag the participants actually involved in a conflict,
              // not the whole row, so the matrix points at who disagrees.
              hasDealbreaker: _participantInDealbreaker(profile, active, spec),
            ),
            valueIconKey: spec.displayIconKey?.call(profile),
          ),
        )
        .toList();
  }

  static GroupPreferenceMatrixCellStatus _preferenceCellStatus({
    required UserProfile profile,
    required String? displayText,
    required List<List<UserProfile>> sortedClusters,
    required List<UserProfile>? largestCluster,
    required bool hasDealbreaker,
  }) {
    if (displayText == null) return GroupPreferenceMatrixCellStatus.missing;
    if (hasDealbreaker) return GroupPreferenceMatrixCellStatus.conflict;
    if (largestCluster == null) return GroupPreferenceMatrixCellStatus.missing;

    final isInLargestCluster =
        largestCluster.any((p) => p.userId == profile.userId);
    if (sortedClusters.length == 1) {
      return GroupPreferenceMatrixCellStatus.fullMatch;
    }
    if (largestCluster.length < 2) {
      return GroupPreferenceMatrixCellStatus.conflict;
    }
    return isInLargestCluster
        ? GroupPreferenceMatrixCellStatus.partialMatch
        : GroupPreferenceMatrixCellStatus.mismatch;
  }

  static String? _preferenceAlignmentSummary(
    List<UserProfile> participants,
    _GroupFieldSpec spec,
  ) {
    final active = participants
        .where((p) => spec.displayText(p) != null)
        .toList(growable: false);
    if (active.length < 2) return null;

    final clusters = _buildClusters(active, spec);
    if (clusters.isEmpty) return null;

    final sortedClusters = clusters.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final largest = sortedClusters.first;
    final countPrefix = "${largest.length}/${participants.length}";

    if (sortedClusters.length == 1 && largest.length == active.length) {
      return "$countPrefix · ${_dominantDisplay(largest, spec)}";
    }

    return "$countPrefix · ${_clusterSummary(sortedClusters, spec)}";
  }

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
    var hasDealbreaker = false;
    for (var i = 0; i < participants.length; i++) {
      for (var j = i + 1; j < participants.length; j++) {
        final analysis = computeProfileCompatibility(
          participants[i],
          participants[j],
        );
        if (analysis.scoredFieldCount == 0) continue;
        pairCount++;
        scoreSum += analysis.percent;
        if (analysis.hasDealbreaker) hasDealbreaker = true;
      }
    }

    if (pairCount == 0) return null;
    final average = (scoreSum / pairCount).round();
    // A single irreconcilable pair makes the whole group a hard match: cap the
    // overall at the dealbreaker ceiling so averaging can't hide the conflict.
    if (hasDealbreaker) {
      return math.min(average, (profileMatchDealbreakerCap * 100).round());
    }
    return average;
  }

  static List<_GroupFieldSpec> _fieldSpecs() {
    return [
      _GroupFieldSpec(
        labelKey: "wakeup_time",
        slug: ProfileMatchDimension.sleep,
        pairScore: (a, b) => dayPhaseSlotScore(a.wakeupTime, b.wakeupTime),
        displayText: (p) => _formatDay(p.wakeupTime),
        displayIconKey: (p) => _dayIconKey(p.wakeupTime),
      ),
      _GroupFieldSpec(
        labelKey: "sleep_time",
        slug: ProfileMatchDimension.sleep,
        pairScore: (a, b) => dayPhaseSlotScore(a.sleepTime, b.sleepTime),
        displayText: (p) => _formatDay(p.sleepTime),
        displayIconKey: (p) => _dayIconKey(p.sleepTime),
      ),
      _GroupFieldSpec(
        labelKey: "smoking_preference",
        slug: ProfileMatchDimension.smoking,
        pairScore: (a, b) => smokingCompatibility(
          a.smokingPreference,
          b.smokingPreference,
        )?.score,
        displayText: (p) => _formatSmoking(p.smokingPreference),
        isDealbreakerPair: (a, b) =>
            smokingCompatibility(a.smokingPreference, b.smokingPreference)
                ?.isDealbreaker ==
            true,
        displayIconKey: (p) => _slugIconKey(
          "smoking",
          p.smokingPreference,
        ),
      ),
      // Keep alcohol next to smoking — they're the two substance-use
      // preferences and read better as an adjacent pair.
      _GroupFieldSpec(
        labelKey: "alcohol_preference",
        slug: ProfileMatchDimension.drinking,
        pairScore: (a, b) => preferenceBinaryScore(
          a.alcoholPreference,
          b.alcoholPreference,
        ),
        displayText: (p) => _formatAlcohol(p.alcoholPreference),
        displayIconKey: (p) => _slugIconKey(
          "alcohol",
          p.alcoholPreference,
        ),
      ),
      _GroupFieldSpec(
        labelKey: "cleanliness",
        slug: ProfileMatchDimension.cleanliness,
        pairScore: (a, b) => scaleCompatibility(a.cleanliness, b.cleanliness),
        displayText: (p) => _formatCleanliness(p.cleanliness),
        displayIconKey: (p) => _scaleIconKey("cleanliness", p.cleanliness),
      ),
      _GroupFieldSpec(
        labelKey: "noise_level",
        slug: ProfileMatchDimension.noise,
        pairScore: (a, b) => scaleCompatibility(a.noiseLevel, b.noiseLevel),
        displayText: (p) => _formatNoise(p.noiseLevel),
        displayIconKey: (p) => _scaleIconKey("noise", p.noiseLevel),
      ),
      _GroupFieldSpec(
        labelKey: "sociability",
        slug: ProfileMatchDimension.sociability,
        pairScore: (a, b) => scaleCompatibility(a.sociability, b.sociability),
        displayText: (p) => _formatSociability(p.sociability),
        displayIconKey: (p) => _scaleIconKey("sociability", p.sociability),
      ),
      _GroupFieldSpec(
        labelKey: "guests",
        slug: ProfileMatchDimension.guests,
        pairScore: (a, b) =>
            preferenceBinaryScore(a.guestsAllowed, b.guestsAllowed),
        displayText: (p) => _formatBool(p.guestsAllowed),
        displayIconKey: (p) => _boolIconKey("guests", p.guestsAllowed),
      ),
      _GroupFieldSpec(
        labelKey: "cooking_habits",
        slug: ProfileMatchDimension.cooking,
        pairScore: (a, b) =>
            preferenceBinaryScore(a.cookingHabits, b.cookingHabits),
        displayText: (p) => _formatCooking(p.cookingHabits),
        displayIconKey: (p) => _boolIconKey("cooking", p.cookingHabits),
      ),
      _GroupFieldSpec(
        labelKey: "language",
        slug: ProfileMatchDimension.language,
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
      // Pets compatibility sits last in the matrix by request.
      _GroupFieldSpec(
        labelKey: "pets_preference",
        slug: ProfileMatchDimension.pets,
        pairScore: (a, b) =>
            petsCompatibility(a.petsPreference, b.petsPreference)?.score,
        displayText: (p) {
          final pref = p.petsPreference;
          if (pref == null || pref.isEmpty) return null;
          return localizedPetsPreference(pref);
        },
        isDealbreakerPair: (a, b) =>
            petsCompatibility(a.petsPreference, b.petsPreference)
                ?.isDealbreaker ==
            true,
        displayIconKey: (p) => _slugIconKey("pets", p.petsPreference),
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
    for (var i = 0; i < profiles.length; i++) {
      for (var j = i + 1; j < profiles.length; j++) {
        if (_isPairDealbreaker(profiles[i], profiles[j], spec)) return true;
      }
    }
    return false;
  }

  /// Whether [profile] is in a dealbreaker conflict with any other active
  /// participant on this dimension.
  static bool _participantInDealbreaker(
    UserProfile profile,
    List<UserProfile> active,
    _GroupFieldSpec spec,
  ) {
    for (final other in active) {
      if (other.userId == profile.userId) continue;
      if (_isPairDealbreaker(profile, other, spec)) return true;
    }
    return false;
  }

  /// A pair conflicts on [spec] when there is a built-in hard conflict, or when
  /// either user lists this dimension as a dealbreaker and the pair score falls
  /// below [profileMatchDealbreakerConflictThreshold]. Mirrors the per-field
  /// dealbreaker logic in `computeProfileCompatibility`.
  static bool _isPairDealbreaker(
    UserProfile a,
    UserProfile b,
    _GroupFieldSpec spec,
  ) {
    if (spec.isDealbreakerPair?.call(a, b) == true) return true;

    final listed = _dealbreakerSlugs(a).contains(spec.slug) ||
        _dealbreakerSlugs(b).contains(spec.slug);
    if (!listed) return false;

    final score = spec.pairScore(a, b);
    return score != null &&
        score < profileMatchDealbreakerConflictThreshold;
  }

  static Set<String> _dealbreakerSlugs(UserProfile profile) {
    final raw = profile.dealbreakers;
    if (raw == null || raw.isEmpty) return const {};
    return raw
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
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

  static String? _dayIconKey(String? value) {
    if (value == null) return null;
    switch (value) {
      case "morning":
      case "evening":
      case "night":
        return "day:$value";
      default:
        return null;
    }
  }

  static String? _slugIconKey(String prefix, String? value) {
    if (value == null || value.isEmpty) return null;
    return "$prefix:$value";
  }

  static String? _boolIconKey(String prefix, bool? value) {
    if (value == null) return null;
    return "$prefix:${value ? "yes" : "no"}";
  }

  static String? _scaleIconKey(String prefix, int? value) {
    if (value == null) return null;
    return "$prefix:${value.clamp(1, 5)}";
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
