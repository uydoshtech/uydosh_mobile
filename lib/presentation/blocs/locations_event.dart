part of "locations_bloc.dart";

@freezed
sealed class LocationsEvent with _$LocationsEvent {
  const factory LocationsEvent.fetchLocations() = _FetchLocations;
}
