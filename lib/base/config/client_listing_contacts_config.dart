import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed flag from [GET /app/settings/listing-contacts-visible]. When
/// true, shows the listing owner's Telegram and phone-call buttons in the
/// Matching/Compatibility section and the sticky bottom action bar.
///
/// Default false: contact happens via in-app chat only. Toggled platform-wide
/// by admins via [PATCH /admin/settings/listing-contacts-visible].
abstract final class ClientListingContactsConfig {
  static final ValueNotifier<bool> showListingContacts = ValueNotifier(false);

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final visible = await service.getListingContactsVisible();
      showListingContacts.value = visible;
    } catch (e, st) {
      logger.d(
        "Listing contacts visible: fetch failed, defaulting to hidden: $e\n$st",
      );
      showListingContacts.value = false;
    }
  }

  /// Updates UI after admin PATCH or a successful refetch.
  static void applyVisible({required bool visible}) {
    showListingContacts.value = visible;
  }
}
