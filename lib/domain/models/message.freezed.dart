// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Message {

 int get id;@JsonKey(name: "conversation_id") int get conversationId;@JsonKey(name: "sender_id") int get senderId; String get content;@JsonKey(name: "message_type") String get messageType;@JsonKey(name: "created_at") String get createdAt;@JsonKey(name: "updated_at") String get updatedAt;@JsonKey(name: "reply_to_message_id") int? get replyToMessageId;@JsonKey(name: "is_edited") bool? get isEdited;@JsonKey(name: "edited_at") String? get editedAt;@JsonKey(name: "is_deleted") bool? get isDeleted;@JsonKey(name: "deleted_at") String? get deletedAt;@JsonKey(name: "previous_content") String? get previousContent;// Related data
 MessageSender? get sender; List<MessageAttachment>? get attachments;@JsonKey(name: "reply_to_message") Message? get replyToMessage;@JsonKey(name: "is_read_by_current_user") bool? get isReadByCurrentUser;@JsonKey(name: "is_read_by_recipient") bool? get isReadByRecipient;@JsonKey(name: "reactions", fromJson: _messageReactionsFromJson, toJson: _messageReactionsToJson) List<MessageReactionCount>? get reactions;@JsonKey(name: "my_reaction") String? get myReaction;@JsonKey(name: "listing_rating", fromJson: _listingRatingFromJson, toJson: _listingRatingToJson) MessageListingRating? get listingRating;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.content, content) || other.content == content)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.previousContent, previousContent) || other.previousContent == previousContent)&&(identical(other.sender, sender) || other.sender == sender)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.replyToMessage, replyToMessage) || other.replyToMessage == replyToMessage)&&(identical(other.isReadByCurrentUser, isReadByCurrentUser) || other.isReadByCurrentUser == isReadByCurrentUser)&&(identical(other.isReadByRecipient, isReadByRecipient) || other.isReadByRecipient == isReadByRecipient)&&const DeepCollectionEquality().equals(other.reactions, reactions)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&(identical(other.listingRating, listingRating) || other.listingRating == listingRating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,conversationId,senderId,content,messageType,createdAt,updatedAt,replyToMessageId,isEdited,editedAt,isDeleted,deletedAt,previousContent,sender,const DeepCollectionEquality().hash(attachments),replyToMessage,isReadByCurrentUser,isReadByRecipient,const DeepCollectionEquality().hash(reactions),myReaction,listingRating]);

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, content: $content, messageType: $messageType, createdAt: $createdAt, updatedAt: $updatedAt, replyToMessageId: $replyToMessageId, isEdited: $isEdited, editedAt: $editedAt, isDeleted: $isDeleted, deletedAt: $deletedAt, previousContent: $previousContent, sender: $sender, attachments: $attachments, replyToMessage: $replyToMessage, isReadByCurrentUser: $isReadByCurrentUser, isReadByRecipient: $isReadByRecipient, reactions: $reactions, myReaction: $myReaction, listingRating: $listingRating)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "conversation_id") int conversationId,@JsonKey(name: "sender_id") int senderId, String content,@JsonKey(name: "message_type") String messageType,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "reply_to_message_id") int? replyToMessageId,@JsonKey(name: "is_edited") bool? isEdited,@JsonKey(name: "edited_at") String? editedAt,@JsonKey(name: "is_deleted") bool? isDeleted,@JsonKey(name: "deleted_at") String? deletedAt,@JsonKey(name: "previous_content") String? previousContent, MessageSender? sender, List<MessageAttachment>? attachments,@JsonKey(name: "reply_to_message") Message? replyToMessage,@JsonKey(name: "is_read_by_current_user") bool? isReadByCurrentUser,@JsonKey(name: "is_read_by_recipient") bool? isReadByRecipient,@JsonKey(name: "reactions", fromJson: _messageReactionsFromJson, toJson: _messageReactionsToJson) List<MessageReactionCount>? reactions,@JsonKey(name: "my_reaction") String? myReaction,@JsonKey(name: "listing_rating", fromJson: _listingRatingFromJson, toJson: _listingRatingToJson) MessageListingRating? listingRating
});


$MessageSenderCopyWith<$Res>? get sender;$MessageCopyWith<$Res>? get replyToMessage;

}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? content = null,Object? messageType = null,Object? createdAt = null,Object? updatedAt = null,Object? replyToMessageId = freezed,Object? isEdited = freezed,Object? editedAt = freezed,Object? isDeleted = freezed,Object? deletedAt = freezed,Object? previousContent = freezed,Object? sender = freezed,Object? attachments = freezed,Object? replyToMessage = freezed,Object? isReadByCurrentUser = freezed,Object? isReadByRecipient = freezed,Object? reactions = freezed,Object? myReaction = freezed,Object? listingRating = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as int,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as int?,isEdited: freezed == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: freezed == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,previousContent: freezed == previousContent ? _self.previousContent : previousContent // ignore: cast_nullable_to_non_nullable
as String?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender?,attachments: freezed == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<MessageAttachment>?,replyToMessage: freezed == replyToMessage ? _self.replyToMessage : replyToMessage // ignore: cast_nullable_to_non_nullable
as Message?,isReadByCurrentUser: freezed == isReadByCurrentUser ? _self.isReadByCurrentUser : isReadByCurrentUser // ignore: cast_nullable_to_non_nullable
as bool?,isReadByRecipient: freezed == isReadByRecipient ? _self.isReadByRecipient : isReadByRecipient // ignore: cast_nullable_to_non_nullable
as bool?,reactions: freezed == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<MessageReactionCount>?,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as String?,listingRating: freezed == listingRating ? _self.listingRating : listingRating // ignore: cast_nullable_to_non_nullable
as MessageListingRating?,
  ));
}
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $MessageSenderCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get replyToMessage {
    if (_self.replyToMessage == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.replyToMessage!, (value) {
    return _then(_self.copyWith(replyToMessage: value));
  });
}
}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "conversation_id")  int conversationId, @JsonKey(name: "sender_id")  int senderId,  String content, @JsonKey(name: "message_type")  String messageType, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "reply_to_message_id")  int? replyToMessageId, @JsonKey(name: "is_edited")  bool? isEdited, @JsonKey(name: "edited_at")  String? editedAt, @JsonKey(name: "is_deleted")  bool? isDeleted, @JsonKey(name: "deleted_at")  String? deletedAt, @JsonKey(name: "previous_content")  String? previousContent,  MessageSender? sender,  List<MessageAttachment>? attachments, @JsonKey(name: "reply_to_message")  Message? replyToMessage, @JsonKey(name: "is_read_by_current_user")  bool? isReadByCurrentUser, @JsonKey(name: "is_read_by_recipient")  bool? isReadByRecipient, @JsonKey(name: "reactions", fromJson: _messageReactionsFromJson, toJson: _messageReactionsToJson)  List<MessageReactionCount>? reactions, @JsonKey(name: "my_reaction")  String? myReaction, @JsonKey(name: "listing_rating", fromJson: _listingRatingFromJson, toJson: _listingRatingToJson)  MessageListingRating? listingRating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.content,_that.messageType,_that.createdAt,_that.updatedAt,_that.replyToMessageId,_that.isEdited,_that.editedAt,_that.isDeleted,_that.deletedAt,_that.previousContent,_that.sender,_that.attachments,_that.replyToMessage,_that.isReadByCurrentUser,_that.isReadByRecipient,_that.reactions,_that.myReaction,_that.listingRating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "conversation_id")  int conversationId, @JsonKey(name: "sender_id")  int senderId,  String content, @JsonKey(name: "message_type")  String messageType, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "reply_to_message_id")  int? replyToMessageId, @JsonKey(name: "is_edited")  bool? isEdited, @JsonKey(name: "edited_at")  String? editedAt, @JsonKey(name: "is_deleted")  bool? isDeleted, @JsonKey(name: "deleted_at")  String? deletedAt, @JsonKey(name: "previous_content")  String? previousContent,  MessageSender? sender,  List<MessageAttachment>? attachments, @JsonKey(name: "reply_to_message")  Message? replyToMessage, @JsonKey(name: "is_read_by_current_user")  bool? isReadByCurrentUser, @JsonKey(name: "is_read_by_recipient")  bool? isReadByRecipient, @JsonKey(name: "reactions", fromJson: _messageReactionsFromJson, toJson: _messageReactionsToJson)  List<MessageReactionCount>? reactions, @JsonKey(name: "my_reaction")  String? myReaction, @JsonKey(name: "listing_rating", fromJson: _listingRatingFromJson, toJson: _listingRatingToJson)  MessageListingRating? listingRating)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.conversationId,_that.senderId,_that.content,_that.messageType,_that.createdAt,_that.updatedAt,_that.replyToMessageId,_that.isEdited,_that.editedAt,_that.isDeleted,_that.deletedAt,_that.previousContent,_that.sender,_that.attachments,_that.replyToMessage,_that.isReadByCurrentUser,_that.isReadByRecipient,_that.reactions,_that.myReaction,_that.listingRating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "conversation_id")  int conversationId, @JsonKey(name: "sender_id")  int senderId,  String content, @JsonKey(name: "message_type")  String messageType, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "updated_at")  String updatedAt, @JsonKey(name: "reply_to_message_id")  int? replyToMessageId, @JsonKey(name: "is_edited")  bool? isEdited, @JsonKey(name: "edited_at")  String? editedAt, @JsonKey(name: "is_deleted")  bool? isDeleted, @JsonKey(name: "deleted_at")  String? deletedAt, @JsonKey(name: "previous_content")  String? previousContent,  MessageSender? sender,  List<MessageAttachment>? attachments, @JsonKey(name: "reply_to_message")  Message? replyToMessage, @JsonKey(name: "is_read_by_current_user")  bool? isReadByCurrentUser, @JsonKey(name: "is_read_by_recipient")  bool? isReadByRecipient, @JsonKey(name: "reactions", fromJson: _messageReactionsFromJson, toJson: _messageReactionsToJson)  List<MessageReactionCount>? reactions, @JsonKey(name: "my_reaction")  String? myReaction, @JsonKey(name: "listing_rating", fromJson: _listingRatingFromJson, toJson: _listingRatingToJson)  MessageListingRating? listingRating)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.conversationId,_that.senderId,_that.content,_that.messageType,_that.createdAt,_that.updatedAt,_that.replyToMessageId,_that.isEdited,_that.editedAt,_that.isDeleted,_that.deletedAt,_that.previousContent,_that.sender,_that.attachments,_that.replyToMessage,_that.isReadByCurrentUser,_that.isReadByRecipient,_that.reactions,_that.myReaction,_that.listingRating);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message implements Message {
  const _Message({required this.id, @JsonKey(name: "conversation_id") required this.conversationId, @JsonKey(name: "sender_id") required this.senderId, required this.content, @JsonKey(name: "message_type") required this.messageType, @JsonKey(name: "created_at") required this.createdAt, @JsonKey(name: "updated_at") required this.updatedAt, @JsonKey(name: "reply_to_message_id") this.replyToMessageId, @JsonKey(name: "is_edited") this.isEdited, @JsonKey(name: "edited_at") this.editedAt, @JsonKey(name: "is_deleted") this.isDeleted, @JsonKey(name: "deleted_at") this.deletedAt, @JsonKey(name: "previous_content") this.previousContent, this.sender, final  List<MessageAttachment>? attachments, @JsonKey(name: "reply_to_message") this.replyToMessage, @JsonKey(name: "is_read_by_current_user") this.isReadByCurrentUser, @JsonKey(name: "is_read_by_recipient") this.isReadByRecipient, @JsonKey(name: "reactions", fromJson: _messageReactionsFromJson, toJson: _messageReactionsToJson) final  List<MessageReactionCount>? reactions, @JsonKey(name: "my_reaction") this.myReaction, @JsonKey(name: "listing_rating", fromJson: _listingRatingFromJson, toJson: _listingRatingToJson) this.listingRating}): _attachments = attachments,_reactions = reactions;
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override final  int id;
@override@JsonKey(name: "conversation_id") final  int conversationId;
@override@JsonKey(name: "sender_id") final  int senderId;
@override final  String content;
@override@JsonKey(name: "message_type") final  String messageType;
@override@JsonKey(name: "created_at") final  String createdAt;
@override@JsonKey(name: "updated_at") final  String updatedAt;
@override@JsonKey(name: "reply_to_message_id") final  int? replyToMessageId;
@override@JsonKey(name: "is_edited") final  bool? isEdited;
@override@JsonKey(name: "edited_at") final  String? editedAt;
@override@JsonKey(name: "is_deleted") final  bool? isDeleted;
@override@JsonKey(name: "deleted_at") final  String? deletedAt;
@override@JsonKey(name: "previous_content") final  String? previousContent;
// Related data
@override final  MessageSender? sender;
 final  List<MessageAttachment>? _attachments;
@override List<MessageAttachment>? get attachments {
  final value = _attachments;
  if (value == null) return null;
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: "reply_to_message") final  Message? replyToMessage;
@override@JsonKey(name: "is_read_by_current_user") final  bool? isReadByCurrentUser;
@override@JsonKey(name: "is_read_by_recipient") final  bool? isReadByRecipient;
 final  List<MessageReactionCount>? _reactions;
@override@JsonKey(name: "reactions", fromJson: _messageReactionsFromJson, toJson: _messageReactionsToJson) List<MessageReactionCount>? get reactions {
  final value = _reactions;
  if (value == null) return null;
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: "my_reaction") final  String? myReaction;
@override@JsonKey(name: "listing_rating", fromJson: _listingRatingFromJson, toJson: _listingRatingToJson) final  MessageListingRating? listingRating;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.content, content) || other.content == content)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.replyToMessageId, replyToMessageId) || other.replyToMessageId == replyToMessageId)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.previousContent, previousContent) || other.previousContent == previousContent)&&(identical(other.sender, sender) || other.sender == sender)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.replyToMessage, replyToMessage) || other.replyToMessage == replyToMessage)&&(identical(other.isReadByCurrentUser, isReadByCurrentUser) || other.isReadByCurrentUser == isReadByCurrentUser)&&(identical(other.isReadByRecipient, isReadByRecipient) || other.isReadByRecipient == isReadByRecipient)&&const DeepCollectionEquality().equals(other._reactions, _reactions)&&(identical(other.myReaction, myReaction) || other.myReaction == myReaction)&&(identical(other.listingRating, listingRating) || other.listingRating == listingRating));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,conversationId,senderId,content,messageType,createdAt,updatedAt,replyToMessageId,isEdited,editedAt,isDeleted,deletedAt,previousContent,sender,const DeepCollectionEquality().hash(_attachments),replyToMessage,isReadByCurrentUser,isReadByRecipient,const DeepCollectionEquality().hash(_reactions),myReaction,listingRating]);

@override
String toString() {
  return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, content: $content, messageType: $messageType, createdAt: $createdAt, updatedAt: $updatedAt, replyToMessageId: $replyToMessageId, isEdited: $isEdited, editedAt: $editedAt, isDeleted: $isDeleted, deletedAt: $deletedAt, previousContent: $previousContent, sender: $sender, attachments: $attachments, replyToMessage: $replyToMessage, isReadByCurrentUser: $isReadByCurrentUser, isReadByRecipient: $isReadByRecipient, reactions: $reactions, myReaction: $myReaction, listingRating: $listingRating)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "conversation_id") int conversationId,@JsonKey(name: "sender_id") int senderId, String content,@JsonKey(name: "message_type") String messageType,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "updated_at") String updatedAt,@JsonKey(name: "reply_to_message_id") int? replyToMessageId,@JsonKey(name: "is_edited") bool? isEdited,@JsonKey(name: "edited_at") String? editedAt,@JsonKey(name: "is_deleted") bool? isDeleted,@JsonKey(name: "deleted_at") String? deletedAt,@JsonKey(name: "previous_content") String? previousContent, MessageSender? sender, List<MessageAttachment>? attachments,@JsonKey(name: "reply_to_message") Message? replyToMessage,@JsonKey(name: "is_read_by_current_user") bool? isReadByCurrentUser,@JsonKey(name: "is_read_by_recipient") bool? isReadByRecipient,@JsonKey(name: "reactions", fromJson: _messageReactionsFromJson, toJson: _messageReactionsToJson) List<MessageReactionCount>? reactions,@JsonKey(name: "my_reaction") String? myReaction,@JsonKey(name: "listing_rating", fromJson: _listingRatingFromJson, toJson: _listingRatingToJson) MessageListingRating? listingRating
});


@override $MessageSenderCopyWith<$Res>? get sender;@override $MessageCopyWith<$Res>? get replyToMessage;

}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? senderId = null,Object? content = null,Object? messageType = null,Object? createdAt = null,Object? updatedAt = null,Object? replyToMessageId = freezed,Object? isEdited = freezed,Object? editedAt = freezed,Object? isDeleted = freezed,Object? deletedAt = freezed,Object? previousContent = freezed,Object? sender = freezed,Object? attachments = freezed,Object? replyToMessage = freezed,Object? isReadByCurrentUser = freezed,Object? isReadByRecipient = freezed,Object? reactions = freezed,Object? myReaction = freezed,Object? listingRating = freezed,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as int,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as int,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String,replyToMessageId: freezed == replyToMessageId ? _self.replyToMessageId : replyToMessageId // ignore: cast_nullable_to_non_nullable
as int?,isEdited: freezed == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool?,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as String?,isDeleted: freezed == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as String?,previousContent: freezed == previousContent ? _self.previousContent : previousContent // ignore: cast_nullable_to_non_nullable
as String?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as MessageSender?,attachments: freezed == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<MessageAttachment>?,replyToMessage: freezed == replyToMessage ? _self.replyToMessage : replyToMessage // ignore: cast_nullable_to_non_nullable
as Message?,isReadByCurrentUser: freezed == isReadByCurrentUser ? _self.isReadByCurrentUser : isReadByCurrentUser // ignore: cast_nullable_to_non_nullable
as bool?,isReadByRecipient: freezed == isReadByRecipient ? _self.isReadByRecipient : isReadByRecipient // ignore: cast_nullable_to_non_nullable
as bool?,reactions: freezed == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<MessageReactionCount>?,myReaction: freezed == myReaction ? _self.myReaction : myReaction // ignore: cast_nullable_to_non_nullable
as String?,listingRating: freezed == listingRating ? _self.listingRating : listingRating // ignore: cast_nullable_to_non_nullable
as MessageListingRating?,
  ));
}

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageSenderCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $MessageSenderCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get replyToMessage {
    if (_self.replyToMessage == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.replyToMessage!, (value) {
    return _then(_self.copyWith(replyToMessage: value));
  });
}
}

/// @nodoc
mixin _$MessageType {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageType()';
}


}

/// @nodoc
class $MessageTypeCopyWith<$Res>  {
$MessageTypeCopyWith(MessageType _, $Res Function(MessageType) __);
}


/// Adds pattern-matching-related methods to [MessageType].
extension MessageTypePatterns on MessageType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Text value)?  text,TResult Function( _Image value)?  image,TResult Function( _File value)?  file,TResult Function( _Location value)?  location,TResult Function( _System value)?  system,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Text() when text != null:
return text(_that);case _Image() when image != null:
return image(_that);case _File() when file != null:
return file(_that);case _Location() when location != null:
return location(_that);case _System() when system != null:
return system(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Text value)  text,required TResult Function( _Image value)  image,required TResult Function( _File value)  file,required TResult Function( _Location value)  location,required TResult Function( _System value)  system,}){
final _that = this;
switch (_that) {
case _Text():
return text(_that);case _Image():
return image(_that);case _File():
return file(_that);case _Location():
return location(_that);case _System():
return system(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Text value)?  text,TResult? Function( _Image value)?  image,TResult? Function( _File value)?  file,TResult? Function( _Location value)?  location,TResult? Function( _System value)?  system,}){
final _that = this;
switch (_that) {
case _Text() when text != null:
return text(_that);case _Image() when image != null:
return image(_that);case _File() when file != null:
return file(_that);case _Location() when location != null:
return location(_that);case _System() when system != null:
return system(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  text,TResult Function()?  image,TResult Function()?  file,TResult Function()?  location,TResult Function()?  system,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Text() when text != null:
return text();case _Image() when image != null:
return image();case _File() when file != null:
return file();case _Location() when location != null:
return location();case _System() when system != null:
return system();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  text,required TResult Function()  image,required TResult Function()  file,required TResult Function()  location,required TResult Function()  system,}) {final _that = this;
switch (_that) {
case _Text():
return text();case _Image():
return image();case _File():
return file();case _Location():
return location();case _System():
return system();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  text,TResult? Function()?  image,TResult? Function()?  file,TResult? Function()?  location,TResult? Function()?  system,}) {final _that = this;
switch (_that) {
case _Text() when text != null:
return text();case _Image() when image != null:
return image();case _File() when file != null:
return file();case _Location() when location != null:
return location();case _System() when system != null:
return system();case _:
  return null;

}
}

}

/// @nodoc


class _Text extends MessageType {
  const _Text(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Text);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageType.text()';
}


}




/// @nodoc


class _Image extends MessageType {
  const _Image(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Image);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageType.image()';
}


}




/// @nodoc


class _File extends MessageType {
  const _File(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _File);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageType.file()';
}


}




/// @nodoc


class _Location extends MessageType {
  const _Location(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Location);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageType.location()';
}


}




/// @nodoc


class _System extends MessageType {
  const _System(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _System);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MessageType.system()';
}


}




// dart format on
