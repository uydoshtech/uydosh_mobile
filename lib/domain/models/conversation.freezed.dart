// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Conversation {

 int get id;@JsonKey(name: "initiator_id") int get initiatorId;@JsonKey(name: "participant_id") int get participantId;@JsonKey(name: "is_active") bool get isActive;@JsonKey(name: "created_at") String get createdAt;@JsonKey(name: "updated_at") String get updatedAt;// Nullable since the gig-module conversations (`context_type` =
// `gig_request` / `gig_offer` / `gig_booking`) don't carry a listing.
// Legacy listing chats keep `listing_id` populated alongside
// `context_type='listing'` for back-compat with grouped views.
@JsonKey(name: "listing_id") int? get listingId;@JsonKey(name: "context_type") String? get contextType;@JsonKey(name: "context_id") int? get contextId;@JsonKey(name: "gig_request_id") int? get gigRequestId;@JsonKey(name: "gig_request_title") String? get gigRequestTitle;@JsonKey(name: "last_message_at") String? get lastMessageAt;@JsonKey(name: "last_message_content") String? get lastMessageContent;@JsonKey(name: "last_message_sender_id") int? get lastMessageSenderId;@JsonKey(name: "archived_at") String? get archivedAt;// Related data
 Listing? get listing; UserProfile? get otherUser;@JsonKey(name: "unread_count") int? get unreadCount;
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCopyWith<Conversation> get copyWith => _$ConversationCopyWithImpl<Conversation>(this as Conversation, _$identity);

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.initiatorId, initiatorId) || other.initiatorId == initiatorId)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.contextType, contextType) || other.contextType == contextType)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.gigRequestId, gigRequestId) || other.gigRequestId == gigRequestId)&&(identical(other.gigRequestTitle, gigRequestTitle) || other.gigRequestTitle == gigRequestTitle)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.listing, listing) || other.listing == listing)&&(identical(other.otherUser, otherUser) || other.otherUser == otherUser)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,initiatorId,participantId,isActive,createdAt,updatedAt,listingId,contextType,contextId,gigRequestId,gigRequestTitle,lastMessageAt,lastMessageContent,lastMessageSenderId,archivedAt,listing,otherUser,unreadCount);

@override
String toString() {
  return 'Conversation(id: $id, initiatorId: $initiatorId, participantId: $participantId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, listingId: $listingId, contextType: $contextType, contextId: $contextId, gigRequestId: $gigRequestId, gigRequestTitle: $gigRequestTitle, lastMessageAt: $lastMessageAt, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, archivedAt: $archivedAt, listing: $listing, otherUser: $otherUser, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $ConversationCopyWith<$Res>  {
  factory $ConversationCopyWith(Conversation value, $Res Function(Conversation) _then) = _$ConversationCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "initiator_id") int initiatorId,@JsonKey(name: "participant_id") int participantId,@JsonKey(name: "is_active") bool isActive,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "listing_id") int? listingId,@JsonKey(name: "context_type") String? contextType,@JsonKey(name: "context_id") int? contextId,@JsonKey(name: "gig_request_id") int? gigRequestId,@JsonKey(name: "gig_request_title") String? gigRequestTitle,@JsonKey(name: "last_message_at") String? lastMessageAt,@JsonKey(name: "last_message_content") String? lastMessageContent,@JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,@JsonKey(name: "archived_at") String? archivedAt, Listing? listing, UserProfile? otherUser,@JsonKey(name: "unread_count") int? unreadCount
});


$ListingCopyWith<$Res>? get listing;$UserProfileCopyWith<$Res>? get otherUser;

}
/// @nodoc
class _$ConversationCopyWithImpl<$Res>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._self, this._then);

  final Conversation _self;
  final $Res Function(Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? initiatorId = null,Object? participantId = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? listingId = freezed,Object? contextType = freezed,Object? contextId = freezed,Object? gigRequestId = freezed,Object? gigRequestTitle = freezed,Object? lastMessageAt = freezed,Object? lastMessageContent = freezed,Object? lastMessageSenderId = freezed,Object? archivedAt = freezed,Object? listing = freezed,Object? otherUser = freezed,Object? unreadCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,initiatorId: null == initiatorId ? _self.initiatorId : initiatorId // ignore: cast_nullable_to_non_nullable
as int,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int?,contextType: freezed == contextType ? _self.contextType : contextType // ignore: cast_nullable_to_non_nullable
as String?,contextId: freezed == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as int?,gigRequestId: freezed == gigRequestId ? _self.gigRequestId : gigRequestId // ignore: cast_nullable_to_non_nullable
as int?,gigRequestTitle: freezed == gigRequestTitle ? _self.gigRequestTitle : gigRequestTitle // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,lastMessageContent: freezed == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as int?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as String?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as Listing?,otherUser: freezed == otherUser ? _self.otherUser : otherUser // ignore: cast_nullable_to_non_nullable
as UserProfile?,unreadCount: freezed == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $ListingCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get otherUser {
    if (_self.otherUser == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.otherUser!, (value) {
    return _then(_self.copyWith(otherUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [Conversation].
extension ConversationPatterns on Conversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Conversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Conversation value)  $default,){
final _that = this;
switch (_that) {
case _Conversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Conversation value)?  $default,){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "initiator_id")  int initiatorId, @JsonKey(name: "participant_id")  int participantId, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "context_type")  String? contextType, @JsonKey(name: "context_id")  int? contextId, @JsonKey(name: "gig_request_id")  int? gigRequestId, @JsonKey(name: "gig_request_title")  String? gigRequestTitle, @JsonKey(name: "last_message_at")  String? lastMessageAt, @JsonKey(name: "last_message_content")  String? lastMessageContent, @JsonKey(name: "last_message_sender_id")  int? lastMessageSenderId, @JsonKey(name: "archived_at")  String? archivedAt,  Listing? listing,  UserProfile? otherUser, @JsonKey(name: "unread_count")  int? unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.initiatorId,_that.participantId,_that.isActive,_that.createdAt,_that.updatedAt,_that.listingId,_that.contextType,_that.contextId,_that.gigRequestId,_that.gigRequestTitle,_that.lastMessageAt,_that.lastMessageContent,_that.lastMessageSenderId,_that.archivedAt,_that.listing,_that.otherUser,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "initiator_id")  int initiatorId, @JsonKey(name: "participant_id")  int participantId, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "context_type")  String? contextType, @JsonKey(name: "context_id")  int? contextId, @JsonKey(name: "gig_request_id")  int? gigRequestId, @JsonKey(name: "gig_request_title")  String? gigRequestTitle, @JsonKey(name: "last_message_at")  String? lastMessageAt, @JsonKey(name: "last_message_content")  String? lastMessageContent, @JsonKey(name: "last_message_sender_id")  int? lastMessageSenderId, @JsonKey(name: "archived_at")  String? archivedAt,  Listing? listing,  UserProfile? otherUser, @JsonKey(name: "unread_count")  int? unreadCount)  $default,) {final _that = this;
switch (_that) {
case _Conversation():
return $default(_that.id,_that.initiatorId,_that.participantId,_that.isActive,_that.createdAt,_that.updatedAt,_that.listingId,_that.contextType,_that.contextId,_that.gigRequestId,_that.gigRequestTitle,_that.lastMessageAt,_that.lastMessageContent,_that.lastMessageSenderId,_that.archivedAt,_that.listing,_that.otherUser,_that.unreadCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "initiator_id")  int initiatorId, @JsonKey(name: "participant_id")  int participantId, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "context_type")  String? contextType, @JsonKey(name: "context_id")  int? contextId, @JsonKey(name: "gig_request_id")  int? gigRequestId, @JsonKey(name: "gig_request_title")  String? gigRequestTitle, @JsonKey(name: "last_message_at")  String? lastMessageAt, @JsonKey(name: "last_message_content")  String? lastMessageContent, @JsonKey(name: "last_message_sender_id")  int? lastMessageSenderId, @JsonKey(name: "archived_at")  String? archivedAt,  Listing? listing,  UserProfile? otherUser, @JsonKey(name: "unread_count")  int? unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.initiatorId,_that.participantId,_that.isActive,_that.createdAt,_that.updatedAt,_that.listingId,_that.contextType,_that.contextId,_that.gigRequestId,_that.gigRequestTitle,_that.lastMessageAt,_that.lastMessageContent,_that.lastMessageSenderId,_that.archivedAt,_that.listing,_that.otherUser,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Conversation implements Conversation {
  const _Conversation({required this.id, @JsonKey(name: "initiator_id") required this.initiatorId, @JsonKey(name: "participant_id") required this.participantId, @JsonKey(name: "is_active") required this.isActive, @JsonKey(name: "created_at") required this.createdAt, @JsonKey(name: "updated_at") required this.updatedAt, @JsonKey(name: "listing_id") this.listingId, @JsonKey(name: "context_type") this.contextType, @JsonKey(name: "context_id") this.contextId, @JsonKey(name: "gig_request_id") this.gigRequestId, @JsonKey(name: "gig_request_title") this.gigRequestTitle, @JsonKey(name: "last_message_at") this.lastMessageAt, @JsonKey(name: "last_message_content") this.lastMessageContent, @JsonKey(name: "last_message_sender_id") this.lastMessageSenderId, @JsonKey(name: "archived_at") this.archivedAt, this.listing, this.otherUser, @JsonKey(name: "unread_count") this.unreadCount});
  factory _Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);

@override final  int id;
@override@JsonKey(name: "initiator_id") final  int initiatorId;
@override@JsonKey(name: "participant_id") final  int participantId;
@override@JsonKey(name: "is_active") final  bool isActive;
@override@JsonKey(name: "created_at") final  String createdAt;
@override@JsonKey(name: "updated_at") final  String updatedAt;
// Nullable since the gig-module conversations (`context_type` =
// `gig_request` / `gig_offer` / `gig_booking`) don't carry a listing.
// Legacy listing chats keep `listing_id` populated alongside
// `context_type='listing'` for back-compat with grouped views.
@override@JsonKey(name: "listing_id") final  int? listingId;
@override@JsonKey(name: "context_type") final  String? contextType;
@override@JsonKey(name: "context_id") final  int? contextId;
@override@JsonKey(name: "gig_request_id") final  int? gigRequestId;
@override@JsonKey(name: "gig_request_title") final  String? gigRequestTitle;
@override@JsonKey(name: "last_message_at") final  String? lastMessageAt;
@override@JsonKey(name: "last_message_content") final  String? lastMessageContent;
@override@JsonKey(name: "last_message_sender_id") final  int? lastMessageSenderId;
@override@JsonKey(name: "archived_at") final  String? archivedAt;
// Related data
@override final  Listing? listing;
@override final  UserProfile? otherUser;
@override@JsonKey(name: "unread_count") final  int? unreadCount;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCopyWith<_Conversation> get copyWith => __$ConversationCopyWithImpl<_Conversation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.initiatorId, initiatorId) || other.initiatorId == initiatorId)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.contextType, contextType) || other.contextType == contextType)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.gigRequestId, gigRequestId) || other.gigRequestId == gigRequestId)&&(identical(other.gigRequestTitle, gigRequestTitle) || other.gigRequestTitle == gigRequestTitle)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.listing, listing) || other.listing == listing)&&(identical(other.otherUser, otherUser) || other.otherUser == otherUser)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,initiatorId,participantId,isActive,createdAt,updatedAt,listingId,contextType,contextId,gigRequestId,gigRequestTitle,lastMessageAt,lastMessageContent,lastMessageSenderId,archivedAt,listing,otherUser,unreadCount);

@override
String toString() {
  return 'Conversation(id: $id, initiatorId: $initiatorId, participantId: $participantId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, listingId: $listingId, contextType: $contextType, contextId: $contextId, gigRequestId: $gigRequestId, gigRequestTitle: $gigRequestTitle, lastMessageAt: $lastMessageAt, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, archivedAt: $archivedAt, listing: $listing, otherUser: $otherUser, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$ConversationCopyWith<$Res> implements $ConversationCopyWith<$Res> {
  factory _$ConversationCopyWith(_Conversation value, $Res Function(_Conversation) _then) = __$ConversationCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "initiator_id") int initiatorId,@JsonKey(name: "participant_id") int participantId,@JsonKey(name: "is_active") bool isActive,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "listing_id") int? listingId,@JsonKey(name: "context_type") String? contextType,@JsonKey(name: "context_id") int? contextId,@JsonKey(name: "gig_request_id") int? gigRequestId,@JsonKey(name: "gig_request_title") String? gigRequestTitle,@JsonKey(name: "last_message_at") String? lastMessageAt,@JsonKey(name: "last_message_content") String? lastMessageContent,@JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,@JsonKey(name: "archived_at") String? archivedAt, Listing? listing, UserProfile? otherUser,@JsonKey(name: "unread_count") int? unreadCount
});


@override $ListingCopyWith<$Res>? get listing;@override $UserProfileCopyWith<$Res>? get otherUser;

}
/// @nodoc
class __$ConversationCopyWithImpl<$Res>
    implements _$ConversationCopyWith<$Res> {
  __$ConversationCopyWithImpl(this._self, this._then);

  final _Conversation _self;
  final $Res Function(_Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? initiatorId = null,Object? participantId = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? listingId = freezed,Object? contextType = freezed,Object? contextId = freezed,Object? gigRequestId = freezed,Object? gigRequestTitle = freezed,Object? lastMessageAt = freezed,Object? lastMessageContent = freezed,Object? lastMessageSenderId = freezed,Object? archivedAt = freezed,Object? listing = freezed,Object? otherUser = freezed,Object? unreadCount = freezed,}) {
  return _then(_Conversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,initiatorId: null == initiatorId ? _self.initiatorId : initiatorId // ignore: cast_nullable_to_non_nullable
as int,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int?,contextType: freezed == contextType ? _self.contextType : contextType // ignore: cast_nullable_to_non_nullable
as String?,contextId: freezed == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as int?,gigRequestId: freezed == gigRequestId ? _self.gigRequestId : gigRequestId // ignore: cast_nullable_to_non_nullable
as int?,gigRequestTitle: freezed == gigRequestTitle ? _self.gigRequestTitle : gigRequestTitle // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,lastMessageContent: freezed == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as int?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as String?,listing: freezed == listing ? _self.listing : listing // ignore: cast_nullable_to_non_nullable
as Listing?,otherUser: freezed == otherUser ? _self.otherUser : otherUser // ignore: cast_nullable_to_non_nullable
as UserProfile?,unreadCount: freezed == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListingCopyWith<$Res>? get listing {
    if (_self.listing == null) {
    return null;
  }

  return $ListingCopyWith<$Res>(_self.listing!, (value) {
    return _then(_self.copyWith(listing: value));
  });
}/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserProfileCopyWith<$Res>? get otherUser {
    if (_self.otherUser == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.otherUser!, (value) {
    return _then(_self.copyWith(otherUser: value));
  });
}
}


/// @nodoc
mixin _$ConversationSummary {

 int get id;@JsonKey(name: "initiator_id") int get initiatorId;@JsonKey(name: "participant_id") int get participantId;@JsonKey(name: "is_active") bool get isActive;@JsonKey(name: "created_at") String get createdAt;@JsonKey(name: "updated_at") String get updatedAt;@JsonKey(name: "listing_id") int? get listingId;@JsonKey(name: "context_type") String? get contextType;@JsonKey(name: "context_id") int? get contextId;@JsonKey(name: "gig_request_id") int? get gigRequestId;@JsonKey(name: "gig_request_title") String? get gigRequestTitle;/// Gig category id (`gig_categories.id`) for gig-scoped chats.
@JsonKey(name: "gig_category_id") int? get gigCategoryId;/// Budget / pricing type from the gig surface (`open`, `hourly`, etc.).
@JsonKey(name: "gig_budget_type") String? get gigBudgetType;@JsonKey(name: "last_message_at") String? get lastMessageAt;@JsonKey(name: "last_message_content") String? get lastMessageContent;@JsonKey(name: "last_message_sender_id") int? get lastMessageSenderId;@JsonKey(name: "archived_at") String? get archivedAt;// Summary data
@JsonKey(name: "listing_title") String? get listingTitle;@JsonKey(name: "listing_type_id") int? get listingTypeId;@JsonKey(name: "listing_gender") int? get listingGender;@JsonKey(name: "listing_price") int? get listingPrice;/// When set (e.g. gig-request chats), [ConversationPriceDisplay] shows this currency instead of y.e.
@JsonKey(name: "price_currency_code") String? get priceCurrencyCode;@JsonKey(name: "conversation_type") String? get conversationType;@JsonKey(name: "other_user_name") String? get otherUserName;@JsonKey(name: "other_user_avatar") String? get otherUserAvatar;/// Group-chat (`listing_group`) member previews for overlapping inbox
/// avatars. Empty for direct/listing/gig chats.
@JsonKey(name: "members") List<ConversationMemberSummary> get members;/// Gig row author: task client for `gig_request`, provider for `gig_offer` / `gig_booking`.
@JsonKey(name: "gig_owner_name") String? get gigOwnerName;@JsonKey(name: "gig_owner_avatar") String? get gigOwnerAvatar;@JsonKey(name: "unread_count") int? get unreadCount;// Location and metro station data
@JsonKey(name: "listing_subway_line_id") int? get listingSubwayLineId;@JsonKey(name: "listing_subway_station_id") int? get listingSubwayStationId;@JsonKey(name: "listing_location_id") int? get listingLocationId;@JsonKey(name: "subway_station_name_uz") String? get subwayStationNameUz;@JsonKey(name: "subway_station_name_ru") String? get subwayStationNameRu;@JsonKey(name: "subway_station_name_en") String? get subwayStationNameEn;@JsonKey(name: "subway_station_line") int? get subwayStationLine;@JsonKey(name: "subway_station_ordinal") int? get subwayStationOrdinal;@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? get searchSubwayStations;@JsonKey(name: "location_name_uz") String? get locationNameUz;@JsonKey(name: "location_name_ru") String? get locationNameRu;@JsonKey(name: "location_name_en") String? get locationNameEn;@JsonKey(name: "location_short_name_uz") String? get locationShortNameUz;@JsonKey(name: "location_short_name_ru") String? get locationShortNameRu;@JsonKey(name: "location_short_name_en") String? get locationShortNameEn;@JsonKey(name: "search_locations") List<LocationDetail>? get searchLocations;
/// Create a copy of ConversationSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationSummaryCopyWith<ConversationSummary> get copyWith => _$ConversationSummaryCopyWithImpl<ConversationSummary>(this as ConversationSummary, _$identity);

  /// Serializes this ConversationSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.initiatorId, initiatorId) || other.initiatorId == initiatorId)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.contextType, contextType) || other.contextType == contextType)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.gigRequestId, gigRequestId) || other.gigRequestId == gigRequestId)&&(identical(other.gigRequestTitle, gigRequestTitle) || other.gigRequestTitle == gigRequestTitle)&&(identical(other.gigCategoryId, gigCategoryId) || other.gigCategoryId == gigCategoryId)&&(identical(other.gigBudgetType, gigBudgetType) || other.gigBudgetType == gigBudgetType)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.listingTitle, listingTitle) || other.listingTitle == listingTitle)&&(identical(other.listingTypeId, listingTypeId) || other.listingTypeId == listingTypeId)&&(identical(other.listingGender, listingGender) || other.listingGender == listingGender)&&(identical(other.listingPrice, listingPrice) || other.listingPrice == listingPrice)&&(identical(other.priceCurrencyCode, priceCurrencyCode) || other.priceCurrencyCode == priceCurrencyCode)&&(identical(other.conversationType, conversationType) || other.conversationType == conversationType)&&(identical(other.otherUserName, otherUserName) || other.otherUserName == otherUserName)&&(identical(other.otherUserAvatar, otherUserAvatar) || other.otherUserAvatar == otherUserAvatar)&&const DeepCollectionEquality().equals(other.members, members)&&(identical(other.gigOwnerName, gigOwnerName) || other.gigOwnerName == gigOwnerName)&&(identical(other.gigOwnerAvatar, gigOwnerAvatar) || other.gigOwnerAvatar == gigOwnerAvatar)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.listingSubwayLineId, listingSubwayLineId) || other.listingSubwayLineId == listingSubwayLineId)&&(identical(other.listingSubwayStationId, listingSubwayStationId) || other.listingSubwayStationId == listingSubwayStationId)&&(identical(other.listingLocationId, listingLocationId) || other.listingLocationId == listingLocationId)&&(identical(other.subwayStationNameUz, subwayStationNameUz) || other.subwayStationNameUz == subwayStationNameUz)&&(identical(other.subwayStationNameRu, subwayStationNameRu) || other.subwayStationNameRu == subwayStationNameRu)&&(identical(other.subwayStationNameEn, subwayStationNameEn) || other.subwayStationNameEn == subwayStationNameEn)&&(identical(other.subwayStationLine, subwayStationLine) || other.subwayStationLine == subwayStationLine)&&(identical(other.subwayStationOrdinal, subwayStationOrdinal) || other.subwayStationOrdinal == subwayStationOrdinal)&&const DeepCollectionEquality().equals(other.searchSubwayStations, searchSubwayStations)&&(identical(other.locationNameUz, locationNameUz) || other.locationNameUz == locationNameUz)&&(identical(other.locationNameRu, locationNameRu) || other.locationNameRu == locationNameRu)&&(identical(other.locationNameEn, locationNameEn) || other.locationNameEn == locationNameEn)&&(identical(other.locationShortNameUz, locationShortNameUz) || other.locationShortNameUz == locationShortNameUz)&&(identical(other.locationShortNameRu, locationShortNameRu) || other.locationShortNameRu == locationShortNameRu)&&(identical(other.locationShortNameEn, locationShortNameEn) || other.locationShortNameEn == locationShortNameEn)&&const DeepCollectionEquality().equals(other.searchLocations, searchLocations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,initiatorId,participantId,isActive,createdAt,updatedAt,listingId,contextType,contextId,gigRequestId,gigRequestTitle,gigCategoryId,gigBudgetType,lastMessageAt,lastMessageContent,lastMessageSenderId,archivedAt,listingTitle,listingTypeId,listingGender,listingPrice,priceCurrencyCode,conversationType,otherUserName,otherUserAvatar,const DeepCollectionEquality().hash(members),gigOwnerName,gigOwnerAvatar,unreadCount,listingSubwayLineId,listingSubwayStationId,listingLocationId,subwayStationNameUz,subwayStationNameRu,subwayStationNameEn,subwayStationLine,subwayStationOrdinal,const DeepCollectionEquality().hash(searchSubwayStations),locationNameUz,locationNameRu,locationNameEn,locationShortNameUz,locationShortNameRu,locationShortNameEn,const DeepCollectionEquality().hash(searchLocations)]);

@override
String toString() {
  return 'ConversationSummary(id: $id, initiatorId: $initiatorId, participantId: $participantId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, listingId: $listingId, contextType: $contextType, contextId: $contextId, gigRequestId: $gigRequestId, gigRequestTitle: $gigRequestTitle, gigCategoryId: $gigCategoryId, gigBudgetType: $gigBudgetType, lastMessageAt: $lastMessageAt, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, archivedAt: $archivedAt, listingTitle: $listingTitle, listingTypeId: $listingTypeId, listingGender: $listingGender, listingPrice: $listingPrice, priceCurrencyCode: $priceCurrencyCode, conversationType: $conversationType, otherUserName: $otherUserName, otherUserAvatar: $otherUserAvatar, members: $members, gigOwnerName: $gigOwnerName, gigOwnerAvatar: $gigOwnerAvatar, unreadCount: $unreadCount, listingSubwayLineId: $listingSubwayLineId, listingSubwayStationId: $listingSubwayStationId, listingLocationId: $listingLocationId, subwayStationNameUz: $subwayStationNameUz, subwayStationNameRu: $subwayStationNameRu, subwayStationNameEn: $subwayStationNameEn, subwayStationLine: $subwayStationLine, subwayStationOrdinal: $subwayStationOrdinal, searchSubwayStations: $searchSubwayStations, locationNameUz: $locationNameUz, locationNameRu: $locationNameRu, locationNameEn: $locationNameEn, locationShortNameUz: $locationShortNameUz, locationShortNameRu: $locationShortNameRu, locationShortNameEn: $locationShortNameEn, searchLocations: $searchLocations)';
}


}

/// @nodoc
abstract mixin class $ConversationSummaryCopyWith<$Res>  {
  factory $ConversationSummaryCopyWith(ConversationSummary value, $Res Function(ConversationSummary) _then) = _$ConversationSummaryCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "initiator_id") int initiatorId,@JsonKey(name: "participant_id") int participantId,@JsonKey(name: "is_active") bool isActive,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "listing_id") int? listingId,@JsonKey(name: "context_type") String? contextType,@JsonKey(name: "context_id") int? contextId,@JsonKey(name: "gig_request_id") int? gigRequestId,@JsonKey(name: "gig_request_title") String? gigRequestTitle,@JsonKey(name: "gig_category_id") int? gigCategoryId,@JsonKey(name: "gig_budget_type") String? gigBudgetType,@JsonKey(name: "last_message_at") String? lastMessageAt,@JsonKey(name: "last_message_content") String? lastMessageContent,@JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,@JsonKey(name: "archived_at") String? archivedAt,@JsonKey(name: "listing_title") String? listingTitle,@JsonKey(name: "listing_type_id") int? listingTypeId,@JsonKey(name: "listing_gender") int? listingGender,@JsonKey(name: "listing_price") int? listingPrice,@JsonKey(name: "price_currency_code") String? priceCurrencyCode,@JsonKey(name: "conversation_type") String? conversationType,@JsonKey(name: "other_user_name") String? otherUserName,@JsonKey(name: "other_user_avatar") String? otherUserAvatar,@JsonKey(name: "members") List<ConversationMemberSummary> members,@JsonKey(name: "gig_owner_name") String? gigOwnerName,@JsonKey(name: "gig_owner_avatar") String? gigOwnerAvatar,@JsonKey(name: "unread_count") int? unreadCount,@JsonKey(name: "listing_subway_line_id") int? listingSubwayLineId,@JsonKey(name: "listing_subway_station_id") int? listingSubwayStationId,@JsonKey(name: "listing_location_id") int? listingLocationId,@JsonKey(name: "subway_station_name_uz") String? subwayStationNameUz,@JsonKey(name: "subway_station_name_ru") String? subwayStationNameRu,@JsonKey(name: "subway_station_name_en") String? subwayStationNameEn,@JsonKey(name: "subway_station_line") int? subwayStationLine,@JsonKey(name: "subway_station_ordinal") int? subwayStationOrdinal,@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? searchSubwayStations,@JsonKey(name: "location_name_uz") String? locationNameUz,@JsonKey(name: "location_name_ru") String? locationNameRu,@JsonKey(name: "location_name_en") String? locationNameEn,@JsonKey(name: "location_short_name_uz") String? locationShortNameUz,@JsonKey(name: "location_short_name_ru") String? locationShortNameRu,@JsonKey(name: "location_short_name_en") String? locationShortNameEn,@JsonKey(name: "search_locations") List<LocationDetail>? searchLocations
});




}
/// @nodoc
class _$ConversationSummaryCopyWithImpl<$Res>
    implements $ConversationSummaryCopyWith<$Res> {
  _$ConversationSummaryCopyWithImpl(this._self, this._then);

  final ConversationSummary _self;
  final $Res Function(ConversationSummary) _then;

/// Create a copy of ConversationSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? initiatorId = null,Object? participantId = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? listingId = freezed,Object? contextType = freezed,Object? contextId = freezed,Object? gigRequestId = freezed,Object? gigRequestTitle = freezed,Object? gigCategoryId = freezed,Object? gigBudgetType = freezed,Object? lastMessageAt = freezed,Object? lastMessageContent = freezed,Object? lastMessageSenderId = freezed,Object? archivedAt = freezed,Object? listingTitle = freezed,Object? listingTypeId = freezed,Object? listingGender = freezed,Object? listingPrice = freezed,Object? priceCurrencyCode = freezed,Object? conversationType = freezed,Object? otherUserName = freezed,Object? otherUserAvatar = freezed,Object? members = null,Object? gigOwnerName = freezed,Object? gigOwnerAvatar = freezed,Object? unreadCount = freezed,Object? listingSubwayLineId = freezed,Object? listingSubwayStationId = freezed,Object? listingLocationId = freezed,Object? subwayStationNameUz = freezed,Object? subwayStationNameRu = freezed,Object? subwayStationNameEn = freezed,Object? subwayStationLine = freezed,Object? subwayStationOrdinal = freezed,Object? searchSubwayStations = freezed,Object? locationNameUz = freezed,Object? locationNameRu = freezed,Object? locationNameEn = freezed,Object? locationShortNameUz = freezed,Object? locationShortNameRu = freezed,Object? locationShortNameEn = freezed,Object? searchLocations = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,initiatorId: null == initiatorId ? _self.initiatorId : initiatorId // ignore: cast_nullable_to_non_nullable
as int,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int?,contextType: freezed == contextType ? _self.contextType : contextType // ignore: cast_nullable_to_non_nullable
as String?,contextId: freezed == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as int?,gigRequestId: freezed == gigRequestId ? _self.gigRequestId : gigRequestId // ignore: cast_nullable_to_non_nullable
as int?,gigRequestTitle: freezed == gigRequestTitle ? _self.gigRequestTitle : gigRequestTitle // ignore: cast_nullable_to_non_nullable
as String?,gigCategoryId: freezed == gigCategoryId ? _self.gigCategoryId : gigCategoryId // ignore: cast_nullable_to_non_nullable
as int?,gigBudgetType: freezed == gigBudgetType ? _self.gigBudgetType : gigBudgetType // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,lastMessageContent: freezed == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as int?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as String?,listingTitle: freezed == listingTitle ? _self.listingTitle : listingTitle // ignore: cast_nullable_to_non_nullable
as String?,listingTypeId: freezed == listingTypeId ? _self.listingTypeId : listingTypeId // ignore: cast_nullable_to_non_nullable
as int?,listingGender: freezed == listingGender ? _self.listingGender : listingGender // ignore: cast_nullable_to_non_nullable
as int?,listingPrice: freezed == listingPrice ? _self.listingPrice : listingPrice // ignore: cast_nullable_to_non_nullable
as int?,priceCurrencyCode: freezed == priceCurrencyCode ? _self.priceCurrencyCode : priceCurrencyCode // ignore: cast_nullable_to_non_nullable
as String?,conversationType: freezed == conversationType ? _self.conversationType : conversationType // ignore: cast_nullable_to_non_nullable
as String?,otherUserName: freezed == otherUserName ? _self.otherUserName : otherUserName // ignore: cast_nullable_to_non_nullable
as String?,otherUserAvatar: freezed == otherUserAvatar ? _self.otherUserAvatar : otherUserAvatar // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self.members : members // ignore: cast_nullable_to_non_nullable
as List<ConversationMemberSummary>,gigOwnerName: freezed == gigOwnerName ? _self.gigOwnerName : gigOwnerName // ignore: cast_nullable_to_non_nullable
as String?,gigOwnerAvatar: freezed == gigOwnerAvatar ? _self.gigOwnerAvatar : gigOwnerAvatar // ignore: cast_nullable_to_non_nullable
as String?,unreadCount: freezed == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int?,listingSubwayLineId: freezed == listingSubwayLineId ? _self.listingSubwayLineId : listingSubwayLineId // ignore: cast_nullable_to_non_nullable
as int?,listingSubwayStationId: freezed == listingSubwayStationId ? _self.listingSubwayStationId : listingSubwayStationId // ignore: cast_nullable_to_non_nullable
as int?,listingLocationId: freezed == listingLocationId ? _self.listingLocationId : listingLocationId // ignore: cast_nullable_to_non_nullable
as int?,subwayStationNameUz: freezed == subwayStationNameUz ? _self.subwayStationNameUz : subwayStationNameUz // ignore: cast_nullable_to_non_nullable
as String?,subwayStationNameRu: freezed == subwayStationNameRu ? _self.subwayStationNameRu : subwayStationNameRu // ignore: cast_nullable_to_non_nullable
as String?,subwayStationNameEn: freezed == subwayStationNameEn ? _self.subwayStationNameEn : subwayStationNameEn // ignore: cast_nullable_to_non_nullable
as String?,subwayStationLine: freezed == subwayStationLine ? _self.subwayStationLine : subwayStationLine // ignore: cast_nullable_to_non_nullable
as int?,subwayStationOrdinal: freezed == subwayStationOrdinal ? _self.subwayStationOrdinal : subwayStationOrdinal // ignore: cast_nullable_to_non_nullable
as int?,searchSubwayStations: freezed == searchSubwayStations ? _self.searchSubwayStations : searchSubwayStations // ignore: cast_nullable_to_non_nullable
as List<SubwayStationDetail>?,locationNameUz: freezed == locationNameUz ? _self.locationNameUz : locationNameUz // ignore: cast_nullable_to_non_nullable
as String?,locationNameRu: freezed == locationNameRu ? _self.locationNameRu : locationNameRu // ignore: cast_nullable_to_non_nullable
as String?,locationNameEn: freezed == locationNameEn ? _self.locationNameEn : locationNameEn // ignore: cast_nullable_to_non_nullable
as String?,locationShortNameUz: freezed == locationShortNameUz ? _self.locationShortNameUz : locationShortNameUz // ignore: cast_nullable_to_non_nullable
as String?,locationShortNameRu: freezed == locationShortNameRu ? _self.locationShortNameRu : locationShortNameRu // ignore: cast_nullable_to_non_nullable
as String?,locationShortNameEn: freezed == locationShortNameEn ? _self.locationShortNameEn : locationShortNameEn // ignore: cast_nullable_to_non_nullable
as String?,searchLocations: freezed == searchLocations ? _self.searchLocations : searchLocations // ignore: cast_nullable_to_non_nullable
as List<LocationDetail>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationSummary].
extension ConversationSummaryPatterns on ConversationSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationSummary value)  $default,){
final _that = this;
switch (_that) {
case _ConversationSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "initiator_id")  int initiatorId, @JsonKey(name: "participant_id")  int participantId, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "context_type")  String? contextType, @JsonKey(name: "context_id")  int? contextId, @JsonKey(name: "gig_request_id")  int? gigRequestId, @JsonKey(name: "gig_request_title")  String? gigRequestTitle, @JsonKey(name: "gig_category_id")  int? gigCategoryId, @JsonKey(name: "gig_budget_type")  String? gigBudgetType, @JsonKey(name: "last_message_at")  String? lastMessageAt, @JsonKey(name: "last_message_content")  String? lastMessageContent, @JsonKey(name: "last_message_sender_id")  int? lastMessageSenderId, @JsonKey(name: "archived_at")  String? archivedAt, @JsonKey(name: "listing_title")  String? listingTitle, @JsonKey(name: "listing_type_id")  int? listingTypeId, @JsonKey(name: "listing_gender")  int? listingGender, @JsonKey(name: "listing_price")  int? listingPrice, @JsonKey(name: "price_currency_code")  String? priceCurrencyCode, @JsonKey(name: "conversation_type")  String? conversationType, @JsonKey(name: "other_user_name")  String? otherUserName, @JsonKey(name: "other_user_avatar")  String? otherUserAvatar, @JsonKey(name: "members")  List<ConversationMemberSummary> members, @JsonKey(name: "gig_owner_name")  String? gigOwnerName, @JsonKey(name: "gig_owner_avatar")  String? gigOwnerAvatar, @JsonKey(name: "unread_count")  int? unreadCount, @JsonKey(name: "listing_subway_line_id")  int? listingSubwayLineId, @JsonKey(name: "listing_subway_station_id")  int? listingSubwayStationId, @JsonKey(name: "listing_location_id")  int? listingLocationId, @JsonKey(name: "subway_station_name_uz")  String? subwayStationNameUz, @JsonKey(name: "subway_station_name_ru")  String? subwayStationNameRu, @JsonKey(name: "subway_station_name_en")  String? subwayStationNameEn, @JsonKey(name: "subway_station_line")  int? subwayStationLine, @JsonKey(name: "subway_station_ordinal")  int? subwayStationOrdinal, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations, @JsonKey(name: "location_name_uz")  String? locationNameUz, @JsonKey(name: "location_name_ru")  String? locationNameRu, @JsonKey(name: "location_name_en")  String? locationNameEn, @JsonKey(name: "location_short_name_uz")  String? locationShortNameUz, @JsonKey(name: "location_short_name_ru")  String? locationShortNameRu, @JsonKey(name: "location_short_name_en")  String? locationShortNameEn, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationSummary() when $default != null:
return $default(_that.id,_that.initiatorId,_that.participantId,_that.isActive,_that.createdAt,_that.updatedAt,_that.listingId,_that.contextType,_that.contextId,_that.gigRequestId,_that.gigRequestTitle,_that.gigCategoryId,_that.gigBudgetType,_that.lastMessageAt,_that.lastMessageContent,_that.lastMessageSenderId,_that.archivedAt,_that.listingTitle,_that.listingTypeId,_that.listingGender,_that.listingPrice,_that.priceCurrencyCode,_that.conversationType,_that.otherUserName,_that.otherUserAvatar,_that.members,_that.gigOwnerName,_that.gigOwnerAvatar,_that.unreadCount,_that.listingSubwayLineId,_that.listingSubwayStationId,_that.listingLocationId,_that.subwayStationNameUz,_that.subwayStationNameRu,_that.subwayStationNameEn,_that.subwayStationLine,_that.subwayStationOrdinal,_that.searchSubwayStations,_that.locationNameUz,_that.locationNameRu,_that.locationNameEn,_that.locationShortNameUz,_that.locationShortNameRu,_that.locationShortNameEn,_that.searchLocations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "initiator_id")  int initiatorId, @JsonKey(name: "participant_id")  int participantId, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "context_type")  String? contextType, @JsonKey(name: "context_id")  int? contextId, @JsonKey(name: "gig_request_id")  int? gigRequestId, @JsonKey(name: "gig_request_title")  String? gigRequestTitle, @JsonKey(name: "gig_category_id")  int? gigCategoryId, @JsonKey(name: "gig_budget_type")  String? gigBudgetType, @JsonKey(name: "last_message_at")  String? lastMessageAt, @JsonKey(name: "last_message_content")  String? lastMessageContent, @JsonKey(name: "last_message_sender_id")  int? lastMessageSenderId, @JsonKey(name: "archived_at")  String? archivedAt, @JsonKey(name: "listing_title")  String? listingTitle, @JsonKey(name: "listing_type_id")  int? listingTypeId, @JsonKey(name: "listing_gender")  int? listingGender, @JsonKey(name: "listing_price")  int? listingPrice, @JsonKey(name: "price_currency_code")  String? priceCurrencyCode, @JsonKey(name: "conversation_type")  String? conversationType, @JsonKey(name: "other_user_name")  String? otherUserName, @JsonKey(name: "other_user_avatar")  String? otherUserAvatar, @JsonKey(name: "members")  List<ConversationMemberSummary> members, @JsonKey(name: "gig_owner_name")  String? gigOwnerName, @JsonKey(name: "gig_owner_avatar")  String? gigOwnerAvatar, @JsonKey(name: "unread_count")  int? unreadCount, @JsonKey(name: "listing_subway_line_id")  int? listingSubwayLineId, @JsonKey(name: "listing_subway_station_id")  int? listingSubwayStationId, @JsonKey(name: "listing_location_id")  int? listingLocationId, @JsonKey(name: "subway_station_name_uz")  String? subwayStationNameUz, @JsonKey(name: "subway_station_name_ru")  String? subwayStationNameRu, @JsonKey(name: "subway_station_name_en")  String? subwayStationNameEn, @JsonKey(name: "subway_station_line")  int? subwayStationLine, @JsonKey(name: "subway_station_ordinal")  int? subwayStationOrdinal, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations, @JsonKey(name: "location_name_uz")  String? locationNameUz, @JsonKey(name: "location_name_ru")  String? locationNameRu, @JsonKey(name: "location_name_en")  String? locationNameEn, @JsonKey(name: "location_short_name_uz")  String? locationShortNameUz, @JsonKey(name: "location_short_name_ru")  String? locationShortNameRu, @JsonKey(name: "location_short_name_en")  String? locationShortNameEn, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations)  $default,) {final _that = this;
switch (_that) {
case _ConversationSummary():
return $default(_that.id,_that.initiatorId,_that.participantId,_that.isActive,_that.createdAt,_that.updatedAt,_that.listingId,_that.contextType,_that.contextId,_that.gigRequestId,_that.gigRequestTitle,_that.gigCategoryId,_that.gigBudgetType,_that.lastMessageAt,_that.lastMessageContent,_that.lastMessageSenderId,_that.archivedAt,_that.listingTitle,_that.listingTypeId,_that.listingGender,_that.listingPrice,_that.priceCurrencyCode,_that.conversationType,_that.otherUserName,_that.otherUserAvatar,_that.members,_that.gigOwnerName,_that.gigOwnerAvatar,_that.unreadCount,_that.listingSubwayLineId,_that.listingSubwayStationId,_that.listingLocationId,_that.subwayStationNameUz,_that.subwayStationNameRu,_that.subwayStationNameEn,_that.subwayStationLine,_that.subwayStationOrdinal,_that.searchSubwayStations,_that.locationNameUz,_that.locationNameRu,_that.locationNameEn,_that.locationShortNameUz,_that.locationShortNameRu,_that.locationShortNameEn,_that.searchLocations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "initiator_id")  int initiatorId, @JsonKey(name: "participant_id")  int participantId, @JsonKey(name: "is_active")  bool isActive, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "listing_id")  int? listingId, @JsonKey(name: "context_type")  String? contextType, @JsonKey(name: "context_id")  int? contextId, @JsonKey(name: "gig_request_id")  int? gigRequestId, @JsonKey(name: "gig_request_title")  String? gigRequestTitle, @JsonKey(name: "gig_category_id")  int? gigCategoryId, @JsonKey(name: "gig_budget_type")  String? gigBudgetType, @JsonKey(name: "last_message_at")  String? lastMessageAt, @JsonKey(name: "last_message_content")  String? lastMessageContent, @JsonKey(name: "last_message_sender_id")  int? lastMessageSenderId, @JsonKey(name: "archived_at")  String? archivedAt, @JsonKey(name: "listing_title")  String? listingTitle, @JsonKey(name: "listing_type_id")  int? listingTypeId, @JsonKey(name: "listing_gender")  int? listingGender, @JsonKey(name: "listing_price")  int? listingPrice, @JsonKey(name: "price_currency_code")  String? priceCurrencyCode, @JsonKey(name: "conversation_type")  String? conversationType, @JsonKey(name: "other_user_name")  String? otherUserName, @JsonKey(name: "other_user_avatar")  String? otherUserAvatar, @JsonKey(name: "members")  List<ConversationMemberSummary> members, @JsonKey(name: "gig_owner_name")  String? gigOwnerName, @JsonKey(name: "gig_owner_avatar")  String? gigOwnerAvatar, @JsonKey(name: "unread_count")  int? unreadCount, @JsonKey(name: "listing_subway_line_id")  int? listingSubwayLineId, @JsonKey(name: "listing_subway_station_id")  int? listingSubwayStationId, @JsonKey(name: "listing_location_id")  int? listingLocationId, @JsonKey(name: "subway_station_name_uz")  String? subwayStationNameUz, @JsonKey(name: "subway_station_name_ru")  String? subwayStationNameRu, @JsonKey(name: "subway_station_name_en")  String? subwayStationNameEn, @JsonKey(name: "subway_station_line")  int? subwayStationLine, @JsonKey(name: "subway_station_ordinal")  int? subwayStationOrdinal, @JsonKey(name: "search_subway_stations")  List<SubwayStationDetail>? searchSubwayStations, @JsonKey(name: "location_name_uz")  String? locationNameUz, @JsonKey(name: "location_name_ru")  String? locationNameRu, @JsonKey(name: "location_name_en")  String? locationNameEn, @JsonKey(name: "location_short_name_uz")  String? locationShortNameUz, @JsonKey(name: "location_short_name_ru")  String? locationShortNameRu, @JsonKey(name: "location_short_name_en")  String? locationShortNameEn, @JsonKey(name: "search_locations")  List<LocationDetail>? searchLocations)?  $default,) {final _that = this;
switch (_that) {
case _ConversationSummary() when $default != null:
return $default(_that.id,_that.initiatorId,_that.participantId,_that.isActive,_that.createdAt,_that.updatedAt,_that.listingId,_that.contextType,_that.contextId,_that.gigRequestId,_that.gigRequestTitle,_that.gigCategoryId,_that.gigBudgetType,_that.lastMessageAt,_that.lastMessageContent,_that.lastMessageSenderId,_that.archivedAt,_that.listingTitle,_that.listingTypeId,_that.listingGender,_that.listingPrice,_that.priceCurrencyCode,_that.conversationType,_that.otherUserName,_that.otherUserAvatar,_that.members,_that.gigOwnerName,_that.gigOwnerAvatar,_that.unreadCount,_that.listingSubwayLineId,_that.listingSubwayStationId,_that.listingLocationId,_that.subwayStationNameUz,_that.subwayStationNameRu,_that.subwayStationNameEn,_that.subwayStationLine,_that.subwayStationOrdinal,_that.searchSubwayStations,_that.locationNameUz,_that.locationNameRu,_that.locationNameEn,_that.locationShortNameUz,_that.locationShortNameRu,_that.locationShortNameEn,_that.searchLocations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ConversationSummary implements ConversationSummary {
  const _ConversationSummary({required this.id, @JsonKey(name: "initiator_id") required this.initiatorId, @JsonKey(name: "participant_id") required this.participantId, @JsonKey(name: "is_active") required this.isActive, @JsonKey(name: "created_at") required this.createdAt, @JsonKey(name: "updated_at") required this.updatedAt, @JsonKey(name: "listing_id") this.listingId, @JsonKey(name: "context_type") this.contextType, @JsonKey(name: "context_id") this.contextId, @JsonKey(name: "gig_request_id") this.gigRequestId, @JsonKey(name: "gig_request_title") this.gigRequestTitle, @JsonKey(name: "gig_category_id") this.gigCategoryId, @JsonKey(name: "gig_budget_type") this.gigBudgetType, @JsonKey(name: "last_message_at") this.lastMessageAt, @JsonKey(name: "last_message_content") this.lastMessageContent, @JsonKey(name: "last_message_sender_id") this.lastMessageSenderId, @JsonKey(name: "archived_at") this.archivedAt, @JsonKey(name: "listing_title") this.listingTitle, @JsonKey(name: "listing_type_id") this.listingTypeId, @JsonKey(name: "listing_gender") this.listingGender, @JsonKey(name: "listing_price") this.listingPrice, @JsonKey(name: "price_currency_code") this.priceCurrencyCode, @JsonKey(name: "conversation_type") this.conversationType, @JsonKey(name: "other_user_name") this.otherUserName, @JsonKey(name: "other_user_avatar") this.otherUserAvatar, @JsonKey(name: "members") final  List<ConversationMemberSummary> members = const <ConversationMemberSummary>[], @JsonKey(name: "gig_owner_name") this.gigOwnerName, @JsonKey(name: "gig_owner_avatar") this.gigOwnerAvatar, @JsonKey(name: "unread_count") this.unreadCount, @JsonKey(name: "listing_subway_line_id") this.listingSubwayLineId, @JsonKey(name: "listing_subway_station_id") this.listingSubwayStationId, @JsonKey(name: "listing_location_id") this.listingLocationId, @JsonKey(name: "subway_station_name_uz") this.subwayStationNameUz, @JsonKey(name: "subway_station_name_ru") this.subwayStationNameRu, @JsonKey(name: "subway_station_name_en") this.subwayStationNameEn, @JsonKey(name: "subway_station_line") this.subwayStationLine, @JsonKey(name: "subway_station_ordinal") this.subwayStationOrdinal, @JsonKey(name: "search_subway_stations") final  List<SubwayStationDetail>? searchSubwayStations, @JsonKey(name: "location_name_uz") this.locationNameUz, @JsonKey(name: "location_name_ru") this.locationNameRu, @JsonKey(name: "location_name_en") this.locationNameEn, @JsonKey(name: "location_short_name_uz") this.locationShortNameUz, @JsonKey(name: "location_short_name_ru") this.locationShortNameRu, @JsonKey(name: "location_short_name_en") this.locationShortNameEn, @JsonKey(name: "search_locations") final  List<LocationDetail>? searchLocations}): _members = members,_searchSubwayStations = searchSubwayStations,_searchLocations = searchLocations;
  factory _ConversationSummary.fromJson(Map<String, dynamic> json) => _$ConversationSummaryFromJson(json);

@override final  int id;
@override@JsonKey(name: "initiator_id") final  int initiatorId;
@override@JsonKey(name: "participant_id") final  int participantId;
@override@JsonKey(name: "is_active") final  bool isActive;
@override@JsonKey(name: "created_at") final  String createdAt;
@override@JsonKey(name: "updated_at") final  String updatedAt;
@override@JsonKey(name: "listing_id") final  int? listingId;
@override@JsonKey(name: "context_type") final  String? contextType;
@override@JsonKey(name: "context_id") final  int? contextId;
@override@JsonKey(name: "gig_request_id") final  int? gigRequestId;
@override@JsonKey(name: "gig_request_title") final  String? gigRequestTitle;
/// Gig category id (`gig_categories.id`) for gig-scoped chats.
@override@JsonKey(name: "gig_category_id") final  int? gigCategoryId;
/// Budget / pricing type from the gig surface (`open`, `hourly`, etc.).
@override@JsonKey(name: "gig_budget_type") final  String? gigBudgetType;
@override@JsonKey(name: "last_message_at") final  String? lastMessageAt;
@override@JsonKey(name: "last_message_content") final  String? lastMessageContent;
@override@JsonKey(name: "last_message_sender_id") final  int? lastMessageSenderId;
@override@JsonKey(name: "archived_at") final  String? archivedAt;
// Summary data
@override@JsonKey(name: "listing_title") final  String? listingTitle;
@override@JsonKey(name: "listing_type_id") final  int? listingTypeId;
@override@JsonKey(name: "listing_gender") final  int? listingGender;
@override@JsonKey(name: "listing_price") final  int? listingPrice;
/// When set (e.g. gig-request chats), [ConversationPriceDisplay] shows this currency instead of y.e.
@override@JsonKey(name: "price_currency_code") final  String? priceCurrencyCode;
@override@JsonKey(name: "conversation_type") final  String? conversationType;
@override@JsonKey(name: "other_user_name") final  String? otherUserName;
@override@JsonKey(name: "other_user_avatar") final  String? otherUserAvatar;
/// Group-chat (`listing_group`) member previews for overlapping inbox
/// avatars. Empty for direct/listing/gig chats.
 final  List<ConversationMemberSummary> _members;
/// Group-chat (`listing_group`) member previews for overlapping inbox
/// avatars. Empty for direct/listing/gig chats.
@override@JsonKey(name: "members") List<ConversationMemberSummary> get members {
  if (_members is EqualUnmodifiableListView) return _members;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_members);
}

/// Gig row author: task client for `gig_request`, provider for `gig_offer` / `gig_booking`.
@override@JsonKey(name: "gig_owner_name") final  String? gigOwnerName;
@override@JsonKey(name: "gig_owner_avatar") final  String? gigOwnerAvatar;
@override@JsonKey(name: "unread_count") final  int? unreadCount;
// Location and metro station data
@override@JsonKey(name: "listing_subway_line_id") final  int? listingSubwayLineId;
@override@JsonKey(name: "listing_subway_station_id") final  int? listingSubwayStationId;
@override@JsonKey(name: "listing_location_id") final  int? listingLocationId;
@override@JsonKey(name: "subway_station_name_uz") final  String? subwayStationNameUz;
@override@JsonKey(name: "subway_station_name_ru") final  String? subwayStationNameRu;
@override@JsonKey(name: "subway_station_name_en") final  String? subwayStationNameEn;
@override@JsonKey(name: "subway_station_line") final  int? subwayStationLine;
@override@JsonKey(name: "subway_station_ordinal") final  int? subwayStationOrdinal;
 final  List<SubwayStationDetail>? _searchSubwayStations;
@override@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? get searchSubwayStations {
  final value = _searchSubwayStations;
  if (value == null) return null;
  if (_searchSubwayStations is EqualUnmodifiableListView) return _searchSubwayStations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: "location_name_uz") final  String? locationNameUz;
@override@JsonKey(name: "location_name_ru") final  String? locationNameRu;
@override@JsonKey(name: "location_name_en") final  String? locationNameEn;
@override@JsonKey(name: "location_short_name_uz") final  String? locationShortNameUz;
@override@JsonKey(name: "location_short_name_ru") final  String? locationShortNameRu;
@override@JsonKey(name: "location_short_name_en") final  String? locationShortNameEn;
 final  List<LocationDetail>? _searchLocations;
@override@JsonKey(name: "search_locations") List<LocationDetail>? get searchLocations {
  final value = _searchLocations;
  if (value == null) return null;
  if (_searchLocations is EqualUnmodifiableListView) return _searchLocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ConversationSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationSummaryCopyWith<_ConversationSummary> get copyWith => __$ConversationSummaryCopyWithImpl<_ConversationSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ConversationSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.initiatorId, initiatorId) || other.initiatorId == initiatorId)&&(identical(other.participantId, participantId) || other.participantId == participantId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.listingId, listingId) || other.listingId == listingId)&&(identical(other.contextType, contextType) || other.contextType == contextType)&&(identical(other.contextId, contextId) || other.contextId == contextId)&&(identical(other.gigRequestId, gigRequestId) || other.gigRequestId == gigRequestId)&&(identical(other.gigRequestTitle, gigRequestTitle) || other.gigRequestTitle == gigRequestTitle)&&(identical(other.gigCategoryId, gigCategoryId) || other.gigCategoryId == gigCategoryId)&&(identical(other.gigBudgetType, gigBudgetType) || other.gigBudgetType == gigBudgetType)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.listingTitle, listingTitle) || other.listingTitle == listingTitle)&&(identical(other.listingTypeId, listingTypeId) || other.listingTypeId == listingTypeId)&&(identical(other.listingGender, listingGender) || other.listingGender == listingGender)&&(identical(other.listingPrice, listingPrice) || other.listingPrice == listingPrice)&&(identical(other.priceCurrencyCode, priceCurrencyCode) || other.priceCurrencyCode == priceCurrencyCode)&&(identical(other.conversationType, conversationType) || other.conversationType == conversationType)&&(identical(other.otherUserName, otherUserName) || other.otherUserName == otherUserName)&&(identical(other.otherUserAvatar, otherUserAvatar) || other.otherUserAvatar == otherUserAvatar)&&const DeepCollectionEquality().equals(other._members, _members)&&(identical(other.gigOwnerName, gigOwnerName) || other.gigOwnerName == gigOwnerName)&&(identical(other.gigOwnerAvatar, gigOwnerAvatar) || other.gigOwnerAvatar == gigOwnerAvatar)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.listingSubwayLineId, listingSubwayLineId) || other.listingSubwayLineId == listingSubwayLineId)&&(identical(other.listingSubwayStationId, listingSubwayStationId) || other.listingSubwayStationId == listingSubwayStationId)&&(identical(other.listingLocationId, listingLocationId) || other.listingLocationId == listingLocationId)&&(identical(other.subwayStationNameUz, subwayStationNameUz) || other.subwayStationNameUz == subwayStationNameUz)&&(identical(other.subwayStationNameRu, subwayStationNameRu) || other.subwayStationNameRu == subwayStationNameRu)&&(identical(other.subwayStationNameEn, subwayStationNameEn) || other.subwayStationNameEn == subwayStationNameEn)&&(identical(other.subwayStationLine, subwayStationLine) || other.subwayStationLine == subwayStationLine)&&(identical(other.subwayStationOrdinal, subwayStationOrdinal) || other.subwayStationOrdinal == subwayStationOrdinal)&&const DeepCollectionEquality().equals(other._searchSubwayStations, _searchSubwayStations)&&(identical(other.locationNameUz, locationNameUz) || other.locationNameUz == locationNameUz)&&(identical(other.locationNameRu, locationNameRu) || other.locationNameRu == locationNameRu)&&(identical(other.locationNameEn, locationNameEn) || other.locationNameEn == locationNameEn)&&(identical(other.locationShortNameUz, locationShortNameUz) || other.locationShortNameUz == locationShortNameUz)&&(identical(other.locationShortNameRu, locationShortNameRu) || other.locationShortNameRu == locationShortNameRu)&&(identical(other.locationShortNameEn, locationShortNameEn) || other.locationShortNameEn == locationShortNameEn)&&const DeepCollectionEquality().equals(other._searchLocations, _searchLocations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,initiatorId,participantId,isActive,createdAt,updatedAt,listingId,contextType,contextId,gigRequestId,gigRequestTitle,gigCategoryId,gigBudgetType,lastMessageAt,lastMessageContent,lastMessageSenderId,archivedAt,listingTitle,listingTypeId,listingGender,listingPrice,priceCurrencyCode,conversationType,otherUserName,otherUserAvatar,const DeepCollectionEquality().hash(_members),gigOwnerName,gigOwnerAvatar,unreadCount,listingSubwayLineId,listingSubwayStationId,listingLocationId,subwayStationNameUz,subwayStationNameRu,subwayStationNameEn,subwayStationLine,subwayStationOrdinal,const DeepCollectionEquality().hash(_searchSubwayStations),locationNameUz,locationNameRu,locationNameEn,locationShortNameUz,locationShortNameRu,locationShortNameEn,const DeepCollectionEquality().hash(_searchLocations)]);

@override
String toString() {
  return 'ConversationSummary(id: $id, initiatorId: $initiatorId, participantId: $participantId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, listingId: $listingId, contextType: $contextType, contextId: $contextId, gigRequestId: $gigRequestId, gigRequestTitle: $gigRequestTitle, gigCategoryId: $gigCategoryId, gigBudgetType: $gigBudgetType, lastMessageAt: $lastMessageAt, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, archivedAt: $archivedAt, listingTitle: $listingTitle, listingTypeId: $listingTypeId, listingGender: $listingGender, listingPrice: $listingPrice, priceCurrencyCode: $priceCurrencyCode, conversationType: $conversationType, otherUserName: $otherUserName, otherUserAvatar: $otherUserAvatar, members: $members, gigOwnerName: $gigOwnerName, gigOwnerAvatar: $gigOwnerAvatar, unreadCount: $unreadCount, listingSubwayLineId: $listingSubwayLineId, listingSubwayStationId: $listingSubwayStationId, listingLocationId: $listingLocationId, subwayStationNameUz: $subwayStationNameUz, subwayStationNameRu: $subwayStationNameRu, subwayStationNameEn: $subwayStationNameEn, subwayStationLine: $subwayStationLine, subwayStationOrdinal: $subwayStationOrdinal, searchSubwayStations: $searchSubwayStations, locationNameUz: $locationNameUz, locationNameRu: $locationNameRu, locationNameEn: $locationNameEn, locationShortNameUz: $locationShortNameUz, locationShortNameRu: $locationShortNameRu, locationShortNameEn: $locationShortNameEn, searchLocations: $searchLocations)';
}


}

/// @nodoc
abstract mixin class _$ConversationSummaryCopyWith<$Res> implements $ConversationSummaryCopyWith<$Res> {
  factory _$ConversationSummaryCopyWith(_ConversationSummary value, $Res Function(_ConversationSummary) _then) = __$ConversationSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "initiator_id") int initiatorId,@JsonKey(name: "participant_id") int participantId,@JsonKey(name: "is_active") bool isActive,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "listing_id") int? listingId,@JsonKey(name: "context_type") String? contextType,@JsonKey(name: "context_id") int? contextId,@JsonKey(name: "gig_request_id") int? gigRequestId,@JsonKey(name: "gig_request_title") String? gigRequestTitle,@JsonKey(name: "gig_category_id") int? gigCategoryId,@JsonKey(name: "gig_budget_type") String? gigBudgetType,@JsonKey(name: "last_message_at") String? lastMessageAt,@JsonKey(name: "last_message_content") String? lastMessageContent,@JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,@JsonKey(name: "archived_at") String? archivedAt,@JsonKey(name: "listing_title") String? listingTitle,@JsonKey(name: "listing_type_id") int? listingTypeId,@JsonKey(name: "listing_gender") int? listingGender,@JsonKey(name: "listing_price") int? listingPrice,@JsonKey(name: "price_currency_code") String? priceCurrencyCode,@JsonKey(name: "conversation_type") String? conversationType,@JsonKey(name: "other_user_name") String? otherUserName,@JsonKey(name: "other_user_avatar") String? otherUserAvatar,@JsonKey(name: "members") List<ConversationMemberSummary> members,@JsonKey(name: "gig_owner_name") String? gigOwnerName,@JsonKey(name: "gig_owner_avatar") String? gigOwnerAvatar,@JsonKey(name: "unread_count") int? unreadCount,@JsonKey(name: "listing_subway_line_id") int? listingSubwayLineId,@JsonKey(name: "listing_subway_station_id") int? listingSubwayStationId,@JsonKey(name: "listing_location_id") int? listingLocationId,@JsonKey(name: "subway_station_name_uz") String? subwayStationNameUz,@JsonKey(name: "subway_station_name_ru") String? subwayStationNameRu,@JsonKey(name: "subway_station_name_en") String? subwayStationNameEn,@JsonKey(name: "subway_station_line") int? subwayStationLine,@JsonKey(name: "subway_station_ordinal") int? subwayStationOrdinal,@JsonKey(name: "search_subway_stations") List<SubwayStationDetail>? searchSubwayStations,@JsonKey(name: "location_name_uz") String? locationNameUz,@JsonKey(name: "location_name_ru") String? locationNameRu,@JsonKey(name: "location_name_en") String? locationNameEn,@JsonKey(name: "location_short_name_uz") String? locationShortNameUz,@JsonKey(name: "location_short_name_ru") String? locationShortNameRu,@JsonKey(name: "location_short_name_en") String? locationShortNameEn,@JsonKey(name: "search_locations") List<LocationDetail>? searchLocations
});




}
/// @nodoc
class __$ConversationSummaryCopyWithImpl<$Res>
    implements _$ConversationSummaryCopyWith<$Res> {
  __$ConversationSummaryCopyWithImpl(this._self, this._then);

  final _ConversationSummary _self;
  final $Res Function(_ConversationSummary) _then;

/// Create a copy of ConversationSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? initiatorId = null,Object? participantId = null,Object? isActive = null,Object? createdAt = null,Object? updatedAt = null,Object? listingId = freezed,Object? contextType = freezed,Object? contextId = freezed,Object? gigRequestId = freezed,Object? gigRequestTitle = freezed,Object? gigCategoryId = freezed,Object? gigBudgetType = freezed,Object? lastMessageAt = freezed,Object? lastMessageContent = freezed,Object? lastMessageSenderId = freezed,Object? archivedAt = freezed,Object? listingTitle = freezed,Object? listingTypeId = freezed,Object? listingGender = freezed,Object? listingPrice = freezed,Object? priceCurrencyCode = freezed,Object? conversationType = freezed,Object? otherUserName = freezed,Object? otherUserAvatar = freezed,Object? members = null,Object? gigOwnerName = freezed,Object? gigOwnerAvatar = freezed,Object? unreadCount = freezed,Object? listingSubwayLineId = freezed,Object? listingSubwayStationId = freezed,Object? listingLocationId = freezed,Object? subwayStationNameUz = freezed,Object? subwayStationNameRu = freezed,Object? subwayStationNameEn = freezed,Object? subwayStationLine = freezed,Object? subwayStationOrdinal = freezed,Object? searchSubwayStations = freezed,Object? locationNameUz = freezed,Object? locationNameRu = freezed,Object? locationNameEn = freezed,Object? locationShortNameUz = freezed,Object? locationShortNameRu = freezed,Object? locationShortNameEn = freezed,Object? searchLocations = freezed,}) {
  return _then(_ConversationSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,initiatorId: null == initiatorId ? _self.initiatorId : initiatorId // ignore: cast_nullable_to_non_nullable
as int,participantId: null == participantId ? _self.participantId : participantId // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,listingId: freezed == listingId ? _self.listingId : listingId // ignore: cast_nullable_to_non_nullable
as int?,contextType: freezed == contextType ? _self.contextType : contextType // ignore: cast_nullable_to_non_nullable
as String?,contextId: freezed == contextId ? _self.contextId : contextId // ignore: cast_nullable_to_non_nullable
as int?,gigRequestId: freezed == gigRequestId ? _self.gigRequestId : gigRequestId // ignore: cast_nullable_to_non_nullable
as int?,gigRequestTitle: freezed == gigRequestTitle ? _self.gigRequestTitle : gigRequestTitle // ignore: cast_nullable_to_non_nullable
as String?,gigCategoryId: freezed == gigCategoryId ? _self.gigCategoryId : gigCategoryId // ignore: cast_nullable_to_non_nullable
as int?,gigBudgetType: freezed == gigBudgetType ? _self.gigBudgetType : gigBudgetType // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as String?,lastMessageContent: freezed == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as int?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as String?,listingTitle: freezed == listingTitle ? _self.listingTitle : listingTitle // ignore: cast_nullable_to_non_nullable
as String?,listingTypeId: freezed == listingTypeId ? _self.listingTypeId : listingTypeId // ignore: cast_nullable_to_non_nullable
as int?,listingGender: freezed == listingGender ? _self.listingGender : listingGender // ignore: cast_nullable_to_non_nullable
as int?,listingPrice: freezed == listingPrice ? _self.listingPrice : listingPrice // ignore: cast_nullable_to_non_nullable
as int?,priceCurrencyCode: freezed == priceCurrencyCode ? _self.priceCurrencyCode : priceCurrencyCode // ignore: cast_nullable_to_non_nullable
as String?,conversationType: freezed == conversationType ? _self.conversationType : conversationType // ignore: cast_nullable_to_non_nullable
as String?,otherUserName: freezed == otherUserName ? _self.otherUserName : otherUserName // ignore: cast_nullable_to_non_nullable
as String?,otherUserAvatar: freezed == otherUserAvatar ? _self.otherUserAvatar : otherUserAvatar // ignore: cast_nullable_to_non_nullable
as String?,members: null == members ? _self._members : members // ignore: cast_nullable_to_non_nullable
as List<ConversationMemberSummary>,gigOwnerName: freezed == gigOwnerName ? _self.gigOwnerName : gigOwnerName // ignore: cast_nullable_to_non_nullable
as String?,gigOwnerAvatar: freezed == gigOwnerAvatar ? _self.gigOwnerAvatar : gigOwnerAvatar // ignore: cast_nullable_to_non_nullable
as String?,unreadCount: freezed == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int?,listingSubwayLineId: freezed == listingSubwayLineId ? _self.listingSubwayLineId : listingSubwayLineId // ignore: cast_nullable_to_non_nullable
as int?,listingSubwayStationId: freezed == listingSubwayStationId ? _self.listingSubwayStationId : listingSubwayStationId // ignore: cast_nullable_to_non_nullable
as int?,listingLocationId: freezed == listingLocationId ? _self.listingLocationId : listingLocationId // ignore: cast_nullable_to_non_nullable
as int?,subwayStationNameUz: freezed == subwayStationNameUz ? _self.subwayStationNameUz : subwayStationNameUz // ignore: cast_nullable_to_non_nullable
as String?,subwayStationNameRu: freezed == subwayStationNameRu ? _self.subwayStationNameRu : subwayStationNameRu // ignore: cast_nullable_to_non_nullable
as String?,subwayStationNameEn: freezed == subwayStationNameEn ? _self.subwayStationNameEn : subwayStationNameEn // ignore: cast_nullable_to_non_nullable
as String?,subwayStationLine: freezed == subwayStationLine ? _self.subwayStationLine : subwayStationLine // ignore: cast_nullable_to_non_nullable
as int?,subwayStationOrdinal: freezed == subwayStationOrdinal ? _self.subwayStationOrdinal : subwayStationOrdinal // ignore: cast_nullable_to_non_nullable
as int?,searchSubwayStations: freezed == searchSubwayStations ? _self._searchSubwayStations : searchSubwayStations // ignore: cast_nullable_to_non_nullable
as List<SubwayStationDetail>?,locationNameUz: freezed == locationNameUz ? _self.locationNameUz : locationNameUz // ignore: cast_nullable_to_non_nullable
as String?,locationNameRu: freezed == locationNameRu ? _self.locationNameRu : locationNameRu // ignore: cast_nullable_to_non_nullable
as String?,locationNameEn: freezed == locationNameEn ? _self.locationNameEn : locationNameEn // ignore: cast_nullable_to_non_nullable
as String?,locationShortNameUz: freezed == locationShortNameUz ? _self.locationShortNameUz : locationShortNameUz // ignore: cast_nullable_to_non_nullable
as String?,locationShortNameRu: freezed == locationShortNameRu ? _self.locationShortNameRu : locationShortNameRu // ignore: cast_nullable_to_non_nullable
as String?,locationShortNameEn: freezed == locationShortNameEn ? _self.locationShortNameEn : locationShortNameEn // ignore: cast_nullable_to_non_nullable
as String?,searchLocations: freezed == searchLocations ? _self._searchLocations : searchLocations // ignore: cast_nullable_to_non_nullable
as List<LocationDetail>?,
  ));
}


}

// dart format on
