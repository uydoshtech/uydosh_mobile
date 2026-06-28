import "package:flutter/foundation.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/services/public_app_settings_service.dart";

class ClientMapLayerDefaults {
  const ClientMapLayerDefaults({
    required this.districts,
    required this.metro,
    required this.universities,
  });

  final bool districts;
  final bool metro;
  final bool universities;
}

/// Server-backed defaults for initial listing-map layer visibility.
abstract final class ClientMapLayerDefaultsConfig {
  static final ValueNotifier<ClientMapLayerDefaults> defaults = ValueNotifier(
    const ClientMapLayerDefaults(
      districts: true,
      metro: true,
      universities: false,
    ),
  );

  static Future<void> load() async {
    try {
      final service = getIt<IPublicAppSettingsService>();
      final snapshot = await service.getMapLayerDefaults();
      apply(
        districts: snapshot.districts,
        metro: snapshot.metro,
        universities: snapshot.universities,
      );
    } catch (e, st) {
      logger.d(
        "Map layer defaults: fetch failed, keeping built-in defaults: $e\n$st",
      );
    }
  }

  static void apply({
    required bool districts,
    required bool metro,
    required bool universities,
  }) {
    defaults.value = ClientMapLayerDefaults(
      districts: districts,
      metro: metro,
      universities: universities,
    );
  }
}
