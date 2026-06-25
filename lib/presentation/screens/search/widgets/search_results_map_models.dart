part of "../search_results_map_screen.dart";

class _SearchMapResult {
  const _SearchMapResult({
    required this.listings,
    required this.pins,
    required this.total,
  });

  final List<Listing> listings;
  final List<ListingMapPin> pins;
  final int total;
}

class _PinMeta {
  const _PinMeta({
    required this.locationLabel,
    required this.stationLabel,
    required this.subwayLineIds,
  });

  final String? locationLabel;
  final String? stationLabel;
  final List<int> subwayLineIds;
}

class _MetroSummary {
  const _MetroSummary({required this.label, required this.lineIds});

  final String label;
  final List<int> lineIds;
}

class _MapBounds {
  const _MapBounds({
    required this.minLatitude,
    required this.maxLatitude,
    required this.minLongitude,
    required this.maxLongitude,
  });

  factory _MapBounds.fromVisibleRegion(VisibleRegion region) {
    final points = [
      region.topLeft,
      region.topRight,
      region.bottomLeft,
      region.bottomRight,
    ];
    final latitudes = points.map((point) => point.latitude);
    final longitudes = points.map((point) => point.longitude);

    return _MapBounds(
      minLatitude: latitudes.reduce((a, b) => a < b ? a : b),
      maxLatitude: latitudes.reduce((a, b) => a > b ? a : b),
      minLongitude: longitudes.reduce((a, b) => a < b ? a : b),
      maxLongitude: longitudes.reduce((a, b) => a > b ? a : b),
    );
  }

  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;

  bool contains(double latitude, double longitude) {
    return latitude >= minLatitude &&
        latitude <= maxLatitude &&
        longitude >= minLongitude &&
        longitude <= maxLongitude;
  }
}
