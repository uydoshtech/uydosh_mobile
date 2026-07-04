import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings/google-sign-in-enabled].
abstract final class ClientGoogleSignInConfig {
  static final ValueNotifier<bool> googleSignInEnabled = ValueNotifier(true);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final enabled = await service.getGoogleSignInEnabled();
      googleSignInEnabled.value = enabled;
    } catch (e, st) {
      logger.d(
        "Google sign-in enabled: fetch failed, defaulting to enabled: $e\n$st",
      );
      googleSignInEnabled.value = true;
    }
  }

  static void applyEnabled({required bool enabled}) {
    googleSignInEnabled.value = enabled;
  }
}
