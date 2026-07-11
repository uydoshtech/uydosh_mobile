// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_detail_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListingDetailEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingDetailEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ListingDetailEvent()';
}


}

/// @nodoc
class $ListingDetailEventCopyWith<$Res>  {
$ListingDetailEventCopyWith(ListingDetailEvent _, $Res Function(ListingDetailEvent) __);
}


/// Adds pattern-matching-related methods to [ListingDetailEvent].
extension ListingDetailEventPatterns on ListingDetailEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FetchListingDetail value)?  fetchListingDetail,TResult Function( _UpdateListingDetail value)?  updateListingDetail,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FetchListingDetail() when fetchListingDetail != null:
return fetchListingDetail(_that);case _UpdateListingDetail() when updateListingDetail != null:
return updateListingDetail(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FetchListingDetail value)  fetchListingDetail,required TResult Function( _UpdateListingDetail value)  updateListingDetail,}){
final _that = this;
switch (_that) {
case _FetchListingDetail():
return fetchListingDetail(_that);case _UpdateListingDetail():
return updateListingDetail(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FetchListingDetail value)?  fetchListingDetail,TResult? Function( _UpdateListingDetail value)?  updateListingDetail,}){
final _that = this;
switch (_that) {
case _FetchListingDetail() when fetchListingDetail != null:
return fetchListingDetail(_that);case _UpdateListingDetail() when updateListingDetail != null:
return updateListingDetail(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int id,  bool isRefresh)?  fetchListingDetail,TResult Function( ListingDetail listingDetail)?  updateListingDetail,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FetchListingDetail() when fetchListingDetail != null:
return fetchListingDetail(_that.id,_that.isRefresh);case _UpdateListingDetail() when updateListingDetail != null:
return updateListingDetail(_that.listingDetail);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int id,  bool isRefresh)  fetchListingDetail,required TResult Function( ListingDetail listingDetail)  updateListingDetail,}) {final _that = this;
switch (_that) {
case _FetchListingDetail():
return fetchListingDetail(_that.id,_that.isRefresh);case _UpdateListingDetail():
return updateListingDetail(_that.listingDetail);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int id,  bool isRefresh)?  fetchListingDetail,TResult? Function( ListingDetail listingDetail)?  updateListingDetail,}) {final _that = this;
switch (_that) {
case _FetchListingDetail() when fetchListingDetail != null:
return fetchListingDetail(_that.id,_that.isRefresh);case _UpdateListingDetail() when updateListingDetail != null:
return updateListingDetail(_that.listingDetail);case _:
  return null;

}
}

}

/// @nodoc


class _FetchListingDetail implements ListingDetailEvent {
  const _FetchListingDetail({required this.id, this.isRefresh = false});
  

 final  int id;
@JsonKey() final  bool isRefresh;

/// Create a copy of ListingDetailEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchListingDetailCopyWith<_FetchListingDetail> get copyWith => __$FetchListingDetailCopyWithImpl<_FetchListingDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchListingDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.isRefresh, isRefresh) || other.isRefresh == isRefresh));
}


@override
int get hashCode => Object.hash(runtimeType,id,isRefresh);

@override
String toString() {
  return 'ListingDetailEvent.fetchListingDetail(id: $id, isRefresh: $isRefresh)';
}


}

/// @nodoc
abstract mixin class _$FetchListingDetailCopyWith<$Res> implements $ListingDetailEventCopyWith<$Res> {
  factory _$FetchListingDetailCopyWith(_FetchListingDetail value, $Res Function(_FetchListingDetail) _then) = __$FetchListingDetailCopyWithImpl;
@useResult
$Res call({
 int id, bool isRefresh
});




}
/// @nodoc
class __$FetchListingDetailCopyWithImpl<$Res>
    implements _$FetchListingDetailCopyWith<$Res> {
  __$FetchListingDetailCopyWithImpl(this._self, this._then);

  final _FetchListingDetail _self;
  final $Res Function(_FetchListingDetail) _then;

/// Create a copy of ListingDetailEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isRefresh = null,}) {
  return _then(_FetchListingDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,isRefresh: null == isRefresh ? _self.isRefresh : isRefresh // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _UpdateListingDetail implements ListingDetailEvent {
  const _UpdateListingDetail({required this.listingDetail});
  

 final  ListingDetail listingDetail;

/// Create a copy of ListingDetailEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateListingDetailCopyWith<_UpdateListingDetail> get copyWith => __$UpdateListingDetailCopyWithImpl<_UpdateListingDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateListingDetail&&(identical(other.listingDetail, listingDetail) || other.listingDetail == listingDetail));
}


@override
int get hashCode => Object.hash(runtimeType,listingDetail);

@override
String toString() {
  return 'ListingDetailEvent.updateListingDetail(listingDetail: $listingDetail)';
}


}

/// @nodoc
abstract mixin class _$UpdateListingDetailCopyWith<$Res> implements $ListingDetailEventCopyWith<$Res> {
  factory _$UpdateListingDetailCopyWith(_UpdateListingDetail value, $Res Function(_UpdateListingDetail) _then) = __$UpdateListingDetailCopyWithImpl;
@useResult
$Res call({
 ListingDetail listingDetail
});


$ListingDetailCopyWith<$Res> get listingDetail;

}
/// @nodoc
class __$UpdateListingDetailCopyWithImpl<$Res>
    implements _$UpdateListingDetailCopyWith<$Res> {
  __$UpdateListingDetailCopyWithImpl(this._self, this._then);

  final _UpdateListingDetail _self;
  final $Res Function(_UpdateListingDetail) _then;

/// Create a copy of ListingDetailEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? listingDetail = null,}) {
  return _then(_UpdateListingDetail(
listingDetail: null == listingDetail ? _self.listingDetail : listingDetail // ignore: cast_nullable_to_non_nullable
as ListingDetail,
  ));
}

/// Create a copy of ListingDetailEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingDetailCopyWith<$Res> get listingDetail {
  
  return $ListingDetailCopyWith<$Res>(_self.listingDetail, (value) {
    return _then(_self.copyWith(listingDetail: value));
  });
}
}

/// @nodoc
mixin _$ListingDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ListingDetailState()';
}


}

/// @nodoc
class $ListingDetailStateCopyWith<$Res>  {
$ListingDetailStateCopyWith(ListingDetailState _, $Res Function(ListingDetailState) __);
}


/// Adds pattern-matching-related methods to [ListingDetailState].
extension ListingDetailStatePatterns on ListingDetailState {
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( ListingDetail listingDetail)?  loaded,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.listingDetail);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( ListingDetail listingDetail)  loaded,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.listingDetail);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( ListingDetail listingDetail)?  loaded,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.listingDetail);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ListingDetailState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ListingDetailState.initial()';
}


}




/// @nodoc


class _Loading implements ListingDetailState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ListingDetailState.loading()';
}


}




/// @nodoc


class _Loaded implements ListingDetailState {
  const _Loaded({required this.listingDetail});
  

 final  ListingDetail listingDetail;

/// Create a copy of ListingDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&(identical(other.listingDetail, listingDetail) || other.listingDetail == listingDetail));
}


@override
int get hashCode => Object.hash(runtimeType,listingDetail);

@override
String toString() {
  return 'ListingDetailState.loaded(listingDetail: $listingDetail)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $ListingDetailStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 ListingDetail listingDetail
});


$ListingDetailCopyWith<$Res> get listingDetail;

}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of ListingDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? listingDetail = null,}) {
  return _then(_Loaded(
listingDetail: null == listingDetail ? _self.listingDetail : listingDetail // ignore: cast_nullable_to_non_nullable
as ListingDetail,
  ));
}

/// Create a copy of ListingDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingDetailCopyWith<$Res> get listingDetail {
  
  return $ListingDetailCopyWith<$Res>(_self.listingDetail, (value) {
    return _then(_self.copyWith(listingDetail: value));
  });
}
}

/// @nodoc


class _Error implements ListingDetailState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of ListingDetailState
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
  return 'ListingDetailState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ListingDetailStateCopyWith<$Res> {
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

/// Create a copy of ListingDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
