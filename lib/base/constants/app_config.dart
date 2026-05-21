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

  /// Yandex Geosuggest API key (address autocomplete). See
  /// [EnvironmentUtil.yandexGeosuggestApiKey].
  static String get yandexGeosuggestApiKey =>
      EnvironmentUtil.yandexGeosuggestApiKey;

  /// Max photos per listing, resolved at runtime from Firebase Remote
  /// Config (key: `max_photos_per_listing`). Falls back to
  /// [EnvironmentUtil.compileTimeMaxPhotosPerListing] (currently 5) when
  /// Remote Config has not yet supplied a value.
  ///
  /// NOTE: this is read every time photo widgets rebuild, so the new
  /// limit propagates to existing screens on the next frame after a
  /// successful RC fetch — no app restart required.
  static int get maxPhotosPerListing => EnvironmentUtil.maxPhotosPerListing;

  /// Max photos per gig offer, resolved at runtime from Firebase Remote
  /// Config (key: `max_photos_per_gig_offer`). Independent from
  /// [maxPhotosPerListing] so the gigs marketplace can evolve its caps
  /// separately from property listings.
  static int get maxPhotosPerGigOffer =>
      EnvironmentUtil.maxPhotosPerGigOffer;

  /// UZS per 1 USD exchange-rate used for client-side display conversions.
  /// Resolved at runtime from Firebase Remote Config (key: `uzs_per_usd`).
  static int get uzsPerUsd => EnvironmentUtil.uzsPerUsd;
}
