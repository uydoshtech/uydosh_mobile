// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_attachment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageAttachmentImpl _$$MessageAttachmentImplFromJson(
  Map<String, dynamic> json,
) => _$MessageAttachmentImpl(
  id: (json['id'] as num).toInt(),
  messageId: (json['message_id'] as num).toInt(),
  fileName: json['file_name'] as String,
  fileUrl: json['file_url'] as String,
  fileType: json['file_type'] as String,
  createdAt: json['created_at'] as String,
  fileSize: (json['file_size'] as num?)?.toInt(),
  mimeType: json['mime_type'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
);

Map<String, dynamic> _$$MessageAttachmentImplToJson(
  _$MessageAttachmentImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'message_id': instance.messageId,
  'file_name': instance.fileName,
  'file_url': instance.fileUrl,
  'file_type': instance.fileType,
  'created_at': instance.createdAt,
  'file_size': instance.fileSize,
  'mime_type': instance.mimeType,
  'thumbnail_url': instance.thumbnailUrl,
};
