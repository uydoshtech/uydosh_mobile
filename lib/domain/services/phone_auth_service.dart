import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Thin wrapper around `FirebaseAuth.verifyPhoneNumber` that exposes the
/// dual-path nature of Android phone verification (instant, via Play Services
/// auto-retrieval, OR SMS-code based) through two Futures:
///
///   * [PhoneVerificationHandle.autoSignedInUser] resolves if the device
///     auto-retrieved the code (Android only) and the user is already signed
///     in to Firebase.
///   * [PhoneVerificationHandle.codeSent] resolves with the `verificationId`
///     once the SMS is dispatched. Pair it with the 6-digit code the user
///     types to produce a `PhoneAuthCredential` via [submitSmsCode].
///
/// Callers should `await` whichever completes first. Only one of the two
/// ever completes; the other is left pending.
abstract class IPhoneAuthService {
  Future<PhoneVerificationHandle> verifyPhoneNumber(String phoneE164);

  /// Completes the flow after the user types the SMS code. Returns the
  /// signed-in [User] on success. Throws [FirebaseAuthException] on wrong
  /// code / expired verificationId.
  Future<User> submitSmsCode({
    required String verificationId,
    required String smsCode,
  });

  /// Whether the string looks like a valid E.164 phone number.
  bool isValidE164(String phone);
}

class PhoneVerificationHandle {
  PhoneVerificationHandle({
    required this.autoSignedInUser,
    required this.codeSent,
  });

  /// Resolves with a signed-in [User] when Android auto-retrieves the code.
  /// Never completes on iOS / web.
  final Future<User> autoSignedInUser;

  /// Resolves with `(verificationId, resendToken)` once the SMS has been
  /// dispatched by Firebase.
  final Future<PhoneCodeSent> codeSent;
}

class PhoneCodeSent {
  PhoneCodeSent({required this.verificationId, this.resendToken});

  final String verificationId;
  final int? resendToken;
}

class PhoneAuthService implements IPhoneAuthService {
  PhoneAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  static final _e164 = RegExp(r"^\+[1-9]\d{1,14}$");

  @override
  bool isValidE164(String phone) => _e164.hasMatch(phone.trim());

  @override
  Future<PhoneVerificationHandle> verifyPhoneNumber(String phoneE164) async {
    if (!isValidE164(phoneE164)) {
      throw ArgumentError.value(
        phoneE164,
        "phoneE164",
        "Expected E.164 format (e.g. +998901234567)",
      );
    }

    final autoCompleter = Completer<User>();
    final codeSentCompleter = Completer<PhoneCodeSent>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneE164,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Android-only auto-retrieval. Sign the user in directly.
        if (autoCompleter.isCompleted) return;
        try {
          logger.d("📲 Phone auth: auto-retrieval succeeded");
          final result = await _auth.signInWithCredential(credential);
          final user = result.user;
          if (user == null) {
            autoCompleter.completeError(
              FirebaseAuthException(
                code: "null-user",
                message: "Firebase returned no user after auto-sign-in",
              ),
            );
          } else {
            autoCompleter.complete(user);
          }
        } catch (e, s) {
          autoCompleter.completeError(e, s);
        }
      },
      verificationFailed: (e) {
        logger.d("❌ Phone auth: verification failed: ${e.code} ${e.message}");
        if (!codeSentCompleter.isCompleted) {
          codeSentCompleter.completeError(e);
        }
        if (!autoCompleter.isCompleted) {
          autoCompleter.completeError(e);
        }
      },
      codeSent: (verificationId, resendToken) {
        logger.d("📨 Phone auth: SMS code dispatched (id=$verificationId)");
        if (!codeSentCompleter.isCompleted) {
          codeSentCompleter.complete(
            PhoneCodeSent(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        logger.d("⏱️ Phone auth: auto-retrieval timed out for $verificationId");
      },
    );

    return PhoneVerificationHandle(
      autoSignedInUser: autoCompleter.future,
      codeSent: codeSentCompleter.future,
    );
  }

  @override
  Future<User> submitSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: "null-user",
        message: "Firebase returned no user after code verification",
      );
    }
    return user;
  }
}
