import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
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
  final Color? textColor;
  final TextStyle? textStyle;
  final bool isLoading;
  final bool isDisabled;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  Color _backgroundColor() {
    if (ThemeState().isLightTheme) {
      return Colors.black;
    }
    return BlueThemeColors.buttonPrimary;
  }

  Color _foregroundColor() {
    return widget.textColor ?? Colors.white;
  }

  bool get _enabled =>
      widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final bg = _backgroundColor();
    final fg = _foregroundColor();
    final radius = widget.borderRadius ?? BorderRadius.circular(8);
    final shadows =
        !_enabled || _pressed
            ? ThreeDSurfaceStyle.pressedShadows(context)
            : ThreeDSurfaceStyle.elevatedShadows(context);
    final pad =
        widget.padding ??
        const EdgeInsets.symmetric(horizontal: 32, vertical: 16);

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
                    style: TextStyle(color: fg),
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
      textColor: textColor,
      textStyle: textStyle,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(icon, size: iconSize),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      ),
    );
  }

  static Widget text({
    required VoidCallback? onPressed,
    required String text,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
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
    Color? textColor,
    bool isLoading = false,
    bool isDisabled = false,
  }) {
    return PrimaryButton(
      onPressed: onPressed,
      padding: padding,
      width: width,
      height: height,
      textColor: textColor,
      isLoading: isLoading,
      isDisabled: isDisabled,
      child: ThemeIcon(icon),
    );
  }
}
