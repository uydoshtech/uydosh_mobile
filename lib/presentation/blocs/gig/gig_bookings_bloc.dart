import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/state/pending_gig_bookings_state.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

abstract class GigBookingsEvent {
  const GigBookingsEvent();
}

class FetchMyGigBookings extends GigBookingsEvent {
  const FetchMyGigBookings({this.role = "all", this.silentRefresh = false});
  final String role;

  /// When true, skip [GigBookingsLoading] so pull-to-refresh keeps showing the
  /// current list (or error) until the new result is ready.
  final bool silentRefresh;
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
      final prev = state;
      if (!e.silentRefresh) {
        emit(const GigBookingsLoading());
      }
      try {
        final list = await _service.listMyBookings(role: e.role);
        emit(GigBookingsLoaded(list, role: e.role));
      } catch (err) {
        if (e.silentRefresh &&
            prev is GigBookingsLoaded &&
            prev.role == e.role) {
          emit(
            GigBookingsLoaded(
              List<GigBooking>.from(prev.bookings),
              role: prev.role,
            ),
          );
        } else {
          emit(GigBookingsError(err.toString()));
        }
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
        unawaited(PendingGigBookingsState().refresh());
      } catch (err) {
        emit(GigBookingsError(err.toString()));
      }
    });
  }

  final IGigService _service;
}
