import "dart:math" as math;

import "package:uy_dosh/domain/models/user_profile.dart";

/// Base weights for profile compatibility dimensions. The "self vs self"
/// lifestyle dims sum to ~1.0; the "what I'm looking for" dims
/// ([roommateGender], [age], [budget]) only contribute when the viewer has
/// filled those preferences, so they never penalize legacy profiles.
class ProfileMatchWeights {
  ProfileMatchWeights._();

  static const double sleepSchedule = 0.18;
  static const double smoking = 0.18;
  static const double pets = 0.10;
  static const double cleanliness = 0.10;
  static const double noiseLevel = 0.10;
  static const double sociability = 0.08;
  static const double drinking = 0.08;
  static const double university = 0.08;
  static const double guests = 0.05;
  static const double cooking = 0.03;
  static const double region = 0.01;
  static const double language = 0.01;

  // "What I'm looking for" dimensions (opt-in; excluded when unset).
  static const double roommateGender = 0.12;
  static const double age = 0.06;
  static const double budget = 0.10;
}

/// Multiplier applied to a dimension's weight when the viewer flags it as a
/// top priority (see [UserProfile.topPriorities]).
const double profileMatchPriorityBoost = 2.0;

/// Max overall score when a dealbreaker dimension conflicts. Dealbreakers are
/// the built-in smoking/pets conflicts plus any dimension the viewer lists in
/// [UserProfile.dealbreakers], plus a specific gender mismatch and a required
/// budget overlap that is not met.
const double profileMatchDealbreakerCap = 0.35;

/// Dimension slugs persisted in [UserProfile.dealbreakers] /
/// [UserProfile.topPriorities], mapped to their breakdown [labelKey].
class ProfileMatchDimension {
  ProfileMatchDimension._();

  static const String sleep = "sleep";
  static const String smoking = "smoking";
  static const String pets = "pets";
  static const String cleanliness = "cleanliness";
  static const String noise = "noise";
  static const String sociability = "sociability";
  static const String drinking = "drinking";
  static const String university = "university";
  static const String guests = "guests";
  static const String cooking = "cooking";
  static const String region = "region";
  static const String language = "language";
  static const String gender = "gender";
  static const String age = "age";
  static const String budget = "budget";

  /// All slugs accepted by the edit UI / backend allow-list.
  static const List<String> all = [
    sleep,
    smoking,
    pets,
    cleanliness,
    noise,
    sociability,
    drinking,
    university,
    guests,
    cooking,
    region,
    language,
    gender,
    age,
    budget,
  ];

  /// Slugs sensible to expose as dealbreakers in the UI.
  static const List<String> selectableDealbreakers = [
    smoking,
    pets,
    cleanliness,
    noise,
    gender,
    age,
    budget,
    sleep,
  ];

  /// Slugs sensible to expose as top priorities in the UI.
  static const List<String> selectablePriorities = [
    sleep,
    smoking,
    pets,
    cleanliness,
    noise,
    sociability,
    drinking,
    gender,
    age,
    budget,
  ];
}

/// Below this per-dimension score a viewer-listed dealbreaker triggers a cap.
const double _dealbreakerConflictThreshold = 0.5;

enum ProfileMatchFieldStatus {
  /// Both sides filled and aligned (includes soft matches like ±1 scale).
  match,

  /// Both sides filled but misaligned.
  difference,

  /// Hard lifestyle conflict (smoking, pets).
  dealbreaker,

  /// At least one side missing — excluded from score denominator.
  incomplete,
}

class ProfileMatchFieldResult {
  const ProfileMatchFieldResult({
    required this.labelKey,
    required this.weight,
    required this.status,
    this.partialScore,
    this.isDealbreaker = false,
  });

  final String labelKey;
  final double weight;

  /// 0–1 when [status] is not [ProfileMatchFieldStatus.incomplete].
  final double? partialScore;
  final ProfileMatchFieldStatus status;
  final bool isDealbreaker;

  bool get countsTowardScore =>
      status != ProfileMatchFieldStatus.incomplete && partialScore != null;
}

class ProfileCompatibilityScore {
  const ProfileCompatibilityScore({
    required this.score,
    required this.percent,
    required this.scoredFieldCount,
    required this.totalFieldCount,
    required this.fields,
    required this.hasDealbreaker,
  });

  /// Normalized 0–1 score after dealbreaker cap.
  final double score;
  final int percent;
  final int scoredFieldCount;
  final int totalFieldCount;
  final List<ProfileMatchFieldResult> fields;
  final bool hasDealbreaker;
}

/// Unified profile compatibility. Asymmetric: each side's own dealbreakers,
/// priorities and "what I'm looking for" preferences are applied to the other.
/// The breakdown [fields] are from [a]'s perspective (the viewing user); the
/// numeric score is `min(a→b, b→a)` so either party's dealbreaker tanks it.
ProfileCompatibilityScore computeProfileCompatibility(
  UserProfile a,
  UserProfile b,
) {
  final forward = _directionalAnalysis(a, b);
  final reverse = _directionalAnalysis(b, a);

  final hasDealbreaker = forward.hasDealbreaker || reverse.hasDealbreaker;

  var score = math.min(forward.rawScore, reverse.rawScore);
  if (hasDealbreaker) {
    score = score.clamp(0.0, profileMatchDealbreakerCap);
  }

  return ProfileCompatibilityScore(
    score: score,
    percent: (score * 100).round(),
    scoredFieldCount: forward.scoredFieldCount,
    totalFieldCount: forward.totalFieldCount,
    fields: forward.fields,
    hasDealbreaker: hasDealbreaker,
  );
}

/// Result of scoring a candidate from one viewer's perspective (before the
/// cross-direction `min` and dealbreaker cap are applied).
class _DirectionalAnalysis {
  const _DirectionalAnalysis({
    required this.rawScore,
    required this.fields,
    required this.scoredFieldCount,
    required this.totalFieldCount,
    required this.hasDealbreaker,
  });

  final double rawScore;
  final List<ProfileMatchFieldResult> fields;
  final int scoredFieldCount;
  final int totalFieldCount;
  final bool hasDealbreaker;
}

/// Viewer-specific matching context: which dimensions are dealbreakers and
/// which are top priorities (weight-boosted).
class _MatchContext {
  _MatchContext(UserProfile viewer)
      : dealbreakers = _slugSet(viewer.dealbreakers),
        priorities = _slugSet(viewer.topPriorities);

  final Set<String> dealbreakers;
  final Set<String> priorities;

  static Set<String> _slugSet(List<String>? raw) {
    if (raw == null) return const {};
    return raw
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
  }
}

/// Scores [candidate] from [viewer]'s perspective (viewer's prefs apply).
_DirectionalAnalysis _directionalAnalysis(
  UserProfile viewer,
  UserProfile candidate,
) {
  final ctx = _MatchContext(viewer);

  final fields = <ProfileMatchFieldResult>[
    _sleepField(viewer, candidate, ctx),
    _smokingField(viewer, candidate, ctx),
    _petsField(viewer, candidate, ctx),
    _cleanlinessField(viewer, candidate, ctx),
    _noiseField(viewer, candidate, ctx),
    _sociabilityField(viewer, candidate, ctx),
    _drinkingField(viewer, candidate, ctx),
    _universityField(viewer, candidate, ctx),
    _guestsField(viewer, candidate, ctx),
    _cookingField(viewer, candidate, ctx),
    _regionField(viewer, candidate, ctx),
    _languageField(viewer, candidate, ctx),
    _roommateGenderField(viewer, candidate, ctx),
    _ageField(viewer, candidate, ctx),
    _budgetField(viewer, candidate, ctx),
  ];

  final scored = fields.where((f) => f.countsTowardScore).toList();
  final hasDealbreaker = fields.any((f) => f.isDealbreaker);

  double rawScore;
  if (scored.isEmpty) {
    rawScore = 0.0;
  } else {
    final weightSum = scored.fold<double>(0, (sum, f) => sum + f.weight);
    final weighted = scored.fold<double>(
      0,
      (sum, f) => sum + f.weight * f.partialScore!,
    );
    rawScore = weightSum == 0 ? 0.0 : (weighted / weightSum).clamp(0.0, 1.0);
  }

  return _DirectionalAnalysis(
    rawScore: rawScore,
    fields: fields,
    scoredFieldCount: scored.length,
    totalFieldCount: fields.length,
    hasDealbreaker: hasDealbreaker,
  );
}

double _weightFor(String slug, double baseWeight, _MatchContext ctx) =>
    ctx.priorities.contains(slug)
        ? baseWeight * profileMatchPriorityBoost
        : baseWeight;

/// Builds a field result, applying the viewer's dealbreaker list and priority
/// weight boost on top of a pre-computed [partial] score.
ProfileMatchFieldResult _finalizeField({
  required String labelKey,
  required String slug,
  required double baseWeight,
  required double? partial,
  required _MatchContext ctx,
  bool builtInDealbreaker = false,
  bool forceDealbreaker = false,
}) {
  final weight = _weightFor(slug, baseWeight, ctx);
  if (partial == null) {
    return ProfileMatchFieldResult(
      labelKey: labelKey,
      weight: weight,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  final listedDealbreaker = ctx.dealbreakers.contains(slug) &&
      partial < _dealbreakerConflictThreshold;
  final isDealbreaker =
      builtInDealbreaker || forceDealbreaker || listedDealbreaker;
  return ProfileMatchFieldResult(
    labelKey: labelKey,
    weight: weight,
    partialScore: partial,
    status: isDealbreaker
        ? ProfileMatchFieldStatus.dealbreaker
        : partial >= 0.75
            ? ProfileMatchFieldStatus.match
            : ProfileMatchFieldStatus.difference,
    isDealbreaker: isDealbreaker,
  );
}

ProfileMatchFieldResult _sleepField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "sleep_schedule",
      slug: ProfileMatchDimension.sleep,
      baseWeight: ProfileMatchWeights.sleepSchedule,
      partial: sleepScheduleCompatibility(
        v.sleepTime,
        v.wakeupTime,
        c.sleepTime,
        c.wakeupTime,
      ),
      ctx: ctx,
    );

ProfileMatchFieldResult _smokingField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) {
  final result = smokingCompatibility(v.smokingPreference, c.smokingPreference);
  return _finalizeField(
    labelKey: "smoking_preference",
    slug: ProfileMatchDimension.smoking,
    baseWeight: ProfileMatchWeights.smoking,
    partial: result?.score,
    ctx: ctx,
    builtInDealbreaker: result?.isDealbreaker ?? false,
  );
}

ProfileMatchFieldResult _petsField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) {
  final result = petsCompatibility(v.petsPreference, c.petsPreference);
  return _finalizeField(
    labelKey: "pets_preference",
    slug: ProfileMatchDimension.pets,
    baseWeight: ProfileMatchWeights.pets,
    partial: result?.score,
    ctx: ctx,
    builtInDealbreaker: result?.isDealbreaker ?? false,
  );
}

ProfileMatchFieldResult _cleanlinessField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "cleanliness",
      slug: ProfileMatchDimension.cleanliness,
      baseWeight: ProfileMatchWeights.cleanliness,
      partial: scaleCompatibility(v.cleanliness, c.cleanliness),
      ctx: ctx,
    );

ProfileMatchFieldResult _noiseField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "noise_level",
      slug: ProfileMatchDimension.noise,
      baseWeight: ProfileMatchWeights.noiseLevel,
      partial: scaleCompatibility(v.noiseLevel, c.noiseLevel),
      ctx: ctx,
    );

ProfileMatchFieldResult _sociabilityField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "sociability",
      slug: ProfileMatchDimension.sociability,
      baseWeight: ProfileMatchWeights.sociability,
      partial: scaleCompatibility(v.sociability, c.sociability),
      ctx: ctx,
    );

ProfileMatchFieldResult _drinkingField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "alcohol_preference",
      slug: ProfileMatchDimension.drinking,
      baseWeight: ProfileMatchWeights.drinking,
      partial: preferenceBinaryScore(v.alcoholPreference, c.alcoholPreference),
      ctx: ctx,
    );

ProfileMatchFieldResult _universityField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "university",
      slug: ProfileMatchDimension.university,
      baseWeight: ProfileMatchWeights.university,
      partial: universityScore(v.universityId, c.universityId),
      ctx: ctx,
    );

ProfileMatchFieldResult _guestsField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "guests",
      slug: ProfileMatchDimension.guests,
      baseWeight: ProfileMatchWeights.guests,
      partial: preferenceBinaryScore(v.guestsAllowed, c.guestsAllowed),
      ctx: ctx,
    );

ProfileMatchFieldResult _cookingField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "cooking_habits",
      slug: ProfileMatchDimension.cooking,
      baseWeight: ProfileMatchWeights.cooking,
      partial: preferenceBinaryScore(v.cookingHabits, c.cookingHabits),
      ctx: ctx,
    );

ProfileMatchFieldResult _regionField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "region",
      slug: ProfileMatchDimension.region,
      baseWeight: ProfileMatchWeights.region,
      partial: preferenceBinaryScore(v.regionId, c.regionId),
      ctx: ctx,
    );

ProfileMatchFieldResult _languageField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "language",
      slug: ProfileMatchDimension.language,
      baseWeight: ProfileMatchWeights.language,
      partial: preferenceBinaryScore(v.preferredLanguage, c.preferredLanguage),
      ctx: ctx,
    );

ProfileMatchFieldResult _roommateGenderField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) {
  final partial = roommateGenderScore(v.prefRoommateGender, c.gender);
  // A specific gender preference that is not met is always a hard filter.
  final specificMismatch = partial != null && partial == 0.0;
  return _finalizeField(
    labelKey: "roommate_gender",
    slug: ProfileMatchDimension.gender,
    baseWeight: ProfileMatchWeights.roommateGender,
    partial: partial,
    ctx: ctx,
    forceDealbreaker: specificMismatch,
  );
}

ProfileMatchFieldResult _ageField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) =>
    _finalizeField(
      labelKey: "age",
      slug: ProfileMatchDimension.age,
      baseWeight: ProfileMatchWeights.age,
      partial: ageRangeScore(v.prefAgeMin, v.prefAgeMax, c.birthYear),
      ctx: ctx,
    );

ProfileMatchFieldResult _budgetField(
  UserProfile v,
  UserProfile c,
  _MatchContext ctx,
) {
  final partial = budgetOverlapScore(
    v.budgetMin,
    v.budgetMax,
    c.budgetMin,
    c.budgetMax,
  );
  final overlapRequiredMiss =
      (v.prefBudgetOverlapRequired ?? false) && partial != null && partial < 1.0;
  return _finalizeField(
    labelKey: "budget",
    slug: ProfileMatchDimension.budget,
    baseWeight: ProfileMatchWeights.budget,
    partial: partial,
    ctx: ctx,
    forceDealbreaker: overlapRequiredMiss,
  );
}

class GradedCompatibility {
  const GradedCompatibility({required this.score, this.isDealbreaker = false});

  final double score;
  final bool isDealbreaker;
}

/// \[0, 1\] from [sleepTime] + [wakeupTime]. Returns null when both slots lack data.
double? sleepScheduleCompatibility(
  String? sleepA,
  String? wakeA,
  String? sleepB,
  String? wakeB,
) {
  final sleepSlot = dayPhaseSlotScore(sleepA, sleepB);
  final wakeSlot = dayPhaseSlotScore(wakeA, wakeB);
  if (sleepSlot == null && wakeSlot == null) return null;
  if (sleepSlot == null) return wakeSlot;
  if (wakeSlot == null) return sleepSlot;
  return (sleepSlot + wakeSlot) / 2.0;
}

/// Public for UI breakdown rows (wake / sleep shown separately).
double? dayPhaseSlotScore(String? x, String? y) {
  if (x == null || y == null) return null;
  final ox = _dayPhaseOrder(x);
  final oy = _dayPhaseOrder(y);
  if (ox != null && oy != null) {
    final dist = (ox - oy).abs();
    return 1.0 - (dist / 2.0).clamp(0.0, 1.0);
  }
  return x == y ? 1.0 : 0.0;
}

int? _dayPhaseOrder(String value) {
  switch (value) {
    case "morning":
      return 0;
    case "evening":
      return 1;
    case "night":
      return 2;
    default:
      return null;
  }
}

/// Same as `a == b ? 1 : 0` when both set; null when either side missing.
double? preferenceBinaryScore<T>(T? a, T? b) {
  if (a == null || b == null) return null;
  return a == b ? 1.0 : 0.0;
}

/// Same university = 1.0; both students at different schools = 0.55.
double? universityScore(int? a, int? b) {
  if (a == null || b == null) return null;
  if (a == b) return 1.0;
  return 0.55;
}

/// 1–5 scale: exact = 1.0, ±1 = 0.75, ±2 = 0.35, farther = 0.0.
double? scaleCompatibility(int? a, int? b, {int tolerance = 1}) {
  if (a == null || b == null) return null;
  final dist = (a - b).abs();
  if (dist == 0) return 1.0;
  if (dist <= tolerance) return 0.75;
  if (dist == tolerance + 1) return 0.35;
  return 0.0;
}

/// Viewer's desired roommate gender ('any'|'male'|'female') vs a candidate's
/// [UserProfile.gender] (1 = male, 2 = female). Null when the viewer has no
/// preference, or the candidate's gender is unknown for a specific preference.
double? roommateGenderScore(String? pref, int? candidateGender) {
  if (pref == null || pref.trim().isEmpty) return null;
  final p = pref.trim().toLowerCase();
  if (p == "any") return 1.0;
  if (candidateGender == null) return null;
  if (p == "male") return candidateGender == 1 ? 1.0 : 0.0;
  if (p == "female") return candidateGender == 2 ? 1.0 : 0.0;
  return null;
}

/// Candidate age (from [birthYear]) against the viewer's desired range.
/// In range = 1.0, within 2 yrs = 0.5, within 4 yrs = 0.25, else 0.0.
/// Null when the viewer set no range, or the candidate has no birth year.
double? ageRangeScore(int? prefMin, int? prefMax, int? birthYear, {int? nowYear}) {
  if (prefMin == null && prefMax == null) return null;
  if (birthYear == null) return null;
  final year = nowYear ?? DateTime.now().year;
  final age = year - birthYear;
  if (age < 0 || age > 120) return null;
  final lo = prefMin ?? 0;
  final hi = prefMax ?? 200;
  if (age >= lo && age <= hi) return 1.0;
  final dist = age < lo ? lo - age : age - hi;
  if (dist <= 2) return 0.5;
  if (dist <= 4) return 0.25;
  return 0.0;
}

/// Overlap of two monthly-budget ranges. Full overlap = 1.0, a near miss
/// (gap within 15% of the larger budget) = 0.5, otherwise 0.0. Null when
/// either side provided no budget at all. Missing bounds default to an open
/// end (no minimum = 0, no maximum = unbounded).
double? budgetOverlapScore(int? aMin, int? aMax, int? bMin, int? bMax) {
  final aHasAny = aMin != null || aMax != null;
  final bHasAny = bMin != null || bMax != null;
  if (!aHasAny || !bHasAny) return null;

  final aLo = (aMin ?? 0).toDouble();
  final double aHi = aMax?.toDouble() ?? double.infinity;
  final bLo = (bMin ?? 0).toDouble();
  final double bHi = bMax?.toDouble() ?? double.infinity;

  final overlapLo = math.max(aLo, bLo);
  final overlapHi = math.min(aHi, bHi);
  if (overlapLo <= overlapHi) return 1.0;

  final gap = overlapLo - overlapHi;
  final finiteRefs = <double>[
    if (aHi.isFinite) aHi,
    if (bHi.isFinite) bHi,
    aLo,
    bLo,
  ];
  final ref = finiteRefs.fold<double>(0, math.max);
  if (ref <= 0) return 0.0;
  return gap <= ref * 0.15 ? 0.5 : 0.0;
}

GradedCompatibility? smokingCompatibility(String? a, String? b) {
  if (a == null || b == null) return null;
  if (a == b) return const GradedCompatibility(score: 1.0);

  const nonSmoker = "non-smoker";
  const occasional = "occasional";
  const regular = "regular";

  final isDealbreaker =
      (a == nonSmoker && b == regular) || (b == nonSmoker && a == regular);
  if (isDealbreaker) {
    return const GradedCompatibility(score: 0.0, isDealbreaker: true);
  }
  if ((a == nonSmoker && b == occasional) ||
      (b == nonSmoker && a == occasional)) {
    return const GradedCompatibility(score: 0.35);
  }
  if ((a == occasional && b == regular) ||
      (b == occasional && a == regular)) {
    return const GradedCompatibility(score: 0.55);
  }
  return const GradedCompatibility(score: 0.0);
}

/// API slugs: `like_pets` | `dont_like_pets` | `have_cat` | `have_dog`.
GradedCompatibility? petsCompatibility(String? a, String? b) {
  if (a == null || b == null) return null;
  if (_petsPreferenceCompatible(a, b)) {
    return const GradedCompatibility(score: 1.0);
  }

  const hasPet = {"have_cat", "have_dog"};
  final isDealbreaker = (a == "dont_like_pets" && hasPet.contains(b)) ||
      (b == "dont_like_pets" && hasPet.contains(a));
  if (isDealbreaker) {
    return const GradedCompatibility(score: 0.0, isDealbreaker: true);
  }
  return const GradedCompatibility(score: 0.2);
}

bool _petsPreferenceCompatible(String a, String b) {
  if (a == b) return true;
  const hasPet = {"have_cat", "have_dog"};
  if (a == "like_pets" && hasPet.contains(b)) return true;
  if (b == "like_pets" && hasPet.contains(a)) return true;
  return false;
}

/// Jaccard similarity on trimmed, lowercased tags. Reserved for when hobbies
/// are persisted on [UserProfile].
double hobbiesJaccardScore(
  List<String> a,
  List<String> b, {
  double neutralWhenBothEmpty = 0.5,
}) {
  final sa = _hobbySet(a);
  final sb = _hobbySet(b);
  if (sa.isEmpty && sb.isEmpty) return neutralWhenBothEmpty;
  if (sa.isEmpty || sb.isEmpty) return 0.0;
  final inter = sa.intersection(sb).length;
  final union = sa.union(sb).length;
  if (union == 0) return neutralWhenBothEmpty;
  return inter / union;
}

Set<String> _hobbySet(List<String> raw) {
  return raw
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toSet();
}

/// Backward-compatible wrapper used by tests.
@Deprecated("Use computeProfileCompatibility instead")
double computeProfileMatchScore(
  UserProfile a,
  UserProfile b, {
  List<String> hobbiesA = const [],
  List<String> hobbiesB = const [],
  double neutralPartialScore = 0.5,
}) {
  return computeProfileCompatibility(a, b).score;
}
