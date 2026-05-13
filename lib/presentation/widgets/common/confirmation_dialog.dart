import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";

/// A reusable confirmation dialog that follows the app's theme guidelines
/// and provides consistent styling across all confirmation dialogs
class ConfirmationDialog extends StatelessWidget {

  const ConfirmationDialog({
    required this.titleKey, required this.messageKey, required this.confirmButtonKey, required this.cancelButtonKey, super.key,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.isDestructive = false,
  });
  final String titleKey;
  final String messageKey;
  final String confirmButtonKey;
  final String cancelButtonKey;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final bool isDestructive;

  /// Show a confirmation dialog with the given parameters
  static Future<bool?> show({
    required BuildContext context,
    required String titleKey,
    required String messageKey,
    required String confirmButtonKey,
    required String cancelButtonKey,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmButtonColor,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return ConfirmationDialog(
          titleKey: titleKey,
          messageKey: messageKey,
          confirmButtonKey: confirmButtonKey,
          cancelButtonKey: cancelButtonKey,
          onConfirm: onConfirm,
          onCancel: onCancel,
          confirmButtonColor: confirmButtonColor,
          isDestructive: isDestructive,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cancelTextColor = scheme.onSurface;
    final confirmTextColor = confirmButtonColor ??
        (isDestructive ? scheme.error : scheme.onSurface);

    return AlertDialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      title: Text(
        L10n.get(titleKey),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: Text(
        L10n.get(messageKey),
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        TextButtonThemed(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          style: TextButton.styleFrom(foregroundColor: cancelTextColor),
          child: Text(
            L10n.get(cancelButtonKey),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TextButtonThemed(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: TextButton.styleFrom(foregroundColor: confirmTextColor),
          child: Text(
            L10n.get(confirmButtonKey),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Predefined confirmation dialogs for common use cases
class CommonConfirmationDialogs {
  /// Show a delete confirmation dialog
  static Future<bool?> showDeleteConfirmation({
    required BuildContext context,
    required String titleKey,
    required String messageKey,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog.show(
      context: context,
      titleKey: titleKey,
      messageKey: messageKey,
      confirmButtonKey: "delete",
      cancelButtonKey: "cancel",
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: true,
    );
  }

  /// Show a logout confirmation dialog
  static Future<bool?> showLogoutConfirmation({
    required BuildContext context,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog.show(
      context: context,
      titleKey: "logout_confirmation",
      messageKey: "logout_description",
      confirmButtonKey: "logout",
      cancelButtonKey: "cancel",
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: true,
    );
  }

  /// Show a generic confirmation dialog
  static Future<bool?> showGenericConfirmation({
    required BuildContext context,
    required String titleKey,
    required String messageKey,
    required String confirmButtonKey,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    return ConfirmationDialog.show(
      context: context,
      titleKey: titleKey,
      messageKey: messageKey,
      confirmButtonKey: confirmButtonKey,
      cancelButtonKey: "cancel",
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: isDestructive,
    );
  }

  /// Show delete account confirmation dialog
  static Future<bool?> showDeleteAccountConfirmation({
    required BuildContext context,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return ConfirmationDialog.show(
      context: context,
      titleKey: "delete_account",
      messageKey: "delete_account_confirmation",
      confirmButtonKey: "delete",
      cancelButtonKey: "cancel",
      onConfirm: onConfirm,
      onCancel: onCancel,
      isDestructive: true,
    );
  }
}
