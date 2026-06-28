import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/services/session_manager.dart";

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

  /// When true, the user closed the filter-chip ribbon. [HomeScreen] skips the
  /// post-start heuristic that would otherwise reopen the ribbon; cleared when
  /// they commit from the search sheet or we restore `activePrefsKey` from
  /// prefs. Scoped per user (or guest) so logout/login does not forget a
  /// deliberate dismiss.
  static const String ribbonUserDismissedPrefsKey =
      "home_inline_search_ribbon_user_dismissed";

  bool _isActive = false;

  /// Loaded from a scoped [ribbonUserDismissedPrefsKey] during home bootstrap.
  bool _ribbonDismissedByUser = false;

  bool get isActive => _isActive;

  bool get ribbonDismissedByUser => _ribbonDismissedByUser;

  static String _ribbonDismissedPrefsKeyForScope({required int? userId}) {
    if (userId != null) {
      return "${ribbonUserDismissedPrefsKey}_$userId";
    }
    return "${ribbonUserDismissedPrefsKey}_guest";
  }

  Future<int?> _currentRibbonDismissScopeUserId() async {
    // Keyed by backend user id whenever it is in prefs — do not gate on
    // [SessionManager.isAuthenticated], which needs token + last_login and
    // can lag behind Firebase auth during login.
    return SessionManager.getUserId();
  }

  void setActive(bool v) {
    if (_isActive == v) return;
    _isActive = v;
    notifyListeners();
  }

  Future<void> hydrateRibbonDismissedFromPrefs({
    bool awaitUserScope = false,
  }) async {
    if (awaitUserScope) {
      await SessionManager.waitForUserId();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await _currentRibbonDismissScopeUserId();
      final scopedKey = _ribbonDismissedPrefsKeyForScope(userId: userId);
      var dismissed = prefs.getBool(scopedKey) ?? false;
      if (!dismissed) {
        final legacyDismissed =
            prefs.getBool(ribbonUserDismissedPrefsKey) ?? false;
        if (legacyDismissed) {
          dismissed = true;
          await prefs.setBool(scopedKey, true);
          await prefs.remove(ribbonUserDismissedPrefsKey);
        }
      }
      if (_ribbonDismissedByUser == dismissed) return;
      _ribbonDismissedByUser = dismissed;
      notifyListeners();
    } catch (_) {
      if (_ribbonDismissedByUser) {
        _ribbonDismissedByUser = false;
        notifyListeners();
      }
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
      final userId = await _currentRibbonDismissScopeUserId();
      final scopedKey = _ribbonDismissedPrefsKeyForScope(userId: userId);
      if (dismissed) {
        await prefs.setBool(scopedKey, true);
      } else {
        await prefs.remove(scopedKey);
      }
    } catch (_) {}
  }

  /// Clears persisted inline-search mode after logout or session expiry so the
  /// guest home feed does not reopen with a search ribbon. Per-user dismiss
  /// prefs are kept so the same account does not see the ribbon pop back after
  /// signing in again.
  Future<void> clearPersistedActiveForLogout() async {
    setActive(false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(activePrefsKey, false);
    } catch (_) {}
    await hydrateRibbonDismissedFromPrefs();
  }
}

