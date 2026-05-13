import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Transparent “plate” [InputDecoration] used with [WheelPickerPlateContainer].
class UydoshPlateFieldDecoration {
  UydoshPlateFieldDecoration._();

  static const EdgeInsets defaultContentPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 14);

  static InputDecoration forHint(
    BuildContext context, {
    required String hintText,
    TextStyle? hintStyle,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final brightness = Theme.of(context).brightness;
    final resolvedHintStyle =
        hintStyle ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color:
              brightness == Brightness.dark
                  ? Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.7)
                  : Colors.grey[400],
        );
    final radius = ThreeDSurfaceStyle.wheelPickerPlateRadius;
    return InputDecoration(
      hintText: hintText,
      hintStyle: resolvedHintStyle,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: contentPadding ?? defaultContentPadding,
    );
  }

  /// Gig / listing post flows: hides inline validator text (plate shows errors).
  static InputDecoration gigPostField(
    BuildContext context, {
    required String hintText,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final hintColor =
        Theme.of(context).brightness == Brightness.dark
            ? scheme.onSurface.withValues(alpha: 0.45)
            : Colors.grey[500]!;
    final cleanedHint =
        hintText.replaceAll(RegExp(r"\s*\([^)]*\)"), "").trim();
    return UydoshPlateFieldDecoration.forHint(
      context,
      hintText: cleanedHint,
      hintStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: hintColor,
      ),
    ).copyWith(
      errorStyle: const TextStyle(height: 0, fontSize: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      isDense: true,
    );
  }
}

/// [TextFormField] on a listing-style [WheelPickerPlateContainer].
class UydoshPlateTextFormField extends StatelessWidget {
  const UydoshPlateTextFormField({
    required this.hintText,
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.buildCounter,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus,
    this.showErrorBorder = false,
    this.dirtyOutlineColor,
    this.style,
    this.decoration,
    this.clipBehavior = Clip.antiAlias,
    this.textCapitalization = TextCapitalization.none,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final InputCounterWidgetBuilder? buildCounter;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool? autofocus;
  final bool showErrorBorder;
  final Color? dirtyOutlineColor;
  final String hintText;
  final TextStyle? style;
  final InputDecoration? decoration;
  final Clip clipBehavior;
  final TextCapitalization textCapitalization;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final resolvedStyle =
        style ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color:
              ThemeState().isLightTheme
                  ? Colors.black
                  : Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final inputDec =
        decoration ?? UydoshPlateFieldDecoration.forHint(context, hintText: hintText);

    return WheelPickerPlateContainer(
      theme: Theme.of(context),
      showErrorBorder: showErrorBorder,
      dirtyOutlineColor: dirtyOutlineColor,
      clipBehavior: clipBehavior,
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        validator: validator,
        onChanged: onChanged,
        onTap: onTap,
        onFieldSubmitted: onFieldSubmitted,
        onEditingComplete: onEditingComplete,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        buildCounter: buildCounter,
        obscureText: obscureText,
        readOnly: readOnly,
        enabled: enabled,
        autofocus: autofocus ?? false,
        style: resolvedStyle,
        decoration: inputDec,
      ),
    );
  }
}
