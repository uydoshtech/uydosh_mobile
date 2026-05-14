import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/presentation/widgets/common/error_border_pulse.dart";

class ThreeDTextField extends StatefulWidget {
  const ThreeDTextField({
    required this.controller,
    super.key,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.onTap,
    this.onSubmitted,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.keyboardType,
    this.obscureText = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.inputFormatters,
    this.maxLength,
    this.buildCounter,
    this.style,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.hintStyle,
    this.cursorColor,
    this.showErrorBorder = false,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconConstraints,
    this.suffixIconConstraints,
  });

  final TextEditingController controller;
  final String? hintText;
  final int? minLines;
  final int? maxLines;
  final bool enabled;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool autocorrect;
  final bool enableSuggestions;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;
  final TextStyle? style;
  final EdgeInsetsGeometry contentPadding;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;
  final TextStyle? hintStyle;
  final Color? cursorColor;

  /// When true, paints a gently pulsing red border around the field to
  /// signal a failed validation pass. The border is an overlay (see
  /// [ErrorBorderPulse]) and does not change the field's intrinsic size.
  final bool showErrorBorder;

  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final BoxConstraints? prefixIconConstraints;
  final BoxConstraints? suffixIconConstraints;

  @override
  State<ThreeDTextField> createState() => _ThreeDTextFieldState();
}

class _ThreeDTextFieldState extends State<ThreeDTextField> {
  FocusNode? _ownedFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant ThreeDTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownedFocusNode)?.removeListener(_onFocusChanged);
      _focusNode.addListener(_onFocusChanged);
    }
  }

  void _onFocusChanged() {
    setStateIfMounted(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bgBase = widget.backgroundColor ?? scheme.surfaceContainerHighest;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rim = BorderRadius.lerp(widget.borderRadius, BorderRadius.circular(999), 0.25)!;
    final focused = _focusNode.hasFocus;

    // Match reference (img1):
    // - overall control reads "sunken" into the page (use inset-like shadows, no drop shadow)
    // - soft outer rim + slightly deeper inner track
    // - absolutely no hard outline on focus
    final outerBg = Color.lerp(bgBase, scheme.onSurface, isDark ? 0.06 : 0.02)!;
    final innerBg = Color.lerp(outerBg, scheme.onSurface, isDark ? 0.10 : 0.03)!;

    final innerBrightness = ThemeData.estimateBrightnessForColor(innerBg);
    final fallbackTextColor =
        innerBrightness == Brightness.dark ? Colors.white : Colors.black;
    final effectiveTextColor = widget.textColor ?? fallbackTextColor;
    final effectiveHintColor = widget.hintColor ??
        effectiveTextColor.withValues(alpha: innerBrightness == Brightness.dark ? 0.7 : 0.65);
    final effectiveHintStyle = widget.hintStyle ?? TextStyle(color: effectiveHintColor);
    final effectiveCursorColor = widget.cursorColor ?? effectiveTextColor;
    final effectiveStyle = widget.style ?? TextStyle(color: effectiveTextColor);

    final outerDarkA = isDark ? (focused ? 0.18 : 0.24) : (focused ? 0.08 : 0.12);
    final outerLightA = isDark ? 0.05 : 0.75;
    final innerDarkA = isDark ? (focused ? 0.16 : 0.22) : (focused ? 0.06 : 0.10);
    final innerLightA = isDark ? 0.05 : 0.78;

    return ErrorBorderPulse(
      showError: widget.showErrorBorder,
      borderRadius: rim,
      child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: rim,
        color: outerBg,
        boxShadow: [
          // Outer rim (inset illusion via negative spread).
          BoxShadow(
            color: Colors.black.withValues(alpha: outerDarkA),
            offset: const Offset(3, 3),
            blurRadius: 14,
            spreadRadius: -10,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: outerLightA),
            offset: const Offset(-3, -3),
            blurRadius: 14,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: innerBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: innerDarkA),
                offset: const Offset(3.5, 3.5),
                blurRadius: 14,
                spreadRadius: -9,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: innerLightA),
                offset: const Offset(-3.5, -3.5),
                blurRadius: 14,
                spreadRadius: -9,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              children: [
                // Subtle top highlight like the reference.
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: isDark ? 0.04 : 0.35),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55],
                        ),
                      ),
                    ),
                  ),
                ),
                TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  autofocus: widget.autofocus,
                  enabled: widget.enabled,
                  readOnly: widget.readOnly,
                  obscureText: widget.obscureText,
                  autocorrect: widget.autocorrect,
                  enableSuggestions: widget.enableSuggestions,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  maxLength: widget.maxLength,
                  buildCounter: widget.buildCounter,
                  cursorColor: effectiveCursorColor,
                  style: effectiveStyle,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: effectiveHintStyle,
                    prefixIcon: widget.prefixIcon,
                    suffixIcon: widget.suffixIcon,
                    prefixIconConstraints: widget.prefixIconConstraints,
                    suffixIconConstraints: widget.suffixIconConstraints,
                    // Blue theme sets [InputDecorationTheme.fillColor] to white; without
                    // an explicit fill here the TextField paints over our plate background.
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: widget.contentPadding,
                  ),
                  maxLines: widget.maxLines,
                  minLines: widget.minLines,
                  textCapitalization: widget.textCapitalization,
                  textInputAction: widget.textInputAction,
                  onTap: widget.onTap,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
