import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";

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

  /// Matches [TextButtonThemed] actions; applied on labels so merged
  /// [ButtonStyle] on the destructive action cannot pick a different theme text style.
  static const TextStyle _actionLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final titleTextColor = isDark ? theme.colorScheme.onSurface : Colors.black;
    final contentTextColor =
        isDark ? theme.colorScheme.onSurfaceVariant : Colors.black;
    const bullet = "•";
    final baseMessage = L10n.get("unsaved_changes_message");
    final contentText = changedFieldLabels.isEmpty
        ? baseMessage
        : "$baseMessage\n\n${L10n.get("changed_fields")}:\n"
            "$bullet ${changedFieldLabels.join("\n$bullet ")}";

    return UydoshGlassDialog(
      title: Text(
        L10n.get("unsaved_changes_title"),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: titleTextColor,
        ),
      ),
      content: Text(
        contentText,
        style: TextStyle(
          fontSize: 16,
          color: contentTextColor,
        ),
      ),
      actions: [
        TextButtonThemed(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(L10n.get("keep_editing"), style: _actionLabelStyle),
        ),
        TextButtonThemed(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            textStyle: _actionLabelStyle,
          ),
          child:
              Text(L10n.get("leave_without_saving"), style: _actionLabelStyle),
        ),
      ],
    );
  }
}
