// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ComplaintEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ComplaintEvent()';
}


}

/// @nodoc
class $ComplaintEventCopyWith<$Res>  {
$ComplaintEventCopyWith(ComplaintEvent _, $Res Function(ComplaintEvent) __);
}


/// Adds pattern-matching-related methods to [ComplaintEvent].
extension ComplaintEventPatterns on ComplaintEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _FetchComplaintCategories value)?  fetchComplaintCategories,TResult Function( _CreateComplaint value)?  createComplaint,TResult Function( _FetchUserComplaints value)?  fetchUserComplaints,TResult Function( _FetchListingComplaints value)?  fetchListingComplaints,TResult Function( _UpdateComplaintStatus value)?  updateComplaintStatus,TResult Function( _DeleteComplaint value)?  deleteComplaint,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FetchComplaintCategories() when fetchComplaintCategories != null:
return fetchComplaintCategories(_that);case _CreateComplaint() when createComplaint != null:
return createComplaint(_that);case _FetchUserComplaints() when fetchUserComplaints != null:
return fetchUserComplaints(_that);case _FetchListingComplaints() when fetchListingComplaints != null:
return fetchListingComplaints(_that);case _UpdateComplaintStatus() when updateComplaintStatus != null:
return updateComplaintStatus(_that);case _DeleteComplaint() when deleteComplaint != null:
return deleteComplaint(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _FetchComplaintCategories value)  fetchComplaintCategories,required TResult Function( _CreateComplaint value)  createComplaint,required TResult Function( _FetchUserComplaints value)  fetchUserComplaints,required TResult Function( _FetchListingComplaints value)  fetchListingComplaints,required TResult Function( _UpdateComplaintStatus value)  updateComplaintStatus,required TResult Function( _DeleteComplaint value)  deleteComplaint,}){
final _that = this;
switch (_that) {
case _FetchComplaintCategories():
return fetchComplaintCategories(_that);case _CreateComplaint():
return createComplaint(_that);case _FetchUserComplaints():
return fetchUserComplaints(_that);case _FetchListingComplaints():
return fetchListingComplaints(_that);case _UpdateComplaintStatus():
return updateComplaintStatus(_that);case _DeleteComplaint():
return deleteComplaint(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _FetchComplaintCategories value)?  fetchComplaintCategories,TResult? Function( _CreateComplaint value)?  createComplaint,TResult? Function( _FetchUserComplaints value)?  fetchUserComplaints,TResult? Function( _FetchListingComplaints value)?  fetchListingComplaints,TResult? Function( _UpdateComplaintStatus value)?  updateComplaintStatus,TResult? Function( _DeleteComplaint value)?  deleteComplaint,}){
final _that = this;
switch (_that) {
case _FetchComplaintCategories() when fetchComplaintCategories != null:
return fetchComplaintCategories(_that);case _CreateComplaint() when createComplaint != null:
return createComplaint(_that);case _FetchUserComplaints() when fetchUserComplaints != null:
return fetchUserComplaints(_that);case _FetchListingComplaints() when fetchListingComplaints != null:
return fetchListingComplaints(_that);case _UpdateComplaintStatus() when updateComplaintStatus != null:
return updateComplaintStatus(_that);case _DeleteComplaint() when deleteComplaint != null:
return deleteComplaint(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  fetchComplaintCategories,TResult Function( CreateComplaintRequest request)?  createComplaint,TResult Function( int userId)?  fetchUserComplaints,TResult Function( int listingId)?  fetchListingComplaints,TResult Function( int id,  String status)?  updateComplaintStatus,TResult Function( int id)?  deleteComplaint,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FetchComplaintCategories() when fetchComplaintCategories != null:
return fetchComplaintCategories();case _CreateComplaint() when createComplaint != null:
return createComplaint(_that.request);case _FetchUserComplaints() when fetchUserComplaints != null:
return fetchUserComplaints(_that.userId);case _FetchListingComplaints() when fetchListingComplaints != null:
return fetchListingComplaints(_that.listingId);case _UpdateComplaintStatus() when updateComplaintStatus != null:
return updateComplaintStatus(_that.id,_that.status);case _DeleteComplaint() when deleteComplaint != null:
return deleteComplaint(_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  fetchComplaintCategories,required TResult Function( CreateComplaintRequest request)  createComplaint,required TResult Function( int userId)  fetchUserComplaints,required TResult Function( int listingId)  fetchListingComplaints,required TResult Function( int id,  String status)  updateComplaintStatus,required TResult Function( int id)  deleteComplaint,}) {final _that = this;
switch (_that) {
case _FetchComplaintCategories():
return fetchComplaintCategories();case _CreateComplaint():
return createComplaint(_that.request);case _FetchUserComplaints():
return fetchUserComplaints(_that.userId);case _FetchListingComplaints():
return fetchListingComplaints(_that.listingId);case _UpdateComplaintStatus():
return updateComplaintStatus(_that.id,_that.status);case _DeleteComplaint():
return deleteComplaint(_that.id);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  fetchComplaintCategories,TResult? Function( CreateComplaintRequest request)?  createComplaint,TResult? Function( int userId)?  fetchUserComplaints,TResult? Function( int listingId)?  fetchListingComplaints,TResult? Function( int id,  String status)?  updateComplaintStatus,TResult? Function( int id)?  deleteComplaint,}) {final _that = this;
switch (_that) {
case _FetchComplaintCategories() when fetchComplaintCategories != null:
return fetchComplaintCategories();case _CreateComplaint() when createComplaint != null:
return createComplaint(_that.request);case _FetchUserComplaints() when fetchUserComplaints != null:
return fetchUserComplaints(_that.userId);case _FetchListingComplaints() when fetchListingComplaints != null:
return fetchListingComplaints(_that.listingId);case _UpdateComplaintStatus() when updateComplaintStatus != null:
return updateComplaintStatus(_that.id,_that.status);case _DeleteComplaint() when deleteComplaint != null:
return deleteComplaint(_that.id);case _:
  return null;

}
}

}

/// @nodoc


class _FetchComplaintCategories implements ComplaintEvent {
  const _FetchComplaintCategories();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchComplaintCategories);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ComplaintEvent.fetchComplaintCategories()';
}


}




/// @nodoc


class _CreateComplaint implements ComplaintEvent {
  const _CreateComplaint(this.request);
  

 final  CreateComplaintRequest request;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateComplaintCopyWith<_CreateComplaint> get copyWith => __$CreateComplaintCopyWithImpl<_CreateComplaint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateComplaint&&(identical(other.request, request) || other.request == request));
}


@override
int get hashCode => Object.hash(runtimeType,request);

@override
String toString() {
  return 'ComplaintEvent.createComplaint(request: $request)';
}


}

/// @nodoc
abstract mixin class _$CreateComplaintCopyWith<$Res> implements $ComplaintEventCopyWith<$Res> {
  factory _$CreateComplaintCopyWith(_CreateComplaint value, $Res Function(_CreateComplaint) _then) = __$CreateComplaintCopyWithImpl;
@useResult
$Res call({
 CreateComplaintRequest request
});


$CreateComplaintRequestCopyWith<$Res> get request;

}
/// @nodoc
class __$CreateComplaintCopyWithImpl<$Res>
    implements _$CreateComplaintCopyWith<$Res> {
  __$CreateComplaintCopyWithImpl(this._self, this._then);

  final _CreateComplaint _self;
  final $Res Function(_CreateComplaint) _then;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? request = null,}) {
  return _then(_CreateComplaint(
null == request ? _self.request : request // ignore: cast_nullable_to_non_nullable
as CreateComplaintRequest,
  ));
}

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CreateComplaintRequestCopyWith<$Res> get request {
  
  return $CreateComplaintRequestCopyWith<$Res>(_self.request, (value) {
    return _then(_self.copyWith(request: value));
  });
}
}

/// @nodoc


class _FetchUserComplaints implements ComplaintEvent {
  const _FetchUserComplaints(this.userId);
  

 final  int userId;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchUserComplaintsCopyWith<_FetchUserComplaints> get copyWith => __$FetchUserComplaintsCopyWithImpl<_FetchUserComplaints>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchUserComplaints&&(identical(other.userId, userId) || other.userId == userId));
}


@override
int get hashCode => Object.hash(runtimeType,userId);

@override
String toString() {
  return 'ComplaintEvent.fetchUserComplaints(userId: $userId)';
}


}

/// @nodoc
abstract mixin class _$FetchUserComplaintsCopyWith<$Res> implements $ComplaintEventCopyWith<$Res> {
  factory _$FetchUserComplaintsCopyWith(_FetchUserComplaints value, $Res Function(_FetchUserComplaints) _then) = __$FetchUserComplaintsCopyWithImpl;
@useResult
$Res call({
 int userId
});




}
/// @nodoc
class __$FetchUserComplaintsCopyWithImpl<$Res>
    implements _$FetchUserComplaintsCopyWith<$Res> {
  __$FetchUserComplaintsCopyWithImpl(this._self, this._then);

  final _FetchUserComplaints _self;
  final $Res Function(_FetchUserComplaints) _then;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userId = null,}) {
  return _then(_FetchUserComplaints(
null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _FetchListingComplaints implements ComplaintEvent {
  const _FetchListingComplaints(this.listingId);
  

 final  int listingId;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FetchListingComplaintsCopyWith<_FetchListingComplaints> get copyWith => __$FetchListingComplaintsCopyWithImpl<_FetchListingComplaints>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FetchListingComplaints&&(identical(other.listingId, listingId) || other.listingId == listingId));
}


@override
int get hashCode => Object.hash(runtimeType,listingId);

@override
String toString() {
  return 'ComplaintEvent.fetchListingComplaints(listingId: $listingId)';
}


}

/// @nodoc
abstract mixin class _$FetchListingComplaintsCopyWith<$Res> implements $ComplaintEventCopyWith<$Res> {
  factory _$FetchListingComplaintsCopyWith(_FetchListingComplaints value, $Res Function(_FetchListingComplaints) _then) = __$FetchListingComplaintsCopyWithImpl;
@useResult
$Res call({
 int listingId
});




}
/// @nodoc
class __$FetchListingComplaintsCopyWithImpl<$Res>
    implements _$FetchListingComplaintsCopyWith<$Res> {
  __$FetchListingComplaintsCopyWithImpl(this._self, this._then);

  final _FetchListingComplaints _self;
  final $Res Function(_FetchListingComplaints) _then;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? listingId = null,}) {
  return _then(_FetchListingComplaints(
null == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _UpdateComplaintStatus implements ComplaintEvent {
  const _UpdateComplaintStatus(this.id, this.status);
  

 final  int id;
 final  String status;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateComplaintStatusCopyWith<_UpdateComplaintStatus> get copyWith => __$UpdateComplaintStatusCopyWithImpl<_UpdateComplaintStatus>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateComplaintStatus&&(identical(other.id, id) || other.id == id)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,status);

@override
String toString() {
  return 'ComplaintEvent.updateComplaintStatus(id: $id, status: $status)';
}


}

/// @nodoc
abstract mixin class _$UpdateComplaintStatusCopyWith<$Res> implements $ComplaintEventCopyWith<$Res> {
  factory _$UpdateComplaintStatusCopyWith(_UpdateComplaintStatus value, $Res Function(_UpdateComplaintStatus) _then) = __$UpdateComplaintStatusCopyWithImpl;
@useResult
$Res call({
 int id, String status
});




}
/// @nodoc
class __$UpdateComplaintStatusCopyWithImpl<$Res>
    implements _$UpdateComplaintStatusCopyWith<$Res> {
  __$UpdateComplaintStatusCopyWithImpl(this._self, this._then);

  final _UpdateComplaintStatus _self;
  final $Res Function(_UpdateComplaintStatus) _then;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,Object? status = null,}) {
  return _then(_UpdateComplaintStatus(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _DeleteComplaint implements ComplaintEvent {
  const _DeleteComplaint(this.id);
  

 final  int id;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeleteComplaintCopyWith<_DeleteComplaint> get copyWith => __$DeleteComplaintCopyWithImpl<_DeleteComplaint>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeleteComplaint&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'ComplaintEvent.deleteComplaint(id: $id)';
}


}

/// @nodoc
abstract mixin class _$DeleteComplaintCopyWith<$Res> implements $ComplaintEventCopyWith<$Res> {
  factory _$DeleteComplaintCopyWith(_DeleteComplaint value, $Res Function(_DeleteComplaint) _then) = __$DeleteComplaintCopyWithImpl;
@useResult
$Res call({
 int id
});




}
/// @nodoc
class __$DeleteComplaintCopyWithImpl<$Res>
    implements _$DeleteComplaintCopyWith<$Res> {
  __$DeleteComplaintCopyWithImpl(this._self, this._then);

  final _DeleteComplaint _self;
  final $Res Function(_DeleteComplaint) _then;

/// Create a copy of ComplaintEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_DeleteComplaint(
null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ComplaintState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ComplaintState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ComplaintState()';
}


}

/// @nodoc
class $ComplaintStateCopyWith<$Res>  {
$ComplaintStateCopyWith(ComplaintState _, $Res Function(ComplaintState) __);
}


/// Adds pattern-matching-related methods to [ComplaintState].
extension ComplaintStatePatterns on ComplaintState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _CategoriesLoaded value)?  categoriesLoaded,TResult Function( _ComplaintCreated value)?  complaintCreated,TResult Function( _ComplaintsLoaded value)?  complaintsLoaded,TResult Function( _ComplaintUpdated value)?  complaintUpdated,TResult Function( _ComplaintDeleted value)?  complaintDeleted,TResult Function( _Error value)?  error,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _CategoriesLoaded() when categoriesLoaded != null:
return categoriesLoaded(_that);case _ComplaintCreated() when complaintCreated != null:
return complaintCreated(_that);case _ComplaintsLoaded() when complaintsLoaded != null:
return complaintsLoaded(_that);case _ComplaintUpdated() when complaintUpdated != null:
return complaintUpdated(_that);case _ComplaintDeleted() when complaintDeleted != null:
return complaintDeleted(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _CategoriesLoaded value)  categoriesLoaded,required TResult Function( _ComplaintCreated value)  complaintCreated,required TResult Function( _ComplaintsLoaded value)  complaintsLoaded,required TResult Function( _ComplaintUpdated value)  complaintUpdated,required TResult Function( _ComplaintDeleted value)  complaintDeleted,required TResult Function( _Error value)  error,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _CategoriesLoaded():
return categoriesLoaded(_that);case _ComplaintCreated():
return complaintCreated(_that);case _ComplaintsLoaded():
return complaintsLoaded(_that);case _ComplaintUpdated():
return complaintUpdated(_that);case _ComplaintDeleted():
return complaintDeleted(_that);case _Error():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _CategoriesLoaded value)?  categoriesLoaded,TResult? Function( _ComplaintCreated value)?  complaintCreated,TResult? Function( _ComplaintsLoaded value)?  complaintsLoaded,TResult? Function( _ComplaintUpdated value)?  complaintUpdated,TResult? Function( _ComplaintDeleted value)?  complaintDeleted,TResult? Function( _Error value)?  error,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _CategoriesLoaded() when categoriesLoaded != null:
return categoriesLoaded(_that);case _ComplaintCreated() when complaintCreated != null:
return complaintCreated(_that);case _ComplaintsLoaded() when complaintsLoaded != null:
return complaintsLoaded(_that);case _ComplaintUpdated() when complaintUpdated != null:
return complaintUpdated(_that);case _ComplaintDeleted() when complaintDeleted != null:
return complaintDeleted(_that);case _Error() when error != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<ComplaintCategory> categories)?  categoriesLoaded,TResult Function( Complaint complaint)?  complaintCreated,TResult Function( List<Complaint> complaints)?  complaintsLoaded,TResult Function( Complaint complaint)?  complaintUpdated,TResult Function( int id)?  complaintDeleted,TResult Function( String message)?  error,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _CategoriesLoaded() when categoriesLoaded != null:
return categoriesLoaded(_that.categories);case _ComplaintCreated() when complaintCreated != null:
return complaintCreated(_that.complaint);case _ComplaintsLoaded() when complaintsLoaded != null:
return complaintsLoaded(_that.complaints);case _ComplaintUpdated() when complaintUpdated != null:
return complaintUpdated(_that.complaint);case _ComplaintDeleted() when complaintDeleted != null:
return complaintDeleted(_that.id);case _Error() when error != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<ComplaintCategory> categories)  categoriesLoaded,required TResult Function( Complaint complaint)  complaintCreated,required TResult Function( List<Complaint> complaints)  complaintsLoaded,required TResult Function( Complaint complaint)  complaintUpdated,required TResult Function( int id)  complaintDeleted,required TResult Function( String message)  error,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _CategoriesLoaded():
return categoriesLoaded(_that.categories);case _ComplaintCreated():
return complaintCreated(_that.complaint);case _ComplaintsLoaded():
return complaintsLoaded(_that.complaints);case _ComplaintUpdated():
return complaintUpdated(_that.complaint);case _ComplaintDeleted():
return complaintDeleted(_that.id);case _Error():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<ComplaintCategory> categories)?  categoriesLoaded,TResult? Function( Complaint complaint)?  complaintCreated,TResult? Function( List<Complaint> complaints)?  complaintsLoaded,TResult? Function( Complaint complaint)?  complaintUpdated,TResult? Function( int id)?  complaintDeleted,TResult? Function( String message)?  error,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _CategoriesLoaded() when categoriesLoaded != null:
return categoriesLoaded(_that.categories);case _ComplaintCreated() when complaintCreated != null:
return complaintCreated(_that.complaint);case _ComplaintsLoaded() when complaintsLoaded != null:
return complaintsLoaded(_that.complaints);case _ComplaintUpdated() when complaintUpdated != null:
return complaintUpdated(_that.complaint);case _ComplaintDeleted() when complaintDeleted != null:
return complaintDeleted(_that.id);case _Error() when error != null:
return error(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements ComplaintState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ComplaintState.initial()';
}


}




/// @nodoc


class _Loading implements ComplaintState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ComplaintState.loading()';
}


}




/// @nodoc


class _CategoriesLoaded implements ComplaintState {
  const _CategoriesLoaded({required final  List<ComplaintCategory> categories}): _categories = categories;
  

 final  List<ComplaintCategory> _categories;
 List<ComplaintCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}


/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CategoriesLoadedCopyWith<_CategoriesLoaded> get copyWith => __$CategoriesLoadedCopyWithImpl<_CategoriesLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CategoriesLoaded&&const DeepCollectionEquality().equals(other._categories, _categories));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'ComplaintState.categoriesLoaded(categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$CategoriesLoadedCopyWith<$Res> implements $ComplaintStateCopyWith<$Res> {
  factory _$CategoriesLoadedCopyWith(_CategoriesLoaded value, $Res Function(_CategoriesLoaded) _then) = __$CategoriesLoadedCopyWithImpl;
@useResult
$Res call({
 List<ComplaintCategory> categories
});




}
/// @nodoc
class __$CategoriesLoadedCopyWithImpl<$Res>
    implements _$CategoriesLoadedCopyWith<$Res> {
  __$CategoriesLoadedCopyWithImpl(this._self, this._then);

  final _CategoriesLoaded _self;
  final $Res Function(_CategoriesLoaded) _then;

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? categories = null,}) {
  return _then(_CategoriesLoaded(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<ComplaintCategory>,
  ));
}


}

/// @nodoc


class _ComplaintCreated implements ComplaintState {
  const _ComplaintCreated({required this.complaint});
  

 final  Complaint complaint;

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintCreatedCopyWith<_ComplaintCreated> get copyWith => __$ComplaintCreatedCopyWithImpl<_ComplaintCreated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintCreated&&(identical(other.complaint, complaint) || other.complaint == complaint));
}


@override
int get hashCode => Object.hash(runtimeType,complaint);

@override
String toString() {
  return 'ComplaintState.complaintCreated(complaint: $complaint)';
}


}

/// @nodoc
abstract mixin class _$ComplaintCreatedCopyWith<$Res> implements $ComplaintStateCopyWith<$Res> {
  factory _$ComplaintCreatedCopyWith(_ComplaintCreated value, $Res Function(_ComplaintCreated) _then) = __$ComplaintCreatedCopyWithImpl;
@useResult
$Res call({
 Complaint complaint
});


$ComplaintCopyWith<$Res> get complaint;

}
/// @nodoc
class __$ComplaintCreatedCopyWithImpl<$Res>
    implements _$ComplaintCreatedCopyWith<$Res> {
  __$ComplaintCreatedCopyWithImpl(this._self, this._then);

  final _ComplaintCreated _self;
  final $Res Function(_ComplaintCreated) _then;

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? complaint = null,}) {
  return _then(_ComplaintCreated(
complaint: null == complaint ? _self.complaint : complaint // ignore: cast_nullable_to_non_nullable
as Complaint,
  ));
}

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintCopyWith<$Res> get complaint {
  
  return $ComplaintCopyWith<$Res>(_self.complaint, (value) {
    return _then(_self.copyWith(complaint: value));
  });
}
}

/// @nodoc


class _ComplaintsLoaded implements ComplaintState {
  const _ComplaintsLoaded({required final  List<Complaint> complaints}): _complaints = complaints;
  

 final  List<Complaint> _complaints;
 List<Complaint> get complaints {
  if (_complaints is EqualUnmodifiableListView) return _complaints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_complaints);
}


/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintsLoadedCopyWith<_ComplaintsLoaded> get copyWith => __$ComplaintsLoadedCopyWithImpl<_ComplaintsLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintsLoaded&&const DeepCollectionEquality().equals(other._complaints, _complaints));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_complaints));

@override
String toString() {
  return 'ComplaintState.complaintsLoaded(complaints: $complaints)';
}


}

/// @nodoc
abstract mixin class _$ComplaintsLoadedCopyWith<$Res> implements $ComplaintStateCopyWith<$Res> {
  factory _$ComplaintsLoadedCopyWith(_ComplaintsLoaded value, $Res Function(_ComplaintsLoaded) _then) = __$ComplaintsLoadedCopyWithImpl;
@useResult
$Res call({
 List<Complaint> complaints
});




}
/// @nodoc
class __$ComplaintsLoadedCopyWithImpl<$Res>
    implements _$ComplaintsLoadedCopyWith<$Res> {
  __$ComplaintsLoadedCopyWithImpl(this._self, this._then);

  final _ComplaintsLoaded _self;
  final $Res Function(_ComplaintsLoaded) _then;

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? complaints = null,}) {
  return _then(_ComplaintsLoaded(
complaints: null == complaints ? _self._complaints : complaints // ignore: cast_nullable_to_non_nullable
as List<Complaint>,
  ));
}


}

/// @nodoc


class _ComplaintUpdated implements ComplaintState {
  const _ComplaintUpdated({required this.complaint});
  

 final  Complaint complaint;

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintUpdatedCopyWith<_ComplaintUpdated> get copyWith => __$ComplaintUpdatedCopyWithImpl<_ComplaintUpdated>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintUpdated&&(identical(other.complaint, complaint) || other.complaint == complaint));
}


@override
int get hashCode => Object.hash(runtimeType,complaint);

@override
String toString() {
  return 'ComplaintState.complaintUpdated(complaint: $complaint)';
}


}

/// @nodoc
abstract mixin class _$ComplaintUpdatedCopyWith<$Res> implements $ComplaintStateCopyWith<$Res> {
  factory _$ComplaintUpdatedCopyWith(_ComplaintUpdated value, $Res Function(_ComplaintUpdated) _then) = __$ComplaintUpdatedCopyWithImpl;
@useResult
$Res call({
 Complaint complaint
});


$ComplaintCopyWith<$Res> get complaint;

}
/// @nodoc
class __$ComplaintUpdatedCopyWithImpl<$Res>
    implements _$ComplaintUpdatedCopyWith<$Res> {
  __$ComplaintUpdatedCopyWithImpl(this._self, this._then);

  final _ComplaintUpdated _self;
  final $Res Function(_ComplaintUpdated) _then;

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? complaint = null,}) {
  return _then(_ComplaintUpdated(
complaint: null == complaint ? _self.complaint : complaint // ignore: cast_nullable_to_non_nullable
as Complaint,
  ));
}

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ComplaintCopyWith<$Res> get complaint {
  
  return $ComplaintCopyWith<$Res>(_self.complaint, (value) {
    return _then(_self.copyWith(complaint: value));
  });
}
}

/// @nodoc


class _ComplaintDeleted implements ComplaintState {
  const _ComplaintDeleted({required this.id});
  

 final  int id;

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ComplaintDeletedCopyWith<_ComplaintDeleted> get copyWith => __$ComplaintDeletedCopyWithImpl<_ComplaintDeleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ComplaintDeleted&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString() {
  return 'ComplaintState.complaintDeleted(id: $id)';
}


}

/// @nodoc
abstract mixin class _$ComplaintDeletedCopyWith<$Res> implements $ComplaintStateCopyWith<$Res> {
  factory _$ComplaintDeletedCopyWith(_ComplaintDeleted value, $Res Function(_ComplaintDeleted) _then) = __$ComplaintDeletedCopyWithImpl;
@useResult
$Res call({
 int id
});




}
/// @nodoc
class __$ComplaintDeletedCopyWithImpl<$Res>
    implements _$ComplaintDeletedCopyWith<$Res> {
  __$ComplaintDeletedCopyWithImpl(this._self, this._then);

  final _ComplaintDeleted _self;
  final $Res Function(_ComplaintDeleted) _then;

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(_ComplaintDeleted(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Error implements ComplaintState {
  const _Error({required this.message});
  

 final  String message;

/// Create a copy of ComplaintState
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
  return 'ComplaintState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $ComplaintStateCopyWith<$Res> {
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

/// Create a copy of ComplaintState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
