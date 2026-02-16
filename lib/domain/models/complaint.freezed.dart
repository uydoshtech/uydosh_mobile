// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'complaint.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Complaint _$ComplaintFromJson(Map<String, dynamic> json) {
  return _Complaint.fromJson(json);
}

/// @nodoc
mixin _$Complaint {
  @JsonKey(
    name: "status",
    fromJson: _complaintStatusFromJson,
    defaultValue: "pending",
  )
  String get status => throw _privateConstructorUsedError;
  int? get id => throw _privateConstructorUsedError;
  @JsonKey(name: "complainant_id")
  int? get complainantId => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_id")
  int? get listingId => throw _privateConstructorUsedError;
  @JsonKey(name: "category_id")
  int? get categoryId => throw _privateConstructorUsedError;
  @JsonKey(name: "category")
  ComplaintCategory? get category => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Complaint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ComplaintCopyWith<Complaint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ComplaintCopyWith<$Res> {
  factory $ComplaintCopyWith(Complaint value, $Res Function(Complaint) then) =
      _$ComplaintCopyWithImpl<$Res, Complaint>;
  @useResult
  $Res call({
    @JsonKey(
      name: "status",
      fromJson: _complaintStatusFromJson,
      defaultValue: "pending",
    )
    String status,
    int? id,
    @JsonKey(name: "complainant_id") int? complainantId,
    @JsonKey(name: "listing_id") int? listingId,
    @JsonKey(name: "category_id") int? categoryId,
    @JsonKey(name: "category") ComplaintCategory? category,
    String? text,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  });

  $ComplaintCategoryCopyWith<$Res>? get category;
}

/// @nodoc
class _$ComplaintCopyWithImpl<$Res, $Val extends Complaint>
    implements $ComplaintCopyWith<$Res> {
  _$ComplaintCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? id = freezed,
    Object? complainantId = freezed,
    Object? listingId = freezed,
    Object? categoryId = freezed,
    Object? category = freezed,
    Object? text = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int?,
            complainantId:
                freezed == complainantId
                    ? _value.complainantId
                    : complainantId // ignore: cast_nullable_to_non_nullable
                        as int?,
            listingId:
                freezed == listingId
                    ? _value.listingId
                    : listingId // ignore: cast_nullable_to_non_nullable
                        as int?,
            categoryId:
                freezed == categoryId
                    ? _value.categoryId
                    : categoryId // ignore: cast_nullable_to_non_nullable
                        as int?,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as ComplaintCategory?,
            text:
                freezed == text
                    ? _value.text
                    : text // ignore: cast_nullable_to_non_nullable
                        as String?,
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

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ComplaintCategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $ComplaintCategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ComplaintImplCopyWith<$Res>
    implements $ComplaintCopyWith<$Res> {
  factory _$$ComplaintImplCopyWith(
    _$ComplaintImpl value,
    $Res Function(_$ComplaintImpl) then,
  ) = __$$ComplaintImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(
      name: "status",
      fromJson: _complaintStatusFromJson,
      defaultValue: "pending",
    )
    String status,
    int? id,
    @JsonKey(name: "complainant_id") int? complainantId,
    @JsonKey(name: "listing_id") int? listingId,
    @JsonKey(name: "category_id") int? categoryId,
    @JsonKey(name: "category") ComplaintCategory? category,
    String? text,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  });

  @override
  $ComplaintCategoryCopyWith<$Res>? get category;
}

/// @nodoc
class __$$ComplaintImplCopyWithImpl<$Res>
    extends _$ComplaintCopyWithImpl<$Res, _$ComplaintImpl>
    implements _$$ComplaintImplCopyWith<$Res> {
  __$$ComplaintImplCopyWithImpl(
    _$ComplaintImpl _value,
    $Res Function(_$ComplaintImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? id = freezed,
    Object? complainantId = freezed,
    Object? listingId = freezed,
    Object? categoryId = freezed,
    Object? category = freezed,
    Object? text = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ComplaintImpl(
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int?,
        complainantId:
            freezed == complainantId
                ? _value.complainantId
                : complainantId // ignore: cast_nullable_to_non_nullable
                    as int?,
        listingId:
            freezed == listingId
                ? _value.listingId
                : listingId // ignore: cast_nullable_to_non_nullable
                    as int?,
        categoryId:
            freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                    as int?,
        category:
            freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as ComplaintCategory?,
        text:
            freezed == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                    as String?,
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
class _$ComplaintImpl implements _Complaint {
  const _$ComplaintImpl({
    @JsonKey(
      name: "status",
      fromJson: _complaintStatusFromJson,
      defaultValue: "pending",
    )
    required this.status,
    this.id,
    @JsonKey(name: "complainant_id") this.complainantId,
    @JsonKey(name: "listing_id") this.listingId,
    @JsonKey(name: "category_id") this.categoryId,
    @JsonKey(name: "category") this.category,
    this.text,
    @JsonKey(name: "created_at") this.createdAt,
    @JsonKey(name: "updated_at") this.updatedAt,
  });

  factory _$ComplaintImpl.fromJson(Map<String, dynamic> json) =>
      _$$ComplaintImplFromJson(json);

  @override
  @JsonKey(
    name: "status",
    fromJson: _complaintStatusFromJson,
    defaultValue: "pending",
  )
  final String status;
  @override
  final int? id;
  @override
  @JsonKey(name: "complainant_id")
  final int? complainantId;
  @override
  @JsonKey(name: "listing_id")
  final int? listingId;
  @override
  @JsonKey(name: "category_id")
  final int? categoryId;
  @override
  @JsonKey(name: "category")
  final ComplaintCategory? category;
  @override
  final String? text;
  @override
  @JsonKey(name: "created_at")
  final String? createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String? updatedAt;

  @override
  String toString() {
    return 'Complaint(status: $status, id: $id, complainantId: $complainantId, listingId: $listingId, categoryId: $categoryId, category: $category, text: $text, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ComplaintImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.complainantId, complainantId) ||
                other.complainantId == complainantId) &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    status,
    id,
    complainantId,
    listingId,
    categoryId,
    category,
    text,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ComplaintImplCopyWith<_$ComplaintImpl> get copyWith =>
      __$$ComplaintImplCopyWithImpl<_$ComplaintImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ComplaintImplToJson(this);
  }
}

abstract class _Complaint implements Complaint {
  const factory _Complaint({
    @JsonKey(
      name: "status",
      fromJson: _complaintStatusFromJson,
      defaultValue: "pending",
    )
    required final String status,
    final int? id,
    @JsonKey(name: "complainant_id") final int? complainantId,
    @JsonKey(name: "listing_id") final int? listingId,
    @JsonKey(name: "category_id") final int? categoryId,
    @JsonKey(name: "category") final ComplaintCategory? category,
    final String? text,
    @JsonKey(name: "created_at") final String? createdAt,
    @JsonKey(name: "updated_at") final String? updatedAt,
  }) = _$ComplaintImpl;

  factory _Complaint.fromJson(Map<String, dynamic> json) =
      _$ComplaintImpl.fromJson;

  @override
  @JsonKey(
    name: "status",
    fromJson: _complaintStatusFromJson,
    defaultValue: "pending",
  )
  String get status;
  @override
  int? get id;
  @override
  @JsonKey(name: "complainant_id")
  int? get complainantId;
  @override
  @JsonKey(name: "listing_id")
  int? get listingId;
  @override
  @JsonKey(name: "category_id")
  int? get categoryId;
  @override
  @JsonKey(name: "category")
  ComplaintCategory? get category;
  @override
  String? get text;
  @override
  @JsonKey(name: "created_at")
  String? get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String? get updatedAt;

  /// Create a copy of Complaint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ComplaintImplCopyWith<_$ComplaintImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateComplaintRequest _$CreateComplaintRequestFromJson(
  Map<String, dynamic> json,
) {
  return _CreateComplaintRequest.fromJson(json);
}

/// @nodoc
mixin _$CreateComplaintRequest {
  @JsonKey(name: "listing_id")
  int get listingId => throw _privateConstructorUsedError;
  @JsonKey(name: "category_id")
  int get categoryId => throw _privateConstructorUsedError;
  String? get text => throw _privateConstructorUsedError;

  /// Serializes this CreateComplaintRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateComplaintRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateComplaintRequestCopyWith<CreateComplaintRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateComplaintRequestCopyWith<$Res> {
  factory $CreateComplaintRequestCopyWith(
    CreateComplaintRequest value,
    $Res Function(CreateComplaintRequest) then,
  ) = _$CreateComplaintRequestCopyWithImpl<$Res, CreateComplaintRequest>;
  @useResult
  $Res call({
    @JsonKey(name: "listing_id") int listingId,
    @JsonKey(name: "category_id") int categoryId,
    String? text,
  });
}

/// @nodoc
class _$CreateComplaintRequestCopyWithImpl<
  $Res,
  $Val extends CreateComplaintRequest
>
    implements $CreateComplaintRequestCopyWith<$Res> {
  _$CreateComplaintRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateComplaintRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listingId = null,
    Object? categoryId = null,
    Object? text = freezed,
  }) {
    return _then(
      _value.copyWith(
            listingId:
                null == listingId
                    ? _value.listingId
                    : listingId // ignore: cast_nullable_to_non_nullable
                        as int,
            categoryId:
                null == categoryId
                    ? _value.categoryId
                    : categoryId // ignore: cast_nullable_to_non_nullable
                        as int,
            text:
                freezed == text
                    ? _value.text
                    : text // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreateComplaintRequestImplCopyWith<$Res>
    implements $CreateComplaintRequestCopyWith<$Res> {
  factory _$$CreateComplaintRequestImplCopyWith(
    _$CreateComplaintRequestImpl value,
    $Res Function(_$CreateComplaintRequestImpl) then,
  ) = __$$CreateComplaintRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "listing_id") int listingId,
    @JsonKey(name: "category_id") int categoryId,
    String? text,
  });
}

/// @nodoc
class __$$CreateComplaintRequestImplCopyWithImpl<$Res>
    extends
        _$CreateComplaintRequestCopyWithImpl<$Res, _$CreateComplaintRequestImpl>
    implements _$$CreateComplaintRequestImplCopyWith<$Res> {
  __$$CreateComplaintRequestImplCopyWithImpl(
    _$CreateComplaintRequestImpl _value,
    $Res Function(_$CreateComplaintRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateComplaintRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? listingId = null,
    Object? categoryId = null,
    Object? text = freezed,
  }) {
    return _then(
      _$CreateComplaintRequestImpl(
        listingId:
            null == listingId
                ? _value.listingId
                : listingId // ignore: cast_nullable_to_non_nullable
                    as int,
        categoryId:
            null == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                    as int,
        text:
            freezed == text
                ? _value.text
                : text // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateComplaintRequestImpl implements _CreateComplaintRequest {
  const _$CreateComplaintRequestImpl({
    @JsonKey(name: "listing_id") required this.listingId,
    @JsonKey(name: "category_id") required this.categoryId,
    this.text,
  });

  factory _$CreateComplaintRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateComplaintRequestImplFromJson(json);

  @override
  @JsonKey(name: "listing_id")
  final int listingId;
  @override
  @JsonKey(name: "category_id")
  final int categoryId;
  @override
  final String? text;

  @override
  String toString() {
    return 'CreateComplaintRequest(listingId: $listingId, categoryId: $categoryId, text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateComplaintRequestImpl &&
            (identical(other.listingId, listingId) ||
                other.listingId == listingId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.text, text) || other.text == text));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, listingId, categoryId, text);

  /// Create a copy of CreateComplaintRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateComplaintRequestImplCopyWith<_$CreateComplaintRequestImpl>
  get copyWith =>
      __$$CreateComplaintRequestImplCopyWithImpl<_$CreateComplaintRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateComplaintRequestImplToJson(this);
  }
}

abstract class _CreateComplaintRequest implements CreateComplaintRequest {
  const factory _CreateComplaintRequest({
    @JsonKey(name: "listing_id") required final int listingId,
    @JsonKey(name: "category_id") required final int categoryId,
    final String? text,
  }) = _$CreateComplaintRequestImpl;

  factory _CreateComplaintRequest.fromJson(Map<String, dynamic> json) =
      _$CreateComplaintRequestImpl.fromJson;

  @override
  @JsonKey(name: "listing_id")
  int get listingId;
  @override
  @JsonKey(name: "category_id")
  int get categoryId;
  @override
  String? get text;

  /// Create a copy of CreateComplaintRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateComplaintRequestImplCopyWith<_$CreateComplaintRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}
