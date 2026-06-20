import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/utils/profile_match_scoring.dart";
import "package:uy_dosh/presentation/screens/listing_detail/group_member_compatibility_helper.dart";

void main() {
  group("GroupMemberCompatibilityHelper", () {
    test("returns empty summary for self", () {
      const profile = UserProfile(id: 1, userId: 1, smokingPreference: "non_smoker");

      final summary = GroupMemberCompatibilityHelper.summarize(profile, profile);

      expect(summary, GroupMemberCompatibilitySummary.empty);
    });

    test("returns percent and prioritized highlights", () {
      const viewer = UserProfile(
        id: 1,
        userId: 1,
        smokingPreference: "non-smoker",
        petsPreference: "dont_like_pets",
        cleanliness: 5,
        noiseLevel: 2,
      );
      const member = UserProfile(
        id: 2,
        userId: 2,
        smokingPreference: "regular",
        petsPreference: "have_cat",
        cleanliness: 2,
        noiseLevel: 4,
      );

      final summary = GroupMemberCompatibilityHelper.summarize(viewer, member);

      expect(summary.percent, isNotNull);
      expect(summary.percent!, lessThanOrEqualTo(35));
      expect(summary.fieldHighlights, isNotEmpty);
      expect(summary.fieldHighlights.length, lessThanOrEqualTo(5));
      expect(
        summary.fieldHighlights.any(
          (highlight) => highlight.status == ProfileMatchFieldStatus.dealbreaker,
        ),
        isTrue,
      );
    });
  });
}
