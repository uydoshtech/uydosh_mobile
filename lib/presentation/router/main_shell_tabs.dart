import "package:uy_dosh/base/config/client_property_feature_config.dart";

/// [IndexedStack] indices for [MainNavigation] shell tabs.
abstract final class MainShellTab {
  static const int housing = 0;

  static int get property =>
      ClientPropertyFeatureConfig.propertyFeatureEnabled.value ? 1 : -1;

  static int get myHub =>
      ClientPropertyFeatureConfig.propertyFeatureEnabled.value ? 2 : 1;

  static int get messages =>
      ClientPropertyFeatureConfig.propertyFeatureEnabled.value ? 3 : 2;

  /// Bottom-bar position of the "+" create launcher (not a shell tab).
  static int get createBarIndex =>
      ClientPropertyFeatureConfig.propertyFeatureEnabled.value ? 4 : 3;

  static int get maxTabIndex => messages;

  static bool isMessagesTab(int shellIndex) => shellIndex == messages;

  static bool isLegacyCreateRouteIndex(int index) =>
      index == createBarIndex ||
      (index == 3 && !ClientPropertyFeatureConfig.propertyFeatureEnabled.value);
}
