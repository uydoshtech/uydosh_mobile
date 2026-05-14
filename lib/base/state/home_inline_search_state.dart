import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Global state for whether Home's inline-search ribbon is active.
///
/// This is used by the main shell AppBar to decide whether to show the
/// listings result count next to the Home title. When the user closes the
/// ribbon (X), the title should return to normal.
class HomeInlineSearchState extends ChangeNotifier {
  factory HomeInlineSearchState() => _instance;
  HomeInlineSearchState._internal();
  static final HomeInlineSearchState _instance =
      HomeInlineSearchState._internal();

  /// Persisted by [HomeScreen] so inline mode survives restarts (including
  /// guests without a backend session; logout clears the pref).
  static const String activePrefsKey = "home_inline_search_active";

  /// When true, the user closed the filter-chip ribbon while filters may still
  /// be non-default. [HomeScreen] skips the post-start heuristic that would
  /// otherwise reopen the ribbon; cleared when they commit from the search
  /// sheet or we restore `activePrefsKey` from prefs. Logout clears this.
  static const String ribbonUserDismissedPrefsKey =
      "home_inline_search_ribbon_user_dismissed";

  bool _isActive = false;

  /// Loaded from [ribbonUserDismissedPrefsKey] during home bootstrap.
  bool _ribbonDismissedByUser = false;

  bool get isActive => _isActive;

  bool get ribbonDismissedByUser => _ribbonDismissedByUser;

  void setActive(bool v) {
    if (_isActive == v) return;
    _isActive = v;
    notifyListeners();
  }

  Future<void> hydrateRibbonDismissedFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ribbonDismissedByUser =
          prefs.getBool(ribbonUserDismissedPrefsKey) ?? false;
    } catch (_) {
      _ribbonDismissedByUser = false;
    }
  }

  /// Persists so a cold start does not re-open the ribbon via the
  /// non-default-filters heuristic after the user dismissed it.
  Future<void> setRibbonDismissedByUser(bool dismissed) async {
    if (_ribbonDismissedByUser == dismissed) return;
    _ribbonDismissedByUser = dismissed;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (dismissed) {
        await prefs.setBool(ribbonUserDismissedPrefsKey, true);
      } else {
        await prefs.remove(ribbonUserDismissedPrefsKey);
      }
    } catch (_) {}
  }

  /// Clears in-memory flag and persisted inline-search mode after logout or
  /// session expiry so the guest home feed does not reopen with a search ribbon.
  Future<void> clearPersistedActiveForLogout() async {
    setActive(false);
    _ribbonDismissedByUser = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(activePrefsKey, false);
      await prefs.remove(ribbonUserDismissedPrefsKey);
    } catch (_) {}
  }
}

