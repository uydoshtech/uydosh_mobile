import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/message_attachment.dart";
import "package:uy_dosh/domain/models/message_sender.dart";

part "message.freezed.dart";
part "message.g.dart";

@freezed
class Message with _$Message {
  const factory Message({
    required int id,
    @JsonKey(name: "conversation_id") required int conversationId,
    @JsonKey(name: "sender_id") required int senderId,
    required String content,
    @JsonKey(name: "message_type") required String messageType,
    @JsonKey(name: "created_at") required String createdAt, @JsonKey(name: "updated_at") required String updatedAt, @JsonKey(name: "reply_to_message_id") int? replyToMessageId,
    @JsonKey(name: "is_edited") bool? isEdited,
    @JsonKey(name: "edited_at") String? editedAt,
    @JsonKey(name: "is_deleted") bool? isDeleted,
    @JsonKey(name: "deleted_at") String? deletedAt,
    // Related data
    MessageSender? sender,
    List<MessageAttachment>? attachments,
    Message? replyToMessage,
    @JsonKey(name: "is_read_by_current_user") bool? isReadByCurrentUser,
    @JsonKey(name: "is_read_by_recipient") bool? isReadByRecipient,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

@freezed
class MessageType with _$MessageType {
  const factory MessageType.text() = _Text;
  const factory MessageType.image() = _Image;
  const factory MessageType.file() = _File;
  const factory MessageType.location() = _Location;
  const factory MessageType.system() = _System;

  const MessageType._();

  factory MessageType.fromString(String type) {
    switch (type) {
      case "text":
        return const MessageType.text();
      case "image":
        return const MessageType.image();
      case "file":
        return const MessageType.file();
      case "location":
        return const MessageType.location();
      case "system":
        return const MessageType.system();
      default:
        return const MessageType.text();
    }
  }

  String get value {
    return when(
      text: () => "text",
      image: () => "image",
      file: () => "file",
      location: () => "location",
      system: () => "system",
    );
  }
}
