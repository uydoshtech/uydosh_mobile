import "package:json_annotation/json_annotation.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/converter/pets_preference_converter.dart";

part "update_profile_request.g.dart";

@JsonSerializable()
class UpdateProfileRequest implements IJsonEncodable {
  const UpdateProfileRequest({
    this.name,
    this.gender,
    this.regionId,
    this.universityId,
    this.role,
    this.aboutMe,
    this.telegram,
    this.avatarUrl,
    this.rating,
    this.employed,
    this.cleanliness,
    this.noiseLevel,
    this.sociability,
    this.guestsAllowed,
    this.smokingPreference,
    this.alcoholPreference,
    this.cookingHabits,
    this.petsPreference,
    this.wakeupTime,
    this.sleepTime,
    this.preferredLanguage,
    this.originCountryIso2,
    this.birthYear,
    this.budgetMin,
    this.budgetMax,
    this.prefRoommateGender,
    this.prefAgeMin,
    this.prefAgeMax,
    this.prefBudgetOverlapRequired,
    this.dealbreakers,
    this.topPriorities,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);

  final String? name;
  final int? gender;
  @JsonKey(name: "region_id")
  final int? regionId;
  @JsonKey(name: "university_id")
  final int? universityId;
  final String? role;
  @JsonKey(name: "about_me")
  final String? aboutMe;
  final String? telegram;
  @JsonKey(name: "avatar_url")
  final String? avatarUrl;
  final int? rating;
  final bool? employed;
  final int? cleanliness;
  @JsonKey(name: "noise_level")
  final int? noiseLevel;
  final int? sociability;
  @JsonKey(name: "guests_allowed")
  final bool? guestsAllowed;
  @JsonKey(name: "smoking_preference")
  final String? smokingPreference;
  @JsonKey(name: "alcohol_preference")
  final String? alcoholPreference;
  @JsonKey(name: "cooking_habits")
  final bool? cookingHabits;
  @JsonKey(
    name: "pets_preference",
    fromJson: PetsPreferenceConverter.fromJson,
    toJson: PetsPreferenceConverter.toJson,
  )
  final String? petsPreference;
  @JsonKey(name: "wakeup_time")
  final String? wakeupTime;
  @JsonKey(name: "sleep_time")
  final String? sleepTime;
  @JsonKey(name: "preferred_language")
  final String? preferredLanguage;
  @JsonKey(name: "origin_country_iso2")
  final String? originCountryIso2;
  @JsonKey(name: "birth_year")
  final int? birthYear;
  @JsonKey(name: "budget_min")
  final int? budgetMin;
  @JsonKey(name: "budget_max")
  final int? budgetMax;
  @JsonKey(name: "pref_roommate_gender")
  final String? prefRoommateGender;
  @JsonKey(name: "pref_age_min")
  final int? prefAgeMin;
  @JsonKey(name: "pref_age_max")
  final int? prefAgeMax;
  @JsonKey(name: "pref_budget_overlap_required")
  final bool? prefBudgetOverlapRequired;
  @JsonKey(name: "dealbreakers")
  final List<String>? dealbreakers;
  @JsonKey(name: "top_priorities")
  final List<String>? topPriorities;

  @override
  Map<String, dynamic> toJson() {
    // Use the generated toJson method which properly maps fields using @JsonKey annotations
    // This will convert: regionId -> region_id, universityId -> university_id, aboutMe -> about_me
    final json = _$UpdateProfileRequestToJson(this);
    json.removeWhere((key, value) => value == null);
    return json;
  }
}
