import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:google_sign_in/google_sign_in.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/google_sign_in_warmup.dart";

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  Future<void> _recordGoogleSignInError(
    Object error,
    StackTrace stackTrace, {
    required String step,
  }) async {
    if (kIsWeb) return;
    try {
      await _crashlytics.setCustomKey("auth_provider", "google");
      await _crashlytics.setCustomKey("auth_flow", "sign_in");
      await _crashlytics.setCustomKey("auth_step", step);

      if (error is FirebaseAuthException) {
        await _crashlytics.setCustomKey("firebase_auth_code", error.code);
      }

      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: false,
        reason: "Google sign-in failed",
      );
    } catch (loggingError) {
      // Never allow telemetry failures to break auth flows.
      logger.d("Crashlytics logging failed: $loggingError");
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await GoogleSignInWarmup.ensureInitialized();

      // Trigger the authentication flow
      GoogleSignInAccount googleUser;
      try {
        googleUser = await GoogleSignIn.instance.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          // User cancelled the sign-in
          return null;
        }
        rethrow;
      }

      // Obtain the auth details from the request (synchronous in v7+;
      // authorization tokens like accessToken are a separate step via
      // `googleUser.authorizationClient`, not needed for Firebase here).
      final googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e, st) {
      await _recordGoogleSignInError(e, st, step: "signInWithGoogle");
      logger.d("Error signing in with Google: $e");
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await GoogleSignInWarmup.ensureInitialized();
      await Future.wait([_auth.signOut(), GoogleSignIn.instance.signOut()]);
    } catch (e) {
      logger.d("Error signing out: $e");
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;

  // Get user email
  String? get userEmail => _auth.currentUser?.email;

  // Get user photo URL
  String? get userPhotoURL => _auth.currentUser?.photoURL;
}
