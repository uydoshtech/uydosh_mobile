import "package:bloc/bloc.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/domain/models/subway_station.dart";

part "subway_stations_bloc.freezed.dart";
part "subway_stations_event.dart";
part "subway_stations_state.dart";

class SubwayStationsBloc
    extends Bloc<SubwayStationsEvent, SubwayStationsState> {
  SubwayStationsBloc() : super(const SubwayStationsState.initial()) {
    on<SubwayStationsEvent>((event, emit) async {
      await event.map(
        fetchSubwayStations: (e) async => _onFetchSubwayStations(emit),
        fetchSubwayStationsByLine:
            (e) async => _onFetchSubwayStationsByLine(emit, e.line),
      );
    });
  }

  Future<void> _onFetchSubwayStations(Emitter<SubwayStationsState> emit) async {
    emit(const SubwayStationsState.loading());

    try {
      // Use cache instead of API call for better performance
      final stations = MetroCache.getAllStations();
      emit(SubwayStationsState.loaded(stations: stations));
    } catch (error) {
      emit(SubwayStationsState.error(message: error.toString()));
    }
  }

  Future<void> _onFetchSubwayStationsByLine(
    Emitter<SubwayStationsState> emit,
    int line,
  ) async {
    emit(const SubwayStationsState.loading());

    try {
      // Use cache instead of API call for better performance
      final stations = MetroCache.getStationsForLine(line);
      emit(SubwayStationsState.loaded(stations: stations));
    } catch (error) {
      emit(SubwayStationsState.error(message: error.toString()));
    }
  }
}
