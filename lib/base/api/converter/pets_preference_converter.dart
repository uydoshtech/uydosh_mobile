/// JSON for [pets_preference]: string slugs, with legacy API boolean support.
class PetsPreferenceConverter {
  PetsPreferenceConverter._();

  static String? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is bool) return json ? "like_pets" : "dont_like_pets";
    if (json is String) {
      if (json.isEmpty) return null;
      return json;
    }
    return null;
  }

  static dynamic toJson(String? value) => value;
}
