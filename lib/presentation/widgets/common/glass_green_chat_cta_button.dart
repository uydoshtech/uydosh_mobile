import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/button_icon_label.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";

/// Frosted “glass” primary CTA used for in-app UyDosh chat entry points: a
/// translucent forest-green panel, backdrop blur, and a brighter green rim
/// so it reads clearly on dark navy shells (matches listing-detail chat).
class GlassGreenChatCtaButton extends StatefulWidget {
  const GlassGreenChatCtaButton({
    required this.onPressed,
    required this.label,
    super.key,
    this.icon = CupertinoIcons.shield_fill,
    this.iconSize = 18,
    this.height = 48,
    this.width,
    this.borderRadius,
    this.textStyle,
    this.isLoading = false,
    this.enableBackdropBlur = true,
  });

  static const Color _brandGreen = Color(0xFF25C06D);

  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final double iconSize;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool enableBackdropBlur;

  @override
  State<GlassGreenChatCtaButton> createState() =>
      _GlassGreenChatCtaButtonState();
}

class _GlassGreenChatCtaButtonState extends State<GlassGreenChatCtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final enableBlur = widget.enableBackdropBlur &&
        LiquidGlassRendering.effectsEnabled(context);

    final blurSigma = enableBlur ? (isDark ? 18.0 : 22.0) : 0.0;

    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    const strokeGreen = GlassGreenChatCtaButton._brandGreen;

    final fg = Colors.white;
    final resolvedStyle = widget.textStyle ??
        TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: fg,
          height: 1.0,
        );

    final enabled = widget.onPressed != null && !widget.isLoading;
    final shadows = !enabled || _pressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);

    const glassLeft = Color(0xFF1A3D2E);
    const glassRight = Color(0xFF0F2419);
    const lightFaceLeft = Color(0xFF000000);
    const lightFaceRight = Color(0xFF1A1A1A);
    final solidSurface = UiPerformancePolicy.solidColorsPreferredForDevice;

    final face = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: isDark
            ? Border.all(
                color: strokeGreen.withValues(alpha: solidSurface ? 1 : 0.88),
                width: 1,
              )
            : null,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark
              ? solidSurface
                  ? const [glassLeft, glassRight]
                  : [
                      glassLeft.withValues(alpha: 0.62),
                      glassRight.withValues(alpha: 0.48),
                    ]
              : const [lightFaceLeft, lightFaceRight],
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: widget.isLoading
              ? UydoshInlineSpinner(color: fg, dimension: 22)
              : ButtonIconLabel(
                  leading:
                      ThemeIcon(widget.icon, size: widget.iconSize, color: fg),
                  label: Text(
                    widget.label,
                    style: resolvedStyle,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        ),
      ),
    );

    Widget buildSizedButton(double? width) {
      return SizedBox(
        width: width,
        height: widget.height,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform:
              Matrix4.translationValues(0, _pressed && enabled ? 2 : 0, 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: borderRadius,
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              onTap: enabled
                  ? () {
                      HapticFeedbackUtils.impact();
                      widget.onPressed?.call();
                    }
                  : null,
              onHighlightChanged:
                  enabled ? (v) => setState(() => _pressed = v) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  boxShadow: shadows,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (enableBlur && !solidSurface)
                        LiquidGlassRendering.backdropBlur(
                          enabled: enableBlur,
                          sigma: blurSigma,
                          child: const SizedBox.expand(),
                        ),
                      Positioned.fill(child: face),
                      // Thin highlight along the top edge — reads as glass lip.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: const Alignment(0, 0.35),
                                colors: [
                                  Colors.white
                                      .withValues(alpha: isDark ? 0.07 : 0.05),
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.width != null) return buildSizedButton(widget.width);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : null;
        return buildSizedButton(width);
      },
    );
  }
}
