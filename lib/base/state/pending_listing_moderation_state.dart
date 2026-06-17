import "package:flutter/foundation.dart";
import "package:flutter/scheduler.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/utils/moderation_staff_utils.dart";
import "package:uy_dosh/domain/services/listing_moderation_admin_service.dart";

/// Tracks whether housing listings are awaiting moderator review so admin
/// entry points can show a green notification dot.
class PendingListingModerationState extends ChangeNotifier {
  factory PendingListingModerationState() => _instance;
  PendingListingModerationState._internal();
  static final PendingListingModerationState _instance =
      PendingListingModerationState._internal();

  bool _hasPending = false;
  int _dotTrigger = 0;

  bool get hasPendingListings => _hasPending;

  /// Increments when pending listings appear (drives the dot pulse).
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

    final role = await SessionManager.getUserRole();
    if (!ModerationStaffUtils.isModerationStaff(role)) {
      if (_hasPending) {
        _hasPending = false;
        _safeNotifyListeners();
      }
      return;
    }

    try {
      final res = await getIt<IListingModerationAdminService>().getPendingQueue(
        page: 1,
        limit: 1,
      );
      final next = res.summary.pendingTotal > 0;
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
