import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/utils/profile_match_scoring.dart";

UserProfile _profile({
  String? sleepTime,
  String? wakeupTime,
  String? smokingPreference,
  String? alcoholPreference,
  int? universityId,
  String? petsPreference,
  int? cleanliness,
  int? noiseLevel,
  int? sociability,
  bool? guestsAllowed,
  bool? cookingHabits,
  int? regionId,
  String? preferredLanguage,
}) {
  return UserProfile(
    id: 1,
    userId: 1,
    sleepTime: sleepTime,
    wakeupTime: wakeupTime,
    smokingPreference: smokingPreference,
    alcoholPreference: alcoholPreference,
    universityId: universityId,
    petsPreference: petsPreference,
    cleanliness: cleanliness,
    noiseLevel: noiseLevel,
    sociability: sociability,
    guestsAllowed: guestsAllowed,
    cookingHabits: cookingHabits,
    regionId: regionId,
    preferredLanguage: preferredLanguage,
  );
}

void main() {
  group("sleepScheduleCompatibility", () {
    test("matching phases score 1.0", () {
      expect(
        sleepScheduleCompatibility("morning", "evening", "morning", "evening"),
        1.0,
      );
    });

    test("missing data on both slots returns null", () {
      expect(
        sleepScheduleCompatibility(null, null, null, null),
        isNull,
      );
    });

    test("one slot filled uses that slot only", () {
      expect(
        sleepScheduleCompatibility(null, "morning", null, "morning"),
        1.0,
      );
    });

    test("non-phase strings fall back to equality per slot", () {
      expect(
        sleepScheduleCompatibility("custom", "x", "custom", "x"),
        1.0,
      );
      expect(
        sleepScheduleCompatibility("custom", "x", "other", "x"),
        0.5,
      );
    });
  });

  group("preferenceBinaryScore", () {
    test("null yields null (excluded from score)", () {
      expect(preferenceBinaryScore(null, "a"), isNull);
      expect(preferenceBinaryScore("a", null), isNull);
    });

    test("match vs mismatch", () {
      expect(preferenceBinaryScore("yes", "yes"), 1.0);
      expect(preferenceBinaryScore("yes", "no"), 0.0);
    });
  });

  group("universityScore", () {
    test("null yields null", () {
      expect(universityScore(null, 1), isNull);
    });

    test("same id is 1.0", () {
      expect(universityScore(5, 5), 1.0);
    });

    test("different ids score as both students", () {
      expect(universityScore(5, 6), 0.55);
    });
  });

  group("scaleCompatibility", () {
    test("exact match is 1.0", () {
      expect(scaleCompatibility(3, 3), 1.0);
    });

    test("distance 1 is soft match", () {
      expect(scaleCompatibility(3, 4), 0.75);
    });

    test("distance 2 is weak", () {
      expect(scaleCompatibility(1, 3), 0.35);
    });

    test("far apart is 0", () {
      expect(scaleCompatibility(1, 5), 0.0);
    });
  });

  group("smokingCompatibility", () {
    test("non-smoker vs regular is dealbreaker", () {
      final result = smokingCompatibility("non-smoker", "regular");
      expect(result?.isDealbreaker, isTrue);
      expect(result?.score, 0.0);
    });

    test("same preference is perfect", () {
      final result = smokingCompatibility("occasional", "occasional");
      expect(result?.score, 1.0);
      expect(result?.isDealbreaker, isFalse);
    });
  });

  group("petsCompatibility", () {
    test("dont_like_pets vs have_cat is dealbreaker", () {
      final result = petsCompatibility("dont_like_pets", "have_cat");
      expect(result?.isDealbreaker, isTrue);
      expect(result?.score, 0.0);
    });

    test("like_pets vs have_dog is compatible", () {
      final result = petsCompatibility("like_pets", "have_dog");
      expect(result?.score, 1.0);
    });
  });

  group("hobbiesJaccardScore", () {
    test("both empty returns neutral", () {
      expect(hobbiesJaccardScore([], [], neutralWhenBothEmpty: 0.42), 0.42);
    });

    test("trims and lowercases", () {
      expect(
        hobbiesJaccardScore([" Reading "], ["reading"]),
        1.0,
      );
    });

    test("one side empty is 0", () {
      expect(hobbiesJaccardScore(["a"], []), 0.0);
    });

    test("jaccard for overlap", () {
      expect(
        hobbiesJaccardScore(["a", "b"], ["a", "c"]),
        closeTo(1 / 3, 1e-9),
      );
    });
  });

  group("computeProfileCompatibility", () {
    test("identical filled profiles score high", () {
      final a = _profile(
        sleepTime: "morning",
        wakeupTime: "evening",
        smokingPreference: "non-smoker",
        alcoholPreference: "non-drinker",
        universityId: 10,
        petsPreference: "like_pets",
        cleanliness: 4,
        noiseLevel: 3,
        sociability: 3,
        guestsAllowed: false,
        cookingHabits: true,
        regionId: 1,
        preferredLanguage: "uz",
      );
      final b = _profile(
        sleepTime: "morning",
        wakeupTime: "evening",
        smokingPreference: "non-smoker",
        alcoholPreference: "non-drinker",
        universityId: 10,
        petsPreference: "like_pets",
        cleanliness: 4,
        noiseLevel: 3,
        sociability: 3,
        guestsAllowed: false,
        cookingHabits: true,
        regionId: 1,
        preferredLanguage: "uz",
      );

      final result = computeProfileCompatibility(a, b);
      expect(result.percent, greaterThanOrEqualTo(95));
      expect(result.scoredFieldCount, 12);
      expect(result.hasDealbreaker, isFalse);
    });

    test("incomplete profiles exclude missing fields from denominator", () {
      final sparse = _profile(smokingPreference: "non-smoker");
      final full = _profile(
        smokingPreference: "non-smoker",
        alcoholPreference: "non-drinker",
        universityId: 1,
        cleanliness: 3,
        noiseLevel: 3,
        sociability: 3,
      );

      final result = computeProfileCompatibility(sparse, full);
      expect(result.scoredFieldCount, lessThan(result.totalFieldCount));
      expect(result.percent, isNot(50));
    });

    test("smoking dealbreaker caps overall score", () {
      final a = _profile(
        sleepTime: "morning",
        wakeupTime: "evening",
        smokingPreference: "non-smoker",
        alcoholPreference: "non-drinker",
        universityId: 10,
        petsPreference: "like_pets",
        cleanliness: 5,
        noiseLevel: 3,
        sociability: 3,
        guestsAllowed: false,
        cookingHabits: true,
        regionId: 1,
        preferredLanguage: "uz",
      );
      final b = _profile(
        sleepTime: "morning",
        wakeupTime: "evening",
        smokingPreference: "regular",
        alcoholPreference: "non-drinker",
        universityId: 10,
        petsPreference: "like_pets",
        cleanliness: 5,
        noiseLevel: 3,
        sociability: 3,
        guestsAllowed: false,
        cookingHabits: true,
        regionId: 1,
        preferredLanguage: "uz",
      );

      final result = computeProfileCompatibility(a, b);
      expect(result.hasDealbreaker, isTrue);
      expect(result.percent, lessThanOrEqualTo(35));
    });

    test("result is clamped to [0, 100]", () {
      final a = _profile(
        sleepTime: "morning",
        wakeupTime: "morning",
        smokingPreference: "non-smoker",
        alcoholPreference: "non-drinker",
        universityId: 1,
        petsPreference: "dont_like_pets",
        cleanliness: 1,
        noiseLevel: 5,
        sociability: 1,
        guestsAllowed: true,
        cookingHabits: false,
        regionId: 1,
        preferredLanguage: "uz",
      );
      final b = _profile(
        sleepTime: "night",
        wakeupTime: "night",
        smokingPreference: "regular",
        alcoholPreference: "regular",
        universityId: 2,
        petsPreference: "have_cat",
        cleanliness: 5,
        noiseLevel: 1,
        sociability: 5,
        guestsAllowed: false,
        cookingHabits: true,
        regionId: 2,
        preferredLanguage: "ru",
      );

      final result = computeProfileCompatibility(a, b);
      expect(result.percent >= 0 && result.percent <= 100, isTrue);
    });
  });
}
