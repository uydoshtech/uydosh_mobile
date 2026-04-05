// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listings_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ListingsEvent {
  int get limit => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int page, int limit, bool isActive, bool isRefresh)
        fetchListings,
    required TResult Function(int limit, bool isActive) loadMore,
    required TResult Function(int subwayStationId, int page, int limit,
            bool isActive, bool isRefresh)
        fetchListingsBySubwayStation,
    required TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)
        fetchListingsByLocation,
    required TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)
        searchListings,
    required TResult Function(int page, int limit, bool isRefresh)
        fetchUserListings,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult? Function(int limit, bool isActive)? loadMore,
    TResult? Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult? Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult? Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult? Function(int page, int limit, bool isRefresh)? fetchUserListings,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult Function(int limit, bool isActive)? loadMore,
    TResult Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult Function(int page, int limit, bool isRefresh)? fetchUserListings,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_$FetchListingsImpl value) fetchListings,
    required TResult Function(_$LoadMoreImpl value) loadMore,
    required TResult Function(_$FetchListingsBySubwayStationImpl value)
        fetchListingsBySubwayStation,
    required TResult Function(_$FetchListingsByLocationImpl value)
        fetchListingsByLocation,
    required TResult Function(_$SearchListingsImpl value) searchListings,
    required TResult Function(_$FetchUserListingsImpl value) fetchUserListings,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_$FetchListingsImpl value)? fetchListings,
    TResult? Function(_$LoadMoreImpl value)? loadMore,
    TResult? Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult? Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult? Function(_$SearchListingsImpl value)? searchListings,
    TResult? Function(_$FetchUserListingsImpl value)? fetchUserListings,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_$FetchListingsImpl value)? fetchListings,
    TResult Function(_$LoadMoreImpl value)? loadMore,
    TResult Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult Function(_$SearchListingsImpl value)? searchListings,
    TResult Function(_$FetchUserListingsImpl value)? fetchUserListings,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingsEventCopyWith<ListingsEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingsEventCopyWith<$Res> {
  factory $ListingsEventCopyWith(
          ListingsEvent value, $Res Function(ListingsEvent) then) =
      _$ListingsEventCopyWithImpl<$Res, ListingsEvent>;
  @useResult
  $Res call({int limit});
}

/// @nodoc
class _$ListingsEventCopyWithImpl<$Res, $Val extends ListingsEvent>
    implements $ListingsEventCopyWith<$Res> {
  _$ListingsEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = null,
  }) {
    return _then(_value.copyWith(
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$$FetchListingsImplImplCopyWith<$Res>
    implements $ListingsEventCopyWith<$Res> {
  factory _$$$FetchListingsImplImplCopyWith(_$$FetchListingsImplImpl value,
          $Res Function(_$$FetchListingsImplImpl) then) =
      __$$$FetchListingsImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int page, int limit, bool isActive, bool isRefresh});
}

/// @nodoc
class __$$$FetchListingsImplImplCopyWithImpl<$Res>
    extends _$ListingsEventCopyWithImpl<$Res, _$$FetchListingsImplImpl>
    implements _$$$FetchListingsImplImplCopyWith<$Res> {
  __$$$FetchListingsImplImplCopyWithImpl(_$$FetchListingsImplImpl _value,
      $Res Function(_$$FetchListingsImplImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? limit = null,
    Object? isActive = null,
    Object? isRefresh = null,
  }) {
    return _then(_$$FetchListingsImplImpl(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefresh: null == isRefresh
          ? _value.isRefresh
          : isRefresh // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$$FetchListingsImplImpl implements _$FetchListingsImpl {
  const _$$FetchListingsImplImpl(
      {this.page = 1,
      this.limit = 10,
      this.isActive = true,
      this.isRefresh = true});

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isRefresh;

  @override
  String toString() {
    return 'ListingsEvent.fetchListings(page: $page, limit: $limit, isActive: $isActive, isRefresh: $isRefresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$FetchListingsImplImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isRefresh, isRefresh) ||
                other.isRefresh == isRefresh));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, page, limit, isActive, isRefresh);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$$FetchListingsImplImplCopyWith<_$$FetchListingsImplImpl> get copyWith =>
      __$$$FetchListingsImplImplCopyWithImpl<_$$FetchListingsImplImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int page, int limit, bool isActive, bool isRefresh)
        fetchListings,
    required TResult Function(int limit, bool isActive) loadMore,
    required TResult Function(int subwayStationId, int page, int limit,
            bool isActive, bool isRefresh)
        fetchListingsBySubwayStation,
    required TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)
        fetchListingsByLocation,
    required TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)
        searchListings,
    required TResult Function(int page, int limit, bool isRefresh)
        fetchUserListings,
  }) {
    return fetchListings(page, limit, isActive, isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult? Function(int limit, bool isActive)? loadMore,
    TResult? Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult? Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult? Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult? Function(int page, int limit, bool isRefresh)? fetchUserListings,
  }) {
    return fetchListings?.call(page, limit, isActive, isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult Function(int limit, bool isActive)? loadMore,
    TResult Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult Function(int page, int limit, bool isRefresh)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (fetchListings != null) {
      return fetchListings(page, limit, isActive, isRefresh);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_$FetchListingsImpl value) fetchListings,
    required TResult Function(_$LoadMoreImpl value) loadMore,
    required TResult Function(_$FetchListingsBySubwayStationImpl value)
        fetchListingsBySubwayStation,
    required TResult Function(_$FetchListingsByLocationImpl value)
        fetchListingsByLocation,
    required TResult Function(_$SearchListingsImpl value) searchListings,
    required TResult Function(_$FetchUserListingsImpl value) fetchUserListings,
  }) {
    return fetchListings(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_$FetchListingsImpl value)? fetchListings,
    TResult? Function(_$LoadMoreImpl value)? loadMore,
    TResult? Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult? Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult? Function(_$SearchListingsImpl value)? searchListings,
    TResult? Function(_$FetchUserListingsImpl value)? fetchUserListings,
  }) {
    return fetchListings?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_$FetchListingsImpl value)? fetchListings,
    TResult Function(_$LoadMoreImpl value)? loadMore,
    TResult Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult Function(_$SearchListingsImpl value)? searchListings,
    TResult Function(_$FetchUserListingsImpl value)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (fetchListings != null) {
      return fetchListings(this);
    }
    return orElse();
  }
}

abstract class _$FetchListingsImpl implements ListingsEvent {
  const factory _$FetchListingsImpl(
      {final int page,
      final int limit,
      final bool isActive,
      final bool isRefresh}) = _$$FetchListingsImplImpl;

  int get page;
  @override
  int get limit;
  bool get isActive;
  bool get isRefresh;

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$$FetchListingsImplImplCopyWith<_$$FetchListingsImplImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$$LoadMoreImplImplCopyWith<$Res>
    implements $ListingsEventCopyWith<$Res> {
  factory _$$$LoadMoreImplImplCopyWith(
          _$$LoadMoreImplImpl value, $Res Function(_$$LoadMoreImplImpl) then) =
      __$$$LoadMoreImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int limit, bool isActive});
}

/// @nodoc
class __$$$LoadMoreImplImplCopyWithImpl<$Res>
    extends _$ListingsEventCopyWithImpl<$Res, _$$LoadMoreImplImpl>
    implements _$$$LoadMoreImplImplCopyWith<$Res> {
  __$$$LoadMoreImplImplCopyWithImpl(
      _$$LoadMoreImplImpl _value, $Res Function(_$$LoadMoreImplImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? limit = null,
    Object? isActive = null,
  }) {
    return _then(_$$LoadMoreImplImpl(
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$$LoadMoreImplImpl implements _$LoadMoreImpl {
  const _$$LoadMoreImplImpl({this.limit = 10, this.isActive = true});

  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'ListingsEvent.loadMore(limit: $limit, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$LoadMoreImplImpl &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @override
  int get hashCode => Object.hash(runtimeType, limit, isActive);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$$LoadMoreImplImplCopyWith<_$$LoadMoreImplImpl> get copyWith =>
      __$$$LoadMoreImplImplCopyWithImpl<_$$LoadMoreImplImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int page, int limit, bool isActive, bool isRefresh)
        fetchListings,
    required TResult Function(int limit, bool isActive) loadMore,
    required TResult Function(int subwayStationId, int page, int limit,
            bool isActive, bool isRefresh)
        fetchListingsBySubwayStation,
    required TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)
        fetchListingsByLocation,
    required TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)
        searchListings,
    required TResult Function(int page, int limit, bool isRefresh)
        fetchUserListings,
  }) {
    return loadMore(limit, isActive);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult? Function(int limit, bool isActive)? loadMore,
    TResult? Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult? Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult? Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult? Function(int page, int limit, bool isRefresh)? fetchUserListings,
  }) {
    return loadMore?.call(limit, isActive);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult Function(int limit, bool isActive)? loadMore,
    TResult Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult Function(int page, int limit, bool isRefresh)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (loadMore != null) {
      return loadMore(limit, isActive);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_$FetchListingsImpl value) fetchListings,
    required TResult Function(_$LoadMoreImpl value) loadMore,
    required TResult Function(_$FetchListingsBySubwayStationImpl value)
        fetchListingsBySubwayStation,
    required TResult Function(_$FetchListingsByLocationImpl value)
        fetchListingsByLocation,
    required TResult Function(_$SearchListingsImpl value) searchListings,
    required TResult Function(_$FetchUserListingsImpl value) fetchUserListings,
  }) {
    return loadMore(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_$FetchListingsImpl value)? fetchListings,
    TResult? Function(_$LoadMoreImpl value)? loadMore,
    TResult? Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult? Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult? Function(_$SearchListingsImpl value)? searchListings,
    TResult? Function(_$FetchUserListingsImpl value)? fetchUserListings,
  }) {
    return loadMore?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_$FetchListingsImpl value)? fetchListings,
    TResult Function(_$LoadMoreImpl value)? loadMore,
    TResult Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult Function(_$SearchListingsImpl value)? searchListings,
    TResult Function(_$FetchUserListingsImpl value)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (loadMore != null) {
      return loadMore(this);
    }
    return orElse();
  }
}

abstract class _$LoadMoreImpl implements ListingsEvent {
  const factory _$LoadMoreImpl({final int limit, final bool isActive}) =
      _$$LoadMoreImplImpl;

  @override
  int get limit;
  bool get isActive;

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$$LoadMoreImplImplCopyWith<_$$LoadMoreImplImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$$FetchListingsBySubwayStationImplImplCopyWith<$Res>
    implements $ListingsEventCopyWith<$Res> {
  factory _$$$FetchListingsBySubwayStationImplImplCopyWith(
          _$$FetchListingsBySubwayStationImplImpl value,
          $Res Function(_$$FetchListingsBySubwayStationImplImpl) then) =
      __$$$FetchListingsBySubwayStationImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int subwayStationId,
      int page,
      int limit,
      bool isActive,
      bool isRefresh});
}

/// @nodoc
class __$$$FetchListingsBySubwayStationImplImplCopyWithImpl<$Res>
    extends _$ListingsEventCopyWithImpl<$Res,
        _$$FetchListingsBySubwayStationImplImpl>
    implements _$$$FetchListingsBySubwayStationImplImplCopyWith<$Res> {
  __$$$FetchListingsBySubwayStationImplImplCopyWithImpl(
      _$$FetchListingsBySubwayStationImplImpl _value,
      $Res Function(_$$FetchListingsBySubwayStationImplImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subwayStationId = null,
    Object? page = null,
    Object? limit = null,
    Object? isActive = null,
    Object? isRefresh = null,
  }) {
    return _then(_$$FetchListingsBySubwayStationImplImpl(
      subwayStationId: null == subwayStationId
          ? _value.subwayStationId
          : subwayStationId // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefresh: null == isRefresh
          ? _value.isRefresh
          : isRefresh // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$$FetchListingsBySubwayStationImplImpl
    implements _$FetchListingsBySubwayStationImpl {
  const _$$FetchListingsBySubwayStationImplImpl(
      {required this.subwayStationId,
      this.page = 1,
      this.limit = 10,
      this.isActive = true,
      this.isRefresh = true});

  @override
  final int subwayStationId;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isRefresh;

  @override
  String toString() {
    return 'ListingsEvent.fetchListingsBySubwayStation(subwayStationId: $subwayStationId, page: $page, limit: $limit, isActive: $isActive, isRefresh: $isRefresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$FetchListingsBySubwayStationImplImpl &&
            (identical(other.subwayStationId, subwayStationId) ||
                other.subwayStationId == subwayStationId) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isRefresh, isRefresh) ||
                other.isRefresh == isRefresh));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, subwayStationId, page, limit, isActive, isRefresh);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$$FetchListingsBySubwayStationImplImplCopyWith<
          _$$FetchListingsBySubwayStationImplImpl>
      get copyWith => __$$$FetchListingsBySubwayStationImplImplCopyWithImpl<
          _$$FetchListingsBySubwayStationImplImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int page, int limit, bool isActive, bool isRefresh)
        fetchListings,
    required TResult Function(int limit, bool isActive) loadMore,
    required TResult Function(int subwayStationId, int page, int limit,
            bool isActive, bool isRefresh)
        fetchListingsBySubwayStation,
    required TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)
        fetchListingsByLocation,
    required TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)
        searchListings,
    required TResult Function(int page, int limit, bool isRefresh)
        fetchUserListings,
  }) {
    return fetchListingsBySubwayStation(
        subwayStationId, page, limit, isActive, isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult? Function(int limit, bool isActive)? loadMore,
    TResult? Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult? Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult? Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult? Function(int page, int limit, bool isRefresh)? fetchUserListings,
  }) {
    return fetchListingsBySubwayStation?.call(
        subwayStationId, page, limit, isActive, isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult Function(int limit, bool isActive)? loadMore,
    TResult Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult Function(int page, int limit, bool isRefresh)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (fetchListingsBySubwayStation != null) {
      return fetchListingsBySubwayStation(
          subwayStationId, page, limit, isActive, isRefresh);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_$FetchListingsImpl value) fetchListings,
    required TResult Function(_$LoadMoreImpl value) loadMore,
    required TResult Function(_$FetchListingsBySubwayStationImpl value)
        fetchListingsBySubwayStation,
    required TResult Function(_$FetchListingsByLocationImpl value)
        fetchListingsByLocation,
    required TResult Function(_$SearchListingsImpl value) searchListings,
    required TResult Function(_$FetchUserListingsImpl value) fetchUserListings,
  }) {
    return fetchListingsBySubwayStation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_$FetchListingsImpl value)? fetchListings,
    TResult? Function(_$LoadMoreImpl value)? loadMore,
    TResult? Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult? Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult? Function(_$SearchListingsImpl value)? searchListings,
    TResult? Function(_$FetchUserListingsImpl value)? fetchUserListings,
  }) {
    return fetchListingsBySubwayStation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_$FetchListingsImpl value)? fetchListings,
    TResult Function(_$LoadMoreImpl value)? loadMore,
    TResult Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult Function(_$SearchListingsImpl value)? searchListings,
    TResult Function(_$FetchUserListingsImpl value)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (fetchListingsBySubwayStation != null) {
      return fetchListingsBySubwayStation(this);
    }
    return orElse();
  }
}

abstract class _$FetchListingsBySubwayStationImpl implements ListingsEvent {
  const factory _$FetchListingsBySubwayStationImpl(
      {required final int subwayStationId,
      final int page,
      final int limit,
      final bool isActive,
      final bool isRefresh}) = _$$FetchListingsBySubwayStationImplImpl;

  int get subwayStationId;
  int get page;
  @override
  int get limit;
  bool get isActive;
  bool get isRefresh;

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$$FetchListingsBySubwayStationImplImplCopyWith<
          _$$FetchListingsBySubwayStationImplImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$$FetchListingsByLocationImplImplCopyWith<$Res>
    implements $ListingsEventCopyWith<$Res> {
  factory _$$$FetchListingsByLocationImplImplCopyWith(
          _$$FetchListingsByLocationImplImpl value,
          $Res Function(_$$FetchListingsByLocationImplImpl) then) =
      __$$$FetchListingsByLocationImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int locationId, int page, int limit, bool isActive, bool isRefresh});
}

/// @nodoc
class __$$$FetchListingsByLocationImplImplCopyWithImpl<$Res>
    extends _$ListingsEventCopyWithImpl<$Res,
        _$$FetchListingsByLocationImplImpl>
    implements _$$$FetchListingsByLocationImplImplCopyWith<$Res> {
  __$$$FetchListingsByLocationImplImplCopyWithImpl(
      _$$FetchListingsByLocationImplImpl _value,
      $Res Function(_$$FetchListingsByLocationImplImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locationId = null,
    Object? page = null,
    Object? limit = null,
    Object? isActive = null,
    Object? isRefresh = null,
  }) {
    return _then(_$$FetchListingsByLocationImplImpl(
      locationId: null == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefresh: null == isRefresh
          ? _value.isRefresh
          : isRefresh // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$$FetchListingsByLocationImplImpl
    implements _$FetchListingsByLocationImpl {
  const _$$FetchListingsByLocationImplImpl(
      {required this.locationId,
      this.page = 1,
      this.limit = 10,
      this.isActive = true,
      this.isRefresh = true});

  @override
  final int locationId;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isRefresh;

  @override
  String toString() {
    return 'ListingsEvent.fetchListingsByLocation(locationId: $locationId, page: $page, limit: $limit, isActive: $isActive, isRefresh: $isRefresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$FetchListingsByLocationImplImpl &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isRefresh, isRefresh) ||
                other.isRefresh == isRefresh));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, locationId, page, limit, isActive, isRefresh);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$$FetchListingsByLocationImplImplCopyWith<
          _$$FetchListingsByLocationImplImpl>
      get copyWith => __$$$FetchListingsByLocationImplImplCopyWithImpl<
          _$$FetchListingsByLocationImplImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int page, int limit, bool isActive, bool isRefresh)
        fetchListings,
    required TResult Function(int limit, bool isActive) loadMore,
    required TResult Function(int subwayStationId, int page, int limit,
            bool isActive, bool isRefresh)
        fetchListingsBySubwayStation,
    required TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)
        fetchListingsByLocation,
    required TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)
        searchListings,
    required TResult Function(int page, int limit, bool isRefresh)
        fetchUserListings,
  }) {
    return fetchListingsByLocation(
        locationId, page, limit, isActive, isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult? Function(int limit, bool isActive)? loadMore,
    TResult? Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult? Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult? Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult? Function(int page, int limit, bool isRefresh)? fetchUserListings,
  }) {
    return fetchListingsByLocation?.call(
        locationId, page, limit, isActive, isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult Function(int limit, bool isActive)? loadMore,
    TResult Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult Function(int page, int limit, bool isRefresh)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (fetchListingsByLocation != null) {
      return fetchListingsByLocation(
          locationId, page, limit, isActive, isRefresh);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_$FetchListingsImpl value) fetchListings,
    required TResult Function(_$LoadMoreImpl value) loadMore,
    required TResult Function(_$FetchListingsBySubwayStationImpl value)
        fetchListingsBySubwayStation,
    required TResult Function(_$FetchListingsByLocationImpl value)
        fetchListingsByLocation,
    required TResult Function(_$SearchListingsImpl value) searchListings,
    required TResult Function(_$FetchUserListingsImpl value) fetchUserListings,
  }) {
    return fetchListingsByLocation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_$FetchListingsImpl value)? fetchListings,
    TResult? Function(_$LoadMoreImpl value)? loadMore,
    TResult? Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult? Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult? Function(_$SearchListingsImpl value)? searchListings,
    TResult? Function(_$FetchUserListingsImpl value)? fetchUserListings,
  }) {
    return fetchListingsByLocation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_$FetchListingsImpl value)? fetchListings,
    TResult Function(_$LoadMoreImpl value)? loadMore,
    TResult Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult Function(_$SearchListingsImpl value)? searchListings,
    TResult Function(_$FetchUserListingsImpl value)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (fetchListingsByLocation != null) {
      return fetchListingsByLocation(this);
    }
    return orElse();
  }
}

abstract class _$FetchListingsByLocationImpl implements ListingsEvent {
  const factory _$FetchListingsByLocationImpl(
      {required final int locationId,
      final int page,
      final int limit,
      final bool isActive,
      final bool isRefresh}) = _$$FetchListingsByLocationImplImpl;

  int get locationId;
  int get page;
  @override
  int get limit;
  bool get isActive;
  bool get isRefresh;

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$$FetchListingsByLocationImplImplCopyWith<
          _$$FetchListingsByLocationImplImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$$SearchListingsImplImplCopyWith<$Res>
    implements $ListingsEventCopyWith<$Res> {
  factory _$$$SearchListingsImplImplCopyWith(_$$SearchListingsImplImpl value,
          $Res Function(_$$SearchListingsImplImpl) then) =
      __$$$SearchListingsImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? listingTypeId,
      int? locationId,
      int? subwayStationId,
      int? subwayLineId,
      int? gender,
      double? minPrice,
      double? maxPrice,
      bool? privateRoom,
      bool? withPhoto,
      int page,
      int limit,
      bool isActive,
      bool isRefresh});
}

/// @nodoc
class __$$$SearchListingsImplImplCopyWithImpl<$Res>
    extends _$ListingsEventCopyWithImpl<$Res, _$$SearchListingsImplImpl>
    implements _$$$SearchListingsImplImplCopyWith<$Res> {
  __$$$SearchListingsImplImplCopyWithImpl(_$$SearchListingsImplImpl _value,
      $Res Function(_$$SearchListingsImplImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listingTypeId = freezed,
    Object? locationId = freezed,
    Object? subwayStationId = freezed,
    Object? subwayLineId = freezed,
    Object? gender = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? privateRoom = freezed,
    Object? withPhoto = freezed,
    Object? page = null,
    Object? limit = null,
    Object? isActive = null,
    Object? isRefresh = null,
  }) {
    return _then(_$$SearchListingsImplImpl(
      listingTypeId: freezed == listingTypeId
          ? _value.listingTypeId
          : listingTypeId // ignore: cast_nullable_to_non_nullable
              as int?,
      locationId: freezed == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayStationId: freezed == subwayStationId
          ? _value.subwayStationId
          : subwayStationId // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayLineId: freezed == subwayLineId
          ? _value.subwayLineId
          : subwayLineId // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      privateRoom: freezed == privateRoom
          ? _value.privateRoom
          : privateRoom // ignore: cast_nullable_to_non_nullable
              as bool?,
      withPhoto: freezed == withPhoto
          ? _value.withPhoto
          : withPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      isRefresh: null == isRefresh
          ? _value.isRefresh
          : isRefresh // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$$SearchListingsImplImpl implements _$SearchListingsImpl {
  const _$$SearchListingsImplImpl(
      {this.listingTypeId,
      this.locationId,
      this.subwayStationId,
      this.subwayLineId,
      this.gender,
      this.minPrice,
      this.maxPrice,
      this.privateRoom,
      this.withPhoto,
      this.page = 1,
      this.limit = 10,
      this.isActive = true,
      this.isRefresh = true});

  @override
  final int? listingTypeId;
  @override
  final int? locationId;
  @override
  final int? subwayStationId;
  @override
  final int? subwayLineId;
  @override
  final int? gender;
  @override
  final double? minPrice;
  @override
  final double? maxPrice;
  @override
  final bool? privateRoom;
  @override
  final bool? withPhoto;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool isRefresh;

  @override
  String toString() {
    return 'ListingsEvent.searchListings(listingTypeId: $listingTypeId, locationId: $locationId, subwayStationId: $subwayStationId, subwayLineId: $subwayLineId, gender: $gender, minPrice: $minPrice, maxPrice: $maxPrice, privateRoom: $privateRoom, withPhoto: $withPhoto, page: $page, limit: $limit, isActive: $isActive, isRefresh: $isRefresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$SearchListingsImplImpl &&
            (identical(other.listingTypeId, listingTypeId) ||
                other.listingTypeId == listingTypeId) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.subwayStationId, subwayStationId) ||
                other.subwayStationId == subwayStationId) &&
            (identical(other.subwayLineId, subwayLineId) ||
                other.subwayLineId == subwayLineId) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.privateRoom, privateRoom) ||
                other.privateRoom == privateRoom) &&
            (identical(other.withPhoto, withPhoto) ||
                other.withPhoto == withPhoto) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.isRefresh, isRefresh) ||
                other.isRefresh == isRefresh));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      listingTypeId,
      locationId,
      subwayStationId,
      subwayLineId,
      gender,
      minPrice,
      maxPrice,
      privateRoom,
      withPhoto,
      page,
      limit,
      isActive,
      isRefresh);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$$SearchListingsImplImplCopyWith<_$$SearchListingsImplImpl> get copyWith =>
      __$$$SearchListingsImplImplCopyWithImpl<_$$SearchListingsImplImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int page, int limit, bool isActive, bool isRefresh)
        fetchListings,
    required TResult Function(int limit, bool isActive) loadMore,
    required TResult Function(int subwayStationId, int page, int limit,
            bool isActive, bool isRefresh)
        fetchListingsBySubwayStation,
    required TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)
        fetchListingsByLocation,
    required TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)
        searchListings,
    required TResult Function(int page, int limit, bool isRefresh)
        fetchUserListings,
  }) {
    return searchListings(
        listingTypeId,
        locationId,
        subwayStationId,
        subwayLineId,
        gender,
        minPrice,
        maxPrice,
        privateRoom,
        withPhoto,
        page,
        limit,
        isActive,
        isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult? Function(int limit, bool isActive)? loadMore,
    TResult? Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult? Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult? Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult? Function(int page, int limit, bool isRefresh)? fetchUserListings,
  }) {
    return searchListings?.call(
        listingTypeId,
        locationId,
        subwayStationId,
        subwayLineId,
        gender,
        minPrice,
        maxPrice,
        privateRoom,
        withPhoto,
        page,
        limit,
        isActive,
        isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult Function(int limit, bool isActive)? loadMore,
    TResult Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult Function(int page, int limit, bool isRefresh)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (searchListings != null) {
      return searchListings(
          listingTypeId,
          locationId,
          subwayStationId,
          subwayLineId,
          gender,
          minPrice,
          maxPrice,
          privateRoom,
          withPhoto,
          page,
          limit,
          isActive,
          isRefresh);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_$FetchListingsImpl value) fetchListings,
    required TResult Function(_$LoadMoreImpl value) loadMore,
    required TResult Function(_$FetchListingsBySubwayStationImpl value)
        fetchListingsBySubwayStation,
    required TResult Function(_$FetchListingsByLocationImpl value)
        fetchListingsByLocation,
    required TResult Function(_$SearchListingsImpl value) searchListings,
    required TResult Function(_$FetchUserListingsImpl value) fetchUserListings,
  }) {
    return searchListings(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_$FetchListingsImpl value)? fetchListings,
    TResult? Function(_$LoadMoreImpl value)? loadMore,
    TResult? Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult? Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult? Function(_$SearchListingsImpl value)? searchListings,
    TResult? Function(_$FetchUserListingsImpl value)? fetchUserListings,
  }) {
    return searchListings?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_$FetchListingsImpl value)? fetchListings,
    TResult Function(_$LoadMoreImpl value)? loadMore,
    TResult Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult Function(_$SearchListingsImpl value)? searchListings,
    TResult Function(_$FetchUserListingsImpl value)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (searchListings != null) {
      return searchListings(this);
    }
    return orElse();
  }
}

abstract class _$SearchListingsImpl implements ListingsEvent {
  const factory _$SearchListingsImpl(
      {final int? listingTypeId,
      final int? locationId,
      final int? subwayStationId,
      final int? subwayLineId,
      final int? gender,
      final double? minPrice,
      final double? maxPrice,
      final bool? privateRoom,
      final bool? withPhoto,
      final int page,
      final int limit,
      final bool isActive,
      final bool isRefresh}) = _$$SearchListingsImplImpl;

  int? get listingTypeId;
  int? get locationId;
  int? get subwayStationId;
  int? get subwayLineId;
  int? get gender;
  double? get minPrice;
  double? get maxPrice;
  bool? get privateRoom;
  bool? get withPhoto;
  int get page;
  @override
  int get limit;
  bool get isActive;
  bool get isRefresh;

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$$SearchListingsImplImplCopyWith<_$$SearchListingsImplImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$$FetchUserListingsImplImplCopyWith<$Res>
    implements $ListingsEventCopyWith<$Res> {
  factory _$$$FetchUserListingsImplImplCopyWith(
          _$$FetchUserListingsImplImpl value,
          $Res Function(_$$FetchUserListingsImplImpl) then) =
      __$$$FetchUserListingsImplImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int page, int limit, bool isRefresh});
}

/// @nodoc
class __$$$FetchUserListingsImplImplCopyWithImpl<$Res>
    extends _$ListingsEventCopyWithImpl<$Res, _$$FetchUserListingsImplImpl>
    implements _$$$FetchUserListingsImplImplCopyWith<$Res> {
  __$$$FetchUserListingsImplImplCopyWithImpl(
      _$$FetchUserListingsImplImpl _value,
      $Res Function(_$$FetchUserListingsImplImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? limit = null,
    Object? isRefresh = null,
  }) {
    return _then(_$$FetchUserListingsImplImpl(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      isRefresh: null == isRefresh
          ? _value.isRefresh
          : isRefresh // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$$FetchUserListingsImplImpl implements _$FetchUserListingsImpl {
  const _$$FetchUserListingsImplImpl(
      {this.page = 1, this.limit = 10, this.isRefresh = true});

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int limit;
  @override
  @JsonKey()
  final bool isRefresh;

  @override
  String toString() {
    return 'ListingsEvent.fetchUserListings(page: $page, limit: $limit, isRefresh: $isRefresh)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$$FetchUserListingsImplImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.isRefresh, isRefresh) ||
                other.isRefresh == isRefresh));
  }

  @override
  int get hashCode => Object.hash(runtimeType, page, limit, isRefresh);

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$$FetchUserListingsImplImplCopyWith<_$$FetchUserListingsImplImpl>
      get copyWith => __$$$FetchUserListingsImplImplCopyWithImpl<
          _$$FetchUserListingsImplImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            int page, int limit, bool isActive, bool isRefresh)
        fetchListings,
    required TResult Function(int limit, bool isActive) loadMore,
    required TResult Function(int subwayStationId, int page, int limit,
            bool isActive, bool isRefresh)
        fetchListingsBySubwayStation,
    required TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)
        fetchListingsByLocation,
    required TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)
        searchListings,
    required TResult Function(int page, int limit, bool isRefresh)
        fetchUserListings,
  }) {
    return fetchUserListings(page, limit, isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult? Function(int limit, bool isActive)? loadMore,
    TResult? Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult? Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult? Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult? Function(int page, int limit, bool isRefresh)? fetchUserListings,
  }) {
    return fetchUserListings?.call(page, limit, isRefresh);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int page, int limit, bool isActive, bool isRefresh)?
        fetchListings,
    TResult Function(int limit, bool isActive)? loadMore,
    TResult Function(int subwayStationId, int page, int limit, bool isActive,
            bool isRefresh)?
        fetchListingsBySubwayStation,
    TResult Function(
            int locationId, int page, int limit, bool isActive, bool isRefresh)?
        fetchListingsByLocation,
    TResult Function(
            int? listingTypeId,
            int? locationId,
            int? subwayStationId,
            int? subwayLineId,
            int? gender,
            double? minPrice,
            double? maxPrice,
            bool? privateRoom,
            bool? withPhoto,
            int page,
            int limit,
            bool isActive,
            bool isRefresh)?
        searchListings,
    TResult Function(int page, int limit, bool isRefresh)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (fetchUserListings != null) {
      return fetchUserListings(page, limit, isRefresh);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_$FetchListingsImpl value) fetchListings,
    required TResult Function(_$LoadMoreImpl value) loadMore,
    required TResult Function(_$FetchListingsBySubwayStationImpl value)
        fetchListingsBySubwayStation,
    required TResult Function(_$FetchListingsByLocationImpl value)
        fetchListingsByLocation,
    required TResult Function(_$SearchListingsImpl value) searchListings,
    required TResult Function(_$FetchUserListingsImpl value) fetchUserListings,
  }) {
    return fetchUserListings(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_$FetchListingsImpl value)? fetchListings,
    TResult? Function(_$LoadMoreImpl value)? loadMore,
    TResult? Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult? Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult? Function(_$SearchListingsImpl value)? searchListings,
    TResult? Function(_$FetchUserListingsImpl value)? fetchUserListings,
  }) {
    return fetchUserListings?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_$FetchListingsImpl value)? fetchListings,
    TResult Function(_$LoadMoreImpl value)? loadMore,
    TResult Function(_$FetchListingsBySubwayStationImpl value)?
        fetchListingsBySubwayStation,
    TResult Function(_$FetchListingsByLocationImpl value)?
        fetchListingsByLocation,
    TResult Function(_$SearchListingsImpl value)? searchListings,
    TResult Function(_$FetchUserListingsImpl value)? fetchUserListings,
    required TResult orElse(),
  }) {
    if (fetchUserListings != null) {
      return fetchUserListings(this);
    }
    return orElse();
  }
}

abstract class _$FetchUserListingsImpl implements ListingsEvent {
  const factory _$FetchUserListingsImpl(
      {final int page,
      final int limit,
      final bool isRefresh}) = _$$FetchUserListingsImplImpl;

  int get page;
  @override
  int get limit;
  bool get isRefresh;

  /// Create a copy of ListingsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$$FetchUserListingsImplImplCopyWith<_$$FetchUserListingsImplImpl>
      get copyWith => throw _privateConstructorUsedError;
}
