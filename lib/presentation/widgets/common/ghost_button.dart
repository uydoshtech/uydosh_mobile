import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/button_icon_label.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";

class GhostButton extends StatefulWidget {
  const GhostButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.borderWidth = 2.0,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.textStyle,
    this.isOnboardingButton = false,
    this.neumorphicSoftUi = false,
    this.neumorphicFillColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double borderWidth;
  final bool isLoading;
  final bool isDisabled;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final TextStyle? textStyle;
  final bool isOnboardingButton;

  /// Flat fill matching [ColorScheme.surface], no stroke, soft dual shadows.
  final bool neumorphicSoftUi;

  /// When [neumorphicSoftUi] is true, optionally use this as the gradient base instead of a flat surface.
  final Color? neumorphicFillColor;

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _pressed = false;

  Color _surfaceGradientBase() => ThemeState().cardColor;

  bool get _enabled =>
      widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

  Color _getTextColor() {
    if (widget.textColor != null) {
      return widget.textColor!;
    }
    if (ThemeState().isLightTheme) {
      return Colors.black;
    } else if (ThemeState().isBlueTheme) {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  Color _getBorderColor() {
    if (widget.borderColor != null) {
      return widget.borderColor!;
    }
    if (ThemeState().isLightTheme) {
      return Colors.black;
    } else if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary;
    } else {
      return BlueThemeColors.buttonPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ??
        BorderRadius.circular(widget.neumorphicSoftUi ? 16 : 8);
    final List<BoxShadow> shadows;
    if (widget.neumorphicSoftUi) {
      shadows =
          _pressed && _enabled
              ? ThreeDSurfaceStyle.insetRecessedShadows(context)
              : ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context);
    } else {
      shadows =
          !_enabled || _pressed
              ? ThreeDSurfaceStyle.pressedShadows(context)
              : ThreeDSurfaceStyle.elevatedShadows(context);
    }
    final bg = _surfaceGradientBase();
    final fg = _getTextColor();
    final pad =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    final baseLabel =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              height: 1.0,
            ) ??
        TextStyle(
          color: fg,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          height: 1.0,
        );
    final labelStyle =
        widget.textStyle != null ? baseLabel.merge(widget.textStyle) : baseLabel;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(
          0,
          _pressed && _enabled ? 2 : 0,
          0,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: _enabled
                ? () {
                    UiFeedbackUtils.tap();
                    widget.onPressed?.call();
                  }
                : null,
            onHighlightChanged:
                _enabled ? (v) => setState(() => _pressed = v) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              padding: pad,
              decoration: BoxDecoration(
                borderRadius: radius,
                color:
                    widget.neumorphicSoftUi &&
                            widget.neumorphicFillColor == null
                        ? Theme.of(context).colorScheme.surface
                        : null,
                gradient:
                    widget.neumorphicSoftUi &&
                            widget.neumorphicFillColor != null
                        ? ThreeDSurfaceStyle.surfaceGradient(
                            context,
                            widget.neumorphicFillColor!,
                          )
                        : (!widget.neumorphicSoftUi
                            ? ThreeDSurfaceStyle.surfaceGradient(context, bg)
                            : null),
                border:
                    widget.neumorphicSoftUi
                        ? null
                        : Border.all(
                          color: _getBorderColor(),
                          width: widget.borderWidth,
                        ),
                boxShadow: shadows,
              ),
              child: Center(
                child: Opacity(
                  opacity: _enabled ? 1 : 0.55,
                  child: DefaultTextStyle.merge(
                    style: labelStyle,
                    child: IconTheme.merge(
                      data: IconThemeData(color: fg),
                    child:
                        widget.isLoading
                            ? UydoshInlineSpinner(color: fg, dimension: 20)
                            : widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Convenience factory for common button patterns
class GhostButtonFactory {
  // Icon + Text button
  static Widget iconText({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    Color? iconColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isOnboardingButton = false,
    bool neumorphicSoftUi = false,
  }) {
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      textColor: textColor,
      iconColor: iconColor,
      textStyle: textStyle,
      isOnboardingButton: isOnboardingButton,
      neumorphicSoftUi: neumorphicSoftUi,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ThemeIcon(icon, color: iconColor ?? textColor, size: iconSize),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(height: 1.0),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
        ],
      ),
    );
  }

  // Text + Icon button
  static Widget textIcon({
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    Color? iconColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isOnboardingButton = false,
    bool neumorphicSoftUi = false,
  }) {
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      textColor: textColor,
      iconColor: iconColor,
      textStyle: textStyle,
      isOnboardingButton: isOnboardingButton,
      neumorphicSoftUi: neumorphicSoftUi,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(height: 1.0),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
          const SizedBox(width: 8),
          ThemeIcon(icon, color: iconColor ?? textColor, size: iconSize),
        ],
      ),
    );
  }

  /// Like [iconText], but keeps the text centered (no horizontal shifting).
  static Widget iconTextCentered({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    Color? iconColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isOnboardingButton = false,
    bool neumorphicSoftUi = false,
    Color? neumorphicFillColor,
    BorderRadius? borderRadius,
  }) {
    final resolvedIconSize = iconSize ?? 22;
    final slotWidth = resolvedIconSize + 8;
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      textColor: textColor,
      iconColor: iconColor,
      textStyle: textStyle,
      isOnboardingButton: isOnboardingButton,
      neumorphicSoftUi: neumorphicSoftUi,
      neumorphicFillColor: neumorphicFillColor,
      child: ButtonIconLabel(
        slotWidth: slotWidth,
        leading: ThemeIcon(
          icon,
          color: iconColor ?? textColor,
          size: resolvedIconSize,
        ),
        label: Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(height: 1.0),
          textHeightBehavior: const TextHeightBehavior(
            applyHeightToFirstAscent: false,
            applyHeightToLastDescent: false,
          ),
        ),
      ),
    );
  }

  /// Like [textIcon], but keeps the text centered (no horizontal shifting).
  static Widget textIconCentered({
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    Color? iconColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isOnboardingButton = false,
    bool neumorphicSoftUi = false,
  }) {
    final resolvedIconSize = iconSize ?? 22;
    final slotWidth = resolvedIconSize + 8;
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      textColor: textColor,
      iconColor: iconColor,
      textStyle: textStyle,
      isOnboardingButton: isOnboardingButton,
      neumorphicSoftUi: neumorphicSoftUi,
      child: ButtonIconLabel(
        slotWidth: slotWidth,
        trailing: ThemeIcon(
          icon,
          color: iconColor ?? textColor,
          size: resolvedIconSize,
        ),
        label: Text(
          text,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // Text only button
  static Widget text({
    required VoidCallback? onPressed,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? textColor,
    TextStyle? textStyle,
    double borderWidth = 2.0,
    bool isOnboardingButton = false,
    bool neumorphicSoftUi = false,
    Color? neumorphicFillColor,
    BorderRadius? borderRadius,
  }) {
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      textColor: textColor,
      textStyle: textStyle,
      isOnboardingButton: isOnboardingButton,
      neumorphicSoftUi: neumorphicSoftUi,
      neumorphicFillColor: neumorphicFillColor,
      child: Text(text),
    );
  }

  // Icon only button
  static Widget icon({
    required VoidCallback? onPressed,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    bool isLoading = false,
    bool isDisabled = false,
    Color? borderColor,
    Color? iconColor,
    bool isOnboardingButton = false,
    bool neumorphicSoftUi = false,
  }) {
    return GhostButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      isLoading: isLoading,
      isDisabled: isDisabled,
      borderColor: borderColor,
      iconColor: iconColor,
      isOnboardingButton: isOnboardingButton,
      neumorphicSoftUi: neumorphicSoftUi,
      child: ThemeIcon(icon, color: iconColor),
    );
  }
}
