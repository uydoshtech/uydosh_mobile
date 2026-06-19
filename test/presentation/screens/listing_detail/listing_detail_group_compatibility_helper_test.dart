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

      final result = ListingDetailGroupCompatibilityHelper.calculate(
        profiles,
        budgetDisplay: "120-180 \$/month",
      );

      expect(result.percent, isNotNull);
      expect(result.fullMatches.any((m) => m.labelKey == "noise_level"), isTrue);
      expect(result.fullMatches.any((m) => m.labelKey == "budget"), isTrue);
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
  });
}
