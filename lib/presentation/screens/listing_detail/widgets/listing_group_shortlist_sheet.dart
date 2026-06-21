import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
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

String? _listingOwnerNameFromProfile(UserProfile profile) {
  final name = profile.name?.trim();
  if (name != null && name.isNotEmpty) return name;
  final telegram = profile.telegram?.trim();
  if (telegram != null && telegram.isNotEmpty) {
    return telegram.startsWith("@") ? telegram : "@$telegram";
  }
  return null;
}

String? _listingOwnerAvatarUrlFromProfile(UserProfile profile) {
  final avatar = profile.avatarUrl?.trim();
  if (avatar != null && avatar.isNotEmpty) return avatar;
  final telegramAvatar = profile.telegramAvatarUrl?.trim();
  if (telegramAvatar != null && telegramAvatar.isNotEmpty) {
    return telegramAvatar;
  }
  return null;
}

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
  final _pageController = PageController();
  var _currentPage = 0;
  int? _currentUserId;
  List<_ShortlistRow> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final currentUserId = await SessionManager.getUserId();
      final items = await getIt<IListingGroupService>().listShortlist(
        groupListingId: widget.groupListingId,
      );
      final rows = <_ShortlistRow>[];
      final ownerProfilesByUserId = <int, UserProfile>{};
      final userProfileService = getIt<IUserProfileService>();
      for (final item in items) {
        final json = item.listingJson;
        if (json == null) continue;
        try {
          final listing = Listing.fromJson(json);
          UserProfile? ownerProfile;
          try {
            ownerProfile = ownerProfilesByUserId[listing.userId] ??=
                await userProfileService.getUserProfile(listing.userId);
          } catch (_) {}
          rows.add(
            _ShortlistRow(
              item: item,
              listing: listing,
              ownerName: ownerProfile == null
                  ? null
                  : _listingOwnerNameFromProfile(ownerProfile),
              ownerAvatarUrl: ownerProfile == null
                  ? null
                  : _listingOwnerAvatarUrlFromProfile(ownerProfile),
            ),
          );
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _currentUserId = currentUserId;
        _rows = rows;
        _currentPage =
            rows.isEmpty ? 0 : _currentPage.clamp(0, rows.length - 1).toInt();
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

  Future<void> _editRating(_ShortlistRow row, int currentStars) async {
    final stars = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        var selected = currentStars.clamp(0, 5).toInt();
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final scheme = Theme.of(context).colorScheme;
            return AlertDialog(
              backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
              title: Text(
                L10n.get("group_shortlist_edit_rating_title"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  final filled = selected >= value;
                  return IconButton(
                    iconSize: 48,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 56,
                      height: 56,
                    ),
                    onPressed: () {
                      HapticFeedbackUtils.selectionClick();
                      setDialogState(() => selected = value);
                    },
                    icon: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled
                          ? AppColors.getThemeAwareWarningIconColor(context)
                          : scheme.onSurfaceVariant,
                    ),
                  );
                }),
              ),
              actions: [
                TextButtonThemed(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style:
                      TextButton.styleFrom(foregroundColor: scheme.onSurface),
                  child: Text(
                    L10n.get("cancel"),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                TextButtonThemed(
                  onPressed: selected <= 0
                      ? null
                      : () => Navigator.of(dialogContext).pop(selected),
                  child: Text(
                    L10n.get("done"),
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
      },
    );
    if (stars == null || stars == currentStars || !mounted) return;

    try {
      final rating = await getIt<IListingGroupService>().rateShortlistItem(
        groupListingId: widget.groupListingId,
        housingListingId: row.listing.id,
        stars: stars,
      );
      if (!mounted) return;
      setState(() {
        _rows = _rows
            .map(
              (candidate) => candidate.listing.id == row.listing.id
                  ? candidate.copyWith(
                      item: candidate.item.copyWith(rating: rating),
                    )
                  : candidate,
            )
            .toList();
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_shortlist_rating_updated"),
      );
      widget.onChanged?.call();
    } catch (e) {
      if (!mounted) return;
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
      final nextRows =
          _rows.where((r) => r.listing.id != row.listing.id).toList();
      final nextPage = nextRows.isEmpty
          ? 0
          : _currentPage.clamp(0, nextRows.length - 1).toInt();
      setState(() {
        _rows = nextRows;
        _currentPage = nextPage;
        _removingId = 0;
      });
      if (nextRows.isNotEmpty && _pageController.hasClients) {
        _pageController.jumpToPage(nextPage);
      }
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

  void _goToPage(int page) {
    if (_rows.isEmpty || page < 0 || page >= _rows.length) return;
    HapticFeedbackUtils.impact();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildShortlistNavigation(BuildContext context) {
    final canGoBack = _currentPage > 0;
    final canGoNext = _currentPage < _rows.length - 1;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          _ShortlistArrowButton(
            icon: Icons.chevron_left,
            tooltip: L10n.get("back"),
            onPressed: canGoBack ? () => _goToPage(_currentPage - 1) : null,
          ),
          Expanded(
            child: Text(
              "${_currentPage + 1} / ${_rows.length}",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          _ShortlistArrowButton(
            icon: Icons.chevron_right,
            tooltip: L10n.get("next"),
            onPressed: canGoNext ? () => _goToPage(_currentPage + 1) : null,
          ),
        ],
      ),
    );
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
    final maxHeight = MediaQuery.sizeOf(context).height * 0.64;
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
          if (!_loading && _rows.length > 1) _buildShortlistNavigation(context),
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
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: _rows.length,
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                        },
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

                          return SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: GroupShortlistItemCard(
                              item: row.item,
                              listing: row.listing,
                              fit: fit,
                              ownerName: row.ownerName,
                              ownerAvatarUrl: row.ownerAvatarUrl,
                              isOwner: widget.isOwner,
                              isRemoving: isRemoving,
                              currentUserId: _currentUserId,
                              onOpen: () => _openListing(row),
                              onRemove: () => _confirmRemove(row),
                              onRate: (stars) => _editRating(row, stars),
                              onContactLandlord: widget.isOwner
                                  ? () => _contactLandlord(row)
                                  : null,
                              onDiscussInGroup: hasGroupChat
                                  ? () => _discussInGroup(row)
                                  : null,
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
    );
  }
}

class _ShortlistArrowButton extends StatelessWidget {
  const _ShortlistArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 28),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(44),
        disabledForegroundColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.32),
      ),
    );
  }
}

class _ShortlistRow {
  const _ShortlistRow({
    required this.item,
    required this.listing,
    this.ownerName,
    this.ownerAvatarUrl,
  });

  final ListingGroupShortlistItem item;
  final Listing listing;
  final String? ownerName;
  final String? ownerAvatarUrl;

  _ShortlistRow copyWith({
    ListingGroupShortlistItem? item,
  }) {
    return _ShortlistRow(
      item: item ?? this.item,
      listing: listing,
      ownerName: ownerName,
      ownerAvatarUrl: ownerAvatarUrl,
    );
  }
}
