import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/listing.dart";

part "listings_state.freezed.dart";

@freezed
sealed class ListingsState with _$ListingsState {
  const factory ListingsState.initial() = _Initial;
  const factory ListingsState.loading() = _Loading;
  const factory ListingsState.loaded({
    required List<Listing> listings,
    required bool hasMore,
    required int currentPage,

    /// Total results count from API (stable across pagination).
    /// Null when the underlying endpoint doesn't provide totals.
    int? total,

    /// Monotonic marker so refresh completions still emit when data is unchanged.
    @Default(0) int revision,
  }) = _Loaded;
  const factory ListingsState.error(String message) = _Error;
}
