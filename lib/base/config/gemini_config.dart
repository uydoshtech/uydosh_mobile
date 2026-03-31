/// Google Gemini (Google AI) API configuration.
///
/// Google AI Studio: `UyDosh_API_Key`, `UyDosh_API_Key_2`. Project:
/// `projects/668524070857` (668524070857).
///
/// TODO: Move keys to `--dart-define`, CI secrets, or remote config before
/// shipping broadly — keys in source can be extracted from the app binary.
abstract final class GeminiConfig {
  static const String apiKey = "AIzaSyCPmgewzP0p9W9b4aCJz8wQTDy53cw8AZE";

  /// Secondary key (same project); used when the primary key hits quota/errors.
  static const String apiKey2 = "AIzaSyAvuvab7wcxaZ9jg5pvUEaFC6LPNnca_MY";

  /// Non-empty keys in preference order (fallback for rate limits / failures).
  static List<String> get apiKeys {
    final keys = <String>[];
    if (apiKey.isNotEmpty) {
      keys.add(apiKey);
    }
    if (apiKey2.isNotEmpty) {
      keys.add(apiKey2);
    }
    return keys;
  }

  /// Default model for text generation (Google AI Gemini API).
  /// Real model id (e.g. `gemini-2.0-flash`); match server `GEMINI_MODEL` when possible.
  static const String defaultModel = "gemini-2.0-flash";

  static bool get isConfigured => apiKeys.isNotEmpty;
}
