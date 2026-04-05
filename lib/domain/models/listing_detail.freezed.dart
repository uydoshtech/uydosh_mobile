// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ListingDetail _$ListingDetailFromJson(Map<String, dynamic> json) {
  return _ListingDetail.fromJson(json);
}

/// @nodoc
mixin _$ListingDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "user_id")
  int get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_type_id")
  int get listingTypeId => throw _privateConstructorUsedError;
  @JsonKey(name: "price")
  int get price => throw _privateConstructorUsedError;
  @JsonKey(name: "is_active")
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: "updated_at")
  String get updatedAt => throw _privateConstructorUsedError;
  UserDetail get user => throw _privateConstructorUsedError;
  @JsonKey(name: "listing_type")
  ListingTypeDetail get listingType => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: "description_ru")
  String? get descriptionRu => throw _privateConstructorUsedError;
  @JsonKey(name: "description_en")
  String? get descriptionEn => throw _privateConstructorUsedError;
  @JsonKey(name: "description_uz")
  String? get descriptionUz => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station_id")
  int? get subwayStationId => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_line_id")
  int? get subwayLineId => throw _privateConstructorUsedError;
  @JsonKey(name: "location_id")
  int? get locationId => throw _privateConstructorUsedError;
  int? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: "featured_at")
  String? get featuredAt => throw _privateConstructorUsedError;
  @JsonKey(name: "move_in_date")
  String? get moveInDate => throw _privateConstructorUsedError;
  @JsonKey(name: "private_room")
  bool? get privateRoom => throw _privateConstructorUsedError;

  /// Parsed from listing text (e.g. Telegram); use for contact when set.
  @JsonKey(name: "contact_phone")
  String? get contactPhone => throw _privateConstructorUsedError;
  @JsonKey(name: "point_cloud_url")
  String? get pointCloudUrl => throw _privateConstructorUsedError;
  @JsonKey(name: "subway_station")
  SubwayStationDetail? get subwayStation => throw _privateConstructorUsedError;
  LocationDetail? get location => throw _privateConstructorUsedError;
  List<Amenity>? get amenities => throw _privateConstructorUsedError;
  List<Photo>? get photos => throw _privateConstructorUsedError;

  /// Serializes this ListingDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingDetailCopyWith<ListingDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingDetailCopyWith<$Res> {
  factory $ListingDetailCopyWith(
          ListingDetail value, $Res Function(ListingDetail) then) =
      _$ListingDetailCopyWithImpl<$Res, ListingDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "user_id") int userId,
      String title,
      @JsonKey(name: "listing_type_id") int listingTypeId,
      @JsonKey(name: "price") int price,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      UserDetail user,
      @JsonKey(name: "listing_type") ListingTypeDetail listingType,
      String? description,
      @JsonKey(name: "description_ru") String? descriptionRu,
      @JsonKey(name: "description_en") String? descriptionEn,
      @JsonKey(name: "description_uz") String? descriptionUz,
      @JsonKey(name: "subway_station_id") int? subwayStationId,
      @JsonKey(name: "subway_line_id") int? subwayLineId,
      @JsonKey(name: "location_id") int? locationId,
      int? gender,
      @JsonKey(name: "featured_at") String? featuredAt,
      @JsonKey(name: "move_in_date") String? moveInDate,
      @JsonKey(name: "private_room") bool? privateRoom,
      @JsonKey(name: "contact_phone") String? contactPhone,
      @JsonKey(name: "point_cloud_url") String? pointCloudUrl,
      @JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,
      LocationDetail? location,
      List<Amenity>? amenities,
      List<Photo>? photos});

  $UserDetailCopyWith<$Res> get user;
  $ListingTypeDetailCopyWith<$Res> get listingType;
  $SubwayStationDetailCopyWith<$Res>? get subwayStation;
  $LocationDetailCopyWith<$Res>? get location;
}

/// @nodoc
class _$ListingDetailCopyWithImpl<$Res, $Val extends ListingDetail>
    implements $ListingDetailCopyWith<$Res> {
  _$ListingDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? listingTypeId = null,
    Object? price = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? user = null,
    Object? listingType = null,
    Object? description = freezed,
    Object? descriptionRu = freezed,
    Object? descriptionEn = freezed,
    Object? descriptionUz = freezed,
    Object? subwayStationId = freezed,
    Object? subwayLineId = freezed,
    Object? locationId = freezed,
    Object? gender = freezed,
    Object? featuredAt = freezed,
    Object? moveInDate = freezed,
    Object? privateRoom = freezed,
    Object? contactPhone = freezed,
    Object? pointCloudUrl = freezed,
    Object? subwayStation = freezed,
    Object? location = freezed,
    Object? amenities = freezed,
    Object? photos = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      listingTypeId: null == listingTypeId
          ? _value.listingTypeId
          : listingTypeId // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserDetail,
      listingType: null == listingType
          ? _value.listingType
          : listingType // ignore: cast_nullable_to_non_nullable
              as ListingTypeDetail,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionRu: freezed == descriptionRu
          ? _value.descriptionRu
          : descriptionRu // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionEn: freezed == descriptionEn
          ? _value.descriptionEn
          : descriptionEn // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionUz: freezed == descriptionUz
          ? _value.descriptionUz
          : descriptionUz // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationId: freezed == subwayStationId
          ? _value.subwayStationId
          : subwayStationId // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayLineId: freezed == subwayLineId
          ? _value.subwayLineId
          : subwayLineId // ignore: cast_nullable_to_non_nullable
              as int?,
      locationId: freezed == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      featuredAt: freezed == featuredAt
          ? _value.featuredAt
          : featuredAt // ignore: cast_nullable_to_non_nullable
              as String?,
      moveInDate: freezed == moveInDate
          ? _value.moveInDate
          : moveInDate // ignore: cast_nullable_to_non_nullable
              as String?,
      privateRoom: freezed == privateRoom
          ? _value.privateRoom
          : privateRoom // ignore: cast_nullable_to_non_nullable
              as bool?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      pointCloudUrl: freezed == pointCloudUrl
          ? _value.pointCloudUrl
          : pointCloudUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStation: freezed == subwayStation
          ? _value.subwayStation
          : subwayStation // ignore: cast_nullable_to_non_nullable
              as SubwayStationDetail?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDetail?,
      amenities: freezed == amenities
          ? _value.amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<Amenity>?,
      photos: freezed == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>?,
    ) as $Val);
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserDetailCopyWith<$Res> get user {
    return $UserDetailCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ListingTypeDetailCopyWith<$Res> get listingType {
    return $ListingTypeDetailCopyWith<$Res>(_value.listingType, (value) {
      return _then(_value.copyWith(listingType: value) as $Val);
    });
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SubwayStationDetailCopyWith<$Res>? get subwayStation {
    if (_value.subwayStation == null) {
      return null;
    }

    return $SubwayStationDetailCopyWith<$Res>(_value.subwayStation!, (value) {
      return _then(_value.copyWith(subwayStation: value) as $Val);
    });
  }

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationDetailCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationDetailCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ListingDetailImplCopyWith<$Res>
    implements $ListingDetailCopyWith<$Res> {
  factory _$$ListingDetailImplCopyWith(
          _$ListingDetailImpl value, $Res Function(_$ListingDetailImpl) then) =
      __$$ListingDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "user_id") int userId,
      String title,
      @JsonKey(name: "listing_type_id") int listingTypeId,
      @JsonKey(name: "price") int price,
      @JsonKey(name: "is_active") bool isActive,
      @JsonKey(name: "created_at") String createdAt,
      @JsonKey(name: "updated_at") String updatedAt,
      UserDetail user,
      @JsonKey(name: "listing_type") ListingTypeDetail listingType,
      String? description,
      @JsonKey(name: "description_ru") String? descriptionRu,
      @JsonKey(name: "description_en") String? descriptionEn,
      @JsonKey(name: "description_uz") String? descriptionUz,
      @JsonKey(name: "subway_station_id") int? subwayStationId,
      @JsonKey(name: "subway_line_id") int? subwayLineId,
      @JsonKey(name: "location_id") int? locationId,
      int? gender,
      @JsonKey(name: "featured_at") String? featuredAt,
      @JsonKey(name: "move_in_date") String? moveInDate,
      @JsonKey(name: "private_room") bool? privateRoom,
      @JsonKey(name: "contact_phone") String? contactPhone,
      @JsonKey(name: "point_cloud_url") String? pointCloudUrl,
      @JsonKey(name: "subway_station") SubwayStationDetail? subwayStation,
      LocationDetail? location,
      List<Amenity>? amenities,
      List<Photo>? photos});

  @override
  $UserDetailCopyWith<$Res> get user;
  @override
  $ListingTypeDetailCopyWith<$Res> get listingType;
  @override
  $SubwayStationDetailCopyWith<$Res>? get subwayStation;
  @override
  $LocationDetailCopyWith<$Res>? get location;
}

/// @nodoc
class __$$ListingDetailImplCopyWithImpl<$Res>
    extends _$ListingDetailCopyWithImpl<$Res, _$ListingDetailImpl>
    implements _$$ListingDetailImplCopyWith<$Res> {
  __$$ListingDetailImplCopyWithImpl(
      _$ListingDetailImpl _value, $Res Function(_$ListingDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? listingTypeId = null,
    Object? price = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? user = null,
    Object? listingType = null,
    Object? description = freezed,
    Object? descriptionRu = freezed,
    Object? descriptionEn = freezed,
    Object? descriptionUz = freezed,
    Object? subwayStationId = freezed,
    Object? subwayLineId = freezed,
    Object? locationId = freezed,
    Object? gender = freezed,
    Object? featuredAt = freezed,
    Object? moveInDate = freezed,
    Object? privateRoom = freezed,
    Object? contactPhone = freezed,
    Object? pointCloudUrl = freezed,
    Object? subwayStation = freezed,
    Object? location = freezed,
    Object? amenities = freezed,
    Object? photos = freezed,
  }) {
    return _then(_$ListingDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      listingTypeId: null == listingTypeId
          ? _value.listingTypeId
          : listingTypeId // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserDetail,
      listingType: null == listingType
          ? _value.listingType
          : listingType // ignore: cast_nullable_to_non_nullable
              as ListingTypeDetail,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionRu: freezed == descriptionRu
          ? _value.descriptionRu
          : descriptionRu // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionEn: freezed == descriptionEn
          ? _value.descriptionEn
          : descriptionEn // ignore: cast_nullable_to_non_nullable
              as String?,
      descriptionUz: freezed == descriptionUz
          ? _value.descriptionUz
          : descriptionUz // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStationId: freezed == subwayStationId
          ? _value.subwayStationId
          : subwayStationId // ignore: cast_nullable_to_non_nullable
              as int?,
      subwayLineId: freezed == subwayLineId
          ? _value.subwayLineId
          : subwayLineId // ignore: cast_nullable_to_non_nullable
              as int?,
      locationId: freezed == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as int?,
      featuredAt: freezed == featuredAt
          ? _value.featuredAt
          : featuredAt // ignore: cast_nullable_to_non_nullable
              as String?,
      moveInDate: freezed == moveInDate
          ? _value.moveInDate
          : moveInDate // ignore: cast_nullable_to_non_nullable
              as String?,
      privateRoom: freezed == privateRoom
          ? _value.privateRoom
          : privateRoom // ignore: cast_nullable_to_non_nullable
              as bool?,
      contactPhone: freezed == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      pointCloudUrl: freezed == pointCloudUrl
          ? _value.pointCloudUrl
          : pointCloudUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      subwayStation: freezed == subwayStation
          ? _value.subwayStation
          : subwayStation // ignore: cast_nullable_to_non_nullable
              as SubwayStationDetail?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as LocationDetail?,
      amenities: freezed == amenities
          ? _value._amenities
          : amenities // ignore: cast_nullable_to_non_nullable
              as List<Amenity>?,
      photos: freezed == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<Photo>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingDetailImpl implements _ListingDetail {
  const _$ListingDetailImpl(
      {required this.id,
      @JsonKey(name: "user_id") required this.userId,
      required this.title,
      @JsonKey(name: "listing_type_id") required this.listingTypeId,
      @JsonKey(name: "price") required this.price,
      @JsonKey(name: "is_active") required this.isActive,
      @JsonKey(name: "created_at") required this.createdAt,
      @JsonKey(name: "updated_at") required this.updatedAt,
      required this.user,
      @JsonKey(name: "listing_type") required this.listingType,
      this.description,
      @JsonKey(name: "description_ru") this.descriptionRu,
      @JsonKey(name: "description_en") this.descriptionEn,
      @JsonKey(name: "description_uz") this.descriptionUz,
      @JsonKey(name: "subway_station_id") this.subwayStationId,
      @JsonKey(name: "subway_line_id") this.subwayLineId,
      @JsonKey(name: "location_id") this.locationId,
      this.gender,
      @JsonKey(name: "featured_at") this.featuredAt,
      @JsonKey(name: "move_in_date") this.moveInDate,
      @JsonKey(name: "private_room") this.privateRoom,
      @JsonKey(name: "contact_phone") this.contactPhone,
      @JsonKey(name: "point_cloud_url") this.pointCloudUrl,
      @JsonKey(name: "subway_station") this.subwayStation,
      this.location,
      final List<Amenity>? amenities,
      final List<Photo>? photos})
      : _amenities = amenities,
        _photos = photos;

  factory _$ListingDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "user_id")
  final int userId;
  @override
  final String title;
  @override
  @JsonKey(name: "listing_type_id")
  final int listingTypeId;
  @override
  @JsonKey(name: "price")
  final int price;
  @override
  @JsonKey(name: "is_active")
  final bool isActive;
  @override
  @JsonKey(name: "created_at")
  final String createdAt;
  @override
  @JsonKey(name: "updated_at")
  final String updatedAt;
  @override
  final UserDetail user;
  @override
  @JsonKey(name: "listing_type")
  final ListingTypeDetail listingType;
  @override
  final String? description;
  @override
  @JsonKey(name: "description_ru")
  final String? descriptionRu;
  @override
  @JsonKey(name: "description_en")
  final String? descriptionEn;
  @override
  @JsonKey(name: "description_uz")
  final String? descriptionUz;
  @override
  @JsonKey(name: "subway_station_id")
  final int? subwayStationId;
  @override
  @JsonKey(name: "subway_line_id")
  final int? subwayLineId;
  @override
  @JsonKey(name: "location_id")
  final int? locationId;
  @override
  final int? gender;
  @override
  @JsonKey(name: "featured_at")
  final String? featuredAt;
  @override
  @JsonKey(name: "move_in_date")
  final String? moveInDate;
  @override
  @JsonKey(name: "private_room")
  final bool? privateRoom;

  /// Parsed from listing text (e.g. Telegram); use for contact when set.
  @override
  @JsonKey(name: "contact_phone")
  final String? contactPhone;
  @override
  @JsonKey(name: "point_cloud_url")
  final String? pointCloudUrl;
  @override
  @JsonKey(name: "subway_station")
  final SubwayStationDetail? subwayStation;
  @override
  final LocationDetail? location;
  final List<Amenity>? _amenities;
  @override
  List<Amenity>? get amenities {
    final value = _amenities;
    if (value == null) return null;
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<Photo>? _photos;
  @override
  List<Photo>? get photos {
    final value = _photos;
    if (value == null) return null;
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ListingDetail(id: $id, userId: $userId, title: $title, listingTypeId: $listingTypeId, price: $price, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, user: $user, listingType: $listingType, description: $description, descriptionRu: $descriptionRu, descriptionEn: $descriptionEn, descriptionUz: $descriptionUz, subwayStationId: $subwayStationId, subwayLineId: $subwayLineId, locationId: $locationId, gender: $gender, featuredAt: $featuredAt, moveInDate: $moveInDate, privateRoom: $privateRoom, contactPhone: $contactPhone, pointCloudUrl: $pointCloudUrl, subwayStation: $subwayStation, location: $location, amenities: $amenities, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.listingTypeId, listingTypeId) ||
                other.listingTypeId == listingTypeId) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.listingType, listingType) ||
                other.listingType == listingType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.descriptionRu, descriptionRu) ||
                other.descriptionRu == descriptionRu) &&
            (identical(other.descriptionEn, descriptionEn) ||
                other.descriptionEn == descriptionEn) &&
            (identical(other.descriptionUz, descriptionUz) ||
                other.descriptionUz == descriptionUz) &&
            (identical(other.subwayStationId, subwayStationId) ||
                other.subwayStationId == subwayStationId) &&
            (identical(other.subwayLineId, subwayLineId) ||
                other.subwayLineId == subwayLineId) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.featuredAt, featuredAt) ||
                other.featuredAt == featuredAt) &&
            (identical(other.moveInDate, moveInDate) ||
                other.moveInDate == moveInDate) &&
            (identical(other.privateRoom, privateRoom) ||
                other.privateRoom == privateRoom) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.pointCloudUrl, pointCloudUrl) ||
                other.pointCloudUrl == pointCloudUrl) &&
            (identical(other.subwayStation, subwayStation) ||
                other.subwayStation == subwayStation) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality()
                .equals(other._amenities, _amenities) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        title,
        listingTypeId,
        price,
        isActive,
        createdAt,
        updatedAt,
        user,
        listingType,
        description,
        descriptionRu,
        descriptionEn,
        descriptionUz,
        subwayStationId,
        subwayLineId,
        locationId,
        gender,
        featuredAt,
        moveInDate,
        privateRoom,
        contactPhone,
        pointCloudUrl,
        subwayStation,
        location,
        const DeepCollectionEquality().hash(_amenities),
        const DeepCollectionEquality().hash(_photos)
      ]);

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingDetailImplCopyWith<_$ListingDetailImpl> get copyWith =>
      __$$ListingDetailImplCopyWithImpl<_$ListingDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingDetailImplToJson(
      this,
    );
  }
}

abstract class _ListingDetail implements ListingDetail {
  const factory _ListingDetail(
      {required final int id,
      @JsonKey(name: "user_id") required final int userId,
      required final String title,
      @JsonKey(name: "listing_type_id") required final int listingTypeId,
      @JsonKey(name: "price") required final int price,
      @JsonKey(name: "is_active") required final bool isActive,
      @JsonKey(name: "created_at") required final String createdAt,
      @JsonKey(name: "updated_at") required final String updatedAt,
      required final UserDetail user,
      @JsonKey(name: "listing_type")
      required final ListingTypeDetail listingType,
      final String? description,
      @JsonKey(name: "description_ru") final String? descriptionRu,
      @JsonKey(name: "description_en") final String? descriptionEn,
      @JsonKey(name: "description_uz") final String? descriptionUz,
      @JsonKey(name: "subway_station_id") final int? subwayStationId,
      @JsonKey(name: "subway_line_id") final int? subwayLineId,
      @JsonKey(name: "location_id") final int? locationId,
      final int? gender,
      @JsonKey(name: "featured_at") final String? featuredAt,
      @JsonKey(name: "move_in_date") final String? moveInDate,
      @JsonKey(name: "private_room") final bool? privateRoom,
      @JsonKey(name: "contact_phone") final String? contactPhone,
      @JsonKey(name: "point_cloud_url") final String? pointCloudUrl,
      @JsonKey(name: "subway_station") final SubwayStationDetail? subwayStation,
      final LocationDetail? location,
      final List<Amenity>? amenities,
      final List<Photo>? photos}) = _$ListingDetailImpl;

  factory _ListingDetail.fromJson(Map<String, dynamic> json) =
      _$ListingDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "user_id")
  int get userId;
  @override
  String get title;
  @override
  @JsonKey(name: "listing_type_id")
  int get listingTypeId;
  @override
  @JsonKey(name: "price")
  int get price;
  @override
  @JsonKey(name: "is_active")
  bool get isActive;
  @override
  @JsonKey(name: "created_at")
  String get createdAt;
  @override
  @JsonKey(name: "updated_at")
  String get updatedAt;
  @override
  UserDetail get user;
  @override
  @JsonKey(name: "listing_type")
  ListingTypeDetail get listingType;
  @override
  String? get description;
  @override
  @JsonKey(name: "description_ru")
  String? get descriptionRu;
  @override
  @JsonKey(name: "description_en")
  String? get descriptionEn;
  @override
  @JsonKey(name: "description_uz")
  String? get descriptionUz;
  @override
  @JsonKey(name: "subway_station_id")
  int? get subwayStationId;
  @override
  @JsonKey(name: "subway_line_id")
  int? get subwayLineId;
  @override
  @JsonKey(name: "location_id")
  int? get locationId;
  @override
  int? get gender;
  @override
  @JsonKey(name: "featured_at")
  String? get featuredAt;
  @override
  @JsonKey(name: "move_in_date")
  String? get moveInDate;
  @override
  @JsonKey(name: "private_room")
  bool? get privateRoom;

  /// Parsed from listing text (e.g. Telegram); use for contact when set.
  @override
  @JsonKey(name: "contact_phone")
  String? get contactPhone;
  @override
  @JsonKey(name: "point_cloud_url")
  String? get pointCloudUrl;
  @override
  @JsonKey(name: "subway_station")
  SubwayStationDetail? get subwayStation;
  @override
  LocationDetail? get location;
  @override
  List<Amenity>? get amenities;
  @override
  List<Photo>? get photos;

  /// Create a copy of ListingDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingDetailImplCopyWith<_$ListingDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserDetail _$UserDetailFromJson(Map<String, dynamic> json) {
  return _UserDetail.fromJson(json);
}

/// @nodoc
mixin _$UserDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "created_at")
  String get createdAt => throw _privateConstructorUsedError;
  String? get email =>
      throw _privateConstructorUsedError; // Add email field from API response
  String? get phone => throw _privateConstructorUsedError;

  /// Serializes this UserDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDetailCopyWith<UserDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDetailCopyWith<$Res> {
  factory $UserDetailCopyWith(
          UserDetail value, $Res Function(UserDetail) then) =
      _$UserDetailCopyWithImpl<$Res, UserDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "created_at") String createdAt,
      String? email,
      String? phone});
}

/// @nodoc
class _$UserDetailCopyWithImpl<$Res, $Val extends UserDetail>
    implements $UserDetailCopyWith<$Res> {
  _$UserDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserDetailImplCopyWith<$Res>
    implements $UserDetailCopyWith<$Res> {
  factory _$$UserDetailImplCopyWith(
          _$UserDetailImpl value, $Res Function(_$UserDetailImpl) then) =
      __$$UserDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "created_at") String createdAt,
      String? email,
      String? phone});
}

/// @nodoc
class __$$UserDetailImplCopyWithImpl<$Res>
    extends _$UserDetailCopyWithImpl<$Res, _$UserDetailImpl>
    implements _$$UserDetailImplCopyWith<$Res> {
  __$$UserDetailImplCopyWithImpl(
      _$UserDetailImpl _value, $Res Function(_$UserDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? createdAt = null,
    Object? email = freezed,
    Object? phone = freezed,
  }) {
    return _then(_$UserDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDetailImpl implements _UserDetail {
  const _$UserDetailImpl(
      {required this.id,
      @JsonKey(name: "created_at") required this.createdAt,
      this.email,
      this.phone});

  factory _$UserDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "created_at")
  final String createdAt;
  @override
  final String? email;
// Add email field from API response
  @override
  final String? phone;

  @override
  String toString() {
    return 'UserDetail(id: $id, createdAt: $createdAt, email: $email, phone: $phone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, createdAt, email, phone);

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDetailImplCopyWith<_$UserDetailImpl> get copyWith =>
      __$$UserDetailImplCopyWithImpl<_$UserDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDetailImplToJson(
      this,
    );
  }
}

abstract class _UserDetail implements UserDetail {
  const factory _UserDetail(
      {required final int id,
      @JsonKey(name: "created_at") required final String createdAt,
      final String? email,
      final String? phone}) = _$UserDetailImpl;

  factory _UserDetail.fromJson(Map<String, dynamic> json) =
      _$UserDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "created_at")
  String get createdAt;
  @override
  String? get email; // Add email field from API response
  @override
  String? get phone;

  /// Create a copy of UserDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDetailImplCopyWith<_$UserDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ListingTypeDetail _$ListingTypeDetailFromJson(Map<String, dynamic> json) {
  return _ListingTypeDetail.fromJson(json);
}

/// @nodoc
mixin _$ListingTypeDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String get nameEn => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;

  /// Serializes this ListingTypeDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ListingTypeDetailCopyWith<ListingTypeDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ListingTypeDetailCopyWith<$Res> {
  factory $ListingTypeDetailCopyWith(
          ListingTypeDetail value, $Res Function(ListingTypeDetail) then) =
      _$ListingTypeDetailCopyWithImpl<$Res, ListingTypeDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      String code});
}

/// @nodoc
class _$ListingTypeDetailCopyWithImpl<$Res, $Val extends ListingTypeDetail>
    implements $ListingTypeDetailCopyWith<$Res> {
  _$ListingTypeDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? code = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ListingTypeDetailImplCopyWith<$Res>
    implements $ListingTypeDetailCopyWith<$Res> {
  factory _$$ListingTypeDetailImplCopyWith(_$ListingTypeDetailImpl value,
          $Res Function(_$ListingTypeDetailImpl) then) =
      __$$ListingTypeDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      String code});
}

/// @nodoc
class __$$ListingTypeDetailImplCopyWithImpl<$Res>
    extends _$ListingTypeDetailCopyWithImpl<$Res, _$ListingTypeDetailImpl>
    implements _$$ListingTypeDetailImplCopyWith<$Res> {
  __$$ListingTypeDetailImplCopyWithImpl(_$ListingTypeDetailImpl _value,
      $Res Function(_$ListingTypeDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? code = null,
  }) {
    return _then(_$ListingTypeDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ListingTypeDetailImpl implements _ListingTypeDetail {
  const _$ListingTypeDetailImpl(
      {required this.id,
      @JsonKey(name: "name_uz") required this.nameUz,
      @JsonKey(name: "name_ru") required this.nameRu,
      @JsonKey(name: "name_en") required this.nameEn,
      required this.code});

  factory _$ListingTypeDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$ListingTypeDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String nameRu;
  @override
  @JsonKey(name: "name_en")
  final String nameEn;
  @override
  final String code;

  @override
  String toString() {
    return 'ListingTypeDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListingTypeDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nameUz, nameRu, nameEn, code);

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListingTypeDetailImplCopyWith<_$ListingTypeDetailImpl> get copyWith =>
      __$$ListingTypeDetailImplCopyWithImpl<_$ListingTypeDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ListingTypeDetailImplToJson(
      this,
    );
  }
}

abstract class _ListingTypeDetail implements ListingTypeDetail {
  const factory _ListingTypeDetail(
      {required final int id,
      @JsonKey(name: "name_uz") required final String nameUz,
      @JsonKey(name: "name_ru") required final String nameRu,
      @JsonKey(name: "name_en") required final String nameEn,
      required final String code}) = _$ListingTypeDetailImpl;

  factory _ListingTypeDetail.fromJson(Map<String, dynamic> json) =
      _$ListingTypeDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String get nameRu;
  @override
  @JsonKey(name: "name_en")
  String get nameEn;
  @override
  String get code;

  /// Create a copy of ListingTypeDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListingTypeDetailImplCopyWith<_$ListingTypeDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SubwayStationDetail _$SubwayStationDetailFromJson(Map<String, dynamic> json) {
  return _SubwayStationDetail.fromJson(json);
}

/// @nodoc
mixin _$SubwayStationDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String get nameEn => throw _privateConstructorUsedError;
  int get line => throw _privateConstructorUsedError;

  /// Serializes this SubwayStationDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubwayStationDetailCopyWith<SubwayStationDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubwayStationDetailCopyWith<$Res> {
  factory $SubwayStationDetailCopyWith(
          SubwayStationDetail value, $Res Function(SubwayStationDetail) then) =
      _$SubwayStationDetailCopyWithImpl<$Res, SubwayStationDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      int line});
}

/// @nodoc
class _$SubwayStationDetailCopyWithImpl<$Res, $Val extends SubwayStationDetail>
    implements $SubwayStationDetailCopyWith<$Res> {
  _$SubwayStationDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? line = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SubwayStationDetailImplCopyWith<$Res>
    implements $SubwayStationDetailCopyWith<$Res> {
  factory _$$SubwayStationDetailImplCopyWith(_$SubwayStationDetailImpl value,
          $Res Function(_$SubwayStationDetailImpl) then) =
      __$$SubwayStationDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      int line});
}

/// @nodoc
class __$$SubwayStationDetailImplCopyWithImpl<$Res>
    extends _$SubwayStationDetailCopyWithImpl<$Res, _$SubwayStationDetailImpl>
    implements _$$SubwayStationDetailImplCopyWith<$Res> {
  __$$SubwayStationDetailImplCopyWithImpl(_$SubwayStationDetailImpl _value,
      $Res Function(_$SubwayStationDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? line = null,
  }) {
    return _then(_$SubwayStationDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      line: null == line
          ? _value.line
          : line // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SubwayStationDetailImpl implements _SubwayStationDetail {
  const _$SubwayStationDetailImpl(
      {required this.id,
      @JsonKey(name: "name_uz") required this.nameUz,
      @JsonKey(name: "name_ru") required this.nameRu,
      @JsonKey(name: "name_en") required this.nameEn,
      required this.line});

  factory _$SubwayStationDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubwayStationDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String nameRu;
  @override
  @JsonKey(name: "name_en")
  final String nameEn;
  @override
  final int line;

  @override
  String toString() {
    return 'SubwayStationDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, line: $line)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubwayStationDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.line, line) || other.line == line));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, nameUz, nameRu, nameEn, line);

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubwayStationDetailImplCopyWith<_$SubwayStationDetailImpl> get copyWith =>
      __$$SubwayStationDetailImplCopyWithImpl<_$SubwayStationDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubwayStationDetailImplToJson(
      this,
    );
  }
}

abstract class _SubwayStationDetail implements SubwayStationDetail {
  const factory _SubwayStationDetail(
      {required final int id,
      @JsonKey(name: "name_uz") required final String nameUz,
      @JsonKey(name: "name_ru") required final String nameRu,
      @JsonKey(name: "name_en") required final String nameEn,
      required final int line}) = _$SubwayStationDetailImpl;

  factory _SubwayStationDetail.fromJson(Map<String, dynamic> json) =
      _$SubwayStationDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String get nameRu;
  @override
  @JsonKey(name: "name_en")
  String get nameEn;
  @override
  int get line;

  /// Create a copy of SubwayStationDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubwayStationDetailImplCopyWith<_$SubwayStationDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocationDetail _$LocationDetailFromJson(Map<String, dynamic> json) {
  return _LocationDetail.fromJson(json);
}

/// @nodoc
mixin _$LocationDetail {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: "name_uz")
  String get nameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "name_ru")
  String get nameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "name_en")
  String get nameEn => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_uz")
  String get shortNameUz => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_ru")
  String get shortNameRu => throw _privateConstructorUsedError;
  @JsonKey(name: "short_name_en")
  String get shortNameEn => throw _privateConstructorUsedError;

  /// Serializes this LocationDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationDetailCopyWith<LocationDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationDetailCopyWith<$Res> {
  factory $LocationDetailCopyWith(
          LocationDetail value, $Res Function(LocationDetail) then) =
      _$LocationDetailCopyWithImpl<$Res, LocationDetail>;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      @JsonKey(name: "short_name_uz") String shortNameUz,
      @JsonKey(name: "short_name_ru") String shortNameRu,
      @JsonKey(name: "short_name_en") String shortNameEn});
}

/// @nodoc
class _$LocationDetailCopyWithImpl<$Res, $Val extends LocationDetail>
    implements $LocationDetailCopyWith<$Res> {
  _$LocationDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? shortNameUz = null,
    Object? shortNameRu = null,
    Object? shortNameEn = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameUz: null == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameRu: null == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameEn: null == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationDetailImplCopyWith<$Res>
    implements $LocationDetailCopyWith<$Res> {
  factory _$$LocationDetailImplCopyWith(_$LocationDetailImpl value,
          $Res Function(_$LocationDetailImpl) then) =
      __$$LocationDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: "name_uz") String nameUz,
      @JsonKey(name: "name_ru") String nameRu,
      @JsonKey(name: "name_en") String nameEn,
      @JsonKey(name: "short_name_uz") String shortNameUz,
      @JsonKey(name: "short_name_ru") String shortNameRu,
      @JsonKey(name: "short_name_en") String shortNameEn});
}

/// @nodoc
class __$$LocationDetailImplCopyWithImpl<$Res>
    extends _$LocationDetailCopyWithImpl<$Res, _$LocationDetailImpl>
    implements _$$LocationDetailImplCopyWith<$Res> {
  __$$LocationDetailImplCopyWithImpl(
      _$LocationDetailImpl _value, $Res Function(_$LocationDetailImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? nameUz = null,
    Object? nameRu = null,
    Object? nameEn = null,
    Object? shortNameUz = null,
    Object? shortNameRu = null,
    Object? shortNameEn = null,
  }) {
    return _then(_$LocationDetailImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      nameUz: null == nameUz
          ? _value.nameUz
          : nameUz // ignore: cast_nullable_to_non_nullable
              as String,
      nameRu: null == nameRu
          ? _value.nameRu
          : nameRu // ignore: cast_nullable_to_non_nullable
              as String,
      nameEn: null == nameEn
          ? _value.nameEn
          : nameEn // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameUz: null == shortNameUz
          ? _value.shortNameUz
          : shortNameUz // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameRu: null == shortNameRu
          ? _value.shortNameRu
          : shortNameRu // ignore: cast_nullable_to_non_nullable
              as String,
      shortNameEn: null == shortNameEn
          ? _value.shortNameEn
          : shortNameEn // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationDetailImpl implements _LocationDetail {
  const _$LocationDetailImpl(
      {required this.id,
      @JsonKey(name: "name_uz") required this.nameUz,
      @JsonKey(name: "name_ru") required this.nameRu,
      @JsonKey(name: "name_en") required this.nameEn,
      @JsonKey(name: "short_name_uz") required this.shortNameUz,
      @JsonKey(name: "short_name_ru") required this.shortNameRu,
      @JsonKey(name: "short_name_en") required this.shortNameEn});

  factory _$LocationDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationDetailImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: "name_uz")
  final String nameUz;
  @override
  @JsonKey(name: "name_ru")
  final String nameRu;
  @override
  @JsonKey(name: "name_en")
  final String nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  final String shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  final String shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  final String shortNameEn;

  @override
  String toString() {
    return 'LocationDetail(id: $id, nameUz: $nameUz, nameRu: $nameRu, nameEn: $nameEn, shortNameUz: $shortNameUz, shortNameRu: $shortNameRu, shortNameEn: $shortNameEn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationDetailImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.nameUz, nameUz) || other.nameUz == nameUz) &&
            (identical(other.nameRu, nameRu) || other.nameRu == nameRu) &&
            (identical(other.nameEn, nameEn) || other.nameEn == nameEn) &&
            (identical(other.shortNameUz, shortNameUz) ||
                other.shortNameUz == shortNameUz) &&
            (identical(other.shortNameRu, shortNameRu) ||
                other.shortNameRu == shortNameRu) &&
            (identical(other.shortNameEn, shortNameEn) ||
                other.shortNameEn == shortNameEn));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, nameUz, nameRu, nameEn,
      shortNameUz, shortNameRu, shortNameEn);

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationDetailImplCopyWith<_$LocationDetailImpl> get copyWith =>
      __$$LocationDetailImplCopyWithImpl<_$LocationDetailImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationDetailImplToJson(
      this,
    );
  }
}

abstract class _LocationDetail implements LocationDetail {
  const factory _LocationDetail(
          {required final int id,
          @JsonKey(name: "name_uz") required final String nameUz,
          @JsonKey(name: "name_ru") required final String nameRu,
          @JsonKey(name: "name_en") required final String nameEn,
          @JsonKey(name: "short_name_uz") required final String shortNameUz,
          @JsonKey(name: "short_name_ru") required final String shortNameRu,
          @JsonKey(name: "short_name_en") required final String shortNameEn}) =
      _$LocationDetailImpl;

  factory _LocationDetail.fromJson(Map<String, dynamic> json) =
      _$LocationDetailImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: "name_uz")
  String get nameUz;
  @override
  @JsonKey(name: "name_ru")
  String get nameRu;
  @override
  @JsonKey(name: "name_en")
  String get nameEn;
  @override
  @JsonKey(name: "short_name_uz")
  String get shortNameUz;
  @override
  @JsonKey(name: "short_name_ru")
  String get shortNameRu;
  @override
  @JsonKey(name: "short_name_en")
  String get shortNameEn;

  /// Create a copy of LocationDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationDetailImplCopyWith<_$LocationDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
