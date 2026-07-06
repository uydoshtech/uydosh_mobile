import "dart:math" show asin, cos, pi, sin, sqrt;

import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/domain/models/subway_station.dart";

/// A metro station paired with an estimated walking time from a point.
class NearbyStationEstimate {
  const NearbyStationEstimate({
    required this.station,
    required this.walkMinutes,
  });

  final SubwayStation station;
  final double walkMinutes;
}

/// Client-side "stations near you" ranking used by the roommate-needed create
/// flow. Mirrors the Telegram Mini App wizard's `findNearbyStations`
/// (`telegram-create.js`) so both surfaces suggest the same stations for the
/// same address, without requiring a backend round trip.
abstract final class NearbyMetroStations {
  static const double _walkMetersPerMinute = 80;
  static const double _walkDetourFactor = 1.3;
  static const int _maxSuggestedStations = 12;
  static const double _fallbackMaxMinutes = 60;

  /// Stations within [maxMinutes] walking time of the given point, closest
  /// first, capped at [_maxSuggestedStations]. If none are within range, the
  /// single closest station is returned instead (as long as it isn't
  /// absurdly far), so the panel is never empty for a resolvable address.
  static List<NearbyStationEstimate> find(
    double latitude,
    double longitude, {
    required int maxMinutes,
  }) {
    final ranked = MetroCache.getAllStations()
        .map(
          (station) => NearbyStationEstimate(
            station: station,
            walkMinutes: _estimatedWalkMinutes(
              _haversineMeters(
                latitude,
                longitude,
                station.latitude,
                station.longitude,
              ),
            ),
          ),
        )
        .toList()
      ..sort((a, b) => a.walkMinutes.compareTo(b.walkMinutes));

    final withinRadius = ranked
        .where((estimate) => estimate.walkMinutes <= maxMinutes)
        .take(_maxSuggestedStations)
        .toList();
    if (withinRadius.isNotEmpty) return withinRadius;

    if (ranked.isNotEmpty && ranked.first.walkMinutes <= _fallbackMaxMinutes) {
      return [ranked.first];
    }
    return const [];
  }

  static double _estimatedWalkMinutes(double meters) {
    if (meters.isInfinite || meters.isNaN) return double.infinity;
    return (meters * _walkDetourFactor) / _walkMetersPerMinute;
  }

  static double _haversineMeters(
    double lat1,
    double lon1,
    double? lat2,
    double? lon2,
  ) {
    if (lat2 == null || lon2 == null) return double.infinity;
    const earthRadiusM = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return earthRadiusM * 2 * asin(sqrt(a.clamp(0.0, 1.0)));
  }

  static double _toRadians(double degrees) => degrees * (pi / 180);
}
