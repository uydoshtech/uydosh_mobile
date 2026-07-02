import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_duplicate_hint.dart";
import "package:uy_dosh/domain/services/admin_telegram_listing_groups_service.dart";
import "package:uy_dosh/presentation/screens/admin/listing_duplicate_hint_ui.dart";
import "package:uy_dosh/presentation/widgets/admin/admin_listing_swipe_to_delete_wrapper.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

/// A bordered card grouping every listing in one possible-duplicate cluster,
/// with a header (member count + confidence) and a "Merge" action that lets
/// an admin pick which member survives.
class DuplicateGroupCard extends StatelessWidget {
  const DuplicateGroupCard({
    required this.members,
    required this.hints,
    required this.onMemberDeleted,
    required this.onMerged,
    super.key,
  });

  final List<Listing> members;
  final Map<int, ListingDuplicateHint?> hints;
  final ValueChanged<int> onMemberDeleted;
  final ValueChanged<TelegramGroupMergeResult> onMerged;

  bool get _isHighConfidence =>
      members.any((m) => hints[m.id]?.isHigh == true);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _isHighConfidence ? scheme.error : scheme.tertiary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.4),
        color: accent.withValues(alpha: 0.06),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, accent),
          const SizedBox(height: 8),
          for (var i = 0; i < members.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _buildMember(context, members[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accent) {
    return Row(
      children: [
        ThemeIcon(Icons.content_copy_rounded, color: accent, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            L10n.getWithParams(
              "admin_telegram_listing_groups_duplicate_group_title",
              params: {"count": "${members.length}"},
            ),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ),
        TextButtonThemed(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          onPressed: () => _showMergePicker(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeIcon(Icons.call_merge_rounded, size: 18, color: accent),
              const SizedBox(width: 6),
              Text(
                L10n.get("admin_telegram_listing_groups_merge_button"),
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMember(BuildContext context, Listing listing) {
    final hint = hints[listing.id];
    DateTime created;
    try {
      created = DateTime.parse(listing.createdAt).toLocal();
    } catch (_) {
      created = DateTime.now();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            children: [
              Text(
                AppDateUtils.formatDateWithMonthDay(context, created),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (hint != null) ...[
                const SizedBox(width: 8),
                Flexible(child: listingDuplicateHintBadge(context, hint)),
              ],
            ],
          ),
        ),
        AdminListingSwipeToDeleteWrapper(
          listingId: listing.id,
          onDeleted: () => onMemberDeleted(listing.id),
          child: ListingTile(
            key: ValueKey(listing.id),
            listing: listing,
            trailingAction: _buildIdBadge(context, listing.id),
          ),
        ),
      ],
    );
  }

  /// Small "#id" tag shown in the top-right corner of each candidate tile
  /// (both in the group list and in the merge picker), so an admin can tell
  /// which listing a given "Keep #id" button below actually refers to.
  Widget _buildIdBadge(BuildContext context, int id) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "#$id",
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Future<void> _showMergePicker(BuildContext context) async {
    final scheme = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text(
                    L10n.get("admin_telegram_listing_groups_merge_picker_title"),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    L10n.getWithParams(
                      "admin_telegram_listing_groups_merge_picker_message",
                      params: {"count": "${members.length - 1}"},
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final member in members) ...[
                    ListingTile(
                      key: ValueKey("pick-${member.id}"),
                      listing: member,
                      trailingAction: _buildIdBadge(context, member.id),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButtonThemed(
                        style: TextButton.styleFrom(
                          backgroundColor: scheme.primaryContainer,
                        ),
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          _confirmAndMerge(context, keepListingId: member.id);
                        },
                        child: Text(
                          L10n.getWithParams(
                            "admin_telegram_listing_groups_merge_keep_button",
                            params: {"id": "${member.id}"},
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmAndMerge(
    BuildContext context, {
    required int keepListingId,
  }) async {
    final confirmed = await _showMergeConfirmationDialog(
      context,
      keepListingId: keepListingId,
      deleteCount: members.length - 1,
    );
    if (confirmed != true || !context.mounted) return;

    try {
      final result = await getIt<IAdminTelegramListingGroupsService>()
          .mergeListings(
        listingIds: members.map((m) => m.id).toList(),
        keepListingId: keepListingId,
      );
      if (!context.mounted) return;
      final expectedDeleteCount = members.length - 1;
      if (result.deletedIds.length < expectedDeleteCount) {
        // The server reports 200 even when some listings couldn't be
        // deleted (e.g. a stray FK it doesn't clean up yet), so a blanket
        // "success" toast here would be misleading — tell the admin exactly
        // how many actually went away instead.
        ToastTheme.showWarning(
          context,
          message: L10n.getWithParams(
            "admin_telegram_listing_groups_merge_partial",
            params: {
              "deleted": "${result.deletedIds.length}",
              "total": "$expectedDeleteCount",
            },
          ),
        );
      } else {
        ToastReporting.successKey(
          context,
          "admin_telegram_listing_groups_merge_success",
        );
      }
      onMerged(result);
    } catch (_) {
      if (!context.mounted) return;
      ToastReporting.errorKey(
        context,
        "admin_telegram_listing_groups_merge_error",
      );
    }
  }

  Future<bool?> _showMergeConfirmationDialog(
    BuildContext context, {
    required int keepListingId,
    required int deleteCount,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return UydoshGlassDialog(
          title: Text(
            L10n.get("admin_telegram_listing_groups_merge_confirm_title"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          content: Text(
            L10n.getWithParams(
              "admin_telegram_listing_groups_merge_confirm_message",
              params: {"id": "$keepListingId", "count": "$deleteCount"},
            ),
          ),
          actions: [
            TextButtonThemed(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(L10n.get("cancel")),
            ),
            TextButtonThemed(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              child: Text(
                L10n.get("admin_telegram_listing_groups_merge_button"),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }
}
