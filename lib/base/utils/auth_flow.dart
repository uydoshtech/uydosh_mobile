import "package:flutter/widgets.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";

/// Centralized auth-related navigation flows.
final class AuthFlow {
  const AuthFlow._();

  /// Whether the app considers the user signed in (Firebase or local session).
  ///
  /// Prefer this over calling [AuthenticationState] directly when you only need a
  /// boolean in business logic; use [requireAuth] when opening sign-in is needed.
  static bool get isAuthenticated => AuthenticationState().isAuthenticated;

  /// Pushes [AuthWizardScreen] on top of the current route (guest registration / sign-in).
  ///
  /// For guarding an action, prefer [requireAuth] so callers consistently bail out.
  static void openSignIn(BuildContext context) {
    context.pushAuthWizard();
  }

  /// Returns `true` if the user is already authenticated.
  ///
  /// Otherwise opens sign-in via [openSignIn] and returns `false`. Callers must
  /// stop their guarded action when this returns `false` (do not continue async work).
  static bool requireAuth(BuildContext context) {
    if (AuthenticationState().isAuthenticated) return true;
    context.pushAuthWizard();
    return false;
  }

  /// Clears local + backend session (best-effort) then routes to auth wizard.
  ///
  /// Safe across async gaps: it checks [BuildContext.mounted] before navigation.
  static Future<void> logoutAndReauthenticate(BuildContext context) async {
    await LogoutService().performLogout();
    if (!context.mounted) return;
    context.pushReplaceAuthWizard();
  }
}
