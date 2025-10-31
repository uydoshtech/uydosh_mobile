part of 'subway_stations_bloc.dart';

@freezed
class SubwayStationsState with _$SubwayStationsState {
  const factory SubwayStationsState.initial() = _Initial;
  const factory SubwayStationsState.loading() = _Loading;
  const factory SubwayStationsState.loaded({
    required List<SubwayStation> stations,
  }) = _Loaded;
  const factory SubwayStationsState.error({required String message}) = _Error;
}
