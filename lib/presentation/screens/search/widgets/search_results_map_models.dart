part of "../search_results_map_screen.dart";

class _SearchMapResult {
  const _SearchMapResult({
    required this.pins,
    required this.total,
  });

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
