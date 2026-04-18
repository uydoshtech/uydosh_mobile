import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/button_icon_label.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    /// Overrides gradient base; default matches the messages inbox toggle track
    /// ([ThemeState.cardColor]).
    this.surfaceGradientBase,
    this.textColor,
    this.textStyle,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? surfaceGradientBase;
  final Color? textColor;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool isDisabled;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  Color _surfaceGradientBase() {
    return ThemeState().cardColor;
  }

  Color _foregroundColor() {
    if (widget.textColor != null) return widget.textColor!;
    return ThemeState().unselectedTabTextColor.withValues(alpha: 0.82);
  }

  bool get _enabled =>
      widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final bg = widget.surfaceGradientBase ?? _surfaceGradientBase();
    final fg = _foregroundColor();
    final radius = widget.borderRadius ?? BorderRadius.circular(8);
    final shadows =
        !_enabled || _pressed
            ? ThreeDSurfaceStyle.pressedShadows(context)
            : ThreeDSurfaceStyle.elevatedShadows(context);
    final pad =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    // Match ElevatedButton label metrics (pre–3d-styles); ambient DefaultTextStyle
    // (e.g. body text with a tall line height) was inflating perceived button height.
    final labelStyle =
        Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              height: 1.0,
            ) ??
            TextStyle(
              color: fg,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.0,
            );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _pressed && _enabled ? 2 : 0, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: _enabled ? widget.onPressed : null,
            onHighlightChanged:
                _enabled ? (v) => setState(() => _pressed = v) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              padding: pad,
              decoration: BoxDecoration(
                borderRadius: radius,
                gradient: ThreeDSurfaceStyle.surfaceGradient(context, bg),
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
                              ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                                ),
                              )
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

/// Convenience factory for common button patterns
class PrimaryButtonFactory {
  static Widget iconText({
    required VoidCallback? onPressed,
    required IconData icon,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? surfaceGradientBase,
    Color? textColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      surfaceGradientBase: surfaceGradientBase,
      textColor: textColor,
      textStyle: textStyle,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      ),
    );
  }

  static Widget textIcon({
    required VoidCallback? onPressed,
    required String text,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? surfaceGradientBase,
    Color? textColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      surfaceGradientBase: surfaceGradientBase,
      textColor: textColor,
      textStyle: textStyle,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: textStyle),
          const SizedBox(width: 8),
          Icon(icon, size: iconSize),
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
    BorderRadius? borderRadius,
    Color? surfaceGradientBase,
    Color? textColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    final resolvedIconSize = iconSize ?? 22;
    final slotWidth = resolvedIconSize + 8;
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      surfaceGradientBase: surfaceGradientBase,
      textColor: textColor,
      textStyle: textStyle,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: ButtonIconLabel(
        slotWidth: slotWidth,
        leading: Icon(icon, size: resolvedIconSize),
        label: Text(
          text,
          style: textStyle,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
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
    BorderRadius? borderRadius,
    Color? surfaceGradientBase,
    Color? textColor,
    TextStyle? textStyle,
    double? iconSize,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    final resolvedIconSize = iconSize ?? 22;
    final slotWidth = resolvedIconSize + 8;
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      surfaceGradientBase: surfaceGradientBase,
      textColor: textColor,
      textStyle: textStyle,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: ButtonIconLabel(
        slotWidth: slotWidth,
        trailing: Icon(icon, size: resolvedIconSize),
        label: Text(
          text,
          style: textStyle,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  static Widget text({
    required VoidCallback? onPressed,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? surfaceGradientBase,
    Color? textColor,
    TextStyle? textStyle,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      surfaceGradientBase: surfaceGradientBase,
      textColor: textColor,
      textStyle: textStyle,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: Text(text, style: textStyle),
    );
  }

  static Widget icon({
    required VoidCallback? onPressed,
    required IconData icon,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    BorderRadius? borderRadius,
    Color? surfaceGradientBase,
    Color? textColor,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      surfaceGradientBase: surfaceGradientBase,
      textColor: textColor,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: Icon(icon),
    );
  }
}
