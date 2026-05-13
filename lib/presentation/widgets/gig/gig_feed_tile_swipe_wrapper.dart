import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/gig_hub_feeds_refresh_notifier.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/utils/destructive_action_flow.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";

/// Leading swipe (finger moves left) to remove **your** gig from a feed.
///
/// Mirrors [MessagesInboxScreen] archive swipe: [DismissDirection.endToStart],
/// stepped haptics, then [CommonConfirmationDialogs.showDeleteConfirmation]
/// before [DestructiveActionFlow.runDestructive] performs the API, gig-hub
/// refresh notification, and success toast.
class GigFeedTileSwipeWrapper extends StatefulWidget {
  const GigFeedTileSwipeWrapper({
    required this.entityId,
    required this.child,
    required this.enabled,
    required this.borderRadius,
    required this.dismissKeyPrefix,
    required this.confirmTitleKey,
    required this.confirmMessageKey,
    required this.successMessageKey,
    required this.errorMessageKey,
    required this.onConfirmDelete,
    required this.onRemovedFromList,
    this.notifyGigHubFeedsOnDelete = true,
    super.key,
  });

  final int entityId;
  final Widget child;
  final bool enabled;
  final BorderRadius borderRadius;
  final String dismissKeyPrefix;
  final String confirmTitleKey;
  final String confirmMessageKey;
  final String successMessageKey;
  final String errorMessageKey;
  final Future<void> Function(IGigService service) onConfirmDelete;
  final VoidCallback onRemovedFromList;

  /// When true, a successful delete tells [GigHubScreen] (embedded tab) to
  /// refetch. Disable on the hub itself — it already drops the row via
  /// [onRemovedFromList].
  final bool notifyGigHubFeedsOnDelete;

  @override
  State<GigFeedTileSwipeWrapper> createState() =>
      _GigFeedTileSwipeWrapperState();
}

class _GigFeedTileSwipeWrapperState extends State<GigFeedTileSwipeWrapper> {
  int _hapticStep = 0;

  @override
  Widget build(BuildContext context) {
    // [Dismissible] does not force cross-axis expansion; without this, tiles
    // shrink to intrinsic width while the list still has horizontal slack.
    final expandedChild = SizedBox(
      width: double.infinity,
      child: widget.child,
    );

    if (!widget.enabled) {
      return expandedChild;
    }

    final scheme = Theme.of(context).colorScheme;
    final ts = ThemeState();
    final swipeFgColor = ts.isBlueTheme ? Colors.white : scheme.primary;
    final swipeBgColor = ts.isBlueTheme
        ? Colors.white.withValues(alpha: 0.14)
        : scheme.primary.withValues(alpha: 0.18);

    return Dismissible(
      key: ValueKey("${widget.dismissKeyPrefix}-${widget.entityId}"),
      direction: DismissDirection.endToStart,
      onUpdate: (details) {
        const steps = 7;
        final currentStep = (details.progress * steps).floor();
        if (currentStep > _hapticStep) {
          for (var i = _hapticStep; i < currentStep; i++) {
            HapticFeedbackUtils.selectionClick();
          }
          _hapticStep = currentStep;
        } else if (currentStep <= 0 && _hapticStep != 0) {
          _hapticStep = 0;
        }
      },
      confirmDismiss: (_) async {
        final confirmed = await CommonConfirmationDialogs.showDeleteConfirmation(
          context: context,
          titleKey: widget.confirmTitleKey,
          messageKey: widget.confirmMessageKey,
        );
        if (confirmed != true || !context.mounted) {
          return false;
        }
        final ok = await DestructiveActionFlow.runDestructive(
          context: context,
          errorToastKey: widget.errorMessageKey,
          action: () async {
            await widget.onConfirmDelete(getIt<IGigService>());
            if (!context.mounted) return;
            if (widget.notifyGigHubFeedsOnDelete) {
              getIt<GigHubFeedsRefreshNotifier>().requestRefresh();
            }
            ToastReporting.successKey(context, widget.successMessageKey);
          },
        );
        return ok;
      },
      onDismissed: (_) {
        _hapticStep = 0;
        widget.onRemovedFromList();
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        decoration: BoxDecoration(
          color: swipeBgColor,
          borderRadius: widget.borderRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeIcon(Icons.delete_outline_rounded, color: swipeFgColor),
            const SizedBox(width: 8),
            Text(
              L10n.get("delete"),
              style: TextStyle(
                color: swipeFgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: expandedChild,
    );
  }
}
