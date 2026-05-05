import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigBookingsEvent {
  const GigBookingsEvent();
}

class FetchMyGigBookings extends GigBookingsEvent {
  const FetchMyGigBookings({this.role = "all"});
  final String role;
}

class TransitionGigBooking extends GigBookingsEvent {
  const TransitionGigBooking({
    required this.bookingId,
    required this.toStatus,
    this.cancellationReason,
  });
  final int bookingId;
  final GigBookingStatus toStatus;
  final String? cancellationReason;
}

abstract class GigBookingsState {
  const GigBookingsState();
}

class GigBookingsInitial extends GigBookingsState {
  const GigBookingsInitial();
}

class GigBookingsLoading extends GigBookingsState {
  const GigBookingsLoading();
}

class GigBookingsLoaded extends GigBookingsState {
  const GigBookingsLoaded(this.bookings, {required this.role});
  final List<GigBooking> bookings;
  final String role;
}

class GigBookingsError extends GigBookingsState {
  const GigBookingsError(this.message);
  final String message;
}

class GigBookingsBloc extends Bloc<GigBookingsEvent, GigBookingsState> {
  GigBookingsBloc(this._service) : super(const GigBookingsInitial()) {
    on<FetchMyGigBookings>((e, emit) async {
      emit(const GigBookingsLoading());
      try {
        final list = await _service.listMyBookings(role: e.role);
        emit(GigBookingsLoaded(list, role: e.role));
      } catch (err) {
        emit(GigBookingsError(err.toString()));
      }
    });
    on<TransitionGigBooking>((e, emit) async {
      final s = state;
      if (s is! GigBookingsLoaded) return;
      try {
        final updated = await _service.transitionBooking(
          id: e.bookingId,
          to: e.toStatus,
          cancellationReason: e.cancellationReason,
        );
        emit(
          GigBookingsLoaded(
            s.bookings
                .map((b) => b.id == updated.id ? updated : b)
                .toList(growable: false),
            role: s.role,
          ),
        );
      } catch (err) {
        emit(GigBookingsError(err.toString()));
      }
    });
  }

  final IGigService _service;
}
