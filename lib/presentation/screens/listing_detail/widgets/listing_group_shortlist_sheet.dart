import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/domain/utils/group_housing_listing_fit.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_search_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_shortlist_item_card.dart";
import "package:uy_dosh/presentation/utils/conversation_entry_flow.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";

Future<void> showListingGroupShortlistSheet({
  required BuildContext context,
  required int groupListingId,
  required bool isOwner,
  ListingDetail? groupListingDetail,
  VoidCallback? onChanged,
}) async {
  await showAppBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 12),
        child: GlassBottomSheetSurface(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            type: MaterialType.transparency,
            child: _ListingGroupShortlistSheet(
              groupListingId: groupListingId,
              isOwner: isOwner,
              groupListingDetail: groupListingDetail,
              onChanged: onChanged,
            ),
          ),
        ),
      );
    },
  );
}

class _ListingGroupShortlistSheet extends StatefulWidget {
  const _ListingGroupShortlistSheet({
    required this.groupListingId,
    required this.isOwner,
    this.groupListingDetail,
    this.onChanged,
  });

  final int groupListingId;
  final bool isOwner;
  final ListingDetail? groupListingDetail;
  final VoidCallback? onChanged;

  @override
  State<_ListingGroupShortlistSheet> createState() =>
      _ListingGroupShortlistSheetState();
}

class _ListingGroupShortlistSheetState
    extends State<_ListingGroupShortlistSheet> {
  var _loading = true;
  var _removingId = 0;
  List<_ShortlistRow> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await getIt<IListingGroupService>().listShortlist(
        groupListingId: widget.groupListingId,
      );
      final rows = <_ShortlistRow>[];
      for (final item in items) {
        final json = item.listingJson;
        if (json == null) continue;
        try {
          rows.add(
            _ShortlistRow(
              item: item,
              listing: Listing.fromJson(json),
            ),
          );
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _loading = false;
      });
      GroupShortlistState().setShortlistCountForGroup(
        widget.groupListingId,
        rows.length,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ToastTheme.showError(
        context,
        message: ErrorMessageHelper.sanitizeErrorMessage(e, context: context),
      );
    }
  }

  Future<void> _confirmRemove(_ShortlistRow row) async {
    if (_removingId != 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
          title: Text(
            L10n.get("group_shortlist_remove_title"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          content: Text(
            L10n.getWithParams(
              "group_shortlist_remove_message",
              params: {"title": row.listing.title},
            ),
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButtonThemed(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
              child: Text(
                L10n.get("cancel"),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            TextButtonThemed(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              child: Text(
                L10n.get("group_shortlist_remove_confirm"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    await _remove(row);
  }

  Future<void> _remove(_ShortlistRow row) async {
    if (_removingId != 0) return;
    setState(() => _removingId = row.listing.id);
    try {
      await getIt<IListingGroupService>().removeFromShortlist(
        groupListingId: widget.groupListingId,
        housingListingId: row.listing.id,
      );
      GroupShortlistState().seedShortlisted(
        groupListingId: widget.groupListingId,
        housingListingId: row.listing.id,
        isShortlisted: false,
      );
      GroupShortlistState().refreshCount(widget.groupListingId);
      if (!mounted) return;
      setState(() {
        _rows = _rows.where((r) => r.listing.id != row.listing.id).toList();
        _removingId = 0;
      });
      widget.onChanged?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _removingId = 0);
      ToastTheme.showError(
        context,
        message: ErrorMessageHelper.sanitizeErrorMessage(e, context: context),
      );
    }
  }

  Future<void> _openListing(_ShortlistRow row) async {
    Navigator.of(context).pop();
    await context.pushListingDetail(
      row.listing.id,
      groupHousingContextListingId: widget.groupListingId,
    );
  }

  Future<void> _contactLandlord(_ShortlistRow row) async {
    try {
      final detail = await getIt<IListingService>().getListingDetail(
        row.listing.id,
      );
      if (!context.mounted) return;
      await ConversationEntryFlow.openListingThread(
        context: context,
        listingDetail: detail,
        analyticsListingRouteId: detail.id,
        pushNewThread: (conversation) async {
          await ConversationEntryFlow.pushChatShell(
            context,
            conversationId: conversation.id,
            chatScreenChild: ChatScreen(
              conversationId: conversation.id,
              listingId: detail.id,
              listingTypeId: detail.listingTypeId,
              listingOwnerUserId: detail.user.id,
              listingTitle: detail.title,
            ),
          );
        },
        pushExistingThread: (summary, currentUserId) async {
          await ConversationEntryFlow.pushChatShell(
            context,
            conversationId: summary.id,
            chatScreenChild: ChatScreen(
              conversationId: summary.id,
              listingId: detail.id,
              listingTypeId: detail.listingTypeId,
              listingOwnerUserId: detail.user.id,
              listingTitle: detail.title,
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ToastTheme.showError(
        context,
        message: ErrorMessageHelper.sanitizeErrorMessage(e, context: context),
      );
    }
  }

  Future<void> _discussInGroup(_ShortlistRow row) async {
    if (!AuthFlow.requireAuth(context)) return;
    final groupDetail = widget.groupListingDetail;
    if (groupDetail == null) return;
    final conversationId = groupDetail.groupContext?.groupConversationId;
    if (conversationId == null) return;

    final fit = GroupHousingListingFit.evaluate(
      groupListing: groupDetail,
      housingListing: row.listing,
    );
    String? ownerName;
    String? ownerAvatarUrl;
    try {
      final ownerProfile = await getIt<IUserProfileService>().getUserProfile(
        row.listing.userId,
      );
      ownerName = ownerProfile.name;
      ownerAvatarUrl = ownerProfile.avatarUrl;
    } catch (_) {}
    final composerText = GroupShortlistDiscussMessage.buildContent(
      listing: row.listing,
      fit: fit,
      ownerName: ownerName,
      ownerAvatarUrl: ownerAvatarUrl,
    );

    Navigator.of(context).pop();
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: ChatScreen.routeName(conversationId)),
        builder: (_) => ChatScreen(
          conversationId: conversationId,
          listingId: groupDetail.id,
          listingTypeId: groupDetail.listingTypeId,
          listingTitle: groupDetail.title,
          conversationContextType: "listing_group",
          initialComposerText: composerText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupDetail = widget.groupListingDetail;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: maxHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              GroupHousingFlow.savedListingsLabel(_rows.length),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: HouseLoadingIndicator())
                : _rows.isEmpty
                    ? UydoshEmptyColumn(
                        title: L10n.get("group_shortlist_empty_title"),
                        subtitle: L10n.get("group_shortlist_empty_subtitle"),
                        action: FilledButton.icon(
                          onPressed: groupDetail == null
                              ? null
                              : () {
                                  Navigator.of(context).pop();
                                  GroupHousingFlow.openSearch(
                                    context: context,
                                    groupListingDetail: groupDetail,
                                  );
                                },
                          icon: const Icon(Icons.search),
                          label: Text(L10n.get("group_find_housing")),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _rows.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final row = _rows[index];
                          final fit = groupDetail == null
                              ? const GroupHousingListingFit(
                                  budget: GroupHousingBudgetFit.unknown,
                                  location: GroupHousingLocationFit.unknown,
                                )
                              : GroupHousingListingFit.evaluate(
                                  groupListing: groupDetail,
                                  housingListing: row.listing,
                                );
                          final isRemoving = _removingId == row.listing.id;
                          final hasGroupChat =
                              groupDetail?.groupContext?.hasGroupChat == true;

                          return GroupShortlistItemCard(
                            item: row.item,
                            listing: row.listing,
                            fit: fit,
                            groupListingDetail: groupDetail,
                            isOwner: widget.isOwner,
                            isRemoving: isRemoving,
                            onOpen: () => _openListing(row),
                            onRemove: () => _confirmRemove(row),
                            onContactLandlord: widget.isOwner
                                ? () => _contactLandlord(row)
                                : null,
                            onDiscussInGroup: hasGroupChat
                                ? () => _discussInGroup(row)
                                : null,
                          );
                        },
                      ),
          ),
          if (!_loading && _rows.isNotEmpty && groupDetail != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => GroupHousingSearchScreen(
                        groupListingDetail: groupDetail,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.search),
                label: Text(L10n.get("group_find_housing")),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShortlistRow {
  const _ShortlistRow({required this.item, required this.listing});

  final ListingGroupShortlistItem item;
  final Listing listing;
}
