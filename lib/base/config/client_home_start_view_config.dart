import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

/// Server-backed setting from [GET /app/settings].
///
/// Valid values are [mapView] and [feedView]. Defaults to [mapView] so the app
/// preserves the current start behavior until an admin changes it.
abstract final class ClientHomeStartViewConfig {
  static const String mapView = "map";
  static const String feedView = "feed";

  static final ValueNotifier<String> homeStartView = ValueNotifier(mapView);

  static bool get showMapInitially => homeStartView.value == mapView;

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final view = await service.getHomeStartView();
      homeStartView.value = normalize(view);
    } catch (e, st) {
      logger.d(
        "Home start view: fetch failed, defaulting to map: $e\n$st",
      );
      homeStartView.value = mapView;
    }
  }

  static void applyView(String view) {
    homeStartView.value = normalize(view);
  }

  static String normalize(String? view) {
    return view?.trim().toLowerCase() == feedView ? feedView : mapView;
  }
}
