// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_owner_profile_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListingOwnerProfileEvent {

 int get userId;
/// Create a copy of ListingOwnerProfileEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingOwnerProfileEventCopyWith<ListingOwnerProfileEvent> get copyWith => _$ListingOwnerProfileEventCopyWithImpl<ListingOwnerProfileEvent>(this as ListingOwnerProfileEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingOwnerProfileEvent&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'ListingOwnerProfileEvent(userId: $userId)';
}


}

/// @nodoc
abstract mixin class $ListingOwnerProfileEventCopyWith<$Res>  {
  factory $ListingOwnerProfileEventCopyWith(ListingOwnerProfileEvent value, $Res Function(ListingOwnerProfileEvent) _then) = _$ListingOwnerProfileEventCopyWithImpl;
@useResult
$Res call({
 int userId
});




}
/// @nodoc
class _$ListingOwnerProfileEventCopyWithImpl<$Res>
    implements $ListingOwnerProfileEventCopyWith<$Res> {
  _$ListingOwnerProfileEventCopyWithImpl(this._self, this._then);

  final ListingOwnerProfileEvent _self;
  final $Res Function(ListingOwnerProfileEvent) _then;

/// Create a copy of ListingOwnerProfileEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingOwnerProfileEvent].
extension ListingOwnerProfileEventPatterns on ListingOwnerProfileEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FetchProfile value)?  fetchProfile,TResult Function( _ToggleFollow value)?  toggleFollow,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FetchProfile() when fetchProfile != null:
return fetchProfile(_that);case _ToggleFollow() when toggleFollow != null:
return toggleFollow(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FetchProfile value)  fetchProfile,required TResult Function( _ToggleFollow value)  toggleFollow,}){
final _that = this;
switch (_that) {
case _FetchProfile():
return fetchProfile(_that);case _ToggleFollow():
return toggleFollow(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FetchProfile value)?  fetchProfile,TResult? Function( _ToggleFollow value)?  toggleFollow,}){
final _that = this;
switch (_that) {
case _FetchProfile() when fetchProfile != null:
return fetchProfile(_that);case _ToggleFollow() when toggleFollow != null:
return toggleFollow(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int userId)?  fetchProfile,TResult Function( int userId)?  toggleFollow,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FetchProfile() when fetchProfile != null:
return fetchProfile(_that.userId);case _ToggleFollow() when toggleFollow != null:
return toggleFollow(_that.userId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int userId)  fetchProfile,required TResult Function( int userId)  toggleFollow,}) {final _that = this;
switch (_that) {
case _FetchProfile():
return fetchProfile(_that.userId);case _ToggleFollow():
return toggleFollow(_that.userId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int userId)?  fetchProfile,TResult? Function( int userId)?  toggleFollow,}) {final _that = this;
switch (_that) {
case _FetchProfile() when fetchProfile != null:
return fetchProfile(_that.userId);case _ToggleFollow() when toggleFollow != null:
return toggleFollow(_that.userId);case _:
  return null;

}
}

}

/// @nodoc


class _FetchProfile implements ListingOwnerProfileEvent {
  const _FetchProfile({required this.userId});
  

@override final  int userId;

/// Create a copy of ListingOwnerProfileEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchProfileCopyWith<_FetchProfile> get copyWith => __$FetchProfileCopyWithImpl<_FetchProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchProfile&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'ListingOwnerProfileEvent.fetchProfile(userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$FetchProfileCopyWith<$Res> implements $ListingOwnerProfileEventCopyWith<$Res> {
  factory _$FetchProfileCopyWith(_FetchProfile value, $Res Function(_FetchProfile) _then) = __$FetchProfileCopyWithImpl;
@override @useResult
$Res call({
 int userId
});




}
/// @nodoc
class __$FetchProfileCopyWithImpl<$Res>
    implements _$FetchProfileCopyWith<$Res> {
  __$FetchProfileCopyWithImpl(this._self, this._then);

  final _FetchProfile _self;
  final $Res Function(_FetchProfile) _then;

/// Create a copy of ListingOwnerProfileEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(_FetchProfile(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ToggleFollow implements ListingOwnerProfileEvent {
  const _ToggleFollow({required this.userId});
  

@override final  int userId;

/// Create a copy of ListingOwnerProfileEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToggleFollowCopyWith<_ToggleFollow> get copyWith => __$ToggleFollowCopyWithImpl<_ToggleFollow>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleFollow&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'ListingOwnerProfileEvent.toggleFollow(userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$ToggleFollowCopyWith<$Res> implements $ListingOwnerProfileEventCopyWith<$Res> {
  factory _$ToggleFollowCopyWith(_ToggleFollow value, $Res Function(_ToggleFollow) _then) = __$ToggleFollowCopyWithImpl;
@override @useResult
$Res call({
 int userId
});




}
/// @nodoc
class __$ToggleFollowCopyWithImpl<$Res>
    implements _$ToggleFollowCopyWith<$Res> {
  __$ToggleFollowCopyWithImpl(this._self, this._then);

  final _ToggleFollow _self;
  final $Res Function(_ToggleFollow) _then;

/// Create a copy of ListingOwnerProfileEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(_ToggleFollow(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ListingOwnerProfileState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingOwnerProfileState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ListingOwnerProfileState()';
}


}

/// @nodoc
class $ListingOwnerProfileStateCopyWith<$Res>  {
$ListingOwnerProfileStateCopyWith(ListingOwnerProfileState _, $Res Function(ListingOwnerProfileState) __);
}


/// Adds pattern-matching-related methods to [ListingOwnerProfileState].
extension ListingOwnerProfileStatePatterns on ListingOwnerProfileState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( UserProfile profile,  bool isFollowing,  bool isFollowLoading,  List<CommonFriend> commonFriends,  int commonFriendsTotal,  bool canFollow)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.profile,_that.isFollowing,_that.isFollowLoading,_that.commonFriends,_that.commonFriendsTotal,_that.canFollow);case _Error() when error != null:
return error(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( UserProfile profile,  bool isFollowing,  bool isFollowLoading,  List<CommonFriend> commonFriends,  int commonFriendsTotal,  bool canFollow)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.profile,_that.isFollowing,_that.isFollowLoading,_that.commonFriends,_that.commonFriendsTotal,_that.canFollow);case _Error():
return error(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( UserProfile profile,  bool isFollowing,  bool isFollowLoading,  List<CommonFriend> commonFriends,  int commonFriendsTotal,  bool canFollow)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.profile,_that.isFollowing,_that.isFollowLoading,_that.commonFriends,_that.commonFriendsTotal,_that.canFollow);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ListingOwnerProfileState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ListingOwnerProfileState.initial()';
}


}




/// @nodoc


class _Loading implements ListingOwnerProfileState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ListingOwnerProfileState.loading()';
}


}




/// @nodoc


class _Loaded implements ListingOwnerProfileState {
  const _Loaded({required this.profile, this.isFollowing = false, this.isFollowLoading = false, final  List<CommonFriend> commonFriends = const <CommonFriend>[], this.commonFriendsTotal = 0, this.canFollow = false}): _commonFriends = commonFriends;
  

 final  UserProfile profile;
@JsonKey() final  bool isFollowing;
@JsonKey() final  bool isFollowLoading;
 final  List<CommonFriend> _commonFriends;
@JsonKey() List<CommonFriend> get commonFriends {
  if (_commonFriends is EqualUnmodifiableListView) return _commonFriends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_commonFriends);
}

@JsonKey() final  int commonFriendsTotal;
@JsonKey() final  bool canFollow;

/// Create a copy of ListingOwnerProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.isFollowLoading, isFollowLoading) || other.isFollowLoading == isFollowLoading)&&const DeepCollectionEquality().equals(other._commonFriends, _commonFriends)&&(identical(other.commonFriendsTotal, commonFriendsTotal) || other.commonFriendsTotal == commonFriendsTotal)&&(identical(other.canFollow, canFollow) || other.canFollow == canFollow));
}


@override
int get hashCode => Object.hash(runtimeType,profile,isFollowing,isFollowLoading,const DeepCollectionEquality().hash(_commonFriends),commonFriendsTotal,canFollow);

@override
String toString() {
  return 'ListingOwnerProfileState.loaded(profile: $profile, isFollowing: $isFollowing, isFollowLoading: $isFollowLoading, commonFriends: $commonFriends, commonFriendsTotal: $commonFriendsTotal, canFollow: $canFollow)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $ListingOwnerProfileStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 UserProfile profile, bool isFollowing, bool isFollowLoading, List<CommonFriend> commonFriends, int commonFriendsTotal, bool canFollow
});


$UserProfileCopyWith<$Res> get profile;

}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of ListingOwnerProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? profile = null,Object? isFollowing = null,Object? isFollowLoading = null,Object? commonFriends = null,Object? commonFriendsTotal = null,Object? canFollow = null,}) {
  return _then(_Loaded(
profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as UserProfile,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,isFollowLoading: null == isFollowLoading ? _self.isFollowLoading : isFollowLoading // ignore: cast_nullable_to_non_nullable
as bool,commonFriends: null == commonFriends ? _self._commonFriends : commonFriends // ignore: cast_nullable_to_non_nullable
as List<CommonFriend>,commonFriendsTotal: null == commonFriendsTotal ? _self.commonFriendsTotal : commonFriendsTotal // ignore: cast_nullable_to_non_nullable
as int,canFollow: null == canFollow ? _self.canFollow : canFollow // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ListingOwnerProfileState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res> get profile {
  
  return $UserProfileCopyWith<$Res>(_self.profile, (value) {
    return _then(_self.copyWith(profile: value));
  });
}
}

/// @nodoc


class _Error implements ListingOwnerProfileState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of ListingOwnerProfileState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'ListingOwnerProfileState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ListingOwnerProfileStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of ListingOwnerProfileState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
