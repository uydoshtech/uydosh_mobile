import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Shortcuts around [ToastTheme] with [BuildContext.mounted] guards and
/// [L10n.get] helpers so screens avoid repeating try/catch + toast shapes.
abstract final class ToastReporting {
  static void successKey(
    BuildContext context,
    String messageKey, {
    IconData? leadingIcon,
    bool playSound = true,
  }) {
    if (!context.mounted) return;
    ToastTheme.showSuccess(
      context,
      message: L10n.get(messageKey),
      leadingIcon: leadingIcon,
      playSound: playSound,
    );
  }

  static void errorKey(
    BuildContext context,
    String messageKey, {
    bool playSound = true,
    bool useRollingAnimation = true,
  }) {
    if (!context.mounted) return;
    ToastTheme.showError(
      context,
      message: L10n.get(messageKey),
      playSound: playSound,
      useRollingAnimation: useRollingAnimation,
    );
  }

  static void warningKey(BuildContext context, String messageKey) {
    if (!context.mounted) return;
    ToastTheme.showWarning(context, message: L10n.get(messageKey));
  }

  static void infoKey(BuildContext context, String messageKey) {
    if (!context.mounted) return;
    ToastTheme.showInfo(context, message: L10n.get(messageKey));
  }

  static void successMessage(
    BuildContext context,
    String message, {
    IconData? leadingIcon,
    bool playSound = true,
  }) {
    if (!context.mounted) return;
    ToastTheme.showSuccess(
      context,
      message: message,
      leadingIcon: leadingIcon,
      playSound: playSound,
    );
  }

  static void errorMessage(
    BuildContext context,
    String message, {
    bool playSound = true,
    bool useRollingAnimation = true,
  }) {
    if (!context.mounted) return;
    ToastTheme.showError(
      context,
      message: message,
      playSound: playSound,
      useRollingAnimation: useRollingAnimation,
    );
  }

  static void infoMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ToastTheme.showInfo(context, message: message);
  }

  /// Runs [operation]; on failure logs and shows an error toast from [errorMessageKey].
  static Future<T?> runAsync<T>(
    BuildContext context,
    Future<T> Function() operation, {
    required String errorMessageKey,
  }) async {
    try {
      return await operation();
    } catch (e, st) {
      logger.d("ToastReporting.runAsync failed: $e\n$st");
      errorKey(context, errorMessageKey);
      return null;
    }
  }
}
