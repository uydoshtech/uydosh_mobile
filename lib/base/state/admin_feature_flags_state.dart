import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Client-side feature flags controlled from the admin panel.
///
/// Note: These are stored locally on the device (SharedPreferences).
class AdminFeatureFlagsState extends ChangeNotifier {
  AdminFeatureFlagsState._();

  static final AdminFeatureFlagsState _instance = AdminFeatureFlagsState._();
  factory AdminFeatureFlagsState() => _instance;

  static const _kShowListingContactsKey = "admin_show_listing_contacts";

  bool _loaded = false;
  bool _showListingContacts = false;

  bool get showListingContacts => _showListingContacts;

  Future<void> _loadIfNeeded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _showListingContacts = prefs.getBool(_kShowListingContactsKey) ?? false;
    _loaded = true;
    notifyListeners();
  }

  /// Ensure preferences are loaded (safe to call multiple times).
  Future<void> ensureLoaded() => _loadIfNeeded();

  Future<void> setShowListingContacts(bool value) async {
    await _loadIfNeeded();
    if (_showListingContacts == value) return;
    _showListingContacts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowListingContactsKey, value);
    notifyListeners();
  }
}

