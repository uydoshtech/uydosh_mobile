// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pageable_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PageableResponse<T> {
  List<T> get data => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get limit => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// Create a copy of PageableResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PageableResponseCopyWith<T, PageableResponse<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PageableResponseCopyWith<T, $Res> {
  factory $PageableResponseCopyWith(
          PageableResponse<T> value, $Res Function(PageableResponse<T>) then) =
      _$PageableResponseCopyWithImpl<T, $Res, PageableResponse<T>>;
  @useResult
  $Res call({List<T> data, int total, int page, int limit, int totalPages});
}

/// @nodoc
class _$PageableResponseCopyWithImpl<T, $Res, $Val extends PageableResponse<T>>
    implements $PageableResponseCopyWith<T, $Res> {
  _$PageableResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PageableResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? totalPages = null,
  }) {
    return _then(_value.copyWith(
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<T>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PageableResponseImplCopyWith<T, $Res>
    implements $PageableResponseCopyWith<T, $Res> {
  factory _$$PageableResponseImplCopyWith(_$PageableResponseImpl<T> value,
          $Res Function(_$PageableResponseImpl<T>) then) =
      __$$PageableResponseImplCopyWithImpl<T, $Res>;
  @override
  @useResult
  $Res call({List<T> data, int total, int page, int limit, int totalPages});
}

/// @nodoc
class __$$PageableResponseImplCopyWithImpl<T, $Res>
    extends _$PageableResponseCopyWithImpl<T, $Res, _$PageableResponseImpl<T>>
    implements _$$PageableResponseImplCopyWith<T, $Res> {
  __$$PageableResponseImplCopyWithImpl(_$PageableResponseImpl<T> _value,
      $Res Function(_$PageableResponseImpl<T>) _then)
      : super(_value, _then);

  /// Create a copy of PageableResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? data = null,
    Object? total = null,
    Object? page = null,
    Object? limit = null,
    Object? totalPages = null,
  }) {
    return _then(_$PageableResponseImpl<T>(
      data: null == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<T>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      limit: null == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$PageableResponseImpl<T> extends _PageableResponse<T> {
  const _$PageableResponseImpl(
      {required final List<T> data,
      required this.total,
      required this.page,
      required this.limit,
      required this.totalPages})
      : _data = data,
        super._();

  final List<T> _data;
  @override
  List<T> get data {
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_data);
  }

  @override
  final int total;
  @override
  final int page;
  @override
  final int limit;
  @override
  final int totalPages;

  @override
  String toString() {
    return 'PageableResponse<$T>(data: $data, total: $total, page: $page, limit: $limit, totalPages: $totalPages)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PageableResponseImpl<T> &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_data),
      total,
      page,
      limit,
      totalPages);

  /// Create a copy of PageableResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PageableResponseImplCopyWith<T, _$PageableResponseImpl<T>> get copyWith =>
      __$$PageableResponseImplCopyWithImpl<T, _$PageableResponseImpl<T>>(
          this, _$identity);
}

abstract class _PageableResponse<T> extends PageableResponse<T> {
  const factory _PageableResponse(
      {required final List<T> data,
      required final int total,
      required final int page,
      required final int limit,
      required final int totalPages}) = _$PageableResponseImpl<T>;
  const _PageableResponse._() : super._();

  @override
  List<T> get data;
  @override
  int get total;
  @override
  int get page;
  @override
  int get limit;
  @override
  int get totalPages;

  /// Create a copy of PageableResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PageableResponseImplCopyWith<T, _$PageableResponseImpl<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
