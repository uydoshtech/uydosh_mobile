import "package:uy_dosh/base/util/environment_util.dart";

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
/// **Key sourcing:** Keys are no longer hardcoded. They resolve at runtime
/// from Firebase Remote Config (keys: `gemini_api_key`, `gemini_api_key_2`)
/// via [EnvironmentUtil], so they can be rotated without an app update.
/// Compile-time fallbacks default to `""` (fail closed); engineers can
/// inject keys for local builds with
/// `--dart-define=GEMINI_API_KEY=… --dart-define=GEMINI_API_KEY_2=…`.
///
/// Reminder: any key shipped to clients is fundamentally extractable from
/// the binary. Restrict the keys in Google Cloud Console (Android package
/// + SHA-256, iOS bundle id) and consider proxying Gemini calls through
/// the backend long-term.
abstract final class GeminiConfig {
  /// Primary Gemini API key. Resolved at runtime from Remote Config.
  static String get apiKey => EnvironmentUtil.geminiApiKey;

  /// Secondary key (same project). Helps if one key is invalid; **not** a
  /// second quota bucket while limits remain project-scoped. Resolved at
  /// runtime from Remote Config.
  static String get apiKey2 => EnvironmentUtil.geminiApiKey2;

  /// Non-empty keys in preference order (fallback for transient / key errors).
  static List<String> get apiKeys {
    final keys = <String>[];
    final primary = apiKey;
    if (primary.isNotEmpty) {
      keys.add(primary);
    }
    final secondary = apiKey2;
    if (secondary.isNotEmpty) {
      keys.add(secondary);
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
