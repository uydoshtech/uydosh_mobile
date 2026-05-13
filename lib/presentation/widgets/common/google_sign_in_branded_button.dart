import "package:flutter/foundation.dart" show defaultTargetPlatform;
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/state/theme_state.dart";

/// Pill-shaped Google sign-in control matching legacy `ios_*_rd_ctn.svg`:
/// dark filled style when [AppTheme.lightTheme] is active, neutral (#F2F2F2)
/// otherwise. [label] should come from localization (e.g. `sign_in_with_google`).
/// Height matches [SignInWithAppleButton] defaults; label metrics follow the
/// same HIG scaling used in `sign_in_with_apple` (`fontSize = height * 0.43`).
const double _kGoogleSignInButtonHeight = 44;

/// Same as `sign_in_with_apple` — fixes the logo + text row height so vertical
/// insets match [SignInWithAppleButton] (`IconAlignment.left`).
const double _kOauthIconSlotScale = 28 / 44;

class GoogleSignInBrandedButton extends StatefulWidget {
  const GoogleSignInBrandedButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<GoogleSignInBrandedButton> createState() =>
      _GoogleSignInBrandedButtonState();
}

class _GoogleSignInBrandedButtonState extends State<GoogleSignInBrandedButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      transform: Matrix4.translationValues(
        0,
        _pressed && _enabled ? 2 : 0,
        0,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        child: ListenableBuilder(
          listenable: ThemeState(),
          builder: (context, child) {
            final isAppLight = ThemeState().currentTheme == AppTheme.lightTheme;
            final background =
                isAppLight ? const Color(0xFF131314) : const Color(0xFFF2F2F2);
            final foreground =
                isAppLight ? const Color(0xFFE3E3E3) : const Color(0xFF1F1F1F);

            // Layout mirrors `SignInWithAppleButton` (left icon, centered label).
            final height = _kGoogleSignInButtonHeight;
            final labelFontSize = height * 0.43;
            final useSfPro = defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS;

            final googleIcon = Container(
              width: _kOauthIconSlotScale * height,
              height: _kOauthIconSlotScale * height + 2,
              padding: EdgeInsets.only(
                bottom: (4 / 44) * height,
              ),
              child: Center(
                child: SizedBox(
                  width: labelFontSize,
                  height: labelFontSize,
                  child: SvgPicture.asset(
                    "assets/images/google_g_logo.svg",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );

            return ClipRRect(
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.hardEdge,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(22),
                  border: isAppLight
                      ? Border.all(color: const Color(0xFF8E918F))
                      : null,
                ),
                child: SizedBox(
                  height: height,
                  child: Opacity(
                    opacity: _enabled ? 1 : 0.55,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          googleIcon,
                          Expanded(
                            child: Text(
                              widget.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                inherit: false,
                                color: foreground,
                                fontSize: labelFontSize,
                                // Same defaults as SignInWithAppleButton text.
                                letterSpacing: -0.41,
                                fontFamily: useSfPro ? ".SF Pro Text" : null,
                              ),
                            ),
                          ),
                          SizedBox(width: _kOauthIconSlotScale * height),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
