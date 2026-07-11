import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart";
import "package:google_sign_in/google_sign_in.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/google_sign_in_warmup.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";

/// Clears auth when the OS restored Firebase from Keychain but the app sandbox
/// (SharedPreferences) has no backend session — typical after iOS reinstall.
///
/// Android reinstall usually wipes Firebase persistence; combined with
/// [backup_rules] / [data_extraction_rules] excluding prefs, tokens are not
/// resurrected from backup.
abstract final class ReinstallSessionGuard {
  /// Call once after [Firebase.initializeApp], before [AuthenticationState]
  /// reads auth.
  static Future<void> clearStaleFirebaseSessionAfterReinstall() async {
    if (kIsWeb) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final token = await SessionManager.getToken();
    if (token != null && token.isNotEmpty) return;

    logger.d(
      "🔐 ReinstallSessionGuard: Firebase user present but no backend token "
      "in prefs — treating as reinstall / wiped sandbox; signing out",
    );

    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      logger.d("⚠️ ReinstallSessionGuard: Firebase signOut failed: $e");
    }
    // Also clear the GoogleSignIn cache. The Firebase user was restored
    // from Keychain on iOS reinstall, but the GoogleSignIn plugin keeps
    // its own cached account — without this, the auth wizard would
    // silently re-sign-in to the pre-reinstall identity instead of
    // letting the user reconfirm their account.
    try {
      await GoogleSignInWarmup.ensureInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      logger.d("⚠️ ReinstallSessionGuard: GoogleSignIn signOut failed: $e");
    }
    try {
      await SessionManager.clearSession();
    } catch (e) {
      logger.d("⚠️ ReinstallSessionGuard: clearSession failed: $e");
    }
    try {
      ProfileCompletionState().reset();
    } catch (_) {}
  }
}
