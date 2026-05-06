import "package:uy_dosh/base/util/environment_util.dart";

/// Global configuration for the app
class AppConfig {
  // Loading indicator configuration
  static const bool useHouseLoaderByDefault = true;

  // Animation configuration
  static const Duration defaultHouseRotationDuration = Duration(
    milliseconds: 600,
  );

  // Loading indicator sizes
  static const double defaultLoadingIndicatorSize = 48.0;
  static const double smallLoadingIndicatorSize = 24.0;
  static const double largeLoadingIndicatorSize = 64.0;

  // Other app-wide configurations can be added here
  static const bool enableHapticFeedback = true;
  static const bool enableSoundEffects = true;
  static const bool enableAnimations = true;

  /// Yandex Maps JS API key. Resolved at runtime from Firebase Remote
  /// Config (key: `yandex_maps_api_key`) so it can be rotated without
  /// shipping an app update. Falls back to
  /// [EnvironmentUtil.compileTimeYandexMapsApiKey] on first cold launch
  /// before Remote Config has fetched.
  static String get yandexMapsApiKey => EnvironmentUtil.yandexMapsApiKey;
}
