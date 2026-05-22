import "package:flutter/foundation.dart" show defaultTargetPlatform;
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";

/// Pill-shaped Telegram sign-in control: flat `#4DA3E9` background,
/// white logo + label.
///
/// [label] should come from localization (e.g. `sign_in_with_telegram`).
/// Layout mirrors [GoogleSignInBrandedButton] / `SignInWithAppleButton`.
const double _kTelegramSignInButtonHeight = 44;

const Color _kTelegramSignInBlue = Color(0xFF4DA3E9);

const double _kOauthIconSlotScale = 28 / 44;

class TelegramSignInBrandedButton extends StatefulWidget {
  const TelegramSignInBrandedButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<TelegramSignInBrandedButton> createState() =>
      _TelegramSignInBrandedButtonState();
}

class _TelegramSignInBrandedButtonState
    extends State<TelegramSignInBrandedButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final height = _kTelegramSignInButtonHeight;
    final labelFontSize = height * 0.43;
    final useSfPro = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 90),
      transform: Matrix4.translationValues(
        0,
        _pressed && _enabled ? 1 : 0,
        0,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.hardEdge,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _enabled
                  ? _kTelegramSignInBlue
                  : _kTelegramSignInBlue.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(22),
            ),
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _TelegramLogoIcon(height: height),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              inherit: false,
                              color: Colors.white,
                              fontSize: labelFontSize,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.41,
                              height: 1.0,
                              fontFamily: useSfPro ? ".SF Pro Text" : null,
                            ),
                          ),
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
      ),
    );
  }
}

const String _kTelegramLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
  <path fill="#FFFFFF" d="M9.78 18.65l.28-4.23 7.68-6.92c.34-.31-.07-.46-.52-.19L7.74 13.3 3.64 12c-.88-.25-.89-.86.2-1.3l15.97-6.16c.73-.33 1.43.18 1.15 1.3l-2.72 12.81c-.19.91-.74 1.13-1.5.71L12.6 16.3l-1.99 1.93c-.23.23-.42.42-.83.42z"/>
</svg>
''';

class _TelegramLogoIcon extends StatelessWidget {
  const _TelegramLogoIcon({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final iconSize = height * 0.43;

    return SizedBox(
      width: _kOauthIconSlotScale * height,
      height: height,
      child: Center(
        child: SizedBox(
          width: iconSize,
          height: iconSize,
          child: SvgPicture.string(
            _kTelegramLogoSvg,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
