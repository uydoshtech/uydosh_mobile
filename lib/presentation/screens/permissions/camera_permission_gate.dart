import "package:flutter/material.dart";
import "package:permission_handler/permission_handler.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/presentation/screens/permissions/permission_rationale_screen.dart";

/// Pre-permission **rationale** for camera access.
///
/// Why a rationale at all? iOS only ever surfaces its system camera prompt
/// **once**. A cold prompt that gets denied is functionally permanent
/// without a Settings deep-link, and warming it up with our own brand
/// screen measurably improves opt-in.
///
/// ## Why this gate does NOT call `Permission.camera.request()`
///
/// `permission_handler` on iOS is fragile: it requires the
/// `PERMISSION_CAMERA=1` preprocessor macro in the Podfile, and even when
/// the macro is set there are persistent reports of `request()` resolving
/// with stale `.denied` values while AVFoundation is still flipping the
/// underlying status (see Baseflow/flutter-permission-handler#1156). Both
/// failure modes look identical: the user taps "Allow camera access",
/// nothing happens, the screen closes — exactly the bug we kept hitting.
///
/// The `camera` plugin's iOS implementation calls AVFoundation's
/// `requestAccess(for: .video)` itself inside `controller.initialize()`,
/// which is the source of truth and reliably triggers the iOS dialog. So
/// we let it do that, and use this gate only as the user-facing
/// rationale. The plugin then surfaces a clean `CameraAccessDenied`
/// exception if the user denies, which `CustomCameraScreen` already
/// handles with its in-screen error UI.
///
/// `Permission.camera.status` (a read, not a request) is still safe to
/// use here as a **hint** for which copy to show — first-run rationale
/// vs. "Camera is off in Settings" deep-link rationale — because a
/// false-negative just means we show the friendly first-run rationale
/// to a user who's already permanently denied, and the camera plugin
/// will then surface the real denial. No flow gets broken.
abstract final class CameraPermissionGate {
  /// Returns:
  ///   - `true`  → user agreed to proceed (rationale-tapped Allow OR
  ///               permission was already granted). Caller can push the
  ///               camera screen; the camera plugin will handle the
  ///               actual OS-level permission ask if needed.
  ///   - `false` → user dismissed the rationale, or asked us to open
  ///               Settings (still a "don't open the camera" signal).
  static Future<bool> ensure(BuildContext context) async {
    final hint = await _safeStatusHint();
    if (hint.isGranted || hint.isLimited) {
      // Already granted: skip rationale entirely, let the camera open.
      logger.d("📷 Camera permission gate: hint=granted, skipping rationale");
      return true;
    }

    if (hint.isPermanentlyDenied || hint.isRestricted) {
      // We've been told NO before. Surface a Settings deep-link
      // rationale instead of pretending we can re-prompt — iOS will
      // never show the system dialog again from `request()`.
      if (!context.mounted) return false;
      logger.d("📷 Camera permission gate: hint=permanentlyDenied → settings rationale");
      final result = await _showRationale(
        context,
        title: L10n.get("permission_camera_denied_title"),
        body: L10n.get("permission_camera_denied_body"),
        primaryLabel: L10n.get("permission_camera_open_settings"),
        secondaryLabel: L10n.get("permission_not_now"),
      );
      if (result == PermissionRationaleResult.allow) {
        await openAppSettings();
      }
      return false;
    }

    // First-run path (`hint == .denied` / .notDetermined): show the
    // friendly warm-up rationale. We DO NOT call `request()` here —
    // see the class doc above for why. We just return true on consent
    // and let the camera plugin trigger the real iOS prompt itself.
    if (!context.mounted) return false;
    logger.d("📷 Camera permission gate: hint=$hint → first-run rationale");
    final consent = await _showRationale(
      context,
      title: L10n.get("permission_camera_title"),
      body: L10n.get("permission_camera_body"),
      primaryLabel: L10n.get("permission_camera_cta"),
      secondaryLabel: L10n.get("permission_not_now"),
    );
    final granted = consent == PermissionRationaleResult.allow;
    logger.d(
      "📷 Camera permission gate: rationale resolved with $consent → "
      "${granted ? "proceeding to camera" : "abort"}",
    );
    return granted;
  }

  /// Best-effort status read, only used to pick which rationale copy to
  /// show. Never blocks the flow on a permission_handler failure.
  static Future<PermissionStatus> _safeStatusHint() async {
    try {
      return await Permission.camera.status;
    } catch (e, st) {
      logger.e(
        "📷 Permission.camera.status threw — defaulting to first-run hint",
        error: e,
        stackTrace: st,
      );
      // Default to the first-run hint, NOT to .granted: if status reads
      // are broken, we'd rather surface our friendly rationale than
      // jump straight into the camera with no warm-up.
      return PermissionStatus.denied;
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
          icon: Icons.camera_alt_rounded,
          title: title,
          body: body,
          primaryLabel: primaryLabel,
          secondaryLabel: secondaryLabel,
        ),
      ),
    );
  }
}
