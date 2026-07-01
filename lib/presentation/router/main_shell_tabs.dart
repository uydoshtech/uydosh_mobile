import "package:uy_dosh/base/constants/app_config.dart";

/// [IndexedStack] indices for [MainNavigation] shell tabs.
abstract final class MainShellTab {
  static const int housing = 0;

  static int get property => AppConfig.propertyFeatureEnabled ? 1 : -1;

  static int get myHub => AppConfig.propertyFeatureEnabled ? 2 : 1;

  static int get messages => AppConfig.propertyFeatureEnabled ? 3 : 2;

  /// Bottom-bar position of the "+" create launcher (not a shell tab).
  static int get createBarIndex =>
      AppConfig.propertyFeatureEnabled ? 4 : 3;

  static int get maxTabIndex => messages;

  static bool isMessagesTab(int shellIndex) => shellIndex == messages;

  static bool isLegacyCreateRouteIndex(int index) =>
      index == createBarIndex ||
      (index == 3 && !AppConfig.propertyFeatureEnabled);
}
