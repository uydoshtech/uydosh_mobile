import "package:uy_dosh/base/localization/l10n.dart";

/// Display label for [UserProfile.petsPreference] API slug.
String localizedPetsPreference(String value) {
  switch (value) {
    case "like_pets":
      return L10n.get("pets_like_pets");
    case "dont_like_pets":
      return L10n.get("pets_dont_like_pets");
    case "have_cat":
      return L10n.get("pets_have_cat");
    case "have_dog":
      return L10n.get("pets_have_dog");
    default:
      return value;
  }
}
