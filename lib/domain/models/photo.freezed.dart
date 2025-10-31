// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Photo _$PhotoFromJson(Map<String, dynamic> json) {
  return _Photo.fromJson(json);
}

/// @nodoc
mixin _$Photo {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String get photoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_order')
  int get photoOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_primary')
  bool get isPrimary => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Photo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoCopyWith<Photo> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoCopyWith<$Res> {
  factory $PhotoCopyWith(Photo value, $Res Function(Photo) then) =
      _$PhotoCopyWithImpl<$Res, Photo>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'photo_url') String photoUrl,
    @JsonKey(name: 'photo_order') int photoOrder,
    @JsonKey(name: 'is_primary') bool isPrimary,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class _$PhotoCopyWithImpl<$Res, $Val extends Photo>
    implements $PhotoCopyWith<$Res> {
  _$PhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photoUrl = null,
    Object? photoOrder = null,
    Object? isPrimary = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            photoUrl:
                null == photoUrl
                    ? _value.photoUrl
                    : photoUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            photoOrder:
                null == photoOrder
                    ? _value.photoOrder
                    : photoOrder // ignore: cast_nullable_to_non_nullable
                        as int,
            isPrimary:
                null == isPrimary
                    ? _value.isPrimary
                    : isPrimary // ignore: cast_nullable_to_non_nullable
                        as bool,
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
abstract class _$$PhotoImplCopyWith<$Res> implements $PhotoCopyWith<$Res> {
  factory _$$PhotoImplCopyWith(
    _$PhotoImpl value,
    $Res Function(_$PhotoImpl) then,
  ) = __$$PhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'photo_url') String photoUrl,
    @JsonKey(name: 'photo_order') int photoOrder,
    @JsonKey(name: 'is_primary') bool isPrimary,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class __$$PhotoImplCopyWithImpl<$Res>
    extends _$PhotoCopyWithImpl<$Res, _$PhotoImpl>
    implements _$$PhotoImplCopyWith<$Res> {
  __$$PhotoImplCopyWithImpl(
    _$PhotoImpl _value,
    $Res Function(_$PhotoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? photoUrl = null,
    Object? photoOrder = null,
    Object? isPrimary = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$PhotoImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        photoUrl:
            null == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        photoOrder:
            null == photoOrder
                ? _value.photoOrder
                : photoOrder // ignore: cast_nullable_to_non_nullable
                    as int,
        isPrimary:
            null == isPrimary
                ? _value.isPrimary
                : isPrimary // ignore: cast_nullable_to_non_nullable
                    as bool,
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
class _$PhotoImpl implements _Photo {
  const _$PhotoImpl({
    required this.id,
    @JsonKey(name: 'photo_url') required this.photoUrl,
    @JsonKey(name: 'photo_order') required this.photoOrder,
    @JsonKey(name: 'is_primary') required this.isPrimary,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$PhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'photo_url')
  final String photoUrl;
  @override
  @JsonKey(name: 'photo_order')
  final int photoOrder;
  @override
  @JsonKey(name: 'is_primary')
  final bool isPrimary;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'Photo(id: $id, photoUrl: $photoUrl, photoOrder: $photoOrder, isPrimary: $isPrimary, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.photoOrder, photoOrder) ||
                other.photoOrder == photoOrder) &&
            (identical(other.isPrimary, isPrimary) ||
                other.isPrimary == isPrimary) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, photoUrl, photoOrder, isPrimary, createdAt);

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      __$$PhotoImplCopyWithImpl<_$PhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoImplToJson(this);
  }
}

abstract class _Photo implements Photo {
  const factory _Photo({
    required final int id,
    @JsonKey(name: 'photo_url') required final String photoUrl,
    @JsonKey(name: 'photo_order') required final int photoOrder,
    @JsonKey(name: 'is_primary') required final bool isPrimary,
    @JsonKey(name: 'created_at') required final String createdAt,
  }) = _$PhotoImpl;

  factory _Photo.fromJson(Map<String, dynamic> json) = _$PhotoImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'photo_url')
  String get photoUrl;
  @override
  @JsonKey(name: 'photo_order')
  int get photoOrder;
  @override
  @JsonKey(name: 'is_primary')
  bool get isPrimary;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of Photo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoImplCopyWith<_$PhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
