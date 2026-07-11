part of "amenities_bloc.dart";

@freezed
sealed class AmenitiesEvent with _$AmenitiesEvent {
  const factory AmenitiesEvent.fetchAmenities() = _FetchAmenities;
}
