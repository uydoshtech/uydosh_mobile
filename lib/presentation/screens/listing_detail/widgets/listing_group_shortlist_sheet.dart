import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_search_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_budget_fit_chip.dart";
import "package:uy_dosh/presentation/utils/conversation_entry_flow.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

Future<void> showListingGroupShortlistSheet({
  required BuildContext context,
  required int groupListingId,
  required bool isOwner,
  ListingDetail? groupListingDetail,
  VoidCallback? onChanged,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return _ListingGroupShortlistSheet(
        groupListingId: groupListingId,
        isOwner: isOwner,
        groupListingDetail: groupListingDetail,
        onChanged: onChanged,
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

class _ListingGroupShortlistSheetState extends State<_ListingGroupShortlistSheet> {
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
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ListingDetailScreen(
          listingId: row.listing.id,
          groupHousingContextListingId: widget.groupListingId,
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    final groupDetail = widget.groupListingDetail;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.82;

    return SafeArea(
      child: SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
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
                                ? GroupHousingBudgetFit.unknown
                                : GroupHousingBudgetFitHelper.evaluateListing(
                                    groupListing: groupDetail,
                                    housingListing: row.listing,
                                  );
                            final priceLabel =
                                PriceRangeHelper.formatStoredListingPrice(
                              storedPrice: row.listing.price,
                              listingTypeCode: row.listing.listingType?.code ??
                                  "roommate_needed",
                              minPrice: row.listing.minPrice,
                              maxPrice: row.listing.maxPrice,
                            );
                            final isRemoving = _removingId == row.listing.id;

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                row.listing.title,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(priceLabel),
                                              if (row.item.savedByName !=
                                                  null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  L10n.getWithParams(
                                                    "group_shortlist_saved_by",
                                                    params: {
                                                      "name":
                                                          row.item.savedByName!,
                                                    },
                                                  ),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        GroupBudgetFitChip(fit: fit),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        TextButtonThemed(
                                          onPressed: isRemoving
                                              ? null
                                              : () => _openListing(row),
                                          child: Text(
                                            L10n.get("group_shortlist_open"),
                                          ),
                                        ),
                                        if (widget.isOwner) ...[
                                          const SizedBox(width: 8),
                                          TextButtonThemed(
                                            onPressed: isRemoving
                                                ? null
                                                : () => _contactLandlord(row),
                                            child: Text(
                                              L10n.get(
                                                "group_shortlist_contact_landlord",
                                              ),
                                            ),
                                          ),
                                        ],
                                        const Spacer(),
                                        IconButton(
                                          onPressed: isRemoving
                                              ? null
                                              : () {
                                                  HapticFeedbackUtils.impact();
                                                  _remove(row);
                                                },
                                          icon: isRemoving
                                              ? const SizedBox(
                                                  width: 18,
                                                  height: 18,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
      ),
    );
  }
}

class _ShortlistRow {
  const _ShortlistRow({required this.item, required this.listing});

  final ListingGroupShortlistItem item;
  final Listing listing;
}
