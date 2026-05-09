import "package:firebase_app_check/firebase_app_check.dart";
import "package:flutter/foundation.dart" show kDebugMode, kIsWeb, kProfileMode;
import "package:uy_dosh/base/logger/logger.dart";

/// Initializes Firebase App Check.
///
/// **Debug (native):** Uses [AndroidProvider.debug] / [AppleProvider.debug].
/// On iOS the Flutter `firebase_app_check` plugin owns the provider factory; do not
/// mirror debug setup in `AppDelegate` (early native Firebase configure races DeviceCheck).
/// Xcode console prints a **debug token** — register it at
/// Firebase Console → App Check → `uydosh_ios` → ⋯ → **Manage debug tokens**.
///
/// **Release / profile (native):** Play Integrity + DeviceCheck.
///
/// **Web:** reCAPTCHA v3 when `FIREBASE_APPCHECK_RECAPTCHA_SITE_KEY` is set.
///
/// Pass `--dart-define=DISABLE_FIREBASE_APP_CHECK=true` to skip entirely.
class AppCheckBootstrap {
  static const _recaptchaSiteKey =
      String.fromEnvironment("FIREBASE_APPCHECK_RECAPTCHA_SITE_KEY");
  static const _disableAppCheck =
      bool.fromEnvironment("DISABLE_FIREBASE_APP_CHECK", defaultValue: false);

  static Future<void> activate() async {
    try {
      final msg =
          "🛡️ App Check bootstrap (debug=$kDebugMode profile=$kProfileMode web=$kIsWeb disable=$_disableAppCheck)";
      logger.d(msg);
      // ignore: avoid_print
      print(msg);

      if (_disableAppCheck) {
        logger.d("🛡️ App Check disabled via DISABLE_FIREBASE_APP_CHECK=1");
        // ignore: avoid_print
        print("🛡️ App Check disabled via DISABLE_FIREBASE_APP_CHECK=1");
        return;
      }

      // Web: reCAPTCHA only when configured.
      if (kIsWeb) {
        if (_recaptchaSiteKey.isEmpty) {
          logger.d(
            "🛡️ App Check skipped on web: missing reCAPTCHA v3 site key. "
            "Provide via --dart-define FIREBASE_APPCHECK_RECAPTCHA_SITE_KEY=...",
          );
          return;
        }
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.deviceCheck,
          webProvider: ReCaptchaV3Provider(_recaptchaSiteKey),
        );
        FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
        logger.d("🛡️ App Check activated for web (reCAPTCHA v3)");
        return;
      }

      // Native DEBUG: debug provider — token printed to Xcode / Flutter console.
      if (kDebugMode) {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
          webProvider: null,
        );
        FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
        const hint =
            "🛡️ App Check DEBUG active. Search Xcode console for the Firebase "
            "App Check debug token, then Firebase Console → App Check → "
            "uydosh_ios → ⋯ → Manage debug tokens → Add.";
        logger.d(hint);
        // ignore: avoid_print
        print(hint);
        return;
      }

      // Native PROFILE / RELEASE: production attestation.
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
        webProvider: null,
      );
      FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      logger.d("🛡️ App Check activated (Play Integrity / DeviceCheck)");
    } catch (e, stackTrace) {
      logger.d("⚠️ App Check activation failed: $e");
      logger.d("Stack trace: $stackTrace");
    }
  }
}
