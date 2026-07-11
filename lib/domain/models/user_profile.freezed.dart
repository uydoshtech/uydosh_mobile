// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int get id;@JsonKey(name: "user_id") int get userId; String? get name; int? get gender;@JsonKey(name: "is_verified") bool? get isVerified;@JsonKey(name: "region_id") int? get regionId;@JsonKey(name: "university_id") int? get universityId;@JsonKey(name: "avatar_url") String? get avatarUrl;@JsonKey(name: "telegram_avatar_url") String? get telegramAvatarUrl; String? get telegram; double? get rating;@JsonKey(name: "about_me") String? get aboutMe; bool? get employed; int? get cleanliness;@JsonKey(name: "noise_level") int? get noiseLevel; int? get sociability;@JsonKey(name: "guests_allowed") bool? get guestsAllowed;@JsonKey(name: "smoking_preference") String? get smokingPreference;@JsonKey(name: "alcohol_preference") String? get alcoholPreference;@JsonKey(name: "cooking_habits") bool? get cookingHabits;@JsonKey(name: "pets_preference", fromJson: PetsPreferenceConverter.fromJson, toJson: PetsPreferenceConverter.toJson) String? get petsPreference;@JsonKey(name: "wakeup_time") String? get wakeupTime;@JsonKey(name: "sleep_time") String? get sleepTime;@JsonKey(name: "preferred_language") String? get preferredLanguage;@JsonKey(name: "origin_country_iso2") String? get originCountryIso2;// ── "What I'm looking for" matching preferences ──
@JsonKey(name: "birth_year") int? get birthYear;@JsonKey(name: "budget_min") int? get budgetMin;@JsonKey(name: "budget_max") int? get budgetMax;@JsonKey(name: "pref_roommate_gender") String? get prefRoommateGender;@JsonKey(name: "pref_age_min") int? get prefAgeMin;@JsonKey(name: "pref_age_max") int? get prefAgeMax;@JsonKey(name: "pref_budget_overlap_required") bool? get prefBudgetOverlapRequired;@JsonKey(name: "dealbreakers") List<String>? get dealbreakers;@JsonKey(name: "top_priorities") List<String>? get topPriorities;@JsonKey(name: "created_at") String? get createdAt;@JsonKey(name: "updated_at") String? get updatedAt; UserProfileRegion? get region; UserProfileUniversity? get university;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.telegramAvatarUrl, telegramAvatarUrl) || other.telegramAvatarUrl == telegramAvatarUrl)&&(identical(other.telegram, telegram) || other.telegram == telegram)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.aboutMe, aboutMe) || other.aboutMe == aboutMe)&&(identical(other.employed, employed) || other.employed == employed)&&(identical(other.cleanliness, cleanliness) || other.cleanliness == cleanliness)&&(identical(other.noiseLevel, noiseLevel) || other.noiseLevel == noiseLevel)&&(identical(other.sociability, sociability) || other.sociability == sociability)&&(identical(other.guestsAllowed, guestsAllowed) || other.guestsAllowed == guestsAllowed)&&(identical(other.smokingPreference, smokingPreference) || other.smokingPreference == smokingPreference)&&(identical(other.alcoholPreference, alcoholPreference) || other.alcoholPreference == alcoholPreference)&&(identical(other.cookingHabits, cookingHabits) || other.cookingHabits == cookingHabits)&&(identical(other.petsPreference, petsPreference) || other.petsPreference == petsPreference)&&(identical(other.wakeupTime, wakeupTime) || other.wakeupTime == wakeupTime)&&(identical(other.sleepTime, sleepTime) || other.sleepTime == sleepTime)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.originCountryIso2, originCountryIso2) || other.originCountryIso2 == originCountryIso2)&&(identical(other.birthYear, birthYear) || other.birthYear == birthYear)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.prefRoommateGender, prefRoommateGender) || other.prefRoommateGender == prefRoommateGender)&&(identical(other.prefAgeMin, prefAgeMin) || other.prefAgeMin == prefAgeMin)&&(identical(other.prefAgeMax, prefAgeMax) || other.prefAgeMax == prefAgeMax)&&(identical(other.prefBudgetOverlapRequired, prefBudgetOverlapRequired) || other.prefBudgetOverlapRequired == prefBudgetOverlapRequired)&&const DeepCollectionEquality().equals(other.dealbreakers, dealbreakers)&&const DeepCollectionEquality().equals(other.topPriorities, topPriorities)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.region, region) || other.region == region)&&(identical(other.university, university) || other.university == university));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,gender,isVerified,regionId,universityId,avatarUrl,telegramAvatarUrl,telegram,rating,aboutMe,employed,cleanliness,noiseLevel,sociability,guestsAllowed,smokingPreference,alcoholPreference,cookingHabits,petsPreference,wakeupTime,sleepTime,preferredLanguage,originCountryIso2,birthYear,budgetMin,budgetMax,prefRoommateGender,prefAgeMin,prefAgeMax,prefBudgetOverlapRequired,const DeepCollectionEquality().hash(dealbreakers),const DeepCollectionEquality().hash(topPriorities),createdAt,updatedAt,region,university]);

@override
String toString() {
  return 'UserProfile(id: $id, userId: $userId, name: $name, gender: $gender, isVerified: $isVerified, regionId: $regionId, universityId: $universityId, avatarUrl: $avatarUrl, telegramAvatarUrl: $telegramAvatarUrl, telegram: $telegram, rating: $rating, aboutMe: $aboutMe, employed: $employed, cleanliness: $cleanliness, noiseLevel: $noiseLevel, sociability: $sociability, guestsAllowed: $guestsAllowed, smokingPreference: $smokingPreference, alcoholPreference: $alcoholPreference, cookingHabits: $cookingHabits, petsPreference: $petsPreference, wakeupTime: $wakeupTime, sleepTime: $sleepTime, preferredLanguage: $preferredLanguage, originCountryIso2: $originCountryIso2, birthYear: $birthYear, budgetMin: $budgetMin, budgetMax: $budgetMax, prefRoommateGender: $prefRoommateGender, prefAgeMin: $prefAgeMin, prefAgeMax: $prefAgeMax, prefBudgetOverlapRequired: $prefBudgetOverlapRequired, dealbreakers: $dealbreakers, topPriorities: $topPriorities, createdAt: $createdAt, updatedAt: $updatedAt, region: $region, university: $university)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int id,@JsonKey(name: "user_id") int userId, String? name, int? gender,@JsonKey(name: "is_verified") bool? isVerified,@JsonKey(name: "region_id") int? regionId,@JsonKey(name: "university_id") int? universityId,@JsonKey(name: "avatar_url") String? avatarUrl,@JsonKey(name: "telegram_avatar_url") String? telegramAvatarUrl, String? telegram, double? rating,@JsonKey(name: "about_me") String? aboutMe, bool? employed, int? cleanliness,@JsonKey(name: "noise_level") int? noiseLevel, int? sociability,@JsonKey(name: "guests_allowed") bool? guestsAllowed,@JsonKey(name: "smoking_preference") String? smokingPreference,@JsonKey(name: "alcohol_preference") String? alcoholPreference,@JsonKey(name: "cooking_habits") bool? cookingHabits,@JsonKey(name: "pets_preference", fromJson: PetsPreferenceConverter.fromJson, toJson: PetsPreferenceConverter.toJson) String? petsPreference,@JsonKey(name: "wakeup_time") String? wakeupTime,@JsonKey(name: "sleep_time") String? sleepTime,@JsonKey(name: "preferred_language") String? preferredLanguage,@JsonKey(name: "origin_country_iso2") String? originCountryIso2,@JsonKey(name: "birth_year") int? birthYear,@JsonKey(name: "budget_min") int? budgetMin,@JsonKey(name: "budget_max") int? budgetMax,@JsonKey(name: "pref_roommate_gender") String? prefRoommateGender,@JsonKey(name: "pref_age_min") int? prefAgeMin,@JsonKey(name: "pref_age_max") int? prefAgeMax,@JsonKey(name: "pref_budget_overlap_required") bool? prefBudgetOverlapRequired,@JsonKey(name: "dealbreakers") List<String>? dealbreakers,@JsonKey(name: "top_priorities") List<String>? topPriorities,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt, UserProfileRegion? region, UserProfileUniversity? university
});


$UserProfileRegionCopyWith<$Res>? get region;$UserProfileUniversityCopyWith<$Res>? get university;

}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = freezed,Object? gender = freezed,Object? isVerified = freezed,Object? regionId = freezed,Object? universityId = freezed,Object? avatarUrl = freezed,Object? telegramAvatarUrl = freezed,Object? telegram = freezed,Object? rating = freezed,Object? aboutMe = freezed,Object? employed = freezed,Object? cleanliness = freezed,Object? noiseLevel = freezed,Object? sociability = freezed,Object? guestsAllowed = freezed,Object? smokingPreference = freezed,Object? alcoholPreference = freezed,Object? cookingHabits = freezed,Object? petsPreference = freezed,Object? wakeupTime = freezed,Object? sleepTime = freezed,Object? preferredLanguage = freezed,Object? originCountryIso2 = freezed,Object? birthYear = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? prefRoommateGender = freezed,Object? prefAgeMin = freezed,Object? prefAgeMax = freezed,Object? prefBudgetOverlapRequired = freezed,Object? dealbreakers = freezed,Object? topPriorities = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? region = freezed,Object? university = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as int?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as int?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,telegramAvatarUrl: freezed == telegramAvatarUrl ? _self.telegramAvatarUrl : telegramAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,telegram: freezed == telegram ? _self.telegram : telegram // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,aboutMe: freezed == aboutMe ? _self.aboutMe : aboutMe // ignore: cast_nullable_to_non_nullable
as String?,employed: freezed == employed ? _self.employed : employed // ignore: cast_nullable_to_non_nullable
as bool?,cleanliness: freezed == cleanliness ? _self.cleanliness : cleanliness // ignore: cast_nullable_to_non_nullable
as int?,noiseLevel: freezed == noiseLevel ? _self.noiseLevel : noiseLevel // ignore: cast_nullable_to_non_nullable
as int?,sociability: freezed == sociability ? _self.sociability : sociability // ignore: cast_nullable_to_non_nullable
as int?,guestsAllowed: freezed == guestsAllowed ? _self.guestsAllowed : guestsAllowed // ignore: cast_nullable_to_non_nullable
as bool?,smokingPreference: freezed == smokingPreference ? _self.smokingPreference : smokingPreference // ignore: cast_nullable_to_non_nullable
as String?,alcoholPreference: freezed == alcoholPreference ? _self.alcoholPreference : alcoholPreference // ignore: cast_nullable_to_non_nullable
as String?,cookingHabits: freezed == cookingHabits ? _self.cookingHabits : cookingHabits // ignore: cast_nullable_to_non_nullable
as bool?,petsPreference: freezed == petsPreference ? _self.petsPreference : petsPreference // ignore: cast_nullable_to_non_nullable
as String?,wakeupTime: freezed == wakeupTime ? _self.wakeupTime : wakeupTime // ignore: cast_nullable_to_non_nullable
as String?,sleepTime: freezed == sleepTime ? _self.sleepTime : sleepTime // ignore: cast_nullable_to_non_nullable
as String?,preferredLanguage: freezed == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String?,originCountryIso2: freezed == originCountryIso2 ? _self.originCountryIso2 : originCountryIso2 // ignore: cast_nullable_to_non_nullable
as String?,birthYear: freezed == birthYear ? _self.birthYear : birthYear // ignore: cast_nullable_to_non_nullable
as int?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as int?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as int?,prefRoommateGender: freezed == prefRoommateGender ? _self.prefRoommateGender : prefRoommateGender // ignore: cast_nullable_to_non_nullable
as String?,prefAgeMin: freezed == prefAgeMin ? _self.prefAgeMin : prefAgeMin // ignore: cast_nullable_to_non_nullable
as int?,prefAgeMax: freezed == prefAgeMax ? _self.prefAgeMax : prefAgeMax // ignore: cast_nullable_to_non_nullable
as int?,prefBudgetOverlapRequired: freezed == prefBudgetOverlapRequired ? _self.prefBudgetOverlapRequired : prefBudgetOverlapRequired // ignore: cast_nullable_to_non_nullable
as bool?,dealbreakers: freezed == dealbreakers ? _self.dealbreakers : dealbreakers // ignore: cast_nullable_to_non_nullable
as List<String>?,topPriorities: freezed == topPriorities ? _self.topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as UserProfileRegion?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as UserProfileUniversity?,
  ));
}
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileRegionCopyWith<$Res>? get region {
    if (_self.region == null) {
    return null;
  }

  return $UserProfileRegionCopyWith<$Res>(_self.region!, (value) {
    return _then(_self.copyWith(region: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileUniversityCopyWith<$Res>? get university {
    if (_self.university == null) {
    return null;
  }

  return $UserProfileUniversityCopyWith<$Res>(_self.university!, (value) {
    return _then(_self.copyWith(university: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "user_id")  int userId,  String? name,  int? gender, @JsonKey(name: "is_verified")  bool? isVerified, @JsonKey(name: "region_id")  int? regionId, @JsonKey(name: "university_id")  int? universityId, @JsonKey(name: "avatar_url")  String? avatarUrl, @JsonKey(name: "telegram_avatar_url")  String? telegramAvatarUrl,  String? telegram,  double? rating, @JsonKey(name: "about_me")  String? aboutMe,  bool? employed,  int? cleanliness, @JsonKey(name: "noise_level")  int? noiseLevel,  int? sociability, @JsonKey(name: "guests_allowed")  bool? guestsAllowed, @JsonKey(name: "smoking_preference")  String? smokingPreference, @JsonKey(name: "alcohol_preference")  String? alcoholPreference, @JsonKey(name: "cooking_habits")  bool? cookingHabits, @JsonKey(name: "pets_preference", fromJson: PetsPreferenceConverter.fromJson, toJson: PetsPreferenceConverter.toJson)  String? petsPreference, @JsonKey(name: "wakeup_time")  String? wakeupTime, @JsonKey(name: "sleep_time")  String? sleepTime, @JsonKey(name: "preferred_language")  String? preferredLanguage, @JsonKey(name: "origin_country_iso2")  String? originCountryIso2, @JsonKey(name: "birth_year")  int? birthYear, @JsonKey(name: "budget_min")  int? budgetMin, @JsonKey(name: "budget_max")  int? budgetMax, @JsonKey(name: "pref_roommate_gender")  String? prefRoommateGender, @JsonKey(name: "pref_age_min")  int? prefAgeMin, @JsonKey(name: "pref_age_max")  int? prefAgeMax, @JsonKey(name: "pref_budget_overlap_required")  bool? prefBudgetOverlapRequired, @JsonKey(name: "dealbreakers")  List<String>? dealbreakers, @JsonKey(name: "top_priorities")  List<String>? topPriorities, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt,  UserProfileRegion? region,  UserProfileUniversity? university)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.gender,_that.isVerified,_that.regionId,_that.universityId,_that.avatarUrl,_that.telegramAvatarUrl,_that.telegram,_that.rating,_that.aboutMe,_that.employed,_that.cleanliness,_that.noiseLevel,_that.sociability,_that.guestsAllowed,_that.smokingPreference,_that.alcoholPreference,_that.cookingHabits,_that.petsPreference,_that.wakeupTime,_that.sleepTime,_that.preferredLanguage,_that.originCountryIso2,_that.birthYear,_that.budgetMin,_that.budgetMax,_that.prefRoommateGender,_that.prefAgeMin,_that.prefAgeMax,_that.prefBudgetOverlapRequired,_that.dealbreakers,_that.topPriorities,_that.createdAt,_that.updatedAt,_that.region,_that.university);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "user_id")  int userId,  String? name,  int? gender, @JsonKey(name: "is_verified")  bool? isVerified, @JsonKey(name: "region_id")  int? regionId, @JsonKey(name: "university_id")  int? universityId, @JsonKey(name: "avatar_url")  String? avatarUrl, @JsonKey(name: "telegram_avatar_url")  String? telegramAvatarUrl,  String? telegram,  double? rating, @JsonKey(name: "about_me")  String? aboutMe,  bool? employed,  int? cleanliness, @JsonKey(name: "noise_level")  int? noiseLevel,  int? sociability, @JsonKey(name: "guests_allowed")  bool? guestsAllowed, @JsonKey(name: "smoking_preference")  String? smokingPreference, @JsonKey(name: "alcohol_preference")  String? alcoholPreference, @JsonKey(name: "cooking_habits")  bool? cookingHabits, @JsonKey(name: "pets_preference", fromJson: PetsPreferenceConverter.fromJson, toJson: PetsPreferenceConverter.toJson)  String? petsPreference, @JsonKey(name: "wakeup_time")  String? wakeupTime, @JsonKey(name: "sleep_time")  String? sleepTime, @JsonKey(name: "preferred_language")  String? preferredLanguage, @JsonKey(name: "origin_country_iso2")  String? originCountryIso2, @JsonKey(name: "birth_year")  int? birthYear, @JsonKey(name: "budget_min")  int? budgetMin, @JsonKey(name: "budget_max")  int? budgetMax, @JsonKey(name: "pref_roommate_gender")  String? prefRoommateGender, @JsonKey(name: "pref_age_min")  int? prefAgeMin, @JsonKey(name: "pref_age_max")  int? prefAgeMax, @JsonKey(name: "pref_budget_overlap_required")  bool? prefBudgetOverlapRequired, @JsonKey(name: "dealbreakers")  List<String>? dealbreakers, @JsonKey(name: "top_priorities")  List<String>? topPriorities, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt,  UserProfileRegion? region,  UserProfileUniversity? university)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.userId,_that.name,_that.gender,_that.isVerified,_that.regionId,_that.universityId,_that.avatarUrl,_that.telegramAvatarUrl,_that.telegram,_that.rating,_that.aboutMe,_that.employed,_that.cleanliness,_that.noiseLevel,_that.sociability,_that.guestsAllowed,_that.smokingPreference,_that.alcoholPreference,_that.cookingHabits,_that.petsPreference,_that.wakeupTime,_that.sleepTime,_that.preferredLanguage,_that.originCountryIso2,_that.birthYear,_that.budgetMin,_that.budgetMax,_that.prefRoommateGender,_that.prefAgeMin,_that.prefAgeMax,_that.prefBudgetOverlapRequired,_that.dealbreakers,_that.topPriorities,_that.createdAt,_that.updatedAt,_that.region,_that.university);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "user_id")  int userId,  String? name,  int? gender, @JsonKey(name: "is_verified")  bool? isVerified, @JsonKey(name: "region_id")  int? regionId, @JsonKey(name: "university_id")  int? universityId, @JsonKey(name: "avatar_url")  String? avatarUrl, @JsonKey(name: "telegram_avatar_url")  String? telegramAvatarUrl,  String? telegram,  double? rating, @JsonKey(name: "about_me")  String? aboutMe,  bool? employed,  int? cleanliness, @JsonKey(name: "noise_level")  int? noiseLevel,  int? sociability, @JsonKey(name: "guests_allowed")  bool? guestsAllowed, @JsonKey(name: "smoking_preference")  String? smokingPreference, @JsonKey(name: "alcohol_preference")  String? alcoholPreference, @JsonKey(name: "cooking_habits")  bool? cookingHabits, @JsonKey(name: "pets_preference", fromJson: PetsPreferenceConverter.fromJson, toJson: PetsPreferenceConverter.toJson)  String? petsPreference, @JsonKey(name: "wakeup_time")  String? wakeupTime, @JsonKey(name: "sleep_time")  String? sleepTime, @JsonKey(name: "preferred_language")  String? preferredLanguage, @JsonKey(name: "origin_country_iso2")  String? originCountryIso2, @JsonKey(name: "birth_year")  int? birthYear, @JsonKey(name: "budget_min")  int? budgetMin, @JsonKey(name: "budget_max")  int? budgetMax, @JsonKey(name: "pref_roommate_gender")  String? prefRoommateGender, @JsonKey(name: "pref_age_min")  int? prefAgeMin, @JsonKey(name: "pref_age_max")  int? prefAgeMax, @JsonKey(name: "pref_budget_overlap_required")  bool? prefBudgetOverlapRequired, @JsonKey(name: "dealbreakers")  List<String>? dealbreakers, @JsonKey(name: "top_priorities")  List<String>? topPriorities, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt,  UserProfileRegion? region,  UserProfileUniversity? university)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.gender,_that.isVerified,_that.regionId,_that.universityId,_that.avatarUrl,_that.telegramAvatarUrl,_that.telegram,_that.rating,_that.aboutMe,_that.employed,_that.cleanliness,_that.noiseLevel,_that.sociability,_that.guestsAllowed,_that.smokingPreference,_that.alcoholPreference,_that.cookingHabits,_that.petsPreference,_that.wakeupTime,_that.sleepTime,_that.preferredLanguage,_that.originCountryIso2,_that.birthYear,_that.budgetMin,_that.budgetMax,_that.prefRoommateGender,_that.prefAgeMin,_that.prefAgeMax,_that.prefBudgetOverlapRequired,_that.dealbreakers,_that.topPriorities,_that.createdAt,_that.updatedAt,_that.region,_that.university);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) required this.id, @JsonKey(name: "user_id") required this.userId, this.name, this.gender, @JsonKey(name: "is_verified") this.isVerified, @JsonKey(name: "region_id") this.regionId, @JsonKey(name: "university_id") this.universityId, @JsonKey(name: "avatar_url") this.avatarUrl, @JsonKey(name: "telegram_avatar_url") this.telegramAvatarUrl, this.telegram, this.rating, @JsonKey(name: "about_me") this.aboutMe, this.employed, this.cleanliness, @JsonKey(name: "noise_level") this.noiseLevel, this.sociability, @JsonKey(name: "guests_allowed") this.guestsAllowed, @JsonKey(name: "smoking_preference") this.smokingPreference, @JsonKey(name: "alcohol_preference") this.alcoholPreference, @JsonKey(name: "cooking_habits") this.cookingHabits, @JsonKey(name: "pets_preference", fromJson: PetsPreferenceConverter.fromJson, toJson: PetsPreferenceConverter.toJson) this.petsPreference, @JsonKey(name: "wakeup_time") this.wakeupTime, @JsonKey(name: "sleep_time") this.sleepTime, @JsonKey(name: "preferred_language") this.preferredLanguage, @JsonKey(name: "origin_country_iso2") this.originCountryIso2, @JsonKey(name: "birth_year") this.birthYear, @JsonKey(name: "budget_min") this.budgetMin, @JsonKey(name: "budget_max") this.budgetMax, @JsonKey(name: "pref_roommate_gender") this.prefRoommateGender, @JsonKey(name: "pref_age_min") this.prefAgeMin, @JsonKey(name: "pref_age_max") this.prefAgeMax, @JsonKey(name: "pref_budget_overlap_required") this.prefBudgetOverlapRequired, @JsonKey(name: "dealbreakers") final  List<String>? dealbreakers, @JsonKey(name: "top_priorities") final  List<String>? topPriorities, @JsonKey(name: "created_at") this.createdAt, @JsonKey(name: "updated_at") this.updatedAt, this.region, this.university}): _dealbreakers = dealbreakers,_topPriorities = topPriorities;
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) final  int id;
@override@JsonKey(name: "user_id") final  int userId;
@override final  String? name;
@override final  int? gender;
@override@JsonKey(name: "is_verified") final  bool? isVerified;
@override@JsonKey(name: "region_id") final  int? regionId;
@override@JsonKey(name: "university_id") final  int? universityId;
@override@JsonKey(name: "avatar_url") final  String? avatarUrl;
@override@JsonKey(name: "telegram_avatar_url") final  String? telegramAvatarUrl;
@override final  String? telegram;
@override final  double? rating;
@override@JsonKey(name: "about_me") final  String? aboutMe;
@override final  bool? employed;
@override final  int? cleanliness;
@override@JsonKey(name: "noise_level") final  int? noiseLevel;
@override final  int? sociability;
@override@JsonKey(name: "guests_allowed") final  bool? guestsAllowed;
@override@JsonKey(name: "smoking_preference") final  String? smokingPreference;
@override@JsonKey(name: "alcohol_preference") final  String? alcoholPreference;
@override@JsonKey(name: "cooking_habits") final  bool? cookingHabits;
@override@JsonKey(name: "pets_preference", fromJson: PetsPreferenceConverter.fromJson, toJson: PetsPreferenceConverter.toJson) final  String? petsPreference;
@override@JsonKey(name: "wakeup_time") final  String? wakeupTime;
@override@JsonKey(name: "sleep_time") final  String? sleepTime;
@override@JsonKey(name: "preferred_language") final  String? preferredLanguage;
@override@JsonKey(name: "origin_country_iso2") final  String? originCountryIso2;
// ── "What I'm looking for" matching preferences ──
@override@JsonKey(name: "birth_year") final  int? birthYear;
@override@JsonKey(name: "budget_min") final  int? budgetMin;
@override@JsonKey(name: "budget_max") final  int? budgetMax;
@override@JsonKey(name: "pref_roommate_gender") final  String? prefRoommateGender;
@override@JsonKey(name: "pref_age_min") final  int? prefAgeMin;
@override@JsonKey(name: "pref_age_max") final  int? prefAgeMax;
@override@JsonKey(name: "pref_budget_overlap_required") final  bool? prefBudgetOverlapRequired;
 final  List<String>? _dealbreakers;
@override@JsonKey(name: "dealbreakers") List<String>? get dealbreakers {
  final value = _dealbreakers;
  if (value == null) return null;
  if (_dealbreakers is EqualUnmodifiableListView) return _dealbreakers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _topPriorities;
@override@JsonKey(name: "top_priorities") List<String>? get topPriorities {
  final value = _topPriorities;
  if (value == null) return null;
  if (_topPriorities is EqualUnmodifiableListView) return _topPriorities;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: "created_at") final  String? createdAt;
@override@JsonKey(name: "updated_at") final  String? updatedAt;
@override final  UserProfileRegion? region;
@override final  UserProfileUniversity? university;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.regionId, regionId) || other.regionId == regionId)&&(identical(other.universityId, universityId) || other.universityId == universityId)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.telegramAvatarUrl, telegramAvatarUrl) || other.telegramAvatarUrl == telegramAvatarUrl)&&(identical(other.telegram, telegram) || other.telegram == telegram)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.aboutMe, aboutMe) || other.aboutMe == aboutMe)&&(identical(other.employed, employed) || other.employed == employed)&&(identical(other.cleanliness, cleanliness) || other.cleanliness == cleanliness)&&(identical(other.noiseLevel, noiseLevel) || other.noiseLevel == noiseLevel)&&(identical(other.sociability, sociability) || other.sociability == sociability)&&(identical(other.guestsAllowed, guestsAllowed) || other.guestsAllowed == guestsAllowed)&&(identical(other.smokingPreference, smokingPreference) || other.smokingPreference == smokingPreference)&&(identical(other.alcoholPreference, alcoholPreference) || other.alcoholPreference == alcoholPreference)&&(identical(other.cookingHabits, cookingHabits) || other.cookingHabits == cookingHabits)&&(identical(other.petsPreference, petsPreference) || other.petsPreference == petsPreference)&&(identical(other.wakeupTime, wakeupTime) || other.wakeupTime == wakeupTime)&&(identical(other.sleepTime, sleepTime) || other.sleepTime == sleepTime)&&(identical(other.preferredLanguage, preferredLanguage) || other.preferredLanguage == preferredLanguage)&&(identical(other.originCountryIso2, originCountryIso2) || other.originCountryIso2 == originCountryIso2)&&(identical(other.birthYear, birthYear) || other.birthYear == birthYear)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.prefRoommateGender, prefRoommateGender) || other.prefRoommateGender == prefRoommateGender)&&(identical(other.prefAgeMin, prefAgeMin) || other.prefAgeMin == prefAgeMin)&&(identical(other.prefAgeMax, prefAgeMax) || other.prefAgeMax == prefAgeMax)&&(identical(other.prefBudgetOverlapRequired, prefBudgetOverlapRequired) || other.prefBudgetOverlapRequired == prefBudgetOverlapRequired)&&const DeepCollectionEquality().equals(other._dealbreakers, _dealbreakers)&&const DeepCollectionEquality().equals(other._topPriorities, _topPriorities)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.region, region) || other.region == region)&&(identical(other.university, university) || other.university == university));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,name,gender,isVerified,regionId,universityId,avatarUrl,telegramAvatarUrl,telegram,rating,aboutMe,employed,cleanliness,noiseLevel,sociability,guestsAllowed,smokingPreference,alcoholPreference,cookingHabits,petsPreference,wakeupTime,sleepTime,preferredLanguage,originCountryIso2,birthYear,budgetMin,budgetMax,prefRoommateGender,prefAgeMin,prefAgeMax,prefBudgetOverlapRequired,const DeepCollectionEquality().hash(_dealbreakers),const DeepCollectionEquality().hash(_topPriorities),createdAt,updatedAt,region,university]);

@override
String toString() {
  return 'UserProfile(id: $id, userId: $userId, name: $name, gender: $gender, isVerified: $isVerified, regionId: $regionId, universityId: $universityId, avatarUrl: $avatarUrl, telegramAvatarUrl: $telegramAvatarUrl, telegram: $telegram, rating: $rating, aboutMe: $aboutMe, employed: $employed, cleanliness: $cleanliness, noiseLevel: $noiseLevel, sociability: $sociability, guestsAllowed: $guestsAllowed, smokingPreference: $smokingPreference, alcoholPreference: $alcoholPreference, cookingHabits: $cookingHabits, petsPreference: $petsPreference, wakeupTime: $wakeupTime, sleepTime: $sleepTime, preferredLanguage: $preferredLanguage, originCountryIso2: $originCountryIso2, birthYear: $birthYear, budgetMin: $budgetMin, budgetMax: $budgetMax, prefRoommateGender: $prefRoommateGender, prefAgeMin: $prefAgeMin, prefAgeMax: $prefAgeMax, prefBudgetOverlapRequired: $prefBudgetOverlapRequired, dealbreakers: $dealbreakers, topPriorities: $topPriorities, createdAt: $createdAt, updatedAt: $updatedAt, region: $region, university: $university)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int id,@JsonKey(name: "user_id") int userId, String? name, int? gender,@JsonKey(name: "is_verified") bool? isVerified,@JsonKey(name: "region_id") int? regionId,@JsonKey(name: "university_id") int? universityId,@JsonKey(name: "avatar_url") String? avatarUrl,@JsonKey(name: "telegram_avatar_url") String? telegramAvatarUrl, String? telegram, double? rating,@JsonKey(name: "about_me") String? aboutMe, bool? employed, int? cleanliness,@JsonKey(name: "noise_level") int? noiseLevel, int? sociability,@JsonKey(name: "guests_allowed") bool? guestsAllowed,@JsonKey(name: "smoking_preference") String? smokingPreference,@JsonKey(name: "alcohol_preference") String? alcoholPreference,@JsonKey(name: "cooking_habits") bool? cookingHabits,@JsonKey(name: "pets_preference", fromJson: PetsPreferenceConverter.fromJson, toJson: PetsPreferenceConverter.toJson) String? petsPreference,@JsonKey(name: "wakeup_time") String? wakeupTime,@JsonKey(name: "sleep_time") String? sleepTime,@JsonKey(name: "preferred_language") String? preferredLanguage,@JsonKey(name: "origin_country_iso2") String? originCountryIso2,@JsonKey(name: "birth_year") int? birthYear,@JsonKey(name: "budget_min") int? budgetMin,@JsonKey(name: "budget_max") int? budgetMax,@JsonKey(name: "pref_roommate_gender") String? prefRoommateGender,@JsonKey(name: "pref_age_min") int? prefAgeMin,@JsonKey(name: "pref_age_max") int? prefAgeMax,@JsonKey(name: "pref_budget_overlap_required") bool? prefBudgetOverlapRequired,@JsonKey(name: "dealbreakers") List<String>? dealbreakers,@JsonKey(name: "top_priorities") List<String>? topPriorities,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt, UserProfileRegion? region, UserProfileUniversity? university
});


@override $UserProfileRegionCopyWith<$Res>? get region;@override $UserProfileUniversityCopyWith<$Res>? get university;

}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = freezed,Object? gender = freezed,Object? isVerified = freezed,Object? regionId = freezed,Object? universityId = freezed,Object? avatarUrl = freezed,Object? telegramAvatarUrl = freezed,Object? telegram = freezed,Object? rating = freezed,Object? aboutMe = freezed,Object? employed = freezed,Object? cleanliness = freezed,Object? noiseLevel = freezed,Object? sociability = freezed,Object? guestsAllowed = freezed,Object? smokingPreference = freezed,Object? alcoholPreference = freezed,Object? cookingHabits = freezed,Object? petsPreference = freezed,Object? wakeupTime = freezed,Object? sleepTime = freezed,Object? preferredLanguage = freezed,Object? originCountryIso2 = freezed,Object? birthYear = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? prefRoommateGender = freezed,Object? prefAgeMin = freezed,Object? prefAgeMax = freezed,Object? prefBudgetOverlapRequired = freezed,Object? dealbreakers = freezed,Object? topPriorities = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? region = freezed,Object? university = freezed,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,isVerified: freezed == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool?,regionId: freezed == regionId ? _self.regionId : regionId // ignore: cast_nullable_to_non_nullable
as int?,universityId: freezed == universityId ? _self.universityId : universityId // ignore: cast_nullable_to_non_nullable
as int?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,telegramAvatarUrl: freezed == telegramAvatarUrl ? _self.telegramAvatarUrl : telegramAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,telegram: freezed == telegram ? _self.telegram : telegram // ignore: cast_nullable_to_non_nullable
as String?,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,aboutMe: freezed == aboutMe ? _self.aboutMe : aboutMe // ignore: cast_nullable_to_non_nullable
as String?,employed: freezed == employed ? _self.employed : employed // ignore: cast_nullable_to_non_nullable
as bool?,cleanliness: freezed == cleanliness ? _self.cleanliness : cleanliness // ignore: cast_nullable_to_non_nullable
as int?,noiseLevel: freezed == noiseLevel ? _self.noiseLevel : noiseLevel // ignore: cast_nullable_to_non_nullable
as int?,sociability: freezed == sociability ? _self.sociability : sociability // ignore: cast_nullable_to_non_nullable
as int?,guestsAllowed: freezed == guestsAllowed ? _self.guestsAllowed : guestsAllowed // ignore: cast_nullable_to_non_nullable
as bool?,smokingPreference: freezed == smokingPreference ? _self.smokingPreference : smokingPreference // ignore: cast_nullable_to_non_nullable
as String?,alcoholPreference: freezed == alcoholPreference ? _self.alcoholPreference : alcoholPreference // ignore: cast_nullable_to_non_nullable
as String?,cookingHabits: freezed == cookingHabits ? _self.cookingHabits : cookingHabits // ignore: cast_nullable_to_non_nullable
as bool?,petsPreference: freezed == petsPreference ? _self.petsPreference : petsPreference // ignore: cast_nullable_to_non_nullable
as String?,wakeupTime: freezed == wakeupTime ? _self.wakeupTime : wakeupTime // ignore: cast_nullable_to_non_nullable
as String?,sleepTime: freezed == sleepTime ? _self.sleepTime : sleepTime // ignore: cast_nullable_to_non_nullable
as String?,preferredLanguage: freezed == preferredLanguage ? _self.preferredLanguage : preferredLanguage // ignore: cast_nullable_to_non_nullable
as String?,originCountryIso2: freezed == originCountryIso2 ? _self.originCountryIso2 : originCountryIso2 // ignore: cast_nullable_to_non_nullable
as String?,birthYear: freezed == birthYear ? _self.birthYear : birthYear // ignore: cast_nullable_to_non_nullable
as int?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as int?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as int?,prefRoommateGender: freezed == prefRoommateGender ? _self.prefRoommateGender : prefRoommateGender // ignore: cast_nullable_to_non_nullable
as String?,prefAgeMin: freezed == prefAgeMin ? _self.prefAgeMin : prefAgeMin // ignore: cast_nullable_to_non_nullable
as int?,prefAgeMax: freezed == prefAgeMax ? _self.prefAgeMax : prefAgeMax // ignore: cast_nullable_to_non_nullable
as int?,prefBudgetOverlapRequired: freezed == prefBudgetOverlapRequired ? _self.prefBudgetOverlapRequired : prefBudgetOverlapRequired // ignore: cast_nullable_to_non_nullable
as bool?,dealbreakers: freezed == dealbreakers ? _self._dealbreakers : dealbreakers // ignore: cast_nullable_to_non_nullable
as List<String>?,topPriorities: freezed == topPriorities ? _self._topPriorities : topPriorities // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as UserProfileRegion?,university: freezed == university ? _self.university : university // ignore: cast_nullable_to_non_nullable
as UserProfileUniversity?,
  ));
}

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileRegionCopyWith<$Res>? get region {
    if (_self.region == null) {
    return null;
  }

  return $UserProfileRegionCopyWith<$Res>(_self.region!, (value) {
    return _then(_self.copyWith(region: value));
  });
}/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileUniversityCopyWith<$Res>? get university {
    if (_self.university == null) {
    return null;
  }

  return $UserProfileUniversityCopyWith<$Res>(_self.university!, (value) {
    return _then(_self.copyWith(university: value));
  });
}
}


/// @nodoc
mixin _$UserProfileRegion {

@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int get id;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_en") String? get nameEn;@JsonKey(name: "short_name_uz") String? get shortNameUz;@JsonKey(name: "short_name_ru") String? get shortNameRu;@JsonKey(name: "short_name_en") String? get shortNameEn;
/// Create a copy of UserProfileRegion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileRegionCopyWith<UserProfileRegion> get copyWith => _$UserProfileRegionCopyWithImpl<UserProfileRegion>(this as UserProfileRegion, _$identity);

  /// Serializes this UserProfileRegion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileRegion&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,shortNameUz,shortNameRu,shortNameEn);

@override
String toString() {
  return 'UserProfileRegion(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn)';
}


}

/// @nodoc
abstract mixin class $UserProfileRegionCopyWith<$Res>  {
  factory $UserProfileRegionCopyWith(UserProfileRegion value, $Res Function(UserProfileRegion) _then) = _$UserProfileRegionCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int id,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_en") String? shortNameEn
});




}
/// @nodoc
class _$UserProfileRegionCopyWithImpl<$Res>
    implements $UserProfileRegionCopyWith<$Res> {
  _$UserProfileRegionCopyWithImpl(this._self, this._then);

  final UserProfileRegion _self;
  final $Res Function(UserProfileRegion) _then;

/// Create a copy of UserProfileRegion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? shortNameUz = freezed,Object? shortNameRu = freezed,Object? shortNameEn = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileRegion].
extension UserProfileRegionPatterns on UserProfileRegion {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileRegion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileRegion() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileRegion value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileRegion():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileRegion value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileRegion() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileRegion() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn)  $default,) {final _that = this;
switch (_that) {
case _UserProfileRegion():
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileRegion() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileRegion implements UserProfileRegion {
  const _UserProfileRegion({@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) required this.id, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_en") this.nameEn, @JsonKey(name: "short_name_uz") this.shortNameUz, @JsonKey(name: "short_name_ru") this.shortNameRu, @JsonKey(name: "short_name_en") this.shortNameEn});
  factory _UserProfileRegion.fromJson(Map<String, dynamic> json) => _$UserProfileRegionFromJson(json);

@override@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) final  int id;
@override@JsonKey(name: "name_uz") final  String? nameUz;
@override@JsonKey(name: "name_ru") final  String? nameRu;
@override@JsonKey(name: "name_en") final  String? nameEn;
@override@JsonKey(name: "short_name_uz") final  String? shortNameUz;
@override@JsonKey(name: "short_name_ru") final  String? shortNameRu;
@override@JsonKey(name: "short_name_en") final  String? shortNameEn;

/// Create a copy of UserProfileRegion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileRegionCopyWith<_UserProfileRegion> get copyWith => __$UserProfileRegionCopyWithImpl<_UserProfileRegion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileRegionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileRegion&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,shortNameUz,shortNameRu,shortNameEn);

@override
String toString() {
  return 'UserProfileRegion(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn)';
}


}

/// @nodoc
abstract mixin class _$UserProfileRegionCopyWith<$Res> implements $UserProfileRegionCopyWith<$Res> {
  factory _$UserProfileRegionCopyWith(_UserProfileRegion value, $Res Function(_UserProfileRegion) _then) = __$UserProfileRegionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int id,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_en") String? shortNameEn
});




}
/// @nodoc
class __$UserProfileRegionCopyWithImpl<$Res>
    implements _$UserProfileRegionCopyWith<$Res> {
  __$UserProfileRegionCopyWithImpl(this._self, this._then);

  final _UserProfileRegion _self;
  final $Res Function(_UserProfileRegion) _then;

/// Create a copy of UserProfileRegion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? shortNameUz = freezed,Object? shortNameRu = freezed,Object? shortNameEn = freezed,}) {
  return _then(_UserProfileRegion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UserProfileUniversity {

@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int get id;@JsonKey(name: "name_uz") String? get nameUz;@JsonKey(name: "name_ru") String? get nameRu;@JsonKey(name: "name_en") String? get nameEn;@JsonKey(name: "short_name_uz") String? get shortNameUz;@JsonKey(name: "short_name_ru") String? get shortNameRu;@JsonKey(name: "short_name_en") String? get shortNameEn; String? get address; String? get website;
/// Create a copy of UserProfileUniversity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileUniversityCopyWith<UserProfileUniversity> get copyWith => _$UserProfileUniversityCopyWithImpl<UserProfileUniversity>(this as UserProfileUniversity, _$identity);

  /// Serializes this UserProfileUniversity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfileUniversity&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn)&&(identical(other.address, address) || other.address == address)&&(identical(other.website, website) || other.website == website));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,shortNameUz,shortNameRu,shortNameEn,address,website);

@override
String toString() {
  return 'UserProfileUniversity(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn, address: $address, website: $website)';
}


}

/// @nodoc
abstract mixin class $UserProfileUniversityCopyWith<$Res>  {
  factory $UserProfileUniversityCopyWith(UserProfileUniversity value, $Res Function(UserProfileUniversity) _then) = _$UserProfileUniversityCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int id,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_en") String? shortNameEn, String? address, String? website
});




}
/// @nodoc
class _$UserProfileUniversityCopyWithImpl<$Res>
    implements $UserProfileUniversityCopyWith<$Res> {
  _$UserProfileUniversityCopyWithImpl(this._self, this._then);

  final UserProfileUniversity _self;
  final $Res Function(UserProfileUniversity) _then;

/// Create a copy of UserProfileUniversity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? shortNameUz = freezed,Object? shortNameRu = freezed,Object? shortNameEn = freezed,Object? address = freezed,Object? website = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfileUniversity].
extension UserProfileUniversityPatterns on UserProfileUniversity {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfileUniversity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfileUniversity() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfileUniversity value)  $default,){
final _that = this;
switch (_that) {
case _UserProfileUniversity():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfileUniversity value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfileUniversity() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn,  String? address,  String? website)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfileUniversity() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn,_that.address,_that.website);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn,  String? address,  String? website)  $default,) {final _that = this;
switch (_that) {
case _UserProfileUniversity():
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn,_that.address,_that.website);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson)  int id, @JsonKey(name: "name_uz")  String? nameUz, @JsonKey(name: "name_ru")  String? nameRu, @JsonKey(name: "name_en")  String? nameEn, @JsonKey(name: "short_name_uz")  String? shortNameUz, @JsonKey(name: "short_name_ru")  String? shortNameRu, @JsonKey(name: "short_name_en")  String? shortNameEn,  String? address,  String? website)?  $default,) {final _that = this;
switch (_that) {
case _UserProfileUniversity() when $default != null:
return $default(_that.id,_that.nameUz,_that.nameRu,_that.nameEn,_that.shortNameUz,_that.shortNameRu,_that.shortNameEn,_that.address,_that.website);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfileUniversity implements UserProfileUniversity {
  const _UserProfileUniversity({@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) required this.id, @JsonKey(name: "name_uz") this.nameUz, @JsonKey(name: "name_ru") this.nameRu, @JsonKey(name: "name_en") this.nameEn, @JsonKey(name: "short_name_uz") this.shortNameUz, @JsonKey(name: "short_name_ru") this.shortNameRu, @JsonKey(name: "short_name_en") this.shortNameEn, this.address, this.website});
  factory _UserProfileUniversity.fromJson(Map<String, dynamic> json) => _$UserProfileUniversityFromJson(json);

@override@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) final  int id;
@override@JsonKey(name: "name_uz") final  String? nameUz;
@override@JsonKey(name: "name_ru") final  String? nameRu;
@override@JsonKey(name: "name_en") final  String? nameEn;
@override@JsonKey(name: "short_name_uz") final  String? shortNameUz;
@override@JsonKey(name: "short_name_ru") final  String? shortNameRu;
@override@JsonKey(name: "short_name_en") final  String? shortNameEn;
@override final  String? address;
@override final  String? website;

/// Create a copy of UserProfileUniversity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileUniversityCopyWith<_UserProfileUniversity> get copyWith => __$UserProfileUniversityCopyWithImpl<_UserProfileUniversity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileUniversityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfileUniversity&&(identical(other.id, id) || other.id == id)&&(identical(other.nameUz, nameUz) || other.nameUz == nameUz)&&(identical(other.nameRu, nameRu) || other.nameRu == nameRu)&&(identical(other.nameEn, nameEn) || other.nameEn == nameEn)&&(identical(other.shortNameUz, shortNameUz) || other.shortNameUz == shortNameUz)&&(identical(other.shortNameRu, shortNameRu) || other.shortNameRu == shortNameRu)&&(identical(other.shortNameEn, shortNameEn) || other.shortNameEn == shortNameEn)&&(identical(other.address, address) || other.address == address)&&(identical(other.website, website) || other.website == website));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nameUz,nameRu,nameEn,shortNameUz,shortNameRu,shortNameEn,address,website);

@override
String toString() {
  return 'UserProfileUniversity(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn, address: $address, website: $website)';
}


}

/// @nodoc
abstract mixin class _$UserProfileUniversityCopyWith<$Res> implements $UserProfileUniversityCopyWith<$Res> {
  factory _$UserProfileUniversityCopyWith(_UserProfileUniversity value, $Res Function(_UserProfileUniversity) _then) = __$UserProfileUniversityCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: NullableIntConverter.convertFromJson, toJson: NullableIntConverter.convertToJson) int id,@JsonKey(name: "name_uz") String? nameUz,@JsonKey(name: "name_ru") String? nameRu,@JsonKey(name: "name_en") String? nameEn,@JsonKey(name: "short_name_uz") String? shortNameUz,@JsonKey(name: "short_name_ru") String? shortNameRu,@JsonKey(name: "short_name_en") String? shortNameEn, String? address, String? website
});




}
/// @nodoc
class __$UserProfileUniversityCopyWithImpl<$Res>
    implements _$UserProfileUniversityCopyWith<$Res> {
  __$UserProfileUniversityCopyWithImpl(this._self, this._then);

  final _UserProfileUniversity _self;
  final $Res Function(_UserProfileUniversity) _then;

/// Create a copy of UserProfileUniversity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nameUz = freezed,Object? nameRu = freezed,Object? nameEn = freezed,Object? shortNameUz = freezed,Object? shortNameRu = freezed,Object? shortNameEn = freezed,Object? address = freezed,Object? website = freezed,}) {
  return _then(_UserProfileUniversity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,nameUz: freezed == nameUz ? _self.nameUz : nameUz // ignore: cast_nullable_to_non_nullable
as String?,nameRu: freezed == nameRu ? _self.nameRu : nameRu // ignore: cast_nullable_to_non_nullable
as String?,nameEn: freezed == nameEn ? _self.nameEn : nameEn // ignore: cast_nullable_to_non_nullable
as String?,shortNameUz: freezed == shortNameUz ? _self.shortNameUz : shortNameUz // ignore: cast_nullable_to_non_nullable
as String?,shortNameRu: freezed == shortNameRu ? _self.shortNameRu : shortNameRu // ignore: cast_nullable_to_non_nullable
as String?,shortNameEn: freezed == shortNameEn ? _self.shortNameEn : shortNameEn // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
