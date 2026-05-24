import "package:uy_dosh/domain/models/user_profile.dart";

/// Weights for profile compatibility dimensions. Sum to 1.0.
/// Hobbies are omitted until persisted on [UserProfile].
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
}

/// Max overall score when a dealbreaker dimension mismatches (smoking, pets).
const double profileMatchDealbreakerCap = 0.35;

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

/// Unified profile compatibility: one formula drives percent and field status.
ProfileCompatibilityScore computeProfileCompatibility(
  UserProfile a,
  UserProfile b,
) {
  const totalFieldCount = 12;

  final fields = <ProfileMatchFieldResult>[
    _sleepField(a, b),
    _smokingField(a, b),
    _petsField(a, b),
    _cleanlinessField(a, b),
    _noiseField(a, b),
    _sociabilityField(a, b),
    _drinkingField(a, b),
    _universityField(a, b),
    _guestsField(a, b),
    _cookingField(a, b),
    _regionField(a, b),
    _languageField(a, b),
  ];

  final scored = fields.where((f) => f.countsTowardScore).toList();
  final hasDealbreaker = fields.any((f) => f.isDealbreaker);

  double score;
  if (scored.isEmpty) {
    score = 0.0;
  } else {
    final weightSum = scored.fold<double>(0, (sum, f) => sum + f.weight);
    final weighted = scored.fold<double>(
      0,
      (sum, f) => sum + f.weight * f.partialScore!,
    );
    score = (weighted / weightSum).clamp(0.0, 1.0);
  }

  if (hasDealbreaker) {
    score = score.clamp(0.0, profileMatchDealbreakerCap);
  }

  return ProfileCompatibilityScore(
    score: score,
    percent: (score * 100).round(),
    scoredFieldCount: scored.length,
    totalFieldCount: totalFieldCount,
    fields: fields,
    hasDealbreaker: hasDealbreaker,
  );
}

ProfileMatchFieldResult _sleepField(UserProfile a, UserProfile b) {
  final partial = sleepScheduleCompatibility(
    a.sleepTime,
    a.wakeupTime,
    b.sleepTime,
    b.wakeupTime,
  );
  if (partial == null) {
    return const ProfileMatchFieldResult(
      labelKey: "sleep_schedule",
      weight: ProfileMatchWeights.sleepSchedule,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: "sleep_schedule",
    weight: ProfileMatchWeights.sleepSchedule,
    partialScore: partial,
    status: partial >= 0.75
        ? ProfileMatchFieldStatus.match
        : ProfileMatchFieldStatus.difference,
  );
}

ProfileMatchFieldResult _smokingField(UserProfile a, UserProfile b) {
  final result = smokingCompatibility(a.smokingPreference, b.smokingPreference);
  if (result == null) {
    return const ProfileMatchFieldResult(
      labelKey: "smoking_preference",
      weight: ProfileMatchWeights.smoking,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: "smoking_preference",
    weight: ProfileMatchWeights.smoking,
    partialScore: result.score,
    status: result.isDealbreaker
        ? ProfileMatchFieldStatus.dealbreaker
        : result.score >= 0.75
            ? ProfileMatchFieldStatus.match
            : ProfileMatchFieldStatus.difference,
    isDealbreaker: result.isDealbreaker,
  );
}

ProfileMatchFieldResult _petsField(UserProfile a, UserProfile b) {
  final result = petsCompatibility(a.petsPreference, b.petsPreference);
  if (result == null) {
    return const ProfileMatchFieldResult(
      labelKey: "pets_preference",
      weight: ProfileMatchWeights.pets,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: "pets_preference",
    weight: ProfileMatchWeights.pets,
    partialScore: result.score,
    status: result.isDealbreaker
        ? ProfileMatchFieldStatus.dealbreaker
        : result.score >= 0.75
            ? ProfileMatchFieldStatus.match
            : ProfileMatchFieldStatus.difference,
    isDealbreaker: result.isDealbreaker,
  );
}

ProfileMatchFieldResult _scaleField({
  required String labelKey,
  required double weight,
  required int? a,
  required int? b,
}) {
  final partial = scaleCompatibility(a, b);
  if (partial == null) {
    return ProfileMatchFieldResult(
      labelKey: labelKey,
      weight: weight,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: labelKey,
    weight: weight,
    partialScore: partial,
    status: partial >= 0.75
        ? ProfileMatchFieldStatus.match
        : ProfileMatchFieldStatus.difference,
  );
}

ProfileMatchFieldResult _cleanlinessField(UserProfile a, UserProfile b) =>
    _scaleField(
      labelKey: "cleanliness",
      weight: ProfileMatchWeights.cleanliness,
      a: a.cleanliness,
      b: b.cleanliness,
    );

ProfileMatchFieldResult _noiseField(UserProfile a, UserProfile b) =>
    _scaleField(
      labelKey: "noise_level",
      weight: ProfileMatchWeights.noiseLevel,
      a: a.noiseLevel,
      b: b.noiseLevel,
    );

ProfileMatchFieldResult _sociabilityField(UserProfile a, UserProfile b) =>
    _scaleField(
      labelKey: "sociability",
      weight: ProfileMatchWeights.sociability,
      a: a.sociability,
      b: b.sociability,
    );

ProfileMatchFieldResult _drinkingField(UserProfile a, UserProfile b) {
  final partial = preferenceBinaryScore(
    a.alcoholPreference,
    b.alcoholPreference,
  );
  if (partial == null) {
    return const ProfileMatchFieldResult(
      labelKey: "alcohol_preference",
      weight: ProfileMatchWeights.drinking,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: "alcohol_preference",
    weight: ProfileMatchWeights.drinking,
    partialScore: partial,
    status: partial >= 0.75
        ? ProfileMatchFieldStatus.match
        : ProfileMatchFieldStatus.difference,
  );
}

ProfileMatchFieldResult _universityField(UserProfile a, UserProfile b) {
  final partial = universityScore(a.universityId, b.universityId);
  if (partial == null) {
    return const ProfileMatchFieldResult(
      labelKey: "university",
      weight: ProfileMatchWeights.university,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: "university",
    weight: ProfileMatchWeights.university,
    partialScore: partial,
    status: partial >= 0.75
        ? ProfileMatchFieldStatus.match
        : ProfileMatchFieldStatus.difference,
  );
}

ProfileMatchFieldResult _boolField({
  required String labelKey,
  required double weight,
  required bool? a,
  required bool? b,
}) {
  final partial = preferenceBinaryScore(a, b);
  if (partial == null) {
    return ProfileMatchFieldResult(
      labelKey: labelKey,
      weight: weight,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: labelKey,
    weight: weight,
    partialScore: partial,
    status: partial >= 0.75
        ? ProfileMatchFieldStatus.match
        : ProfileMatchFieldStatus.difference,
  );
}

ProfileMatchFieldResult _guestsField(UserProfile a, UserProfile b) =>
    _boolField(
      labelKey: "guests",
      weight: ProfileMatchWeights.guests,
      a: a.guestsAllowed,
      b: b.guestsAllowed,
    );

ProfileMatchFieldResult _cookingField(UserProfile a, UserProfile b) =>
    _boolField(
      labelKey: "cooking_habits",
      weight: ProfileMatchWeights.cooking,
      a: a.cookingHabits,
      b: b.cookingHabits,
    );

ProfileMatchFieldResult _regionField(UserProfile a, UserProfile b) {
  final partial = preferenceBinaryScore(a.regionId, b.regionId);
  if (partial == null) {
    return const ProfileMatchFieldResult(
      labelKey: "region",
      weight: ProfileMatchWeights.region,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: "region",
    weight: ProfileMatchWeights.region,
    partialScore: partial,
    status: partial >= 0.75
        ? ProfileMatchFieldStatus.match
        : ProfileMatchFieldStatus.difference,
  );
}

ProfileMatchFieldResult _languageField(UserProfile a, UserProfile b) {
  final partial = preferenceBinaryScore(
    a.preferredLanguage,
    b.preferredLanguage,
  );
  if (partial == null) {
    return const ProfileMatchFieldResult(
      labelKey: "language",
      weight: ProfileMatchWeights.language,
      status: ProfileMatchFieldStatus.incomplete,
    );
  }
  return ProfileMatchFieldResult(
    labelKey: "language",
    weight: ProfileMatchWeights.language,
    partialScore: partial,
    status: partial >= 0.75
        ? ProfileMatchFieldStatus.match
        : ProfileMatchFieldStatus.difference,
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
