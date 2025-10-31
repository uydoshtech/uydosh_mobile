// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subway_station.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubwayStation _$SubwayStationFromJson(Map<String, dynamic> json) {
  return _SubwayStation.fromJson(json);
}

/// @nodoc
mixin _$SubwayStation {
  int get id => throw _privateConstructorUsedError;
  int get line => throw _privateConstructorUsedError;
  int get ordinal => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String? get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String? get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String? get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "latitude")
  double? get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: "longitude")
  double? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: "location_id")
  int? get locationId => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SubwayStation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubwayStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubwayStationCopyWith<SubwayStation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubwayStationCopyWith<$Res> {
  factory $SubwayStationCopyWith(
    SubwayStation value,
    $Res Function(SubwayStation) then,
  ) = _$SubwayStationCopyWithImpl<$Res, SubwayStation>;
  @useResult
  $Res call({
    int id,
    int line,
    int ordinal,
    @JsonKey(name: "name_uz") String? nameUz,
    @JsonKey(name: "name_ru") String? nameRu,
    @JsonKey(name: "name_en") String? nameEn,
    @JsonKey(name: "latitude") double? latitude,
    @JsonKey(name: "longitude") double? longitude,
    @JsonKey(name: "location_id") int? locationId,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  });
}

/// @nodoc
class _$SubwayStationCopyWithImpl<$Res, $Val extends SubwayStation>
    implements $SubwayStationCopyWith<$Res> {
  _$SubwayStationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubwayStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? line = null,
    Object? ordinal = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as int,
            line:
                null == line
                    ? _value.line
                    : line // ignore: cast_nullable_to_non_nullable
                        as int,
            ordinal:
                null == ordinal
                    ? _value.ordinal
                    : ordinal // ignore: cast_nullable_to_non_nullable
                        as int,
            nameUz:
                freezed == nameUz
                    ? _value.nameUz
                    : nameUz // ignore: cast_nullable_to_non_nullable
                        as String?,
            nameRu:
                freezed == nameRu
                    ? _value.nameRu
                    : nameRu // ignore: cast_nullable_to_non_nullable
                        as String?,
            nameEn:
                freezed == nameEn
                    ? _value.nameEn
                    : nameEn // ignore: cast_nullable_to_non_nullable
                        as String?,
            latitude:
                freezed == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            longitude:
                freezed == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double?,
            locationId:
                freezed == locationId
                    ? _value.locationId
                    : locationId // ignore: cast_nullable_to_non_nullable
                        as int?,
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
abstract class _$$SubwayStationImplCopyWith<$Res>
    implements $SubwayStationCopyWith<$Res> {
  factory _$$SubwayStationImplCopyWith(
    _$SubwayStationImpl value,
    $Res Function(_$SubwayStationImpl) then,
  ) = __$$SubwayStationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    int line,
    int ordinal,
    @JsonKey(name: "name_uz") String? nameUz,
    @JsonKey(name: "name_ru") String? nameRu,
    @JsonKey(name: "name_en") String? nameEn,
    @JsonKey(name: "latitude") double? latitude,
    @JsonKey(name: "longitude") double? longitude,
    @JsonKey(name: "location_id") int? locationId,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  });
}

/// @nodoc
class __$$SubwayStationImplCopyWithImpl<$Res>
    extends _$SubwayStationCopyWithImpl<$Res, _$SubwayStationImpl>
    implements _$$SubwayStationImplCopyWith<$Res> {
  __$$SubwayStationImplCopyWithImpl(
    _$SubwayStationImpl _value,
    $Res Function(_$SubwayStationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubwayStation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? line = null,
    Object? ordinal = null,
    Object? nameUz = freezed,
    Object? nameRu = freezed,
    Object? nameEn = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$SubwayStationImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as int,
        line:
            null == line
                ? _value.line
                : line // ignore: cast_nullable_to_non_nullable
                    as int,
        ordinal:
            null == ordinal
                ? _value.ordinal
                : ordinal // ignore: cast_nullable_to_non_nullable
                    as int,
        nameUz:
            freezed == nameUz
                ? _value.nameUz
                : nameUz // ignore: cast_nullable_to_non_nullable
                    as String?,
        nameRu:
            freezed == nameRu
                ? _value.nameRu
                : nameRu // ignore: cast_nullable_to_non_nullable
                    as String?,
        nameEn:
            freezed == nameEn
                ? _value.nameEn
                : nameEn // ignore: cast_nullable_to_non_nullable
                    as String?,
        latitude:
            freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        longitude:
            freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double?,
        locationId:
            freezed == locationId
                ? _value.locationId
                : locationId // ignore: cast_nullable_to_non_nullable
                    as int?,
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
class _$SubwayStationImpl implements _SubwayStation {
  const _$SubwayStationImpl({
    required this.id,
    required this.line,
    required this.ordinal,
    @JsonKey(name: "name_uz") this.nameUz,
    @JsonKey(name: "name_ru") this.nameRu,
    @JsonKey(name: "name_en") this.nameEn,
    @JsonKey(name: "latitude") this.latitude,
    @JsonKey(name: "longitude") this.longitude,
    @JsonKey(name: "location_id") this.locationId,
    @JsonKey(name: "created_at") this.createdAt,
    @JsonKey(name: "updated_at") this.updatedAt,
  });

  factory _$SubwayStationImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubwayStationImplFromJson(json);

  @override
  final int id;
  @override
  final int line;
  @override
  final int ordinal;
  @override
  @JsonKey(name: "name_uz")
  final String? nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String? nameRu;
  @override
  @JsonKey(name: "name_en")
  final String? nameEn;
  @override
  @JsonKey(name: "latitude")
  final double? latitude;
  @override
  @JsonKey(name: "longitude")
  final double? longitude;
  @override
  @JsonKey(name: "location_id")
  final int? locationId;
  @override
  @JsonKey(name: "created_at")
  final String? createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String? updatedAt;

  @override
  String toString() {
    return 'SubwayStation(id: $id, line: $line, ordinal: $ordinal, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, latitude: $latitude, longitude: $longitude, locationId: $locationId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubwayStationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.line, line) || other.line == line) &&
            (identical(other.ordinal, ordinal) || other.ordinal == ordinal) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
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
    line,
    ordinal,
    nameUz,
    nameRu,
    nameEn,
    latitude,
    longitude,
    locationId,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SubwayStation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubwayStationImplCopyWith<_$SubwayStationImpl> get copyWith =>
      __$$SubwayStationImplCopyWithImpl<_$SubwayStationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubwayStationImplToJson(this);
  }
}

abstract class _SubwayStation implements SubwayStation {
  const factory _SubwayStation({
    required final int id,
    required final int line,
    required final int ordinal,
    @JsonKey(name: "name_uz") final String? nameUz,
    @JsonKey(name: "name_ru") final String? nameRu,
    @JsonKey(name: "name_en") final String? nameEn,
    @JsonKey(name: "latitude") final double? latitude,
    @JsonKey(name: "longitude") final double? longitude,
    @JsonKey(name: "location_id") final int? locationId,
    @JsonKey(name: "created_at") final String? createdAt,
    @JsonKey(name: "updated_at") final String? updatedAt,
  }) = _$SubwayStationImpl;

  factory _SubwayStation.fromJson(Map<String, dynamic> json) =
      _$SubwayStationImpl.fromJson;

  @override
  int get id;
  @override
  int get line;
  @override
  int get ordinal;
  @override
  @JsonKey(name: "name_uz")
  String? get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String? get nameRu;
  @override
  @JsonKey(name: "name_en")
  String? get nameEn;
  @override
  @JsonKey(name: "latitude")
  double? get latitude;
  @override
  @JsonKey(name: "longitude")
  double? get longitude;
  @override
  @JsonKey(name: "location_id")
  int? get locationId;
  @override
  @JsonKey(name: "created_at")
  String? get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String? get updatedAt;

  /// Create a copy of SubwayStation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubwayStationImplCopyWith<_$SubwayStationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
