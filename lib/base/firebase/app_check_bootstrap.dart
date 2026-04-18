import "dart:io" show Platform;

import "package:firebase_app_check/firebase_app_check.dart";
import "package:flutter/foundation.dart" show kDebugMode, kIsWeb;
import "package:uy_dosh/base/logger/logger.dart";

/// Initializes Firebase App Check.
///
/// Firebase Phone Auth uses App Check to protect against abuse. In debug
/// builds we register the **debug provider** — the native SDK generates a
/// debug token on first run and prints it to the IDE console. That token
/// must be registered once in Firebase Console → App Check → Apps → Manage
/// debug tokens. The Dart-side `activate()` does NOT accept a pre-generated
/// token (it's a native-only setting), so we just switch on debug mode here
/// and rely on the printed token.
///
/// In release builds this uses:
/// * Android → Play Integrity
/// * iOS     → App Attest (falls back to DeviceCheck on older devices)
/// * Web     → reCAPTCHA v3 (pass the site key via `--dart-define
///             FIREBASE_APPCHECK_RECAPTCHA_SITE_KEY=...` if/when needed)
class AppCheckBootstrap {
  static const _recaptchaSiteKey =
      String.fromEnvironment("FIREBASE_APPCHECK_RECAPTCHA_SITE_KEY");

  static Future<void> activate() async {
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider:
            kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
        appleProvider: kDebugMode
            ? AppleProvider.debug
            : AppleProvider.appAttestWithDeviceCheckFallback,
        webProvider: _recaptchaSiteKey.isNotEmpty
            ? ReCaptchaV3Provider(_recaptchaSiteKey)
            : null,
      );
      FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

      if (kDebugMode) {
        logger.d(
          "🛡️ App Check activated in DEBUG mode. "
          "Look for a 'Enter this debug secret into the Firebase Console' line "
          "in the console and register it at "
          "Firebase Console → App Check → Apps → Manage debug tokens.",
        );
      } else {
        final platform = kIsWeb
            ? "web"
            : Platform.isAndroid
                ? "Android (Play Integrity)"
                : Platform.isIOS
                    ? "iOS (App Attest)"
                    : "other";
        logger.d("🛡️ App Check activated for $platform");
      }
    } catch (e, stackTrace) {
      logger.d("⚠️ App Check activation failed: $e");
      logger.d("Stack trace: $stackTrace");
    }
  }
}
