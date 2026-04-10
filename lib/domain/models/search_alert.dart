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

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim());
    return null;
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim());
    return null;
  }

  static int? _nullIfNonPositiveInt(dynamic v) {
    final x = _toInt(v);
    if (x == null) return null;
    return x > 0 ? x : null;
  }

  static dynamic _get(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      if (json.containsKey(k)) return json[k];
    }
    return null;
  }

  static SearchAlert fromJson(Map<String, dynamic> json) {
    final ids = _get(json, const ["subway_station_ids", "subwayStationIds"]);
    return SearchAlert(
      id: _toInt(_get(json, const ["id"])) ?? 0,
      enabled: json["enabled"] as bool? ?? true,
      listingTypeId: _toInt(
        _get(json, const ["listing_type_id", "listingTypeId"]),
      ),
      // 0 means "any district" / "not set" — treat as null.
      locationId: _nullIfNonPositiveInt(
        _get(json, const ["location_id", "locationId"]),
      ),
      // 0 means "not set" — treat as null.
      subwayStationId: _nullIfNonPositiveInt(
        _get(json, const ["subway_station_id", "subwayStationId"]),
      ),
      subwayStationIds:
          ids is List
              ? ids
                  .map(_nullIfNonPositiveInt)
                  .whereType<int>()
                  .toList()
              : null,
      subwayLineId: _nullIfNonPositiveInt(
        _get(json, const ["subway_line_id", "subwayLineId"]),
      ),
      gender: _toInt(_get(json, const ["gender"])),
      minPrice: _toDouble(_get(json, const ["min_price", "minPrice"])),
      maxPrice: _toDouble(_get(json, const ["max_price", "maxPrice"])),
      privateRoom: _get(json, const ["private_room", "privateRoom"]) as bool?,
      withPhoto: _get(json, const ["with_photo", "withPhoto"]) as bool?,
    );
  }
}

