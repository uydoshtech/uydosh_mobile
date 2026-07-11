import "dart:async";

import "package:flutter/foundation.dart" show kIsWeb;
import "package:google_sign_in/google_sign_in.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/authentication_state.dart";

/// Eagerly initializes the GoogleSignIn plugin so the user's first tap on
/// "Sign in with Google" doesn't pay the full native cold-start cost
/// (loading the GIDSignIn / GIS SDK, OAuth discovery roundtrip, system
/// sheet warm-up). On the user's device this manifested as a 1–3s
/// hiccup between tapping the button and seeing the system sheet —
/// because nothing in the wizard's `initState` was actually exercising
/// the native plugin until the tap.
///
/// Two-part design:
///
///  1. [start] is called once from `main.dart`'s post-frame callback
///     (alongside the other deferred startup work). The warmup runs in
///     parallel with the splash + onboarding navigation, so on a cold
///     start it has up to ~5 seconds of free runway before the user
///     could plausibly reach the auth wizard.
///  2. [ensureWarm] is awaited from the wizard's sign-in handler
///     immediately before [GoogleSignIn.authenticate]. If the warmup
///     already finished this is essentially free; if the user tapped the
///     button while the warmup was still in flight, we pay the wait
///     once here instead of paying the cold-start cost on the system UI
///     presentation itself.
///
/// The warmup deliberately does `attemptLightweightAuthentication`
/// followed by `signOut` — the silent call forces the native plugin to
/// fully initialize
/// (and on devices where the user previously authorized this app, also
/// triggers OAuth discovery), and the immediate `signOut` discards any
/// resolved cached account so the next interactive `signIn` still
/// shows the system account chooser. `signOut` is an in-memory call —
/// it doesn't unload the SDK, so the warm-up benefit is preserved.
abstract final class GoogleSignInWarmup {
  static Future<void>? _future;
  static Future<void>? _initFuture;

  /// The web OAuth client ID. Only needed on web — native platforms pick up
  /// their client ID from `GoogleService-Info.plist` / `google-services.json`.
  static const String _webClientId =
      "626930983094-ir8a7rjvo8o1kjp795024ghh5abrb9o9.apps.googleusercontent.com";

  /// `google_sign_in` 7.x made [GoogleSignIn] a singleton that must have
  /// [GoogleSignIn.initialize] called (and awaited) exactly once before any
  /// other method is touched — calling it more than once is undefined
  /// behavior. This is the single call site for that; every other file that
  /// needs [GoogleSignIn.instance] (sign-in button, sign-out on logout /
  /// session-expiry / reinstall) awaits this first. Idempotent: later calls
  /// return the same future.
  static Future<void> ensureInitialized() {
    return _initFuture ??= GoogleSignIn.instance.initialize(
      clientId: kIsWeb ? _webClientId : null,
    );
  }

  /// How long to wait after the first frame before kicking off the
  /// native warm-up when called from app startup. The splash logo's
  /// fade-in / slide-in is most sensitive to UI-thread blips during the
  /// first second or so; pushing the (background) plugin init past that
  /// window keeps any one-time framework-load cost away from the
  /// animation's peak. The full splash plays for ~4s, so we still
  /// finish well before the auth wizard could appear.
  static const Duration _startupDelay = Duration(milliseconds: 1500);

  /// Kick off the warm-up if it hasn't already started. Idempotent and
  /// safe to call from anywhere; later calls return the same future.
  /// When [delayed] is true (the default for the app-startup call site),
  /// we wait [_startupDelay] before starting native work — see comment
  /// on that constant for rationale. Call sites that want the warmup
  /// immediately (e.g. [ensureWarm] from a button tap) pass false.
  static Future<void> start({bool delayed = true}) {
    return _future ??= _run(delayed: delayed);
  }

  /// Wait for the warmup to finish, starting it on demand if no one
  /// else has already. Call this immediately before
  /// [GoogleSignIn.signIn] in the auth wizard so we never trigger the
  /// system sheet on a half-initialized plugin. Always starts the
  /// warmup *immediately* (no delay) — by the time the user has tapped
  /// the button, we want zero extra wait.
  static Future<void> ensureWarm() => start(delayed: false);

  static Future<void> _run({required bool delayed}) async {
    if (kIsWeb) return;
    // Already-authenticated users won't hit the auth wizard, so warming
    // GoogleSignIn for them is wasted work. They'll only ever need it
    // again after an explicit logout, at which point [LogoutService]
    // already does the cleanup we'd want.
    if (AuthenticationState().isAuthenticated) {
      logger.d("GoogleSignInWarmup: skipped (user already authenticated)");
      return;
    }
    if (delayed) {
      // Yield well past the splash logo's most animation-sensitive
      // window so any one-time native framework load doesn't compete
      // with rendering. This is a wait on the Dart side only — no
      // CPU spin, no UI-thread blocking.
      await Future<void>.delayed(_startupDelay);
    }
    final stopwatch = Stopwatch()..start();
    try {
      await ensureInitialized();
    } catch (e) {
      logger.d("GoogleSignInWarmup: initialize failed (non-fatal): $e");
      return;
    }
    try {
      // Doesn't throw for cancellation/interruption/no-UI outcomes by
      // default (see [GoogleSignIn.attemptLightweightAuthentication]),
      // which mirrors the old `signInSilently(suppressErrors: true)`.
      await GoogleSignIn.instance.attemptLightweightAuthentication();
    } catch (e) {
      logger.d(
        "GoogleSignInWarmup: attemptLightweightAuthentication failed (non-fatal): $e",
      );
    }
    // Drop any silently-resolved account so the next interactive signIn
    // shows the account chooser. See class doc for why.
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      logger.d("GoogleSignInWarmup: signOut failed (non-fatal): $e");
    }
    logger.d(
      "GoogleSignInWarmup: completed in ${stopwatch.elapsedMilliseconds}ms",
    );
  }
}
