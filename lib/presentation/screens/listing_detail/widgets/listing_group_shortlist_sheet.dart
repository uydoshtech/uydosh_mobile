import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:dio/dio.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
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
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/domain/utils/group_housing_listing_fit.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_shortlist_item_card.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/listing_rating_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";

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

const _shortlistSheetTopChromeHeight = 70.0;
const _shortlistSheetNavigationHeight = 46.0;

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
        padding: EdgeInsets.only(bottom: bottomInset + 12),
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
  var _landlordInviteBusyListingId = 0;
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
    final currentReasons = _currentUserReasonCodes(row);
    final currentCategoryRatings = _currentUserCategoryRatings(row);
    final currentVerdict = _currentUserVerdict(row);
    final result = await showListingRatingDialog(
      context: context,
      currentStars: currentStars,
      initialReasonCodes: currentReasons,
      initialCategoryRatings: currentCategoryRatings,
      prefillMissingCategoryRatings: false,
    );
    if (result == null || !mounted) return;
    final stars = result.stars;
    final reasons = result.reasons;
    if (stars == currentStars &&
        _setsEqual(currentReasons, reasons.toSet()) &&
        _mapsEqual(currentCategoryRatings, result.categoryRatings) &&
        currentVerdict == result.verdict) {
      return;
    }

    try {
      final rating = await getIt<IListingGroupService>().rateShortlistItem(
        groupListingId: widget.groupListingId,
        housingListingId: row.listing.id,
        stars: stars,
        reasons: reasons,
        categoryRatings: result.categoryRatings,
        verdict: result.verdict,
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

  Set<String> _currentUserReasonCodes(_ShortlistRow row) {
    return {
      for (final participant in row.item.rating?.participants ??
          const <ListingGroupShortlistParticipantRating>[])
        if (participant.userId == _currentUserId) ...participant.reasons,
    };
  }

  Map<String, int> _currentUserCategoryRatings(_ShortlistRow row) {
    for (final participant in row.item.rating?.participants ??
        const <ListingGroupShortlistParticipantRating>[]) {
      if (participant.userId == _currentUserId) {
        return participant.categoryRatings;
      }
    }
    return const {};
  }

  String? _currentUserVerdict(_ShortlistRow row) {
    for (final participant in row.item.rating?.participants ??
        const <ListingGroupShortlistParticipantRating>[]) {
      if (participant.userId == _currentUserId) {
        return participant.verdict;
      }
    }
    return null;
  }

  bool _setsEqual(Set<String> left, Set<String> right) {
    return left.length == right.length && left.every(right.contains);
  }

  bool _mapsEqual(Map<String, int> left, Map<String, int> right) {
    return left.length == right.length &&
        left.entries.every((entry) => right[entry.key] == entry.value);
  }

  Future<void> _confirmRemove(_ShortlistRow row) async {
    if (_removingId != 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return UydoshGlassDialog(
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
    final theme = Theme.of(context);
    final controlColor = theme.brightness == Brightness.light
        ? Colors.black
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          _ShortlistArrowButton(
            icon: Icons.chevron_left,
            tooltip: L10n.get("back"),
            color: controlColor,
            onPressed: canGoBack ? () => _goToPage(_currentPage - 1) : null,
          ),
          Expanded(
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _rows.length,
                effect: WormEffect(
                  dotColor: controlColor,
                  activeDotColor: controlColor,
                  dotHeight: 7,
                  dotWidth: 7,
                  spacing: 6,
                  paintStyle: PaintingStyle.stroke,
                  strokeWidth: 1.2,
                ),
              ),
            ),
          ),
          _ShortlistArrowButton(
            icon: Icons.chevron_right,
            tooltip: L10n.get("next"),
            color: controlColor,
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
    if (_landlordInviteBusyListingId != 0) return;
    setState(() => _landlordInviteBusyListingId = row.listing.id);
    try {
      final result =
          await getIt<IListingGroupService>().inviteLandlordToGroupChat(
        groupListingId: widget.groupListingId,
        housingListingId: row.listing.id,
      );
      if (!context.mounted) return;
      if (result.inviteId != null) {
        setState(() {
          _rows = _rows
              .map(
                (candidate) => candidate.listing.id == row.listing.id
                    ? candidate.copyWith(
                        item: candidate.item.copyWith(
                          pendingLandlordInviteId: result.inviteId,
                        ),
                      )
                    : candidate,
              )
              .toList();
        });
      }
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_landlord_invite_sent"),
      );
      widget.onChanged?.call();
    } catch (e) {
      if (!context.mounted) return;
      ToastTheme.showError(
        context,
        message: _landlordInviteErrorMessage(e),
      );
    } finally {
      if (mounted) setState(() => _landlordInviteBusyListingId = 0);
    }
  }

  Future<void> _revokeLandlordInvite(_ShortlistRow row) async {
    final inviteId = row.item.pendingLandlordInviteId;
    if (inviteId == null || _landlordInviteBusyListingId != 0) return;
    setState(() => _landlordInviteBusyListingId = row.listing.id);
    try {
      await getIt<IListingGroupService>().cancelLandlordInvite(
        groupListingId: widget.groupListingId,
        inviteId: inviteId,
      );
      if (!context.mounted) return;
      setState(() {
        _rows = _rows
            .map(
              (candidate) => candidate.listing.id == row.listing.id
                  ? candidate.copyWith(
                      item: candidate.item.copyWith(
                        clearPendingLandlordInviteId: true,
                      ),
                    )
                  : candidate,
            )
            .toList();
      });
      ToastTheme.showInfo(
        context,
        message: L10n.get("group_landlord_invite_revoked"),
      );
      widget.onChanged?.call();
    } catch (e) {
      if (!context.mounted) return;
      ToastTheme.showError(
        context,
        message: ErrorMessageHelper.sanitizeErrorMessage(e, context: context),
      );
    } finally {
      if (mounted) setState(() => _landlordInviteBusyListingId = 0);
    }
  }

  String _landlordInviteErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      final serverError = data is Map
          ? (data["error"] ?? data["message"])?.toString()
          : data is String
              ? data
              : error.message;
      if (serverError == "GROUP_LANDLORD_ALREADY_ACTIVE" ||
          serverError == "GROUP_LANDLORD_INVITE_ALREADY_PENDING") {
        return L10n.get("group_landlord_invite_one_at_a_time");
      }
      if (error.response?.statusCode == 409) {
        return L10n.get("group_landlord_invite_one_at_a_time");
      }
    }
    return ErrorMessageHelper.sanitizeErrorMessage(error, context: context);
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
          discussListingId: row.listing.id,
          listingShareToPost: composerText,
        ),
      ),
    );
  }

  void _openGroupHousingSearch(ListingDetail groupDetail) {
    Navigator.of(context).pop();
    GroupHousingFlow.openSearch(
      context: context,
      groupListingDetail: groupDetail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupDetail = widget.groupListingDetail;
    final mediaQuery = MediaQuery.of(context);
    final maxSheetHeight = mediaQuery.size.height -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom -
        24;
    final reservedHeight = _shortlistSheetTopChromeHeight +
        (_rows.length > 1 ? _shortlistSheetNavigationHeight : 0);
    final maxCarouselHeight =
        (maxSheetHeight - reservedHeight).clamp(0.0, maxSheetHeight).toDouble();
    final scheme = Theme.of(context).colorScheme;
    final statusLabelKey = groupDetail?.groupContext?.progressStatusLabelKey;
    final statusLabel =
        statusLabelKey == null ? null : L10n.get(statusLabelKey);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        GroupHousingFlow.savedListingsLabel(_rows.length),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_loading &&
                        _rows.isNotEmpty &&
                        groupDetail != null) ...[
                      const SizedBox(width: 8),
                      _ContinueSearchPillButton(
                        onPressed: () => _openGroupHousingSearch(groupDetail),
                      ),
                    ],
                  ],
                ),
                if (statusLabel != null) ...[
                  const SizedBox(height: 8),
                  _ShortlistStatusLabel(label: statusLabel),
                ],
              ],
            ),
          ),
          if (_loading)
            const SizedBox(
              height: 200,
              child: Center(child: HouseLoadingIndicator()),
            )
          else if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: UydoshEmptyColumn(
                title: L10n.get("group_shortlist_empty_title"),
                subtitle: L10n.get("group_shortlist_empty_subtitle"),
                action: FilledButton.icon(
                  onPressed: groupDetail == null
                      ? null
                      : () => _openGroupHousingSearch(groupDetail),
                  icon: const Icon(Icons.search),
                  label: Text(L10n.get("group_find_housing")),
                ),
              ),
            )
          else
            Flexible(
              fit: FlexFit.loose,
              child: _ExpandablePageView(
                controller: _pageController,
                itemCount: _rows.length,
                maxHeight: maxCarouselHeight,
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
                  final isLandlordInviteBusy =
                      _landlordInviteBusyListingId == row.listing.id;
                  final groupContext = groupDetail?.groupContext;
                  final isLandlordInvitePending =
                      row.item.pendingLandlordInviteId != null;
                  final hasGroupChat = groupContext?.hasGroupChat == true;
                  final canInviteLandlord = groupContext?.groupProgress == null
                      ? widget.isOwner && !isLandlordInvitePending
                      : groupContext?.canInviteLandlord == true;
                  final canRevokeLandlordInvite =
                      groupContext?.groupProgress == null
                          ? widget.isOwner && isLandlordInvitePending
                          : groupContext?.canRevokeLandlordInvite == true;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    child: GroupShortlistItemCard(
                      item: row.item,
                      listing: row.listing,
                      fit: fit,
                      ownerName: row.ownerName,
                      ownerAvatarUrl: row.ownerAvatarUrl,
                      isOwner: widget.isOwner,
                      isRemoving: isRemoving,
                      currentUserId: _currentUserId,
                      isLandlordInvitePending: isLandlordInvitePending,
                      isLandlordInviteBusy: isLandlordInviteBusy,
                      onOpen: () => _openListing(row),
                      onRemove: () => _confirmRemove(row),
                      onRate: (stars) => _editRating(row, stars),
                      onContactLandlord: widget.isOwner &&
                              canInviteLandlord &&
                              !isLandlordInvitePending
                          ? () => _contactLandlord(row)
                          : null,
                      onRevokeLandlordInvite: widget.isOwner &&
                              canRevokeLandlordInvite &&
                              isLandlordInvitePending
                          ? () => _revokeLandlordInvite(row)
                          : null,
                      onDiscussInGroup:
                          hasGroupChat ? () => _discussInGroup(row) : null,
                    ),
                  );
                },
              ),
            ),
          if (!_loading && _rows.length > 1) _buildShortlistNavigation(context),
        ],
      ),
    );
  }
}

class _ContinueSearchPillButton extends StatelessWidget {
  const _ContinueSearchPillButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final label = L10n.get("group_continue_search");

    return Tooltip(
      message: label,
      child: Material(
        color: scheme.onSurface.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 18, color: scheme.onSurface),
                const SizedBox(width: 7),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A horizontal [PageView] that sizes its height to the currently-visible
/// page's content (capped at [maxHeight]) instead of forcing a fixed viewport.
///
/// Each page's natural height is measured on layout; the container animates to
/// that height so cards are shown in full without an inner scroll. [maxHeight]
/// only prevents the sheet from exceeding the visible screen on very small
/// devices.
class _ExpandablePageView extends StatefulWidget {
  const _ExpandablePageView({
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    required this.maxHeight,
    required this.onPageChanged,
  });

  final PageController controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double maxHeight;
  final ValueChanged<int> onPageChanged;

  @override
  State<_ExpandablePageView> createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<_ExpandablePageView> {
  static const _estimatedInitialHeight = 260.0;

  late List<double> _heights;
  var _currentPage = 0;

  double get _currentHeight =>
      _heights.isEmpty ? widget.maxHeight : _heights[_currentPage];

  double get _initialHeight =>
      _estimatedInitialHeight.clamp(0.0, widget.maxHeight).toDouble();

  @override
  void initState() {
    super.initState();
    _heights = List<double>.filled(widget.itemCount, _initialHeight);
    _currentPage = widget.controller.initialPage
        .clamp(0, widget.itemCount == 0 ? 0 : widget.itemCount - 1)
        .toInt();
  }

  @override
  void didUpdateWidget(covariant _ExpandablePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.itemCount != widget.itemCount) {
      final next = List<double>.filled(widget.itemCount, _initialHeight);
      for (var i = 0; i < widget.itemCount && i < _heights.length; i++) {
        next[i] = _heights[i];
      }
      _heights = next;
      if (widget.itemCount == 0) {
        _currentPage = 0;
      } else if (_currentPage >= widget.itemCount) {
        _currentPage = widget.itemCount - 1;
      }
    }
  }

  void _setHeight(int index, double height) {
    if (index < 0 || index >= _heights.length) return;
    if ((_heights[index] - height).abs() < 0.5) return;
    setState(() => _heights[index] = height);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      height: _currentHeight.clamp(0.0, widget.maxHeight),
      child: PageView.builder(
        controller: widget.controller,
        itemCount: widget.itemCount,
        onPageChanged: (page) {
          setState(() => _currentPage = page);
          widget.onPageChanged(page);
        },
        itemBuilder: (context, index) {
          return OverflowBox(
            minHeight: 0,
            maxHeight: double.infinity,
            alignment: Alignment.topCenter,
            child: _MeasureSize(
              onChange: (size) => _setHeight(index, size.height),
              child: widget.itemBuilder(context, index),
            ),
          );
        },
      ),
    );
  }
}

typedef _OnWidgetSizeChange = void Function(Size size);

/// Reports its child's laid-out size to [onChange] after each layout pass.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final _OnWidgetSizeChange onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);

  _OnWidgetSizeChange onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class _ShortlistStatusLabel extends StatelessWidget {
  const _ShortlistStatusLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = scheme.primary;

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 32,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline_rounded, size: 15, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
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
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;
    return IconButton.filledTonal(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 20),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 32, height: 32),
      style: IconButton.styleFrom(
        minimumSize: const Size.square(32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: scheme.onSurface.withValues(alpha: 0.10),
        foregroundColor: color,
        disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.05),
        disabledForegroundColor:
            isLight ? color : scheme.onSurface.withValues(alpha: 0.32),
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
