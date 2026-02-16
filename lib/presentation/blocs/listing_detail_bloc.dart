import "package:bloc/bloc.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/listing_service.dart";

part "listing_detail_bloc.freezed.dart";
part "listing_detail_event.dart";
part "listing_detail_state.dart";

class ListingDetailBloc extends Bloc<ListingDetailEvent, ListingDetailState> {
  ListingDetailBloc(this._listingService)
    : super(const ListingDetailState.initial()) {
    on<ListingDetailEvent>((event, emit) async {
      await event.map(
        fetchListingDetail:
            (e) async => _onFetchListingDetail(emit, e.id),
        updateListingDetail:
            (e) async => _onUpdateListingDetail(emit, e.listingDetail),
      );
    });
  }

  final IListingService _listingService;

  Future<void> _onFetchListingDetail(
    Emitter<ListingDetailState> emit,
    int id,
  ) async {
    // Always emit loading to ensure fresh data is fetched
    emit(const ListingDetailState.loading());

    try {
      final listingDetail = await _listingService.getListingDetail(id);
      emit(ListingDetailState.loaded(listingDetail: listingDetail));
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ListingDetailState.error(message: sanitizedMessage));
    }
  }

  Future<void> _onUpdateListingDetail(
    Emitter<ListingDetailState> emit,
    ListingDetail listingDetail,
  ) async {
    // Update the state with the new listing detail
    emit(ListingDetailState.loaded(listingDetail: listingDetail));
  }
}
