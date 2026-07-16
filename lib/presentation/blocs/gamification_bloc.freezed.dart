// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gamification_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GamificationEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamificationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GamificationEvent()';
}


}

/// @nodoc
class $GamificationEventCopyWith<$Res>  {
$GamificationEventCopyWith(GamificationEvent _, $Res Function(GamificationEvent) __);
}


/// Adds pattern-matching-related methods to [GamificationEvent].
extension GamificationEventPatterns on GamificationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _LoadAchievements value)?  loadAchievements,TResult Function( _CheckAndUnlock value)?  checkAndUnlock,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoadAchievements() when loadAchievements != null:
return loadAchievements(_that);case _CheckAndUnlock() when checkAndUnlock != null:
return checkAndUnlock(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _LoadAchievements value)  loadAchievements,required TResult Function( _CheckAndUnlock value)  checkAndUnlock,}){
final _that = this;
switch (_that) {
case _LoadAchievements():
return loadAchievements(_that);case _CheckAndUnlock():
return checkAndUnlock(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _LoadAchievements value)?  loadAchievements,TResult? Function( _CheckAndUnlock value)?  checkAndUnlock,}){
final _that = this;
switch (_that) {
case _LoadAchievements() when loadAchievements != null:
return loadAchievements(_that);case _CheckAndUnlock() when checkAndUnlock != null:
return checkAndUnlock(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loadAchievements,TResult Function( bool hasAccount,  int profileCompletionPercent,  int viewedListingsCount,  int favoritesCount,  int messagesSentCount,  int listingsCreatedCount,  int conversationsStartedCount)?  checkAndUnlock,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoadAchievements() when loadAchievements != null:
return loadAchievements();case _CheckAndUnlock() when checkAndUnlock != null:
return checkAndUnlock(_that.hasAccount,_that.profileCompletionPercent,_that.viewedListingsCount,_that.favoritesCount,_that.messagesSentCount,_that.listingsCreatedCount,_that.conversationsStartedCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loadAchievements,required TResult Function( bool hasAccount,  int profileCompletionPercent,  int viewedListingsCount,  int favoritesCount,  int messagesSentCount,  int listingsCreatedCount,  int conversationsStartedCount)  checkAndUnlock,}) {final _that = this;
switch (_that) {
case _LoadAchievements():
return loadAchievements();case _CheckAndUnlock():
return checkAndUnlock(_that.hasAccount,_that.profileCompletionPercent,_that.viewedListingsCount,_that.favoritesCount,_that.messagesSentCount,_that.listingsCreatedCount,_that.conversationsStartedCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loadAchievements,TResult? Function( bool hasAccount,  int profileCompletionPercent,  int viewedListingsCount,  int favoritesCount,  int messagesSentCount,  int listingsCreatedCount,  int conversationsStartedCount)?  checkAndUnlock,}) {final _that = this;
switch (_that) {
case _LoadAchievements() when loadAchievements != null:
return loadAchievements();case _CheckAndUnlock() when checkAndUnlock != null:
return checkAndUnlock(_that.hasAccount,_that.profileCompletionPercent,_that.viewedListingsCount,_that.favoritesCount,_that.messagesSentCount,_that.listingsCreatedCount,_that.conversationsStartedCount);case _:
  return null;

}
}

}

/// @nodoc


class _LoadAchievements implements GamificationEvent {
  const _LoadAchievements();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadAchievements);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GamificationEvent.loadAchievements()';
}


}




/// @nodoc


class _CheckAndUnlock implements GamificationEvent {
  const _CheckAndUnlock({required this.hasAccount, required this.profileCompletionPercent, required this.viewedListingsCount, required this.favoritesCount, required this.messagesSentCount, required this.listingsCreatedCount, required this.conversationsStartedCount});
  

 final  bool hasAccount;
 final  int profileCompletionPercent;
 final  int viewedListingsCount;
 final  int favoritesCount;
 final  int messagesSentCount;
 final  int listingsCreatedCount;
 final  int conversationsStartedCount;

/// Create a copy of GamificationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckAndUnlockCopyWith<_CheckAndUnlock> get copyWith => __$CheckAndUnlockCopyWithImpl<_CheckAndUnlock>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckAndUnlock&&(identical(other.hasAccount, hasAccount) || other.hasAccount == hasAccount)&&(identical(other.profileCompletionPercent, profileCompletionPercent) || other.profileCompletionPercent == profileCompletionPercent)&&(identical(other.viewedListingsCount, viewedListingsCount) || other.viewedListingsCount == viewedListingsCount)&&(identical(other.favoritesCount, favoritesCount) || other.favoritesCount == favoritesCount)&&(identical(other.messagesSentCount, messagesSentCount) || other.messagesSentCount == messagesSentCount)&&(identical(other.listingsCreatedCount, listingsCreatedCount) || other.listingsCreatedCount == listingsCreatedCount)&&(identical(other.conversationsStartedCount, conversationsStartedCount) || other.conversationsStartedCount == conversationsStartedCount));
}


@override
int get hashCode => Object.hash(runtimeType,hasAccount,profileCompletionPercent,viewedListingsCount,favoritesCount,messagesSentCount,listingsCreatedCount,conversationsStartedCount);

@override
String toString() {
  return 'GamificationEvent.checkAndUnlock(hasAccount: $hasAccount, profileCompletionPercent: $profileCompletionPercent, viewedListingsCount: $viewedListingsCount, favoritesCount: $favoritesCount, messagesSentCount: $messagesSentCount, listingsCreatedCount: $listingsCreatedCount, conversationsStartedCount: $conversationsStartedCount)';
}


}

/// @nodoc
abstract mixin class _$CheckAndUnlockCopyWith<$Res> implements $GamificationEventCopyWith<$Res> {
  factory _$CheckAndUnlockCopyWith(_CheckAndUnlock value, $Res Function(_CheckAndUnlock) _then) = __$CheckAndUnlockCopyWithImpl;
@useResult
$Res call({
 bool hasAccount, int profileCompletionPercent, int viewedListingsCount, int favoritesCount, int messagesSentCount, int listingsCreatedCount, int conversationsStartedCount
});




}
/// @nodoc
class __$CheckAndUnlockCopyWithImpl<$Res>
    implements _$CheckAndUnlockCopyWith<$Res> {
  __$CheckAndUnlockCopyWithImpl(this._self, this._then);

  final _CheckAndUnlock _self;
  final $Res Function(_CheckAndUnlock) _then;

/// Create a copy of GamificationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? hasAccount = null,Object? profileCompletionPercent = null,Object? viewedListingsCount = null,Object? favoritesCount = null,Object? messagesSentCount = null,Object? listingsCreatedCount = null,Object? conversationsStartedCount = null,}) {
  return _then(_CheckAndUnlock(
hasAccount: null == hasAccount ? _self.hasAccount : hasAccount // ignore: cast_nullable_to_non_nullable
as bool,profileCompletionPercent: null == profileCompletionPercent ? _self.profileCompletionPercent : profileCompletionPercent // ignore: cast_nullable_to_non_nullable
as int,viewedListingsCount: null == viewedListingsCount ? _self.viewedListingsCount : viewedListingsCount // ignore: cast_nullable_to_non_nullable
as int,favoritesCount: null == favoritesCount ? _self.favoritesCount : favoritesCount // ignore: cast_nullable_to_non_nullable
as int,messagesSentCount: null == messagesSentCount ? _self.messagesSentCount : messagesSentCount // ignore: cast_nullable_to_non_nullable
as int,listingsCreatedCount: null == listingsCreatedCount ? _self.listingsCreatedCount : listingsCreatedCount // ignore: cast_nullable_to_non_nullable
as int,conversationsStartedCount: null == conversationsStartedCount ? _self.conversationsStartedCount : conversationsStartedCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GamificationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GamificationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GamificationState()';
}


}

/// @nodoc
class $GamificationStateCopyWith<$Res>  {
$GamificationStateCopyWith(GamificationState _, $Res Function(GamificationState) __);
}


/// Adds pattern-matching-related methods to [GamificationState].
extension GamificationStatePatterns on GamificationState {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<Achievement> achievements,  Set<String> unlockedIds)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.achievements,_that.unlockedIds);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<Achievement> achievements,  Set<String> unlockedIds)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.achievements,_that.unlockedIds);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<Achievement> achievements,  Set<String> unlockedIds)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.achievements,_that.unlockedIds);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements GamificationState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GamificationState.initial()';
}


}




/// @nodoc


class _Loading implements GamificationState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GamificationState.loading()';
}


}




/// @nodoc


class _Loaded implements GamificationState {
  const _Loaded({required final  List<Achievement> achievements, required final  Set<String> unlockedIds}): _achievements = achievements,_unlockedIds = unlockedIds;
  

 final  List<Achievement> _achievements;
 List<Achievement> get achievements {
  if (_achievements is EqualUnmodifiableListView) return _achievements;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_achievements);
}

 final  Set<String> _unlockedIds;
 Set<String> get unlockedIds {
  if (_unlockedIds is EqualUnmodifiableSetView) return _unlockedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_unlockedIds);
}


/// Create a copy of GamificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._achievements, _achievements)&&const DeepCollectionEquality().equals(other._unlockedIds, _unlockedIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_achievements),const DeepCollectionEquality().hash(_unlockedIds));

@override
String toString() {
  return 'GamificationState.loaded(achievements: $achievements, unlockedIds: $unlockedIds)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $GamificationStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<Achievement> achievements, Set<String> unlockedIds
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of GamificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? achievements = null,Object? unlockedIds = null,}) {
  return _then(_Loaded(
achievements: null == achievements ? _self._achievements : achievements // ignore: cast_nullable_to_non_nullable
as List<Achievement>,unlockedIds: null == unlockedIds ? _self._unlockedIds : unlockedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

/// @nodoc


class _Error implements GamificationState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of GamificationState
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
  return 'GamificationState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $GamificationStateCopyWith<$Res> {
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

/// Create a copy of GamificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
