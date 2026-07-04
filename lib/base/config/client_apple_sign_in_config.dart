import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings/apple-sign-in-enabled].
///
/// This only controls whether admins have turned the button off platform-wide;
/// callers must still check `AppleAuthService.isAvailable` for platform support.
abstract final class ClientAppleSignInConfig {
  static final ValueNotifier<bool> appleSignInEnabled = ValueNotifier(true);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final enabled = await service.getAppleSignInEnabled();
      appleSignInEnabled.value = enabled;
    } catch (e, st) {
      logger.d(
        "Apple sign-in enabled: fetch failed, defaulting to enabled: $e\n$st",
      );
      appleSignInEnabled.value = true;
    }
  }

  static void applyEnabled({required bool enabled}) {
    appleSignInEnabled.value = enabled;
  }
}
