import "dart:async";

import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/foundation.dart" show kDebugMode;
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/cache/country_cache.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/country.dart";
import "package:uy_dosh/domain/services/phone_auth_service.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_theme.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Phone-country picker offerings, in order of display.
///
/// Used to be backed by `package:country_picker`'s 250-entry catalog filtered
/// down to the same set; replaced with this static list so we can drop the
/// dependency. Keep iso2 keys uppercase to match [Country.iso2] / firebase
/// auth conventions. Values are E.164 country calling codes (no leading "+").
///
/// New entries: add the iso2 + dial code here, and ensure the country exists
/// in [CountryCache] so display names render in all three locales.
const Map<String, String> _allowedPhoneDialCodes = <String, String>{
  "UZ": "998",
  "RU": "7",
  "KZ": "7",
  "KG": "996",
  "TJ": "992",
  "TM": "993",
  "AZ": "994",
  "AM": "374",
  "GE": "995",
  "BY": "375",
  "UA": "380",
  "MD": "373",
  "EE": "372",
  "LV": "371",
  "LT": "370",
  "US": "1",
};

/// Order in which the picker renders the allowed countries. UZ first (the
/// default for our market), USA last, ex-Soviet block in the middle ordered
/// by familiarity rather than alphabetically.
const List<String> _allowedPhoneIsoOrder = <String>[
  "UZ", "RU", "KZ", "KG", "TJ", "TM",
  "AZ", "AM", "GE", "BY", "UA", "MD",
  "EE", "LV", "LT",
  "US",
];

/// Materialized [Country] entries for the picker. Each [Country] still carries
/// its localized names from [CountryCache]; the picker layers dial code on top
/// via [_allowedPhoneDialCodes].
List<Country> _allowedPhoneCountries() {
  final out = <Country>[];
  for (final iso in _allowedPhoneIsoOrder) {
    final c = CountryCache.getCountryByIso2(iso);
    if (c != null) out.add(c);
  }
  return out;
}

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
    return showAppBottomSheet<User?>(
      context: context,
      useSafeArea: false,
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
  late final AppAnalyticsService _analytics;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _countrySearchController = TextEditingController();
  final _phoneFocus = FocusNode();
  final _codeFocus = FocusNode();

  // Selected country code for phone login. This prefix is not user-editable.
  String _selectedDialCode = "998";
  String _selectedFlagEmoji = "🇺🇿";

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
    _analytics = getIt<AppAnalyticsService>();
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
    _countrySearchController.dispose();
    _phoneFocus.dispose();
    _codeFocus.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  String _normalizeNationalNumber(String raw) => raw.replaceAll(RegExp(r"[^\d]"), "");

  String _buildE164() {
    final national = _normalizeNationalNumber(_phoneController.text);
    return "+$_selectedDialCode$national";
  }

  String _stripE164PrefixForHint(String e164Example) {
    // Example strings currently include "+998 ...". Once we show the dial code
    // as a separate non-editable prefix, show only the national part as hint.
    return e164Example.replaceFirst(RegExp(r"^\+\d+\s*"), "");
  }

  /// Debug-only: prefill the phone field with the Firebase test number so the
  /// flow can be verified end-to-end without burning real SMS quota.
  /// The fixed SMS code is whatever you configured in Firebase Console.
  void _prefillTestNumber() {
    // Match Firebase test number default: +1 0000000000
    _selectedDialCode = "1";
    _selectedFlagEmoji = "🇺🇸";
    _phoneController.text = _kFirebaseTestPhoneNumber.replaceFirst(RegExp(r"^\+\d+\s*"), "");
    _phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: _phoneController.text.length),
    );
  }

  Future<void> _onSendCode() async {
    HapticFeedbackUtils.impact();
    final phone = _buildE164();
    if (!_phoneAuth.isValidE164(phone)) {
      ToastTheme.showWarning(
        context,
        message: L10n.get("phone_invalid_format"),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      // Helps measure drop-off before/after SMS dispatch.
      unawaited(_analytics.logSignInStarted(method: "phone"));
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
      setStateIfMounted(() {
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
      setStateIfMounted(() => _busy = false);
      unawaited(
        _analytics.logLoginError(
          method: "phone",
          stage: "phone_send_code",
          errorCode: "firebase_auth:${e.code}",
          errorMessage: e.message ?? e.code,
        ),
      );
      _showFirebaseError(e);
    } catch (e) {
      setStateIfMounted(() => _busy = false);
      unawaited(
        _analytics.logLoginError(
          method: "phone",
          stage: "phone_send_code",
          errorCode: e is PlatformException ? "platform:${e.code}" : null,
          errorMessage: e.toString(),
        ),
      );
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
      setStateIfMounted(() => _busy = false);
      unawaited(
        _analytics.logLoginError(
          method: "phone",
          stage: "phone_submit_code",
          errorCode: "firebase_auth:${e.code}",
          errorMessage: e.message ?? e.code,
        ),
      );
      _showFirebaseError(e);
    } catch (e) {
      setStateIfMounted(() => _busy = false);
      unawaited(
        _analytics.logLoginError(
          method: "phone",
          stage: "phone_submit_code",
          errorCode: e is PlatformException ? "platform:${e.code}" : null,
          errorMessage: e.toString(),
        ),
      );
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
      child: GlassBottomSheetSurface(
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
                  color: AuthWizardTheme.getBottomSheetHandleColor(context),
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
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_step == _Step.enterPhone) _buildPhoneStep(textColor),
            if (_step == _Step.enterCode) _buildCodeStep(textColor),
          ],
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
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCountryPrefixPicker(textColor),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                enabled: !_busy,
                cursorColor: AuthWizardTheme.getBottomSheetCursorColor(),
                style: TextStyle(color: textColor, fontSize: 18),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[\d\s()-]")),
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: InputDecoration(
                  hintText: _stripE164PrefixForHint(L10n.get("phone_number_example")),
                  hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: textColor.withValues(alpha: 0.04),
                ),
                onSubmitted: (_) => _onSendCode(),
              ),
            ),
          ],
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

  Widget _buildCountryPrefixPicker(Color textColor) {
    final bg = textColor.withValues(alpha: 0.04);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: Theme.of(context).inputDecorationTheme.enabledBorder?.borderSide ??
          BorderSide(color: textColor.withValues(alpha: 0.15)),
    );

    // IMPORTANT: InputDecorator can't be laid out with unbounded width.
    // When placed inside a Row, we must provide a finite max width.
    return SizedBox(
      width: 104,
      child: InkWell(
        onTap: _busy ? null : _showPhoneCountryPicker,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(
                color: AuthWizardTheme.getBottomSheetCursorColor(),
              ),
            ),
            filled: true,
            fillColor: bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // On narrow layouts, hide the expand icon to avoid overflow.
              final showIcon = constraints.maxWidth >= 104;

              return Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(_selectedFlagEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "+$_selectedDialCode",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (showIcon) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.unfold_more,
                      size: 18,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showPhoneCountryPicker() {
    final themeTextColor = AuthWizardTheme.getBottomSheetTextColor();
    final searchFill = themeTextColor.withValues(alpha: 0.08);

    // Allowed phone-auth countries materialized from [CountryCache] (for
    // localized names + flag) augmented with our private dial-code table.
    // Migrated off `package:country_picker` to drop a ~100 KB AOT dep that
    // shipped a 250-country catalog when we only ever expose 16.
    final allowedCountries = _allowedPhoneCountries();

    String displayName(Country c) =>
        c.getLocalizedName(L10n.currentLanguage);

    String dialCode(Country c) => _allowedPhoneDialCodes[c.iso2] ?? "";

    List<Country> filter(String rawQuery) {
      var q = rawQuery.trim().toLowerCase();
      if (q.isEmpty) return List<Country>.from(allowedCountries);
      if (q.startsWith("+")) q = q.substring(1).trim();

      // Tiny synonym help for common adjective searches.
      const synonyms = <String, String>{
        "russian": "russia",
        "uzbek": "uzbekistan",
        "kazakh": "kazakhstan",
        "kyrgyz": "kyrgyzstan",
        "tajik": "tajikistan",
        "turkmen": "turkmenistan",
        "american": "united states",
      };
      q = synonyms[q] ?? q;

      bool matches(Country c) {
        if (dialCode(c).startsWith(q)) return true;
        if (c.iso2.toLowerCase().startsWith(q)) return true;
        // Match across all three localizations so a Russian-locale user can
        // still find "Uzbekistan" by typing the English name.
        return c.nameEn.toLowerCase().contains(q) ||
            c.nameRu.toLowerCase().contains(q) ||
            c.nameUz.toLowerCase().contains(q);
      }

      return allowedCountries.where(matches).toList();
    }

    showAppBottomSheet<void>(
      context: context,
      // Enable safe area so the list stays below Dynamic Island — same flag
      // as other app bottom sheets.
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = filter(_countrySearchController.text);
            return AnimatedPadding(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: GlassBottomSheetSurface(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AuthWizardTheme.getBottomSheetHandleColor(ctx),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: themeTextColor.withValues(alpha: 0.08),
                        ),
                        itemBuilder: (ctx, i) {
                          final c = filtered[i];
                          final name = displayName(c);
                          final code = dialCode(c);
                          final isSelected = code == _selectedDialCode;
                          return ListTile(
                            dense: true,
                            leading: Text(
                              c.flag,
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(
                              name,
                              style: TextStyle(
                                color: themeTextColor,
                                fontWeight:
                                    isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            trailing: Text(
                              "+$code",
                              style: TextStyle(
                                color: themeTextColor.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedDialCode = code;
                                _selectedFlagEmoji = c.flag;
                              });
                              Navigator.of(ctx).pop();
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) _phoneFocus.requestFocus();
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _countrySearchController,
                      autofocus: true,
                      style: TextStyle(color: themeTextColor),
                      cursorColor: AuthWizardTheme.getBottomSheetCursorColor(),
                      decoration: InputDecoration(
                        labelText: L10n.get("search"),
                        labelStyle: TextStyle(
                          color: themeTextColor.withValues(alpha: 0.7),
                        ),
                        hintStyle: TextStyle(
                          color: themeTextColor.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: themeTextColor.withValues(alpha: 0.7),
                        ),
                        filled: true,
                        fillColor: searchFill,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: themeTextColor.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AuthWizardTheme.getBottomSheetCursorColor(),
                          ),
                        ),
                      ),
                      onChanged: (_) => setModalState(() {}),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Clear the query after the modal fully closes.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _countrySearchController.clear();
      });
    });
  }
}
