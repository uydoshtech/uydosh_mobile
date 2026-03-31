// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'university.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

University _$UniversityFromJson(Map<String, dynamic> json) {
  return _University.fromJson(json);
}

/// @nodoc
mixin _$University {
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertFromJson)
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name")
  String? get name => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String? get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String? get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String? get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name")
  String? get shortName => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_en")
  String? get shortNameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_ru")
  String? get shortNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_uz")
  String? get shortNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "latitude")
  String? get latitude => throw _privateConstructorUsedError;
  @JsonKey(name: "longitude")
  String? get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: "location_id")
  int? get locationId => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String? get updatedAt => throw _privateConstructorUsedError;
  @JsonKey(name: "location")
  Map<String, dynamic>? get location => throw _privateConstructorUsedError;

  /// Serializes this University to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of University
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UniversityCopyWith<University> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UniversityCopyWith<$Res> {
  factory $UniversityCopyWith(
          University value, $Res Function(University) then) =
      _$UniversityCopyWithImpl<$Res, University>;
  @useResult
  $Res call(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertFromJson)
      int id,
      @JsonKey(name: "name") String? name,
      @JsonKey(name: "name_en") String? nameEn,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "short_name") String? shortName,
      @JsonKey(name: "short_name_en") String? shortNameEn,
      @JsonKey(name: "short_name_ru") String? shortNameRu,
      @JsonKey(name: "short_name_uz") String? shortNameUz,
      @JsonKey(name: "latitude") String? latitude,
      @JsonKey(name: "longitude") String? longitude,
      @JsonKey(name: "location_id") int? locationId,
      @JsonKey(name: "created_at") String? createdAt,
      @JsonKey(name: "updated_at") String? updatedAt,
      @JsonKey(name: "location") Map<String, dynamic>? location});
}

/// @nodoc
class _$UniversityCopyWithImpl<$Res, $Val extends University>
    implements $UniversityCopyWith<$Res> {
  _$UniversityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of University
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? nameEn = freezed,
    Object? nameRu = freezed,
    Object? nameUz = freezed,
    Object? shortName = freezed,
    Object? shortNameEn = freezed,
    Object? shortNameRu = freezed,
    Object? shortNameUz = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? location = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      shortName: freezed == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameEn: freezed == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameRu: freezed == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameUz: freezed == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as String?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as String?,
      locationId: freezed == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UniversityImplCopyWith<$Res>
    implements $UniversityCopyWith<$Res> {
  factory _$$UniversityImplCopyWith(
          _$UniversityImpl value, $Res Function(_$UniversityImpl) then) =
      __$$UniversityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertFromJson)
      int id,
      @JsonKey(name: "name") String? name,
      @JsonKey(name: "name_en") String? nameEn,
      @JsonKey(name: "name_ru") String? nameRu,
      @JsonKey(name: "name_uz") String? nameUz,
      @JsonKey(name: "short_name") String? shortName,
      @JsonKey(name: "short_name_en") String? shortNameEn,
      @JsonKey(name: "short_name_ru") String? shortNameRu,
      @JsonKey(name: "short_name_uz") String? shortNameUz,
      @JsonKey(name: "latitude") String? latitude,
      @JsonKey(name: "longitude") String? longitude,
      @JsonKey(name: "location_id") int? locationId,
      @JsonKey(name: "created_at") String? createdAt,
      @JsonKey(name: "updated_at") String? updatedAt,
      @JsonKey(name: "location") Map<String, dynamic>? location});
}

/// @nodoc
class __$$UniversityImplCopyWithImpl<$Res>
    extends _$UniversityCopyWithImpl<$Res, _$UniversityImpl>
    implements _$$UniversityImplCopyWith<$Res> {
  __$$UniversityImplCopyWithImpl(
      _$UniversityImpl _value, $Res Function(_$UniversityImpl) _then)
      : super(_value, _then);

  /// Create a copy of University
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? nameEn = freezed,
    Object? nameRu = freezed,
    Object? nameUz = freezed,
    Object? shortName = freezed,
    Object? shortNameEn = freezed,
    Object? shortNameRu = freezed,
    Object? shortNameUz = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? location = freezed,
  }) {
    return _then(_$UniversityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      nameEn: freezed == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      nameRu: freezed == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      nameUz: freezed == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      shortName: freezed == shortName
          ? _value.shortName
          : shortName // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameEn: freezed == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameRu: freezed == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String?,
      shortNameUz: freezed == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as String?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as String?,
      locationId: freezed == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value._location
          : location // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UniversityImpl implements _University {
  const _$UniversityImpl(
      {@JsonKey(
          fromJson: NullableIntConverter.convertFromJson,
          toJson: NullableIntConverter.convertFromJson)
      required this.id,
      @JsonKey(name: "name") this.name,
      @JsonKey(name: "name_en") this.nameEn,
      @JsonKey(name: "name_ru") this.nameRu,
      @JsonKey(name: "name_uz") this.nameUz,
      @JsonKey(name: "short_name") this.shortName,
      @JsonKey(name: "short_name_en") this.shortNameEn,
      @JsonKey(name: "short_name_ru") this.shortNameRu,
      @JsonKey(name: "short_name_uz") this.shortNameUz,
      @JsonKey(name: "latitude") this.latitude,
      @JsonKey(name: "longitude") this.longitude,
      @JsonKey(name: "location_id") this.locationId,
      @JsonKey(name: "created_at") this.createdAt,
      @JsonKey(name: "updated_at") this.updatedAt,
      @JsonKey(name: "location") final Map<String, dynamic>? location})
      : _location = location;

  factory _$UniversityImpl.fromJson(Map<String, dynamic> json) =>
      _$$UniversityImplFromJson(json);

  @override
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertFromJson)
  final int id;
  @override
  @JsonKey(name: "name")
  final String? name;
  @override
  @JsonKey(name: "name_en")
  final String? nameEn;
  @override
  @JsonKey(name: "name_ru")
  final String? nameRu;
  @override
  @JsonKey(name: "name_uz")
  final String? nameUz;
  @override
  @JsonKey(name: "short_name")
  final String? shortName;
  @override
  @JsonKey(name: "short_name_en")
  final String? shortNameEn;
  @override
  @JsonKey(name: "short_name_ru")
  final String? shortNameRu;
  @override
  @JsonKey(name: "short_name_uz")
  final String? shortNameUz;
  @override
  @JsonKey(name: "latitude")
  final String? latitude;
  @override
  @JsonKey(name: "longitude")
  final String? longitude;
  @override
  @JsonKey(name: "location_id")
  final int? locationId;
  @override
  @JsonKey(name: "created_at")
  final String? createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String? updatedAt;
  final Map<String, dynamic>? _location;
  @override
  @JsonKey(name: "location")
  Map<String, dynamic>? get location {
    final value = _location;
    if (value == null) return null;
    if (_location is EqualUnmodifiableMapView) return _location;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'University(id: $id, name: $name, nameEn: $nameEn, nameRu: $nameRu, nameUz: $nameUz, shortName: $shortName, shortNameEn: $shortNameEn, shortNameRu: $shortNameRu, shortNameUz: $shortNameUz, latitude: $latitude, longitude: $longitude, locationId: $locationId, createdAt: $createdAt, updatedAt: $updatedAt, location: $location)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UniversityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.shortName, shortName) ||
                other.shortName == shortName) &&
            (identical(other.shortNameEn, shortNameEn) ||
                other.shortNameEn == shortNameEn) &&
            (identical(other.shortNameRu, shortNameRu) ||
                other.shortNameRu == shortNameRu) &&
            (identical(other.shortNameUz, shortNameUz) ||
                other.shortNameUz == shortNameUz) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._location, _location));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      nameEn,
      nameRu,
      nameUz,
      shortName,
      shortNameEn,
      shortNameRu,
      shortNameUz,
      latitude,
      longitude,
      locationId,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_location));

  /// Create a copy of University
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UniversityImplCopyWith<_$UniversityImpl> get copyWith =>
      __$$UniversityImplCopyWithImpl<_$UniversityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UniversityImplToJson(
      this,
    );
  }
}

abstract class _University implements University {
  const factory _University(
          {@JsonKey(
              fromJson: NullableIntConverter.convertFromJson,
              toJson: NullableIntConverter.convertFromJson)
          required final int id,
          @JsonKey(name: "name") final String? name,
          @JsonKey(name: "name_en") final String? nameEn,
          @JsonKey(name: "name_ru") final String? nameRu,
          @JsonKey(name: "name_uz") final String? nameUz,
          @JsonKey(name: "short_name") final String? shortName,
          @JsonKey(name: "short_name_en") final String? shortNameEn,
          @JsonKey(name: "short_name_ru") final String? shortNameRu,
          @JsonKey(name: "short_name_uz") final String? shortNameUz,
          @JsonKey(name: "latitude") final String? latitude,
          @JsonKey(name: "longitude") final String? longitude,
          @JsonKey(name: "location_id") final int? locationId,
          @JsonKey(name: "created_at") final String? createdAt,
          @JsonKey(name: "updated_at") final String? updatedAt,
          @JsonKey(name: "location") final Map<String, dynamic>? location}) =
      _$UniversityImpl;

  factory _University.fromJson(Map<String, dynamic> json) =
      _$UniversityImpl.fromJson;

  @override
  @JsonKey(
      fromJson: NullableIntConverter.convertFromJson,
      toJson: NullableIntConverter.convertFromJson)
  int get id;
  @override
  @JsonKey(name: "name")
  String? get name;
  @override
  @JsonKey(name: "name_en")
  String? get nameEn;
  @override
  @JsonKey(name: "name_ru")
  String? get nameRu;
  @override
  @JsonKey(name: "name_uz")
  String? get nameUz;
  @override
  @JsonKey(name: "short_name")
  String? get shortName;
  @override
  @JsonKey(name: "short_name_en")
  String? get shortNameEn;
  @override
  @JsonKey(name: "short_name_ru")
  String? get shortNameRu;
  @override
  @JsonKey(name: "short_name_uz")
  String? get shortNameUz;
  @override
  @JsonKey(name: "latitude")
  String? get latitude;
  @override
  @JsonKey(name: "longitude")
  String? get longitude;
  @override
  @JsonKey(name: "location_id")
  int? get locationId;
  @override
  @JsonKey(name: "created_at")
  String? get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String? get updatedAt;
  @override
  @JsonKey(name: "location")
  Map<String, dynamic>? get location;

  /// Create a copy of University
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UniversityImplCopyWith<_$UniversityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
