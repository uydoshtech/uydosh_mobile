import "package:flutter/widgets.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";

/// Centralized auth-related navigation flows.
final class AuthFlow {
  const AuthFlow._();

  /// Clears local + backend session (best-effort) then routes to auth wizard.
  ///
  /// Safe across async gaps: it checks [BuildContext.mounted] before navigation.
  static Future<void> logoutAndReauthenticate(BuildContext context) async {
    await LogoutService().performLogout();
    if (!context.mounted) return;
    context.pushReplaceAuthWizard();
  }
}

