import "package:json_annotation/json_annotation.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";

part "messaging_requests.g.dart";

/// Request body for `POST /conversations`.
///
/// Two valid shapes today:
///   - Listing chat: `listingId` + `participantId`.
///   - Gig-request chat: `contextType='gig_request'` + `contextId=<requestId>`.
///     The server overwrites `participant_id` with the gig request's owner;
///     callers can omit it.
///   - Gig booking chat: `contextType='gig_booking'` + `contextId=<bookingId>`.
///     The server sets `participant_id` to the other party on the booking;
///     callers can omit it.
///
/// We intentionally serialize `null` keys as absent (`includeIfNull: false`)
/// so the backend's "exactly one shape" validation isn't tripped by stray
/// nulls when the gig path is used.
@JsonSerializable(includeIfNull: false)
class CreateConversationRequest implements IJsonEncodable {
  const CreateConversationRequest({
    this.listingId,
    this.participantId,
    this.contextType,
    this.contextId,
  });

  factory CreateConversationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateConversationRequestFromJson(json);

  @JsonKey(name: "listing_id")
  final int? listingId;

  @JsonKey(name: "participant_id")
  final int? participantId;

  @JsonKey(name: "context_type")
  final String? contextType;

  @JsonKey(name: "context_id")
  final int? contextId;

  @override
  Map<String, dynamic> toJson() => _$CreateConversationRequestToJson(this);
}

@JsonSerializable()
class SendMessageRequest implements IJsonEncodable {
  const SendMessageRequest({
    required this.content,
    this.messageType = "text",
    this.replyToMessageId,
  });

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);

  final String content;

  @JsonKey(name: "message_type")
  final String messageType;

  @JsonKey(name: "reply_to_message_id")
  final int? replyToMessageId;

  @override
  Map<String, dynamic> toJson() => _$SendMessageRequestToJson(this);
}

@JsonSerializable()
class MarkMessagesAsReadRequest implements IJsonEncodable {
  const MarkMessagesAsReadRequest({required this.conversationId});

  factory MarkMessagesAsReadRequest.fromJson(Map<String, dynamic> json) =>
      _$MarkMessagesAsReadRequestFromJson(json);

  @JsonKey(name: "conversation_id")
  final int conversationId;

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

  factory UploadAttachmentRequest.fromJson(Map<String, dynamic> json) =>
      _$UploadAttachmentRequestFromJson(json);

  @JsonKey(name: "message_id")
  final int messageId;

  @JsonKey(name: "file_name")
  final String fileName;

  @JsonKey(name: "file_type")
  final String fileType;

  @JsonKey(name: "file_size")
  final int fileSize;

  @JsonKey(name: "mime_type")
  final String? mimeType;

  @override
  Map<String, dynamic> toJson() => _$UploadAttachmentRequestToJson(this);
}

@JsonSerializable()
class UnreadCountResponse {
  const UnreadCountResponse({required this.count});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);

  final int count;
}
