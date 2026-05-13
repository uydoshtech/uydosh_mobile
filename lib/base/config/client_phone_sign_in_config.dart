import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings/phone-sign-in-enabled].
abstract final class ClientPhoneSignInConfig {
  static final ValueNotifier<bool> phoneSignInEnabled = ValueNotifier(false);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final enabled = await service.getPhoneSignInEnabled();
      phoneSignInEnabled.value = enabled;
    } catch (e, st) {
      logger.d(
        "Phone sign-in enabled: fetch failed, defaulting to disabled: $e\n$st",
      );
      phoneSignInEnabled.value = false;
    }
  }

  static void applyEnabled({required bool enabled}) {
    phoneSignInEnabled.value = enabled;
  }
}
