import "package:flutter_bloc/flutter_bloc.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/services/amenity_service.dart";

part "amenities_event.dart";
part "amenities_state.dart";
part "amenities_bloc.freezed.dart";

class AmenitiesBloc extends Bloc<AmenitiesEvent, AmenitiesState> {

  AmenitiesBloc(this._amenityService) : super(const AmenitiesState.initial()) {
    on<AmenitiesEvent>((event, emit) async {
      await event.map(
        fetchAmenities: (e) async {
          emit(const AmenitiesState.loading());
          try {
            final amenities = await _amenityService.getAmenities();

            emit(AmenitiesState.loaded(amenities: amenities));
          } catch (error) {
            emit(AmenitiesState.error(message: error.toString()));
          }
        },
      );
    });
  }
  final IAmenityService _amenityService;
}
