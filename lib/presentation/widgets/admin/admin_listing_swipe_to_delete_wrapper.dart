import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/utils/destructive_action_flow.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Swipe-left (leading, [DismissDirection.endToStart]) to permanently delete
/// a listing from an admin listing list, gated by a confirmation dialog.
///
/// Mirrors [GigFeedTileSwipeWrapper]'s haptics/confirm/destructive-flow
/// pattern but targets [IListingService.deleteListing] directly, since admin
/// screens don't need the extra gig-hub refresh notification.
class AdminListingSwipeToDeleteWrapper extends StatefulWidget {
  const AdminListingSwipeToDeleteWrapper({
    required this.listingId,
    required this.child,
    required this.onDeleted,
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final int listingId;
  final Widget child;
  final BorderRadius borderRadius;

  /// Called after the listing has been deleted server-side, so the caller can
  /// drop it from its local state.
  final VoidCallback onDeleted;

  @override
  State<AdminListingSwipeToDeleteWrapper> createState() =>
      _AdminListingSwipeToDeleteWrapperState();
}

class _AdminListingSwipeToDeleteWrapperState
    extends State<AdminListingSwipeToDeleteWrapper> {
  int _hapticStep = 0;

  @override
  Widget build(BuildContext context) {
    final expandedChild = SizedBox(width: double.infinity, child: widget.child);

    final ts = ThemeState();
    final swipeFgColor = ts.isBlueTheme ? Colors.white : AppColors.error;
    final swipeBgColor = ts.isBlueTheme
        ? AppColors.error.withValues(alpha: 0.38)
        : AppColors.error.withValues(alpha: 0.2);

    return Dismissible(
      key: ValueKey("admin-listing-swipe-delete-${widget.listingId}"),
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
          titleKey: "delete_listing",
          messageKey: "delete_listing_confirmation",
        );
        if (confirmed != true || !context.mounted) {
          return false;
        }
        return DestructiveActionFlow.runDestructive(
          context: context,
          errorToastKey: "delete_listing_error",
          action: () async {
            await getIt<IListingService>().deleteListing(widget.listingId);
          },
        );
      },
      onDismissed: (_) {
        _hapticStep = 0;
        widget.onDeleted();
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
              style: TextStyle(color: swipeFgColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      child: expandedChild,
    );
  }
}
