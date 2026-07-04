import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/utils/destructive_action_flow.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Owner-only "Renew" / "Delete" actions for a row on the "My Listings"
/// screen. Deliberately kept out of [ListingTile] (used unmodified on
/// search/favorites/admin screens) and rendered as a small adjacent row
/// instead.
class UserListingOwnerActionsRow extends StatefulWidget {
  const UserListingOwnerActionsRow({
    required this.listing,
    required this.onRenewed,
    required this.onDeleted,
    super.key,
  });

  final Listing listing;

  /// Called with the row's updated listing after a renew attempt — either
  /// the freshly-renewed listing, or the same listing with a synced
  /// [Listing.nextRenewalAt] when the server reports an active cooldown.
  final ValueChanged<Listing> onRenewed;

  /// Called after the listing has been deleted successfully.
  final VoidCallback onDeleted;

  @override
  State<UserListingOwnerActionsRow> createState() =>
      _UserListingOwnerActionsRowState();
}

class _UserListingOwnerActionsRowState
    extends State<UserListingOwnerActionsRow> {
  bool _isRenewing = false;
  bool _isDeleting = false;

  /// Whole days remaining until renewal is available again, rounded up to at
  /// least 1 whenever the cooldown is still active. Null once renewal is
  /// available (i.e. [Listing.nextRenewalAt] is null or already in the past).
  int? get _daysRemaining {
    final raw = widget.listing.nextRenewalAt;
    if (raw == null || raw.isEmpty) return null;
    final nextRenewalAt = DateTime.tryParse(raw);
    if (nextRenewalAt == null) return null;
    final diff = nextRenewalAt.difference(DateTime.now());
    if (!diff.isNegative && diff > Duration.zero) {
      final days = (diff.inHours / 24).ceil();
      return days < 1 ? 1 : days;
    }
    return null;
  }

  Future<void> _handleRenew() async {
    if (_isRenewing || _daysRemaining != null) return;
    setState(() => _isRenewing = true);

    final result = await getIt<IListingService>().renewListing(
      widget.listing.id,
    );

    if (!mounted) return;
    setState(() => _isRenewing = false);

    if (result.isSuccess) {
      ToastReporting.successKey(context, "renew_listing_success");
      widget.onRenewed(result.listing ?? widget.listing);
      return;
    }

    ToastReporting.errorKey(context, "renew_listing_error");
    if (result.isCooldown && result.nextRenewalAt != null) {
      widget.onRenewed(
        widget.listing.copyWith(nextRenewalAt: result.nextRenewalAt),
      );
    }
  }

  Future<void> _handleDelete() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    final deleted = await DestructiveActionFlow.runAfterDeleteConfirmed(
      context: context,
      titleKey: "delete_listing",
      messageKey: "delete_listing_confirmation",
      errorToastKey: "delete_listing_error",
      onConfirmed: () async {
        final success = await getIt<IListingService>().deleteListing(
          widget.listing.id,
        );
        if (!success) throw Exception("Delete operation failed");
      },
    );

    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (deleted) {
      ToastReporting.successKey(context, "delete_listing_success");
      HomeRefreshState().markForRefresh();
      widget.onDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final daysRemaining = _daysRemaining;
    final renewEnabled = !_isRenewing && daysRemaining == null;

    return Row(
      children: [
        ThreeDPillButton(
          onPressed: renewEnabled ? _handleRenew : null,
          child: _isRenewing
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onSurface,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThemeIcon(
                      CupertinoIcons.arrow_2_circlepath,
                      size: 16,
                      color: scheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      daysRemaining != null
                          ? L10n.getWithParams(
                              "renew_in_days",
                              params: {"days": daysRemaining.toString()},
                            )
                          : L10n.get("renew_listing"),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(width: 10),
        ThreeDPillButton(
          onPressed: _isDeleting ? null : _handleDelete,
          child: _isDeleting
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.error,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ThemeIcon(
                      CupertinoIcons.trash,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      L10n.get("delete_listing"),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
