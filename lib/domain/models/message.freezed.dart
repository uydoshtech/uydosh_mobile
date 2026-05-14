// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "conversation_id")
  int get conversationId => throw _privateConstructorUsedError;
  @JsonKey(name: "sender_id")
  int get senderId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: "message_type")
  String get messageType => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "reply_to_message_id")
  int? get replyToMessageId => throw _privateConstructorUsedError;
  @JsonKey(name: "is_edited")
  bool? get isEdited => throw _privateConstructorUsedError;
  @JsonKey(name: "edited_at")
  String? get editedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "is_deleted")
  bool? get isDeleted => throw _privateConstructorUsedError;
  @JsonKey(name: "deleted_at")
  String? get deletedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "previous_content")
  String? get previousContent =>
      throw _privateConstructorUsedError; // Related data
  MessageSender? get sender => throw _privateConstructorUsedError;
  List<MessageAttachment>? get attachments =>
      throw _privateConstructorUsedError;
  Message? get replyToMessage => throw _privateConstructorUsedError;
  @JsonKey(name: "is_read_by_current_user")
  bool? get isReadByCurrentUser => throw _privateConstructorUsedError;
  @JsonKey(name: "is_read_by_recipient")
  bool? get isReadByRecipient => throw _privateConstructorUsedError;
  @JsonKey(
      name: "reactions",
      fromJson: _messageReactionsFromJson,
      toJson: _messageReactionsToJson)
  List<MessageReactionCount>? get reactions =>
      throw _privateConstructorUsedError;
  @JsonKey(name: "my_reaction")
  String? get myReaction => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "conversation_id") int conversationId,
      @JsonKey(name: "sender_id") int senderId,
      String content,
      @JsonKey(name: "message_type") String messageType,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      @JsonKey(name: "reply_to_message_id") int? replyToMessageId,
      @JsonKey(name: "is_edited") bool? isEdited,
      @JsonKey(name: "edited_at") String? editedAt,
      @JsonKey(name: "is_deleted") bool? isDeleted,
      @JsonKey(name: "deleted_at") String? deletedAt,
      @JsonKey(name: "previous_content") String? previousContent,
      MessageSender? sender,
      List<MessageAttachment>? attachments,
      Message? replyToMessage,
      @JsonKey(name: "is_read_by_current_user") bool? isReadByCurrentUser,
      @JsonKey(name: "is_read_by_recipient") bool? isReadByRecipient,
      @JsonKey(
          name: "reactions",
          fromJson: _messageReactionsFromJson,
          toJson: _messageReactionsToJson)
      List<MessageReactionCount>? reactions,
      @JsonKey(name: "my_reaction") String? myReaction});

  $MessageSenderCopyWith<$Res>? get sender;
  $MessageCopyWith<$Res>? get replyToMessage;
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? content = null,
    Object? messageType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? replyToMessageId = freezed,
    Object? isEdited = freezed,
    Object? editedAt = freezed,
    Object? isDeleted = freezed,
    Object? deletedAt = freezed,
    Object? previousContent = freezed,
    Object? sender = freezed,
    Object? attachments = freezed,
    Object? replyToMessage = freezed,
    Object? isReadByCurrentUser = freezed,
    Object? isReadByRecipient = freezed,
    Object? reactions = freezed,
    Object? myReaction = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as int?,
      isEdited: freezed == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool?,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: freezed == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      previousContent: freezed == previousContent
          ? _value.previousContent
          : previousContent // ignore: cast_nullable_to_non_nullable
              as String?,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as MessageSender?,
      attachments: freezed == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<MessageAttachment>?,
      replyToMessage: freezed == replyToMessage
          ? _value.replyToMessage
          : replyToMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
      isReadByCurrentUser: freezed == isReadByCurrentUser
          ? _value.isReadByCurrentUser
          : isReadByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      isReadByRecipient: freezed == isReadByRecipient
          ? _value.isReadByRecipient
          : isReadByRecipient // ignore: cast_nullable_to_non_nullable
              as bool?,
      reactions: freezed == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<MessageReactionCount>?,
      myReaction: freezed == myReaction
          ? _value.myReaction
          : myReaction // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageSenderCopyWith<$Res>? get sender {
    if (_value.sender == null) {
      return null;
    }

    return $MessageSenderCopyWith<$Res>(_value.sender!, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageCopyWith<$Res>? get replyToMessage {
    if (_value.replyToMessage == null) {
      return null;
    }

    return $MessageCopyWith<$Res>(_value.replyToMessage!, (value) {
      return _then(_value.copyWith(replyToMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "conversation_id") int conversationId,
      @JsonKey(name: "sender_id") int senderId,
      String content,
      @JsonKey(name: "message_type") String messageType,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      @JsonKey(name: "reply_to_message_id") int? replyToMessageId,
      @JsonKey(name: "is_edited") bool? isEdited,
      @JsonKey(name: "edited_at") String? editedAt,
      @JsonKey(name: "is_deleted") bool? isDeleted,
      @JsonKey(name: "deleted_at") String? deletedAt,
      @JsonKey(name: "previous_content") String? previousContent,
      MessageSender? sender,
      List<MessageAttachment>? attachments,
      Message? replyToMessage,
      @JsonKey(name: "is_read_by_current_user") bool? isReadByCurrentUser,
      @JsonKey(name: "is_read_by_recipient") bool? isReadByRecipient,
      @JsonKey(
          name: "reactions",
          fromJson: _messageReactionsFromJson,
          toJson: _messageReactionsToJson)
      List<MessageReactionCount>? reactions,
      @JsonKey(name: "my_reaction") String? myReaction});

  @override
  $MessageSenderCopyWith<$Res>? get sender;
  @override
  $MessageCopyWith<$Res>? get replyToMessage;
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? conversationId = null,
    Object? senderId = null,
    Object? content = null,
    Object? messageType = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? replyToMessageId = freezed,
    Object? isEdited = freezed,
    Object? editedAt = freezed,
    Object? isDeleted = freezed,
    Object? deletedAt = freezed,
    Object? previousContent = freezed,
    Object? sender = freezed,
    Object? attachments = freezed,
    Object? replyToMessage = freezed,
    Object? isReadByCurrentUser = freezed,
    Object? isReadByRecipient = freezed,
    Object? reactions = freezed,
    Object? myReaction = freezed,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      conversationId: null == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as int,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      replyToMessageId: freezed == replyToMessageId
          ? _value.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as int?,
      isEdited: freezed == isEdited
          ? _value.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool?,
      editedAt: freezed == editedAt
          ? _value.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isDeleted: freezed == isDeleted
          ? _value.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      previousContent: freezed == previousContent
          ? _value.previousContent
          : previousContent // ignore: cast_nullable_to_non_nullable
              as String?,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as MessageSender?,
      attachments: freezed == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<MessageAttachment>?,
      replyToMessage: freezed == replyToMessage
          ? _value.replyToMessage
          : replyToMessage // ignore: cast_nullable_to_non_nullable
              as Message?,
      isReadByCurrentUser: freezed == isReadByCurrentUser
          ? _value.isReadByCurrentUser
          : isReadByCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool?,
      isReadByRecipient: freezed == isReadByRecipient
          ? _value.isReadByRecipient
          : isReadByRecipient // ignore: cast_nullable_to_non_nullable
              as bool?,
      reactions: freezed == reactions
          ? _value._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<MessageReactionCount>?,
      myReaction: freezed == myReaction
          ? _value.myReaction
          : myReaction // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      @JsonKey(name: "conversation_id") required this.conversationId,
      @JsonKey(name: "sender_id") required this.senderId,
      required this.content,
      @JsonKey(name: "message_type") required this.messageType,
      @JsonKey(name: "created_at") required this.createdAt,
      @JsonKey(name: "updated_at") required this.updatedAt,
      @JsonKey(name: "reply_to_message_id") this.replyToMessageId,
      @JsonKey(name: "is_edited") this.isEdited,
      @JsonKey(name: "edited_at") this.editedAt,
      @JsonKey(name: "is_deleted") this.isDeleted,
      @JsonKey(name: "deleted_at") this.deletedAt,
      @JsonKey(name: "previous_content") this.previousContent,
      this.sender,
      final List<MessageAttachment>? attachments,
      this.replyToMessage,
      @JsonKey(name: "is_read_by_current_user") this.isReadByCurrentUser,
      @JsonKey(name: "is_read_by_recipient") this.isReadByRecipient,
      @JsonKey(
          name: "reactions",
          fromJson: _messageReactionsFromJson,
          toJson: _messageReactionsToJson)
      final List<MessageReactionCount>? reactions,
      @JsonKey(name: "my_reaction") this.myReaction})
      : _attachments = attachments,
        _reactions = reactions;

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "conversation_id")
  final int conversationId;
  @override
  @JsonKey(name: "sender_id")
  final int senderId;
  @override
  final String content;
  @override
  @JsonKey(name: "message_type")
  final String messageType;
  @override
  @JsonKey(name: "created_at")
  final String createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String updatedAt;
  @override
  @JsonKey(name: "reply_to_message_id")
  final int? replyToMessageId;
  @override
  @JsonKey(name: "is_edited")
  final bool? isEdited;
  @override
  @JsonKey(name: "edited_at")
  final String? editedAt;
  @override
  @JsonKey(name: "is_deleted")
  final bool? isDeleted;
  @override
  @JsonKey(name: "deleted_at")
  final String? deletedAt;
  @override
  @JsonKey(name: "previous_content")
  final String? previousContent;
// Related data
  @override
  final MessageSender? sender;
  final List<MessageAttachment>? _attachments;
  @override
  List<MessageAttachment>? get attachments {
    final value = _attachments;
    if (value == null) return null;
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Message? replyToMessage;
  @override
  @JsonKey(name: "is_read_by_current_user")
  final bool? isReadByCurrentUser;
  @override
  @JsonKey(name: "is_read_by_recipient")
  final bool? isReadByRecipient;
  final List<MessageReactionCount>? _reactions;
  @override
  @JsonKey(
      name: "reactions",
      fromJson: _messageReactionsFromJson,
      toJson: _messageReactionsToJson)
  List<MessageReactionCount>? get reactions {
    final value = _reactions;
    if (value == null) return null;
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey(name: "my_reaction")
  final String? myReaction;

  @override
  String toString() {
    return 'Message(id: $id, conversationId: $conversationId, senderId: $senderId, content: $content, messageType: $messageType, createdAt: $createdAt, updatedAt: $updatedAt, replyToMessageId: $replyToMessageId, isEdited: $isEdited, editedAt: $editedAt, isDeleted: $isDeleted, deletedAt: $deletedAt, previousContent: $previousContent, sender: $sender, attachments: $attachments, replyToMessage: $replyToMessage, isReadByCurrentUser: $isReadByCurrentUser, isReadByRecipient: $isReadByRecipient, reactions: $reactions, myReaction: $myReaction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.previousContent, previousContent) ||
                other.previousContent == previousContent) &&
            (identical(other.sender, sender) || other.sender == sender) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.replyToMessage, replyToMessage) ||
                other.replyToMessage == replyToMessage) &&
            (identical(other.isReadByCurrentUser, isReadByCurrentUser) ||
                other.isReadByCurrentUser == isReadByCurrentUser) &&
            (identical(other.isReadByRecipient, isReadByRecipient) ||
                other.isReadByRecipient == isReadByRecipient) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions) &&
            (identical(other.myReaction, myReaction) ||
                other.myReaction == myReaction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        conversationId,
        senderId,
        content,
        messageType,
        createdAt,
        updatedAt,
        replyToMessageId,
        isEdited,
        editedAt,
        isDeleted,
        deletedAt,
        previousContent,
        sender,
        const DeepCollectionEquality().hash(_attachments),
        replyToMessage,
        isReadByCurrentUser,
        isReadByRecipient,
        const DeepCollectionEquality().hash(_reactions),
        myReaction
      ]);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final int id,
      @JsonKey(name: "conversation_id") required final int conversationId,
      @JsonKey(name: "sender_id") required final int senderId,
      required final String content,
      @JsonKey(name: "message_type") required final String messageType,
      @JsonKey(name: "created_at") required final String createdAt,
      @JsonKey(name: "updated_at") required final String updatedAt,
      @JsonKey(name: "reply_to_message_id") final int? replyToMessageId,
      @JsonKey(name: "is_edited") final bool? isEdited,
      @JsonKey(name: "edited_at") final String? editedAt,
      @JsonKey(name: "is_deleted") final bool? isDeleted,
      @JsonKey(name: "deleted_at") final String? deletedAt,
      @JsonKey(name: "previous_content") final String? previousContent,
      final MessageSender? sender,
      final List<MessageAttachment>? attachments,
      final Message? replyToMessage,
      @JsonKey(name: "is_read_by_current_user") final bool? isReadByCurrentUser,
      @JsonKey(name: "is_read_by_recipient") final bool? isReadByRecipient,
      @JsonKey(
          name: "reactions",
          fromJson: _messageReactionsFromJson,
          toJson: _messageReactionsToJson)
      final List<MessageReactionCount>? reactions,
      @JsonKey(name: "my_reaction") final String? myReaction}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "conversation_id")
  int get conversationId;
  @override
  @JsonKey(name: "sender_id")
  int get senderId;
  @override
  String get content;
  @override
  @JsonKey(name: "message_type")
  String get messageType;
  @override
  @JsonKey(name: "created_at")
  String get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String get updatedAt;
  @override
  @JsonKey(name: "reply_to_message_id")
  int? get replyToMessageId;
  @override
  @JsonKey(name: "is_edited")
  bool? get isEdited;
  @override
  @JsonKey(name: "edited_at")
  String? get editedAt;
  @override
  @JsonKey(name: "is_deleted")
  bool? get isDeleted;
  @override
  @JsonKey(name: "deleted_at")
  String? get deletedAt;
  @override
  @JsonKey(name: "previous_content")
  String? get previousContent; // Related data
  @override
  MessageSender? get sender;
  @override
  List<MessageAttachment>? get attachments;
  @override
  Message? get replyToMessage;
  @override
  @JsonKey(name: "is_read_by_current_user")
  bool? get isReadByCurrentUser;
  @override
  @JsonKey(name: "is_read_by_recipient")
  bool? get isReadByRecipient;
  @override
  @JsonKey(
      name: "reactions",
      fromJson: _messageReactionsFromJson,
      toJson: _messageReactionsToJson)
  List<MessageReactionCount>? get reactions;
  @override
  @JsonKey(name: "my_reaction")
  String? get myReaction;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MessageType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() text,
    required TResult Function() image,
    required TResult Function() file,
    required TResult Function() location,
    required TResult Function() system,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? text,
    TResult? Function()? image,
    TResult? Function()? file,
    TResult? Function()? location,
    TResult? Function()? system,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? text,
    TResult Function()? image,
    TResult Function()? file,
    TResult Function()? location,
    TResult Function()? system,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Text value) text,
    required TResult Function(_Image value) image,
    required TResult Function(_File value) file,
    required TResult Function(_Location value) location,
    required TResult Function(_System value) system,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Text value)? text,
    TResult? Function(_Image value)? image,
    TResult? Function(_File value)? file,
    TResult? Function(_Location value)? location,
    TResult? Function(_System value)? system,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Text value)? text,
    TResult Function(_Image value)? image,
    TResult Function(_File value)? file,
    TResult Function(_Location value)? location,
    TResult Function(_System value)? system,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageTypeCopyWith<$Res> {
  factory $MessageTypeCopyWith(
          MessageType value, $Res Function(MessageType) then) =
      _$MessageTypeCopyWithImpl<$Res, MessageType>;
}

/// @nodoc
class _$MessageTypeCopyWithImpl<$Res, $Val extends MessageType>
    implements $MessageTypeCopyWith<$Res> {
  _$MessageTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$TextImplCopyWith<$Res> {
  factory _$$TextImplCopyWith(
          _$TextImpl value, $Res Function(_$TextImpl) then) =
      __$$TextImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TextImplCopyWithImpl<$Res>
    extends _$MessageTypeCopyWithImpl<$Res, _$TextImpl>
    implements _$$TextImplCopyWith<$Res> {
  __$$TextImplCopyWithImpl(_$TextImpl _value, $Res Function(_$TextImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$TextImpl extends _Text {
  const _$TextImpl() : super._();

  @override
  String toString() {
    return 'MessageType.text()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$TextImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() text,
    required TResult Function() image,
    required TResult Function() file,
    required TResult Function() location,
    required TResult Function() system,
  }) {
    return text();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? text,
    TResult? Function()? image,
    TResult? Function()? file,
    TResult? Function()? location,
    TResult? Function()? system,
  }) {
    return text?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? text,
    TResult Function()? image,
    TResult Function()? file,
    TResult Function()? location,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Text value) text,
    required TResult Function(_Image value) image,
    required TResult Function(_File value) file,
    required TResult Function(_Location value) location,
    required TResult Function(_System value) system,
  }) {
    return text(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Text value)? text,
    TResult? Function(_Image value)? image,
    TResult? Function(_File value)? file,
    TResult? Function(_Location value)? location,
    TResult? Function(_System value)? system,
  }) {
    return text?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Text value)? text,
    TResult Function(_Image value)? image,
    TResult Function(_File value)? file,
    TResult Function(_Location value)? location,
    TResult Function(_System value)? system,
    required TResult orElse(),
  }) {
    if (text != null) {
      return text(this);
    }
    return orElse();
  }
}

abstract class _Text extends MessageType {
  const factory _Text() = _$TextImpl;
  const _Text._() : super._();
}

/// @nodoc
abstract class _$$ImageImplCopyWith<$Res> {
  factory _$$ImageImplCopyWith(
          _$ImageImpl value, $Res Function(_$ImageImpl) then) =
      __$$ImageImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ImageImplCopyWithImpl<$Res>
    extends _$MessageTypeCopyWithImpl<$Res, _$ImageImpl>
    implements _$$ImageImplCopyWith<$Res> {
  __$$ImageImplCopyWithImpl(
      _$ImageImpl _value, $Res Function(_$ImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ImageImpl extends _Image {
  const _$ImageImpl() : super._();

  @override
  String toString() {
    return 'MessageType.image()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ImageImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() text,
    required TResult Function() image,
    required TResult Function() file,
    required TResult Function() location,
    required TResult Function() system,
  }) {
    return image();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? text,
    TResult? Function()? image,
    TResult? Function()? file,
    TResult? Function()? location,
    TResult? Function()? system,
  }) {
    return image?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? text,
    TResult Function()? image,
    TResult Function()? file,
    TResult Function()? location,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Text value) text,
    required TResult Function(_Image value) image,
    required TResult Function(_File value) file,
    required TResult Function(_Location value) location,
    required TResult Function(_System value) system,
  }) {
    return image(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Text value)? text,
    TResult? Function(_Image value)? image,
    TResult? Function(_File value)? file,
    TResult? Function(_Location value)? location,
    TResult? Function(_System value)? system,
  }) {
    return image?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Text value)? text,
    TResult Function(_Image value)? image,
    TResult Function(_File value)? file,
    TResult Function(_Location value)? location,
    TResult Function(_System value)? system,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this);
    }
    return orElse();
  }
}

abstract class _Image extends MessageType {
  const factory _Image() = _$ImageImpl;
  const _Image._() : super._();
}

/// @nodoc
abstract class _$$FileImplCopyWith<$Res> {
  factory _$$FileImplCopyWith(
          _$FileImpl value, $Res Function(_$FileImpl) then) =
      __$$FileImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FileImplCopyWithImpl<$Res>
    extends _$MessageTypeCopyWithImpl<$Res, _$FileImpl>
    implements _$$FileImplCopyWith<$Res> {
  __$$FileImplCopyWithImpl(_$FileImpl _value, $Res Function(_$FileImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FileImpl extends _File {
  const _$FileImpl() : super._();

  @override
  String toString() {
    return 'MessageType.file()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FileImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() text,
    required TResult Function() image,
    required TResult Function() file,
    required TResult Function() location,
    required TResult Function() system,
  }) {
    return file();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? text,
    TResult? Function()? image,
    TResult? Function()? file,
    TResult? Function()? location,
    TResult? Function()? system,
  }) {
    return file?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? text,
    TResult Function()? image,
    TResult Function()? file,
    TResult Function()? location,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if (file != null) {
      return file();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Text value) text,
    required TResult Function(_Image value) image,
    required TResult Function(_File value) file,
    required TResult Function(_Location value) location,
    required TResult Function(_System value) system,
  }) {
    return file(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Text value)? text,
    TResult? Function(_Image value)? image,
    TResult? Function(_File value)? file,
    TResult? Function(_Location value)? location,
    TResult? Function(_System value)? system,
  }) {
    return file?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Text value)? text,
    TResult Function(_Image value)? image,
    TResult Function(_File value)? file,
    TResult Function(_Location value)? location,
    TResult Function(_System value)? system,
    required TResult orElse(),
  }) {
    if (file != null) {
      return file(this);
    }
    return orElse();
  }
}

abstract class _File extends MessageType {
  const factory _File() = _$FileImpl;
  const _File._() : super._();
}

/// @nodoc
abstract class _$$LocationImplCopyWith<$Res> {
  factory _$$LocationImplCopyWith(
          _$LocationImpl value, $Res Function(_$LocationImpl) then) =
      __$$LocationImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LocationImplCopyWithImpl<$Res>
    extends _$MessageTypeCopyWithImpl<$Res, _$LocationImpl>
    implements _$$LocationImplCopyWith<$Res> {
  __$$LocationImplCopyWithImpl(
      _$LocationImpl _value, $Res Function(_$LocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LocationImpl extends _Location {
  const _$LocationImpl() : super._();

  @override
  String toString() {
    return 'MessageType.location()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LocationImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() text,
    required TResult Function() image,
    required TResult Function() file,
    required TResult Function() location,
    required TResult Function() system,
  }) {
    return location();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? text,
    TResult? Function()? image,
    TResult? Function()? file,
    TResult? Function()? location,
    TResult? Function()? system,
  }) {
    return location?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? text,
    TResult Function()? image,
    TResult Function()? file,
    TResult Function()? location,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if (location != null) {
      return location();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Text value) text,
    required TResult Function(_Image value) image,
    required TResult Function(_File value) file,
    required TResult Function(_Location value) location,
    required TResult Function(_System value) system,
  }) {
    return location(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Text value)? text,
    TResult? Function(_Image value)? image,
    TResult? Function(_File value)? file,
    TResult? Function(_Location value)? location,
    TResult? Function(_System value)? system,
  }) {
    return location?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Text value)? text,
    TResult Function(_Image value)? image,
    TResult Function(_File value)? file,
    TResult Function(_Location value)? location,
    TResult Function(_System value)? system,
    required TResult orElse(),
  }) {
    if (location != null) {
      return location(this);
    }
    return orElse();
  }
}

abstract class _Location extends MessageType {
  const factory _Location() = _$LocationImpl;
  const _Location._() : super._();
}

/// @nodoc
abstract class _$$SystemImplCopyWith<$Res> {
  factory _$$SystemImplCopyWith(
          _$SystemImpl value, $Res Function(_$SystemImpl) then) =
      __$$SystemImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SystemImplCopyWithImpl<$Res>
    extends _$MessageTypeCopyWithImpl<$Res, _$SystemImpl>
    implements _$$SystemImplCopyWith<$Res> {
  __$$SystemImplCopyWithImpl(
      _$SystemImpl _value, $Res Function(_$SystemImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$SystemImpl extends _System {
  const _$SystemImpl() : super._();

  @override
  String toString() {
    return 'MessageType.system()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SystemImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() text,
    required TResult Function() image,
    required TResult Function() file,
    required TResult Function() location,
    required TResult Function() system,
  }) {
    return system();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? text,
    TResult? Function()? image,
    TResult? Function()? file,
    TResult? Function()? location,
    TResult? Function()? system,
  }) {
    return system?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? text,
    TResult Function()? image,
    TResult Function()? file,
    TResult Function()? location,
    TResult Function()? system,
    required TResult orElse(),
  }) {
    if (system != null) {
      return system();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Text value) text,
    required TResult Function(_Image value) image,
    required TResult Function(_File value) file,
    required TResult Function(_Location value) location,
    required TResult Function(_System value) system,
  }) {
    return system(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Text value)? text,
    TResult? Function(_Image value)? image,
    TResult? Function(_File value)? file,
    TResult? Function(_Location value)? location,
    TResult? Function(_System value)? system,
  }) {
    return system?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Text value)? text,
    TResult Function(_Image value)? image,
    TResult Function(_File value)? file,
    TResult Function(_Location value)? location,
    TResult Function(_System value)? system,
    required TResult orElse(),
  }) {
    if (system != null) {
      return system(this);
    }
    return orElse();
  }
}

abstract class _System extends MessageType {
  const factory _System() = _$SystemImpl;
  const _System._() : super._();
}
