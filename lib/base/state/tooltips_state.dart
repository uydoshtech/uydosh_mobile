import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Global switch for in-app tips/tooltips (coach marks, explainers, etc.).
///
/// Individual tooltips may also have their own "dismissed" flags; when tooltips
/// are disabled globally, all tooltips should be hidden regardless of per-tooltip
/// dismissal state.
class TooltipsState extends ChangeNotifier {
  factory TooltipsState() => _instance;
  TooltipsState._internal();
  static final TooltipsState _instance = TooltipsState._internal();

  static const String keyNotificationsAlertsExplainerDismissed =
      "notifications_alerts_explainer_dismissed";

  static const String _keyTooltipsEnabled = "client_tooltips_enabled";

  bool _enabled = true;
  bool _isInitialized = false;

  bool get enabled => _enabled;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Persist default so it's visible/adjustable in device storage.
      if (!prefs.containsKey(_keyTooltipsEnabled)) {
        await prefs.setBool(_keyTooltipsEnabled, true);
      }

      _enabled = prefs.getBool(_keyTooltipsEnabled) ?? true;
      logger.d("Loaded tooltips preference: $_enabled");
    } catch (e) {
      logger.d("Error initializing tooltips state: $e");
      _enabled = true;
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setEnabled(bool enabled) async {
    if (_enabled == enabled) return;

    _enabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyTooltipsEnabled, enabled);
    } catch (e) {
      logger.d("Error saving tooltips preference: $e");
    }
  }

  /// Re-enable tips and reset known per-tooltip dismissal flags.
  ///
  /// This is intended for the Settings toggle: when user turns tips back on,
  /// they expect the tips to show again.
  Future<void> enableAndResetAll() async {
    await setEnabled(true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyNotificationsAlertsExplainerDismissed, false);
    } catch (e) {
      logger.d("Error resetting tooltip flags: $e");
    }
  }
}

