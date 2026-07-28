import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/presentation/screens/permissions/permission_rationale_screen.dart";

/// One-time warm-up flow for location permission before the map-first home UX.
abstract final class LocationPermissionGate {
  static const String _keyRationaleShown =
      "permissions.location.rationale_shown";

  static Future<bool> ensure(
    BuildContext context, {
    bool allowSkipPersistsAcrossLaunches = false,
  }) async {
    if (kIsWeb) return false;

    final status = await _safeStatus();
    if (status.isGranted || status.isLimited) return true;

    // Permanently denied: no OS prompt left to show — only Settings deep-link.
    // "Not now" is allowed here because this is not delaying a permission request.
    if (status.isPermanentlyDenied || status.isRestricted) {
      if (!context.mounted) return false;
      final result = await _showRationale(
        context,
        title: L10n.get("permission_location_title"),
        body: L10n.get("permission_location_denied_body"),
        primaryLabel: L10n.get("permission_camera_open_settings"),
        secondaryLabel: L10n.get("permission_not_now"),
      );
      if (result == PermissionRationaleResult.allow) {
        await openAppSettings();
      }
      await _markRationaleShown();
      return false;
    }

    if (allowSkipPersistsAcrossLaunches && await hasPromptedBefore()) {
      return false;
    }

    // Guideline 5.1.1(iv): pre-prompt CTA must be Continue/Next (not "Allow…"),
    // and the user must always proceed to the system permission request — no
    // "Not now" skip that delays the dialog.
    var requestedStatus = status;
    if (!context.mounted) return false;
    await _showRationale(
      context,
      title: L10n.get("permission_location_title"),
      body: L10n.get("permission_location_body"),
      primaryLabel: L10n.get("permission_location_cta"),
      allowSkip: false,
      onBeforePopAllow: () async {
        requestedStatus = await Permission.location.request();
      },
    );

    await _markRationaleShown();
    return requestedStatus.isGranted || requestedStatus.isLimited;
  }

  static Future<bool> hasPromptedBefore() => _readRationaleShown();

  static Future<PermissionStatus> _safeStatus() async {
    try {
      return await Permission.location.status;
    } catch (e, st) {
      logger.e(
        "📍 Permission.location.status threw",
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
    } catch (_) {}
  }

  static Future<PermissionRationaleResult?> _showRationale(
    BuildContext context, {
    required String title,
    required String body,
    required String primaryLabel,
    String? secondaryLabel,
    bool allowSkip = true,
    Future<void> Function()? onBeforePopAllow,
  }) {
    return Navigator.of(context).push<PermissionRationaleResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PermissionRationaleScreen(
          icon: Icons.my_location_rounded,
          title: title,
          body: body,
          primaryLabel: primaryLabel,
          secondaryLabel: allowSkip ? secondaryLabel : null,
          allowSkip: allowSkip,
          onBeforePopAllow: onBeforePopAllow,
        ),
      ),
    );
  }
}
