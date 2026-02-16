import "package:bloc/bloc.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/services/location_service.dart";

part "locations_event.dart";
part "locations_state.dart";
part "locations_bloc.freezed.dart";

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  LocationsBloc(this._locationService) : super(const LocationsState.initial()) {
    on<LocationsEvent>((event, emit) async {
      await event.map(
        fetchLocations: (e) async => _onFetchLocations(emit),
      );
    });
  }

  final ILocationService _locationService;

  Future<void> _onFetchLocations(Emitter<LocationsState> emit) async {
    emit(const LocationsState.loading());

    try {
      // Service now automatically uses current app language
      final locations = await _locationService.getLocations();
      emit(LocationsState.loaded(locations: locations));
    } catch (error) {
      emit(LocationsState.error(message: error.toString()));
    }
  }
}
