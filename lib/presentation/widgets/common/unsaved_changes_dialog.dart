import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// Confirmation dialog shown when the user tries to leave an edit form with
/// pending changes. Displays a localized title/message and a bullet list of
/// changed field labels when provided.
///
/// Returns `true` if the user chose to discard changes (leave) and `false`
/// (or `null` if dismissed) if they want to keep editing.
class UnsavedChangesDialog {
  const UnsavedChangesDialog._();

  /// Shows the unsaved-changes confirmation dialog.
  ///
  /// Pass [changedFieldLabels] to render a localized "changed fields" bullet
  /// list under the message; pass an empty list to show only the generic
  /// message.
  static Future<bool> show(
    BuildContext context, {
    List<String> changedFieldLabels = const <String>[],
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _UnsavedChangesDialog(
        changedFieldLabels: changedFieldLabels,
      ),
    );
    return result ?? false;
  }
}

class _UnsavedChangesDialog extends StatelessWidget {
  const _UnsavedChangesDialog({required this.changedFieldLabels});

  final List<String> changedFieldLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const bullet = "•";
    final baseMessage = L10n.get("unsaved_changes_message");
    final contentText = changedFieldLabels.isEmpty
        ? baseMessage
        : "$baseMessage\n\n${L10n.get("changed_fields")}:\n"
            "$bullet ${changedFieldLabels.join("\n$bullet ")}";

    return AlertDialog(
      backgroundColor: theme.dialogTheme.backgroundColor,
      title: Text(
        L10n.get("unsaved_changes_title"),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Text(
        contentText,
        style: TextStyle(
          fontSize: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(L10n.get("keep_editing")),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
          child: Text(L10n.get("leave_without_saving")),
        ),
      ],
    );
  }
}
