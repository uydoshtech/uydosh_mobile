int? _nullableMapPinIntFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _mapPinDoubleFromJson(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

/// Lightweight listing row returned by GET /listings/map for map pins.
class ListingMapPinData {
  const ListingMapPinData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.listingTypeId,
    required this.price,
    required this.title,
    this.gender,
    this.photoUrl,
    this.minPrice,
    this.maxPrice,
    this.listingTypeCode,
    this.subwayStationId,
    this.locationId,
    this.subwayLineId,
  });

  final int id;
  final double latitude;
  final double longitude;
  final int listingTypeId;
  final int? gender;
  final int price;
  final String title;
  final String? photoUrl;
  final int? minPrice;
  final int? maxPrice;
  final String? listingTypeCode;
  final int? subwayStationId;
  final int? locationId;
  final int? subwayLineId;

  factory ListingMapPinData.fromJson(Map<String, dynamic> json) {
    return ListingMapPinData(
      id: _nullableMapPinIntFromJson(json['id']) ?? 0,
      latitude: _mapPinDoubleFromJson(json['latitude']),
      longitude: _mapPinDoubleFromJson(json['longitude']),
      listingTypeId: _nullableMapPinIntFromJson(json['listing_type_id']) ?? 0,
      gender: _nullableMapPinIntFromJson(json['gender']),
      price: _nullableMapPinIntFromJson(json['price']) ?? 0,
      title: json['title'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      minPrice: _nullableMapPinIntFromJson(json['min_price']),
      maxPrice: _nullableMapPinIntFromJson(json['max_price']),
      listingTypeCode: json['listing_type_code'] as String?,
      subwayStationId: _nullableMapPinIntFromJson(json['subway_station_id']),
      locationId: _nullableMapPinIntFromJson(json['location_id']),
      subwayLineId: _nullableMapPinIntFromJson(json['subway_line_id']),
    );
  }
}
