// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_sender.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageSender {

 int get id;// All three identity fields are independently nullable because a user may
// have signed in via only one of Google (email + firebase_uid), Phone
// (firebase_uid + phone_number), or Telegram (telegram_id). The backend
// returns whichever are present and `null` for the rest.
 String? get email;@JsonKey(name: "firebase_uid") String? get firebaseUid;@JsonKey(name: "telegram_id") String? get telegramId;@JsonKey(name: "phone_number") String? get phoneNumber; MessageSenderProfile? get profile;
/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<MessageSender> get copyWith => _$MessageSenderCopyWithImpl<MessageSender>(this as MessageSender, _$identity);

  /// Serializes this MessageSender to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSender&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firebaseUid, firebaseUid) || other.firebaseUid == firebaseUid)&&(identical(other.telegramId, telegramId) || other.telegramId == telegramId)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,firebaseUid,telegramId,phoneNumber,profile);

@override
String toString() {
  return 'MessageSender(id: $id, email: $email, firebaseUid: $firebaseUid, telegramId: $telegramId, phoneNumber: $phoneNumber, profile: $profile)';
}


}

/// @nodoc
abstract mixin class $MessageSenderCopyWith<$Res>  {
  factory $MessageSenderCopyWith(MessageSender value, $Res Function(MessageSender) _then) = _$MessageSenderCopyWithImpl;
@useResult
$Res call({
 int id, String? email,@JsonKey(name: "firebase_uid") String? firebaseUid,@JsonKey(name: "telegram_id") String? telegramId,@JsonKey(name: "phone_number") String? phoneNumber, MessageSenderProfile? profile
});


$MessageSenderProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class _$MessageSenderCopyWithImpl<$Res>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._self, this._then);

  final MessageSender _self;
  final $Res Function(MessageSender) _then;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = freezed,Object? firebaseUid = freezed,Object? telegramId = freezed,Object? phoneNumber = freezed,Object? profile = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firebaseUid: freezed == firebaseUid ? _self.firebaseUid : firebaseUid // ignore: cast_nullable_to_non_nullable
as String?,telegramId: freezed == telegramId ? _self.telegramId : telegramId // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as MessageSenderProfile?,
  ));
}
/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $MessageSenderProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// Adds pattern-matching-related methods to [MessageSender].
extension MessageSenderPatterns on MessageSender {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSender value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSender value)  $default,){
final _that = this;
switch (_that) {
case _MessageSender():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSender value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? email, @JsonKey(name: "firebase_uid")  String? firebaseUid, @JsonKey(name: "telegram_id")  String? telegramId, @JsonKey(name: "phone_number")  String? phoneNumber,  MessageSenderProfile? profile)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that.id,_that.email,_that.firebaseUid,_that.telegramId,_that.phoneNumber,_that.profile);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? email, @JsonKey(name: "firebase_uid")  String? firebaseUid, @JsonKey(name: "telegram_id")  String? telegramId, @JsonKey(name: "phone_number")  String? phoneNumber,  MessageSenderProfile? profile)  $default,) {final _that = this;
switch (_that) {
case _MessageSender():
return $default(_that.id,_that.email,_that.firebaseUid,_that.telegramId,_that.phoneNumber,_that.profile);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? email, @JsonKey(name: "firebase_uid")  String? firebaseUid, @JsonKey(name: "telegram_id")  String? telegramId, @JsonKey(name: "phone_number")  String? phoneNumber,  MessageSenderProfile? profile)?  $default,) {final _that = this;
switch (_that) {
case _MessageSender() when $default != null:
return $default(_that.id,_that.email,_that.firebaseUid,_that.telegramId,_that.phoneNumber,_that.profile);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageSender implements MessageSender {
  const _MessageSender({required this.id, this.email, @JsonKey(name: "firebase_uid") this.firebaseUid, @JsonKey(name: "telegram_id") this.telegramId, @JsonKey(name: "phone_number") this.phoneNumber, this.profile});
  factory _MessageSender.fromJson(Map<String, dynamic> json) => _$MessageSenderFromJson(json);

@override final  int id;
// All three identity fields are independently nullable because a user may
// have signed in via only one of Google (email + firebase_uid), Phone
// (firebase_uid + phone_number), or Telegram (telegram_id). The backend
// returns whichever are present and `null` for the rest.
@override final  String? email;
@override@JsonKey(name: "firebase_uid") final  String? firebaseUid;
@override@JsonKey(name: "telegram_id") final  String? telegramId;
@override@JsonKey(name: "phone_number") final  String? phoneNumber;
@override final  MessageSenderProfile? profile;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSenderCopyWith<_MessageSender> get copyWith => __$MessageSenderCopyWithImpl<_MessageSender>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageSenderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSender&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.firebaseUid, firebaseUid) || other.firebaseUid == firebaseUid)&&(identical(other.telegramId, telegramId) || other.telegramId == telegramId)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.profile, profile) || other.profile == profile));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,firebaseUid,telegramId,phoneNumber,profile);

@override
String toString() {
  return 'MessageSender(id: $id, email: $email, firebaseUid: $firebaseUid, telegramId: $telegramId, phoneNumber: $phoneNumber, profile: $profile)';
}


}

/// @nodoc
abstract mixin class _$MessageSenderCopyWith<$Res> implements $MessageSenderCopyWith<$Res> {
  factory _$MessageSenderCopyWith(_MessageSender value, $Res Function(_MessageSender) _then) = __$MessageSenderCopyWithImpl;
@override @useResult
$Res call({
 int id, String? email,@JsonKey(name: "firebase_uid") String? firebaseUid,@JsonKey(name: "telegram_id") String? telegramId,@JsonKey(name: "phone_number") String? phoneNumber, MessageSenderProfile? profile
});


@override $MessageSenderProfileCopyWith<$Res>? get profile;

}
/// @nodoc
class __$MessageSenderCopyWithImpl<$Res>
    implements _$MessageSenderCopyWith<$Res> {
  __$MessageSenderCopyWithImpl(this._self, this._then);

  final _MessageSender _self;
  final $Res Function(_MessageSender) _then;

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = freezed,Object? firebaseUid = freezed,Object? telegramId = freezed,Object? phoneNumber = freezed,Object? profile = freezed,}) {
  return _then(_MessageSender(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,firebaseUid: freezed == firebaseUid ? _self.firebaseUid : firebaseUid // ignore: cast_nullable_to_non_nullable
as String?,telegramId: freezed == telegramId ? _self.telegramId : telegramId // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,profile: freezed == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as MessageSenderProfile?,
  ));
}

/// Create a copy of MessageSender
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderProfileCopyWith<$Res>? get profile {
    if (_self.profile == null) {
    return null;
  }

  return $MessageSenderProfileCopyWith<$Res>(_self.profile!, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}


/// @nodoc
mixin _$MessageSenderProfile {

 String? get name;@JsonKey(name: "avatar_url") String? get avatarUrl;
/// Create a copy of MessageSenderProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageSenderProfileCopyWith<MessageSenderProfile> get copyWith => _$MessageSenderProfileCopyWithImpl<MessageSenderProfile>(this as MessageSenderProfile, _$identity);

  /// Serializes this MessageSenderProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSenderProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl);

@override
String toString() {
  return 'MessageSenderProfile(name: $name, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class $MessageSenderProfileCopyWith<$Res>  {
  factory $MessageSenderProfileCopyWith(MessageSenderProfile value, $Res Function(MessageSenderProfile) _then) = _$MessageSenderProfileCopyWithImpl;
@useResult
$Res call({
 String? name,@JsonKey(name: "avatar_url") String? avatarUrl
});




}
/// @nodoc
class _$MessageSenderProfileCopyWithImpl<$Res>
    implements $MessageSenderProfileCopyWith<$Res> {
  _$MessageSenderProfileCopyWithImpl(this._self, this._then);

  final MessageSenderProfile _self;
  final $Res Function(MessageSenderProfile) _then;

/// Create a copy of MessageSenderProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? avatarUrl = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageSenderProfile].
extension MessageSenderProfilePatterns on MessageSenderProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageSenderProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageSenderProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageSenderProfile value)  $default,){
final _that = this;
switch (_that) {
case _MessageSenderProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageSenderProfile value)?  $default,){
final _that = this;
switch (_that) {
case _MessageSenderProfile() when $default != null:
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
case _MessageSenderProfile() when $default != null:
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
case _MessageSenderProfile():
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
case _MessageSenderProfile() when $default != null:
return $default(_that.name,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageSenderProfile implements MessageSenderProfile {
  const _MessageSenderProfile({this.name, @JsonKey(name: "avatar_url") this.avatarUrl});
  factory _MessageSenderProfile.fromJson(Map<String, dynamic> json) => _$MessageSenderProfileFromJson(json);

@override final  String? name;
@override@JsonKey(name: "avatar_url") final  String? avatarUrl;

/// Create a copy of MessageSenderProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSenderProfileCopyWith<_MessageSenderProfile> get copyWith => __$MessageSenderProfileCopyWithImpl<_MessageSenderProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageSenderProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSenderProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,avatarUrl);

@override
String toString() {
  return 'MessageSenderProfile(name: $name, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$MessageSenderProfileCopyWith<$Res> implements $MessageSenderProfileCopyWith<$Res> {
  factory _$MessageSenderProfileCopyWith(_MessageSenderProfile value, $Res Function(_MessageSenderProfile) _then) = __$MessageSenderProfileCopyWithImpl;
@override @useResult
$Res call({
 String? name,@JsonKey(name: "avatar_url") String? avatarUrl
});




}
/// @nodoc
class __$MessageSenderProfileCopyWithImpl<$Res>
    implements _$MessageSenderProfileCopyWith<$Res> {
  __$MessageSenderProfileCopyWithImpl(this._self, this._then);

  final _MessageSenderProfile _self;
  final $Res Function(_MessageSenderProfile) _then;

/// Create a copy of MessageSenderProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? avatarUrl = freezed,}) {
  return _then(_MessageSenderProfile(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
