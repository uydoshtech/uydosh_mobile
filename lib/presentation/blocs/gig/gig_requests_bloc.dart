import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/state/gig_favorites_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigRequestsEvent {
  const GigRequestsEvent();
}

class FetchGigRequests extends GigRequestsEvent {
  const FetchGigRequests({
    this.refresh = false,
    this.categoryId,
    this.status,
    this.clientUserId,
  });
  final bool refresh;
  final int? categoryId;
  final GigRequestStatus? status;
  /// When set, lists only tasks posted by this user (e.g. "my tasks").
  final int? clientUserId;
}

class LoadMoreGigRequests extends GigRequestsEvent {
  const LoadMoreGigRequests();
}

/// Drops one request from the current loaded page after a successful owner cancel.
class RemoveGigRequestFromList extends GigRequestsEvent {
  const RemoveGigRequestFromList(this.requestId);
  final int requestId;
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
    this.clientUserId,
  });
  final List<GigRequest> requests;
  final bool hasMore;
  final int page;
  final int? categoryId;
  final GigRequestStatus? status;
  final int? clientUserId;
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
    on<RemoveGigRequestFromList>(_onRemoveRequest);
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
        clientUserId: e.clientUserId,
      );
      emit(
        GigRequestsLoaded(
          requests: res.requests,
          hasMore: res.hasMore,
          page: 1,
          categoryId: e.categoryId,
          status: e.status,
          clientUserId: e.clientUserId,
        ),
      );
      GigFavoritesState().syncFromRequests(res.requests);
    } catch (err) {
      emit(GigRequestsError(ErrorMessageHelper.sanitizeErrorMessage(err)));
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
        clientUserId: s.clientUserId,
      );
      emit(
        GigRequestsLoaded(
          requests: [...s.requests, ...res.requests],
          hasMore: res.hasMore,
          page: s.page + 1,
          categoryId: s.categoryId,
          status: s.status,
          clientUserId: s.clientUserId,
        ),
      );
      GigFavoritesState().syncFromRequests(res.requests);
    } catch (err) {
      emit(GigRequestsError(ErrorMessageHelper.sanitizeErrorMessage(err)));
    }
  }

  void _onRemoveRequest(
    RemoveGigRequestFromList e,
    Emitter<GigRequestsState> emit,
  ) {
    final s = state;
    if (s is! GigRequestsLoaded) return;
    final next = s.requests.where((r) => r.id != e.requestId).toList();
    emit(
      GigRequestsLoaded(
        requests: next,
        hasMore: s.hasMore,
        page: s.page,
        categoryId: s.categoryId,
        status: s.status,
        clientUserId: s.clientUserId,
      ),
    );
  }
}
