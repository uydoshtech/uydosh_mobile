import "package:flutter/widgets.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";

/// Shared wiring for destructive UX: confirmation (when needed), guarded work,
/// and a keyed error toast on failure.
///
/// Success feedback and refreshes stay in [onConfirmed] / [action] because
/// ordering varies (toast vs navigate vs [HomeRefreshState]).
abstract final class DestructiveActionFlow {
  /// Runs [CommonConfirmationDialogs.showDeleteConfirmation], then [onConfirmed].
  ///
  /// Returns `false` if the user cancels or [context] is unmounted after the
  /// dialog. Returns `true` if [onConfirmed] completes without throwing.
  static Future<bool> runAfterDeleteConfirmed({
    required BuildContext context,
    required String titleKey,
    required String messageKey,
    required String errorToastKey,
    required Future<void> Function() onConfirmed,
  }) async {
    final confirmed = await CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: titleKey,
      messageKey: messageKey,
    );
    if (confirmed != true || !context.mounted) return false;
    return runDestructive(
      context: context,
      errorToastKey: errorToastKey,
      action: onConfirmed,
    );
  }

  /// Runs [action] with logging + [errorToastKey] on failure (e.g. after swipe
  /// confirmation or another bespoke gate).
  static Future<bool> runDestructive({
    required BuildContext context,
    required String errorToastKey,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
      return true;
    } catch (e, st) {
      logger.d("DestructiveActionFlow: $e\n$st");
      if (context.mounted) {
        ToastReporting.errorKey(context, errorToastKey);
      }
      return false;
    }
  }
}
