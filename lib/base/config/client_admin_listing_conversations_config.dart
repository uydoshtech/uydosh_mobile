import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/admin_content_moderation_settings_service.dart";

/// Server-backed admin flag from
/// [GET /admin/settings/admin-listing-conversations-enabled]. When true,
/// admins see the listing-scoped chat browser on listing detail.
///
/// Default false until loaded. Toggled platform-wide by admins via
/// [PATCH /admin/settings/admin-listing-conversations-enabled].
abstract final class ClientAdminListingConversationsConfig {
  static final ValueNotifier<bool> enabled = ValueNotifier(false);

  static Future<void>? _loading;

  static Future<void> ensureLoaded() {
    _loading ??= _load();
    return _loading!;
  }

  static Future<void> _load() async {
    try {
      final service = getIt<IAdminContentModerationSettingsService>();
      final res = await service.getAdminListingConversationsEnabledSetting();
      enabled.value = res.enabled;
    } catch (e, st) {
      logger.d(
        "Admin listing conversations enabled: fetch failed, defaulting to off: $e\n$st",
      );
      enabled.value = false;
    }
  }

  /// Updates UI after admin PATCH or a successful refetch.
  static void applyEnabled({required bool value}) {
    enabled.value = value;
  }
}
