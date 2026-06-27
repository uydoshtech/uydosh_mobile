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

    var requestedStatus = status;
    if (!context.mounted) return false;
    final consent = await _showRationale(
      context,
      title: L10n.get("permission_location_title"),
      body: L10n.get("permission_location_body"),
      primaryLabel: L10n.get("permission_location_cta"),
      secondaryLabel: L10n.get("permission_not_now"),
      onBeforePopAllow: () async {
        requestedStatus = await Permission.location.request();
      },
    );

    await _markRationaleShown();
    if (consent != PermissionRationaleResult.allow) return false;
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
    required String secondaryLabel,
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
          secondaryLabel: secondaryLabel,
          onBeforePopAllow: onBeforePopAllow,
        ),
      ),
    );
  }
}
