import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_group_compatibility_helper.dart";

UserProfile _profile({
  required int userId,
  String? smokingPreference,
  String? wakeupTime,
  String? sleepTime,
  int? cleanliness,
  int? noiseLevel,
  bool? cookingHabits,
  String? preferredLanguage,
  List<String>? dealbreakers,
}) {
  return UserProfile(
    id: userId,
    userId: userId,
    smokingPreference: smokingPreference,
    wakeupTime: wakeupTime,
    sleepTime: sleepTime,
    cleanliness: cleanliness,
    noiseLevel: noiseLevel,
    cookingHabits: cookingHabits,
    preferredLanguage: preferredLanguage,
    dealbreakers: dealbreakers,
  );
}

void main() {
  group("ListingDetailGroupCompatibilityHelper", () {
    test("full match when all three share lifestyle values", () {
      final profiles = [
        _profile(
          userId: 1,
          noiseLevel: 2,
          cleanliness: 4,
          cookingHabits: true,
          preferredLanguage: "ru",
        ),
        _profile(
          userId: 2,
          noiseLevel: 2,
          cleanliness: 4,
          cookingHabits: true,
          preferredLanguage: "ru",
        ),
        _profile(
          userId: 3,
          noiseLevel: 2,
          cleanliness: 4,
          cookingHabits: true,
          preferredLanguage: "ru",
        ),
      ];

      final result = ListingDetailGroupCompatibilityHelper.calculate(profiles);

      expect(result.percent, isNotNull);
      expect(result.fullMatches.any((m) => m.labelKey == "noise_level"), isTrue);
      expect(result.fullMatches.any((m) => m.labelKey == "budget"), isFalse);
      expect(result.discussItems, isEmpty);
    });

    test("discuss item when smoking dealbreaker splits group", () {
      final profiles = [
        _profile(userId: 1, smokingPreference: "non-smoker"),
        _profile(userId: 2, smokingPreference: "non-smoker"),
        _profile(userId: 3, smokingPreference: "regular"),
      ];

      final result = ListingDetailGroupCompatibilityHelper.calculate(profiles);

      expect(
        result.discussItems.any((d) => d.labelKey == "smoking_preference"),
        isTrue,
      );
    });

    test("partial match when two of three agree on wakeup time", () {
      final profiles = [
        _profile(userId: 1, wakeupTime: "morning"),
        _profile(userId: 2, wakeupTime: "morning"),
        _profile(userId: 3, wakeupTime: "evening"),
      ];

      final result = ListingDetailGroupCompatibilityHelper.calculate(profiles);

      expect(
        result.partialMatches.any((m) => m.labelKey == "wakeup_time"),
        isTrue,
      );
    });

    test(
      "user-listed cleanliness dealbreaker flags only the conflicting members",
      () {
        final profiles = [
          _profile(userId: 1, cleanliness: 1, dealbreakers: ["cleanliness"]),
          _profile(userId: 2, cleanliness: 5),
          _profile(userId: 3, cleanliness: 1),
        ];

        final matrix =
            ListingDetailGroupCompatibilityHelper.buildPreferenceMatrix(
          profiles,
        );
        final row = matrix.firstWhere((r) => r.labelKey == "cleanliness");
        GroupPreferenceMatrixCell cellFor(int userId) =>
            row.cells.firstWhere((c) => c.userId == userId);

        // 1 (dealbreaker owner) and 2 (the messy roommate) conflict; 3 matches 1.
        expect(
          cellFor(1).status,
          GroupPreferenceMatrixCellStatus.conflict,
        );
        expect(
          cellFor(2).status,
          GroupPreferenceMatrixCellStatus.conflict,
        );
        expect(
          cellFor(3).status,
          isNot(GroupPreferenceMatrixCellStatus.conflict),
        );

        // The field is surfaced as something to discuss.
        final result =
            ListingDetailGroupCompatibilityHelper.calculate(profiles);
        expect(
          result.discussItems.any((d) => d.labelKey == "cleanliness"),
          isTrue,
        );
      },
    );

    test("overall percent is capped when a pair hits a dealbreaker", () {
      final profiles = [
        _profile(
          userId: 1,
          cleanliness: 1,
          noiseLevel: 2,
          cookingHabits: true,
          preferredLanguage: "ru",
          dealbreakers: ["cleanliness"],
        ),
        _profile(
          userId: 2,
          cleanliness: 5,
          noiseLevel: 2,
          cookingHabits: true,
          preferredLanguage: "ru",
        ),
      ];

      final result = ListingDetailGroupCompatibilityHelper.calculate(profiles);

      expect(result.percent, isNotNull);
      expect(result.percent! <= 35, isTrue);
    });
  });
}
