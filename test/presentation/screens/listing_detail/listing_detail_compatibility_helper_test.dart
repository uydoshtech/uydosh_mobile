import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_compatibility_helper.dart";

UserProfile _profile({
  required int userId,
  int? regionId,
  UserProfileRegion? region,
}) {
  return UserProfile(
    id: userId,
    userId: userId,
    regionId: regionId,
    region: region,
    smokingPreference: "non-smoker",
    alcoholPreference: "non-drinker",
    cleanliness: 3,
    noiseLevel: 3,
    sociability: 3,
  );
}

UserProfileRegion _bukharaRegion() {
  return const UserProfileRegion(
    id: 5,
    nameEn: "Bukhara Region",
    nameRu: "Бухарская область",
    nameUz: "Buxoro viloyati",
    shortNameEn: "Bukhara",
    shortNameRu: "Бухара",
    shortNameUz: "Buxoro",
  );
}

UserProfileRegion _tashkentRegion() {
  return const UserProfileRegion(
    id: 1,
    nameEn: "Tashkent City",
    nameRu: "Город Ташкент",
    nameUz: "Toshkent shahri",
    shortNameEn: "Tashkent",
    shortNameRu: "Ташкент",
    shortNameUz: "Toshkent",
  );
}

void main() {
  group("ListingDetailCompatibilityHelper region rows", () {
    test("same Uzbekistan region appears in matches", () {
      final region = _bukharaRegion();
      final current = _profile(userId: 1, regionId: 5, region: region);
      final owner = _profile(userId: 2, regionId: 5, region: region);

      final result = ListingDetailCompatibilityHelper.calculate(current, owner);

      expect(
        result.matches.any((m) => m.labelKey == "same_region"),
        isTrue,
        reason: "Expected a same-region match row",
      );
      expect(result.differences.where((d) => d.labelKey == "region"), isEmpty);
    });

    test("different Uzbekistan regions appear in differences", () {
      final current = _profile(
        userId: 1,
        regionId: 5,
        region: _bukharaRegion(),
      );
      final owner = _profile(
        userId: 2,
        regionId: 1,
        region: _tashkentRegion(),
      );

      final result = ListingDetailCompatibilityHelper.calculate(current, owner);

      expect(result.matches.where((m) => m.labelKey == "same_region"), isEmpty);
      expect(
        result.differences.any((d) => d.labelKey == "region"),
        isTrue,
        reason: "Expected a region difference row",
      );
    });

    test("missing region on either side omits region rows", () {
      final current = _profile(
        userId: 1,
        regionId: 5,
        region: _bukharaRegion(),
      );
      final owner = _profile(userId: 2);

      final result = ListingDetailCompatibilityHelper.calculate(current, owner);

      expect(result.matches.where((m) => m.labelKey == "same_region"), isEmpty);
      expect(result.differences.where((d) => d.labelKey == "region"), isEmpty);
      expect(result.dealbreakers.where((d) => d.labelKey == "region"), isEmpty);
    });
  });
}
