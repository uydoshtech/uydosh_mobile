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
  static const bool enableAnimations = true;

  // Maps configuration
  static const String yandexMapsApiKey = "b7e30079-55fe-44d0-960c-50a03c3715e6";
}
