// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listings_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListingsEvent {

 int get limit;
/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingsEventCopyWith<ListingsEvent> get copyWith => _$ListingsEventCopyWithImpl<ListingsEvent>(this as ListingsEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingsEvent&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,limit);

@override
String toString() {
  return 'ListingsEvent(limit: $limit)';
}


}

/// @nodoc
abstract mixin class $ListingsEventCopyWith<$Res>  {
  factory $ListingsEventCopyWith(ListingsEvent value, $Res Function(ListingsEvent) _then) = _$ListingsEventCopyWithImpl;
@useResult
$Res call({
 int limit
});




}
/// @nodoc
class _$ListingsEventCopyWithImpl<$Res>
    implements $ListingsEventCopyWith<$Res> {
  _$ListingsEventCopyWithImpl(this._self, this._then);

  final ListingsEvent _self;
  final $Res Function(ListingsEvent) _then;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = null,}) {
  return _then(_self.copyWith(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingsEvent].
extension ListingsEventPatterns on ListingsEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FetchListings value)?  fetchListings,TResult Function( _LoadMore value)?  loadMore,TResult Function( _FetchListingsByLocation value)?  fetchListingsByLocation,TResult Function( _SearchListings value)?  searchListings,TResult Function( _FetchUserListings value)?  fetchUserListings,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FetchListings() when fetchListings != null:
return fetchListings(_that);case _LoadMore() when loadMore != null:
return loadMore(_that);case _FetchListingsByLocation() when fetchListingsByLocation != null:
return fetchListingsByLocation(_that);case _SearchListings() when searchListings != null:
return searchListings(_that);case _FetchUserListings() when fetchUserListings != null:
return fetchUserListings(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FetchListings value)  fetchListings,required TResult Function( _LoadMore value)  loadMore,required TResult Function( _FetchListingsByLocation value)  fetchListingsByLocation,required TResult Function( _SearchListings value)  searchListings,required TResult Function( _FetchUserListings value)  fetchUserListings,}){
final _that = this;
switch (_that) {
case _FetchListings():
return fetchListings(_that);case _LoadMore():
return loadMore(_that);case _FetchListingsByLocation():
return fetchListingsByLocation(_that);case _SearchListings():
return searchListings(_that);case _FetchUserListings():
return fetchUserListings(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FetchListings value)?  fetchListings,TResult? Function( _LoadMore value)?  loadMore,TResult? Function( _FetchListingsByLocation value)?  fetchListingsByLocation,TResult? Function( _SearchListings value)?  searchListings,TResult? Function( _FetchUserListings value)?  fetchUserListings,}){
final _that = this;
switch (_that) {
case _FetchListings() when fetchListings != null:
return fetchListings(_that);case _LoadMore() when loadMore != null:
return loadMore(_that);case _FetchListingsByLocation() when fetchListingsByLocation != null:
return fetchListingsByLocation(_that);case _SearchListings() when searchListings != null:
return searchListings(_that);case _FetchUserListings() when fetchUserListings != null:
return fetchUserListings(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int page,  int limit,  bool isActive,  bool isRefresh)?  fetchListings,TResult Function( int limit,  bool isActive)?  loadMore,TResult Function( int locationId,  int page,  int limit,  bool isActive,  bool isRefresh)?  fetchListingsByLocation,TResult Function( int? listingTypeId,  List<int>? listingTypeIds,  int? locationId,  int? subwayStationId,  List<int>? subwayStationIds,  int? subwayLineId,  int? gender,  double? minPrice,  double? maxPrice,  bool? privateRoom,  bool? withPhoto,  bool? has3dTour,  String? priceSortOrder,  List<int>? excludeUserIds,  int page,  int limit,  bool isActive,  bool isRefresh,  bool keepStaleWhileRefreshing)?  searchListings,TResult Function( int page,  int limit,  bool isRefresh)?  fetchUserListings,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FetchListings() when fetchListings != null:
return fetchListings(_that.page,_that.limit,_that.isActive,_that.isRefresh);case _LoadMore() when loadMore != null:
return loadMore(_that.limit,_that.isActive);case _FetchListingsByLocation() when fetchListingsByLocation != null:
return fetchListingsByLocation(_that.locationId,_that.page,_that.limit,_that.isActive,_that.isRefresh);case _SearchListings() when searchListings != null:
return searchListings(_that.listingTypeId,_that.listingTypeIds,_that.locationId,_that.subwayStationId,_that.subwayStationIds,_that.subwayLineId,_that.gender,_that.minPrice,_that.maxPrice,_that.privateRoom,_that.withPhoto,_that.has3dTour,_that.priceSortOrder,_that.excludeUserIds,_that.page,_that.limit,_that.isActive,_that.isRefresh,_that.keepStaleWhileRefreshing);case _FetchUserListings() when fetchUserListings != null:
return fetchUserListings(_that.page,_that.limit,_that.isRefresh);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int page,  int limit,  bool isActive,  bool isRefresh)  fetchListings,required TResult Function( int limit,  bool isActive)  loadMore,required TResult Function( int locationId,  int page,  int limit,  bool isActive,  bool isRefresh)  fetchListingsByLocation,required TResult Function( int? listingTypeId,  List<int>? listingTypeIds,  int? locationId,  int? subwayStationId,  List<int>? subwayStationIds,  int? subwayLineId,  int? gender,  double? minPrice,  double? maxPrice,  bool? privateRoom,  bool? withPhoto,  bool? has3dTour,  String? priceSortOrder,  List<int>? excludeUserIds,  int page,  int limit,  bool isActive,  bool isRefresh,  bool keepStaleWhileRefreshing)  searchListings,required TResult Function( int page,  int limit,  bool isRefresh)  fetchUserListings,}) {final _that = this;
switch (_that) {
case _FetchListings():
return fetchListings(_that.page,_that.limit,_that.isActive,_that.isRefresh);case _LoadMore():
return loadMore(_that.limit,_that.isActive);case _FetchListingsByLocation():
return fetchListingsByLocation(_that.locationId,_that.page,_that.limit,_that.isActive,_that.isRefresh);case _SearchListings():
return searchListings(_that.listingTypeId,_that.listingTypeIds,_that.locationId,_that.subwayStationId,_that.subwayStationIds,_that.subwayLineId,_that.gender,_that.minPrice,_that.maxPrice,_that.privateRoom,_that.withPhoto,_that.has3dTour,_that.priceSortOrder,_that.excludeUserIds,_that.page,_that.limit,_that.isActive,_that.isRefresh,_that.keepStaleWhileRefreshing);case _FetchUserListings():
return fetchUserListings(_that.page,_that.limit,_that.isRefresh);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int page,  int limit,  bool isActive,  bool isRefresh)?  fetchListings,TResult? Function( int limit,  bool isActive)?  loadMore,TResult? Function( int locationId,  int page,  int limit,  bool isActive,  bool isRefresh)?  fetchListingsByLocation,TResult? Function( int? listingTypeId,  List<int>? listingTypeIds,  int? locationId,  int? subwayStationId,  List<int>? subwayStationIds,  int? subwayLineId,  int? gender,  double? minPrice,  double? maxPrice,  bool? privateRoom,  bool? withPhoto,  bool? has3dTour,  String? priceSortOrder,  List<int>? excludeUserIds,  int page,  int limit,  bool isActive,  bool isRefresh,  bool keepStaleWhileRefreshing)?  searchListings,TResult? Function( int page,  int limit,  bool isRefresh)?  fetchUserListings,}) {final _that = this;
switch (_that) {
case _FetchListings() when fetchListings != null:
return fetchListings(_that.page,_that.limit,_that.isActive,_that.isRefresh);case _LoadMore() when loadMore != null:
return loadMore(_that.limit,_that.isActive);case _FetchListingsByLocation() when fetchListingsByLocation != null:
return fetchListingsByLocation(_that.locationId,_that.page,_that.limit,_that.isActive,_that.isRefresh);case _SearchListings() when searchListings != null:
return searchListings(_that.listingTypeId,_that.listingTypeIds,_that.locationId,_that.subwayStationId,_that.subwayStationIds,_that.subwayLineId,_that.gender,_that.minPrice,_that.maxPrice,_that.privateRoom,_that.withPhoto,_that.has3dTour,_that.priceSortOrder,_that.excludeUserIds,_that.page,_that.limit,_that.isActive,_that.isRefresh,_that.keepStaleWhileRefreshing);case _FetchUserListings() when fetchUserListings != null:
return fetchUserListings(_that.page,_that.limit,_that.isRefresh);case _:
  return null;

}
}

}

/// @nodoc


class _FetchListings implements ListingsEvent {
  const _FetchListings({this.page = 1, this.limit = 10, this.isActive = true, this.isRefresh = true});
  

@JsonKey() final  int page;
@override@JsonKey() final  int limit;
@JsonKey() final  bool isActive;
@JsonKey() final  bool isRefresh;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchListingsCopyWith<_FetchListings> get copyWith => __$FetchListingsCopyWithImpl<_FetchListings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchListings&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isRefresh, isRefresh) || other.isRefresh == isRefresh));
}


@override
int get hashCode => Object.hash(runtimeType,page,limit,isActive,isRefresh);

@override
String toString() {
  return 'ListingsEvent.fetchListings(page: $page, limit: $limit, isActive: $isActive, isRefresh: $isRefresh)';
}


}

/// @nodoc
abstract mixin class _$FetchListingsCopyWith<$Res> implements $ListingsEventCopyWith<$Res> {
  factory _$FetchListingsCopyWith(_FetchListings value, $Res Function(_FetchListings) _then) = __$FetchListingsCopyWithImpl;
@override @useResult
$Res call({
 int page, int limit, bool isActive, bool isRefresh
});




}
/// @nodoc
class __$FetchListingsCopyWithImpl<$Res>
    implements _$FetchListingsCopyWith<$Res> {
  __$FetchListingsCopyWithImpl(this._self, this._then);

  final _FetchListings _self;
  final $Res Function(_FetchListings) _then;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? limit = null,Object? isActive = null,Object? isRefresh = null,}) {
  return _then(_FetchListings(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isRefresh: null == isRefresh ? _self.isRefresh : isRefresh // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _LoadMore implements ListingsEvent {
  const _LoadMore({this.limit = 10, this.isActive = true});
  

@override@JsonKey() final  int limit;
@JsonKey() final  bool isActive;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadMoreCopyWith<_LoadMore> get copyWith => __$LoadMoreCopyWithImpl<_LoadMore>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoadMore&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}


@override
int get hashCode => Object.hash(runtimeType,limit,isActive);

@override
String toString() {
  return 'ListingsEvent.loadMore(limit: $limit, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$LoadMoreCopyWith<$Res> implements $ListingsEventCopyWith<$Res> {
  factory _$LoadMoreCopyWith(_LoadMore value, $Res Function(_LoadMore) _then) = __$LoadMoreCopyWithImpl;
@override @useResult
$Res call({
 int limit, bool isActive
});




}
/// @nodoc
class __$LoadMoreCopyWithImpl<$Res>
    implements _$LoadMoreCopyWith<$Res> {
  __$LoadMoreCopyWithImpl(this._self, this._then);

  final _LoadMore _self;
  final $Res Function(_LoadMore) _then;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = null,Object? isActive = null,}) {
  return _then(_LoadMore(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _FetchListingsByLocation implements ListingsEvent {
  const _FetchListingsByLocation({required this.locationId, this.page = 1, this.limit = 10, this.isActive = true, this.isRefresh = true});
  

 final  int locationId;
@JsonKey() final  int page;
@override@JsonKey() final  int limit;
@JsonKey() final  bool isActive;
@JsonKey() final  bool isRefresh;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchListingsByLocationCopyWith<_FetchListingsByLocation> get copyWith => __$FetchListingsByLocationCopyWithImpl<_FetchListingsByLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchListingsByLocation&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isRefresh, isRefresh) || other.isRefresh == isRefresh));
}


@override
int get hashCode => Object.hash(runtimeType,locationId,page,limit,isActive,isRefresh);

@override
String toString() {
  return 'ListingsEvent.fetchListingsByLocation(locationId: $locationId, page: $page, limit: $limit, isActive: $isActive, isRefresh: $isRefresh)';
}


}

/// @nodoc
abstract mixin class _$FetchListingsByLocationCopyWith<$Res> implements $ListingsEventCopyWith<$Res> {
  factory _$FetchListingsByLocationCopyWith(_FetchListingsByLocation value, $Res Function(_FetchListingsByLocation) _then) = __$FetchListingsByLocationCopyWithImpl;
@override @useResult
$Res call({
 int locationId, int page, int limit, bool isActive, bool isRefresh
});




}
/// @nodoc
class __$FetchListingsByLocationCopyWithImpl<$Res>
    implements _$FetchListingsByLocationCopyWith<$Res> {
  __$FetchListingsByLocationCopyWithImpl(this._self, this._then);

  final _FetchListingsByLocation _self;
  final $Res Function(_FetchListingsByLocation) _then;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationId = null,Object? page = null,Object? limit = null,Object? isActive = null,Object? isRefresh = null,}) {
  return _then(_FetchListingsByLocation(
locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isRefresh: null == isRefresh ? _self.isRefresh : isRefresh // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _SearchListings implements ListingsEvent {
  const _SearchListings({this.listingTypeId, final  List<int>? listingTypeIds, this.locationId, this.subwayStationId, final  List<int>? subwayStationIds, this.subwayLineId, this.gender, this.minPrice, this.maxPrice, this.privateRoom, this.withPhoto, this.has3dTour, this.priceSortOrder, final  List<int>? excludeUserIds, this.page = 1, this.limit = 10, this.isActive = true, this.isRefresh = true, this.keepStaleWhileRefreshing = false}): _listingTypeIds = listingTypeIds,_subwayStationIds = subwayStationIds,_excludeUserIds = excludeUserIds;
  

 final  int? listingTypeId;
 final  List<int>? _listingTypeIds;
 List<int>? get listingTypeIds {
  final value = _listingTypeIds;
  if (value == null) return null;
  if (_listingTypeIds is EqualUnmodifiableListView) return _listingTypeIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  int? locationId;
 final  int? subwayStationId;
 final  List<int>? _subwayStationIds;
 List<int>? get subwayStationIds {
  final value = _subwayStationIds;
  if (value == null) return null;
  if (_subwayStationIds is EqualUnmodifiableListView) return _subwayStationIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  int? subwayLineId;
 final  int? gender;
 final  double? minPrice;
 final  double? maxPrice;
 final  bool? privateRoom;
 final  bool? withPhoto;
 final  bool? has3dTour;
 final  String? priceSortOrder;
 final  List<int>? _excludeUserIds;
 List<int>? get excludeUserIds {
  final value = _excludeUserIds;
  if (value == null) return null;
  if (_excludeUserIds is EqualUnmodifiableListView) return _excludeUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@JsonKey() final  int page;
@override@JsonKey() final  int limit;
@JsonKey() final  bool isActive;
@JsonKey() final  bool isRefresh;
/// When true with [isRefresh], keeps current listings on screen until the
/// new page returns (skips loading/skeleton state).
@JsonKey() final  bool keepStaleWhileRefreshing;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchListingsCopyWith<_SearchListings> get copyWith => __$SearchListingsCopyWithImpl<_SearchListings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchListings&&(identical(other.listingTypeId, listingTypeId) || other.listingTypeId == listingTypeId)&&const DeepCollectionEquality().equals(other._listingTypeIds, _listingTypeIds)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.subwayStationId, subwayStationId) || other.subwayStationId == subwayStationId)&&const DeepCollectionEquality().equals(other._subwayStationIds, _subwayStationIds)&&(identical(other.subwayLineId, subwayLineId) || other.subwayLineId == subwayLineId)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.privateRoom, privateRoom) || other.privateRoom == privateRoom)&&(identical(other.withPhoto, withPhoto) || other.withPhoto == withPhoto)&&(identical(other.has3dTour, has3dTour) || other.has3dTour == has3dTour)&&(identical(other.priceSortOrder, priceSortOrder) || other.priceSortOrder == priceSortOrder)&&const DeepCollectionEquality().equals(other._excludeUserIds, _excludeUserIds)&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.isRefresh, isRefresh) || other.isRefresh == isRefresh)&&(identical(other.keepStaleWhileRefreshing, keepStaleWhileRefreshing) || other.keepStaleWhileRefreshing == keepStaleWhileRefreshing));
}


@override
int get hashCode => Object.hashAll([runtimeType,listingTypeId,const DeepCollectionEquality().hash(_listingTypeIds),locationId,subwayStationId,const DeepCollectionEquality().hash(_subwayStationIds),subwayLineId,gender,minPrice,maxPrice,privateRoom,withPhoto,has3dTour,priceSortOrder,const DeepCollectionEquality().hash(_excludeUserIds),page,limit,isActive,isRefresh,keepStaleWhileRefreshing]);

@override
String toString() {
  return 'ListingsEvent.searchListings(listingTypeId: $listingTypeId, listingTypeIds: $listingTypeIds, locationId: $locationId, subwayStationId: $subwayStationId, subwayStationIds: $subwayStationIds, subwayLineId: $subwayLineId, gender: $gender, minPrice: $minPrice, maxPrice: $maxPrice, privateRoom: $privateRoom, withPhoto: $withPhoto, has3dTour: $has3dTour, priceSortOrder: $priceSortOrder, excludeUserIds: $excludeUserIds, page: $page, limit: $limit, isActive: $isActive, isRefresh: $isRefresh, keepStaleWhileRefreshing: $keepStaleWhileRefreshing)';
}


}

/// @nodoc
abstract mixin class _$SearchListingsCopyWith<$Res> implements $ListingsEventCopyWith<$Res> {
  factory _$SearchListingsCopyWith(_SearchListings value, $Res Function(_SearchListings) _then) = __$SearchListingsCopyWithImpl;
@override @useResult
$Res call({
 int? listingTypeId, List<int>? listingTypeIds, int? locationId, int? subwayStationId, List<int>? subwayStationIds, int? subwayLineId, int? gender, double? minPrice, double? maxPrice, bool? privateRoom, bool? withPhoto, bool? has3dTour, String? priceSortOrder, List<int>? excludeUserIds, int page, int limit, bool isActive, bool isRefresh, bool keepStaleWhileRefreshing
});




}
/// @nodoc
class __$SearchListingsCopyWithImpl<$Res>
    implements _$SearchListingsCopyWith<$Res> {
  __$SearchListingsCopyWithImpl(this._self, this._then);

  final _SearchListings _self;
  final $Res Function(_SearchListings) _then;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listingTypeId = freezed,Object? listingTypeIds = freezed,Object? locationId = freezed,Object? subwayStationId = freezed,Object? subwayStationIds = freezed,Object? subwayLineId = freezed,Object? gender = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? privateRoom = freezed,Object? withPhoto = freezed,Object? has3dTour = freezed,Object? priceSortOrder = freezed,Object? excludeUserIds = freezed,Object? page = null,Object? limit = null,Object? isActive = null,Object? isRefresh = null,Object? keepStaleWhileRefreshing = null,}) {
  return _then(_SearchListings(
listingTypeId: freezed == listingTypeId ? _self.listingTypeId : listingTypeId // ignore: cast_nullable_to_non_nullable
as int?,listingTypeIds: freezed == listingTypeIds ? _self._listingTypeIds : listingTypeIds // ignore: cast_nullable_to_non_nullable
as List<int>?,locationId: freezed == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as int?,subwayStationId: freezed == subwayStationId ? _self.subwayStationId : subwayStationId // ignore: cast_nullable_to_non_nullable
as int?,subwayStationIds: freezed == subwayStationIds ? _self._subwayStationIds : subwayStationIds // ignore: cast_nullable_to_non_nullable
as List<int>?,subwayLineId: freezed == subwayLineId ? _self.subwayLineId : subwayLineId // ignore: cast_nullable_to_non_nullable
as int?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as int?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as double?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as double?,privateRoom: freezed == privateRoom ? _self.privateRoom : privateRoom // ignore: cast_nullable_to_non_nullable
as bool?,withPhoto: freezed == withPhoto ? _self.withPhoto : withPhoto // ignore: cast_nullable_to_non_nullable
as bool?,has3dTour: freezed == has3dTour ? _self.has3dTour : has3dTour // ignore: cast_nullable_to_non_nullable
as bool?,priceSortOrder: freezed == priceSortOrder ? _self.priceSortOrder : priceSortOrder // ignore: cast_nullable_to_non_nullable
as String?,excludeUserIds: freezed == excludeUserIds ? _self._excludeUserIds : excludeUserIds // ignore: cast_nullable_to_non_nullable
as List<int>?,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,isRefresh: null == isRefresh ? _self.isRefresh : isRefresh // ignore: cast_nullable_to_non_nullable
as bool,keepStaleWhileRefreshing: null == keepStaleWhileRefreshing ? _self.keepStaleWhileRefreshing : keepStaleWhileRefreshing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _FetchUserListings implements ListingsEvent {
  const _FetchUserListings({this.page = 1, this.limit = 10, this.isRefresh = true});
  

@JsonKey() final  int page;
@override@JsonKey() final  int limit;
@JsonKey() final  bool isRefresh;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchUserListingsCopyWith<_FetchUserListings> get copyWith => __$FetchUserListingsCopyWithImpl<_FetchUserListings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchUserListings&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.isRefresh, isRefresh) || other.isRefresh == isRefresh));
}


@override
int get hashCode => Object.hash(runtimeType,page,limit,isRefresh);

@override
String toString() {
  return 'ListingsEvent.fetchUserListings(page: $page, limit: $limit, isRefresh: $isRefresh)';
}


}

/// @nodoc
abstract mixin class _$FetchUserListingsCopyWith<$Res> implements $ListingsEventCopyWith<$Res> {
  factory _$FetchUserListingsCopyWith(_FetchUserListings value, $Res Function(_FetchUserListings) _then) = __$FetchUserListingsCopyWithImpl;
@override @useResult
$Res call({
 int page, int limit, bool isRefresh
});




}
/// @nodoc
class __$FetchUserListingsCopyWithImpl<$Res>
    implements _$FetchUserListingsCopyWith<$Res> {
  __$FetchUserListingsCopyWithImpl(this._self, this._then);

  final _FetchUserListings _self;
  final $Res Function(_FetchUserListings) _then;

/// Create a copy of ListingsEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? limit = null,Object? isRefresh = null,}) {
  return _then(_FetchUserListings(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,isRefresh: null == isRefresh ? _self.isRefresh : isRefresh // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
