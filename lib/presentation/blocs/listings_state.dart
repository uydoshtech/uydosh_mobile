import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/listing.dart";

part "listings_state.freezed.dart";

@freezed
class ListingsState with _$ListingsState {
  const factory ListingsState.initial() = _$InitialImpl;
  const factory ListingsState.loading() = _$LoadingImpl;
  const factory ListingsState.loaded({
    required List<Listing> listings,
    required bool hasMore,
    required int currentPage,
  }) = _$LoadedImpl;
  const factory ListingsState.error(String message) = _$ErrorImpl;
}
