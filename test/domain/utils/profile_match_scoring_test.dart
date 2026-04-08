import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/utils/profile_match_scoring.dart";

UserProfile _profile({
  String? sleepTime,
  String? wakeupTime,
  String? smokingPreference,
  String? alcoholPreference,
  int? universityId,
}) {
  return UserProfile(
    id: 1,
    userId: 1,
    sleepTime: sleepTime,
    wakeupTime: wakeupTime,
    smokingPreference: smokingPreference,
    alcoholPreference: alcoholPreference,
    universityId: universityId,
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

    test("unknown on one side uses neutral per slot", () {
      expect(
        sleepScheduleCompatibility(
          null,
          "morning",
          "night",
          "night",
          neutralPartialScore: 0.5,
        ),
        closeTo(0.25, 1e-9),
      );
    });

    test("non-phase strings fall back to equality", () {
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
    test("null yields neutral", () {
      expect(preferenceBinaryScore(null, "a"), 0.5);
      expect(preferenceBinaryScore("a", null), 0.5);
    });

    test("match vs mismatch", () {
      expect(preferenceBinaryScore("yes", "yes"), 1.0);
      expect(preferenceBinaryScore("yes", "no"), 0.0);
    });
  });

  group("universityScore", () {
    test("null yields neutral", () {
      expect(universityScore(null, 1), 0.5);
    });

    test("same id is 1.0", () {
      expect(universityScore(5, 5), 1.0);
      expect(universityScore(5, 6), 0.0);
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

  group("computeProfileMatchScore", () {
    test("identical filled profiles trend to 1.0 with matching hobbies", () {
      final a = _profile(
        sleepTime: "morning",
        wakeupTime: "evening",
        smokingPreference: "no",
        alcoholPreference: "no",
        universityId: 10,
      );
      final b = _profile(
        sleepTime: "morning",
        wakeupTime: "evening",
        smokingPreference: "no",
        alcoholPreference: "no",
        universityId: 10,
      );
      expect(
        computeProfileMatchScore(
          a,
          b,
          hobbiesA: const ["music"],
          hobbiesB: const ["music"],
        ),
        1.0,
      );
    });

    test("result is clamped to [0, 1]", () {
      final a = _profile(
        sleepTime: "morning",
        wakeupTime: "morning",
        smokingPreference: "no",
        alcoholPreference: "no",
        universityId: 1,
      );
      final b = _profile(
        sleepTime: "night",
        wakeupTime: "night",
        smokingPreference: "yes",
        alcoholPreference: "yes",
        universityId: 2,
      );
      final score = computeProfileMatchScore(
        a,
        b,
        hobbiesA: const ["a"],
        hobbiesB: const ["b"],
      );
      expect(score >= 0.0 && score <= 1.0, isTrue);
    });
  });
}
