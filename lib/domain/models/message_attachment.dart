import "package:freezed_annotation/freezed_annotation.dart";

part "message_attachment.freezed.dart";
part "message_attachment.g.dart";

@freezed
class MessageAttachment with _$MessageAttachment {
  const factory MessageAttachment({
    required int id,
    @JsonKey(name: "message_id") required int messageId,
    @JsonKey(name: "file_name") required String fileName,
    @JsonKey(name: "file_url") required String fileUrl,
    @JsonKey(name: "file_type") required String fileType,
    @JsonKey(name: "created_at") required String createdAt, @JsonKey(name: "file_size") int? fileSize,
    @JsonKey(name: "mime_type") String? mimeType,
    @JsonKey(name: "thumbnail_url") String? thumbnailUrl,
  }) = _MessageAttachment;

  factory MessageAttachment.fromJson(Map<String, dynamic> json) =>
      _$MessageAttachmentFromJson(json);
}

@freezed
class AttachmentType with _$AttachmentType {
  const factory AttachmentType.image() = _Image;
  const factory AttachmentType.document() = _Document;
  const factory AttachmentType.video() = _Video;
  const factory AttachmentType.audio() = _Audio;
  const factory AttachmentType.other() = _Other;

  const AttachmentType._();

  factory AttachmentType.fromString(String type) {
    switch (type.toLowerCase()) {
      case "image":
        return const AttachmentType.image();
      case "document":
        return const AttachmentType.document();
      case "video":
        return const AttachmentType.video();
      case "audio":
        return const AttachmentType.audio();
      default:
        return const AttachmentType.other();
    }
  }

  String get value {
    return when(
      image: () => "image",
      document: () => "document",
      video: () => "video",
      audio: () => "audio",
      other: () => "other",
    );
  }

  String get displayName {
    return when(
      image: () => "Image",
      document: () => "Document",
      video: () => "Video",
      audio: () => "Audio",
      other: () => "File",
    );
  }
}
