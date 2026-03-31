/// Google Gemini (Google AI) API configuration.
///
/// Key name in Google AI Studio: `UyDosh_API_Key`. Project:
/// `projects/668524070857` (668524070857).
///
/// TODO: Move the key to `--dart-define`, CI secrets, or remote config before
/// shipping broadly — keys in source can be extracted from the app binary.
abstract final class GeminiConfig {
  static const String apiKey = "AIzaSyCPmgewzP0p9W9b4aCJz8wQTDy53cw8AZE";

  /// Default model for text generation (Google AI Gemini API).
  static const String defaultModel = "gemini-2.0-flash";

  static bool get isConfigured => apiKey.isNotEmpty;
}
