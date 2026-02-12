import 'package:flutter/material.dart';
import 'package:uy_dosh/base/state/theme_state.dart';
import '../language_switcher.dart';

/// A reusable confirmation dialog that follows the app's theme guidelines
/// and provides consistent styling across all confirmation dialogs
class ConfirmationDialog extends StatelessWidget {
  final String titleKey;
  final String messageKey;
  final String confirmButtonKey;
  final String cancelButtonKey;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmButtonColor;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.titleKey,
    required this.messageKey,
    required this.confirmButtonKey,
    required this.cancelButtonKey,
    this.onConfirm,
    this.onCancel,
    this.confirmButtonColor,
    this.isDestructive = false,
  });

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
      builder: (BuildContext context) {
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
    final themeState = ThemeState();
    final isBlueTheme = themeState.isBlueTheme;
    final baseCancelTextColor = isBlueTheme ? Colors.white : Colors.black;
    final baseConfirmTextColor = isBlueTheme
        ? Colors.red
        : confirmButtonColor ??
            (isDestructive
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary);
    final cancelTextColor = baseCancelTextColor;
    final confirmTextColor = baseConfirmTextColor;

    return AlertDialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      title: Text(
        LanguageAwareStringHelper.getCurrent(context, titleKey),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      content: Text(
        LanguageAwareStringHelper.getCurrent(context, messageKey),
        style: TextStyle(
          fontSize: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          style: TextButton.styleFrom(foregroundColor: cancelTextColor),
          child: Text(
            LanguageAwareStringHelper.getCurrent(context, cancelButtonKey),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        // Confirm button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          style: TextButton.styleFrom(foregroundColor: confirmTextColor),
          child: Text(
            LanguageAwareStringHelper.getCurrent(context, confirmButtonKey),
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
}
