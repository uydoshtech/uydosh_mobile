// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ComplaintCategory _$ComplaintCategoryFromJson(Map<String, dynamic> json) {
  return _ComplaintCategory.fromJson(json);
}

/// @nodoc
mixin _$ComplaintCategory {
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_uz')
  String get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_ru')
  String get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: 'name_en')
  String get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ComplaintCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ComplaintCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComplaintCategoryCopyWith<ComplaintCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComplaintCategoryCopyWith<$Res> {
  factory $ComplaintCategoryCopyWith(
    ComplaintCategory value,
    $Res Function(ComplaintCategory) then,
  ) = _$ComplaintCategoryCopyWithImpl<$Res, ComplaintCategory>;
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'name_uz') String nameUz,
    @JsonKey(name: 'name_ru') String nameRu,
    @JsonKey(name: 'name_en') String nameEn,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });
}

/// @nodoc
class _$ComplaintCategoryCopyWithImpl<$Res, $Val extends ComplaintCategory>
    implements $ComplaintCategoryCopyWith<$Res> {
  _$ComplaintCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ComplaintCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            nameUz:
                null == nameUz
                    ? _value.nameUz
                    : nameUz // ignore: cast_nullable_to_non_nullable
                        as String,
            nameRu:
                null == nameRu
                    ? _value.nameRu
                    : nameRu // ignore: cast_nullable_to_non_nullable
                        as String,
            nameEn:
                null == nameEn
                    ? _value.nameEn
                    : nameEn // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as String?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ComplaintCategoryImplCopyWith<$Res>
    implements $ComplaintCategoryCopyWith<$Res> {
  factory _$$ComplaintCategoryImplCopyWith(
    _$ComplaintCategoryImpl value,
    $Res Function(_$ComplaintCategoryImpl) then,
  ) = __$$ComplaintCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    @JsonKey(name: 'name_uz') String nameUz,
    @JsonKey(name: 'name_ru') String nameRu,
    @JsonKey(name: 'name_en') String nameEn,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  });
}

/// @nodoc
class __$$ComplaintCategoryImplCopyWithImpl<$Res>
    extends _$ComplaintCategoryCopyWithImpl<$Res, _$ComplaintCategoryImpl>
    implements _$$ComplaintCategoryImplCopyWith<$Res> {
  __$$ComplaintCategoryImplCopyWithImpl(
    _$ComplaintCategoryImpl _value,
    $Res Function(_$ComplaintCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ComplaintCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ComplaintCategoryImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        nameUz:
            null == nameUz
                ? _value.nameUz
                : nameUz // ignore: cast_nullable_to_non_nullable
                    as String,
        nameRu:
            null == nameRu
                ? _value.nameRu
                : nameRu // ignore: cast_nullable_to_non_nullable
                    as String,
        nameEn:
            null == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as String?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ComplaintCategoryImpl implements _ComplaintCategory {
  const _$ComplaintCategoryImpl({
    this.id,
    @JsonKey(name: 'name_uz') required this.nameUz,
    @JsonKey(name: 'name_ru') required this.nameRu,
    @JsonKey(name: 'name_en') required this.nameEn,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'updated_at') this.updatedAt,
  });

  factory _$ComplaintCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComplaintCategoryImplFromJson(json);

  @override
  final int? id;
  @override
  @JsonKey(name: 'name_uz')
  final String nameUz;
  @override
  @JsonKey(name: 'name_ru')
  final String nameRu;
  @override
  @JsonKey(name: 'name_en')
  final String nameEn;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @override
  String toString() {
    return 'ComplaintCategory(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComplaintCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    nameUz,
    nameRu,
    nameEn,
    createdAt,
    updatedAt,
  );

  /// Create a copy of ComplaintCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComplaintCategoryImplCopyWith<_$ComplaintCategoryImpl> get copyWith =>
      __$$ComplaintCategoryImplCopyWithImpl<_$ComplaintCategoryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ComplaintCategoryImplToJson(this);
  }
}

abstract class _ComplaintCategory implements ComplaintCategory {
  const factory _ComplaintCategory({
    final int? id,
    @JsonKey(name: 'name_uz') required final String nameUz,
    @JsonKey(name: 'name_ru') required final String nameRu,
    @JsonKey(name: 'name_en') required final String nameEn,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'updated_at') final String? updatedAt,
  }) = _$ComplaintCategoryImpl;

  factory _ComplaintCategory.fromJson(Map<String, dynamic> json) =
      _$ComplaintCategoryImpl.fromJson;

  @override
  int? get id;
  @override
  @JsonKey(name: 'name_uz')
  String get nameUz;
  @override
  @JsonKey(name: 'name_ru')
  String get nameRu;
  @override
  @JsonKey(name: 'name_en')
  String get nameEn;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String? get updatedAt;

  /// Create a copy of ComplaintCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComplaintCategoryImplCopyWith<_$ComplaintCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
