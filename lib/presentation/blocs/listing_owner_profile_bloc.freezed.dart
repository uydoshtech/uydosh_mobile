// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_owner_profile_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ListingOwnerProfileEvent {
  int get userId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int userId) fetchProfile,
    required TResult Function(int userId) toggleFollow,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int userId)? fetchProfile,
    TResult? Function(int userId)? toggleFollow,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int userId)? fetchProfile,
    TResult Function(int userId)? toggleFollow,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchProfile value) fetchProfile,
    required TResult Function(_ToggleFollow value) toggleFollow,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchProfile value)? fetchProfile,
    TResult? Function(_ToggleFollow value)? toggleFollow,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchProfile value)? fetchProfile,
    TResult Function(_ToggleFollow value)? toggleFollow,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ListingOwnerProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingOwnerProfileEventCopyWith<ListingOwnerProfileEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingOwnerProfileEventCopyWith<$Res> {
  factory $ListingOwnerProfileEventCopyWith(ListingOwnerProfileEvent value,
          $Res Function(ListingOwnerProfileEvent) then) =
      _$ListingOwnerProfileEventCopyWithImpl<$Res, ListingOwnerProfileEvent>;
  @useResult
  $Res call({int userId});
}

/// @nodoc
class _$ListingOwnerProfileEventCopyWithImpl<$Res,
        $Val extends ListingOwnerProfileEvent>
    implements $ListingOwnerProfileEventCopyWith<$Res> {
  _$ListingOwnerProfileEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingOwnerProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FetchProfileImplCopyWith<$Res>
    implements $ListingOwnerProfileEventCopyWith<$Res> {
  factory _$$FetchProfileImplCopyWith(
          _$FetchProfileImpl value, $Res Function(_$FetchProfileImpl) then) =
      __$$FetchProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId});
}

/// @nodoc
class __$$FetchProfileImplCopyWithImpl<$Res>
    extends _$ListingOwnerProfileEventCopyWithImpl<$Res, _$FetchProfileImpl>
    implements _$$FetchProfileImplCopyWith<$Res> {
  __$$FetchProfileImplCopyWithImpl(
      _$FetchProfileImpl _value, $Res Function(_$FetchProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingOwnerProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
  }) {
    return _then(_$FetchProfileImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$FetchProfileImpl implements _FetchProfile {
  const _$FetchProfileImpl({required this.userId});

  @override
  final int userId;

  @override
  String toString() {
    return 'ListingOwnerProfileEvent.fetchProfile(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FetchProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of ListingOwnerProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FetchProfileImplCopyWith<_$FetchProfileImpl> get copyWith =>
      __$$FetchProfileImplCopyWithImpl<_$FetchProfileImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int userId) fetchProfile,
    required TResult Function(int userId) toggleFollow,
  }) {
    return fetchProfile(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int userId)? fetchProfile,
    TResult? Function(int userId)? toggleFollow,
  }) {
    return fetchProfile?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int userId)? fetchProfile,
    TResult Function(int userId)? toggleFollow,
    required TResult orElse(),
  }) {
    if (fetchProfile != null) {
      return fetchProfile(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchProfile value) fetchProfile,
    required TResult Function(_ToggleFollow value) toggleFollow,
  }) {
    return fetchProfile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchProfile value)? fetchProfile,
    TResult? Function(_ToggleFollow value)? toggleFollow,
  }) {
    return fetchProfile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchProfile value)? fetchProfile,
    TResult Function(_ToggleFollow value)? toggleFollow,
    required TResult orElse(),
  }) {
    if (fetchProfile != null) {
      return fetchProfile(this);
    }
    return orElse();
  }
}

abstract class _FetchProfile implements ListingOwnerProfileEvent {
  const factory _FetchProfile({required final int userId}) = _$FetchProfileImpl;

  @override
  int get userId;

  /// Create a copy of ListingOwnerProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FetchProfileImplCopyWith<_$FetchProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ToggleFollowImplCopyWith<$Res>
    implements $ListingOwnerProfileEventCopyWith<$Res> {
  factory _$$ToggleFollowImplCopyWith(
          _$ToggleFollowImpl value, $Res Function(_$ToggleFollowImpl) then) =
      __$$ToggleFollowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId});
}

/// @nodoc
class __$$ToggleFollowImplCopyWithImpl<$Res>
    extends _$ListingOwnerProfileEventCopyWithImpl<$Res, _$ToggleFollowImpl>
    implements _$$ToggleFollowImplCopyWith<$Res> {
  __$$ToggleFollowImplCopyWithImpl(
      _$ToggleFollowImpl _value, $Res Function(_$ToggleFollowImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingOwnerProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
  }) {
    return _then(_$ToggleFollowImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ToggleFollowImpl implements _ToggleFollow {
  const _$ToggleFollowImpl({required this.userId});

  @override
  final int userId;

  @override
  String toString() {
    return 'ListingOwnerProfileEvent.toggleFollow(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ToggleFollowImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of ListingOwnerProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ToggleFollowImplCopyWith<_$ToggleFollowImpl> get copyWith =>
      __$$ToggleFollowImplCopyWithImpl<_$ToggleFollowImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int userId) fetchProfile,
    required TResult Function(int userId) toggleFollow,
  }) {
    return toggleFollow(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int userId)? fetchProfile,
    TResult? Function(int userId)? toggleFollow,
  }) {
    return toggleFollow?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int userId)? fetchProfile,
    TResult Function(int userId)? toggleFollow,
    required TResult orElse(),
  }) {
    if (toggleFollow != null) {
      return toggleFollow(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_FetchProfile value) fetchProfile,
    required TResult Function(_ToggleFollow value) toggleFollow,
  }) {
    return toggleFollow(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_FetchProfile value)? fetchProfile,
    TResult? Function(_ToggleFollow value)? toggleFollow,
  }) {
    return toggleFollow?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_FetchProfile value)? fetchProfile,
    TResult Function(_ToggleFollow value)? toggleFollow,
    required TResult orElse(),
  }) {
    if (toggleFollow != null) {
      return toggleFollow(this);
    }
    return orElse();
  }
}

abstract class _ToggleFollow implements ListingOwnerProfileEvent {
  const factory _ToggleFollow({required final int userId}) = _$ToggleFollowImpl;

  @override
  int get userId;

  /// Create a copy of ListingOwnerProfileEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ToggleFollowImplCopyWith<_$ToggleFollowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ListingOwnerProfileState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingOwnerProfileStateCopyWith<$Res> {
  factory $ListingOwnerProfileStateCopyWith(ListingOwnerProfileState value,
          $Res Function(ListingOwnerProfileState) then) =
      _$ListingOwnerProfileStateCopyWithImpl<$Res, ListingOwnerProfileState>;
}

/// @nodoc
class _$ListingOwnerProfileStateCopyWithImpl<$Res,
        $Val extends ListingOwnerProfileState>
    implements $ListingOwnerProfileStateCopyWith<$Res> {
  _$ListingOwnerProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ListingOwnerProfileStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ListingOwnerProfileState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ListingOwnerProfileState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$ListingOwnerProfileStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'ListingOwnerProfileState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements ListingOwnerProfileState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$LoadedImplCopyWith<$Res> {
  factory _$$LoadedImplCopyWith(
          _$LoadedImpl value, $Res Function(_$LoadedImpl) then) =
      __$$LoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {UserProfile profile,
      bool isFollowing,
      bool isFollowLoading,
      List<CommonFriend> commonFriends,
      int commonFriendsTotal,
      bool canFollow});

  $UserProfileCopyWith<$Res> get profile;
}

/// @nodoc
class __$$LoadedImplCopyWithImpl<$Res>
    extends _$ListingOwnerProfileStateCopyWithImpl<$Res, _$LoadedImpl>
    implements _$$LoadedImplCopyWith<$Res> {
  __$$LoadedImplCopyWithImpl(
      _$LoadedImpl _value, $Res Function(_$LoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? isFollowing = null,
    Object? isFollowLoading = null,
    Object? commonFriends = null,
    Object? commonFriendsTotal = null,
    Object? canFollow = null,
  }) {
    return _then(_$LoadedImpl(
      profile: null == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as UserProfile,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowLoading: null == isFollowLoading
          ? _value.isFollowLoading
          : isFollowLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      commonFriends: null == commonFriends
          ? _value._commonFriends
          : commonFriends // ignore: cast_nullable_to_non_nullable
              as List<CommonFriend>,
      commonFriendsTotal: null == commonFriendsTotal
          ? _value.commonFriendsTotal
          : commonFriendsTotal // ignore: cast_nullable_to_non_nullable
              as int,
      canFollow: null == canFollow
          ? _value.canFollow
          : canFollow // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res> get profile {
    return $UserProfileCopyWith<$Res>(_value.profile, (value) {
      return _then(_value.copyWith(profile: value));
    });
  }
}

/// @nodoc

class _$LoadedImpl implements _Loaded {
  const _$LoadedImpl(
      {required this.profile,
      this.isFollowing = false,
      this.isFollowLoading = false,
      final List<CommonFriend> commonFriends = const <CommonFriend>[],
      this.commonFriendsTotal = 0,
      this.canFollow = false})
      : _commonFriends = commonFriends;

  @override
  final UserProfile profile;
  @override
  @JsonKey()
  final bool isFollowing;
  @override
  @JsonKey()
  final bool isFollowLoading;
  final List<CommonFriend> _commonFriends;
  @override
  @JsonKey()
  List<CommonFriend> get commonFriends {
    if (_commonFriends is EqualUnmodifiableListView) return _commonFriends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_commonFriends);
  }

  @override
  @JsonKey()
  final int commonFriendsTotal;
  @override
  @JsonKey()
  final bool canFollow;

  @override
  String toString() {
    return 'ListingOwnerProfileState.loaded(profile: $profile, isFollowing: $isFollowing, isFollowLoading: $isFollowLoading, commonFriends: $commonFriends, commonFriendsTotal: $commonFriendsTotal, canFollow: $canFollow)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadedImpl &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isFollowLoading, isFollowLoading) ||
                other.isFollowLoading == isFollowLoading) &&
            const DeepCollectionEquality()
                .equals(other._commonFriends, _commonFriends) &&
            (identical(other.commonFriendsTotal, commonFriendsTotal) ||
                other.commonFriendsTotal == commonFriendsTotal) &&
            (identical(other.canFollow, canFollow) ||
                other.canFollow == canFollow));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      profile,
      isFollowing,
      isFollowLoading,
      const DeepCollectionEquality().hash(_commonFriends),
      commonFriendsTotal,
      canFollow);

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      __$$LoadedImplCopyWithImpl<_$LoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(profile, isFollowing, isFollowLoading, commonFriends,
        commonFriendsTotal, canFollow);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(profile, isFollowing, isFollowLoading, commonFriends,
        commonFriendsTotal, canFollow);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(profile, isFollowing, isFollowLoading, commonFriends,
          commonFriendsTotal, canFollow);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _Loaded implements ListingOwnerProfileState {
  const factory _Loaded(
      {required final UserProfile profile,
      final bool isFollowing,
      final bool isFollowLoading,
      final List<CommonFriend> commonFriends,
      final int commonFriendsTotal,
      final bool canFollow}) = _$LoadedImpl;

  UserProfile get profile;
  bool get isFollowing;
  bool get isFollowLoading;
  List<CommonFriend> get commonFriends;
  int get commonFriendsTotal;
  bool get canFollow;

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadedImplCopyWith<_$LoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$ListingOwnerProfileStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'ListingOwnerProfileState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            UserProfile profile,
            bool isFollowing,
            bool isFollowLoading,
            List<CommonFriend> commonFriends,
            int commonFriendsTotal,
            bool canFollow)?
        loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements ListingOwnerProfileState {
  const factory _Error({required final String message}) = _$ErrorImpl;

  String get message;

  /// Create a copy of ListingOwnerProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
