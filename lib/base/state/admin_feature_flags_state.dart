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
  static const _kShowPushDebugKey = "admin_show_push_debug";
  static const _kShowListingMoveToTopKey = "admin_show_listing_move_to_top";

  bool _loaded = false;
  bool _showPriceInsights = true;
  bool _showPushDebug = false;
  bool _showListingMoveToTop = false;

  bool get showPriceInsights => _showPriceInsights;

  /// Push token / permission debug panel on the notifications screen.
  bool get showPushDebug => _showPushDebug;

  /// Admin affordances for moving a listing to / from the featured top slot
  /// (overflow menu on listing detail, long-press on featured feed tiles).
  bool get showListingMoveToTop => _showListingMoveToTop;

  Future<void> _loadIfNeeded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _showPriceInsights = prefs.getBool(_kShowPriceInsightsKey) ?? true;
    _showPushDebug = prefs.getBool(_kShowPushDebugKey) ?? false;
    _showListingMoveToTop =
        prefs.getBool(_kShowListingMoveToTopKey) ?? false;
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

  Future<void> setShowPushDebug(bool value) async {
    await _loadIfNeeded();
    if (_showPushDebug == value) return;
    _showPushDebug = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowPushDebugKey, value);
    notifyListeners();
  }

  Future<void> setShowListingMoveToTop(bool value) async {
    await _loadIfNeeded();
    if (_showListingMoveToTop == value) return;
    _showListingMoveToTop = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowListingMoveToTopKey, value);
    notifyListeners();
  }
}
