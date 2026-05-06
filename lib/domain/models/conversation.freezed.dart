// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Conversation _$ConversationFromJson(Map<String, dynamic> json) {
  return _Conversation.fromJson(json);
}

/// @nodoc
mixin _$Conversation {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "initiator_id")
  int get initiatorId => throw _privateConstructorUsedError;
  @JsonKey(name: "participant_id")
  int get participantId => throw _privateConstructorUsedError;
  @JsonKey(name: "is_active")
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String get updatedAt =>
      throw _privateConstructorUsedError; // Nullable since the gig-module conversations (`context_type` =
// `gig_request` / `gig_offer` / `gig_booking`) don't carry a listing.
// Legacy listing chats keep `listing_id` populated alongside
// `context_type='listing'` for back-compat with grouped views.
  @JsonKey(name: "listing_id")
  int? get listingId => throw _privateConstructorUsedError;
  @JsonKey(name: "context_type")
  String? get contextType => throw _privateConstructorUsedError;
  @JsonKey(name: "context_id")
  int? get contextId => throw _privateConstructorUsedError;
  @JsonKey(name: "gig_request_id")
  int? get gigRequestId => throw _privateConstructorUsedError;
  @JsonKey(name: "gig_request_title")
  String? get gigRequestTitle => throw _privateConstructorUsedError;
  @JsonKey(name: "last_message_at")
  String? get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(name: "last_message_content")
  String? get lastMessageContent => throw _privateConstructorUsedError;
  @JsonKey(name: "last_message_sender_id")
  int? get lastMessageSenderId => throw _privateConstructorUsedError;
  @JsonKey(name: "archived_at")
  String? get archivedAt => throw _privateConstructorUsedError; // Related data
  Listing? get listing => throw _privateConstructorUsedError;
  UserProfile? get otherUser => throw _privateConstructorUsedError;
  @JsonKey(name: "unread_count")
  int? get unreadCount => throw _privateConstructorUsedError;

  /// Serializes this Conversation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationCopyWith<Conversation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationCopyWith<$Res> {
  factory $ConversationCopyWith(
          Conversation value, $Res Function(Conversation) then) =
      _$ConversationCopyWithImpl<$Res, Conversation>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "initiator_id") int initiatorId,
      @JsonKey(name: "participant_id") int participantId,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      @JsonKey(name: "listing_id") int? listingId,
      @JsonKey(name: "context_type") String? contextType,
      @JsonKey(name: "context_id") int? contextId,
      @JsonKey(name: "gig_request_id") int? gigRequestId,
      @JsonKey(name: "gig_request_title") String? gigRequestTitle,
      @JsonKey(name: "last_message_at") String? lastMessageAt,
      @JsonKey(name: "last_message_content") String? lastMessageContent,
      @JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,
      @JsonKey(name: "archived_at") String? archivedAt,
      Listing? listing,
      UserProfile? otherUser,
      @JsonKey(name: "unread_count") int? unreadCount});

  $ListingCopyWith<$Res>? get listing;
  $UserProfileCopyWith<$Res>? get otherUser;
}

/// @nodoc
class _$ConversationCopyWithImpl<$Res, $Val extends Conversation>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initiatorId = null,
    Object? participantId = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? listingId = freezed,
    Object? contextType = freezed,
    Object? contextId = freezed,
    Object? gigRequestId = freezed,
    Object? gigRequestTitle = freezed,
    Object? lastMessageAt = freezed,
    Object? lastMessageContent = freezed,
    Object? lastMessageSenderId = freezed,
    Object? archivedAt = freezed,
    Object? listing = freezed,
    Object? otherUser = freezed,
    Object? unreadCount = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      initiatorId: null == initiatorId
          ? _value.initiatorId
          : initiatorId // ignore: cast_nullable_to_non_nullable
              as int,
      participantId: null == participantId
          ? _value.participantId
          : participantId // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as int?,
      contextType: freezed == contextType
          ? _value.contextType
          : contextType // ignore: cast_nullable_to_non_nullable
              as String?,
      contextId: freezed == contextId
          ? _value.contextId
          : contextId // ignore: cast_nullable_to_non_nullable
              as int?,
      gigRequestId: freezed == gigRequestId
          ? _value.gigRequestId
          : gigRequestId // ignore: cast_nullable_to_non_nullable
              as int?,
      gigRequestTitle: freezed == gigRequestTitle
          ? _value.gigRequestTitle
          : gigRequestTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageContent: freezed == lastMessageContent
          ? _value.lastMessageContent
          : lastMessageContent // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageSenderId: freezed == lastMessageSenderId
          ? _value.lastMessageSenderId
          : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
              as int?,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      listing: freezed == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as Listing?,
      otherUser: freezed == otherUser
          ? _value.otherUser
          : otherUser // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      unreadCount: freezed == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListingCopyWith<$Res>? get listing {
    if (_value.listing == null) {
      return null;
    }

    return $ListingCopyWith<$Res>(_value.listing!, (value) {
      return _then(_value.copyWith(listing: value) as $Val);
    });
  }

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileCopyWith<$Res>? get otherUser {
    if (_value.otherUser == null) {
      return null;
    }

    return $UserProfileCopyWith<$Res>(_value.otherUser!, (value) {
      return _then(_value.copyWith(otherUser: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ConversationImplCopyWith<$Res>
    implements $ConversationCopyWith<$Res> {
  factory _$$ConversationImplCopyWith(
          _$ConversationImpl value, $Res Function(_$ConversationImpl) then) =
      __$$ConversationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "initiator_id") int initiatorId,
      @JsonKey(name: "participant_id") int participantId,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      @JsonKey(name: "listing_id") int? listingId,
      @JsonKey(name: "context_type") String? contextType,
      @JsonKey(name: "context_id") int? contextId,
      @JsonKey(name: "gig_request_id") int? gigRequestId,
      @JsonKey(name: "gig_request_title") String? gigRequestTitle,
      @JsonKey(name: "last_message_at") String? lastMessageAt,
      @JsonKey(name: "last_message_content") String? lastMessageContent,
      @JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,
      @JsonKey(name: "archived_at") String? archivedAt,
      Listing? listing,
      UserProfile? otherUser,
      @JsonKey(name: "unread_count") int? unreadCount});

  @override
  $ListingCopyWith<$Res>? get listing;
  @override
  $UserProfileCopyWith<$Res>? get otherUser;
}

/// @nodoc
class __$$ConversationImplCopyWithImpl<$Res>
    extends _$ConversationCopyWithImpl<$Res, _$ConversationImpl>
    implements _$$ConversationImplCopyWith<$Res> {
  __$$ConversationImplCopyWithImpl(
      _$ConversationImpl _value, $Res Function(_$ConversationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initiatorId = null,
    Object? participantId = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? listingId = freezed,
    Object? contextType = freezed,
    Object? contextId = freezed,
    Object? gigRequestId = freezed,
    Object? gigRequestTitle = freezed,
    Object? lastMessageAt = freezed,
    Object? lastMessageContent = freezed,
    Object? lastMessageSenderId = freezed,
    Object? archivedAt = freezed,
    Object? listing = freezed,
    Object? otherUser = freezed,
    Object? unreadCount = freezed,
  }) {
    return _then(_$ConversationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      initiatorId: null == initiatorId
          ? _value.initiatorId
          : initiatorId // ignore: cast_nullable_to_non_nullable
              as int,
      participantId: null == participantId
          ? _value.participantId
          : participantId // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as int?,
      contextType: freezed == contextType
          ? _value.contextType
          : contextType // ignore: cast_nullable_to_non_nullable
              as String?,
      contextId: freezed == contextId
          ? _value.contextId
          : contextId // ignore: cast_nullable_to_non_nullable
              as int?,
      gigRequestId: freezed == gigRequestId
          ? _value.gigRequestId
          : gigRequestId // ignore: cast_nullable_to_non_nullable
              as int?,
      gigRequestTitle: freezed == gigRequestTitle
          ? _value.gigRequestTitle
          : gigRequestTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageContent: freezed == lastMessageContent
          ? _value.lastMessageContent
          : lastMessageContent // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageSenderId: freezed == lastMessageSenderId
          ? _value.lastMessageSenderId
          : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
              as int?,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      listing: freezed == listing
          ? _value.listing
          : listing // ignore: cast_nullable_to_non_nullable
              as Listing?,
      otherUser: freezed == otherUser
          ? _value.otherUser
          : otherUser // ignore: cast_nullable_to_non_nullable
              as UserProfile?,
      unreadCount: freezed == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationImpl implements _Conversation {
  const _$ConversationImpl(
      {required this.id,
      @JsonKey(name: "initiator_id") required this.initiatorId,
      @JsonKey(name: "participant_id") required this.participantId,
      @JsonKey(name: "is_active") required this.isActive,
      @JsonKey(name: "created_at") required this.createdAt,
      @JsonKey(name: "updated_at") required this.updatedAt,
      @JsonKey(name: "listing_id") this.listingId,
      @JsonKey(name: "context_type") this.contextType,
      @JsonKey(name: "context_id") this.contextId,
      @JsonKey(name: "gig_request_id") this.gigRequestId,
      @JsonKey(name: "gig_request_title") this.gigRequestTitle,
      @JsonKey(name: "last_message_at") this.lastMessageAt,
      @JsonKey(name: "last_message_content") this.lastMessageContent,
      @JsonKey(name: "last_message_sender_id") this.lastMessageSenderId,
      @JsonKey(name: "archived_at") this.archivedAt,
      this.listing,
      this.otherUser,
      @JsonKey(name: "unread_count") this.unreadCount});

  factory _$ConversationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "initiator_id")
  final int initiatorId;
  @override
  @JsonKey(name: "participant_id")
  final int participantId;
  @override
  @JsonKey(name: "is_active")
  final bool isActive;
  @override
  @JsonKey(name: "created_at")
  final String createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String updatedAt;
// Nullable since the gig-module conversations (`context_type` =
// `gig_request` / `gig_offer` / `gig_booking`) don't carry a listing.
// Legacy listing chats keep `listing_id` populated alongside
// `context_type='listing'` for back-compat with grouped views.
  @override
  @JsonKey(name: "listing_id")
  final int? listingId;
  @override
  @JsonKey(name: "context_type")
  final String? contextType;
  @override
  @JsonKey(name: "context_id")
  final int? contextId;
  @override
  @JsonKey(name: "gig_request_id")
  final int? gigRequestId;
  @override
  @JsonKey(name: "gig_request_title")
  final String? gigRequestTitle;
  @override
  @JsonKey(name: "last_message_at")
  final String? lastMessageAt;
  @override
  @JsonKey(name: "last_message_content")
  final String? lastMessageContent;
  @override
  @JsonKey(name: "last_message_sender_id")
  final int? lastMessageSenderId;
  @override
  @JsonKey(name: "archived_at")
  final String? archivedAt;
// Related data
  @override
  final Listing? listing;
  @override
  final UserProfile? otherUser;
  @override
  @JsonKey(name: "unread_count")
  final int? unreadCount;

  @override
  String toString() {
    return 'Conversation(id: $id, initiatorId: $initiatorId, participantId: $participantId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, listingId: $listingId, contextType: $contextType, contextId: $contextId, gigRequestId: $gigRequestId, gigRequestTitle: $gigRequestTitle, lastMessageAt: $lastMessageAt, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, archivedAt: $archivedAt, listing: $listing, otherUser: $otherUser, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initiatorId, initiatorId) ||
                other.initiatorId == initiatorId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.contextType, contextType) ||
                other.contextType == contextType) &&
            (identical(other.contextId, contextId) ||
                other.contextId == contextId) &&
            (identical(other.gigRequestId, gigRequestId) ||
                other.gigRequestId == gigRequestId) &&
            (identical(other.gigRequestTitle, gigRequestTitle) ||
                other.gigRequestTitle == gigRequestTitle) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.lastMessageContent, lastMessageContent) ||
                other.lastMessageContent == lastMessageContent) &&
            (identical(other.lastMessageSenderId, lastMessageSenderId) ||
                other.lastMessageSenderId == lastMessageSenderId) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.listing, listing) || other.listing == listing) &&
            (identical(other.otherUser, otherUser) ||
                other.otherUser == otherUser) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      initiatorId,
      participantId,
      isActive,
      createdAt,
      updatedAt,
      listingId,
      contextType,
      contextId,
      gigRequestId,
      gigRequestTitle,
      lastMessageAt,
      lastMessageContent,
      lastMessageSenderId,
      archivedAt,
      listing,
      otherUser,
      unreadCount);

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      __$$ConversationImplCopyWithImpl<_$ConversationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationImplToJson(
      this,
    );
  }
}

abstract class _Conversation implements Conversation {
  const factory _Conversation(
      {required final int id,
      @JsonKey(name: "initiator_id") required final int initiatorId,
      @JsonKey(name: "participant_id") required final int participantId,
      @JsonKey(name: "is_active") required final bool isActive,
      @JsonKey(name: "created_at") required final String createdAt,
      @JsonKey(name: "updated_at") required final String updatedAt,
      @JsonKey(name: "listing_id") final int? listingId,
      @JsonKey(name: "context_type") final String? contextType,
      @JsonKey(name: "context_id") final int? contextId,
      @JsonKey(name: "gig_request_id") final int? gigRequestId,
      @JsonKey(name: "gig_request_title") final String? gigRequestTitle,
      @JsonKey(name: "last_message_at") final String? lastMessageAt,
      @JsonKey(name: "last_message_content") final String? lastMessageContent,
      @JsonKey(name: "last_message_sender_id") final int? lastMessageSenderId,
      @JsonKey(name: "archived_at") final String? archivedAt,
      final Listing? listing,
      final UserProfile? otherUser,
      @JsonKey(name: "unread_count")
      final int? unreadCount}) = _$ConversationImpl;

  factory _Conversation.fromJson(Map<String, dynamic> json) =
      _$ConversationImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "initiator_id")
  int get initiatorId;
  @override
  @JsonKey(name: "participant_id")
  int get participantId;
  @override
  @JsonKey(name: "is_active")
  bool get isActive;
  @override
  @JsonKey(name: "created_at")
  String get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String
      get updatedAt; // Nullable since the gig-module conversations (`context_type` =
// `gig_request` / `gig_offer` / `gig_booking`) don't carry a listing.
// Legacy listing chats keep `listing_id` populated alongside
// `context_type='listing'` for back-compat with grouped views.
  @override
  @JsonKey(name: "listing_id")
  int? get listingId;
  @override
  @JsonKey(name: "context_type")
  String? get contextType;
  @override
  @JsonKey(name: "context_id")
  int? get contextId;
  @override
  @JsonKey(name: "gig_request_id")
  int? get gigRequestId;
  @override
  @JsonKey(name: "gig_request_title")
  String? get gigRequestTitle;
  @override
  @JsonKey(name: "last_message_at")
  String? get lastMessageAt;
  @override
  @JsonKey(name: "last_message_content")
  String? get lastMessageContent;
  @override
  @JsonKey(name: "last_message_sender_id")
  int? get lastMessageSenderId;
  @override
  @JsonKey(name: "archived_at")
  String? get archivedAt; // Related data
  @override
  Listing? get listing;
  @override
  UserProfile? get otherUser;
  @override
  @JsonKey(name: "unread_count")
  int? get unreadCount;

  /// Create a copy of Conversation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationImplCopyWith<_$ConversationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConversationSummary _$ConversationSummaryFromJson(Map<String, dynamic> json) {
  return _ConversationSummary.fromJson(json);
}

/// @nodoc
mixin _$ConversationSummary {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "initiator_id")
  int get initiatorId => throw _privateConstructorUsedError;
  @JsonKey(name: "participant_id")
  int get participantId => throw _privateConstructorUsedError;
  @JsonKey(name: "is_active")
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_id")
  int? get listingId => throw _privateConstructorUsedError;
  @JsonKey(name: "context_type")
  String? get contextType => throw _privateConstructorUsedError;
  @JsonKey(name: "context_id")
  int? get contextId => throw _privateConstructorUsedError;
  @JsonKey(name: "gig_request_id")
  int? get gigRequestId => throw _privateConstructorUsedError;
  @JsonKey(name: "gig_request_title")
  String? get gigRequestTitle => throw _privateConstructorUsedError;

  /// Gig request category id (`gig_categories.id`) when [contextType] is `gig_request`.
  @JsonKey(name: "gig_category_id")
  int? get gigCategoryId => throw _privateConstructorUsedError;
  @JsonKey(name: "last_message_at")
  String? get lastMessageAt => throw _privateConstructorUsedError;
  @JsonKey(name: "last_message_content")
  String? get lastMessageContent => throw _privateConstructorUsedError;
  @JsonKey(name: "last_message_sender_id")
  int? get lastMessageSenderId => throw _privateConstructorUsedError;
  @JsonKey(name: "archived_at")
  String? get archivedAt => throw _privateConstructorUsedError; // Summary data
  @JsonKey(name: "listing_title")
  String? get listingTitle => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_type_id")
  int? get listingTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_gender")
  int? get listingGender => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_price")
  int? get listingPrice => throw _privateConstructorUsedError;
  @JsonKey(name: "other_user_name")
  String? get otherUserName => throw _privateConstructorUsedError;
  @JsonKey(name: "other_user_avatar")
  String? get otherUserAvatar => throw _privateConstructorUsedError;
  @JsonKey(name: "unread_count")
  int? get unreadCount =>
      throw _privateConstructorUsedError; // Location and metro station data
  @JsonKey(name: "listing_subway_line_id")
  int? get listingSubwayLineId => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_subway_station_id")
  int? get listingSubwayStationId => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_location_id")
  int? get listingLocationId => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station_name_uz")
  String? get subwayStationNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station_name_ru")
  String? get subwayStationNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station_name_en")
  String? get subwayStationNameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station_line")
  int? get subwayStationLine => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station_ordinal")
  int? get subwayStationOrdinal => throw _privateConstructorUsedError;
  @JsonKey(name: "location_name_uz")
  String? get locationNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "location_name_ru")
  String? get locationNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "location_name_en")
  String? get locationNameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "location_short_name_uz")
  String? get locationShortNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "location_short_name_ru")
  String? get locationShortNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "location_short_name_en")
  String? get locationShortNameEn => throw _privateConstructorUsedError;

  /// Serializes this ConversationSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationSummaryCopyWith<ConversationSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationSummaryCopyWith<$Res> {
  factory $ConversationSummaryCopyWith(
          ConversationSummary value, $Res Function(ConversationSummary) then) =
      _$ConversationSummaryCopyWithImpl<$Res, ConversationSummary>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "initiator_id") int initiatorId,
      @JsonKey(name: "participant_id") int participantId,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      @JsonKey(name: "listing_id") int? listingId,
      @JsonKey(name: "context_type") String? contextType,
      @JsonKey(name: "context_id") int? contextId,
      @JsonKey(name: "gig_request_id") int? gigRequestId,
      @JsonKey(name: "gig_request_title") String? gigRequestTitle,
      @JsonKey(name: "gig_category_id") int? gigCategoryId,
      @JsonKey(name: "last_message_at") String? lastMessageAt,
      @JsonKey(name: "last_message_content") String? lastMessageContent,
      @JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,
      @JsonKey(name: "archived_at") String? archivedAt,
      @JsonKey(name: "listing_title") String? listingTitle,
      @JsonKey(name: "listing_type_id") int? listingTypeId,
      @JsonKey(name: "listing_gender") int? listingGender,
      @JsonKey(name: "listing_price") int? listingPrice,
      @JsonKey(name: "other_user_name") String? otherUserName,
      @JsonKey(name: "other_user_avatar") String? otherUserAvatar,
      @JsonKey(name: "unread_count") int? unreadCount,
      @JsonKey(name: "listing_subway_line_id") int? listingSubwayLineId,
      @JsonKey(name: "listing_subway_station_id") int? listingSubwayStationId,
      @JsonKey(name: "listing_location_id") int? listingLocationId,
      @JsonKey(name: "subway_station_name_uz") String? subwayStationNameUz,
      @JsonKey(name: "subway_station_name_ru") String? subwayStationNameRu,
      @JsonKey(name: "subway_station_name_en") String? subwayStationNameEn,
      @JsonKey(name: "subway_station_line") int? subwayStationLine,
      @JsonKey(name: "subway_station_ordinal") int? subwayStationOrdinal,
      @JsonKey(name: "location_name_uz") String? locationNameUz,
      @JsonKey(name: "location_name_ru") String? locationNameRu,
      @JsonKey(name: "location_name_en") String? locationNameEn,
      @JsonKey(name: "location_short_name_uz") String? locationShortNameUz,
      @JsonKey(name: "location_short_name_ru") String? locationShortNameRu,
      @JsonKey(name: "location_short_name_en") String? locationShortNameEn});
}

/// @nodoc
class _$ConversationSummaryCopyWithImpl<$Res, $Val extends ConversationSummary>
    implements $ConversationSummaryCopyWith<$Res> {
  _$ConversationSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initiatorId = null,
    Object? participantId = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? listingId = freezed,
    Object? contextType = freezed,
    Object? contextId = freezed,
    Object? gigRequestId = freezed,
    Object? gigRequestTitle = freezed,
    Object? gigCategoryId = freezed,
    Object? lastMessageAt = freezed,
    Object? lastMessageContent = freezed,
    Object? lastMessageSenderId = freezed,
    Object? archivedAt = freezed,
    Object? listingTitle = freezed,
    Object? listingTypeId = freezed,
    Object? listingGender = freezed,
    Object? listingPrice = freezed,
    Object? otherUserName = freezed,
    Object? otherUserAvatar = freezed,
    Object? unreadCount = freezed,
    Object? listingSubwayLineId = freezed,
    Object? listingSubwayStationId = freezed,
    Object? listingLocationId = freezed,
    Object? subwayStationNameUz = freezed,
    Object? subwayStationNameRu = freezed,
    Object? subwayStationNameEn = freezed,
    Object? subwayStationLine = freezed,
    Object? subwayStationOrdinal = freezed,
    Object? locationNameUz = freezed,
    Object? locationNameRu = freezed,
    Object? locationNameEn = freezed,
    Object? locationShortNameUz = freezed,
    Object? locationShortNameRu = freezed,
    Object? locationShortNameEn = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      initiatorId: null == initiatorId
          ? _value.initiatorId
          : initiatorId // ignore: cast_nullable_to_non_nullable
              as int,
      participantId: null == participantId
          ? _value.participantId
          : participantId // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as int?,
      contextType: freezed == contextType
          ? _value.contextType
          : contextType // ignore: cast_nullable_to_non_nullable
              as String?,
      contextId: freezed == contextId
          ? _value.contextId
          : contextId // ignore: cast_nullable_to_non_nullable
              as int?,
      gigRequestId: freezed == gigRequestId
          ? _value.gigRequestId
          : gigRequestId // ignore: cast_nullable_to_non_nullable
              as int?,
      gigRequestTitle: freezed == gigRequestTitle
          ? _value.gigRequestTitle
          : gigRequestTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      gigCategoryId: freezed == gigCategoryId
          ? _value.gigCategoryId
          : gigCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageContent: freezed == lastMessageContent
          ? _value.lastMessageContent
          : lastMessageContent // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageSenderId: freezed == lastMessageSenderId
          ? _value.lastMessageSenderId
          : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
              as int?,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      listingTitle: freezed == listingTitle
          ? _value.listingTitle
          : listingTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      listingTypeId: freezed == listingTypeId
          ? _value.listingTypeId
          : listingTypeId // ignore: cast_nullable_to_non_nullable
              as int?,
      listingGender: freezed == listingGender
          ? _value.listingGender
          : listingGender // ignore: cast_nullable_to_non_nullable
              as int?,
      listingPrice: freezed == listingPrice
          ? _value.listingPrice
          : listingPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      otherUserName: freezed == otherUserName
          ? _value.otherUserName
          : otherUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserAvatar: freezed == otherUserAvatar
          ? _value.otherUserAvatar
          : otherUserAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      unreadCount: freezed == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int?,
      listingSubwayLineId: freezed == listingSubwayLineId
          ? _value.listingSubwayLineId
          : listingSubwayLineId // ignore: cast_nullable_to_non_nullable
              as int?,
      listingSubwayStationId: freezed == listingSubwayStationId
          ? _value.listingSubwayStationId
          : listingSubwayStationId // ignore: cast_nullable_to_non_nullable
              as int?,
      listingLocationId: freezed == listingLocationId
          ? _value.listingLocationId
          : listingLocationId // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayStationNameUz: freezed == subwayStationNameUz
          ? _value.subwayStationNameUz
          : subwayStationNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationNameRu: freezed == subwayStationNameRu
          ? _value.subwayStationNameRu
          : subwayStationNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationNameEn: freezed == subwayStationNameEn
          ? _value.subwayStationNameEn
          : subwayStationNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationLine: freezed == subwayStationLine
          ? _value.subwayStationLine
          : subwayStationLine // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayStationOrdinal: freezed == subwayStationOrdinal
          ? _value.subwayStationOrdinal
          : subwayStationOrdinal // ignore: cast_nullable_to_non_nullable
              as int?,
      locationNameUz: freezed == locationNameUz
          ? _value.locationNameUz
          : locationNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      locationNameRu: freezed == locationNameRu
          ? _value.locationNameRu
          : locationNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      locationNameEn: freezed == locationNameEn
          ? _value.locationNameEn
          : locationNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      locationShortNameUz: freezed == locationShortNameUz
          ? _value.locationShortNameUz
          : locationShortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      locationShortNameRu: freezed == locationShortNameRu
          ? _value.locationShortNameRu
          : locationShortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      locationShortNameEn: freezed == locationShortNameEn
          ? _value.locationShortNameEn
          : locationShortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ConversationSummaryImplCopyWith<$Res>
    implements $ConversationSummaryCopyWith<$Res> {
  factory _$$ConversationSummaryImplCopyWith(_$ConversationSummaryImpl value,
          $Res Function(_$ConversationSummaryImpl) then) =
      __$$ConversationSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "initiator_id") int initiatorId,
      @JsonKey(name: "participant_id") int participantId,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      @JsonKey(name: "listing_id") int? listingId,
      @JsonKey(name: "context_type") String? contextType,
      @JsonKey(name: "context_id") int? contextId,
      @JsonKey(name: "gig_request_id") int? gigRequestId,
      @JsonKey(name: "gig_request_title") String? gigRequestTitle,
      @JsonKey(name: "gig_category_id") int? gigCategoryId,
      @JsonKey(name: "last_message_at") String? lastMessageAt,
      @JsonKey(name: "last_message_content") String? lastMessageContent,
      @JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,
      @JsonKey(name: "archived_at") String? archivedAt,
      @JsonKey(name: "listing_title") String? listingTitle,
      @JsonKey(name: "listing_type_id") int? listingTypeId,
      @JsonKey(name: "listing_gender") int? listingGender,
      @JsonKey(name: "listing_price") int? listingPrice,
      @JsonKey(name: "other_user_name") String? otherUserName,
      @JsonKey(name: "other_user_avatar") String? otherUserAvatar,
      @JsonKey(name: "unread_count") int? unreadCount,
      @JsonKey(name: "listing_subway_line_id") int? listingSubwayLineId,
      @JsonKey(name: "listing_subway_station_id") int? listingSubwayStationId,
      @JsonKey(name: "listing_location_id") int? listingLocationId,
      @JsonKey(name: "subway_station_name_uz") String? subwayStationNameUz,
      @JsonKey(name: "subway_station_name_ru") String? subwayStationNameRu,
      @JsonKey(name: "subway_station_name_en") String? subwayStationNameEn,
      @JsonKey(name: "subway_station_line") int? subwayStationLine,
      @JsonKey(name: "subway_station_ordinal") int? subwayStationOrdinal,
      @JsonKey(name: "location_name_uz") String? locationNameUz,
      @JsonKey(name: "location_name_ru") String? locationNameRu,
      @JsonKey(name: "location_name_en") String? locationNameEn,
      @JsonKey(name: "location_short_name_uz") String? locationShortNameUz,
      @JsonKey(name: "location_short_name_ru") String? locationShortNameRu,
      @JsonKey(name: "location_short_name_en") String? locationShortNameEn});
}

/// @nodoc
class __$$ConversationSummaryImplCopyWithImpl<$Res>
    extends _$ConversationSummaryCopyWithImpl<$Res, _$ConversationSummaryImpl>
    implements _$$ConversationSummaryImplCopyWith<$Res> {
  __$$ConversationSummaryImplCopyWithImpl(_$ConversationSummaryImpl _value,
      $Res Function(_$ConversationSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initiatorId = null,
    Object? participantId = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? listingId = freezed,
    Object? contextType = freezed,
    Object? contextId = freezed,
    Object? gigRequestId = freezed,
    Object? gigRequestTitle = freezed,
    Object? gigCategoryId = freezed,
    Object? lastMessageAt = freezed,
    Object? lastMessageContent = freezed,
    Object? lastMessageSenderId = freezed,
    Object? archivedAt = freezed,
    Object? listingTitle = freezed,
    Object? listingTypeId = freezed,
    Object? listingGender = freezed,
    Object? listingPrice = freezed,
    Object? otherUserName = freezed,
    Object? otherUserAvatar = freezed,
    Object? unreadCount = freezed,
    Object? listingSubwayLineId = freezed,
    Object? listingSubwayStationId = freezed,
    Object? listingLocationId = freezed,
    Object? subwayStationNameUz = freezed,
    Object? subwayStationNameRu = freezed,
    Object? subwayStationNameEn = freezed,
    Object? subwayStationLine = freezed,
    Object? subwayStationOrdinal = freezed,
    Object? locationNameUz = freezed,
    Object? locationNameRu = freezed,
    Object? locationNameEn = freezed,
    Object? locationShortNameUz = freezed,
    Object? locationShortNameRu = freezed,
    Object? locationShortNameEn = freezed,
  }) {
    return _then(_$ConversationSummaryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      initiatorId: null == initiatorId
          ? _value.initiatorId
          : initiatorId // ignore: cast_nullable_to_non_nullable
              as int,
      participantId: null == participantId
          ? _value.participantId
          : participantId // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      listingId: freezed == listingId
          ? _value.listingId
          : listingId // ignore: cast_nullable_to_non_nullable
              as int?,
      contextType: freezed == contextType
          ? _value.contextType
          : contextType // ignore: cast_nullable_to_non_nullable
              as String?,
      contextId: freezed == contextId
          ? _value.contextId
          : contextId // ignore: cast_nullable_to_non_nullable
              as int?,
      gigRequestId: freezed == gigRequestId
          ? _value.gigRequestId
          : gigRequestId // ignore: cast_nullable_to_non_nullable
              as int?,
      gigRequestTitle: freezed == gigRequestTitle
          ? _value.gigRequestTitle
          : gigRequestTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      gigCategoryId: freezed == gigCategoryId
          ? _value.gigCategoryId
          : gigCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      lastMessageAt: freezed == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageContent: freezed == lastMessageContent
          ? _value.lastMessageContent
          : lastMessageContent // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageSenderId: freezed == lastMessageSenderId
          ? _value.lastMessageSenderId
          : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
              as int?,
      archivedAt: freezed == archivedAt
          ? _value.archivedAt
          : archivedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      listingTitle: freezed == listingTitle
          ? _value.listingTitle
          : listingTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      listingTypeId: freezed == listingTypeId
          ? _value.listingTypeId
          : listingTypeId // ignore: cast_nullable_to_non_nullable
              as int?,
      listingGender: freezed == listingGender
          ? _value.listingGender
          : listingGender // ignore: cast_nullable_to_non_nullable
              as int?,
      listingPrice: freezed == listingPrice
          ? _value.listingPrice
          : listingPrice // ignore: cast_nullable_to_non_nullable
              as int?,
      otherUserName: freezed == otherUserName
          ? _value.otherUserName
          : otherUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserAvatar: freezed == otherUserAvatar
          ? _value.otherUserAvatar
          : otherUserAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      unreadCount: freezed == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int?,
      listingSubwayLineId: freezed == listingSubwayLineId
          ? _value.listingSubwayLineId
          : listingSubwayLineId // ignore: cast_nullable_to_non_nullable
              as int?,
      listingSubwayStationId: freezed == listingSubwayStationId
          ? _value.listingSubwayStationId
          : listingSubwayStationId // ignore: cast_nullable_to_non_nullable
              as int?,
      listingLocationId: freezed == listingLocationId
          ? _value.listingLocationId
          : listingLocationId // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayStationNameUz: freezed == subwayStationNameUz
          ? _value.subwayStationNameUz
          : subwayStationNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationNameRu: freezed == subwayStationNameRu
          ? _value.subwayStationNameRu
          : subwayStationNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationNameEn: freezed == subwayStationNameEn
          ? _value.subwayStationNameEn
          : subwayStationNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationLine: freezed == subwayStationLine
          ? _value.subwayStationLine
          : subwayStationLine // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayStationOrdinal: freezed == subwayStationOrdinal
          ? _value.subwayStationOrdinal
          : subwayStationOrdinal // ignore: cast_nullable_to_non_nullable
              as int?,
      locationNameUz: freezed == locationNameUz
          ? _value.locationNameUz
          : locationNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      locationNameRu: freezed == locationNameRu
          ? _value.locationNameRu
          : locationNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      locationNameEn: freezed == locationNameEn
          ? _value.locationNameEn
          : locationNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      locationShortNameUz: freezed == locationShortNameUz
          ? _value.locationShortNameUz
          : locationShortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      locationShortNameRu: freezed == locationShortNameRu
          ? _value.locationShortNameRu
          : locationShortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      locationShortNameEn: freezed == locationShortNameEn
          ? _value.locationShortNameEn
          : locationShortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationSummaryImpl implements _ConversationSummary {
  const _$ConversationSummaryImpl(
      {required this.id,
      @JsonKey(name: "initiator_id") required this.initiatorId,
      @JsonKey(name: "participant_id") required this.participantId,
      @JsonKey(name: "is_active") required this.isActive,
      @JsonKey(name: "created_at") required this.createdAt,
      @JsonKey(name: "updated_at") required this.updatedAt,
      @JsonKey(name: "listing_id") this.listingId,
      @JsonKey(name: "context_type") this.contextType,
      @JsonKey(name: "context_id") this.contextId,
      @JsonKey(name: "gig_request_id") this.gigRequestId,
      @JsonKey(name: "gig_request_title") this.gigRequestTitle,
      @JsonKey(name: "gig_category_id") this.gigCategoryId,
      @JsonKey(name: "last_message_at") this.lastMessageAt,
      @JsonKey(name: "last_message_content") this.lastMessageContent,
      @JsonKey(name: "last_message_sender_id") this.lastMessageSenderId,
      @JsonKey(name: "archived_at") this.archivedAt,
      @JsonKey(name: "listing_title") this.listingTitle,
      @JsonKey(name: "listing_type_id") this.listingTypeId,
      @JsonKey(name: "listing_gender") this.listingGender,
      @JsonKey(name: "listing_price") this.listingPrice,
      @JsonKey(name: "other_user_name") this.otherUserName,
      @JsonKey(name: "other_user_avatar") this.otherUserAvatar,
      @JsonKey(name: "unread_count") this.unreadCount,
      @JsonKey(name: "listing_subway_line_id") this.listingSubwayLineId,
      @JsonKey(name: "listing_subway_station_id") this.listingSubwayStationId,
      @JsonKey(name: "listing_location_id") this.listingLocationId,
      @JsonKey(name: "subway_station_name_uz") this.subwayStationNameUz,
      @JsonKey(name: "subway_station_name_ru") this.subwayStationNameRu,
      @JsonKey(name: "subway_station_name_en") this.subwayStationNameEn,
      @JsonKey(name: "subway_station_line") this.subwayStationLine,
      @JsonKey(name: "subway_station_ordinal") this.subwayStationOrdinal,
      @JsonKey(name: "location_name_uz") this.locationNameUz,
      @JsonKey(name: "location_name_ru") this.locationNameRu,
      @JsonKey(name: "location_name_en") this.locationNameEn,
      @JsonKey(name: "location_short_name_uz") this.locationShortNameUz,
      @JsonKey(name: "location_short_name_ru") this.locationShortNameRu,
      @JsonKey(name: "location_short_name_en") this.locationShortNameEn});

  factory _$ConversationSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationSummaryImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "initiator_id")
  final int initiatorId;
  @override
  @JsonKey(name: "participant_id")
  final int participantId;
  @override
  @JsonKey(name: "is_active")
  final bool isActive;
  @override
  @JsonKey(name: "created_at")
  final String createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String updatedAt;
  @override
  @JsonKey(name: "listing_id")
  final int? listingId;
  @override
  @JsonKey(name: "context_type")
  final String? contextType;
  @override
  @JsonKey(name: "context_id")
  final int? contextId;
  @override
  @JsonKey(name: "gig_request_id")
  final int? gigRequestId;
  @override
  @JsonKey(name: "gig_request_title")
  final String? gigRequestTitle;

  /// Gig request category id (`gig_categories.id`) when [contextType] is `gig_request`.
  @override
  @JsonKey(name: "gig_category_id")
  final int? gigCategoryId;
  @override
  @JsonKey(name: "last_message_at")
  final String? lastMessageAt;
  @override
  @JsonKey(name: "last_message_content")
  final String? lastMessageContent;
  @override
  @JsonKey(name: "last_message_sender_id")
  final int? lastMessageSenderId;
  @override
  @JsonKey(name: "archived_at")
  final String? archivedAt;
// Summary data
  @override
  @JsonKey(name: "listing_title")
  final String? listingTitle;
  @override
  @JsonKey(name: "listing_type_id")
  final int? listingTypeId;
  @override
  @JsonKey(name: "listing_gender")
  final int? listingGender;
  @override
  @JsonKey(name: "listing_price")
  final int? listingPrice;
  @override
  @JsonKey(name: "other_user_name")
  final String? otherUserName;
  @override
  @JsonKey(name: "other_user_avatar")
  final String? otherUserAvatar;
  @override
  @JsonKey(name: "unread_count")
  final int? unreadCount;
// Location and metro station data
  @override
  @JsonKey(name: "listing_subway_line_id")
  final int? listingSubwayLineId;
  @override
  @JsonKey(name: "listing_subway_station_id")
  final int? listingSubwayStationId;
  @override
  @JsonKey(name: "listing_location_id")
  final int? listingLocationId;
  @override
  @JsonKey(name: "subway_station_name_uz")
  final String? subwayStationNameUz;
  @override
  @JsonKey(name: "subway_station_name_ru")
  final String? subwayStationNameRu;
  @override
  @JsonKey(name: "subway_station_name_en")
  final String? subwayStationNameEn;
  @override
  @JsonKey(name: "subway_station_line")
  final int? subwayStationLine;
  @override
  @JsonKey(name: "subway_station_ordinal")
  final int? subwayStationOrdinal;
  @override
  @JsonKey(name: "location_name_uz")
  final String? locationNameUz;
  @override
  @JsonKey(name: "location_name_ru")
  final String? locationNameRu;
  @override
  @JsonKey(name: "location_name_en")
  final String? locationNameEn;
  @override
  @JsonKey(name: "location_short_name_uz")
  final String? locationShortNameUz;
  @override
  @JsonKey(name: "location_short_name_ru")
  final String? locationShortNameRu;
  @override
  @JsonKey(name: "location_short_name_en")
  final String? locationShortNameEn;

  @override
  String toString() {
    return 'ConversationSummary(id: $id, initiatorId: $initiatorId, participantId: $participantId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, listingId: $listingId, contextType: $contextType, contextId: $contextId, gigRequestId: $gigRequestId, gigRequestTitle: $gigRequestTitle, gigCategoryId: $gigCategoryId, lastMessageAt: $lastMessageAt, lastMessageContent: $lastMessageContent, lastMessageSenderId: $lastMessageSenderId, archivedAt: $archivedAt, listingTitle: $listingTitle, listingTypeId: $listingTypeId, listingGender: $listingGender, listingPrice: $listingPrice, otherUserName: $otherUserName, otherUserAvatar: $otherUserAvatar, unreadCount: $unreadCount, listingSubwayLineId: $listingSubwayLineId, listingSubwayStationId: $listingSubwayStationId, listingLocationId: $listingLocationId, subwayStationNameUz: $subwayStationNameUz, subwayStationNameRu: $subwayStationNameRu, subwayStationNameEn: $subwayStationNameEn, subwayStationLine: $subwayStationLine, subwayStationOrdinal: $subwayStationOrdinal, locationNameUz: $locationNameUz, locationNameRu: $locationNameRu, locationNameEn: $locationNameEn, locationShortNameUz: $locationShortNameUz, locationShortNameRu: $locationShortNameRu, locationShortNameEn: $locationShortNameEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initiatorId, initiatorId) ||
                other.initiatorId == initiatorId) &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.contextType, contextType) ||
                other.contextType == contextType) &&
            (identical(other.contextId, contextId) ||
                other.contextId == contextId) &&
            (identical(other.gigRequestId, gigRequestId) ||
                other.gigRequestId == gigRequestId) &&
            (identical(other.gigRequestTitle, gigRequestTitle) ||
                other.gigRequestTitle == gigRequestTitle) &&
            (identical(other.gigCategoryId, gigCategoryId) ||
                other.gigCategoryId == gigCategoryId) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.lastMessageContent, lastMessageContent) ||
                other.lastMessageContent == lastMessageContent) &&
            (identical(other.lastMessageSenderId, lastMessageSenderId) ||
                other.lastMessageSenderId == lastMessageSenderId) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.listingTitle, listingTitle) ||
                other.listingTitle == listingTitle) &&
            (identical(other.listingTypeId, listingTypeId) ||
                other.listingTypeId == listingTypeId) &&
            (identical(other.listingGender, listingGender) ||
                other.listingGender == listingGender) &&
            (identical(other.listingPrice, listingPrice) ||
                other.listingPrice == listingPrice) &&
            (identical(other.otherUserName, otherUserName) ||
                other.otherUserName == otherUserName) &&
            (identical(other.otherUserAvatar, otherUserAvatar) ||
                other.otherUserAvatar == otherUserAvatar) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.listingSubwayLineId, listingSubwayLineId) ||
                other.listingSubwayLineId == listingSubwayLineId) &&
            (identical(other.listingSubwayStationId, listingSubwayStationId) ||
                other.listingSubwayStationId == listingSubwayStationId) &&
            (identical(other.listingLocationId, listingLocationId) ||
                other.listingLocationId == listingLocationId) &&
            (identical(other.subwayStationNameUz, subwayStationNameUz) ||
                other.subwayStationNameUz == subwayStationNameUz) &&
            (identical(other.subwayStationNameRu, subwayStationNameRu) ||
                other.subwayStationNameRu == subwayStationNameRu) &&
            (identical(other.subwayStationNameEn, subwayStationNameEn) ||
                other.subwayStationNameEn == subwayStationNameEn) &&
            (identical(other.subwayStationLine, subwayStationLine) ||
                other.subwayStationLine == subwayStationLine) &&
            (identical(other.subwayStationOrdinal, subwayStationOrdinal) ||
                other.subwayStationOrdinal == subwayStationOrdinal) &&
            (identical(other.locationNameUz, locationNameUz) ||
                other.locationNameUz == locationNameUz) &&
            (identical(other.locationNameRu, locationNameRu) ||
                other.locationNameRu == locationNameRu) &&
            (identical(other.locationNameEn, locationNameEn) ||
                other.locationNameEn == locationNameEn) &&
            (identical(other.locationShortNameUz, locationShortNameUz) ||
                other.locationShortNameUz == locationShortNameUz) &&
            (identical(other.locationShortNameRu, locationShortNameRu) ||
                other.locationShortNameRu == locationShortNameRu) &&
            (identical(other.locationShortNameEn, locationShortNameEn) ||
                other.locationShortNameEn == locationShortNameEn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        initiatorId,
        participantId,
        isActive,
        createdAt,
        updatedAt,
        listingId,
        contextType,
        contextId,
        gigRequestId,
        gigRequestTitle,
        gigCategoryId,
        lastMessageAt,
        lastMessageContent,
        lastMessageSenderId,
        archivedAt,
        listingTitle,
        listingTypeId,
        listingGender,
        listingPrice,
        otherUserName,
        otherUserAvatar,
        unreadCount,
        listingSubwayLineId,
        listingSubwayStationId,
        listingLocationId,
        subwayStationNameUz,
        subwayStationNameRu,
        subwayStationNameEn,
        subwayStationLine,
        subwayStationOrdinal,
        locationNameUz,
        locationNameRu,
        locationNameEn,
        locationShortNameUz,
        locationShortNameRu,
        locationShortNameEn
      ]);

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationSummaryImplCopyWith<_$ConversationSummaryImpl> get copyWith =>
      __$$ConversationSummaryImplCopyWithImpl<_$ConversationSummaryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationSummaryImplToJson(
      this,
    );
  }
}

abstract class _ConversationSummary implements ConversationSummary {
  const factory _ConversationSummary(
      {required final int id,
      @JsonKey(name: "initiator_id") required final int initiatorId,
      @JsonKey(name: "participant_id") required final int participantId,
      @JsonKey(name: "is_active") required final bool isActive,
      @JsonKey(name: "created_at") required final String createdAt,
      @JsonKey(name: "updated_at") required final String updatedAt,
      @JsonKey(name: "listing_id") final int? listingId,
      @JsonKey(name: "context_type") final String? contextType,
      @JsonKey(name: "context_id") final int? contextId,
      @JsonKey(name: "gig_request_id") final int? gigRequestId,
      @JsonKey(name: "gig_request_title") final String? gigRequestTitle,
      @JsonKey(name: "gig_category_id") final int? gigCategoryId,
      @JsonKey(name: "last_message_at") final String? lastMessageAt,
      @JsonKey(name: "last_message_content") final String? lastMessageContent,
      @JsonKey(name: "last_message_sender_id") final int? lastMessageSenderId,
      @JsonKey(name: "archived_at") final String? archivedAt,
      @JsonKey(name: "listing_title") final String? listingTitle,
      @JsonKey(name: "listing_type_id") final int? listingTypeId,
      @JsonKey(name: "listing_gender") final int? listingGender,
      @JsonKey(name: "listing_price") final int? listingPrice,
      @JsonKey(name: "other_user_name") final String? otherUserName,
      @JsonKey(name: "other_user_avatar") final String? otherUserAvatar,
      @JsonKey(name: "unread_count") final int? unreadCount,
      @JsonKey(name: "listing_subway_line_id") final int? listingSubwayLineId,
      @JsonKey(name: "listing_subway_station_id")
      final int? listingSubwayStationId,
      @JsonKey(name: "listing_location_id") final int? listingLocationId,
      @JsonKey(name: "subway_station_name_uz")
      final String? subwayStationNameUz,
      @JsonKey(name: "subway_station_name_ru")
      final String? subwayStationNameRu,
      @JsonKey(name: "subway_station_name_en")
      final String? subwayStationNameEn,
      @JsonKey(name: "subway_station_line") final int? subwayStationLine,
      @JsonKey(name: "subway_station_ordinal") final int? subwayStationOrdinal,
      @JsonKey(name: "location_name_uz") final String? locationNameUz,
      @JsonKey(name: "location_name_ru") final String? locationNameRu,
      @JsonKey(name: "location_name_en") final String? locationNameEn,
      @JsonKey(name: "location_short_name_uz")
      final String? locationShortNameUz,
      @JsonKey(name: "location_short_name_ru")
      final String? locationShortNameRu,
      @JsonKey(name: "location_short_name_en")
      final String? locationShortNameEn}) = _$ConversationSummaryImpl;

  factory _ConversationSummary.fromJson(Map<String, dynamic> json) =
      _$ConversationSummaryImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "initiator_id")
  int get initiatorId;
  @override
  @JsonKey(name: "participant_id")
  int get participantId;
  @override
  @JsonKey(name: "is_active")
  bool get isActive;
  @override
  @JsonKey(name: "created_at")
  String get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String get updatedAt;
  @override
  @JsonKey(name: "listing_id")
  int? get listingId;
  @override
  @JsonKey(name: "context_type")
  String? get contextType;
  @override
  @JsonKey(name: "context_id")
  int? get contextId;
  @override
  @JsonKey(name: "gig_request_id")
  int? get gigRequestId;
  @override
  @JsonKey(name: "gig_request_title")
  String? get gigRequestTitle;

  /// Gig request category id (`gig_categories.id`) when [contextType] is `gig_request`.
  @override
  @JsonKey(name: "gig_category_id")
  int? get gigCategoryId;
  @override
  @JsonKey(name: "last_message_at")
  String? get lastMessageAt;
  @override
  @JsonKey(name: "last_message_content")
  String? get lastMessageContent;
  @override
  @JsonKey(name: "last_message_sender_id")
  int? get lastMessageSenderId;
  @override
  @JsonKey(name: "archived_at")
  String? get archivedAt; // Summary data
  @override
  @JsonKey(name: "listing_title")
  String? get listingTitle;
  @override
  @JsonKey(name: "listing_type_id")
  int? get listingTypeId;
  @override
  @JsonKey(name: "listing_gender")
  int? get listingGender;
  @override
  @JsonKey(name: "listing_price")
  int? get listingPrice;
  @override
  @JsonKey(name: "other_user_name")
  String? get otherUserName;
  @override
  @JsonKey(name: "other_user_avatar")
  String? get otherUserAvatar;
  @override
  @JsonKey(name: "unread_count")
  int? get unreadCount; // Location and metro station data
  @override
  @JsonKey(name: "listing_subway_line_id")
  int? get listingSubwayLineId;
  @override
  @JsonKey(name: "listing_subway_station_id")
  int? get listingSubwayStationId;
  @override
  @JsonKey(name: "listing_location_id")
  int? get listingLocationId;
  @override
  @JsonKey(name: "subway_station_name_uz")
  String? get subwayStationNameUz;
  @override
  @JsonKey(name: "subway_station_name_ru")
  String? get subwayStationNameRu;
  @override
  @JsonKey(name: "subway_station_name_en")
  String? get subwayStationNameEn;
  @override
  @JsonKey(name: "subway_station_line")
  int? get subwayStationLine;
  @override
  @JsonKey(name: "subway_station_ordinal")
  int? get subwayStationOrdinal;
  @override
  @JsonKey(name: "location_name_uz")
  String? get locationNameUz;
  @override
  @JsonKey(name: "location_name_ru")
  String? get locationNameRu;
  @override
  @JsonKey(name: "location_name_en")
  String? get locationNameEn;
  @override
  @JsonKey(name: "location_short_name_uz")
  String? get locationShortNameUz;
  @override
  @JsonKey(name: "location_short_name_ru")
  String? get locationShortNameRu;
  @override
  @JsonKey(name: "location_short_name_en")
  String? get locationShortNameEn;

  /// Create a copy of ConversationSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationSummaryImplCopyWith<_$ConversationSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
