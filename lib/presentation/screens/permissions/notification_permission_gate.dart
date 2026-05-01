import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/presentation/screens/permissions/permission_rationale_screen.dart";

/// Wraps `IPushNotificationService.requestPermissionAndRegister` with a
/// UyDosh rationale screen.
///
/// iOS only ever surfaces its system notifications prompt **once** — a cold
/// prompt that gets denied is unrecoverable without a Settings deep-link,
/// and Apple's own guidance plus every A/B test consistently shows that a
/// pre-prompt rationale measurably improves opt-in. We use that opt-in
/// rate to power the search-alert feature (no opt-in → no search alert
/// notifications can reach the user → feature dies on the vine).
abstract final class NotificationPermissionGate {
  /// SharedPreferences key tracking whether we've already asked the user
  /// (with our rationale) at least once. Lets the onboarding entry point
  /// skip itself on subsequent launches without having to inspect the
  /// underlying OS state.
  static const String _keyRationaleShown =
      "permissions.notifications.rationale_shown";

  /// Ensures notifications are enabled. Returns `true` iff permission is
  /// granted (or provisional) and the FCM token has been registered with
  /// the backend.
  ///
  /// [allowSkipPersistsAcrossLaunches] — when `true` (used by the
  /// onboarding entry), tapping "Not now" persists a flag so the gate
  /// won't auto-fire from the same entry point on subsequent launches.
  /// Per-action entries (like creating a search alert) should pass
  /// `false`: every alert creation is a meaningful intent worth asking
  /// the user about.
  static Future<bool> ensure(
    BuildContext context, {
    bool allowSkipPersistsAcrossLaunches = false,
  }) async {
    final push = getIt<IPushNotificationService>();
    if (!push.isSupported) return false;

    final initialStatus = await _safeStatus(push);

    if (initialStatus == AuthorizationStatus.authorized ||
        initialStatus == AuthorizationStatus.provisional) {
      // Already opted in — make sure the backend has the latest token in
      // case the user reinstalled / cleared data, then return success
      // without surfacing any UI.
      final ok = await push.requestPermissionAndRegister(
        openSettingsOnDenied: false,
      );
      return ok;
    }

    if (initialStatus == AuthorizationStatus.denied) {
      // Distinguish "never asked" from "asked + denied". On iOS the
      // FirebaseMessaging API doesn't expose `notDetermined` as a separate
      // case after the first ask — it just stays `denied`. We use the
      // permission_handler status as a tiebreaker since it does expose
      // .permanentlyDenied.
      final permStatus = await _safePermStatus();
      final wasEverAsked = permStatus.isPermanentlyDenied ||
          permStatus.isDenied ||
          permStatus.isRestricted;
      // If we've never shown our rationale before, treat this as the
      // first time regardless of what the OS thinks.
      final hasShownBefore = await _readRationaleShown();

      if (wasEverAsked && hasShownBefore) {
        if (!context.mounted) return false;
        final result = await _showRationale(
          context,
          title: L10n.get("permission_notifications_title"),
          body: L10n.get("permission_notifications_denied_body"),
          primaryLabel: L10n.get("permission_camera_open_settings"),
          secondaryLabel: L10n.get("permission_not_now"),
        );
        if (result == PermissionRationaleResult.allow) {
          await openAppSettings();
        }
        return false;
      }
    }

    if (!context.mounted) return false;
    final consent = await _showRationale(
      context,
      title: L10n.get("permission_notifications_title"),
      body: L10n.get("permission_notifications_body"),
      primaryLabel: L10n.get("permission_notifications_cta"),
      secondaryLabel: L10n.get("permission_not_now"),
    );

    // Persist the fact that we've shown the rationale, so the
    // "denied + asked-before" branch above can fire correctly next time.
    await _markRationaleShown();
    if (allowSkipPersistsAcrossLaunches &&
        consent == PermissionRationaleResult.skip) {
      // Reuse the same flag — its presence already prevents the
      // onboarding entry from re-firing the gate. Dedicated key would
      // only matter if we wanted to differentiate "shown but skipped"
      // from "shown and granted/denied", which we don't right now.
    }

    if (consent != PermissionRationaleResult.allow) return false;

    if (!context.mounted) return false;
    final ok = await push.requestPermissionAndRegister(
      openSettingsOnDenied: false,
    );
    return ok;
  }

  /// `true` iff the rationale screen has been surfaced to the user at
  /// least once on this device. Used by the onboarding flow to decide
  /// whether to push the gate again.
  static Future<bool> hasPromptedBefore() => _readRationaleShown();

  static Future<AuthorizationStatus> _safeStatus(
    IPushNotificationService push,
  ) async {
    try {
      return (await push.getNotificationStatus()) ??
          AuthorizationStatus.notDetermined;
    } catch (e, st) {
      logger.e("📲 getNotificationStatus threw", error: e, stackTrace: st);
      return AuthorizationStatus.notDetermined;
    }
  }

  static Future<PermissionStatus> _safePermStatus() async {
    try {
      return await Permission.notification.status;
    } catch (e, st) {
      logger.e(
        "📲 Permission.notification.status threw",
        error: e,
        stackTrace: st,
      );
      return PermissionStatus.denied;
    }
  }

  static Future<bool> _readRationaleShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyRationaleShown) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _markRationaleShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyRationaleShown, true);
    } catch (_) {
      // Best-effort: missing this flag just means the rationale shows
      // one extra time next launch, which is acceptable.
    }
  }

  static Future<PermissionRationaleResult?> _showRationale(
    BuildContext context, {
    required String title,
    required String body,
    required String primaryLabel,
    required String secondaryLabel,
  }) {
    return Navigator.of(context).push<PermissionRationaleResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PermissionRationaleScreen(
          icon: Icons.notifications_active_rounded,
          title: title,
          body: body,
          primaryLabel: primaryLabel,
          secondaryLabel: secondaryLabel,
        ),
      ),
    );
  }
}
