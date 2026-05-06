import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigOfferDetailEvent {
  const GigOfferDetailEvent();
}

class FetchGigOfferDetail extends GigOfferDetailEvent {
  const FetchGigOfferDetail(this.offerId);
  final int offerId;
}

class BookThisOffer extends GigOfferDetailEvent {
  const BookThisOffer({this.scheduledStartAt, this.addressText});
  final DateTime? scheduledStartAt;
  final String? addressText;
}

abstract class GigOfferDetailState {
  const GigOfferDetailState();
}

class GigOfferDetailInitial extends GigOfferDetailState {
  const GigOfferDetailInitial();
}

class GigOfferDetailLoading extends GigOfferDetailState {
  const GigOfferDetailLoading();
}

class GigOfferDetailLoaded extends GigOfferDetailState {
  const GigOfferDetailLoaded(this.offer, {this.bookingInFlight = false});
  final GigOffer offer;
  final bool bookingInFlight;
}

class GigOfferDetailError extends GigOfferDetailState {
  const GigOfferDetailError(this.message);
  final String message;
}

class GigOfferBookingCreated extends GigOfferDetailState {
  const GigOfferBookingCreated(this.booking);
  final GigBooking booking;
}

class GigOfferDetailBloc extends Bloc<GigOfferDetailEvent, GigOfferDetailState> {
  GigOfferDetailBloc(this._service) : super(const GigOfferDetailInitial()) {
    on<FetchGigOfferDetail>((e, emit) async {
      emit(const GigOfferDetailLoading());
      try {
        final offer = await _service.getOffer(e.offerId);
        emit(GigOfferDetailLoaded(offer));
      } catch (err) {
        emit(
          GigOfferDetailError(ErrorMessageHelper.sanitizeErrorMessage(err)),
        );
      }
    });
    on<BookThisOffer>((e, emit) async {
      final s = state;
      if (s is! GigOfferDetailLoaded) return;
      emit(GigOfferDetailLoaded(s.offer, bookingInFlight: true));
      try {
        final booking = await _service.bookOffer(
          offerId: s.offer.id,
          scheduledStartAt: e.scheduledStartAt,
          addressText: e.addressText,
        );
        emit(GigOfferBookingCreated(booking));
      } catch (err) {
        emit(
          GigOfferDetailError(ErrorMessageHelper.sanitizeErrorMessage(err)),
        );
      }
    });
  }

  final IGigService _service;
}
