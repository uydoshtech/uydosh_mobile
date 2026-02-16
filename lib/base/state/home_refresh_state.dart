import "package:flutter/foundation.dart";

/// Global state to track when home screen should refresh
/// This is used to trigger refresh when returning from listing-related screens
class HomeRefreshState extends ChangeNotifier {
  factory HomeRefreshState() => _instance;
  HomeRefreshState._internal();
  static final HomeRefreshState _instance = HomeRefreshState._internal();

  bool _shouldRefresh = false;
  bool _forceRefresh = false;

  /// Whether the home screen should refresh
  bool get shouldRefresh => _shouldRefresh;

  /// Whether to force refresh (for immediate refresh after creation)
  bool get forceRefresh => _forceRefresh;

  /// Mark that home screen should refresh (call this when creating/updating listings)
  void markForRefresh() {
    _shouldRefresh = true;
    notifyListeners();
  }

  /// Force immediate refresh (call this when creating new listings)
  void forceRefreshNow() {
    _forceRefresh = true;
    notifyListeners();
  }

  /// Clear the refresh flag (call this after refreshing)
  void clearRefreshFlag() {
    _shouldRefresh = false;
    _forceRefresh = false;
    notifyListeners();
  }

  /// Reset the state
  void reset() {
    _shouldRefresh = false;
    _forceRefresh = false;
    notifyListeners();
  }
}
