import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings/telegram-sign-in-enabled].
abstract final class ClientTelegramSignInConfig {
  static final ValueNotifier<bool> telegramSignInEnabled = ValueNotifier(true);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final enabled = await service.getTelegramSignInEnabled();
      telegramSignInEnabled.value = enabled;
    } catch (e, st) {
      logger.d(
        "Telegram sign-in enabled: fetch failed, defaulting to enabled: $e\n$st",
      );
      telegramSignInEnabled.value = true;
    }
  }

  static void applyEnabled({required bool enabled}) {
    telegramSignInEnabled.value = enabled;
  }
}
