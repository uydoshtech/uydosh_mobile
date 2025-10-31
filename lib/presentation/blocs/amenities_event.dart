part of 'amenities_bloc.dart';

@freezed
class AmenitiesEvent with _$AmenitiesEvent {
  const factory AmenitiesEvent.fetchAmenities() = _FetchAmenities;
}
