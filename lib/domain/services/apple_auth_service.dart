import "dart:convert";
import "dart:math";

import "package:crypto/crypto.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";
import "package:flutter/foundation.dart" show defaultTargetPlatform, kIsWeb, TargetPlatform;
import "package:sign_in_with_apple/sign_in_with_apple.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Result of a successful Apple sign-in: the Firebase [UserCredential]
/// plus the one-shot `authorizationCode` Apple returned. The auth code
/// is needed by the backend to exchange for a long-lived refresh token
/// (so we can call Apple's `auth/revoke` at account deletion time per
/// App Review Guideline 5.1.1(v)). It is short-lived (~5 min) and
/// single-use, so the caller MUST forward it to the server immediately
/// — there is no second chance.
class AppleSignInResult {
  AppleSignInResult({
    required this.userCredential,
    required this.authorizationCode,
  });

  final UserCredential userCredential;

  /// The Apple `authorization_code` to POST to `/users/apple-bind`.
  /// Almost always non-null on a successful sign-in; modeled as
  /// nullable because Apple has, on rare occasions, returned a
  /// credential without one and we don't want to crash the auth flow
  /// over it.
  final String? authorizationCode;
}

/// Sign in with Apple wrapper that mirrors [GoogleAuthService] in shape:
/// kicks off the native ASAuthorization flow, exchanges the resulting
/// identity token for a Firebase credential, and returns the Firebase
/// [UserCredential] so the rest of the app's auth pipeline (backend
/// session, profile creation, etc.) can stay unchanged.
///
/// Apple-specific quirks worth knowing:
///
/// * Apple returns the user's full name and email **only on the very
///   first sign-in** for a given Apple ID + bundle. We capture
///   `givenName` / `familyName` from the credential and best-effort push
///   them onto the Firebase user via [User.updateDisplayName] so
///   downstream code (`currentUser.displayName`) sees them on subsequent
///   logins too.
/// * The user may pick "Hide My Email" — we'll receive a
///   `@privaterelay.appleid.com` address. Treat it as a normal email; it
///   round-trips through Apple's relay to the user's real inbox.
/// * Firebase requires a **raw nonce** to be hashed with SHA-256 and
///   sent to Apple as `nonce`, then provided unhashed to
///   `OAuthProvider.credential(rawNonce: ...)`. Without this Firebase
///   rejects the credential with `invalid_nonce`.
class AppleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Returns true when SIWA is supported on the current device. iOS/macOS
  /// support it natively; Android and Web require a Service ID + return
  /// URL we haven't configured yet, so the button is hidden there.
  static bool get isAvailable {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<void> _record(
    Object error,
    StackTrace stackTrace, {
    required String step,
  }) async {
    if (kIsWeb) return;
    try {
      await _crashlytics.setCustomKey("auth_provider", "apple");
      await _crashlytics.setCustomKey("auth_flow", "sign_in");
      await _crashlytics.setCustomKey("auth_step", step);

      if (error is FirebaseAuthException) {
        await _crashlytics.setCustomKey("firebase_auth_code", error.code);
      }

      await _crashlytics.recordError(
        error,
        stackTrace,
        fatal: false,
        reason: "Apple sign-in failed",
      );
    } catch (loggingError) {
      logger.d("Crashlytics logging failed: $loggingError");
    }
  }

  /// Generates a cryptographically secure random nonce to bind the
  /// Apple identity token to this specific sign-in attempt. The hashed
  /// form is sent to Apple; the raw form is later given to Firebase so
  /// it can verify the binding. Length 32 follows Firebase's example.
  String _generateRawNonce({int length = 32}) {
    const charset =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._";
    final random = Random.secure();
    return List<String>.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Trigger the native Sign in with Apple flow and exchange the result
  /// for a Firebase session. Returns `null` if the user cancels at the
  /// system sheet (mirrors [GoogleAuthService.signInWithGoogle]).
  ///
  /// On success the returned [AppleSignInResult] also carries Apple's
  /// one-shot `authorizationCode`. The caller is responsible for
  /// forwarding that code to `/users/apple-bind` immediately so the
  /// server can persist a refresh token for later revocation (App
  /// Review Guideline 5.1.1(v)).
  Future<AppleSignInResult?> signInWithApple() async {
    try {
      if (!isAvailable) {
        // Belt-and-braces guard: callers should already have hidden the
        // button on unsupported platforms.
        logger.d("Apple sign-in attempted on unsupported platform");
        return null;
      }

      final rawNonce = _generateRawNonce();
      final hashedNonce = _sha256(rawNonce);

      logger.d("Apple sign-in: requesting credential (nonce_sha256_len=${hashedNonce.length})");
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final identityToken = appleCredential.identityToken;
      final authorizationCode = appleCredential.authorizationCode;

      // Never log raw tokens/codes. Log only presence/length so we can
      // debug "invalid OAuth response" issues safely.
      logger.d(
        "Apple sign-in: credential received "
        "(userId_present=${(appleCredential.userIdentifier ?? '').isNotEmpty}, "
        "identityToken_len=${identityToken?.length ?? 0}, "
        "authCode_len=${authorizationCode?.length ?? 0}, "
        "email_present=${(appleCredential.email ?? '').isNotEmpty}, "
        "given_present=${(appleCredential.givenName ?? '').isNotEmpty}, "
        "family_present=${(appleCredential.familyName ?? '').isNotEmpty})",
      );
      if (identityToken == null) {
        // Should be unreachable when the flow succeeded, but Apple has
        // shipped this nil before — fail loudly rather than passing a
        // null token to Firebase.
        throw FirebaseAuthException(
          code: "invalid-credential",
          message: "Apple ID credential was missing an identityToken",
        );
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: identityToken,
        rawNonce: rawNonce,
      );

      try {
        final userCredential = await _auth.signInWithCredential(oauthCredential);

        // Apple sends givenName/familyName ONCE — on the very first sign-in
        // for this Apple ID + app bundle. If we don't capture it now,
        // there is no way to re-fetch it later. Push it onto the Firebase
        // user so `currentUser.displayName` continues to work everywhere
        // that already trusts Firebase as the name source.
        final user = userCredential.user;
        if (user != null) {
          final newDisplayName = _composeDisplayName(
            appleCredential.givenName,
            appleCredential.familyName,
          );
          if (newDisplayName != null && (user.displayName ?? "").trim().isEmpty) {
            try {
              await user.updateDisplayName(newDisplayName);
              await user.reload();
            } catch (e) {
              // Don't fail the whole sign-in just because we couldn't
              // persist a nicer display name — the user can fill it in on
              // the profile page.
              logger.d("Apple sign-in: updateDisplayName failed: $e");
            }
          }
        }

        return AppleSignInResult(
          userCredential: userCredential,
          authorizationCode: authorizationCode,
        );
      } on FirebaseAuthException catch (e, st) {
        // Surface more detail than the UI toast; this is the common failure
        // path for `[firebase_auth/invalid-credential] Invalid OAuth response`.
        logger.d(
          "Apple sign-in: FirebaseAuthException code=${e.code} "
          "message=${e.message} "
          "email=${e.email} "
          "credentialProvider=${e.credential?.providerId}",
        );
        await _record(e, st, step: "firebase_signInWithCredential");
        rethrow;
      }
    } catch (e, st) {
      await _record(e, st, step: "signInWithApple");
      logger.d("Error signing in with Apple: $e");
      rethrow;
    }
  }

  /// Apple has no native "sign out" — clearing the Firebase session is
  /// sufficient because there is no app-side keychain entry to wipe (the
  /// SIWA credential lives in iOS's system Keychain and is shared with
  /// Settings → Apple ID → Password & Security → Sign in with Apple).
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      logger.d("Error signing out from Apple/Firebase: $e");
      rethrow;
    }
  }

  bool get isSignedIn => _auth.currentUser != null;

  String? _composeDisplayName(String? given, String? family) {
    final parts = <String>[
      if (given != null && given.trim().isNotEmpty) given.trim(),
      if (family != null && family.trim().isNotEmpty) family.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(" ");
  }
}
