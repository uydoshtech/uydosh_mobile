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

  /// Persisted by [HomeScreen] so inline mode survives restarts while logged in.
  static const String activePrefsKey = "home_inline_search_active";

  bool _isActive = false;

  bool get isActive => _isActive;

  void setActive(bool v) {
    if (_isActive == v) return;
    _isActive = v;
    notifyListeners();
  }

  /// Clears in-memory flag and persisted inline-search mode after logout or
  /// session expiry so the guest home feed does not reopen with a search ribbon.
  Future<void> clearPersistedActiveForLogout() async {
    setActive(false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(activePrefsKey, false);
    } catch (_) {}
  }
}

