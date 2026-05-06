import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigRequestsEvent {
  const GigRequestsEvent();
}

class FetchGigRequests extends GigRequestsEvent {
  const FetchGigRequests({this.refresh = false, this.categoryId, this.status});
  final bool refresh;
  final int? categoryId;
  final GigRequestStatus? status;
}

class LoadMoreGigRequests extends GigRequestsEvent {
  const LoadMoreGigRequests();
}

abstract class GigRequestsState {
  const GigRequestsState();
}

class GigRequestsInitial extends GigRequestsState {
  const GigRequestsInitial();
}

class GigRequestsLoading extends GigRequestsState {
  const GigRequestsLoading();
}

class GigRequestsLoaded extends GigRequestsState {
  const GigRequestsLoaded({
    required this.requests,
    required this.hasMore,
    required this.page,
    required this.categoryId,
    required this.status,
  });
  final List<GigRequest> requests;
  final bool hasMore;
  final int page;
  final int? categoryId;
  final GigRequestStatus? status;
}

class GigRequestsError extends GigRequestsState {
  const GigRequestsError(this.message);
  final String message;
}

/// Paginated list bloc for `/gigs/requests`. Mirrors [GigOffersBloc] so the
/// Services hub can swap between Services / Tasks tabs with the same
/// load-more / pull-to-refresh patterns.
class GigRequestsBloc extends Bloc<GigRequestsEvent, GigRequestsState> {
  GigRequestsBloc(this._service) : super(const GigRequestsInitial()) {
    on<FetchGigRequests>(_onFetch);
    on<LoadMoreGigRequests>(_onLoadMore);
  }

  final IGigService _service;

  Future<void> _onFetch(
    FetchGigRequests e,
    Emitter<GigRequestsState> emit,
  ) async {
    emit(const GigRequestsLoading());
    try {
      final res = await _service.listRequests(
        page: 1,
        limit: 20,
        categoryId: e.categoryId,
        status: e.status,
      );
      emit(
        GigRequestsLoaded(
          requests: res.requests,
          hasMore: res.hasMore,
          page: 1,
          categoryId: e.categoryId,
          status: e.status,
        ),
      );
    } catch (err) {
      emit(GigRequestsError(err.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreGigRequests _,
    Emitter<GigRequestsState> emit,
  ) async {
    final s = state;
    if (s is! GigRequestsLoaded || !s.hasMore) return;
    try {
      final res = await _service.listRequests(
        page: s.page + 1,
        limit: 20,
        categoryId: s.categoryId,
        status: s.status,
      );
      emit(
        GigRequestsLoaded(
          requests: [...s.requests, ...res.requests],
          hasMore: res.hasMore,
          page: s.page + 1,
          categoryId: s.categoryId,
          status: s.status,
        ),
      );
    } catch (err) {
      emit(GigRequestsError(err.toString()));
    }
  }
}
