import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigOffersEvent {
  const GigOffersEvent();
}

class FetchGigOffers extends GigOffersEvent {
  const FetchGigOffers({this.refresh = false, this.categoryId});
  final bool refresh;
  final int? categoryId;
}

class LoadMoreGigOffers extends GigOffersEvent {
  const LoadMoreGigOffers();
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
  });
  final List<GigOffer> offers;
  final bool hasMore;
  final int page;
  final int? categoryId;
}

class GigOffersError extends GigOffersState {
  const GigOffersError(this.message);
  final String message;
}

class GigOffersBloc extends Bloc<GigOffersEvent, GigOffersState> {
  GigOffersBloc(this._service) : super(const GigOffersInitial()) {
    on<FetchGigOffers>(_onFetch);
    on<LoadMoreGigOffers>(_onLoadMore);
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
      );
      emit(
        GigOffersLoaded(
          offers: res.offers,
          hasMore: res.hasMore,
          page: 1,
          categoryId: e.categoryId,
        ),
      );
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
      );
      emit(
        GigOffersLoaded(
          offers: [...s.offers, ...res.offers],
          hasMore: res.hasMore,
          page: s.page + 1,
          categoryId: s.categoryId,
        ),
      );
    } catch (err) {
      emit(GigOffersError(err.toString()));
    }
  }
}
