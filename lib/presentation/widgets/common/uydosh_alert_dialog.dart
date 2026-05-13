import "package:flutter/material.dart";

/// Default app [AlertDialog] chrome: dialog background and common title/content
/// padding. Callers supply [title], [content], and [actions].
class UydoshAlertDialog extends StatelessWidget {
  const UydoshAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.backgroundColor,
    this.titlePadding = const EdgeInsets.fromLTRB(24, 24, 24, 8),
    this.contentPadding = const EdgeInsets.fromLTRB(24, 0, 24, 16),
    this.actionsPadding,
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
  final Color? backgroundColor;
  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final String? semanticLabel;
  final bool scrollable;

  /// Passed to [AlertDialog.insetPadding]; override for edge-to-edge dialogs.
  final EdgeInsets insetPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Widget? body;
    final c = content;
    if (c == null) {
      body = null;
    } else if (scrollable) {
      body = SingleChildScrollView(child: c);
    } else {
      body = c;
    }
    return AlertDialog(
      backgroundColor: backgroundColor ?? theme.dialogTheme.backgroundColor,
      semanticLabel: semanticLabel,
      title: title,
      content: body,
      actions: actions,
      titlePadding: titlePadding,
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      insetPadding: insetPadding,
    );
  }
}
