part of "subway_stations_bloc.dart";

@freezed
sealed class SubwayStationsEvent with _$SubwayStationsEvent {
  const factory SubwayStationsEvent.fetchSubwayStations() =
      _FetchSubwayStations;
  const factory SubwayStationsEvent.fetchSubwayStationsByLine({
    required int line,
  }) = _FetchSubwayStationsByLine;
}
