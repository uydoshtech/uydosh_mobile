import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/state/gig_favorites_state.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigOffersEvent {
  const GigOffersEvent();
}

class FetchGigOffers extends GigOffersEvent {
  const FetchGigOffers({this.refresh = false, this.categoryId, this.providerUserId});
  final bool refresh;
  final int? categoryId;
  /// When set, lists only offers from this provider account (e.g. "my services").
  final int? providerUserId;
}

class LoadMoreGigOffers extends GigOffersEvent {
  const LoadMoreGigOffers();
}

/// Drops one offer from the current loaded page after a successful owner delete.
class RemoveGigOfferFromList extends GigOffersEvent {
  const RemoveGigOfferFromList(this.offerId);
  final int offerId;
}

abstract class GigOffersState {
  const GigOffersState();
}

class GigOffersInitial extends GigOffersState {
  const GigOffersInitial();
}

class GigOffersLoading extends GigOffersState {
  const GigOffersLoading();
}

class GigOffersLoaded extends GigOffersState {
  const GigOffersLoaded({
    required this.offers,
    required this.hasMore,
    required this.page,
    required this.categoryId,
    this.providerUserId,
  });
  final List<GigOffer> offers;
  final bool hasMore;
  final int page;
  final int? categoryId;
  final int? providerUserId;
}

class GigOffersError extends GigOffersState {
  const GigOffersError(this.message);
  final String message;
}

class GigOffersBloc extends Bloc<GigOffersEvent, GigOffersState> {
  GigOffersBloc(this._service) : super(const GigOffersInitial()) {
    on<FetchGigOffers>(_onFetch);
    on<LoadMoreGigOffers>(_onLoadMore);
    on<RemoveGigOfferFromList>(_onRemoveOffer);
  }

  final IGigService _service;

  Future<void> _onFetch(
    FetchGigOffers e,
    Emitter<GigOffersState> emit,
  ) async {
    emit(const GigOffersLoading());
    try {
      final res = await _service.listOffers(
        page: 1,
        limit: 20,
        categoryId: e.categoryId,
        providerUserId: e.providerUserId,
      );
      emit(
        GigOffersLoaded(
          offers: res.offers,
          hasMore: res.hasMore,
          page: 1,
          categoryId: e.categoryId,
          providerUserId: e.providerUserId,
        ),
      );
      GigFavoritesState().syncFromOffers(res.offers);
    } catch (err) {
      emit(GigOffersError(err.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreGigOffers _,
    Emitter<GigOffersState> emit,
  ) async {
    final s = state;
    if (s is! GigOffersLoaded || !s.hasMore) return;
    try {
      final res = await _service.listOffers(
        page: s.page + 1,
        limit: 20,
        categoryId: s.categoryId,
        providerUserId: s.providerUserId,
      );
      emit(
        GigOffersLoaded(
          offers: [...s.offers, ...res.offers],
          hasMore: res.hasMore,
          page: s.page + 1,
          categoryId: s.categoryId,
          providerUserId: s.providerUserId,
        ),
      );
      GigFavoritesState().syncFromOffers(res.offers);
    } catch (err) {
      emit(GigOffersError(err.toString()));
    }
  }

  void _onRemoveOffer(
    RemoveGigOfferFromList e,
    Emitter<GigOffersState> emit,
  ) {
    final s = state;
    if (s is! GigOffersLoaded) return;
    final next = s.offers.where((o) => o.id != e.offerId).toList();
    emit(
      GigOffersLoaded(
        offers: next,
        hasMore: s.hasMore,
        page: s.page,
        categoryId: s.categoryId,
        providerUserId: s.providerUserId,
      ),
    );
  }
}
