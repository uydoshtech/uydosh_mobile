import "package:flutter/foundation.dart" show kDebugMode;
import "package:posthog_flutter/posthog_flutter.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// Initializes the PostHog Flutter SDK when a project API key is available.
///
/// The project API key is a public client write-only token (same class as a
/// GA measurement ID). Default lives in [EnvironmentUtil.compileTimePosthogApiKey]
/// (US Cloud). Override at build time if needed:
///
/// ```bash
/// flutter run --dart-define=POSTHOG_API_KEY=phc_…
/// # optional host override (defaults to US cloud):
/// flutter run --dart-define=POSTHOG_HOST=https://eu.i.posthog.com
/// ```
///
/// When the key is empty the SDK is not set up and [isEnabled] stays false —
/// [AppAnalyticsService] then no-ops its PostHog dual-writes.
abstract final class PosthogBootstrap {
  static bool _enabled = false;

  /// Whether [setup] successfully initialized the SDK for this process.
  static bool get isEnabled => _enabled;

  /// Call once during app startup (after [WidgetsFlutterBinding.ensureInitialized]).
  static Future<void> setup() async {
    if (_enabled) return;

    final apiKey = EnvironmentUtil.compileTimePosthogApiKey.trim();
    if (apiKey.isEmpty) {
      logger.d(
        "PostHog skipped: POSTHOG_API_KEY not set "
        "(pass --dart-define=POSTHOG_API_KEY=…)",
      );
      return;
    }

    try {
      final config = PostHogConfig(apiKey)
        ..host = EnvironmentUtil.compileTimePosthogHost
        ..debug = kDebugMode
        ..captureApplicationLifecycleEvents = true
        ..personProfiles = PostHogPersonProfiles.identifiedOnly;

      await Posthog().setup(config);
      _enabled = true;
      logger.d("PostHog initialized (${EnvironmentUtil.compileTimePosthogHost})");
    } catch (e) {
      logger.d("PostHog initialization failed: $e");
    }
  }
}
