import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed kill switch from [GET /app/settings]
/// (`webAppMultipleInstanceCheckEnabled`). When true, [WebMultiInstanceGuardState]
/// locks every browser tab except the most recently opened one. Default false
/// (off) so the check only runs where an admin explicitly opts in.
///
/// Web-only by design: this flag (and the detection it gates) is intended for
/// the Flutter web build only. It is inert on the native iOS/Android apps —
/// see the `kIsWeb` guard in [WebMultiInstanceGuardState.startIfEnabled] — and
/// unrelated to the separate Telegram Mini App site's own session handling.
abstract final class ClientWebAppMultipleInstanceConfig {
  static final ValueNotifier<bool> enabled = ValueNotifier(false);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final value = await service.getWebAppMultipleInstanceCheckEnabled();
      enabled.value = value;
    } catch (e, st) {
      logger.d(
        "Web app multiple instance check: fetch failed, defaulting to disabled: $e\n$st",
      );
      enabled.value = false;
    }
  }

  static void applyEnabled({required bool value}) {
    enabled.value = value;
  }
}
