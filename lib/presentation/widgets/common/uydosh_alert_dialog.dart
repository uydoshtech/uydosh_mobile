import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";

/// Default app dialog chrome: frosted "liquid glass" surface with common
/// title/content padding. Callers supply [title], [content], and [actions].
///
/// Backed by [UydoshGlassDialog] so it shares the same glass treatment as the
/// drawer and modal bottom sheets.
class UydoshAlertDialog extends StatelessWidget {
  const UydoshAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.backgroundColor,
    this.titlePadding = const EdgeInsets.fromLTRB(24, 24, 24, 10),
    this.contentPadding = const EdgeInsets.fromLTRB(24, 0, 24, 20),
    this.actionsPadding = const EdgeInsets.fromLTRB(16, 0, 12, 12),
    this.semanticLabel,
    this.scrollable = false,
    this.insetPadding = const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 24,
    ),
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  /// Solid fill used only when blur effects are disabled (reduce motion).
  final Color? backgroundColor;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry actionsPadding;
  final String? semanticLabel;
  final bool scrollable;

  /// Passed to [Dialog.insetPadding]; override for edge-to-edge dialogs.
  final EdgeInsets insetPadding;

  @override
  Widget build(BuildContext context) {
    return UydoshGlassDialog(
      title: title,
      content: content,
      actions: actions,
      fallbackBackgroundColor: backgroundColor,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      semanticLabel: semanticLabel,
      scrollable: scrollable,
      insetPadding: insetPadding,
    );
  }
}
