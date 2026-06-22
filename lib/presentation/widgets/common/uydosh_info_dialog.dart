import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";

/// Themed informational [AlertDialog] used by the settings "About" and legal
/// (privacy/terms) popups.
///
/// Provides the shared chrome — centered title with configurable style,
/// optional scrollable body, single "Close" action button — while callers
/// supply a [content] widget.
///
/// Use [UydoshInfoDialog.show] to present it; it wires up haptics on close
/// and returns when the dialog is dismissed.
class UydoshInfoDialog extends StatelessWidget {
  const UydoshInfoDialog({
    required this.title,
    required this.content,
    super.key,
    this.backgroundColor,
    this.titleStyle,
    this.closeLabel,
    this.closeButtonColor,
    this.scrollable = false,
  });

  final Widget title;
  final Widget content;
  final Color? backgroundColor;
  final TextStyle? titleStyle;
  final String? closeLabel;
  final Color? closeButtonColor;

  /// When true wraps [content] in a [SingleChildScrollView] so long bodies
  /// (e.g. legal terms) can scroll within the dialog.
  final bool scrollable;

  static Future<void> show(
    BuildContext context, {
    required Widget title,
    required Widget content,
    Color? backgroundColor,
    TextStyle? titleStyle,
    String? closeLabel,
    Color? closeButtonColor,
    bool scrollable = false,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => UydoshInfoDialog(
        title: title,
        content: content,
        backgroundColor: backgroundColor,
        titleStyle: titleStyle,
        closeLabel: closeLabel,
        closeButtonColor: closeButtonColor,
        scrollable: scrollable,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = titleStyle;
    final titleChild = resolvedStyle == null
        ? title
        : DefaultTextStyle.merge(
            style: resolvedStyle,
            textAlign: TextAlign.center,
            child: title,
          );

    return UydoshGlassDialog(
      fallbackBackgroundColor: backgroundColor,
      scrollable: scrollable,
      title: Center(child: titleChild),
      content: content,
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedbackUtils.impact();
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            foregroundColor: closeButtonColor ?? AppColors.error,
          ),
          child: Text(closeLabel ?? L10n.get("close")),
        ),
      ],
    );
  }
}
