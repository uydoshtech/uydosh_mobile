// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  name: json['name'] as String?,
  gender: (json['gender'] as num?)?.toInt(),
  regionId: (json['region_id'] as num?)?.toInt(),
  universityId: (json['university_id'] as num?)?.toInt(),
  role: json['role'] as String?,
  aboutMe: json['about_me'] as String?,
  telegram: json['telegram'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  rating: (json['rating'] as num?)?.toInt(),
  employed: json['employed'] as bool?,
  cleanliness: (json['cleanliness'] as num?)?.toInt(),
  noiseLevel: (json['noise_level'] as num?)?.toInt(),
  sociability: (json['sociability'] as num?)?.toInt(),
  guestsAllowed: json['guests_allowed'] as bool?,
  smokingPreference: json['smoking_preference'] as String?,
  alcoholPreference: json['alcohol_preference'] as String?,
  cookingHabits: json['cooking_habits'] as bool?,
  petsPreference: PetsPreferenceConverter.fromJson(json['pets_preference']),
  wakeupTime: json['wakeup_time'] as String?,
  sleepTime: json['sleep_time'] as String?,
  preferredLanguage: json['preferred_language'] as String?,
  originCountryIso2: json['origin_country_iso2'] as String?,
  birthYear: (json['birth_year'] as num?)?.toInt(),
  budgetMin: (json['budget_min'] as num?)?.toInt(),
  budgetMax: (json['budget_max'] as num?)?.toInt(),
  prefRoommateGender: json['pref_roommate_gender'] as String?,
  prefAgeMin: (json['pref_age_min'] as num?)?.toInt(),
  prefAgeMax: (json['pref_age_max'] as num?)?.toInt(),
  prefBudgetOverlapRequired: json['pref_budget_overlap_required'] as bool?,
  dealbreakers: (json['dealbreakers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  topPriorities: (json['top_priorities'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'gender': instance.gender,
  'region_id': instance.regionId,
  'university_id': instance.universityId,
  'role': instance.role,
  'about_me': instance.aboutMe,
  'telegram': instance.telegram,
  'avatar_url': instance.avatarUrl,
  'rating': instance.rating,
  'employed': instance.employed,
  'cleanliness': instance.cleanliness,
  'noise_level': instance.noiseLevel,
  'sociability': instance.sociability,
  'guests_allowed': instance.guestsAllowed,
  'smoking_preference': instance.smokingPreference,
  'alcohol_preference': instance.alcoholPreference,
  'cooking_habits': instance.cookingHabits,
  'pets_preference': PetsPreferenceConverter.toJson(instance.petsPreference),
  'wakeup_time': instance.wakeupTime,
  'sleep_time': instance.sleepTime,
  'preferred_language': instance.preferredLanguage,
  'origin_country_iso2': instance.originCountryIso2,
  'birth_year': instance.birthYear,
  'budget_min': instance.budgetMin,
  'budget_max': instance.budgetMax,
  'pref_roommate_gender': instance.prefRoommateGender,
  'pref_age_min': instance.prefAgeMin,
  'pref_age_max': instance.prefAgeMax,
  'pref_budget_overlap_required': instance.prefBudgetOverlapRequired,
  'dealbreakers': instance.dealbreakers,
  'top_priorities': instance.topPriorities,
};
