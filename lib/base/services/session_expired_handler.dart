import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/google_sign_in_warmup.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Global handler for the "session is dead on the backend" case (401s that
/// cannot be recovered from). Wiped local session, signs out of Firebase,
/// shows a toast, and redirects to the auth wizard.
///
/// Idempotent: concurrent 401s that all race here collapse into a single
/// logout+redirect.
class SessionExpiredHandler {
  factory SessionExpiredHandler() => _instance;
  SessionExpiredHandler._internal();
  static final SessionExpiredHandler _instance =
      SessionExpiredHandler._internal();

  static SessionExpiredHandler get instance => _instance;

  bool _handling = false;
  DateTime? _lastHandled;

  /// Triggers the session-expired flow if one isn't already in progress.
  /// Safe to call from anywhere (interceptors, blocs, services) — it uses
  /// the globally registered [GlobalKey<NavigatorState>] to navigate.
  Future<void> handle({String? reason}) async {
    if (_handling) {
      logger.d(
        "🚨 SessionExpiredHandler: Already handling an expired session, skipping (reason=$reason)",
      );
      return;
    }
    // Debounce rapid re-entries (e.g. a burst of parallel 401s right after
    // we kicked the user out).
    final now = DateTime.now();
    if (_lastHandled != null &&
        now.difference(_lastHandled!) < const Duration(seconds: 5)) {
      logger.d(
        "🚨 SessionExpiredHandler: Recently handled (<5s ago), skipping (reason=$reason)",
      );
      return;
    }
    _handling = true;
    _lastHandled = now;
    logger.d(
      "🚨 SessionExpiredHandler: Session expired, forcing logout (reason=$reason)",
    );

    try {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        logger.d("⚠️ SessionExpiredHandler: Firebase sign out failed: $e");
      }

      // Clear the GoogleSignIn plugin's cached account too. Otherwise the
      // user gets bounced to the auth wizard and the next "Sign in with
      // Google" tap silently re-authenticates as the same Google
      // identity — which, since the backend killed *that* identity's
      // session, just reproduces the 401 in a loop. Showing the account
      // chooser gives them a real way out (switch account / contact
      // support).
      if (!kIsWeb) {
        try {
          await GoogleSignInWarmup.ensureInitialized();
          await GoogleSignIn.instance.signOut();
        } catch (e) {
          logger.d("⚠️ SessionExpiredHandler: GoogleSignIn sign out failed: $e");
        }
      }

      try {
        await SessionManager.clearSession();
      } catch (e) {
        logger.d("⚠️ SessionExpiredHandler: clearSession failed: $e");
      }

      try {
        ProfileCompletionState().reset();
      } catch (_) {}

      try {
        await AuthenticationState().logout();
      } catch (e) {
        logger.d("⚠️ SessionExpiredHandler: AuthenticationState.logout failed: $e");
      }

      _showToastAndRedirect();
    } finally {
      _handling = false;
    }
  }

  void _showToastAndRedirect() {
    if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) {
      logger.d(
        "⚠️ SessionExpiredHandler: navigatorKey not registered; skipping redirect",
      );
      return;
    }
    final navigatorKey = getIt<GlobalKey<NavigatorState>>();
    // Defer to the next frame so we're not mid-build when the navigator
    // (and any ScaffoldMessenger above it) are rebuilt by the auth logout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentState?.overlay?.context ??
          navigatorKey.currentContext;
      if (context == null) {
        logger.d(
          "⚠️ SessionExpiredHandler: no navigator context available; skipping redirect",
        );
        return;
      }

      try {
        ToastTheme.showError(
          context,
          message: L10n.get("session_expired"),
        );
      } catch (e) {
        logger.d("⚠️ SessionExpiredHandler: toast failed: $e");
      }

      try {
        context.pushReplaceAuthWizard(skipExistingSessionCheck: true);
      } catch (e) {
        logger.d("⚠️ SessionExpiredHandler: redirect failed: $e");
      }
    });
  }
}
