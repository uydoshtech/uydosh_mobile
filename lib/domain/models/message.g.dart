// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: (json['id'] as num).toInt(),
      conversationId: (json['conversation_id'] as num).toInt(),
      senderId: (json['sender_id'] as num).toInt(),
      content: json['content'] as String,
      messageType: json['message_type'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      replyToMessageId: (json['reply_to_message_id'] as num?)?.toInt(),
      isEdited: json['is_edited'] as bool?,
      editedAt: json['edited_at'] as String?,
      isDeleted: json['is_deleted'] as bool?,
      deletedAt: json['deleted_at'] as String?,
      sender: json['sender'] == null
          ? null
          : MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => MessageAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      replyToMessage: json['replyToMessage'] == null
          ? null
          : Message.fromJson(json['replyToMessage'] as Map<String, dynamic>),
      isReadByCurrentUser: json['is_read_by_current_user'] as bool?,
      isReadByRecipient: json['is_read_by_recipient'] as bool?,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'sender_id': instance.senderId,
      'content': instance.content,
      'message_type': instance.messageType,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'reply_to_message_id': instance.replyToMessageId,
      'is_edited': instance.isEdited,
      'edited_at': instance.editedAt,
      'is_deleted': instance.isDeleted,
      'deleted_at': instance.deletedAt,
      'sender': instance.sender,
      'attachments': instance.attachments,
      'replyToMessage': instance.replyToMessage,
      'is_read_by_current_user': instance.isReadByCurrentUser,
      'is_read_by_recipient': instance.isReadByRecipient,
    };
