/// Google Gemini (Google AI) API configuration.
///
/// Google AI Studio: `UyDosh_API_Key`, `UyDosh_API_Key_2`. Project:
/// `projects/668524070857` (668524070857).
///
/// **Quota:** Per [Google’s rate-limit docs](https://ai.google.dev/gemini-api/docs/rate-limits),
/// limits apply **per Google Cloud project**, not per API key. Extra keys in the
/// same project share one RPM/RPD/TPM pool; they do not double free-tier quota.
/// See [AI Studio rate limits](https://aistudio.google.com/rate-limit) for your
/// project’s current numbers. Higher throughput requires a paid tier / billing.
///
/// TODO: Move keys to `--dart-define`, CI secrets, or remote config before
/// shipping broadly — keys in source can be extracted from the app binary.
abstract final class GeminiConfig {
  static const String apiKey = "AIzaSyCPmgewzP0p9W9b4aCJz8wQTDy53cw8AZE";

  /// Secondary key (same project). Helps if one key is invalid; **not** a
  /// second quota bucket while limits remain project-scoped.
  static const String apiKey2 = "AIzaSyAvuvab7wcxaZ9jg5pvUEaFC6LPNnca_MY";

  /// Non-empty keys in preference order (fallback for transient / key errors).
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
  /// `gemini-2.5-flash-lite` — stable, cost-efficient, suited to translation
  /// and high-frequency text (see [model card](https://ai.google.dev/gemini-api/docs/models/gemini-2.5-flash-lite)).
  /// Match server `GEMINI_MODEL` when possible. `gemini-2.0-flash` is deprecated.
  static const String defaultModel = "gemini-2.5-flash-lite";

  static bool get isConfigured => apiKeys.isNotEmpty;
}
