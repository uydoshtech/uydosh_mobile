// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messaging_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateConversationRequest _$CreateConversationRequestFromJson(
  Map<String, dynamic> json,
) => CreateConversationRequest(
  listingId: (json['listing_id'] as num).toInt(),
  participantId: (json['participant_id'] as num).toInt(),
);

Map<String, dynamic> _$CreateConversationRequestToJson(
  CreateConversationRequest instance,
) => <String, dynamic>{
  'listing_id': instance.listingId,
  'participant_id': instance.participantId,
};

SendMessageRequest _$SendMessageRequestFromJson(Map<String, dynamic> json) =>
    SendMessageRequest(
      content: json['content'] as String,
      messageType: json['message_type'] as String? ?? 'text',
      replyToMessageId: (json['reply_to_message_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SendMessageRequestToJson(SendMessageRequest instance) =>
    <String, dynamic>{
      'content': instance.content,
      'message_type': instance.messageType,
      'reply_to_message_id': instance.replyToMessageId,
    };

MarkMessagesAsReadRequest _$MarkMessagesAsReadRequestFromJson(
  Map<String, dynamic> json,
) => MarkMessagesAsReadRequest(
  conversationId: (json['conversation_id'] as num).toInt(),
);

Map<String, dynamic> _$MarkMessagesAsReadRequestToJson(
  MarkMessagesAsReadRequest instance,
) => <String, dynamic>{'conversation_id': instance.conversationId};

UploadAttachmentRequest _$UploadAttachmentRequestFromJson(
  Map<String, dynamic> json,
) => UploadAttachmentRequest(
  messageId: (json['message_id'] as num).toInt(),
  fileName: json['file_name'] as String,
  fileType: json['file_type'] as String,
  fileSize: (json['file_size'] as num).toInt(),
  mimeType: json['mime_type'] as String?,
);

Map<String, dynamic> _$UploadAttachmentRequestToJson(
  UploadAttachmentRequest instance,
) => <String, dynamic>{
  'message_id': instance.messageId,
  'file_name': instance.fileName,
  'file_type': instance.fileType,
  'file_size': instance.fileSize,
  'mime_type': instance.mimeType,
};

UnreadCountResponse _$UnreadCountResponseFromJson(Map<String, dynamic> json) =>
    UnreadCountResponse(count: (json['count'] as num).toInt());

Map<String, dynamic> _$UnreadCountResponseToJson(
  UnreadCountResponse instance,
) => <String, dynamic>{'count': instance.count};
