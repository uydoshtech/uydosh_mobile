import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:google_sign_in/google_sign_in.dart";
import "package:uy_dosh/base/logger/logger.dart";

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        kIsWeb
            ? "626930983094-ir8a7rjvo8o1kjp795024ghh5abrb9o9.apps.googleusercontent.com"
            : null,
  );

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
      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
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
      await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
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
