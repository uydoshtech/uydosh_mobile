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

  static const String keyArchivedChatsTipDismissed =
      "archived_chats_tip_dismissed";

  static const String keyMetroAllStationsHintDismissed =
      "metro_all_stations_hint_dismissed";

  static const String keyEmptySearchBellHintDismissed =
      "empty_search_bell_hint_dismissed";

  /// Shown once: inbox grouped chats auto-expand/collapse to highlight the
  /// chevron affordance.
  static const String keyGroupedChatsExpandCoachDismissed =
      "grouped_chats_expand_coach_dismissed";

  static const String _keyTooltipsEnabled = "client_tooltips_enabled";

  bool _enabled = true;
  bool _isInitialized = false;
  bool _metroAllStationsHintDismissed = true;

  bool get enabled => _enabled;
  bool get isInitialized => _isInitialized;

  /// Cached from prefs during [initialize]. Defaults to hidden until loaded.
  bool get metroAllStationsHintDismissed => _metroAllStationsHintDismissed;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Persist default so it's visible/adjustable in device storage.
      if (!prefs.containsKey(_keyTooltipsEnabled)) {
        await prefs.setBool(_keyTooltipsEnabled, true);
      }

      _enabled = prefs.getBool(_keyTooltipsEnabled) ?? true;
      _metroAllStationsHintDismissed =
          prefs.getBool(keyMetroAllStationsHintDismissed) ?? false;
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

  Future<void> dismissMetroAllStationsHint() async {
    if (_metroAllStationsHintDismissed) return;
    _metroAllStationsHintDismissed = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyMetroAllStationsHintDismissed, true);
    } catch (e) {
      logger.d("Error saving metro all-stations hint dismissal: $e");
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
      await prefs.setBool(keyArchivedChatsTipDismissed, false);
      await prefs.setBool(keyMetroAllStationsHintDismissed, false);
      await prefs.setBool(keyEmptySearchBellHintDismissed, false);
      await prefs.setBool(keyGroupedChatsExpandCoachDismissed, false);
      _metroAllStationsHintDismissed = false;
      notifyListeners();
    } catch (e) {
      logger.d("Error resetting tooltip flags: $e");
    }
  }
}

