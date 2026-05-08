import "package:flutter/foundation.dart";
import "package:flutter/scheduler.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

/// Tracks whether the user has gig bookings in [GigBookingStatus.pending]
/// so the Services hub can show the same style of dot used for unread
/// messages.
class PendingGigBookingsState extends ChangeNotifier {
  factory PendingGigBookingsState() => _instance;
  PendingGigBookingsState._internal();
  static final PendingGigBookingsState _instance =
      PendingGigBookingsState._internal();

  bool _hasPending = false;
  int _dotTrigger = 0;

  bool get hasPendingBookings => _hasPending;

  /// Increments when pending bookings appear (drives the hub dot pulse).
  int get dotTrigger => _dotTrigger;

  void _safeNotifyListeners() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    final isBuilding = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks ||
        phase == SchedulerPhase.transientCallbacks;
    if (isBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!AuthenticationState().isAuthenticated) {
      if (_hasPending) {
        _hasPending = false;
        _safeNotifyListeners();
      }
      return;
    }
    try {
      final list = await getIt<IGigService>().listMyBookings(
        role: "all",
        status: GigBookingStatus.pending,
      );
      final next = list.isNotEmpty;
      final hadPending = _hasPending;
      _hasPending = next;
      if (_hasPending && !hadPending) {
        _dotTrigger++;
      }
      _safeNotifyListeners();
    } catch (_) {
      // Keep last known state so a transient error does not flicker the UI.
    }
  }
}
