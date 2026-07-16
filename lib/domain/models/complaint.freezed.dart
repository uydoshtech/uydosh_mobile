// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ComplaintComplainantProfile {

 String? get name;@JsonKey(name: "avatar_url") String? get avatarUrl;
/// Create a copy of ComplaintComplainantProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintComplainantProfileCopyWith<ComplaintComplainantProfile> get copyWith => _$ComplaintComplainantProfileCopyWithImpl<ComplaintComplainantProfile>(this as ComplaintComplainantProfile, _$identity);

  /// Serializes this ComplaintComplainantProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintComplainantProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl);

@override
String toString() {
  return 'ComplaintComplainantProfile(name: $name, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $ComplaintComplainantProfileCopyWith<$Res>  {
  factory $ComplaintComplainantProfileCopyWith(ComplaintComplainantProfile value, $Res Function(ComplaintComplainantProfile) _then) = _$ComplaintComplainantProfileCopyWithImpl;
@useResult
$Res call({
 String? name,@JsonKey(name: "avatar_url") String? avatarUrl
});




}
/// @nodoc
class _$ComplaintComplainantProfileCopyWithImpl<$Res>
    implements $ComplaintComplainantProfileCopyWith<$Res> {
  _$ComplaintComplainantProfileCopyWithImpl(this._self, this._then);

  final ComplaintComplainantProfile _self;
  final $Res Function(ComplaintComplainantProfile) _then;

/// Create a copy of ComplaintComplainantProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ComplaintComplainantProfile].
extension ComplaintComplainantProfilePatterns on ComplaintComplainantProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintComplainantProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintComplainantProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintComplainantProfile value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintComplainantProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintComplainantProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintComplainantProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name, @JsonKey(name: "avatar_url")  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintComplainantProfile() when $default != null:
return $default(_that.name,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name, @JsonKey(name: "avatar_url")  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _ComplaintComplainantProfile():
return $default(_that.name,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name, @JsonKey(name: "avatar_url")  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintComplainantProfile() when $default != null:
return $default(_that.name,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintComplainantProfile implements ComplaintComplainantProfile {
  const _ComplaintComplainantProfile({this.name, @JsonKey(name: "avatar_url") this.avatarUrl});
  factory _ComplaintComplainantProfile.fromJson(Map<String, dynamic> json) => _$ComplaintComplainantProfileFromJson(json);

@override final  String? name;
@override@JsonKey(name: "avatar_url") final  String? avatarUrl;

/// Create a copy of ComplaintComplainantProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintComplainantProfileCopyWith<_ComplaintComplainantProfile> get copyWith => __$ComplaintComplainantProfileCopyWithImpl<_ComplaintComplainantProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintComplainantProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintComplainantProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl);

@override
String toString() {
  return 'ComplaintComplainantProfile(name: $name, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$ComplaintComplainantProfileCopyWith<$Res> implements $ComplaintComplainantProfileCopyWith<$Res> {
  factory _$ComplaintComplainantProfileCopyWith(_ComplaintComplainantProfile value, $Res Function(_ComplaintComplainantProfile) _then) = __$ComplaintComplainantProfileCopyWithImpl;
@override @useResult
$Res call({
 String? name,@JsonKey(name: "avatar_url") String? avatarUrl
});




}
/// @nodoc
class __$ComplaintComplainantProfileCopyWithImpl<$Res>
    implements _$ComplaintComplainantProfileCopyWith<$Res> {
  __$ComplaintComplainantProfileCopyWithImpl(this._self, this._then);

  final _ComplaintComplainantProfile _self;
  final $Res Function(_ComplaintComplainantProfile) _then;

/// Create a copy of ComplaintComplainantProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? avatarUrl = freezed,}) {
  return _then(_ComplaintComplainantProfile(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ComplaintComplainant {

 int? get id; ComplaintComplainantProfile? get profile;
/// Create a copy of ComplaintComplainant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintComplainantCopyWith<ComplaintComplainant> get copyWith => _$ComplaintComplainantCopyWithImpl<ComplaintComplainant>(this as ComplaintComplainant, _$identity);

  /// Serializes this ComplaintComplainant to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintComplainant&&(identical(other.id, id) || other.id == id)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,profile);

@override
String toString() {
  return 'ComplaintComplainant(id: $id, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $ComplaintComplainantCopyWith<$Res>  {
  factory $ComplaintComplainantCopyWith(ComplaintComplainant value, $Res Function(ComplaintComplainant) _then) = _$ComplaintComplainantCopyWithImpl;
@useResult
$Res call({
 int? id, ComplaintComplainantProfile? profile
});


$ComplaintComplainantProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$ComplaintComplainantCopyWithImpl<$Res>
    implements $ComplaintComplainantCopyWith<$Res> {
  _$ComplaintComplainantCopyWithImpl(this._self, this._then);

  final ComplaintComplainant _self;
  final $Res Function(ComplaintComplainant) _then;

/// Create a copy of ComplaintComplainant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? profile = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ComplaintComplainantProfile?,
  ));
}
/// Create a copy of ComplaintComplainant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintComplainantProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ComplaintComplainantProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [ComplaintComplainant].
extension ComplaintComplainantPatterns on ComplaintComplainant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ComplaintComplainant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ComplaintComplainant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ComplaintComplainant value)  $default,){
final _that = this;
switch (_that) {
case _ComplaintComplainant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ComplaintComplainant value)?  $default,){
final _that = this;
switch (_that) {
case _ComplaintComplainant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  ComplaintComplainantProfile? profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ComplaintComplainant() when $default != null:
return $default(_that.id,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  ComplaintComplainantProfile? profile)  $default,) {final _that = this;
switch (_that) {
case _ComplaintComplainant():
return $default(_that.id,_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  ComplaintComplainantProfile? profile)?  $default,) {final _that = this;
switch (_that) {
case _ComplaintComplainant() when $default != null:
return $default(_that.id,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ComplaintComplainant implements ComplaintComplainant {
  const _ComplaintComplainant({this.id, this.profile});
  factory _ComplaintComplainant.fromJson(Map<String, dynamic> json) => _$ComplaintComplainantFromJson(json);

@override final  int? id;
@override final  ComplaintComplainantProfile? profile;

/// Create a copy of ComplaintComplainant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintComplainantCopyWith<_ComplaintComplainant> get copyWith => __$ComplaintComplainantCopyWithImpl<_ComplaintComplainant>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintComplainantToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintComplainant&&(identical(other.id, id) || other.id == id)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,profile);

@override
String toString() {
  return 'ComplaintComplainant(id: $id, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$ComplaintComplainantCopyWith<$Res> implements $ComplaintComplainantCopyWith<$Res> {
  factory _$ComplaintComplainantCopyWith(_ComplaintComplainant value, $Res Function(_ComplaintComplainant) _then) = __$ComplaintComplainantCopyWithImpl;
@override @useResult
$Res call({
 int? id, ComplaintComplainantProfile? profile
});


@override $ComplaintComplainantProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$ComplaintComplainantCopyWithImpl<$Res>
    implements _$ComplaintComplainantCopyWith<$Res> {
  __$ComplaintComplainantCopyWithImpl(this._self, this._then);

  final _ComplaintComplainant _self;
  final $Res Function(_ComplaintComplainant) _then;

/// Create a copy of ComplaintComplainant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? profile = freezed,}) {
  return _then(_ComplaintComplainant(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as ComplaintComplainantProfile?,
  ));
}

/// Create a copy of ComplaintComplainant
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintComplainantProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $ComplaintComplainantProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$Complaint {

@JsonKey(name: "status", fromJson: _complaintStatusFromJson, defaultValue: "pending") String get status; int? get id;@JsonKey(name: "complainant_id") int? get complainantId;@JsonKey(name: "complainant") ComplaintComplainant? get complainant;@JsonKey(name: "listing_id") int? get listingId;@JsonKey(name: "category_id") int? get categoryId;@JsonKey(name: "category") ComplaintCategory? get category; String? get text;@JsonKey(name: "created_at") String? get createdAt;@JsonKey(name: "updated_at") String? get updatedAt;
/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ComplaintCopyWith<Complaint> get copyWith => _$ComplaintCopyWithImpl<Complaint>(this as Complaint, _$identity);

  /// Serializes this Complaint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Complaint&&(identical(other.status, status) || other.status == status)&&(identical(other.id, id) || other.id == id)&&(identical(other.complainantId, complainantId) || other.complainantId == complainantId)&&(identical(other.complainant, complainant) || other.complainant == complainant)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,id,complainantId,complainant,listingId,categoryId,category,text,createdAt,updatedAt);

@override
String toString() {
  return 'Complaint(status: $status, id: $id, complainantId: $complainantId, complainant: $complainant, listingId: $listingId, categoryId: $categoryId, category: $category, text: $text, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ComplaintCopyWith<$Res>  {
  factory $ComplaintCopyWith(Complaint value, $Res Function(Complaint) _then) = _$ComplaintCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "status", fromJson: _complaintStatusFromJson, defaultValue: "pending") String status, int? id,@JsonKey(name: "complainant_id") int? complainantId,@JsonKey(name: "complainant") ComplaintComplainant? complainant,@JsonKey(name: "listing_id") int? listingId,@JsonKey(name: "category_id") int? categoryId,@JsonKey(name: "category") ComplaintCategory? category, String? text,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});


$ComplaintComplainantCopyWith<$Res>? get complainant;$ComplaintCategoryCopyWith<$Res>? get category;

}
/// @nodoc
class _$ComplaintCopyWithImpl<$Res>
    implements $ComplaintCopyWith<$Res> {
  _$ComplaintCopyWithImpl(this._self, this._then);

  final Complaint _self;
  final $Res Function(Complaint) _then;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? id = freezed,Object? complainantId = freezed,Object? complainant = freezed,Object? listingId = freezed,Object? categoryId = freezed,Object? category = freezed,Object? text = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,complainantId: freezed == complainantId ? _self.complainantId : complainantId // ignore: cast_nullable_to_non_nullable
as int?,complainant: freezed == complainant ? _self.complainant : complainant // ignore: cast_nullable_to_non_nullable
as ComplaintComplainant?,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ComplaintCategory?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintComplainantCopyWith<$Res>? get complainant {
    if (_self.complainant == null) {
    return null;
  }

  return $ComplaintComplainantCopyWith<$Res>(_self.complainant!, (value) {
    return _then(_self.copyWith(complainant: value));
  });
}/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintCategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $ComplaintCategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [Complaint].
extension ComplaintPatterns on Complaint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Complaint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Complaint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Complaint value)  $default,){
final _that = this;
switch (_that) {
case _Complaint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Complaint value)?  $default,){
final _that = this;
switch (_that) {
case _Complaint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "status", fromJson: _complaintStatusFromJson, defaultValue: "pending")  String status,  int? id, @JsonKey(name: "complainant_id")  int? complainantId, @JsonKey(name: "complainant")  ComplaintComplainant? complainant, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "category_id")  int? categoryId, @JsonKey(name: "category")  ComplaintCategory? category,  String? text, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Complaint() when $default != null:
return $default(_that.status,_that.id,_that.complainantId,_that.complainant,_that.listingId,_that.categoryId,_that.category,_that.text,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "status", fromJson: _complaintStatusFromJson, defaultValue: "pending")  String status,  int? id, @JsonKey(name: "complainant_id")  int? complainantId, @JsonKey(name: "complainant")  ComplaintComplainant? complainant, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "category_id")  int? categoryId, @JsonKey(name: "category")  ComplaintCategory? category,  String? text, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Complaint():
return $default(_that.status,_that.id,_that.complainantId,_that.complainant,_that.listingId,_that.categoryId,_that.category,_that.text,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "status", fromJson: _complaintStatusFromJson, defaultValue: "pending")  String status,  int? id, @JsonKey(name: "complainant_id")  int? complainantId, @JsonKey(name: "complainant")  ComplaintComplainant? complainant, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "category_id")  int? categoryId, @JsonKey(name: "category")  ComplaintCategory? category,  String? text, @JsonKey(name: "created_at")  String? createdAt, @JsonKey(name: "updated_at")  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Complaint() when $default != null:
return $default(_that.status,_that.id,_that.complainantId,_that.complainant,_that.listingId,_that.categoryId,_that.category,_that.text,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Complaint implements Complaint {
  const _Complaint({@JsonKey(name: "status", fromJson: _complaintStatusFromJson, defaultValue: "pending") required this.status, this.id, @JsonKey(name: "complainant_id") this.complainantId, @JsonKey(name: "complainant") this.complainant, @JsonKey(name: "listing_id") this.listingId, @JsonKey(name: "category_id") this.categoryId, @JsonKey(name: "category") this.category, this.text, @JsonKey(name: "created_at") this.createdAt, @JsonKey(name: "updated_at") this.updatedAt});
  factory _Complaint.fromJson(Map<String, dynamic> json) => _$ComplaintFromJson(json);

@override@JsonKey(name: "status", fromJson: _complaintStatusFromJson, defaultValue: "pending") final  String status;
@override final  int? id;
@override@JsonKey(name: "complainant_id") final  int? complainantId;
@override@JsonKey(name: "complainant") final  ComplaintComplainant? complainant;
@override@JsonKey(name: "listing_id") final  int? listingId;
@override@JsonKey(name: "category_id") final  int? categoryId;
@override@JsonKey(name: "category") final  ComplaintCategory? category;
@override final  String? text;
@override@JsonKey(name: "created_at") final  String? createdAt;
@override@JsonKey(name: "updated_at") final  String? updatedAt;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintCopyWith<_Complaint> get copyWith => __$ComplaintCopyWithImpl<_Complaint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ComplaintToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Complaint&&(identical(other.status, status) || other.status == status)&&(identical(other.id, id) || other.id == id)&&(identical(other.complainantId, complainantId) || other.complainantId == complainantId)&&(identical(other.complainant, complainant) || other.complainant == complainant)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.category, category) || other.category == category)&&(identical(other.text, text) || other.text == text)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,id,complainantId,complainant,listingId,categoryId,category,text,createdAt,updatedAt);

@override
String toString() {
  return 'Complaint(status: $status, id: $id, complainantId: $complainantId, complainant: $complainant, listingId: $listingId, categoryId: $categoryId, category: $category, text: $text, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ComplaintCopyWith<$Res> implements $ComplaintCopyWith<$Res> {
  factory _$ComplaintCopyWith(_Complaint value, $Res Function(_Complaint) _then) = __$ComplaintCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "status", fromJson: _complaintStatusFromJson, defaultValue: "pending") String status, int? id,@JsonKey(name: "complainant_id") int? complainantId,@JsonKey(name: "complainant") ComplaintComplainant? complainant,@JsonKey(name: "listing_id") int? listingId,@JsonKey(name: "category_id") int? categoryId,@JsonKey(name: "category") ComplaintCategory? category, String? text,@JsonKey(name: "created_at") String? createdAt,@JsonKey(name: "updated_at") String? updatedAt
});


@override $ComplaintComplainantCopyWith<$Res>? get complainant;@override $ComplaintCategoryCopyWith<$Res>? get category;

}
/// @nodoc
class __$ComplaintCopyWithImpl<$Res>
    implements _$ComplaintCopyWith<$Res> {
  __$ComplaintCopyWithImpl(this._self, this._then);

  final _Complaint _self;
  final $Res Function(_Complaint) _then;

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? id = freezed,Object? complainantId = freezed,Object? complainant = freezed,Object? listingId = freezed,Object? categoryId = freezed,Object? category = freezed,Object? text = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Complaint(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,complainantId: freezed == complainantId ? _self.complainantId : complainantId // ignore: cast_nullable_to_non_nullable
as int?,complainant: freezed == complainant ? _self.complainant : complainant // ignore: cast_nullable_to_non_nullable
as ComplaintComplainant?,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ComplaintCategory?,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintComplainantCopyWith<$Res>? get complainant {
    if (_self.complainant == null) {
    return null;
  }

  return $ComplaintComplainantCopyWith<$Res>(_self.complainant!, (value) {
    return _then(_self.copyWith(complainant: value));
  });
}/// Create a copy of Complaint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintCategoryCopyWith<$Res>? get category {
    if (_self.category == null) {
    return null;
  }

  return $ComplaintCategoryCopyWith<$Res>(_self.category!, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// @nodoc
mixin _$CreateComplaintRequest {

@JsonKey(name: "listing_id") int get listingId;@JsonKey(name: "category_id") int get categoryId; String? get text;
/// Create a copy of CreateComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateComplaintRequestCopyWith<CreateComplaintRequest> get copyWith => _$CreateComplaintRequestCopyWithImpl<CreateComplaintRequest>(this as CreateComplaintRequest, _$identity);

  /// Serializes this CreateComplaintRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateComplaintRequest&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,listingId,categoryId,text);

@override
String toString() {
  return 'CreateComplaintRequest(listingId: $listingId, categoryId: $categoryId, text: $text)';
}


}

/// @nodoc
abstract mixin class $CreateComplaintRequestCopyWith<$Res>  {
  factory $CreateComplaintRequestCopyWith(CreateComplaintRequest value, $Res Function(CreateComplaintRequest) _then) = _$CreateComplaintRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "listing_id") int listingId,@JsonKey(name: "category_id") int categoryId, String? text
});




}
/// @nodoc
class _$CreateComplaintRequestCopyWithImpl<$Res>
    implements $CreateComplaintRequestCopyWith<$Res> {
  _$CreateComplaintRequestCopyWithImpl(this._self, this._then);

  final CreateComplaintRequest _self;
  final $Res Function(CreateComplaintRequest) _then;

/// Create a copy of CreateComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listingId = null,Object? categoryId = null,Object? text = freezed,}) {
  return _then(_self.copyWith(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateComplaintRequest].
extension CreateComplaintRequestPatterns on CreateComplaintRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateComplaintRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateComplaintRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateComplaintRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateComplaintRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateComplaintRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateComplaintRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "listing_id")  int listingId, @JsonKey(name: "category_id")  int categoryId,  String? text)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateComplaintRequest() when $default != null:
return $default(_that.listingId,_that.categoryId,_that.text);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "listing_id")  int listingId, @JsonKey(name: "category_id")  int categoryId,  String? text)  $default,) {final _that = this;
switch (_that) {
case _CreateComplaintRequest():
return $default(_that.listingId,_that.categoryId,_that.text);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "listing_id")  int listingId, @JsonKey(name: "category_id")  int categoryId,  String? text)?  $default,) {final _that = this;
switch (_that) {
case _CreateComplaintRequest() when $default != null:
return $default(_that.listingId,_that.categoryId,_that.text);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateComplaintRequest implements CreateComplaintRequest {
  const _CreateComplaintRequest({@JsonKey(name: "listing_id") required this.listingId, @JsonKey(name: "category_id") required this.categoryId, this.text});
  factory _CreateComplaintRequest.fromJson(Map<String, dynamic> json) => _$CreateComplaintRequestFromJson(json);

@override@JsonKey(name: "listing_id") final  int listingId;
@override@JsonKey(name: "category_id") final  int categoryId;
@override final  String? text;

/// Create a copy of CreateComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateComplaintRequestCopyWith<_CreateComplaintRequest> get copyWith => __$CreateComplaintRequestCopyWithImpl<_CreateComplaintRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateComplaintRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateComplaintRequest&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.text, text) || other.text == text));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,listingId,categoryId,text);

@override
String toString() {
  return 'CreateComplaintRequest(listingId: $listingId, categoryId: $categoryId, text: $text)';
}


}

/// @nodoc
abstract mixin class _$CreateComplaintRequestCopyWith<$Res> implements $CreateComplaintRequestCopyWith<$Res> {
  factory _$CreateComplaintRequestCopyWith(_CreateComplaintRequest value, $Res Function(_CreateComplaintRequest) _then) = __$CreateComplaintRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "listing_id") int listingId,@JsonKey(name: "category_id") int categoryId, String? text
});




}
/// @nodoc
class __$CreateComplaintRequestCopyWithImpl<$Res>
    implements _$CreateComplaintRequestCopyWith<$Res> {
  __$CreateComplaintRequestCopyWithImpl(this._self, this._then);

  final _CreateComplaintRequest _self;
  final $Res Function(_CreateComplaintRequest) _then;

/// Create a copy of CreateComplaintRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingId = null,Object? categoryId = null,Object? text = freezed,}) {
  return _then(_CreateComplaintRequest(
listingId: null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as int,text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
