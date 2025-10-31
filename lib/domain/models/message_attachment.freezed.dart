// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageAttachment _$MessageAttachmentFromJson(Map<String, dynamic> json) {
  return _MessageAttachment.fromJson(json);
}

/// @nodoc
mixin _$MessageAttachment {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'message_id')
  int get messageId => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_name')
  String get fileName => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_url')
  String get fileUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_type')
  String get fileType => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size')
  int? get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'mime_type')
  String? get mimeType => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MessageAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageAttachmentCopyWith<MessageAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageAttachmentCopyWith<$Res> {
  factory $MessageAttachmentCopyWith(
    MessageAttachment value,
    $Res Function(MessageAttachment) then,
  ) = _$MessageAttachmentCopyWithImpl<$Res, MessageAttachment>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'message_id') int messageId,
    @JsonKey(name: 'file_name') String fileName,
    @JsonKey(name: 'file_url') String fileUrl,
    @JsonKey(name: 'file_type') String fileType,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class _$MessageAttachmentCopyWithImpl<$Res, $Val extends MessageAttachment>
    implements $MessageAttachmentCopyWith<$Res> {
  _$MessageAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? fileName = null,
    Object? fileUrl = null,
    Object? fileType = null,
    Object? fileSize = freezed,
    Object? mimeType = freezed,
    Object? thumbnailUrl = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            messageId:
                null == messageId
                    ? _value.messageId
                    : messageId // ignore: cast_nullable_to_non_nullable
                        as int,
            fileName:
                null == fileName
                    ? _value.fileName
                    : fileName // ignore: cast_nullable_to_non_nullable
                        as String,
            fileUrl:
                null == fileUrl
                    ? _value.fileUrl
                    : fileUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            fileType:
                null == fileType
                    ? _value.fileType
                    : fileType // ignore: cast_nullable_to_non_nullable
                        as String,
            fileSize:
                freezed == fileSize
                    ? _value.fileSize
                    : fileSize // ignore: cast_nullable_to_non_nullable
                        as int?,
            mimeType:
                freezed == mimeType
                    ? _value.mimeType
                    : mimeType // ignore: cast_nullable_to_non_nullable
                        as String?,
            thumbnailUrl:
                freezed == thumbnailUrl
                    ? _value.thumbnailUrl
                    : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageAttachmentImplCopyWith<$Res>
    implements $MessageAttachmentCopyWith<$Res> {
  factory _$$MessageAttachmentImplCopyWith(
    _$MessageAttachmentImpl value,
    $Res Function(_$MessageAttachmentImpl) then,
  ) = __$$MessageAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'message_id') int messageId,
    @JsonKey(name: 'file_name') String fileName,
    @JsonKey(name: 'file_url') String fileUrl,
    @JsonKey(name: 'file_type') String fileType,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class __$$MessageAttachmentImplCopyWithImpl<$Res>
    extends _$MessageAttachmentCopyWithImpl<$Res, _$MessageAttachmentImpl>
    implements _$$MessageAttachmentImplCopyWith<$Res> {
  __$$MessageAttachmentImplCopyWithImpl(
    _$MessageAttachmentImpl _value,
    $Res Function(_$MessageAttachmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messageId = null,
    Object? fileName = null,
    Object? fileUrl = null,
    Object? fileType = null,
    Object? fileSize = freezed,
    Object? mimeType = freezed,
    Object? thumbnailUrl = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$MessageAttachmentImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        messageId:
            null == messageId
                ? _value.messageId
                : messageId // ignore: cast_nullable_to_non_nullable
                    as int,
        fileName:
            null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                    as String,
        fileUrl:
            null == fileUrl
                ? _value.fileUrl
                : fileUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        fileType:
            null == fileType
                ? _value.fileType
                : fileType // ignore: cast_nullable_to_non_nullable
                    as String,
        fileSize:
            freezed == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                    as int?,
        mimeType:
            freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                    as String?,
        thumbnailUrl:
            freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageAttachmentImpl implements _MessageAttachment {
  const _$MessageAttachmentImpl({
    required this.id,
    @JsonKey(name: 'message_id') required this.messageId,
    @JsonKey(name: 'file_name') required this.fileName,
    @JsonKey(name: 'file_url') required this.fileUrl,
    @JsonKey(name: 'file_type') required this.fileType,
    @JsonKey(name: 'file_size') this.fileSize,
    @JsonKey(name: 'mime_type') this.mimeType,
    @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$MessageAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageAttachmentImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'message_id')
  final int messageId;
  @override
  @JsonKey(name: 'file_name')
  final String fileName;
  @override
  @JsonKey(name: 'file_url')
  final String fileUrl;
  @override
  @JsonKey(name: 'file_type')
  final String fileType;
  @override
  @JsonKey(name: 'file_size')
  final int? fileSize;
  @override
  @JsonKey(name: 'mime_type')
  final String? mimeType;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'MessageAttachment(id: $id, messageId: $messageId, fileName: $fileName, fileUrl: $fileUrl, fileType: $fileType, fileSize: $fileSize, mimeType: $mimeType, thumbnailUrl: $thumbnailUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageAttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.messageId, messageId) ||
                other.messageId == messageId) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.fileType, fileType) ||
                other.fileType == fileType) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    messageId,
    fileName,
    fileUrl,
    fileType,
    fileSize,
    mimeType,
    thumbnailUrl,
    createdAt,
  );

  /// Create a copy of MessageAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageAttachmentImplCopyWith<_$MessageAttachmentImpl> get copyWith =>
      __$$MessageAttachmentImplCopyWithImpl<_$MessageAttachmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageAttachmentImplToJson(this);
  }
}

abstract class _MessageAttachment implements MessageAttachment {
  const factory _MessageAttachment({
    required final int id,
    @JsonKey(name: 'message_id') required final int messageId,
    @JsonKey(name: 'file_name') required final String fileName,
    @JsonKey(name: 'file_url') required final String fileUrl,
    @JsonKey(name: 'file_type') required final String fileType,
    @JsonKey(name: 'file_size') final int? fileSize,
    @JsonKey(name: 'mime_type') final String? mimeType,
    @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
    @JsonKey(name: 'created_at') required final String createdAt,
  }) = _$MessageAttachmentImpl;

  factory _MessageAttachment.fromJson(Map<String, dynamic> json) =
      _$MessageAttachmentImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'message_id')
  int get messageId;
  @override
  @JsonKey(name: 'file_name')
  String get fileName;
  @override
  @JsonKey(name: 'file_url')
  String get fileUrl;
  @override
  @JsonKey(name: 'file_type')
  String get fileType;
  @override
  @JsonKey(name: 'file_size')
  int? get fileSize;
  @override
  @JsonKey(name: 'mime_type')
  String? get mimeType;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of MessageAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageAttachmentImplCopyWith<_$MessageAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AttachmentType {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() image,
    required TResult Function() document,
    required TResult Function() video,
    required TResult Function() audio,
    required TResult Function() other,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? image,
    TResult? Function()? document,
    TResult? Function()? video,
    TResult? Function()? audio,
    TResult? Function()? other,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? image,
    TResult Function()? document,
    TResult Function()? video,
    TResult Function()? audio,
    TResult Function()? other,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Image value) image,
    required TResult Function(_Document value) document,
    required TResult Function(_Video value) video,
    required TResult Function(_Audio value) audio,
    required TResult Function(_Other value) other,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Image value)? image,
    TResult? Function(_Document value)? document,
    TResult? Function(_Video value)? video,
    TResult? Function(_Audio value)? audio,
    TResult? Function(_Other value)? other,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Image value)? image,
    TResult Function(_Document value)? document,
    TResult Function(_Video value)? video,
    TResult Function(_Audio value)? audio,
    TResult Function(_Other value)? other,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AttachmentTypeCopyWith<$Res> {
  factory $AttachmentTypeCopyWith(
    AttachmentType value,
    $Res Function(AttachmentType) then,
  ) = _$AttachmentTypeCopyWithImpl<$Res, AttachmentType>;
}

/// @nodoc
class _$AttachmentTypeCopyWithImpl<$Res, $Val extends AttachmentType>
    implements $AttachmentTypeCopyWith<$Res> {
  _$AttachmentTypeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AttachmentType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ImageImplCopyWith<$Res> {
  factory _$$ImageImplCopyWith(
    _$ImageImpl value,
    $Res Function(_$ImageImpl) then,
  ) = __$$ImageImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ImageImplCopyWithImpl<$Res>
    extends _$AttachmentTypeCopyWithImpl<$Res, _$ImageImpl>
    implements _$$ImageImplCopyWith<$Res> {
  __$$ImageImplCopyWithImpl(
    _$ImageImpl _value,
    $Res Function(_$ImageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttachmentType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ImageImpl extends _Image {
  const _$ImageImpl() : super._();

  @override
  String toString() {
    return 'AttachmentType.image()';
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
    required TResult Function() image,
    required TResult Function() document,
    required TResult Function() video,
    required TResult Function() audio,
    required TResult Function() other,
  }) {
    return image();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? image,
    TResult? Function()? document,
    TResult? Function()? video,
    TResult? Function()? audio,
    TResult? Function()? other,
  }) {
    return image?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? image,
    TResult Function()? document,
    TResult Function()? video,
    TResult Function()? audio,
    TResult Function()? other,
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
    required TResult Function(_Image value) image,
    required TResult Function(_Document value) document,
    required TResult Function(_Video value) video,
    required TResult Function(_Audio value) audio,
    required TResult Function(_Other value) other,
  }) {
    return image(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Image value)? image,
    TResult? Function(_Document value)? document,
    TResult? Function(_Video value)? video,
    TResult? Function(_Audio value)? audio,
    TResult? Function(_Other value)? other,
  }) {
    return image?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Image value)? image,
    TResult Function(_Document value)? document,
    TResult Function(_Video value)? video,
    TResult Function(_Audio value)? audio,
    TResult Function(_Other value)? other,
    required TResult orElse(),
  }) {
    if (image != null) {
      return image(this);
    }
    return orElse();
  }
}

abstract class _Image extends AttachmentType {
  const factory _Image() = _$ImageImpl;
  const _Image._() : super._();
}

/// @nodoc
abstract class _$$DocumentImplCopyWith<$Res> {
  factory _$$DocumentImplCopyWith(
    _$DocumentImpl value,
    $Res Function(_$DocumentImpl) then,
  ) = __$$DocumentImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$DocumentImplCopyWithImpl<$Res>
    extends _$AttachmentTypeCopyWithImpl<$Res, _$DocumentImpl>
    implements _$$DocumentImplCopyWith<$Res> {
  __$$DocumentImplCopyWithImpl(
    _$DocumentImpl _value,
    $Res Function(_$DocumentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttachmentType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$DocumentImpl extends _Document {
  const _$DocumentImpl() : super._();

  @override
  String toString() {
    return 'AttachmentType.document()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$DocumentImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() image,
    required TResult Function() document,
    required TResult Function() video,
    required TResult Function() audio,
    required TResult Function() other,
  }) {
    return document();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? image,
    TResult? Function()? document,
    TResult? Function()? video,
    TResult? Function()? audio,
    TResult? Function()? other,
  }) {
    return document?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? image,
    TResult Function()? document,
    TResult Function()? video,
    TResult Function()? audio,
    TResult Function()? other,
    required TResult orElse(),
  }) {
    if (document != null) {
      return document();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Image value) image,
    required TResult Function(_Document value) document,
    required TResult Function(_Video value) video,
    required TResult Function(_Audio value) audio,
    required TResult Function(_Other value) other,
  }) {
    return document(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Image value)? image,
    TResult? Function(_Document value)? document,
    TResult? Function(_Video value)? video,
    TResult? Function(_Audio value)? audio,
    TResult? Function(_Other value)? other,
  }) {
    return document?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Image value)? image,
    TResult Function(_Document value)? document,
    TResult Function(_Video value)? video,
    TResult Function(_Audio value)? audio,
    TResult Function(_Other value)? other,
    required TResult orElse(),
  }) {
    if (document != null) {
      return document(this);
    }
    return orElse();
  }
}

abstract class _Document extends AttachmentType {
  const factory _Document() = _$DocumentImpl;
  const _Document._() : super._();
}

/// @nodoc
abstract class _$$VideoImplCopyWith<$Res> {
  factory _$$VideoImplCopyWith(
    _$VideoImpl value,
    $Res Function(_$VideoImpl) then,
  ) = __$$VideoImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$VideoImplCopyWithImpl<$Res>
    extends _$AttachmentTypeCopyWithImpl<$Res, _$VideoImpl>
    implements _$$VideoImplCopyWith<$Res> {
  __$$VideoImplCopyWithImpl(
    _$VideoImpl _value,
    $Res Function(_$VideoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttachmentType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$VideoImpl extends _Video {
  const _$VideoImpl() : super._();

  @override
  String toString() {
    return 'AttachmentType.video()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$VideoImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() image,
    required TResult Function() document,
    required TResult Function() video,
    required TResult Function() audio,
    required TResult Function() other,
  }) {
    return video();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? image,
    TResult? Function()? document,
    TResult? Function()? video,
    TResult? Function()? audio,
    TResult? Function()? other,
  }) {
    return video?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? image,
    TResult Function()? document,
    TResult Function()? video,
    TResult Function()? audio,
    TResult Function()? other,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Image value) image,
    required TResult Function(_Document value) document,
    required TResult Function(_Video value) video,
    required TResult Function(_Audio value) audio,
    required TResult Function(_Other value) other,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Image value)? image,
    TResult? Function(_Document value)? document,
    TResult? Function(_Video value)? video,
    TResult? Function(_Audio value)? audio,
    TResult? Function(_Other value)? other,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Image value)? image,
    TResult Function(_Document value)? document,
    TResult Function(_Video value)? video,
    TResult Function(_Audio value)? audio,
    TResult Function(_Other value)? other,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class _Video extends AttachmentType {
  const factory _Video() = _$VideoImpl;
  const _Video._() : super._();
}

/// @nodoc
abstract class _$$AudioImplCopyWith<$Res> {
  factory _$$AudioImplCopyWith(
    _$AudioImpl value,
    $Res Function(_$AudioImpl) then,
  ) = __$$AudioImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AudioImplCopyWithImpl<$Res>
    extends _$AttachmentTypeCopyWithImpl<$Res, _$AudioImpl>
    implements _$$AudioImplCopyWith<$Res> {
  __$$AudioImplCopyWithImpl(
    _$AudioImpl _value,
    $Res Function(_$AudioImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttachmentType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AudioImpl extends _Audio {
  const _$AudioImpl() : super._();

  @override
  String toString() {
    return 'AttachmentType.audio()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AudioImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() image,
    required TResult Function() document,
    required TResult Function() video,
    required TResult Function() audio,
    required TResult Function() other,
  }) {
    return audio();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? image,
    TResult? Function()? document,
    TResult? Function()? video,
    TResult? Function()? audio,
    TResult? Function()? other,
  }) {
    return audio?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? image,
    TResult Function()? document,
    TResult Function()? video,
    TResult Function()? audio,
    TResult Function()? other,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Image value) image,
    required TResult Function(_Document value) document,
    required TResult Function(_Video value) video,
    required TResult Function(_Audio value) audio,
    required TResult Function(_Other value) other,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Image value)? image,
    TResult? Function(_Document value)? document,
    TResult? Function(_Video value)? video,
    TResult? Function(_Audio value)? audio,
    TResult? Function(_Other value)? other,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Image value)? image,
    TResult Function(_Document value)? document,
    TResult Function(_Video value)? video,
    TResult Function(_Audio value)? audio,
    TResult Function(_Other value)? other,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }
}

abstract class _Audio extends AttachmentType {
  const factory _Audio() = _$AudioImpl;
  const _Audio._() : super._();
}

/// @nodoc
abstract class _$$OtherImplCopyWith<$Res> {
  factory _$$OtherImplCopyWith(
    _$OtherImpl value,
    $Res Function(_$OtherImpl) then,
  ) = __$$OtherImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$OtherImplCopyWithImpl<$Res>
    extends _$AttachmentTypeCopyWithImpl<$Res, _$OtherImpl>
    implements _$$OtherImplCopyWith<$Res> {
  __$$OtherImplCopyWithImpl(
    _$OtherImpl _value,
    $Res Function(_$OtherImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AttachmentType
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$OtherImpl extends _Other {
  const _$OtherImpl() : super._();

  @override
  String toString() {
    return 'AttachmentType.other()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$OtherImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() image,
    required TResult Function() document,
    required TResult Function() video,
    required TResult Function() audio,
    required TResult Function() other,
  }) {
    return other();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? image,
    TResult? Function()? document,
    TResult? Function()? video,
    TResult? Function()? audio,
    TResult? Function()? other,
  }) {
    return other?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? image,
    TResult Function()? document,
    TResult Function()? video,
    TResult Function()? audio,
    TResult Function()? other,
    required TResult orElse(),
  }) {
    if (other != null) {
      return other();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Image value) image,
    required TResult Function(_Document value) document,
    required TResult Function(_Video value) video,
    required TResult Function(_Audio value) audio,
    required TResult Function(_Other value) other,
  }) {
    return other(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Image value)? image,
    TResult? Function(_Document value)? document,
    TResult? Function(_Video value)? video,
    TResult? Function(_Audio value)? audio,
    TResult? Function(_Other value)? other,
  }) {
    return other?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Image value)? image,
    TResult Function(_Document value)? document,
    TResult Function(_Video value)? video,
    TResult Function(_Audio value)? audio,
    TResult Function(_Other value)? other,
    required TResult orElse(),
  }) {
    if (other != null) {
      return other(this);
    }
    return orElse();
  }
}

abstract class _Other extends AttachmentType {
  const factory _Other() = _$OtherImpl;
  const _Other._() : super._();
}
