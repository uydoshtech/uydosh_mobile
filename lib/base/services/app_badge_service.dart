import "package:app_badge_plus/app_badge_plus.dart";
import "package:flutter/foundation.dart" show TargetPlatform, defaultTargetPlatform, kIsWeb;
import "package:uy_dosh/base/logger/logger.dart";

abstract class IAppBadgeService {
  Future<void> setBadgeCount(int count);
  Future<void> clearBadge();
}

class AppBadgeService implements IAppBadgeService {
  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  Future<void> setBadgeCount(int count) async {
    if (!_isSupported) return;
    final safeCount = count < 0 ? 0 : count;
    try {
      await AppBadgePlus.updateBadge(safeCount);
    } catch (e) {
      logger.d("🔔 AppBadgeService: failed to set badge: $e");
    }
  }

  @override
  Future<void> clearBadge() => setBadgeCount(0);
}
