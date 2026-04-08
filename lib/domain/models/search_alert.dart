class SearchAlert {
  const SearchAlert({
    required this.id,
    required this.enabled,
    required this.listingTypeId,
    required this.locationId,
    required this.subwayStationId,
    required this.subwayStationIds,
    required this.subwayLineId,
    required this.gender,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
  });

  final int id;
  final bool enabled;
  final int? listingTypeId;
  final int? locationId;
  final int? subwayStationId;
  final List<int>? subwayStationIds;
  final int? subwayLineId;
  final int? gender;
  final double? minPrice;
  final double? maxPrice;
  final bool? privateRoom;
  final bool? withPhoto;

  static SearchAlert fromJson(Map<String, dynamic> json) {
    final ids = json["subway_station_ids"];
    return SearchAlert(
      id: (json["id"] as num).toInt(),
      enabled: json["enabled"] as bool? ?? true,
      listingTypeId: (json["listing_type_id"] as num?)?.toInt(),
      locationId: (json["location_id"] as num?)?.toInt(),
      subwayStationId: (json["subway_station_id"] as num?)?.toInt(),
      subwayStationIds:
          ids is List ? ids.whereType<num>().map((e) => e.toInt()).toList() : null,
      subwayLineId: (json["subway_line_id"] as num?)?.toInt(),
      gender: (json["gender"] as num?)?.toInt(),
      minPrice: (json["min_price"] as num?)?.toDouble(),
      maxPrice: (json["max_price"] as num?)?.toDouble(),
      privateRoom: json["private_room"] as bool?,
      withPhoto: json["with_photo"] as bool?,
    );
  }
}

