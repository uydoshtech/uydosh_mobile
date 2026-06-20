import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/utils/profile_match_scoring.dart";

class MemberCompatibilityFieldHighlight {
  const MemberCompatibilityFieldHighlight({
    required this.labelKey,
    required this.status,
  });

  final String labelKey;
  final ProfileMatchFieldStatus status;

  @override
  bool operator ==(Object other) {
    return other is MemberCompatibilityFieldHighlight &&
        other.labelKey == labelKey &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(labelKey, status);
}

class GroupMemberCompatibilitySummary {
  const GroupMemberCompatibilitySummary({
    this.percent,
    this.fieldHighlights = const [],
  });

  final int? percent;
  final List<MemberCompatibilityFieldHighlight> fieldHighlights;

  static const empty = GroupMemberCompatibilitySummary();

  @override
  bool operator ==(Object other) {
    return other is GroupMemberCompatibilitySummary &&
        other.percent == percent &&
        _listEquals(other.fieldHighlights, fieldHighlights);
  }

  @override
  int get hashCode => Object.hash(percent, Object.hashAll(fieldHighlights));
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Pairwise viewer-vs-member compatibility for group member profile tiles.
class GroupMemberCompatibilityHelper {
  GroupMemberCompatibilityHelper._();

  static const _maxHighlights = 5;

  static GroupMemberCompatibilitySummary summarize(
    UserProfile viewer,
    UserProfile member,
  ) {
    if (viewer.userId == member.userId) {
      return GroupMemberCompatibilitySummary.empty;
    }

    final analysis = computeProfileCompatibility(viewer, member);
    if (analysis.scoredFieldCount == 0) {
      return GroupMemberCompatibilitySummary.empty;
    }

    final scored = analysis.fields
        .where((field) => field.status != ProfileMatchFieldStatus.incomplete)
        .toList()
      ..sort(
        (a, b) => _statusRank(a.status).compareTo(_statusRank(b.status)),
      );

    final highlights = scored
        .take(_maxHighlights)
        .map(
          (field) => MemberCompatibilityFieldHighlight(
            labelKey: field.labelKey,
            status: field.status,
          ),
        )
        .toList();

    return GroupMemberCompatibilitySummary(
      percent: analysis.percent,
      fieldHighlights: highlights,
    );
  }

  static int _statusRank(ProfileMatchFieldStatus status) {
    switch (status) {
      case ProfileMatchFieldStatus.dealbreaker:
        return 0;
      case ProfileMatchFieldStatus.difference:
        return 1;
      case ProfileMatchFieldStatus.match:
        return 2;
      case ProfileMatchFieldStatus.incomplete:
        return 3;
    }
  }
}
