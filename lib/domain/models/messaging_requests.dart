import 'package:json_annotation/json_annotation.dart';
import 'package:uy_dosh/base/api/client/json_encodable.dart';

part 'messaging_requests.g.dart';

@JsonSerializable()
class CreateConversationRequest implements IJsonEncodable {
  const CreateConversationRequest({
    required this.listingId,
    required this.participantId,
  });

  @JsonKey(name: 'listing_id')
  final int listingId;

  @JsonKey(name: 'participant_id')
  final int participantId;

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateConversationRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}

@JsonSerializable()
class SendMessageRequest implements IJsonEncodable {
  const SendMessageRequest({
    required this.content,
    this.messageType = 'text',
    this.replyToMessageId,
  });

  final String content;

  @JsonKey(name: 'message_type')
  final String messageType;

  @JsonKey(name: 'reply_to_message_id')
  final int? replyToMessageId;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}

@JsonSerializable()
class MarkMessagesAsReadRequest implements IJsonEncodable {
  const MarkMessagesAsReadRequest({required this.conversationId});

  @JsonKey(name: 'conversation_id')
  final int conversationId;

  factory MarkMessagesAsReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MarkMessagesAsReadRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MarkMessagesAsReadRequestToJson(this);
}

@JsonSerializable()
class UploadAttachmentRequest implements IJsonEncodable {
  const UploadAttachmentRequest({
    required this.messageId,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.mimeType,
  });

  @JsonKey(name: 'message_id')
  final int messageId;

  @JsonKey(name: 'file_name')
  final String fileName;

  @JsonKey(name: 'file_type')
  final String fileType;

  @JsonKey(name: 'file_size')
  final int fileSize;

  @JsonKey(name: 'mime_type')
  final String? mimeType;

  factory UploadAttachmentRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadAttachmentRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UploadAttachmentRequestToJson(this);
}

@JsonSerializable()
class UnreadCountResponse {
  const UnreadCountResponse({required this.count});

  final int count;

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
}
