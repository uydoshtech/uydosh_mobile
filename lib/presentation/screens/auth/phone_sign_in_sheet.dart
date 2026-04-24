import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart" show kDebugMode;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/services/phone_auth_service.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_theme.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Modal bottom sheet that walks the user through Firebase Phone Auth:
///
///   1. Enter phone number (E.164, default `+998` prefix for Uzbekistan).
///   2. Wait for SMS / auto-retrieval.
///   3. Type the 6-digit code OR get auto-signed-in (Android Play Services).
///
/// On success, pops with the verified [User]. On cancel, pops with `null`.
class PhoneSignInSheet extends StatefulWidget {
  const PhoneSignInSheet({super.key});

  static Future<User?> show(BuildContext context) {
    return showModalBottomSheet<User?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PhoneSignInSheet(),
    );
  }

  @override
  State<PhoneSignInSheet> createState() => _PhoneSignInSheetState();
}

enum _Step { enterPhone, enterCode }

/// Firebase test number that must also be registered in
/// Firebase Console → Auth → Sign-in method → Phone numbers for testing.
/// No real SMS is sent for this number — the fixed code configured in the
/// console will verify it.
const String _kFirebaseTestPhoneNumber = "+1 0000000000";

class _PhoneSignInSheetState extends State<PhoneSignInSheet> {
  late final IPhoneAuthService _phoneAuth;
  final _phoneController = TextEditingController(text: "+998 ");
  final _codeController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _codeFocus = FocusNode();

  _Step _step = _Step.enterPhone;
  bool _busy = false;
  String? _verificationId;
  String? _lastPhoneE164;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _phoneAuth = getIt<IPhoneAuthService>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: _phoneController.text.length),
        );
        _phoneFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String _normalizePhone(String raw) => raw.replaceAll(RegExp(r"[^\d+]"), "");

  /// Debug-only: prefill the phone field with the Firebase test number so the
  /// flow can be verified end-to-end without burning real SMS quota.
  /// The fixed SMS code is whatever you configured in Firebase Console.
  void _prefillTestNumber() {
    _phoneController.text = _kFirebaseTestPhoneNumber;
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneController.text.length),
    );
  }

  Future<void> _onSendCode() async {
    HapticFeedbackUtils.impact();
    final phone = _normalizePhone(_phoneController.text);
    if (!_phoneAuth.isValidE164(phone)) {
      ToastTheme.showWarning(
        context,
        message: L10n.get("phone_invalid_format"),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final handle = await _phoneAuth.verifyPhoneNumber(phone);

      // Race the two outcomes. Whichever wins drives the UI.
      unawaited(
        handle.autoSignedInUser.then(
          (user) {
            if (!mounted) return;
            logger.d("📲 Phone auth: auto-signed-in as ${user.uid}");
            Navigator.of(context).pop(user);
          },
          onError: (Object e, StackTrace s) {
            logger.d("Phone auth autoSignedInUser error: $e");
          },
        ),
      );

      final codeSent = await handle.codeSent;
      if (!mounted) return;
      setState(() {
        _verificationId = codeSent.verificationId;
        _lastPhoneE164 = phone;
        _step = _Step.enterCode;
        _busy = false;
      });
      _startResendCountdown();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _codeFocus.requestFocus(),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showFirebaseError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ToastTheme.showWarning(
        context,
        message: L10n.get("phone_verification_failed")
            .replaceAll("{error}", e.toString()),
      );
    }
  }

  Future<void> _onSubmitCode() async {
    HapticFeedbackUtils.impact();
    final code = _codeController.text.trim();
    final verificationId = _verificationId;
    if (code.length != 6 || verificationId == null) {
      ToastTheme.showWarning(
        context,
        message: L10n.get("phone_code_invalid"),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      final user = await _phoneAuth.submitSmsCode(
        verificationId: verificationId,
        smsCode: code,
      );
      if (!mounted) return;
      HapticFeedbackUtils.strongImpact();
      Navigator.of(context).pop(user);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showFirebaseError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ToastTheme.showWarning(
        context,
        message: L10n.get("phone_verification_failed")
            .replaceAll("{error}", e.toString()),
      );
    }
  }

  void _showFirebaseError(FirebaseAuthException e) {
    final key = switch (e.code) {
      "too-many-requests" => "phone_too_many_requests",
      "quota-exceeded" => "phone_quota_exceeded",
      "invalid-verification-code" => "phone_code_invalid",
      "session-expired" => "phone_code_invalid",
      "invalid-phone-number" => "phone_invalid_format",
      _ => "phone_verification_failed",
    };
    final message = key == "phone_verification_failed"
        ? L10n.get(key).replaceAll("{error}", e.message ?? e.code)
        : L10n.get(key);
    ToastTheme.showWarning(context, message: message);
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _resendSeconds -= 1;
        if (_resendSeconds <= 0) t.cancel();
      });
    });
  }

  Future<void> _onResend() async {
    if (_resendSeconds > 0 || _busy) return;
    setState(() {
      _codeController.clear();
      _step = _Step.enterPhone;
    });
    await _onSendCode();
  }

  void _onChangeNumber() {
    _resendTimer?.cancel();
    setState(() {
      _step = _Step.enterPhone;
      _codeController.clear();
      _verificationId = null;
      _resendSeconds = 0;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _phoneFocus.requestFocus(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final textColor = AuthWizardTheme.getBottomSheetTextColor();

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AuthWizardTheme.getBottomSheetBackgroundColor(),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                        AuthWizardTheme.getBottomSheetHandleColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _step == _Step.enterPhone
                    ? L10n.get("sign_in_with_phone")
                    : L10n.get("phone_code_entry_title"),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _step == _Step.enterPhone
                    ? L10n.get("sign_in_with_phone_description")
                    : L10n.get("phone_code_entry_description")
                        .replaceAll("{phone}", _lastPhoneE164 ?? ""),
                style: TextStyle(fontSize: 14, color: textColor.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_step == _Step.enterPhone) _buildPhoneStep(textColor),
              if (_step == _Step.enterCode) _buildCodeStep(textColor),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _buttonTextStyle(BuildContext context) {
    final label = Theme.of(context).textTheme.labelLarge;
    return label?.copyWith(fontSize: 17, height: 1.0) ??
        const TextStyle(fontSize: 17, height: 1.0, fontWeight: FontWeight.w500);
  }

  Widget _buildPhoneStep(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          keyboardType: TextInputType.phone,
          enabled: !_busy,
          cursorColor: AuthWizardTheme.getBottomSheetCursorColor(),
          style: TextStyle(color: textColor, fontSize: 18),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[\d+\s]")),
            LengthLimitingTextInputFormatter(20),
          ],
          decoration: InputDecoration(
            hintText: L10n.get("phone_number_example"),
            hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: textColor.withValues(alpha: 0.04),
          ),
          onSubmitted: (_) => _onSendCode(),
        ),
        if (kDebugMode) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _busy
                  ? null
                  : () {
                      HapticFeedbackUtils.impact();
                      _prefillTestNumber();
                    },
              icon: const Icon(Icons.science_outlined, size: 16),
              label: const Text("Use Firebase test number"),
              style: TextButton.styleFrom(
                foregroundColor: textColor.withValues(alpha: 0.75),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                visualDensity: VisualDensity.compact,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        PrimaryButtonFactory.textIconCentered(
          onPressed: _busy ? null : _onSendCode,
          text: L10n.get("phone_send_code"),
          icon: Icons.chevron_right,
          width: double.infinity,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: _buttonTextStyle(context),
          isLoading: _busy,
        ),
      ],
    );
  }

  Widget _buildCodeStep(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _codeController,
          focusNode: _codeFocus,
          keyboardType: TextInputType.number,
          enabled: !_busy,
          maxLength: 6,
          textAlign: TextAlign.center,
          cursorColor: AuthWizardTheme.getBottomSheetCursorColor(),
          style: TextStyle(
            color: textColor,
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 8,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: "",
            hintText: "• • • • • •",
            hintStyle: TextStyle(
              color: textColor.withValues(alpha: 0.3),
              letterSpacing: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: textColor.withValues(alpha: 0.04),
          ),
          onChanged: (value) {
            if (value.length == 6 && !_busy) {
              _onSubmitCode();
            }
          },
        ),
        const SizedBox(height: 16),
        PrimaryButtonFactory.textIconCentered(
          onPressed: _busy ? null : _onSubmitCode,
          text: _busy ? L10n.get("phone_verifying") : L10n.get("phone_verify"),
          icon: Icons.check,
          width: double.infinity,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: _buttonTextStyle(context),
          isLoading: _busy,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GhostButtonFactory.text(
                onPressed: _busy ? null : _onChangeNumber,
                text: L10n.get("change_phone_number"),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GhostButtonFactory.text(
                onPressed: _resendSeconds > 0 || _busy ? null : _onResend,
                text: _resendSeconds > 0
                    ? L10n.get("phone_resend_in_seconds")
                        .replaceAll("{seconds}", _resendSeconds.toString())
                    : L10n.get("phone_resend_code"),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
