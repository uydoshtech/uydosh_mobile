import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Local-only setting (SharedPreferences). When true, hides listing description
/// translation controls and the AI improve action on create/edit.
abstract final class ClientGeminiListingUiConfig {
  static const _prefsKey = "client_gemini_listing_ui_hidden";

  static final ValueNotifier<bool> hideGeminiListingUi = ValueNotifier(false);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    hideGeminiListingUi.value = prefs.getBool(_prefsKey) ?? false;
  }

  /// Updates UI immediately; persists to [SharedPreferences] asynchronously.
  static void setHide({required bool hide}) {
    hideGeminiListingUi.value = hide;
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setBool(_prefsKey, hide),
    );
  }
}
