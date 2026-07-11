part of "amenities_bloc.dart";

@freezed
sealed class AmenitiesState with _$AmenitiesState {
  const factory AmenitiesState.initial() = _Initial;
  const factory AmenitiesState.loading() = _Loading;
  const factory AmenitiesState.loaded({required List<Amenity> amenities}) =
      _Loaded;
  const factory AmenitiesState.error({required String message}) = _Error;
}
