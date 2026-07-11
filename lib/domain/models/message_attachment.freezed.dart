// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageAttachment {

 int get id;@JsonKey(name: "message_id") int get messageId;@JsonKey(name: "file_name") String get fileName;@JsonKey(name: "file_url") String get fileUrl;@JsonKey(name: "file_type") String get fileType;@JsonKey(name: "created_at") String get createdAt;@JsonKey(name: "file_size") int? get fileSize;@JsonKey(name: "mime_type") String? get mimeType;@JsonKey(name: "thumbnail_url") String? get thumbnailUrl;
/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageAttachmentCopyWith<MessageAttachment> get copyWith => _$MessageAttachmentCopyWithImpl<MessageAttachment>(this as MessageAttachment, _$identity);

  /// Serializes this MessageAttachment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,fileName,fileUrl,fileType,createdAt,fileSize,mimeType,thumbnailUrl);

@override
String toString() {
  return 'MessageAttachment(id: $id, messageId: $messageId, fileName: $fileName, fileUrl: $fileUrl, fileType: $fileType, createdAt: $createdAt, fileSize: $fileSize, mimeType: $mimeType, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class $MessageAttachmentCopyWith<$Res>  {
  factory $MessageAttachmentCopyWith(MessageAttachment value, $Res Function(MessageAttachment) _then) = _$MessageAttachmentCopyWithImpl;
@useResult
$Res call({
 int id,@JsonKey(name: "message_id") int messageId,@JsonKey(name: "file_name") String fileName,@JsonKey(name: "file_url") String fileUrl,@JsonKey(name: "file_type") String fileType,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "file_size") int? fileSize,@JsonKey(name: "mime_type") String? mimeType,@JsonKey(name: "thumbnail_url") String? thumbnailUrl
});




}
/// @nodoc
class _$MessageAttachmentCopyWithImpl<$Res>
    implements $MessageAttachmentCopyWith<$Res> {
  _$MessageAttachmentCopyWithImpl(this._self, this._then);

  final MessageAttachment _self;
  final $Res Function(MessageAttachment) _then;

/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? messageId = null,Object? fileName = null,Object? fileUrl = null,Object? fileType = null,Object? createdAt = null,Object? fileSize = freezed,Object? mimeType = freezed,Object? thumbnailUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MessageAttachment].
extension MessageAttachmentPatterns on MessageAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MessageAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MessageAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MessageAttachment value)  $default,){
final _that = this;
switch (_that) {
case _MessageAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MessageAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _MessageAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "message_id")  int messageId, @JsonKey(name: "file_name")  String fileName, @JsonKey(name: "file_url")  String fileUrl, @JsonKey(name: "file_type")  String fileType, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "file_size")  int? fileSize, @JsonKey(name: "mime_type")  String? mimeType, @JsonKey(name: "thumbnail_url")  String? thumbnailUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MessageAttachment() when $default != null:
return $default(_that.id,_that.messageId,_that.fileName,_that.fileUrl,_that.fileType,_that.createdAt,_that.fileSize,_that.mimeType,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id, @JsonKey(name: "message_id")  int messageId, @JsonKey(name: "file_name")  String fileName, @JsonKey(name: "file_url")  String fileUrl, @JsonKey(name: "file_type")  String fileType, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "file_size")  int? fileSize, @JsonKey(name: "mime_type")  String? mimeType, @JsonKey(name: "thumbnail_url")  String? thumbnailUrl)  $default,) {final _that = this;
switch (_that) {
case _MessageAttachment():
return $default(_that.id,_that.messageId,_that.fileName,_that.fileUrl,_that.fileType,_that.createdAt,_that.fileSize,_that.mimeType,_that.thumbnailUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id, @JsonKey(name: "message_id")  int messageId, @JsonKey(name: "file_name")  String fileName, @JsonKey(name: "file_url")  String fileUrl, @JsonKey(name: "file_type")  String fileType, @JsonKey(name: "created_at")  String createdAt, @JsonKey(name: "file_size")  int? fileSize, @JsonKey(name: "mime_type")  String? mimeType, @JsonKey(name: "thumbnail_url")  String? thumbnailUrl)?  $default,) {final _that = this;
switch (_that) {
case _MessageAttachment() when $default != null:
return $default(_that.id,_that.messageId,_that.fileName,_that.fileUrl,_that.fileType,_that.createdAt,_that.fileSize,_that.mimeType,_that.thumbnailUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MessageAttachment implements MessageAttachment {
  const _MessageAttachment({required this.id, @JsonKey(name: "message_id") required this.messageId, @JsonKey(name: "file_name") required this.fileName, @JsonKey(name: "file_url") required this.fileUrl, @JsonKey(name: "file_type") required this.fileType, @JsonKey(name: "created_at") required this.createdAt, @JsonKey(name: "file_size") this.fileSize, @JsonKey(name: "mime_type") this.mimeType, @JsonKey(name: "thumbnail_url") this.thumbnailUrl});
  factory _MessageAttachment.fromJson(Map<String, dynamic> json) => _$MessageAttachmentFromJson(json);

@override final  int id;
@override@JsonKey(name: "message_id") final  int messageId;
@override@JsonKey(name: "file_name") final  String fileName;
@override@JsonKey(name: "file_url") final  String fileUrl;
@override@JsonKey(name: "file_type") final  String fileType;
@override@JsonKey(name: "created_at") final  String createdAt;
@override@JsonKey(name: "file_size") final  int? fileSize;
@override@JsonKey(name: "mime_type") final  String? mimeType;
@override@JsonKey(name: "thumbnail_url") final  String? thumbnailUrl;

/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageAttachmentCopyWith<_MessageAttachment> get copyWith => __$MessageAttachmentCopyWithImpl<_MessageAttachment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageAttachmentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageAttachment&&(identical(other.id, id) || other.id == id)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.fileType, fileType) || other.fileType == fileType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,messageId,fileName,fileUrl,fileType,createdAt,fileSize,mimeType,thumbnailUrl);

@override
String toString() {
  return 'MessageAttachment(id: $id, messageId: $messageId, fileName: $fileName, fileUrl: $fileUrl, fileType: $fileType, createdAt: $createdAt, fileSize: $fileSize, mimeType: $mimeType, thumbnailUrl: $thumbnailUrl)';
}


}

/// @nodoc
abstract mixin class _$MessageAttachmentCopyWith<$Res> implements $MessageAttachmentCopyWith<$Res> {
  factory _$MessageAttachmentCopyWith(_MessageAttachment value, $Res Function(_MessageAttachment) _then) = __$MessageAttachmentCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(name: "message_id") int messageId,@JsonKey(name: "file_name") String fileName,@JsonKey(name: "file_url") String fileUrl,@JsonKey(name: "file_type") String fileType,@JsonKey(name: "created_at") String createdAt,@JsonKey(name: "file_size") int? fileSize,@JsonKey(name: "mime_type") String? mimeType,@JsonKey(name: "thumbnail_url") String? thumbnailUrl
});




}
/// @nodoc
class __$MessageAttachmentCopyWithImpl<$Res>
    implements _$MessageAttachmentCopyWith<$Res> {
  __$MessageAttachmentCopyWithImpl(this._self, this._then);

  final _MessageAttachment _self;
  final $Res Function(_MessageAttachment) _then;

/// Create a copy of MessageAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? messageId = null,Object? fileName = null,Object? fileUrl = null,Object? fileType = null,Object? createdAt = null,Object? fileSize = freezed,Object? mimeType = freezed,Object? thumbnailUrl = freezed,}) {
  return _then(_MessageAttachment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as int,fileName: null == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String,fileUrl: null == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String,fileType: null == fileType ? _self.fileType : fileType // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$AttachmentType {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AttachmentType);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AttachmentType()';
}


}

/// @nodoc
class $AttachmentTypeCopyWith<$Res>  {
$AttachmentTypeCopyWith(AttachmentType _, $Res Function(AttachmentType) __);
}


/// Adds pattern-matching-related methods to [AttachmentType].
extension AttachmentTypePatterns on AttachmentType {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Image value)?  image,TResult Function( _Document value)?  document,TResult Function( _Video value)?  video,TResult Function( _Audio value)?  audio,TResult Function( _Other value)?  other,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Image() when image != null:
return image(_that);case _Document() when document != null:
return document(_that);case _Video() when video != null:
return video(_that);case _Audio() when audio != null:
return audio(_that);case _Other() when other != null:
return other(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Image value)  image,required TResult Function( _Document value)  document,required TResult Function( _Video value)  video,required TResult Function( _Audio value)  audio,required TResult Function( _Other value)  other,}){
final _that = this;
switch (_that) {
case _Image():
return image(_that);case _Document():
return document(_that);case _Video():
return video(_that);case _Audio():
return audio(_that);case _Other():
return other(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Image value)?  image,TResult? Function( _Document value)?  document,TResult? Function( _Video value)?  video,TResult? Function( _Audio value)?  audio,TResult? Function( _Other value)?  other,}){
final _that = this;
switch (_that) {
case _Image() when image != null:
return image(_that);case _Document() when document != null:
return document(_that);case _Video() when video != null:
return video(_that);case _Audio() when audio != null:
return audio(_that);case _Other() when other != null:
return other(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  image,TResult Function()?  document,TResult Function()?  video,TResult Function()?  audio,TResult Function()?  other,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Image() when image != null:
return image();case _Document() when document != null:
return document();case _Video() when video != null:
return video();case _Audio() when audio != null:
return audio();case _Other() when other != null:
return other();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  image,required TResult Function()  document,required TResult Function()  video,required TResult Function()  audio,required TResult Function()  other,}) {final _that = this;
switch (_that) {
case _Image():
return image();case _Document():
return document();case _Video():
return video();case _Audio():
return audio();case _Other():
return other();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  image,TResult? Function()?  document,TResult? Function()?  video,TResult? Function()?  audio,TResult? Function()?  other,}) {final _that = this;
switch (_that) {
case _Image() when image != null:
return image();case _Document() when document != null:
return document();case _Video() when video != null:
return video();case _Audio() when audio != null:
return audio();case _Other() when other != null:
return other();case _:
  return null;

}
}

}

/// @nodoc


class _Image extends AttachmentType {
  const _Image(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Image);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AttachmentType.image()';
}


}




/// @nodoc


class _Document extends AttachmentType {
  const _Document(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Document);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AttachmentType.document()';
}


}




/// @nodoc


class _Video extends AttachmentType {
  const _Video(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Video);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AttachmentType.video()';
}


}




/// @nodoc


class _Audio extends AttachmentType {
  const _Audio(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Audio);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AttachmentType.audio()';
}


}




/// @nodoc


class _Other extends AttachmentType {
  const _Other(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Other);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AttachmentType.other()';
}


}




// dart format on
