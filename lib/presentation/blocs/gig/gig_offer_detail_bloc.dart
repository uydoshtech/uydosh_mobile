import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

bool gigBookingStatusBlocksDuplicateOfferBooking(GigBookingStatus status) {
  switch (status) {
    case GigBookingStatus.completed:
    case GigBookingStatus.cancelled:
      return false;
    case GigBookingStatus.pending:
    case GigBookingStatus.accepted:
    case GigBookingStatus.inProgress:
    case GigBookingStatus.disputed:
      return true;
  }
}

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
  const GigOfferDetailLoaded(
    this.offer, {
    this.bookingInFlight = false,
    this.activeClientBookingForOffer,
  });
  final GigOffer offer;
  final bool bookingInFlight;
  /// Non-null when the signed-in user is the client on an unfinished booking
  /// for this catalog offer ([GigBookingSourceType.offer], same offer id).
  final GigBooking? activeClientBookingForOffer;
}

class GigOfferDetailError extends GigOfferDetailState {
  const GigOfferDetailError(this.message);
  final String message;
}

class GigOfferDetailBloc extends Bloc<GigOfferDetailEvent, GigOfferDetailState> {
  GigOfferDetailBloc(this._service) : super(const GigOfferDetailInitial()) {
    on<FetchGigOfferDetail>((e, emit) async {
      emit(const GigOfferDetailLoading());
      try {
        final offer = await _service.getOffer(e.offerId);
        GigBooking? activeForOffer;
        try {
          final asClient = await _service.listMyBookings(role: "client");
          for (final b in asClient) {
            if (b.sourceType == GigBookingSourceType.offer &&
                b.offerId == offer.id &&
                gigBookingStatusBlocksDuplicateOfferBooking(b.status)) {
              activeForOffer = b;
              break;
            }
          }
        } catch (_) {
          // Guest or transient failure — still show the offer; duplicate guard
          // runs again on POST /book and the footer stays bookable until then.
          activeForOffer = null;
        }
        emit(
          GigOfferDetailLoaded(
            offer,
            activeClientBookingForOffer: activeForOffer,
          ),
        );
      } catch (err) {
        emit(
          GigOfferDetailError(ErrorMessageHelper.sanitizeErrorMessage(err)),
        );
      }
    });
    on<BookThisOffer>((e, emit) async {
      final s = state;
      if (s is! GigOfferDetailLoaded) return;
      if (s.activeClientBookingForOffer != null) return;
      emit(
        GigOfferDetailLoaded(
          s.offer,
          bookingInFlight: true,
          activeClientBookingForOffer: s.activeClientBookingForOffer,
        ),
      );
      try {
        final booking = await _service.bookOffer(
          offerId: s.offer.id,
          scheduledStartAt: e.scheduledStartAt,
          addressText: e.addressText,
        );
        emit(
          GigOfferDetailLoaded(
            s.offer,
            activeClientBookingForOffer: booking,
          ),
        );
      } catch (err) {
        emit(
          GigOfferDetailError(ErrorMessageHelper.sanitizeErrorMessage(err)),
        );
      }
    });
  }

  final IGigService _service;
}
