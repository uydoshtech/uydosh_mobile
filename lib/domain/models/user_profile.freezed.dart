// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "user_id")
  int get userId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  int? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: "is_verified")
  bool? get isVerified => throw _privateConstructorUsedError;
  @JsonKey(name: "region_id")
  int? get regionId => throw _privateConstructorUsedError;
  @JsonKey(name: "university_id")
  int? get universityId => throw _privateConstructorUsedError;
  @JsonKey(name: "avatar_url")
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: "telegram_avatar_url")
  String? get telegramAvatarUrl => throw _privateConstructorUsedError;
  String? get telegram => throw _privateConstructorUsedError;
  double? get rating => throw _privateConstructorUsedError;
  @JsonKey(name: "about_me")
  String? get aboutMe => throw _privateConstructorUsedError;
  bool? get employed => throw _privateConstructorUsedError;
  int? get cleanliness => throw _privateConstructorUsedError;
  @JsonKey(name: "noise_level")
  int? get noiseLevel => throw _privateConstructorUsedError;
  int? get sociability => throw _privateConstructorUsedError;
  @JsonKey(name: "guests_allowed")
  bool? get guestsAllowed => throw _privateConstructorUsedError;
  @JsonKey(name: "smoking_preference")
  String? get smokingPreference => throw _privateConstructorUsedError;
  @JsonKey(name: "alcohol_preference")
  String? get alcoholPreference => throw _privateConstructorUsedError;
  @JsonKey(name: "cooking_habits")
  bool? get cookingHabits => throw _privateConstructorUsedError;
  @JsonKey(
      name: "pets_preference",
      fromJson: PetsPreferenceConverter.fromJson,
      toJson: PetsPreferenceConverter.toJson)
  String? get petsPreference => throw _privateConstructorUsedError;
  @JsonKey(name: "wakeup_time")
  String? get wakeupTime => throw _privateConstructorUsedError;
  @JsonKey(name: "sleep_time")
  String? get sleepTime => throw _privateConstructorUsedError;
  @JsonKey(name: "preferred_language")
  String? get preferredLanguage => throw _privateConstructorUsedError;
  @JsonKey(name: "origin_country_iso2")
  String? get originCountryIso2 =>
      throw _privateConstructorUsedError; // ── "What I'm looking for" matching preferences ──
  @JsonKey(name: "birth_year")
  int? get birthYear => throw _privateConstructorUsedError;
  @JsonKey(name: "budget_min")
  int? get budgetMin => throw _privateConstructorUsedError;
  @JsonKey(name: "budget_max")
  int? get budgetMax => throw _privateConstructorUsedError;
  @JsonKey(name: "pref_roommate_gender")
  String? get prefRoommateGender => throw _privateConstructorUsedError;
  @JsonKey(name: "pref_age_min")
  int? get prefAgeMin => throw _privateConstructorUsedError;
  @JsonKey(name: "pref_age_max")
  int? get prefAgeMax => throw _privateConstructorUsedError;
  @JsonKey(name: "pref_budget_overlap_required")
  bool? get prefBudgetOverlapRequired => throw _privateConstructorUsedError;
  @JsonKey(name: "dealbreakers")
  List<String>? get dealbreakers => throw _privateConstructorUsedError;
  @JsonKey(name: "top_priorities")
  List<String>? get topPriorities => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String? get updatedAt => throw _privateConstructorUsedError;
  UserProfileRegion? get region => throw _privateConstructorUsedError;
  UserProfileUniversity? get university => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      int id,
      @JsonKey(name: "user_id") int userId,
      String? name,
      int? gender,
      @JsonKey(name: "is_verified") bool? isVerified,
      @JsonKey(name: "region_id") int? regionId,
      @JsonKey(name: "university_id") int? universityId,
      @JsonKey(name: "avatar_url") String? avatarUrl,
      @JsonKey(name: "telegram_avatar_url") String? telegramAvatarUrl,
      String? telegram,
      double? rating,
      @JsonKey(name: "about_me") String? aboutMe,
      bool? employed,
      int? cleanliness,
      @JsonKey(name: "noise_level") int? noiseLevel,
      int? sociability,
      @JsonKey(name: "guests_allowed") bool? guestsAllowed,
      @JsonKey(name: "smoking_preference") String? smokingPreference,
      @JsonKey(name: "alcohol_preference") String? alcoholPreference,
      @JsonKey(name: "cooking_habits") bool? cookingHabits,
      @JsonKey(
          name: "pets_preference",
          fromJson: PetsPreferenceConverter.fromJson,
          toJson: PetsPreferenceConverter.toJson)
      String? petsPreference,
      @JsonKey(name: "wakeup_time") String? wakeupTime,
      @JsonKey(name: "sleep_time") String? sleepTime,
      @JsonKey(name: "preferred_language") String? preferredLanguage,
      @JsonKey(name: "origin_country_iso2") String? originCountryIso2,
      @JsonKey(name: "birth_year") int? birthYear,
      @JsonKey(name: "budget_min") int? budgetMin,
      @JsonKey(name: "budget_max") int? budgetMax,
      @JsonKey(name: "pref_roommate_gender") String? prefRoommateGender,
      @JsonKey(name: "pref_age_min") int? prefAgeMin,
      @JsonKey(name: "pref_age_max") int? prefAgeMax,
      @JsonKey(name: "pref_budget_overlap_required")
      bool? prefBudgetOverlapRequired,
      @JsonKey(name: "dealbreakers") List<String>? dealbreakers,
      @JsonKey(name: "top_priorities") List<String>? topPriorities,
      @JsonKey(name: "created_at") String? createdAt,
      @JsonKey(name: "updated_at") String? updatedAt,
      UserProfileRegion? region,
      UserProfileUniversity? university});

  $UserProfileRegionCopyWith<$Res>? get region;
  $UserProfileUniversityCopyWith<$Res>? get university;
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = freezed,
    Object? gender = freezed,
    Object? isVerified = freezed,
    Object? regionId = freezed,
    Object? universityId = freezed,
    Object? avatarUrl = freezed,
    Object? telegramAvatarUrl = freezed,
    Object? telegram = freezed,
    Object? rating = freezed,
    Object? aboutMe = freezed,
    Object? employed = freezed,
    Object? cleanliness = freezed,
    Object? noiseLevel = freezed,
    Object? sociability = freezed,
    Object? guestsAllowed = freezed,
    Object? smokingPreference = freezed,
    Object? alcoholPreference = freezed,
    Object? cookingHabits = freezed,
    Object? petsPreference = freezed,
    Object? wakeupTime = freezed,
    Object? sleepTime = freezed,
    Object? preferredLanguage = freezed,
    Object? originCountryIso2 = freezed,
    Object? birthYear = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? prefRoommateGender = freezed,
    Object? prefAgeMin = freezed,
    Object? prefAgeMax = freezed,
    Object? prefBudgetOverlapRequired = freezed,
    Object? dealbreakers = freezed,
    Object? topPriorities = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? region = freezed,
    Object? university = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      regionId: freezed == regionId
          ? _value.regionId
          : regionId // ignore: cast_nullable_to_non_nullable
              as int?,
      universityId: freezed == universityId
          ? _value.universityId
          : universityId // ignore: cast_nullable_to_non_nullable
              as int?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      telegramAvatarUrl: freezed == telegramAvatarUrl
          ? _value.telegramAvatarUrl
          : telegramAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      telegram: freezed == telegram
          ? _value.telegram
          : telegram // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      aboutMe: freezed == aboutMe
          ? _value.aboutMe
          : aboutMe // ignore: cast_nullable_to_non_nullable
              as String?,
      employed: freezed == employed
          ? _value.employed
          : employed // ignore: cast_nullable_to_non_nullable
              as bool?,
      cleanliness: freezed == cleanliness
          ? _value.cleanliness
          : cleanliness // ignore: cast_nullable_to_non_nullable
              as int?,
      noiseLevel: freezed == noiseLevel
          ? _value.noiseLevel
          : noiseLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      sociability: freezed == sociability
          ? _value.sociability
          : sociability // ignore: cast_nullable_to_non_nullable
              as int?,
      guestsAllowed: freezed == guestsAllowed
          ? _value.guestsAllowed
          : guestsAllowed // ignore: cast_nullable_to_non_nullable
              as bool?,
      smokingPreference: freezed == smokingPreference
          ? _value.smokingPreference
          : smokingPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      alcoholPreference: freezed == alcoholPreference
          ? _value.alcoholPreference
          : alcoholPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      cookingHabits: freezed == cookingHabits
          ? _value.cookingHabits
          : cookingHabits // ignore: cast_nullable_to_non_nullable
              as bool?,
      petsPreference: freezed == petsPreference
          ? _value.petsPreference
          : petsPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      wakeupTime: freezed == wakeupTime
          ? _value.wakeupTime
          : wakeupTime // ignore: cast_nullable_to_non_nullable
              as String?,
      sleepTime: freezed == sleepTime
          ? _value.sleepTime
          : sleepTime // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLanguage: freezed == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      originCountryIso2: freezed == originCountryIso2
          ? _value.originCountryIso2
          : originCountryIso2 // ignore: cast_nullable_to_non_nullable
              as String?,
      birthYear: freezed == birthYear
          ? _value.birthYear
          : birthYear // ignore: cast_nullable_to_non_nullable
              as int?,
      budgetMin: freezed == budgetMin
          ? _value.budgetMin
          : budgetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      budgetMax: freezed == budgetMax
          ? _value.budgetMax
          : budgetMax // ignore: cast_nullable_to_non_nullable
              as int?,
      prefRoommateGender: freezed == prefRoommateGender
          ? _value.prefRoommateGender
          : prefRoommateGender // ignore: cast_nullable_to_non_nullable
              as String?,
      prefAgeMin: freezed == prefAgeMin
          ? _value.prefAgeMin
          : prefAgeMin // ignore: cast_nullable_to_non_nullable
              as int?,
      prefAgeMax: freezed == prefAgeMax
          ? _value.prefAgeMax
          : prefAgeMax // ignore: cast_nullable_to_non_nullable
              as int?,
      prefBudgetOverlapRequired: freezed == prefBudgetOverlapRequired
          ? _value.prefBudgetOverlapRequired
          : prefBudgetOverlapRequired // ignore: cast_nullable_to_non_nullable
              as bool?,
      dealbreakers: freezed == dealbreakers
          ? _value.dealbreakers
          : dealbreakers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      topPriorities: freezed == topPriorities
          ? _value.topPriorities
          : topPriorities // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as UserProfileRegion?,
      university: freezed == university
          ? _value.university
          : university // ignore: cast_nullable_to_non_nullable
              as UserProfileUniversity?,
    ) as $Val);
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileRegionCopyWith<$Res>? get region {
    if (_value.region == null) {
      return null;
    }

    return $UserProfileRegionCopyWith<$Res>(_value.region!, (value) {
      return _then(_value.copyWith(region: value) as $Val);
    });
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileUniversityCopyWith<$Res>? get university {
    if (_value.university == null) {
      return null;
    }

    return $UserProfileUniversityCopyWith<$Res>(_value.university!, (value) {
      return _then(_value.copyWith(university: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      int id,
      @JsonKey(name: "user_id") int userId,
      String? name,
      int? gender,
      @JsonKey(name: "is_verified") bool? isVerified,
      @JsonKey(name: "region_id") int? regionId,
      @JsonKey(name: "university_id") int? universityId,
      @JsonKey(name: "avatar_url") String? avatarUrl,
      @JsonKey(name: "telegram_avatar_url") String? telegramAvatarUrl,
      String? telegram,
      double? rating,
      @JsonKey(name: "about_me") String? aboutMe,
      bool? employed,
      int? cleanliness,
      @JsonKey(name: "noise_level") int? noiseLevel,
      int? sociability,
      @JsonKey(name: "guests_allowed") bool? guestsAllowed,
      @JsonKey(name: "smoking_preference") String? smokingPreference,
      @JsonKey(name: "alcohol_preference") String? alcoholPreference,
      @JsonKey(name: "cooking_habits") bool? cookingHabits,
      @JsonKey(
          name: "pets_preference",
          fromJson: PetsPreferenceConverter.fromJson,
          toJson: PetsPreferenceConverter.toJson)
      String? petsPreference,
      @JsonKey(name: "wakeup_time") String? wakeupTime,
      @JsonKey(name: "sleep_time") String? sleepTime,
      @JsonKey(name: "preferred_language") String? preferredLanguage,
      @JsonKey(name: "origin_country_iso2") String? originCountryIso2,
      @JsonKey(name: "birth_year") int? birthYear,
      @JsonKey(name: "budget_min") int? budgetMin,
      @JsonKey(name: "budget_max") int? budgetMax,
      @JsonKey(name: "pref_roommate_gender") String? prefRoommateGender,
      @JsonKey(name: "pref_age_min") int? prefAgeMin,
      @JsonKey(name: "pref_age_max") int? prefAgeMax,
      @JsonKey(name: "pref_budget_overlap_required")
      bool? prefBudgetOverlapRequired,
      @JsonKey(name: "dealbreakers") List<String>? dealbreakers,
      @JsonKey(name: "top_priorities") List<String>? topPriorities,
      @JsonKey(name: "created_at") String? createdAt,
      @JsonKey(name: "updated_at") String? updatedAt,
      UserProfileRegion? region,
      UserProfileUniversity? university});

  @override
  $UserProfileRegionCopyWith<$Res>? get region;
  @override
  $UserProfileUniversityCopyWith<$Res>? get university;
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = freezed,
    Object? gender = freezed,
    Object? isVerified = freezed,
    Object? regionId = freezed,
    Object? universityId = freezed,
    Object? avatarUrl = freezed,
    Object? telegramAvatarUrl = freezed,
    Object? telegram = freezed,
    Object? rating = freezed,
    Object? aboutMe = freezed,
    Object? employed = freezed,
    Object? cleanliness = freezed,
    Object? noiseLevel = freezed,
    Object? sociability = freezed,
    Object? guestsAllowed = freezed,
    Object? smokingPreference = freezed,
    Object? alcoholPreference = freezed,
    Object? cookingHabits = freezed,
    Object? petsPreference = freezed,
    Object? wakeupTime = freezed,
    Object? sleepTime = freezed,
    Object? preferredLanguage = freezed,
    Object? originCountryIso2 = freezed,
    Object? birthYear = freezed,
    Object? budgetMin = freezed,
    Object? budgetMax = freezed,
    Object? prefRoommateGender = freezed,
    Object? prefAgeMin = freezed,
    Object? prefAgeMax = freezed,
    Object? prefBudgetOverlapRequired = freezed,
    Object? dealbreakers = freezed,
    Object? topPriorities = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? region = freezed,
    Object? university = freezed,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      regionId: freezed == regionId
          ? _value.regionId
          : regionId // ignore: cast_nullable_to_non_nullable
              as int?,
      universityId: freezed == universityId
          ? _value.universityId
          : universityId // ignore: cast_nullable_to_non_nullable
              as int?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      telegramAvatarUrl: freezed == telegramAvatarUrl
          ? _value.telegramAvatarUrl
          : telegramAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      telegram: freezed == telegram
          ? _value.telegram
          : telegram // ignore: cast_nullable_to_non_nullable
              as String?,
      rating: freezed == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double?,
      aboutMe: freezed == aboutMe
          ? _value.aboutMe
          : aboutMe // ignore: cast_nullable_to_non_nullable
              as String?,
      employed: freezed == employed
          ? _value.employed
          : employed // ignore: cast_nullable_to_non_nullable
              as bool?,
      cleanliness: freezed == cleanliness
          ? _value.cleanliness
          : cleanliness // ignore: cast_nullable_to_non_nullable
              as int?,
      noiseLevel: freezed == noiseLevel
          ? _value.noiseLevel
          : noiseLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      sociability: freezed == sociability
          ? _value.sociability
          : sociability // ignore: cast_nullable_to_non_nullable
              as int?,
      guestsAllowed: freezed == guestsAllowed
          ? _value.guestsAllowed
          : guestsAllowed // ignore: cast_nullable_to_non_nullable
              as bool?,
      smokingPreference: freezed == smokingPreference
          ? _value.smokingPreference
          : smokingPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      alcoholPreference: freezed == alcoholPreference
          ? _value.alcoholPreference
          : alcoholPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      cookingHabits: freezed == cookingHabits
          ? _value.cookingHabits
          : cookingHabits // ignore: cast_nullable_to_non_nullable
              as bool?,
      petsPreference: freezed == petsPreference
          ? _value.petsPreference
          : petsPreference // ignore: cast_nullable_to_non_nullable
              as String?,
      wakeupTime: freezed == wakeupTime
          ? _value.wakeupTime
          : wakeupTime // ignore: cast_nullable_to_non_nullable
              as String?,
      sleepTime: freezed == sleepTime
          ? _value.sleepTime
          : sleepTime // ignore: cast_nullable_to_non_nullable
              as String?,
      preferredLanguage: freezed == preferredLanguage
          ? _value.preferredLanguage
          : preferredLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      originCountryIso2: freezed == originCountryIso2
          ? _value.originCountryIso2
          : originCountryIso2 // ignore: cast_nullable_to_non_nullable
              as String?,
      birthYear: freezed == birthYear
          ? _value.birthYear
          : birthYear // ignore: cast_nullable_to_non_nullable
              as int?,
      budgetMin: freezed == budgetMin
          ? _value.budgetMin
          : budgetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      budgetMax: freezed == budgetMax
          ? _value.budgetMax
          : budgetMax // ignore: cast_nullable_to_non_nullable
              as int?,
      prefRoommateGender: freezed == prefRoommateGender
          ? _value.prefRoommateGender
          : prefRoommateGender // ignore: cast_nullable_to_non_nullable
              as String?,
      prefAgeMin: freezed == prefAgeMin
          ? _value.prefAgeMin
          : prefAgeMin // ignore: cast_nullable_to_non_nullable
              as int?,
      prefAgeMax: freezed == prefAgeMax
          ? _value.prefAgeMax
          : prefAgeMax // ignore: cast_nullable_to_non_nullable
              as int?,
      prefBudgetOverlapRequired: freezed == prefBudgetOverlapRequired
          ? _value.prefBudgetOverlapRequired
          : prefBudgetOverlapRequired // ignore: cast_nullable_to_non_nullable
              as bool?,
      dealbreakers: freezed == dealbreakers
          ? _value._dealbreakers
          : dealbreakers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      topPriorities: freezed == topPriorities
          ? _value._topPriorities
          : topPriorities // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      region: freezed == region
          ? _value.region
          : region // ignore: cast_nullable_to_non_nullable
              as UserProfileRegion?,
      university: freezed == university
          ? _value.university
          : university // ignore: cast_nullable_to_non_nullable
              as UserProfileUniversity?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      required this.id,
      @JsonKey(name: "user_id") required this.userId,
      this.name,
      this.gender,
      @JsonKey(name: "is_verified") this.isVerified,
      @JsonKey(name: "region_id") this.regionId,
      @JsonKey(name: "university_id") this.universityId,
      @JsonKey(name: "avatar_url") this.avatarUrl,
      @JsonKey(name: "telegram_avatar_url") this.telegramAvatarUrl,
      this.telegram,
      this.rating,
      @JsonKey(name: "about_me") this.aboutMe,
      this.employed,
      this.cleanliness,
      @JsonKey(name: "noise_level") this.noiseLevel,
      this.sociability,
      @JsonKey(name: "guests_allowed") this.guestsAllowed,
      @JsonKey(name: "smoking_preference") this.smokingPreference,
      @JsonKey(name: "alcohol_preference") this.alcoholPreference,
      @JsonKey(name: "cooking_habits") this.cookingHabits,
      @JsonKey(
          name: "pets_preference",
          fromJson: PetsPreferenceConverter.fromJson,
          toJson: PetsPreferenceConverter.toJson)
      this.petsPreference,
      @JsonKey(name: "wakeup_time") this.wakeupTime,
      @JsonKey(name: "sleep_time") this.sleepTime,
      @JsonKey(name: "preferred_language") this.preferredLanguage,
      @JsonKey(name: "origin_country_iso2") this.originCountryIso2,
      @JsonKey(name: "birth_year") this.birthYear,
      @JsonKey(name: "budget_min") this.budgetMin,
      @JsonKey(name: "budget_max") this.budgetMax,
      @JsonKey(name: "pref_roommate_gender") this.prefRoommateGender,
      @JsonKey(name: "pref_age_min") this.prefAgeMin,
      @JsonKey(name: "pref_age_max") this.prefAgeMax,
      @JsonKey(name: "pref_budget_overlap_required")
      this.prefBudgetOverlapRequired,
      @JsonKey(name: "dealbreakers") final List<String>? dealbreakers,
      @JsonKey(name: "top_priorities") final List<String>? topPriorities,
      @JsonKey(name: "created_at") this.createdAt,
      @JsonKey(name: "updated_at") this.updatedAt,
      this.region,
      this.university})
      : _dealbreakers = dealbreakers,
        _topPriorities = topPriorities;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  final int id;
  @override
  @JsonKey(name: "user_id")
  final int userId;
  @override
  final String? name;
  @override
  final int? gender;
  @override
  @JsonKey(name: "is_verified")
  final bool? isVerified;
  @override
  @JsonKey(name: "region_id")
  final int? regionId;
  @override
  @JsonKey(name: "university_id")
  final int? universityId;
  @override
  @JsonKey(name: "avatar_url")
  final String? avatarUrl;
  @override
  @JsonKey(name: "telegram_avatar_url")
  final String? telegramAvatarUrl;
  @override
  final String? telegram;
  @override
  final double? rating;
  @override
  @JsonKey(name: "about_me")
  final String? aboutMe;
  @override
  final bool? employed;
  @override
  final int? cleanliness;
  @override
  @JsonKey(name: "noise_level")
  final int? noiseLevel;
  @override
  final int? sociability;
  @override
  @JsonKey(name: "guests_allowed")
  final bool? guestsAllowed;
  @override
  @JsonKey(name: "smoking_preference")
  final String? smokingPreference;
  @override
  @JsonKey(name: "alcohol_preference")
  final String? alcoholPreference;
  @override
  @JsonKey(name: "cooking_habits")
  final bool? cookingHabits;
  @override
  @JsonKey(
      name: "pets_preference",
      fromJson: PetsPreferenceConverter.fromJson,
      toJson: PetsPreferenceConverter.toJson)
  final String? petsPreference;
  @override
  @JsonKey(name: "wakeup_time")
  final String? wakeupTime;
  @override
  @JsonKey(name: "sleep_time")
  final String? sleepTime;
  @override
  @JsonKey(name: "preferred_language")
  final String? preferredLanguage;
  @override
  @JsonKey(name: "origin_country_iso2")
  final String? originCountryIso2;
// ── "What I'm looking for" matching preferences ──
  @override
  @JsonKey(name: "birth_year")
  final int? birthYear;
  @override
  @JsonKey(name: "budget_min")
  final int? budgetMin;
  @override
  @JsonKey(name: "budget_max")
  final int? budgetMax;
  @override
  @JsonKey(name: "pref_roommate_gender")
  final String? prefRoommateGender;
  @override
  @JsonKey(name: "pref_age_min")
  final int? prefAgeMin;
  @override
  @JsonKey(name: "pref_age_max")
  final int? prefAgeMax;
  @override
  @JsonKey(name: "pref_budget_overlap_required")
  final bool? prefBudgetOverlapRequired;
  final List<String>? _dealbreakers;
  @override
  @JsonKey(name: "dealbreakers")
  List<String>? get dealbreakers {
    final value = _dealbreakers;
    if (value == null) return null;
    if (_dealbreakers is EqualUnmodifiableListView) return _dealbreakers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _topPriorities;
  @override
  @JsonKey(name: "top_priorities")
  List<String>? get topPriorities {
    final value = _topPriorities;
    if (value == null) return null;
    if (_topPriorities is EqualUnmodifiableListView) return _topPriorities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "created_at")
  final String? createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String? updatedAt;
  @override
  final UserProfileRegion? region;
  @override
  final UserProfileUniversity? university;

  @override
  String toString() {
    return 'UserProfile(id: $id, userId: $userId, name: $name, gender: $gender, isVerified: $isVerified, regionId: $regionId, universityId: $universityId, avatarUrl: $avatarUrl, telegramAvatarUrl: $telegramAvatarUrl, telegram: $telegram, rating: $rating, aboutMe: $aboutMe, employed: $employed, cleanliness: $cleanliness, noiseLevel: $noiseLevel, sociability: $sociability, guestsAllowed: $guestsAllowed, smokingPreference: $smokingPreference, alcoholPreference: $alcoholPreference, cookingHabits: $cookingHabits, petsPreference: $petsPreference, wakeupTime: $wakeupTime, sleepTime: $sleepTime, preferredLanguage: $preferredLanguage, originCountryIso2: $originCountryIso2, birthYear: $birthYear, budgetMin: $budgetMin, budgetMax: $budgetMax, prefRoommateGender: $prefRoommateGender, prefAgeMin: $prefAgeMin, prefAgeMax: $prefAgeMax, prefBudgetOverlapRequired: $prefBudgetOverlapRequired, dealbreakers: $dealbreakers, topPriorities: $topPriorities, createdAt: $createdAt, updatedAt: $updatedAt, region: $region, university: $university)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.regionId, regionId) ||
                other.regionId == regionId) &&
            (identical(other.universityId, universityId) ||
                other.universityId == universityId) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.telegramAvatarUrl, telegramAvatarUrl) ||
                other.telegramAvatarUrl == telegramAvatarUrl) &&
            (identical(other.telegram, telegram) ||
                other.telegram == telegram) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.aboutMe, aboutMe) || other.aboutMe == aboutMe) &&
            (identical(other.employed, employed) ||
                other.employed == employed) &&
            (identical(other.cleanliness, cleanliness) ||
                other.cleanliness == cleanliness) &&
            (identical(other.noiseLevel, noiseLevel) ||
                other.noiseLevel == noiseLevel) &&
            (identical(other.sociability, sociability) ||
                other.sociability == sociability) &&
            (identical(other.guestsAllowed, guestsAllowed) ||
                other.guestsAllowed == guestsAllowed) &&
            (identical(other.smokingPreference, smokingPreference) ||
                other.smokingPreference == smokingPreference) &&
            (identical(other.alcoholPreference, alcoholPreference) ||
                other.alcoholPreference == alcoholPreference) &&
            (identical(other.cookingHabits, cookingHabits) ||
                other.cookingHabits == cookingHabits) &&
            (identical(other.petsPreference, petsPreference) ||
                other.petsPreference == petsPreference) &&
            (identical(other.wakeupTime, wakeupTime) ||
                other.wakeupTime == wakeupTime) &&
            (identical(other.sleepTime, sleepTime) ||
                other.sleepTime == sleepTime) &&
            (identical(other.preferredLanguage, preferredLanguage) ||
                other.preferredLanguage == preferredLanguage) &&
            (identical(other.originCountryIso2, originCountryIso2) ||
                other.originCountryIso2 == originCountryIso2) &&
            (identical(other.birthYear, birthYear) ||
                other.birthYear == birthYear) &&
            (identical(other.budgetMin, budgetMin) ||
                other.budgetMin == budgetMin) &&
            (identical(other.budgetMax, budgetMax) ||
                other.budgetMax == budgetMax) &&
            (identical(other.prefRoommateGender, prefRoommateGender) ||
                other.prefRoommateGender == prefRoommateGender) &&
            (identical(other.prefAgeMin, prefAgeMin) ||
                other.prefAgeMin == prefAgeMin) &&
            (identical(other.prefAgeMax, prefAgeMax) ||
                other.prefAgeMax == prefAgeMax) &&
            (identical(other.prefBudgetOverlapRequired,
                    prefBudgetOverlapRequired) ||
                other.prefBudgetOverlapRequired == prefBudgetOverlapRequired) &&
            const DeepCollectionEquality()
                .equals(other._dealbreakers, _dealbreakers) &&
            const DeepCollectionEquality()
                .equals(other._topPriorities, _topPriorities) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.region, region) || other.region == region) &&
            (identical(other.university, university) ||
                other.university == university));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        name,
        gender,
        isVerified,
        regionId,
        universityId,
        avatarUrl,
        telegramAvatarUrl,
        telegram,
        rating,
        aboutMe,
        employed,
        cleanliness,
        noiseLevel,
        sociability,
        guestsAllowed,
        smokingPreference,
        alcoholPreference,
        cookingHabits,
        petsPreference,
        wakeupTime,
        sleepTime,
        preferredLanguage,
        originCountryIso2,
        birthYear,
        budgetMin,
        budgetMax,
        prefRoommateGender,
        prefAgeMin,
        prefAgeMax,
        prefBudgetOverlapRequired,
        const DeepCollectionEquality().hash(_dealbreakers),
        const DeepCollectionEquality().hash(_topPriorities),
        createdAt,
        updatedAt,
        region,
        university
      ]);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      required final int id,
      @JsonKey(name: "user_id") required final int userId,
      final String? name,
      final int? gender,
      @JsonKey(name: "is_verified") final bool? isVerified,
      @JsonKey(name: "region_id") final int? regionId,
      @JsonKey(name: "university_id") final int? universityId,
      @JsonKey(name: "avatar_url") final String? avatarUrl,
      @JsonKey(name: "telegram_avatar_url") final String? telegramAvatarUrl,
      final String? telegram,
      final double? rating,
      @JsonKey(name: "about_me") final String? aboutMe,
      final bool? employed,
      final int? cleanliness,
      @JsonKey(name: "noise_level") final int? noiseLevel,
      final int? sociability,
      @JsonKey(name: "guests_allowed") final bool? guestsAllowed,
      @JsonKey(name: "smoking_preference") final String? smokingPreference,
      @JsonKey(name: "alcohol_preference") final String? alcoholPreference,
      @JsonKey(name: "cooking_habits") final bool? cookingHabits,
      @JsonKey(
          name: "pets_preference",
          fromJson: PetsPreferenceConverter.fromJson,
          toJson: PetsPreferenceConverter.toJson)
      final String? petsPreference,
      @JsonKey(name: "wakeup_time") final String? wakeupTime,
      @JsonKey(name: "sleep_time") final String? sleepTime,
      @JsonKey(name: "preferred_language") final String? preferredLanguage,
      @JsonKey(name: "origin_country_iso2") final String? originCountryIso2,
      @JsonKey(name: "birth_year") final int? birthYear,
      @JsonKey(name: "budget_min") final int? budgetMin,
      @JsonKey(name: "budget_max") final int? budgetMax,
      @JsonKey(name: "pref_roommate_gender") final String? prefRoommateGender,
      @JsonKey(name: "pref_age_min") final int? prefAgeMin,
      @JsonKey(name: "pref_age_max") final int? prefAgeMax,
      @JsonKey(name: "pref_budget_overlap_required")
      final bool? prefBudgetOverlapRequired,
      @JsonKey(name: "dealbreakers") final List<String>? dealbreakers,
      @JsonKey(name: "top_priorities") final List<String>? topPriorities,
      @JsonKey(name: "created_at") final String? createdAt,
      @JsonKey(name: "updated_at") final String? updatedAt,
      final UserProfileRegion? region,
      final UserProfileUniversity? university}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  int get id;
  @override
  @JsonKey(name: "user_id")
  int get userId;
  @override
  String? get name;
  @override
  int? get gender;
  @override
  @JsonKey(name: "is_verified")
  bool? get isVerified;
  @override
  @JsonKey(name: "region_id")
  int? get regionId;
  @override
  @JsonKey(name: "university_id")
  int? get universityId;
  @override
  @JsonKey(name: "avatar_url")
  String? get avatarUrl;
  @override
  @JsonKey(name: "telegram_avatar_url")
  String? get telegramAvatarUrl;
  @override
  String? get telegram;
  @override
  double? get rating;
  @override
  @JsonKey(name: "about_me")
  String? get aboutMe;
  @override
  bool? get employed;
  @override
  int? get cleanliness;
  @override
  @JsonKey(name: "noise_level")
  int? get noiseLevel;
  @override
  int? get sociability;
  @override
  @JsonKey(name: "guests_allowed")
  bool? get guestsAllowed;
  @override
  @JsonKey(name: "smoking_preference")
  String? get smokingPreference;
  @override
  @JsonKey(name: "alcohol_preference")
  String? get alcoholPreference;
  @override
  @JsonKey(name: "cooking_habits")
  bool? get cookingHabits;
  @override
  @JsonKey(
      name: "pets_preference",
      fromJson: PetsPreferenceConverter.fromJson,
      toJson: PetsPreferenceConverter.toJson)
  String? get petsPreference;
  @override
  @JsonKey(name: "wakeup_time")
  String? get wakeupTime;
  @override
  @JsonKey(name: "sleep_time")
  String? get sleepTime;
  @override
  @JsonKey(name: "preferred_language")
  String? get preferredLanguage;
  @override
  @JsonKey(name: "origin_country_iso2")
  String?
      get originCountryIso2; // ── "What I'm looking for" matching preferences ──
  @override
  @JsonKey(name: "birth_year")
  int? get birthYear;
  @override
  @JsonKey(name: "budget_min")
  int? get budgetMin;
  @override
  @JsonKey(name: "budget_max")
  int? get budgetMax;
  @override
  @JsonKey(name: "pref_roommate_gender")
  String? get prefRoommateGender;
  @override
  @JsonKey(name: "pref_age_min")
  int? get prefAgeMin;
  @override
  @JsonKey(name: "pref_age_max")
  int? get prefAgeMax;
  @override
  @JsonKey(name: "pref_budget_overlap_required")
  bool? get prefBudgetOverlapRequired;
  @override
  @JsonKey(name: "dealbreakers")
  List<String>? get dealbreakers;
  @override
  @JsonKey(name: "top_priorities")
  List<String>? get topPriorities;
  @override
  @JsonKey(name: "created_at")
  String? get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String? get updatedAt;
  @override
  UserProfileRegion? get region;
  @override
  UserProfileUniversity? get university;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfileRegion _$UserProfileRegionFromJson(Map<String, dynamic> json) {
  return _UserProfileRegion.fromJson(json);
}

/// @nodoc
mixin _$UserProfileRegion {
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String? get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String? get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String? get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_uz")
  String? get shortNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_ru")
  String? get shortNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_en")
  String? get shortNameEn => throw _privateConstructorUsedError;

  /// Serializes this UserProfileRegion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileRegion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileRegionCopyWith<UserProfileRegion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileRegionCopyWith<$Res> {
  factory $UserProfileRegionCopyWith(
          UserProfileRegion value, $Res Function(UserProfileRegion) then) =
      _$UserProfileRegionCopyWithImpl<$Res, UserProfileRegion>;
  @useResult
  $Res call(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      int id,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn,
      @JsonKey(name: "short_name_uz") String? shortNameUz,
      @JsonKey(name: "short_name_ru") String? shortNameRu,
      @JsonKey(name: "short_name_en") String? shortNameEn});
}

/// @nodoc
class _$UserProfileRegionCopyWithImpl<$Res, $Val extends UserProfileRegion>
    implements $UserProfileRegionCopyWith<$Res> {
  _$UserProfileRegionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileRegion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
    Object? shortNameUz = freezed,
    Object? shortNameRu = freezed,
    Object? shortNameEn = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameUz: freezed == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameRu: freezed == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameEn: freezed == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileRegionImplCopyWith<$Res>
    implements $UserProfileRegionCopyWith<$Res> {
  factory _$$UserProfileRegionImplCopyWith(_$UserProfileRegionImpl value,
          $Res Function(_$UserProfileRegionImpl) then) =
      __$$UserProfileRegionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      int id,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn,
      @JsonKey(name: "short_name_uz") String? shortNameUz,
      @JsonKey(name: "short_name_ru") String? shortNameRu,
      @JsonKey(name: "short_name_en") String? shortNameEn});
}

/// @nodoc
class __$$UserProfileRegionImplCopyWithImpl<$Res>
    extends _$UserProfileRegionCopyWithImpl<$Res, _$UserProfileRegionImpl>
    implements _$$UserProfileRegionImplCopyWith<$Res> {
  __$$UserProfileRegionImplCopyWithImpl(_$UserProfileRegionImpl _value,
      $Res Function(_$UserProfileRegionImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfileRegion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
    Object? shortNameUz = freezed,
    Object? shortNameRu = freezed,
    Object? shortNameEn = freezed,
  }) {
    return _then(_$UserProfileRegionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameUz: freezed == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameRu: freezed == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameEn: freezed == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileRegionImpl implements _UserProfileRegion {
  const _$UserProfileRegionImpl(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      required this.id,
      @JsonKey(name: "name_uz") this.nameUz,
      @JsonKey(name: "name_ru") this.nameRu,
      @JsonKey(name: "name_en") this.nameEn,
      @JsonKey(name: "short_name_uz") this.shortNameUz,
      @JsonKey(name: "short_name_ru") this.shortNameRu,
      @JsonKey(name: "short_name_en") this.shortNameEn});

  factory _$UserProfileRegionImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileRegionImplFromJson(json);

  @override
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String? nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String? nameRu;
  @override
  @JsonKey(name: "name_en")
  final String? nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  final String? shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  final String? shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  final String? shortNameEn;

  @override
  String toString() {
    return 'UserProfileRegion(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileRegionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.shortNameUz, shortNameUz) ||
                other.shortNameUz == shortNameUz) &&
            (identical(other.shortNameRu, shortNameRu) ||
                other.shortNameRu == shortNameRu) &&
            (identical(other.shortNameEn, shortNameEn) ||
                other.shortNameEn == shortNameEn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameUz, nameRu, nameEn,
      shortNameUz, shortNameRu, shortNameEn);

  /// Create a copy of UserProfileRegion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileRegionImplCopyWith<_$UserProfileRegionImpl> get copyWith =>
      __$$UserProfileRegionImplCopyWithImpl<_$UserProfileRegionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileRegionImplToJson(
      this,
    );
  }
}

abstract class _UserProfileRegion implements UserProfileRegion {
  const factory _UserProfileRegion(
          {@JsonKey(
              fromJson: NullableIntConverter.convertFromJson,
              toJson: NullableIntConverter.convertToJson)
          required final int id,
          @JsonKey(name: "name_uz") final String? nameUz,
          @JsonKey(name: "name_ru") final String? nameRu,
          @JsonKey(name: "name_en") final String? nameEn,
          @JsonKey(name: "short_name_uz") final String? shortNameUz,
          @JsonKey(name: "short_name_ru") final String? shortNameRu,
          @JsonKey(name: "short_name_en") final String? shortNameEn}) =
      _$UserProfileRegionImpl;

  factory _UserProfileRegion.fromJson(Map<String, dynamic> json) =
      _$UserProfileRegionImpl.fromJson;

  @override
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String? get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String? get nameRu;
  @override
  @JsonKey(name: "name_en")
  String? get nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  String? get shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  String? get shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  String? get shortNameEn;

  /// Create a copy of UserProfileRegion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileRegionImplCopyWith<_$UserProfileRegionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProfileUniversity _$UserProfileUniversityFromJson(
    Map<String, dynamic> json) {
  return _UserProfileUniversity.fromJson(json);
}

/// @nodoc
mixin _$UserProfileUniversity {
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String? get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String? get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String? get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_uz")
  String? get shortNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_ru")
  String? get shortNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_en")
  String? get shortNameEn => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get website => throw _privateConstructorUsedError;

  /// Serializes this UserProfileUniversity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileUniversity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileUniversityCopyWith<UserProfileUniversity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileUniversityCopyWith<$Res> {
  factory $UserProfileUniversityCopyWith(UserProfileUniversity value,
          $Res Function(UserProfileUniversity) then) =
      _$UserProfileUniversityCopyWithImpl<$Res, UserProfileUniversity>;
  @useResult
  $Res call(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      int id,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn,
      @JsonKey(name: "short_name_uz") String? shortNameUz,
      @JsonKey(name: "short_name_ru") String? shortNameRu,
      @JsonKey(name: "short_name_en") String? shortNameEn,
      String? address,
      String? website});
}

/// @nodoc
class _$UserProfileUniversityCopyWithImpl<$Res,
        $Val extends UserProfileUniversity>
    implements $UserProfileUniversityCopyWith<$Res> {
  _$UserProfileUniversityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileUniversity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
    Object? shortNameUz = freezed,
    Object? shortNameRu = freezed,
    Object? shortNameEn = freezed,
    Object? address = freezed,
    Object? website = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameUz: freezed == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameRu: freezed == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameEn: freezed == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileUniversityImplCopyWith<$Res>
    implements $UserProfileUniversityCopyWith<$Res> {
  factory _$$UserProfileUniversityImplCopyWith(
          _$UserProfileUniversityImpl value,
          $Res Function(_$UserProfileUniversityImpl) then) =
      __$$UserProfileUniversityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      int id,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_en") String? nameEn,
      @JsonKey(name: "short_name_uz") String? shortNameUz,
      @JsonKey(name: "short_name_ru") String? shortNameRu,
      @JsonKey(name: "short_name_en") String? shortNameEn,
      String? address,
      String? website});
}

/// @nodoc
class __$$UserProfileUniversityImplCopyWithImpl<$Res>
    extends _$UserProfileUniversityCopyWithImpl<$Res,
        _$UserProfileUniversityImpl>
    implements _$$UserProfileUniversityImplCopyWith<$Res> {
  __$$UserProfileUniversityImplCopyWithImpl(_$UserProfileUniversityImpl _value,
      $Res Function(_$UserProfileUniversityImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProfileUniversity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
    Object? shortNameUz = freezed,
    Object? shortNameRu = freezed,
    Object? shortNameEn = freezed,
    Object? address = freezed,
    Object? website = freezed,
  }) {
    return _then(_$UserProfileUniversityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameUz: freezed == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameRu: freezed == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameEn: freezed == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      website: freezed == website
          ? _value.website
          : website // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileUniversityImpl implements _UserProfileUniversity {
  const _$UserProfileUniversityImpl(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      required this.id,
      @JsonKey(name: "name_uz") this.nameUz,
      @JsonKey(name: "name_ru") this.nameRu,
      @JsonKey(name: "name_en") this.nameEn,
      @JsonKey(name: "short_name_uz") this.shortNameUz,
      @JsonKey(name: "short_name_ru") this.shortNameRu,
      @JsonKey(name: "short_name_en") this.shortNameEn,
      this.address,
      this.website});

  factory _$UserProfileUniversityImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileUniversityImplFromJson(json);

  @override
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String? nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String? nameRu;
  @override
  @JsonKey(name: "name_en")
  final String? nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  final String? shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  final String? shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  final String? shortNameEn;
  @override
  final String? address;
  @override
  final String? website;

  @override
  String toString() {
    return 'UserProfileUniversity(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn, address: $address, website: $website)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileUniversityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.shortNameUz, shortNameUz) ||
                other.shortNameUz == shortNameUz) &&
            (identical(other.shortNameRu, shortNameRu) ||
                other.shortNameRu == shortNameRu) &&
            (identical(other.shortNameEn, shortNameEn) ||
                other.shortNameEn == shortNameEn) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.website, website) || other.website == website));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameUz, nameRu, nameEn,
      shortNameUz, shortNameRu, shortNameEn, address, website);

  /// Create a copy of UserProfileUniversity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileUniversityImplCopyWith<_$UserProfileUniversityImpl>
      get copyWith => __$$UserProfileUniversityImplCopyWithImpl<
          _$UserProfileUniversityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileUniversityImplToJson(
      this,
    );
  }
}

abstract class _UserProfileUniversity implements UserProfileUniversity {
  const factory _UserProfileUniversity(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertToJson)
      required final int id,
      @JsonKey(name: "name_uz") final String? nameUz,
      @JsonKey(name: "name_ru") final String? nameRu,
      @JsonKey(name: "name_en") final String? nameEn,
      @JsonKey(name: "short_name_uz") final String? shortNameUz,
      @JsonKey(name: "short_name_ru") final String? shortNameRu,
      @JsonKey(name: "short_name_en") final String? shortNameEn,
      final String? address,
      final String? website}) = _$UserProfileUniversityImpl;

  factory _UserProfileUniversity.fromJson(Map<String, dynamic> json) =
      _$UserProfileUniversityImpl.fromJson;

  @override
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertToJson)
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String? get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String? get nameRu;
  @override
  @JsonKey(name: "name_en")
  String? get nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  String? get shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  String? get shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  String? get shortNameEn;
  @override
  String? get address;
  @override
  String? get website;

  /// Create a copy of UserProfileUniversity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileUniversityImplCopyWith<_$UserProfileUniversityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
