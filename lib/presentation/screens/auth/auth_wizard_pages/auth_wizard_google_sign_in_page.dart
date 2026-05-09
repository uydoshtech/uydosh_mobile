import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
// Prefixed because [IconAlignment] collides with Flutter Material's
// own `IconAlignment` exported from `package:flutter/material.dart`.
import "package:sign_in_with_apple/sign_in_with_apple.dart" as siwa;
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/services/apple_auth_service.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class AuthWizardGoogleSignInPage extends StatefulWidget {
  const AuthWizardGoogleSignInPage({
    required this.isAuthenticating,
    required this.isGoogleSignedIn,
    required this.currentUser,
    required this.onSignInWithGoogle,
    required this.onSignInWithApple,
    required this.onSignInWithPhone,
    super.key,
  });

  final bool isAuthenticating;
  final bool isGoogleSignedIn;
  final User? currentUser;
  final VoidCallback onSignInWithGoogle;

  /// Called when the user taps the Sign in with Apple button. Only
  /// invoked on platforms where SIWA is available (iOS/macOS); on
  /// other platforms the button is hidden entirely, so this callback
  /// can be a no-op there if the parent prefers.
  final VoidCallback onSignInWithApple;
  final VoidCallback onSignInWithPhone;

  @override
  State<AuthWizardGoogleSignInPage> createState() =>
      _AuthWizardGoogleSignInPageState();
}

class _AuthWizardGoogleSignInPageState extends State<AuthWizardGoogleSignInPage> {
  bool _pressed = false;

  bool get _enabled => !widget.isAuthenticating;

  Color _getOnboardingTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _getOnboardingTextSecondaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    const loaderSlotHeight = 104.0;
    const minButtonWidth = 199.0;
    const maxButtonWidth = 320.0;
    const horizontalPadding = 32.0; // matches Container padding below

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final buttonWidth = availableWidth.clamp(minButtonWidth, maxButtonWidth);

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: L10n.text(
                      "sign_in_with_google_description",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        height: 1.25,
                        color: _getOnboardingTextSecondaryColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!widget.isGoogleSignedIn) ...[
                    // Sign in with Apple — App Review Guideline 4.8
                    // requires this option to be at least as prominent
                    // as Google when both are offered. The native
                    // [SignInWithAppleButton] is rendered by the
                    // package and respects Apple HIG (logo, font,
                    // localized label). Width/height match the Google
                    // SVG button below for visual parity.
                    if (AppleAuthService.isAvailable) ...[
                      Center(
                        child: SizedBox(
                          width: buttonWidth,
                          height: 44,
                          child: siwa.SignInWithAppleButton(
                            onPressed: _enabled
                                ? () {
                                    HapticFeedbackUtils.impact();
                                    widget.onSignInWithApple();
                                  }
                                : () {},
                            // Always-black variant matches the dark
                            // Google SVG asset shipped below; Apple's
                            // button keeps the same look across themes
                            // per HIG.
                            style: siwa.SignInWithAppleButtonStyle.black,
                            height: 44,
                            borderRadius: BorderRadius.circular(22),
                            iconAlignment: siwa.IconAlignment.left,
                            text: L10n.get("sign_in_with_apple"),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Center(
                      child: SizedBox(
                        width: buttonWidth,
                        height: 44,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 90),
                          transform: Matrix4.translationValues(
                            0,
                            _pressed && _enabled ? 2 : 0,
                            0,
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap:
                                widget.isAuthenticating
                                    ? null
                                    : () {
                                      HapticFeedbackUtils.impact();
                                      widget.onSignInWithGoogle();
                                    },
                            onTapDown:
                                _enabled
                                    ? (_) => setState(() => _pressed = true)
                                    : null,
                            onTapUp:
                                _enabled
                                    ? (_) => setState(() => _pressed = false)
                                    : null,
                            onTapCancel:
                                _enabled
                                    ? () => setState(() => _pressed = false)
                                    : null,
                            child: ListenableBuilder(
                              listenable: ThemeState(),
                              builder: (context, child) {
                                final currentTheme =
                                    ThemeState().currentTheme;
                                final svgAsset =
                                    currentTheme == AppTheme.lightTheme
                                        ? "assets/images/ios_dark_rd_ctn.svg"
                                        : "assets/images/ios_neutral_rd_ctn.svg";
                                return SvgPicture.asset(
                                  svgAsset,
                                  width: buttonWidth,
                                  height: 44,
                                  fit: BoxFit.fitWidth,
                                  alignment: Alignment.center,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: _getOnboardingTextSecondaryColor(context)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            L10n.get("auth_separator_or"),
                            style: TextStyle(
                              color: _getOnboardingTextSecondaryColor(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: _getOnboardingTextSecondaryColor(context)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GhostButton(
                        onPressed: _enabled ? widget.onSignInWithPhone : null,
                        width: buttonWidth,
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        borderRadius: BorderRadius.circular(22),
                        textColor: _getOnboardingTextColor(context),
                        iconColor: _getOnboardingTextColor(context),
                        neumorphicSoftUi: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ThemeIcon(
                              Icons.phone_iphone,
                              color: _getOnboardingTextColor(context),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              L10n.get("sign_in_with_phone"),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (widget.isGoogleSignedIn && widget.currentUser != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _getOnboardingTextColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          widget.currentUser!.photoURL != null
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: widget.currentUser!.photoURL!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    memCacheWidth: 120,
                                    memCacheHeight: 120,
                                    placeholder: (context, url) => ThemeIcon(
                                      Icons.person,
                                      size: 30,
                                      color: _getOnboardingTextColor(context),
                                    ),
                                    errorWidget: (context, url, error) => ThemeIcon(
                                      Icons.person,
                                      size: 30,
                                      color: _getOnboardingTextColor(context),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 30,
                                  child: ThemeIcon(
                                    Icons.person,
                                    size: 30,
                                    color: _getOnboardingTextColor(context),
                                  ),
                                ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.currentUser!.displayName ?? "User",
                                  style: TextStyle(
                                    color: _getOnboardingTextColor(context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.currentUser!.email ?? "",
                                  style: TextStyle(
                                    color: _getOnboardingTextSecondaryColor(context),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Reserve space so content doesn't jump when loader appears.
                  SizedBox(
                    height: loaderSlotHeight,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child:
                            widget.isAuthenticating
                                ? CenteredHouseLoadingIndicator(
                                  key: const ValueKey("auth_loader"),
                                  text: L10n.get("signing_in"),
                                  textStyle: TextStyle(
                                    color:
                                        _getOnboardingTextSecondaryColor(context),
                                    fontSize: 16,
                                  ),
                                )
                                : const SizedBox(
                                  key: ValueKey("auth_loader_placeholder"),
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
