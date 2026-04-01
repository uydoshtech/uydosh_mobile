import "package:uy_dosh/domain/models/user_profile.dart";

/// Weighted compatibility in \[0, 1\]: sleep schedule matters most, university least.
/// Raw weights sum to [totalWeight]; the final score divides by that so the range stays 0–1.
class ProfileMatchWeights {
  ProfileMatchWeights._();

  /// Sleep / wake rhythm (combined).
  static const double sleepSchedule = 0.25;

  /// Smoking preference — high impact (near “dealbreaker” vs equal weighting).
  static const double smoking = 0.2;

  static const double drinking = 0.1;
  static const double university = 0.1;
  static const double hobbies = 0.15;

  static const double totalWeight =
      sleepSchedule + smoking + drinking + university + hobbies;
}

/// Smart profile match: not all fields contribute equally.
///
/// [hobbiesA] / [hobbiesB] — optional until persisted on [UserProfile]; when both
/// empty, the hobbies term is neutral ([neutralPartialScore]) so it does not inflate scores.
double computeProfileMatchScore(
  UserProfile a,
  UserProfile b, {
  List<String> hobbiesA = const [],
  List<String> hobbiesB = const [],
  double neutralPartialScore = 0.5,
}) {
  final sleep = sleepScheduleCompatibility(
    a.sleepTime,
    a.wakeupTime,
    b.sleepTime,
    b.wakeupTime,
    neutralPartialScore: neutralPartialScore,
  );
  final smoke = preferenceBinaryScore(
    a.smokingPreference,
    b.smokingPreference,
    neutralPartialScore: neutralPartialScore,
  );
  final drink = preferenceBinaryScore(
    a.alcoholPreference,
    b.alcoholPreference,
    neutralPartialScore: neutralPartialScore,
  );
  final uni = universityScore(
    a.universityId,
    b.universityId,
    neutralPartialScore: neutralPartialScore,
  );
  final hobby = hobbiesJaccardScore(
    hobbiesA,
    hobbiesB,
    neutralWhenBothEmpty: neutralPartialScore,
  );

  final raw = sleep * ProfileMatchWeights.sleepSchedule +
      smoke * ProfileMatchWeights.smoking +
      drink * ProfileMatchWeights.drinking +
      uni * ProfileMatchWeights.university +
      hobby * ProfileMatchWeights.hobbies;

  final normalized = raw / ProfileMatchWeights.totalWeight;
  return normalized.clamp(0.0, 1.0);
}

/// \[0, 1\] from [sleepTime] + [wakeupTime] (e.g. morning / evening / night).
/// Unknown on one side yields [neutralPartialScore] for that slot only.
double sleepScheduleCompatibility(
  String? sleepA,
  String? wakeA,
  String? sleepB,
  String? wakeB, {
  double neutralPartialScore = 0.5,
}) {
  double slot(String? x, String? y) {
    if (x == null || y == null) return neutralPartialScore;
    final ox = _dayPhaseOrder(x);
    final oy = _dayPhaseOrder(y);
    if (ox != null && oy != null) {
      final dist = (ox - oy).abs();
      return 1.0 - (dist / 2.0).clamp(0.0, 1.0);
    }
    return x == y ? 1.0 : 0.0;
  }

  return (slot(sleepA, sleepB) + slot(wakeA, wakeB)) / 2.0;
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

/// Same as `a == b ? 1 : 0` when both set; partial data → neutral.
double preferenceBinaryScore(
  String? a,
  String? b, {
  double neutralPartialScore = 0.5,
}) {
  if (a == null || b == null) return neutralPartialScore;
  return a == b ? 1.0 : 0.0;
}

double universityScore(
  int? a,
  int? b, {
  double neutralPartialScore = 0.5,
}) {
  if (a == null || b == null) return neutralPartialScore;
  return a == b ? 1.0 : 0.0;
}

/// Jaccard similarity on trimmed, lowercased tags. Both empty → [neutralWhenBothEmpty].
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
