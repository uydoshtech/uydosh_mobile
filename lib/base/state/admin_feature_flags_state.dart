import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Local, per-device admin-only UI preferences.
///
/// Note: For platform-wide flags (visible to every user) prefer the
/// server-backed configs in `lib/base/config/` (e.g.
/// `ClientListingContactsConfig`). This class only holds settings that should
/// remain device-local.
class AdminFeatureFlagsState extends ChangeNotifier {
  AdminFeatureFlagsState._();

  static final AdminFeatureFlagsState _instance = AdminFeatureFlagsState._();
  factory AdminFeatureFlagsState() => _instance;

  static const _kShowPriceInsightsKey = "admin_show_price_insights";

  bool _loaded = false;
  bool _showPriceInsights = true;

  bool get showPriceInsights => _showPriceInsights;

  Future<void> _loadIfNeeded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _showPriceInsights = prefs.getBool(_kShowPriceInsightsKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  /// Ensure preferences are loaded (safe to call multiple times).
  Future<void> ensureLoaded() => _loadIfNeeded();

  Future<void> setShowPriceInsights(bool value) async {
    await _loadIfNeeded();
    if (_showPriceInsights == value) return;
    _showPriceInsights = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowPriceInsightsKey, value);
    notifyListeners();
  }
}
