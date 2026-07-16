// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: NullableIntConverter.convertFromJson(json['id']),
  userId: (json['user_id'] as num).toInt(),
  name: json['name'] as String?,
  gender: (json['gender'] as num?)?.toInt(),
  isVerified: json['is_verified'] as bool?,
  regionId: (json['region_id'] as num?)?.toInt(),
  universityId: (json['university_id'] as num?)?.toInt(),
  avatarUrl: json['avatar_url'] as String?,
  telegramAvatarUrl: json['telegram_avatar_url'] as String?,
  telegram: json['telegram'] as String?,
  rating: (json['rating'] as num?)?.toDouble(),
  aboutMe: json['about_me'] as String?,
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
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
  region: json['region'] == null
      ? null
      : UserProfileRegion.fromJson(json['region'] as Map<String, dynamic>),
  university: json['university'] == null
      ? null
      : UserProfileUniversity.fromJson(
          json['university'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UserProfileToJson(
  _UserProfile instance,
) => <String, dynamic>{
  'id': NullableIntConverter.convertToJson(instance.id),
  'user_id': instance.userId,
  'name': instance.name,
  'gender': instance.gender,
  'is_verified': instance.isVerified,
  'region_id': instance.regionId,
  'university_id': instance.universityId,
  'avatar_url': instance.avatarUrl,
  'telegram_avatar_url': instance.telegramAvatarUrl,
  'telegram': instance.telegram,
  'rating': instance.rating,
  'about_me': instance.aboutMe,
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
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
  'region': instance.region,
  'university': instance.university,
};

_UserProfileRegion _$UserProfileRegionFromJson(Map<String, dynamic> json) =>
    _UserProfileRegion(
      id: NullableIntConverter.convertFromJson(json['id']),
      nameUz: json['name_uz'] as String?,
      nameRu: json['name_ru'] as String?,
      nameEn: json['name_en'] as String?,
      shortNameUz: json['short_name_uz'] as String?,
      shortNameRu: json['short_name_ru'] as String?,
      shortNameEn: json['short_name_en'] as String?,
    );

Map<String, dynamic> _$UserProfileRegionToJson(_UserProfileRegion instance) =>
    <String, dynamic>{
      'id': NullableIntConverter.convertToJson(instance.id),
      'name_uz': instance.nameUz,
      'name_ru': instance.nameRu,
      'name_en': instance.nameEn,
      'short_name_uz': instance.shortNameUz,
      'short_name_ru': instance.shortNameRu,
      'short_name_en': instance.shortNameEn,
    };

_UserProfileUniversity _$UserProfileUniversityFromJson(
  Map<String, dynamic> json,
) => _UserProfileUniversity(
  id: NullableIntConverter.convertFromJson(json['id']),
  nameUz: json['name_uz'] as String?,
  nameRu: json['name_ru'] as String?,
  nameEn: json['name_en'] as String?,
  shortNameUz: json['short_name_uz'] as String?,
  shortNameRu: json['short_name_ru'] as String?,
  shortNameEn: json['short_name_en'] as String?,
  address: json['address'] as String?,
  website: json['website'] as String?,
);

Map<String, dynamic> _$UserProfileUniversityToJson(
  _UserProfileUniversity instance,
) => <String, dynamic>{
  'id': NullableIntConverter.convertToJson(instance.id),
  'name_uz': instance.nameUz,
  'name_ru': instance.nameRu,
  'name_en': instance.nameEn,
  'short_name_uz': instance.shortNameUz,
  'short_name_ru': instance.shortNameRu,
  'short_name_en': instance.shortNameEn,
  'address': instance.address,
  'website': instance.website,
};
