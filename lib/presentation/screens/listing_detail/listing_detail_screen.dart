import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter_bloc/flutter_bloc.dart";
import "package:dio/dio.dart";
import "package:flutter/services.dart";
import "package:share_plus/share_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/api/auth_token_repository.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/oauth_dio_configurator.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/follow_service.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/theme_helper.dart"
    show ThemeHelper, liquidGlassAppBarMaterialColor;
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/deep_link_service.dart";
import "package:uy_dosh/base/services/room_scan_metrics_hydration_service.dart";
import "package:uy_dosh/base/services/room_usdz_viewer_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/config/client_admin_listing_conversations_config.dart";
import "package:uy_dosh/base/config/client_listing_contacts_config.dart";
import "package:uy_dosh/base/state/admin_feature_flags_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/util/dio_api_error_message.dart";
import "package:uy_dosh/base/util/listing_contact_redaction.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/moderation_staff_utils.dart";
import "package:uy_dosh/base/utils/peer_interaction_eligibility.dart";
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/models/photo_network_display.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/admin_entity_ownership_service.dart";
import "package:uy_dosh/domain/services/location_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/locations_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/subway_stations_bloc.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listing_owner_conversations_screen.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_entry_flow.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/utils/destructive_action_flow.dart";
import "package:uy_dosh/presentation/widgets/admin/reassign_owner_dialog.dart";
import "package:uy_dosh/presentation/screens/complaint/create_complaint_screen.dart";
import "package:uy_dosh/presentation/screens/complaint/listing_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/edit_listing/edit_listing_screen.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/screens/profile/edit_profile_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_compatibility_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_budget_fit_chip.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_shortlist_pill_button.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/group_shortlist_save_button.dart";
import "package:uy_dosh/presentation/screens/listing_detail/group_member_compatibility_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_group_compatibility_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_date_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_pending_action.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_admin_contact_info.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_meta_and_price_tile.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_compatibility_section.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_complaints_card.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_listing_owner_messages_card.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_nearby_stores_card.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_contact_action_bar.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_group_forming_action_bar.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_group_join_requests_sheet.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_group_member_profiles_sheet.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_content_card.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_owner_toolbar.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_photo_section.dart";
import "package:uy_dosh/presentation/screens/listing_detail/room_3d_tile.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_loading_placeholder.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_error_placeholder.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_nearby_matches_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_nearby_matches_tile.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_view_similar_tile.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/widgets/achievement_unlock_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/full_screen_photo_viewer.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_toggle.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/feed_scroll_scope.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";

/// Label for listing author from profile when [UserProfile.name] is empty.
String? _listingAuthorNameFromProfile(UserProfile profile) {
  final name = profile.name?.trim();
  if (name != null && name.isNotEmpty) return name;
  final telegram = profile.telegram?.trim();
  if (telegram != null && telegram.isNotEmpty) {
    return telegram.startsWith("@") ? telegram : "@$telegram";
  }
  return null;
}

String? _listingAuthorAvatarUrlFromProfile(UserProfile profile) {
  final avatar = profile.avatarUrl?.trim();
  if (avatar != null && avatar.isNotEmpty) return avatar;
  final telegramAvatar = profile.telegramAvatarUrl?.trim();
  if (telegramAvatar != null && telegramAvatar.isNotEmpty) {
    return telegramAvatar;
  }
  return null;
}

/// Owner label for listing UI / chat entry: use [ListingDetailPageBloc] cache only
/// when it matches [ListingDetail.user], otherwise listing payload email (always
/// tied to the current owner row).
String _resolvedListingOwnerDisplayLabel(
  ListingDetail listingDetail,
  ListingDetailPageState pageState,
) {
  final ownerId = listingDetail.user.id;
  final cached = pageState.ownerName?.trim();
  if (cached != null &&
      cached.isNotEmpty &&
      pageState.ownerNameListingUserId == ownerId) {
    return cached;
  }
  final email = listingDetail.user.email?.trim();
  if (email != null && email.isNotEmpty) return email;
  return "";
}

// Data classes for BlocSelector to reduce unnecessary rebuilds
class _ListingDetailIconsData {
  const _ListingDetailIconsData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.listingDetail,
  });
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final ListingDetail? listingDetail;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ListingDetailIconsData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.listingDetail == listingDetail;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        listingDetail.hashCode;
  }
}

class _ListingDetailBodyData {
  const _ListingDetailBodyData({
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
    required this.listingDetail,
  });
  final bool isLoading;
  final bool hasError;
  final String errorMessage;
  final ListingDetail? listingDetail;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _ListingDetailBodyData &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.listingDetail == listingDetail;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        hasError.hashCode ^
        errorMessage.hashCode ^
        listingDetail.hashCode;
  }
}

class _FloatingGroupChatButton extends StatelessWidget {
  const _FloatingGroupChatButton({
    required this.label,
    required this.hasUnread,
    required this.unreadTrigger,
    required this.onPressed,
  });

  final String label;
  final bool hasUnread;
  final int unreadTrigger;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBlueTheme = ThemeState().isBlueTheme;
    final unreadColor = ThemeState().unreadIndicatorColor;
    final surface = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.84)
        : Colors.white.withValues(alpha: 0.92);
    final foreground = isDark ? Colors.white : Colors.black;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
      side: isBlueTheme
          ? const BorderSide(color: Colors.white, width: 1)
          : BorderSide.none,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: surface,
            shape: shape,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onPressed,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStatePropertyAll(
                foreground.withValues(alpha: 0.06),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      size: 19,
                      color: unreadColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasUnread)
          Positioned(
            right: 2,
            top: -2,
            child: PulseThenBlinkDotWidget(
              trigger: unreadTrigger,
              color: unreadColor,
              size: 10,
              blinkDuration: const Duration(milliseconds: 750),
              borderColor: surface,
              borderWidth: 1.5,
            ),
          ),
      ],
    );
  }
}

class _FloatingGroupParticipantsButton extends StatelessWidget {
  const _FloatingGroupParticipantsButton({
    required this.members,
    required this.memberCount,
    required this.currentUserId,
    required this.showDot,
    required this.dotTrigger,
    required this.onPressed,
  });

  final List<ConversationMemberSummary> members;
  final int memberCount;
  final int? currentUserId;
  final bool showDot;
  final int dotTrigger;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isBlueTheme = ThemeState().isBlueTheme;
    final accentColor = ThemeState().isBlueTheme
        ? const Color(0xFF34D399)
        : theme.colorScheme.primary;
    final surface = isDark
        ? theme.colorScheme.surface.withValues(alpha: 0.84)
        : Colors.white.withValues(alpha: 0.92);
    final foreground = isDark ? Colors.white : Colors.black;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(999),
      side: isDark
          ? (isBlueTheme
              ? const BorderSide(color: Colors.white, width: 1)
              : BorderSide(
                  color: accentColor.withValues(alpha: 0.58),
                  width: 1,
                ))
          : BorderSide.none,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.16),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: surface,
            shape: shape,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onPressed,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStatePropertyAll(
                foreground.withValues(alpha: 0.06),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (members.isEmpty)
                      _FloatingParticipantIconStack(
                        count: memberCount,
                        color: accentColor,
                      )
                    else
                      ChatParticipantAvatarStack(
                        participants: members,
                        currentUserId: currentUserId,
                        avatarSize: 22,
                        maxVisible: 5,
                      ),
                    const SizedBox(width: 9),
                    Text(
                      L10n.get("group_floating_participants_label"),
                      style: TextStyle(
                        color: foreground,
                        fontSize: 14,
                        height: 1.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDot)
          Positioned(
            right: 2,
            top: -2,
            child: PulseThenBlinkDotWidget(
              trigger: dotTrigger,
              color: ThemeState().unreadIndicatorColor,
              size: 10,
              blinkDuration: const Duration(milliseconds: 750),
              borderColor: surface,
              borderWidth: 1.5,
            ),
          ),
      ],
    );
  }
}

class _FloatingParticipantIconStack extends StatelessWidget {
  const _FloatingParticipantIconStack({
    required this.count,
    required this.color,
  });

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const iconSize = 22.0;
    const overlap = 9.0;
    final visibleCount = count.clamp(1, 6).toInt();
    final step = iconSize - overlap;

    return SizedBox(
      width: iconSize + (visibleCount - 1) * step,
      height: iconSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(
          visibleCount,
          (index) => Positioned(
            left: index * step,
            child: Icon(
              index.isEven ? Icons.person_outline : Icons.person,
              size: iconSize,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({
    required this.listingId,
    this.initialPendingAction,
    this.groupHousingContextListingId,
    super.key,
  });
  final int listingId;
  final ListingDetailPendingAction? initialPendingAction;

  /// When set, shows "Save for group" on `roommate_needed` housing listings.
  final int? groupHousingContextListingId;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen>
    with TickerProviderStateMixin {
  // The warning-blink controller used to live here and run forever, even on
  // listings with zero complaints (the vast majority). It now lives inside
  // [ListingDetailComplaintsCard] which is only mounted when there's
  // actually a complaint to warn about — see that widget for the controller.
  //
  // The 3D-room rotate controller used to live here too and ran forever even
  // for listings without a `pointCloudUrl`. It now lives inside [ListingRoom3dTile]
  // which is only mounted when there's a 3D scan to rotate the icon for.
  late PageController _pageController;
  late ScrollController _scrollController;
  bool _isOpeningRoom3d = false;
  ListingDetail? _groupListingDetailForHousing;
  int? _roomScanMetricsHydrationListingId;

  /// Cached so [ListenableBuilder] around the app bar menu does not restart
  /// [FutureBuilder] and re-invoke [SessionManager.getUserRole] on every rebuild.
  late final Future<String?> _userRoleFuture = SessionManager.getUserRole();
  final GlobalKey _compatibilitySectionKey = GlobalKey();

  /// Session uid fallback while [UserListingState] has not finished hydrating.
  int? _sessionUserId;
  var _handledInitialPendingAction = false;

  bool _isListingOwner(int listingUserId) =>
      PeerInteractionEligibility.isPublisher(
        publisherUserId: listingUserId,
        viewerUserIdFallback: _sessionUserId,
      );

  bool _isGroupFormingListing(ListingDetail listingDetail) =>
      ListingGroupProgress.isGroupFormingDetail(listingDetail);

  bool _canShowGroupShortlistPill(ListingDetail listingDetail) {
    final ctx = listingDetail.groupContext;
    if (ctx?.canUseHousingShortlist != true) return false;
    return ctx?.isOwner == true || ctx?.isMember == true;
  }

  bool _canShowFloatingGroupChatButton(ListingDetail listingDetail) {
    final ctx = listingDetail.groupContext;
    if (ctx?.hasGroupChat != true) return false;
    return ctx?.isOwner == true || ctx?.isMember == true;
  }

  bool _canShowFloatingGroupParticipantsButton(ListingDetail listingDetail) {
    final groupProgress = ListingGroupProgress.fromListingDetail(listingDetail);
    if (groupProgress == null) return false;
    return groupProgress.current >=
        ListingGroupProgress.minMembersForGroupCompatibility;
  }

  static const double _floatingGroupChatButtonHeight = 40;
  static const double _floatingGroupParticipantsPillHeight = 40;
  static const double _floatingShortlistPillHeight = 38;
  static const double _floatingGroupActionsGap = 10;
  static const double _floatingGroupActionsBottomInset = 16;
  static const double _floatingGroupActionsShadowBuffer = 8;

  double _groupFormingFloatingActionsBottomPad(ListingDetail listingDetail) {
    final showChat = _canShowFloatingGroupChatButton(listingDetail);
    final showShortlist = _canShowGroupShortlistPill(listingDetail);
    final showParticipants = _canShowFloatingGroupParticipantsButton(
      listingDetail,
    );
    if (!showChat && !showShortlist && !showParticipants) {
      return 16.0 + MediaQuery.paddingOf(context).bottom;
    }

    var height =
        _floatingGroupActionsBottomInset + _floatingGroupActionsShadowBuffer;
    if (showParticipants) height += _floatingGroupParticipantsPillHeight;
    if (showChat) height += _floatingGroupChatButtonHeight;
    if (showShortlist) {
      if (showChat || showParticipants) height += _floatingGroupActionsGap;
      height += _floatingShortlistPillHeight;
    }
    if (showChat && showParticipants) height += _floatingGroupActionsGap;
    return height + MediaQuery.paddingOf(context).bottom;
  }

  bool _canShowFloatingGroupActions(ListingDetail listingDetail) =>
      _canShowGroupShortlistPill(listingDetail) ||
      _canShowFloatingGroupChatButton(listingDetail) ||
      _canShowFloatingGroupParticipantsButton(listingDetail);

  bool _hasUnreadGroupChat(ListingDetail listingDetail) {
    final conversationId = listingDetail.groupContext?.groupConversationId;
    if (conversationId == null) return false;
    return UnreadMessagesState().hasUnreadForConversation(conversationId);
  }

  void _seedGroupShortlistCount(ListingDetail listingDetail) {
    if (!_canShowGroupShortlistPill(listingDetail)) return;
    final count = listingDetail.groupContext?.groupShortlistCount;
    if (count != null) {
      GroupShortlistState().setShortlistCountForGroup(listingDetail.id, count);
    }
    unawaited(GroupShortlistState().refreshCount(listingDetail.id));
  }

  void _reloadListingDetail() {
    context.read<ListingDetailBloc>().add(
          ListingDetailEvent.fetchListingDetail(id: widget.listingId),
        );
  }

  double _listingDetailPullRefreshEdgeOffset(BuildContext context) {
    return 8.0 + ThemeState().mainShellGlassExtraTopInset(context);
  }

  Future<void> _onListingDetailPullRefresh() async {
    final bloc = context.read<ListingDetailBloc>();
    final isRefresh = bloc.state.maybeMap(
      loaded: (_) => true,
      orElse: () => false,
    );
    final refreshDone = bloc.stream.firstWhere(
      (state) => state.maybeMap(loading: (_) => false, orElse: () => true),
    );
    bloc.add(
      ListingDetailEvent.fetchListingDetail(
        id: widget.listingId,
        isRefresh: isRefresh,
      ),
    );
    await refreshDone;
  }

  Widget _wrapListingDetailPullToRefresh(Widget scrollableChild) {
    return UydoshRefreshIndicator.mainShell(
      onRefresh: _onListingDetailPullRefresh,
      edgeOffset: _listingDetailPullRefreshEdgeOffset(context),
      child: PullToRefreshStretchHaptics(child: scrollableChild),
    );
  }

  Future<void> _openGroupChat(ListingDetail listingDetail) async {
    if (!AuthFlow.requireAuth(context)) return;
    final conversationId = listingDetail.groupContext?.groupConversationId;
    if (conversationId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: ChatScreen.routeName(conversationId)),
        builder: (_) => ChatScreen(
          conversationId: conversationId,
          listingId: listingDetail.id,
          listingTypeId: listingDetail.listingTypeId,
          listingTitle: listingDetail.title,
          conversationContextType: "listing_group",
        ),
      ),
    );
  }

  Future<UserProfile?> _loadCurrentUserProfileForGroupJoin({
    bool preferCache = false,
  }) async {
    if (preferCache) {
      final cached = await SessionManager.getCachedUserProfile();
      if (cached != null) return cached;
    }

    try {
      final profile =
          await getIt<IUserProfileService>().getCurrentUserProfile();
      await SessionManager.storeUserProfile(profile);
      ProfileCompletionState().updateFromProfile(profile);
      return profile;
    } catch (e) {
      final cached =
          preferCache ? null : await SessionManager.getCachedUserProfile();
      if (cached != null) return cached;
      if (mounted)
        ToastReporting.errorMessage(context, throwableUserMessage(e));
      return null;
    }
  }

  Future<bool> _ensureProfileReadyForGroupJoin() async {
    var profile = await _loadCurrentUserProfileForGroupJoin();
    if (!mounted || profile == null) return false;
    if (ProfileCompletionState.hasCompleteProfile(profile)) {
      return true;
    }

    ToastReporting.warningKey(context, "group_join_requires_profile");
    final profileForEdit = profile;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(profile: profileForEdit),
      ),
    );
    if (!mounted || result != true) return false;

    profile = await _loadCurrentUserProfileForGroupJoin();
    if (!mounted || profile == null) return false;
    final isReady = ProfileCompletionState.hasCompleteProfile(profile);
    if (!isReady) {
      ToastReporting.warningKey(context, "group_join_requires_profile");
    }
    return isReady;
  }

  Future<void> _requestToJoinGroup(
    ListingDetail listingDetail, {
    bool allowProfileRetry = true,
  }) async {
    if (!AuthFlow.requireAuth(context)) return;
    if (!await _ensureProfileReadyForGroupJoin()) return;
    try {
      await getIt<IListingGroupService>().createJoinRequest(
        listingId: listingDetail.id,
      );
      if (!mounted) return;
      ToastReporting.successKey(context, "group_join_request_success");
      _reloadListingDetail();
    } catch (e) {
      if (!mounted) return;
      final message = throwableUserMessage(e);
      if (_isAlreadyInAnotherGroupMessage(message)) {
        ToastReporting.warningKey(
          context,
          "group_join_request_already_in_group_warning",
        );
        return;
      }
      if (allowProfileRetry && _isProfileRequiredForGroupJoinMessage(message)) {
        final isReady = await _ensureProfileReadyForGroupJoin();
        if (isReady && mounted) {
          await _requestToJoinGroup(
            listingDetail,
            allowProfileRetry: false,
          );
        }
        return;
      }
      ToastReporting.errorMessage(context, message);
    }
  }

  bool _isProfileRequiredForGroupJoinMessage(String message) {
    return message.trim().toLowerCase() ==
        "please complete your profile before joining a group";
  }

  bool _isAlreadyInAnotherGroupMessage(String message) {
    return message.trim().toLowerCase() ==
        "you are already in another active group";
  }

  Future<void> _withdrawGroupJoinRequest(ListingDetail listingDetail) async {
    try {
      await getIt<IListingGroupService>().withdrawJoinRequest(
        listingId: listingDetail.id,
      );
      if (!mounted) return;
      ToastReporting.successKey(context, "group_join_request_withdrawn");
      _reloadListingDetail();
    } catch (e) {
      if (!mounted) return;
      ToastReporting.errorMessage(context, throwableUserMessage(e));
    }
  }

  Future<void> _openGroupMemberProfiles(
    ListingDetail listingDetail,
    List<ConversationMemberSummary> groupMembers, {
    required bool isOwner,
  }) async {
    var pageState = context.read<ListingDetailPageBloc>().state;
    var members =
        groupMembers.isNotEmpty ? groupMembers : pageState.groupMembers;
    if (members.isEmpty) {
      await _loadCompatibility(listingDetail);
      if (!mounted) return;
      pageState = context.read<ListingDetailPageBloc>().state;
      members = pageState.groupMembers;
    }
    if (members.isEmpty) return;

    showListingGroupMemberProfilesSheet(
      context: context,
      listingId: listingDetail.id,
      members: members,
      ownerUserId: listingDetail.user.id,
      currentUserId: _sessionUserId,
      isOwner: isOwner,
      groupProgress: ListingGroupProgress.fromListingDetail(listingDetail),
      memberCompatibility: pageState.groupMemberCompatibility,
      groupListingDetail: listingDetail,
      onMemberTap: (userId) => _navigateToProfile(userId),
      onChanged: _reloadListingDetail,
    );
  }

  Widget _buildGroupFormingActionBar(
    ListingDetail listingDetail, {
    required bool isOwner,
    VoidCallback? onViewMemberProfiles,
  }) {
    final ctx = listingDetail.groupContext;

    void openJoinRequestsSheet() {
      showListingGroupJoinRequestsSheet(
        context: context,
        listingId: listingDetail.id,
        onChanged: _reloadListingDetail,
      );
    }

    if (ctx?.canUseHousingShortlist == true &&
        (ctx?.isOwner == true || ctx?.isMember == true)) {
      final pendingCount = ctx?.pendingJoinRequestCount ?? 0;
      final hasGroupChat = ctx?.hasGroupChat == true;
      final showManageRequestsFallback = ctx?.isOwner == true && !hasGroupChat;

      return ListingGroupFormingActionBar(
        listingDetail: listingDetail,
        primaryLabel: L10n.get("group_find_housing"),
        onPrimary: () => GroupHousingFlow.openSearch(
          context: context,
          groupListingDetail: listingDetail,
        ),
        secondaryLabel: showManageRequestsFallback
            ? L10n.get("group_manage_requests")
            : null,
        onSecondary: showManageRequestsFallback ? openJoinRequestsSheet : null,
        showManageRequestsDot: showManageRequestsFallback && pendingCount > 0,
        manageRequestsDotTrigger: pendingCount,
        onViewMemberProfiles: onViewMemberProfiles,
        showMemberProfilesDot: onViewMemberProfiles != null && pendingCount > 0,
        memberProfilesDotTrigger: pendingCount,
      );
    }
    if (isOwner) {
      final pendingCount = ctx?.pendingJoinRequestCount ?? 0;

      return ListingGroupFormingActionBar(
        listingDetail: listingDetail,
        primaryLabel: L10n.get("group_manage_requests"),
        onPrimary: openJoinRequestsSheet,
        showManageRequestsDot: pendingCount > 0,
        manageRequestsDotTrigger: pendingCount,
        onViewMemberProfiles: onViewMemberProfiles,
        showMemberProfilesDot: pendingCount > 0,
        memberProfilesDotTrigger: pendingCount,
      );
    }
    if (ctx?.isMember == true) {
      if (onViewMemberProfiles == null) return const SizedBox.shrink();
      return ListingGroupFormingActionBar(
        listingDetail: listingDetail,
        onViewMemberProfiles: onViewMemberProfiles,
      );
    }
    if (ctx?.hasPendingJoinRequest == true) {
      return ListingGroupFormingActionBar(
        listingDetail: listingDetail,
        primaryLabel: L10n.get("group_join_request_withdraw"),
        onPrimary: () => _withdrawGroupJoinRequest(listingDetail),
        onViewMemberProfiles: onViewMemberProfiles,
      );
    }
    if (ctx?.canRequestToJoin == true) {
      return ListingGroupFormingActionBar(
        listingDetail: listingDetail,
        primaryLabel: L10n.get("group_request_to_join"),
        onPrimary: () => _requestToJoinGroup(listingDetail),
        onViewMemberProfiles: onViewMemberProfiles,
      );
    }
    return const SizedBox.shrink();
  }

  Widget? _buildGroupHousingContextSection(ListingDetail housingListing) {
    final groupDetail = _groupListingDetailForHousing;
    final groupId = widget.groupHousingContextListingId;
    if (groupId == null || groupDetail == null) return null;
    if (housingListing.listingTypeId != ListingTypeIds.roommateNeeded &&
        housingListing.listingType.code != ListingTypeCodes.roommateNeeded) {
      return null;
    }

    final fit = GroupHousingBudgetFitHelper.evaluate(
      groupListing: groupDetail,
      housingPrice: housingListing.price,
      housingMinPrice: housingListing.minPrice,
      housingMaxPrice: housingListing.maxPrice,
      housingListingTypeCode: housingListing.listingType.code,
    );
    final groupSize = groupDetail.groupContext?.groupSizeTarget ??
        groupDetail.groupSizeTarget;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GroupBudgetFitChip(fit: fit),
          ),
          const SizedBox(height: 10),
          GroupShortlistSaveButton(
            groupListingId: groupId,
            housingListingId: housingListing.id,
            groupSizeLabel: groupSize?.toString(),
          ),
        ],
      ),
    );
  }

  /// In-app chat CTA for guests (login prompt) or signed-in non-owners only.
  bool _canShowInAppListingChat(ListingDetail listingDetail) {
    if (PeerInteractionEligibility
        .isInternalListingChatDisabledForPublisherEmail(
      listingDetail.user.email,
    )) {
      return false;
    }
    if (!AuthenticationState().isAuthenticated) return true;
    return PeerInteractionEligibility.mayInteractWithPublisher(
      publisherUserId: listingDetail.user.id,
      viewerUserIdFallback: _sessionUserId,
    );
  }

  Future<void> _hydrateSessionUserId() async {
    final id = await SessionManager.getUserId();
    if (mounted) setState(() => _sessionUserId = id);
  }

  @override
  void initState() {
    super.initState();

    // Initialize user listing state
    UserListingState().initialize();

    // Refresh user ID to ensure we have the current user
    UserListingState().refreshUserId();
    unawaited(_hydrateSessionUserId());

    // Initialize favorites state
    FavoritesState().initialize();

    unawaited(_prefetchAdminListingConversationsIfNeeded());

    // Initialize page controller for photo carousel
    _pageController = PageController();
    _scrollController = ScrollController();

    getIt<AppAnalyticsService>().logScreenView(screenName: "listing_detail");
    getIt<AppAnalyticsService>().logListingViewed(listingId: widget.listingId);

    // Fetch listing details
    context.read<ListingDetailBloc>().add(
          ListingDetailEvent.fetchListingDetail(id: widget.listingId),
        );
    unawaited(_loadGroupListingDetailForHousing());
  }

  Future<void> _loadGroupListingDetailForHousing() async {
    final groupId = widget.groupHousingContextListingId;
    if (groupId == null) return;
    try {
      final detail = await getIt<IListingService>().getListingDetail(groupId);
      if (!mounted) return;
      setState(() => _groupListingDetailForHousing = detail);
      await GroupShortlistState().refreshCount(groupId);
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Favorite status check is now handled by BlocListener when data loads
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Toggle listing active status
  Future<void> _toggleListingActive(int listingId) async {
    try {
      logger.d(
        "🔄 Starting toggle listing active status for listing ID: $listingId",
      );

      context.read<ListingDetailPageBloc>().setToggling(true);

      final listingService = getIt<IListingService>();
      final success = await listingService.toggleListingActive(listingId);

      if (success) {
        logger.d("✅ Toggle successful");

        // Update the listing data in the BLoC state to reflect the new status
        if (mounted) {
          logger.d("🔄 Updating listing data in BLoC state...");

          // Get current state and update the listing"s isActive status
          final currentState = context.read<ListingDetailBloc>().state;
          currentState.map(
            initial: (_) =>
                logger.d("🔄 Current state: initial - cannot update"),
            loading: (_) =>
                logger.d("🔄 Current state: loading - cannot update"),
            loaded: (loadedState) {
              logger.d(
                "🔄 Current listing active status: ${loadedState.listingDetail.isActive}",
              );
              logger.d(
                "🔄 About to update to: ${!loadedState.listingDetail.isActive}",
              );

              // Create updated listing with toggled status
              final updatedListing = loadedState.listingDetail.copyWith(
                isActive: !loadedState.listingDetail.isActive,
              );

              context.read<ListingDetailBloc>().add(
                    ListingDetailEvent.updateListingDetail(
                      listingDetail: updatedListing,
                    ),
                  );

              logger.d("✅ Listing status updated in BLoC state");
            },
            error: (errorState) =>
                logger.d("🔄 Current state: error - cannot update"),
          );
        }

        // Mark home screen for refresh to reflect the status change
        HomeRefreshState().markForRefresh();
        unawaited(
          getIt<AppAnalyticsService>().refreshHasActiveListingProperty(),
        );

        context.read<ListingDetailPageBloc>().setToggling(false);
        logger.d(
          "✅ Loading state reset, button should now be interactive again",
        );
      } else {
        throw Exception("Failed to toggle listing active status");
      }
    } catch (e) {
      logger.d("❌ Error toggling listing active status: $e");
      logger.d("❌ Error type: ${e.runtimeType}");
      logger.d("❌ Error details: $e");

      // Show error message
      ToastReporting.errorKey(context, "error_deactivating_listing");
    } finally {
      if (mounted) {
        context.read<ListingDetailPageBloc>().setToggling(false);
        logger.d("🔄 Loading state reset in finally block");
      }
    }
  }

  // Check favorite status from server and sync with global state
  Future<void> _checkFavoriteStatusFromServer() async {
    // First check if user is authenticated
    final authState = AuthenticationState();
    if (!authState.isAuthenticated) {
      return;
    }

    // Then check if user listing state is initialized
    final userListingState = UserListingState();
    if (!userListingState.isInitialized ||
        userListingState.currentUserId == null) {
      return;
    }

    // Get the current listing user ID to check ownership
    final listingUserId = _getCurrentListingUserId();
    if (listingUserId == null) {
      return;
    }

    // If user is the owner, they can"t have favorites, so no need to check
    if (_isListingOwner(listingUserId)) {
      return;
    }

    try {
      final favoriteService = FavoriteService(
        OAuthApiClient(
          configurator: OAuthDioConfigurator(tokenRepo: AuthTokenRepository()),
        ),
      );

      final isFavorite = await favoriteService.checkIfFavorited(
        widget.listingId,
      );

      if (mounted) {
        // Update global favorites state to keep it in sync with server
        final favoritesState = FavoritesState();

        if (isFavorite) {
          await favoritesState.addToFavorites(widget.listingId);
        } else {
          await favoritesState.removeFromFavorites(widget.listingId);
        }
      }
    } catch (e) {
      logger.e("Error checking favorite status from server: $e");
      // Don"t show error to user for this check, just log it
      // The heart icon will show as unfavorited by default
    }
  }

  Future<void> _loadComplaintCount(int listingId) async {
    final pageBloc = context.read<ListingDetailPageBloc>();
    if (pageBloc.state.isLoadingComplaintsCount &&
        pageBloc.state.complaintsCountListingId == listingId) {
      return;
    }

    pageBloc.setLoadingComplaintsCount(listingId);

    try {
      final complaintService = getIt<IComplaintService>();
      final count = await complaintService.getListingComplaintsCount(listingId);

      if (!mounted) return;
      pageBloc.setComplaintsCount(listingId, count);
    } catch (e) {
      logger.d("Error loading complaints count: $e");
      if (!mounted) return;
      pageBloc.setComplaintsCountError();
    }
  }

  Future<void> _loadViewCount(int listingId) async {
    final pageBloc = context.read<ListingDetailPageBloc>();
    if (pageBloc.state.isLoadingViewCount &&
        pageBloc.state.viewCountListingId == listingId) {
      return;
    }

    pageBloc.setLoadingViewCount(listingId);

    try {
      final listingService = getIt<IListingService>();
      final count = await listingService.getListingViewCount(listingId);

      if (!mounted) return;
      pageBloc.setViewCount(listingId, count);
    } catch (e) {
      logger.d("Error loading view count: $e");
      if (!mounted) return;
      pageBloc.setViewCountError();
    }
  }

  Future<void> _onListingLoaded(ListingDetail listingDetail) async {
    // Ensure UserListingState is initialized before owner check
    await UserListingState().initialize();
    if (!mounted) return;

    context
        .read<ListingDetailPageBloc>()
        .invalidateStaleListingOwnerPresentation(
          listingDetail.user.id,
        );

    final isOwner = _isListingOwner(listingDetail.user.id);
    if (isOwner) {
      _loadViewCount(listingDetail.id);
      _loadOwnerName(listingDetail.user.id);
      if (_isGroupFormingListing(listingDetail)) {
        _loadCompatibility(listingDetail);
      }
    } else {
      if (AuthenticationState().isAuthenticated) {
        _recordView(listingDetail.id);
      }
      _loadCompatibility(listingDetail);
    }
    _loadSimilarListingsCount(listingDetail);
    _loadNearbyMatchesCount(listingDetail);
    _seedGroupShortlistCount(listingDetail);
    unawaited(_hydrateRoomScanMetricsIfNeeded(listingDetail));
    _maybeHandleInitialPendingAction(listingDetail);
  }

  void _maybeHandleInitialPendingAction(ListingDetail listingDetail) {
    final action = widget.initialPendingAction;
    if (action == null || _handledInitialPendingAction) return;
    _handledInitialPendingAction = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      switch (action) {
        case ListingDetailPendingAction.openJoinRequests:
          if (!_isListingOwner(listingDetail.user.id)) return;
          await showListingGroupJoinRequestsSheet(
            context: context,
            listingId: listingDetail.id,
            onChanged: _reloadListingDetail,
          );
        case ListingDetailPendingAction.openGroupChat:
          if (listingDetail.groupContext?.isMember != true) return;
          await _openGroupChat(listingDetail);
      }
    });
  }

  /// Details tile reads metrics from the API; legacy scans often have USDZ but
  /// null DB columns. Compute from the cached USDZ so dimensions show without
  /// opening the 3D viewer first.
  Future<void> _hydrateRoomScanMetricsIfNeeded(
    ListingDetail listingDetail,
  ) async {
    if (kIsWeb || !isIOSDevice) return;
    final raw = listingDetail.pointCloudUrl;
    if (raw == null || raw.isEmpty) return;
    if (!listingDetail.roomScanMetricsMissing) return;
    if (_roomScanMetricsHydrationListingId == listingDetail.id) return;
    _roomScanMetricsHydrationListingId = listingDetail.id;
    try {
      final metrics =
          await RoomScanMetricsHydrationService.computeFromRemoteUrl(
        absoluteUrl: _buildPhotoUrl(raw),
        listingId: listingDetail.id,
      );
      if (!mounted || metrics == null) return;
      context.read<ListingDetailBloc>().add(
            ListingDetailEvent.updateListingDetail(
              listingDetail: listingDetail.withRoomScanMetrics(metrics),
            ),
          );
      await UserListingState().initialize();
      if (!mounted) return;
      final role = (await SessionManager.getUserRole())?.toLowerCase().trim();
      final canBackfill =
          _isListingOwner(listingDetail.user.id) || role == "admin";
      if (canBackfill) {
        try {
          await getIt<IListingService>().patchRoomScanMetricsIfMissing(
            listingId: listingDetail.id,
            metrics: metrics,
          );
        } catch (e, st) {
          logger.d("Room scan metrics backfill on detail load failed: $e\n$st");
        }
      }
    } catch (e, st) {
      logger.d("Room scan metrics hydration on detail load failed: $e\n$st");
    } finally {
      if (_roomScanMetricsHydrationListingId == listingDetail.id) {
        _roomScanMetricsHydrationListingId = null;
      }
    }
  }

  /// Loads how many active listings match the "similar" filter for this
  /// listing — excluding the current listing itself. The result is used to
  /// hide the "view similar" tile when there's nothing to navigate to.
  Future<void> _loadSimilarListingsCount(ListingDetail listingDetail) async {
    final pageBloc = context.read<ListingDetailPageBloc>();
    if (pageBloc.state.isLoadingSimilarListingsCount &&
        pageBloc.state.similarListingsCountListingId == listingDetail.id) {
      return;
    }
    pageBloc.setLoadingSimilarListingsCount(listingDetail.id);

    try {
      final stationId = listingDetail.subwayStation?.id;
      final locationId = listingDetail.location?.id;
      final price = _similarPriceRange(listingDetail);

      // Fetch up to 2 results so we can detect "only the current listing
      // matches" without paying for a full page.
      final response = await getIt<IListingService>().getListings(
        page: 1,
        limit: 2,
        listingTypeId: listingDetail.listingTypeId,
        subwayStationId: stationId,
        locationId: stationId == null ? locationId : null,
        gender: listingDetail.gender,
        minPrice: price?.min,
        maxPrice: price?.max,
      );

      // If `total > 1` there's guaranteed to be at least one listing other
      // than the current one. Otherwise inspect the (small) page payload to
      // see whether the single match (if any) is the current listing itself.
      final hasOther = response.total > 1 ||
          response.data.any((l) => l.id != listingDetail.id);
      final otherCount = hasOther ? 1 : 0;

      if (!mounted) return;
      pageBloc.setSimilarListingsCount(listingDetail.id, otherCount);
    } catch (e) {
      logger.d("Error loading similar listings count: $e");
      if (!mounted) return;
      pageBloc.setSimilarListingsCountError();
    }
  }

  /// Loads how many active listings match the cross-type "nearby matches"
  /// filter — complementary listing type at the same station or district.
  Future<void> _loadNearbyMatchesCount(ListingDetail listingDetail) async {
    if (!ListingDetailNearbyMatchesHelper.canShowForListing(listingDetail)) {
      return;
    }

    final pageBloc = context.read<ListingDetailPageBloc>();
    if (pageBloc.state.isLoadingNearbyMatchesCount &&
        pageBloc.state.nearbyMatchesCountListingId == listingDetail.id) {
      return;
    }
    pageBloc.setLoadingNearbyMatchesCount(listingDetail.id);

    try {
      final filters =
          ListingDetailNearbyMatchesHelper.searchFilters(listingDetail);

      final response = await getIt<IListingService>().getListings(
        page: 1,
        limit: 1,
        listingTypeId: filters.complementaryListingTypeId,
        subwayStationId: filters.subwayStationId,
        locationId: filters.locationId,
        gender: filters.gender,
      );

      final count = response.total > 0 ? 1 : 0;

      if (!mounted) return;
      pageBloc.setNearbyMatchesCount(listingDetail.id, count);
    } catch (e) {
      logger.d("Error loading nearby matches count: $e");
      if (!mounted) return;
      pageBloc.setNearbyMatchesCountError();
    }
  }

  Future<void> _recordView(int listingId) async {
    try {
      final listingService = getIt<IListingService>();
      await listingService.recordListingView(listingId);
    } catch (e) {
      logger.d("Error recording listing view: $e");
    }
  }

  Future<void> _loadOwnerName(int listingUserId) async {
    final pageBloc = context.read<ListingDetailPageBloc>();
    if (pageBloc.state.ownerNameListingUserId == listingUserId &&
        pageBloc.state.ownerName != null) {
      return;
    }
    if (!AuthenticationState().isAuthenticated) return;
    try {
      final profile =
          await getIt<IUserProfileService>().getUserProfile(listingUserId);
      if (!mounted) return;
      if (_getCurrentListingUserId() != listingUserId) return;
      pageBloc.setOwnerName(
        listingUserId,
        _listingAuthorNameFromProfile(profile),
        avatarUrl: _listingAuthorAvatarUrlFromProfile(profile),
      );
    } catch (e) {
      logger.d("Error loading owner name: $e");
    }
  }

  Future<void> _loadCompatibility(ListingDetail listingDetail) async {
    final authState = AuthenticationState();
    if (!authState.isAuthenticated) return;

    if (_isGroupFormingListing(listingDetail) &&
        !ListingGroupProgress.canShowGroupCompatibility(listingDetail)) {
      return;
    }

    final listingUserId = listingDetail.user.id;
    final pageBloc = context.read<ListingDetailPageBloc>();
    if (pageBloc.state.isLoadingCompatibility &&
        pageBloc.state.compatibilityListingUserId == listingUserId) {
      return;
    }

    pageBloc.setLoadingCompatibility(listingUserId);

    try {
      final userProfileService = getIt<IUserProfileService>();
      final currentProfile = await userProfileService.getCurrentUserProfile();

      if (_isGroupFormingListing(listingDetail)) {
        await _loadGroupCompatibility(
          listingDetail: listingDetail,
          listingUserId: listingUserId,
          currentProfile: currentProfile,
          pageBloc: pageBloc,
          userProfileService: userProfileService,
        );
        return;
      }

      final ownerProfile =
          await userProfileService.getUserProfile(listingUserId);
      final result = ListingDetailCompatibilityHelper.calculate(
        currentProfile,
        ownerProfile,
      );

      if (!mounted) return;
      if (_getCurrentListingUserId() != listingUserId) return;
      pageBloc.setCompatibilityResult(
        listingUserId: listingUserId,
        percent: result.percent,
        matches: result.matches,
        differences: result.differences,
        dealbreakers: result.dealbreakers,
        scoredFieldCount: result.scoredFieldCount,
        totalFieldCount: result.totalFieldCount,
        ownerName: _listingAuthorNameFromProfile(ownerProfile),
        ownerAvatarUrl: _listingAuthorAvatarUrlFromProfile(ownerProfile),
        currentUserAvatarUrl:
            _listingAuthorAvatarUrlFromProfile(currentProfile),
      );
    } catch (e) {
      logger.d("Error loading compatibility: $e");
      if (!mounted) return;
      pageBloc.setCompatibilityError(e.toString());
    }
  }

  Future<void> _loadGroupCompatibility({
    required ListingDetail listingDetail,
    required int listingUserId,
    required UserProfile currentProfile,
    required ListingDetailPageBloc pageBloc,
    required IUserProfileService userProfileService,
  }) async {
    final members = await getIt<IListingGroupService>()
        .listMembers(listingId: listingDetail.id);

    final memberUserIds = members.map((m) => m.userId).toSet();
    final canViewGroupCompatibilityDetails =
        memberUserIds.contains(currentProfile.userId) ||
            (members.isEmpty && listingUserId == currentProfile.userId);
    final profiles = <UserProfile>[];
    final groupMembers = <ConversationMemberSummary>[];

    Future<UserProfile> profileFor(int userId) async {
      if (userId == currentProfile.userId) return currentProfile;
      return userProfileService.getUserProfile(userId);
    }

    if (members.isEmpty) {
      if (listingUserId != currentProfile.userId) {
        final ownerProfile = await profileFor(listingUserId);
        profiles.add(ownerProfile);
        groupMembers.add(
          ConversationMemberSummary(
            userId: ownerProfile.userId,
            name: ownerProfile.name ?? L10n.get("user"),
            avatarUrl: _listingAuthorAvatarUrlFromProfile(ownerProfile),
          ),
        );
      }
      if (canViewGroupCompatibilityDetails &&
          !profiles.any((p) => p.userId == currentProfile.userId)) {
        profiles.add(currentProfile);
        groupMembers.add(
          ConversationMemberSummary(
            userId: currentProfile.userId,
            name: currentProfile.name ?? L10n.get("user"),
            avatarUrl: _listingAuthorAvatarUrlFromProfile(currentProfile),
          ),
        );
      }
    } else {
      final fetchedProfiles = await Future.wait(
        members.map((m) => profileFor(m.userId)),
      );
      profiles.addAll(fetchedProfiles);
      for (final profile in fetchedProfiles) {
        groupMembers.add(
          ConversationMemberSummary(
            userId: profile.userId,
            name: profile.name ?? L10n.get("user"),
            avatarUrl: _listingAuthorAvatarUrlFromProfile(profile),
          ),
        );
      }
    }

    await _putListingOwnerFirstInGroupMembers(
      listingUserId: listingUserId,
      profileFor: profileFor,
      profiles: profiles,
      groupMembers: groupMembers,
    );

    final groupResult =
        ListingDetailGroupCompatibilityHelper.calculate(profiles);

    final profileByUserId = {
      for (final profile in profiles) profile.userId: profile,
    };
    final matrixProfiles = groupMembers
        .map((member) => profileByUserId[member.userId])
        .whereType<UserProfile>()
        .toList(growable: false);
    final groupPreferenceMatrix =
        ListingDetailGroupCompatibilityHelper.buildPreferenceMatrix(
      matrixProfiles,
    );
    final groupMemberCompatibility = <int, GroupMemberCompatibilitySummary>{};
    if (canViewGroupCompatibilityDetails) {
      for (final member in groupMembers) {
        if (member.userId == currentProfile.userId) continue;
        final memberProfile = profileByUserId[member.userId];
        if (memberProfile == null) continue;
        groupMemberCompatibility[member.userId] =
            GroupMemberCompatibilityHelper.summarize(
          currentProfile,
          memberProfile,
        );
      }
    }

    if (!mounted) return;
    if (_getCurrentListingUserId() != listingUserId) return;

    pageBloc.setCompatibilityResult(
      listingUserId: listingUserId,
      percent: groupResult.percent,
      matches: const [],
      differences: const [],
      dealbreakers: const [],
      scoredFieldCount: groupResult.scoredFieldCount,
      totalFieldCount: groupResult.totalFieldCount,
      currentUserAvatarUrl: _listingAuthorAvatarUrlFromProfile(currentProfile),
      isGroupCompatibility: true,
      groupMembers: groupMembers,
      groupFullMatches: groupResult.fullMatches,
      groupPartialMatches: groupResult.partialMatches,
      groupDiscussItems: groupResult.discussItems,
      groupPreferenceMatrix: groupPreferenceMatrix,
      groupMemberCompatibility: groupMemberCompatibility,
      canViewGroupCompatibilityDetails: canViewGroupCompatibilityDetails,
    );
  }

  /// Listing owner is always group member #1; repair display when the API row
  /// is missing or arrives later in the member list.
  Future<void> _putListingOwnerFirstInGroupMembers({
    required int listingUserId,
    required Future<UserProfile> Function(int userId) profileFor,
    required List<UserProfile> profiles,
    required List<ConversationMemberSummary> groupMembers,
  }) async {
    UserProfile? ownerProfile;

    final memberIndex = groupMembers.indexWhere(
      (member) => member.userId == listingUserId,
    );
    if (memberIndex == -1) {
      ownerProfile = await profileFor(listingUserId);
      groupMembers.insert(
        0,
        ConversationMemberSummary(
          userId: ownerProfile.userId,
          name: ownerProfile.name ?? L10n.get("user"),
          avatarUrl: _listingAuthorAvatarUrlFromProfile(ownerProfile),
        ),
      );
    } else if (memberIndex > 0) {
      final ownerMember = groupMembers.removeAt(memberIndex);
      groupMembers.insert(0, ownerMember);
    }

    final profileIndex = profiles.indexWhere(
      (profile) => profile.userId == listingUserId,
    );
    if (profileIndex == -1) {
      ownerProfile ??= await profileFor(listingUserId);
      profiles.insert(0, ownerProfile);
    } else if (profileIndex > 0) {
      final ownerProfile = profiles.removeAt(profileIndex);
      profiles.insert(0, ownerProfile);
    }
  }

  Future<void> _openTelegramChat(String handle) async {
    final trimmed = handle.trim();
    if (trimmed.isEmpty) return;
    final username = trimmed.startsWith("@") ? trimmed.substring(1) : trimmed;
    if (username.isEmpty) return;

    final appUri = Uri.parse("tg://resolve?domain=$username");
    final webUri = Uri.parse("https://t.me/$username");

    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      logger.d("Error opening Telegram: $e");
      if (!mounted) return;
      ToastReporting.errorKey(context, "could_not_open_telegram");
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final trimmed = phoneNumber.trim();
    if (trimmed.isEmpty) return;
    final digits = trimmed.replaceAll(RegExp(r"[^0-9+]"), "");
    final uri = Uri.parse("tel:$digits");

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception("canLaunchUrl returned false");
      }
    } catch (e) {
      logger.d("Error making phone call: $e");
      if (!mounted) return;
      ToastReporting.errorKey(context, "could_not_make_call");
    }
  }

  String _buildComplaintsButtonLabel(
    bool isLoadingComplaintsCount,
    int? complaintsCount,
  ) {
    final base = L10n.get("view_listing_complaints");

    if (isLoadingComplaintsCount && complaintsCount == null) {
      return "$base ...";
    }
    if (complaintsCount != null) {
      final countText = L10n.plural(
        "complaints_count_short",
        complaintsCount,
      );
      return "$base • $countText";
    }
    return base;
  }

  // Helper method to get the appropriate name based on current language
  String _getLocalizedName({
    required String language,
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) {
    switch (language) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? L10n.get("unknown");
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? L10n.get("unknown");
      case "en":
        return nameRu ?? nameUz ?? nameEn ?? L10n.get("unknown");
      default:
        return nameRu ?? nameUz ?? nameEn ?? L10n.get("unknown");
    }
  }

  void _shareListing() {
    getIt<AppAnalyticsService>().logShareInitiated(listingId: widget.listingId);
    // Get the current listing detail from the bloc state
    final currentState = context.read<ListingDetailBloc>().state;

    currentState.map(
      initial: (_) => _showShareError(
        L10n.get(
          "error_listing_not_loaded",
        ),
      ),
      loading: (_) => _showShareError(
        L10n.get(
          "error_listing_still_loading",
        ),
      ),
      loaded: (loadedState) =>
          _performShare(loadedState.listingDetail, context),
      error: (errorState) => _showShareError(
        L10n.get(
          "error_loading_listing_details",
        ),
      ),
    );
  }

  Future<void> _performShare(
    ListingDetail listingDetail,
    BuildContext context,
  ) async {
    final currentLanguage = LanguageState().currentLanguage;

    // Build share text based on current language
    var shareText = _buildShareText(listingDetail, currentLanguage);
    if (shareText.trim().isEmpty) {
      shareText = DeepLinkService.buildListingDeepLink(listingDetail.id);
    }

    try {
      // sharePositionOrigin prevents iOS crash (share_plus 12.0.1 fix for iOS 26)
      await Share.share(
        shareText,
        subject: _getShareSubject(currentLanguage),
        sharePositionOrigin: Rect.zero,
      );
    } catch (e, stackTrace) {
      logger.e("Share failed", error: e, stackTrace: stackTrace);
      if (context.mounted) {
        _showShareError(L10n.get("error_sharing_listing"));
      }
      return;
    }

    getIt<AppAnalyticsService>().logShareCompleted(listingId: widget.listingId);

    if (!context.mounted) return;
    final achievement = await getIt<IGamificationService>().recordShare();
    if (context.mounted && achievement != null) {
      AchievementUnlockBottomSheet.show(
        context,
        achievement: achievement,
      );
    }
  }

  String _buildShareText(ListingDetail listingDetail, String language) {
    final title =
        ListingUtils.usesPresetListingTitle(listingDetail.listingTypeId)
            ? L10n.getForLanguage(
                ListingUtils.presetListingTitleL10nKey(
                  listingTypeId: listingDetail.listingTypeId,
                  gender: listingDetail.gender,
                ),
                language,
              )
            : _getLocalizedName(
                nameUz: listingDetail.title,
                nameRu: listingDetail.title,
                nameEn: listingDetail.title,
                language: language,
              );

    final description = ListingContactRedaction.stripForPublicDisplay(
      listingDetail.description ?? "",
    );
    final price = listingDetail.price;

    // Build location info
    var locationInfo = "";
    if (listingDetail.location != null) {
      final locationName = _getLocalizedName(
        nameUz: listingDetail.location!.nameUz,
        nameRu: listingDetail.location!.nameRu,
        nameEn: listingDetail.location!.nameEn,
        language: language,
      );
      locationInfo = "\n📍 $locationName";
    }

    // Build listing type info
    var typeInfo = "";
    final typeName = _getLocalizedName(
      nameUz: listingDetail.listingType.nameUz,
      nameRu: listingDetail.listingType.nameRu,
      nameEn: listingDetail.listingType.nameEn,
      language: language,
    );
    typeInfo = "\n🏠 $typeName";

    // Build subway station info
    var subwayInfo = "";
    if (listingDetail.subwayStation != null) {
      final stationName = _getLocalizedName(
        nameUz: listingDetail.subwayStation!.nameUz,
        nameRu: listingDetail.subwayStation!.nameRu,
        nameEn: listingDetail.subwayStation!.nameEn,
        language: language,
      );
      subwayInfo = "\n🚇 $stationName";
    }

    final deepLink = DeepLinkService.buildListingDeepLink(listingDetail.id);

    return """$title$typeInfo$locationInfo$subwayInfo

${description.isNotEmpty ? "$description\n" : ""}💰 ${PriceRangeHelper.formatStoredListingPrice(
      storedPrice: price,
      listingTypeCode: listingDetail.listingType.code,
      minPrice: listingDetail.minPrice,
      maxPrice: listingDetail.maxPrice,
    )}

📱 ${L10n.get("check_out_listing_on_uydosh")}

🔗 $deepLink""";
  }

  String _buildPhotoUrl(String photoUrl) {
    logger.d("🔍 [Photo URL] Original photoUrl: $photoUrl");

    // If the URL is already absolute, return it as is
    if (photoUrl.startsWith("http://") || photoUrl.startsWith("https://")) {
      logger.d("🔍 [Photo URL] Already absolute, returning: $photoUrl");
      return photoUrl;
    }

    // If it"s a relative URL, prepend the base URL
    // Since images are stored on EC2 instance, they should be served from the same domain
    // You can configure this base URL in your app config
    final fullUrl = "${EnvironmentUtil.basePath}$photoUrl";
    logger.d("🔍 [Photo URL] Constructed full URL: $fullUrl");
    return fullUrl;
  }

  void _toastRoom3dOpenError() {
    ToastReporting.errorKey(context, "room_3d_open_error");
  }

  void _showListingId() {
    ToastReporting.infoMessage(
      context,
      L10n.getWithParams(
        "listing_detail_id",
        params: {"id": widget.listingId.toString()},
      ),
    );
  }

  Future<void> _openRoom3dViewer(ListingDetail listingDetail) async {
    if (_isOpeningRoom3d) return;
    final raw = listingDetail.pointCloudUrl;
    if (raw == null || raw.isEmpty) return;
    setState(() => _isOpeningRoom3d = true);
    HapticFeedbackUtils.impact();
    final url = _buildPhotoUrl(raw);
    try {
      if (kIsWeb) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
        return;
      }
      await UserListingState().initialize();
      final role = (await SessionManager.getUserRole())?.toLowerCase().trim();
      final isAdmin = role == "admin";
      // Admins get the same edit privileges as the owner (north orientation slider + metrics backfill).
      final canEditAsOwner = _isListingOwner(listingDetail.user.id) || isAdmin;
      final metricsMissing = listingDetail.roomScanMetricsMissing;
      final ok = await RoomUsdzViewerService.downloadAndPresent(
        url,
        listingId: listingDetail.id,
        languageCode: LanguageState().currentLanguage,
        publishMetricsIfMissing: canEditAsOwner && metricsMissing,
        worldPlusXBearingDeg: listingDetail.roomScanWorldPlusXBearingDeg,
        northCorrectionDeg: listingDetail.roomScanNorthCorrectionDeg,
        isListingOwner: canEditAsOwner,
      );
      if (!mounted) return;
      if (!ok) {
        _toastRoom3dOpenError();
      } else {
        // iOS resolves `presentLocalFile` when the viewer is dismissed; backfilled metrics
        // may already be on the server — reload listing so the tile shows dimensions.
        await Future<void>.delayed(const Duration(milliseconds: 280));
        if (!mounted) return;
        try {
          final fresh =
              await getIt<IListingService>().getListingDetail(listingDetail.id);
          if (!mounted) return;
          context.read<ListingDetailBloc>().add(
                ListingDetailEvent.updateListingDetail(listingDetail: fresh),
              );
        } catch (e, st) {
          logger.d("Listing refresh after 3D viewer failed: $e\n$st");
        }
      }
    } on MissingPluginException catch (e, st) {
      logger.d("Room 3D viewer missing-plugin: $e\n$st");
      _toastRoom3dOpenError();
    } on PlatformException catch (e, st) {
      logger.d("Room 3D viewer platform error: ${e.code} ${e.message}\n$st");
      _toastRoom3dOpenError();
    } on DioException catch (e) {
      logger.d(
        "Room 3D viewer network error (status=${e.response?.statusCode}): $e",
      );
      if (!mounted) return;
      final status = e.response?.statusCode;
      if (status == 404) {
        _toastRoom3dOpenError();
        return;
      }
      if (status == 401 || status == 403) {
        ToastReporting.errorKey(context, "error_not_authenticated");
        return;
      }
      _toastRoom3dOpenError();
    } catch (e) {
      logger.d("Room 3D viewer error: $e");
      _toastRoom3dOpenError();
    } finally {
      if (mounted) {
        setState(() => _isOpeningRoom3d = false);
      } else {
        _isOpeningRoom3d = false;
      }
    }
  }

  void _openFullScreenPhotoViewer(int initialIndex) {
    final currentState = context.read<ListingDetailBloc>().state;
    currentState.map(
      initial: (_) => null,
      loading: (_) => null,
      loaded: (loadedState) {
        final photos = loadedState.listingDetail.photos;
        if (photos != null && photos.isNotEmpty) {
          // Use ordered photos for the fullscreen viewer
          final orderedPhotos = _getOrderedPhotos(photos);
          final photoUrls = orderedPhotos
              .map((photo) => (photo as Photo).networkDisplayPhotoUrl)
              .toList()
              .cast<String>();

          // Adjust the initial index based on the new order
          final orderedInitialIndex = orderedPhotos.indexWhere(
            (photo) => photos.indexOf(photo) == initialIndex,
          );

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FullScreenPhotoViewer(
                photoUrls: photoUrls,
                initialIndex:
                    orderedInitialIndex >= 0 ? orderedInitialIndex : 0,
                baseUrl: EnvironmentUtil.basePath,
              ),
            ),
          );
        }
      },
      error: (_) => null,
    );
  }

  // Helper method to get photos in correct order (primary first)
  List<dynamic> _getOrderedPhotos(List<dynamic> photos) {
    final orderedPhotos = List<dynamic>.from(photos);

    // Find the primary photo and move it to the front
    final primaryPhotoIndex = orderedPhotos.indexWhere(
      (photo) => photo.isPrimary,
    );
    if (primaryPhotoIndex != -1 && primaryPhotoIndex != 0) {
      // Remove primary photo from current position and insert at beginning
      final primaryPhoto = orderedPhotos.removeAt(primaryPhotoIndex);
      orderedPhotos.insert(0, primaryPhoto);
    }

    return orderedPhotos;
  }

  String _getShareSubject(String language) {
    switch (language) {
      case "uz":
        return L10n.get("share_subject_uz");
      case "ru":
        return L10n.get("share_subject_ru");
      case "en":
        return L10n.get("share_subject_en");
      default:
        return L10n.get("share_subject_en");
    }
  }

  void _showShareError(String message) {
    ToastReporting.errorMessage(context, message);
  }

  void _navigateToSignIn() => AuthFlow.openSignIn(context);

  void _editListing() {
    // Get the current listing detail from the bloc state
    final currentState = context.read<ListingDetailBloc>().state;

    currentState.map(
      initial: (_) => _showEditError(
        L10n.get(
          "error_listing_not_loaded",
        ),
      ),
      loading: (_) => _showEditError(
        L10n.get(
          "error_listing_still_loading",
        ),
      ),
      loaded: (loadedState) => _navigateToEdit(loadedState.listingDetail),
      error: (errorState) => _showEditError(
        L10n.get(
          "error_loading_listing_details",
        ),
      ),
    );
  }

  Future<void> _navigateToEdit(ListingDetail listingDetail) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider<SubwayStationsBloc>(
              create: (context) => SubwayStationsBloc(),
            ),
            BlocProvider<LocationsBloc>(
              create: (context) => LocationsBloc(getIt<ILocationService>()),
            ),
          ],
          child: EditListingScreen(listingDetail: listingDetail),
        ),
      ),
    );

    // If the listing was updated, refresh the data
    if (result == true) {
      HomeRefreshState().markForRefresh();

      // Fetch fresh data from server (bloc emits loading then loaded)
      context.read<ListingDetailBloc>().add(
            ListingDetailEvent.fetchListingDetail(id: widget.listingId),
          );
    }
  }

  void _showEditError(String message) {
    ToastReporting.errorMessage(context, message);
  }

  Future<void> _toggleFeatureListing() async {
    // Get the current listing detail from the bloc state
    final currentState = context.read<ListingDetailBloc>().state;

    currentState.map(
      initial: (_) => _showFeatureError(
        L10n.get(
          "error_listing_not_loaded",
        ),
      ),
      loading: (_) => _showFeatureError(
        L10n.get(
          "error_listing_still_loading",
        ),
      ),
      loaded: (loadedState) => _performToggleFeature(loadedState.listingDetail),
      error: (errorState) => _showFeatureError(
        L10n.get(
          "error_loading_listing_details",
        ),
      ),
    );
  }

  static const _promotionCooldownDays = 7;

  Future<bool> _canPromoteListing() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return true; // Fallback if somehow unauthenticated
    final prefs = await SharedPreferences.getInstance();
    final key = "promotion_last_used_$userId";
    final lastUsedMillis = prefs.getInt(key);
    if (lastUsedMillis == null) return true;
    final lastUsed = DateTime.fromMillisecondsSinceEpoch(lastUsedMillis);
    final now = DateTime.now();
    return now.difference(lastUsed).inDays >= _promotionCooldownDays;
  }

  Future<void> _savePromotionTimestamp() async {
    final userId = await SessionManager.getUserId();
    if (userId == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      "promotion_last_used_$userId",
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _performToggleFeature(ListingDetail listingDetail) async {
    try {
      final isPromoting =
          !ListingUtils.isCurrentlyFeaturedDetail(listingDetail);
      if (isPromoting) {
        final canPromote = await _canPromoteListing();
        if (!canPromote) {
          _showFeatureError(
            L10n.get(
              "error_promotion_once_per_week",
            ),
          );
          return;
        }
      }

      context.read<ListingDetailPageBloc>().setToggling(true);

      // Call the toggle feature listing service
      final listingService = getIt<IListingService>();
      final success = await listingService.toggleFeatureListing(
        listingDetail.id,
        ListingUtils.isCurrentlyFeaturedDetail(listingDetail),
      );

      if (success) {
        if (ListingUtils.isCurrentlyFeaturedDetail(listingDetail)) {
          ToastReporting.successKey(context, "unfeature_listing_success");
        } else {
          ToastReporting.successKey(context, "feature_listing_success");
        }

        if (isPromoting) {
          await _savePromotionTimestamp();
        }

        // Update the listing detail with new featured state
        final updatedListingDetail = listingDetail.copyWith(
          featuredAt: !ListingUtils.isCurrentlyFeaturedDetail(listingDetail)
              ? DateTime.now().toIso8601String()
              : null,
        );

        // Update the bloc state
        context.read<ListingDetailBloc>().add(
              ListingDetailEvent.updateListingDetail(
                listingDetail: updatedListingDetail,
              ),
            );

        // Mark home screen for refresh since listing featured state changed
        HomeRefreshState().markForRefresh();
      } else {
        _showFeatureError(
          L10n.get(
            "feature_listing_error",
          ),
        );
      }
    } catch (e) {
      logger.e("Error toggling feature listing: $e");
      _showFeatureError(
        L10n.get("feature_listing_error"),
      );
    } finally {
      if (mounted) {
        context.read<ListingDetailPageBloc>().setToggling(false);
      }
    }
  }

  void _showFeatureError(String message) {
    ToastReporting.errorMessage(context, message);
  }

  Future<void> _toggleFavorite() async {
    triggerFavoriteToggleFeedback();

    final favoritesState = FavoritesState();
    final isFavorite = favoritesState.isFavorite(widget.listingId);

    // Store current state to determine if we're adding or removing
    final wasFavorite = isFavorite;

    // Call API to toggle favorite
    try {
      final favoriteService = FavoriteService(
        OAuthApiClient(
          configurator: OAuthDioConfigurator(tokenRepo: AuthTokenRepository()),
        ),
      );

      final success = await favoriteService.toggleFavorite(widget.listingId);

      if (success) {
        // Update global state to keep it in sync
        await favoritesState.toggleFavorite(widget.listingId);

        if (wasFavorite) {
          getIt<AppAnalyticsService>()
              .logFavoriteRemoved(listingId: widget.listingId);
        } else {
          getIt<AppAnalyticsService>()
              .logFavoriteAdded(listingId: widget.listingId);
        }

        // Show success message
        if (wasFavorite) {
          ToastReporting.successKey(context, "removed_from_favorites");
        } else {
          ToastReporting.successKey(context, "added_to_favorites");
        }
      } else {
        // Show error message to user
        ToastReporting.errorKey(context, "favorite_toggle_network_error");
      }
    } catch (e) {
      logger.d("❌ Error toggling favorite: $e");
      // Show error message to user
      ToastReporting.errorKey(context, "favorite_toggle_network_error");
    }
  }

  List<ActionMenuItem> _buildActionMenuItems(
    ListingDetail listingDetail, {
    required bool isListingStaff,
    required bool isStrictAdmin,
  }) {
    final isOwner = _isListingOwner(listingDetail.user.id);
    final authState = AuthenticationState();
    final isAuthenticated = authState.isAuthenticated;
    final menuEnabled = isAuthenticated;

    final items = <ActionMenuItem>[];

    if (!isAuthenticated) {
      items.add(
        ActionMenuItem(
          value: "sign_in",
          icon: Icons.login,
          textKey: "sign_in",
          onPressed: _navigateToSignIn,
        ),
      );
    }

    // Chat option - only show when not owner and internal chat is allowed.
    if (_canShowInAppListingChat(listingDetail)) {
      items.add(
        ActionMenuItem(
          value: "chat",
          icon: CupertinoIcons.bubble_left_bubble_right,
          textKey: "chat",
          onPressed: () => _startConversation(listingDetail),
          enabled: isAuthenticated,
        ),
      );
    }

    // Profile option - only show when not owner
    if (!isOwner) {
      items.add(
        ActionMenuItem(
          value: "profile",
          icon: Icons.person_outline,
          textKey: "profile",
          onPressed: () => _navigateToProfile(listingDetail.user.id),
          enabled: menuEnabled,
        ),
      );
    }

    // Favorite option - only show when authenticated and not owner
    if (!isOwner) {
      final favoritesState = FavoritesState();
      final isFavorite = favoritesState.isFavorite(widget.listingId);

      items.add(
        ActionMenuItem(
          value: "favorite",
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          textKey: isFavorite ? "remove_from_favorites" : "add_to_favorites",
          onPressed: _toggleFavorite,
          iconColor: isFavorite ? AppColors.favoriteActive : null,
          enabled: isAuthenticated,
        ),
      );
    }

    // Edit option - show for listing owner or moderation staff
    if (isOwner || isListingStaff) {
      items.add(
        ActionMenuItem(
          value: "edit",
          icon: Icons.edit,
          textKey: "edit",
          onPressed: _editListing,
          labelFontWeight: isListingStaff && !isOwner ? FontWeight.w600 : null,
        ),
      );
    }

    // Deactivate/Activate option - only show for listing owner
    if (isOwner) {
      items.add(
        ActionMenuItem(
          value: "toggle_active",
          icon: listingDetail.isActive
              ? Icons.pause_circle_outline
              : Icons.play_circle_outline,
          textKey: listingDetail.isActive
              ? "deactivate_listing"
              : "activate_listing",
          onPressed: () => _showToggleActiveConfirmation(listingDetail.id),
        ),
      );
    }

    // Delete option - show for listing owner or moderation staff
    if (isOwner || isListingStaff) {
      items.add(
        ActionMenuItem(
          value: "delete",
          icon: Icons.delete_outline,
          textKey: "delete_listing",
          onPressed: () => _showDeleteConfirmation(listingDetail.id),
          iconColor: Colors.red,
          textColor: Colors.red,
          labelFontWeight: isListingStaff && !isOwner ? FontWeight.w600 : null,
        ),
      );
    }

    if (isListingStaff) {
      items.add(
        ActionMenuItem(
          value: "reassign_owner",
          icon: Icons.swap_horiz,
          textKey: "admin_reassign_owner_menu",
          onPressed: () {
            unawaited(_reassignListingOwner(listingDetail));
          },
          labelFontWeight: FontWeight.w600,
        ),
      );
    }

    // Admin-only: remove listing from top (unfeature) on listings the admin
    // does not own. Reuses [_toggleFeatureListing], which — because the
    // listing is currently featured — will go down the "unfeature" branch
    // (DELETE /listings/:id/feature) and skip the owner-only weekly promotion
    // cooldown.
    if (isStrictAdmin &&
        !isOwner &&
        AdminFeatureFlagsState().showListingMoveToTop &&
        ListingUtils.isCurrentlyFeaturedDetail(listingDetail)) {
      items.add(
        ActionMenuItem(
          value: "admin_remove_from_top",
          icon: CupertinoIcons.arrow_down_circle,
          textKey: "remove_from_top",
          onPressed: _toggleFeatureListing,
          iconColor: Colors.red,
          textColor: Colors.red,
          labelFontWeight: FontWeight.w600,
        ),
      );
    }

    // Share option - always show
    items.add(
      ActionMenuItem(
        value: "share",
        icon: Icons.ios_share,
        textKey: "share",
        onPressed: _shareListing,
        enabled: menuEnabled,
      ),
    );

    // Complain option - only show when not owner
    if (!isOwner) {
      items.add(
        ActionMenuItem(
          value: "complain",
          icon: CupertinoIcons.exclamationmark_circle_fill,
          textKey: "complain",
          onPressed: () => _createComplaint(listingDetail),
          enabled: menuEnabled,
          iconColor: Colors.red,
          textColor: Colors.red,
        ),
      );
    }

    return items;
  }

  Future<void> _createComplaint(ListingDetail listingDetail) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<ComplaintBloc>(
          create: (context) => ComplaintBloc(getIt<IComplaintService>()),
          child: CreateComplaintScreen(listingId: listingDetail.id),
        ),
      ),
    );

    // If complaint was created successfully, show a message
    if (result == true) {
      ToastReporting.successKey(context, "complaint_created_success");
      _loadComplaintCount(listingDetail.id);
    }
  }

  void _viewListingComplaints(int listingId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider<ComplaintBloc>(
          create: (context) => ComplaintBloc(getIt<IComplaintService>()),
          child: ListingComplaintsScreen(listingId: listingId),
        ),
      ),
    );
  }

  void _openAdminListingOwnerConversations(ListingDetail listingDetail) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            AdminListingOwnerConversationsScreen(listingDetail: listingDetail),
      ),
    );
  }

  Future<void> _prefetchAdminListingConversationsIfNeeded() async {
    final role = await _userRoleFuture;
    if (role != "admin") return;
    await ClientAdminListingConversationsConfig.ensureLoaded();
  }

  Future<void> _reassignListingOwner(ListingDetail listingDetail) async {
    final ok = await showReassignOwnerDialog(
      context,
      entityType: AdminEntityOwnershipType.listing,
      entityId: listingDetail.id,
      fromUserId: listingDetail.user.id,
    );
    if (!ok || !mounted) return;
    context.read<ListingDetailBloc>().add(
          ListingDetailEvent.fetchListingDetail(id: widget.listingId),
        );
  }

  Future<void> _startConversation(ListingDetail listingDetail) async {
    final pageState = context.read<ListingDetailPageBloc>().state;
    final displayName =
        _resolvedListingOwnerDisplayLabel(listingDetail, pageState);

    await ConversationEntryFlow.openListingThread(
      context: context,
      listingDetail: listingDetail,
      analyticsListingRouteId: widget.listingId,
      pushNewThread: (conversation) async {
        await ConversationEntryFlow.pushChatShell(
          context,
          conversationId: conversation.id,
          chatScreenChild: ChatScreen(
            conversationId: conversation.id,
            listingId: widget.listingId,
            listingTypeId: listingDetail.listingTypeId,
            listingOwnerUserId: listingDetail.user.id,
            listingTitle:
                resolvedListingChatTitleFromListingDetail(listingDetail),
            otherUserInitials: StringUtils.extractInitials(displayName),
            otherUserName: displayName.isNotEmpty ? displayName : null,
            otherUserId: listingDetail.user.id,
          ),
        );
      },
      pushExistingThread: (existingConversation, currentUserId) async {
        await ConversationEntryFlow.pushChatShell(
          context,
          conversationId: existingConversation.id,
          chatScreenChild: ChatScreen(
            conversationId: existingConversation.id,
            listingId: widget.listingId,
            listingTypeId: existingConversation.listingTypeId,
            listingOwnerUserId: existingConversation.participantId,
            listingTitle:
                resolvedConversationListingTitle(existingConversation),
            otherUserInitials: StringUtils.extractInitials(
              existingConversation.otherUserName,
            ),
            otherUserName: existingConversation.otherUserName,
            otherUserId: existingConversation.initiatorId == currentUserId
                ? existingConversation.participantId
                : existingConversation.initiatorId,
            otherUserAvatar: existingConversation.otherUserAvatar,
          ),
        );
      },
    );
  }

  Future<void> _confirmOpenInYandexMaps(ListingDetail listingDetail) async {
    final shouldOpen = await CommonConfirmationDialogs.showGenericConfirmation(
      context: context,
      titleKey: "open_in_yandex_maps",
      messageKey: "open_in_yandex_maps_confirmation",
      confirmButtonKey: "confirm",
    );

    if (shouldOpen ?? false) {
      await _openInYandexMaps(listingDetail);
    }
  }

  Future<void> _openInYandexMaps(ListingDetail listingDetail) async {
    try {
      // Get coordinates from the listing detail
      final coordinates = _getCoordinatesFromListing(listingDetail);
      if (coordinates == null) {
        ToastReporting.errorKey(context, "error_loading_listing_details");
        return;
      }

      final latitude = coordinates["latitude"]!;
      final longitude = coordinates["longitude"]!;

      // Create Yandex Maps URL
      final yandexMapsUrl =
          "https://yandex.com/maps/?pt=$longitude,$latitude&z=16&l=map";

      final uri = Uri.parse(yandexMapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ToastReporting.errorMessage(context, "Could not open Yandex Maps");
      }
    } catch (e) {
      logger.e("Error opening Yandex Maps: $e");
      ToastReporting.errorMessage(context, "Error opening Yandex Maps");
    }
  }

  Future<void> _openStoreInYandexMaps(ListingNearbyStore store) async {
    final yandexMapsUrl =
        "https://yandex.com/maps/?pt=${store.longitude},${store.latitude}&z=17&l=map";
    final uri = Uri.parse(yandexMapsUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    ToastReporting.errorKey(context, "error_loading_listing_details");
  }

  Map<String, double>? _getCoordinatesFromListing(ListingDetail listingDetail) {
    final addressLatitude = listingDetail.addressLatitude;
    final addressLongitude = listingDetail.addressLongitude;
    if (addressLatitude != null && addressLongitude != null) {
      return {
        "latitude": addressLatitude,
        "longitude": addressLongitude,
      };
    }

    // Try to get coordinates from metro station first (highest priority)
    if (listingDetail.subwayStation != null) {
      // Try to get coordinates by station ID first
      final coordsById = MetroCache.getMetroStationCoordinatesById(
        listingDetail.subwayStation!.id,
      );
      if (coordsById != null) {
        return coordsById;
      }

      // Fallback to name-based lookup
      final stationName = listingDetail.subwayStation?.nameEn ??
          listingDetail.subwayStation?.nameRu ??
          listingDetail.subwayStation?.nameUz;

      if (stationName != null && stationName.isNotEmpty) {
        final coordsByName = MetroCache.getMetroStationCoordinatesByName(
          stationName,
        );
        if (coordsByName != null) {
          return coordsByName;
        }
      }
    }

    // Try to get coordinates from location (lower priority)
    if (listingDetail.location != null) {
      // Try to get coordinates by location ID first
      final coordsById = LocationCache.getLocationCoordinatesById(
        listingDetail.location!.id,
      );
      if (coordsById != null) {
        return coordsById;
      }

      // Fallback to name-based lookup
      final locationName = listingDetail.location?.nameEn ??
          listingDetail.location?.nameRu ??
          listingDetail.location?.nameUz;

      if (locationName != null && locationName.isNotEmpty) {
        final coordsByName = LocationCache.getLocationCoordinatesByName(
          locationName,
        );
        if (coordsByName != null) {
          return coordsByName;
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ListingDetailBloc, ListingDetailState>(
      listener: (context, state) {
        state.map(
          initial: (_) {},
          loading: (_) {},
          loaded: (loadedState) {
            // Check favorite status after listing data is loaded
            _checkFavoriteStatusFromServer();
            _loadComplaintCount(loadedState.listingDetail.id);
            _onListingLoaded(loadedState.listingDetail);
          },
          error: (_) {},
        );
      },
      child: ListenableBuilder(
        listenable: ThemeState(),
        builder: (context, _) {
          final themeState = ThemeState();
          final theme = Theme.of(context);
          final appBarTheme = theme.appBarTheme;
          final useLiquidGlassAppBar =
              themeState.isBlueTheme || themeState.isLightTheme;
          return Scaffold(
            extendBodyBehindAppBar: useLiquidGlassAppBar,
            // Mirror [extendBodyBehindAppBar] for the bottom bar so the
            // sticky [ListingDetailContactActionBar] can render a frosted
            // backdrop blur over the scrolling body (liquid glass footer).
            // The body's scroll padding compensates below so the last row
            // of content still clears the bar.
            extendBody: useLiquidGlassAppBar,
            appBar: UydoshAppBar(
              backgroundColor: useLiquidGlassAppBar
                  ? liquidGlassAppBarMaterialColor(context)
                  : _getAppBarBackgroundColor(),
              surfaceTintColor: useLiquidGlassAppBar
                  ? Colors.transparent
                  : appBarTheme.surfaceTintColor,
              elevation: useLiquidGlassAppBar ? 0 : null,
              scrolledUnderElevation: useLiquidGlassAppBar ? 0 : null,
              shadowColor: useLiquidGlassAppBar
                  ? Colors.transparent
                  : appBarTheme.shadowColor,
              forceMaterialTransparency: useLiquidGlassAppBar,
              flexibleSpace: useLiquidGlassAppBar
                  ? const LiquidGlassAppBarFlexibleSpace()
                  : null,
              foregroundColor:
                  appBarTheme.foregroundColor ?? AppColors.textLight,
              centerTitle: true,
              leading: ThreeDAppBarIconButton.backLeading(
                context,
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _showListingId,
                child: L10n.text(
                  "listing_details",
                  style: appBarTheme.titleTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              actionsPadding: const EdgeInsets.only(right: 8),
              actions: [
                BlocSelector<ListingDetailBloc, ListingDetailState,
                    _ListingDetailIconsData>(
                  selector: (state) => state.map(
                    initial: (_) => const _ListingDetailIconsData(
                      isLoading: true,
                      hasError: false,
                      errorMessage: "",
                      listingDetail: null,
                    ),
                    loading: (_) => const _ListingDetailIconsData(
                      isLoading: true,
                      hasError: false,
                      errorMessage: "",
                      listingDetail: null,
                    ),
                    loaded: (loadedState) => _ListingDetailIconsData(
                      isLoading: false,
                      hasError: false,
                      errorMessage: "",
                      listingDetail: loadedState.listingDetail,
                    ),
                    error: (errorState) => _ListingDetailIconsData(
                      isLoading: false,
                      hasError: true,
                      errorMessage: errorState.message,
                      listingDetail: null,
                    ),
                  ),
                  builder: (context, data) {
                    if (data.isLoading || data.listingDetail == null) {
                      return const SizedBox.shrink();
                    }

                    final listingDetail = data.listingDetail!;
                    return ListenableBuilder(
                      listenable: Listenable.merge([
                        AuthenticationState(),
                        FavoritesState().listenableFor(widget.listingId),
                      ]),
                      builder: (context, _) {
                        final isAuthenticated =
                            AuthenticationState().isAuthenticated;
                        final actionMenu = !isAuthenticated
                            ? ActionDropdownMenu(
                                items: _buildActionMenuItems(
                                  listingDetail,
                                  isListingStaff: false,
                                  isStrictAdmin: false,
                                ),
                              )
                            : FutureBuilder<String?>(
                                future: _userRoleFuture,
                                builder: (context, snapshot) {
                                  final role = snapshot.data;
                                  final isListingStaff =
                                      ModerationStaffUtils.isModerationStaff(
                                    role,
                                  );
                                  final isStrictAdmin = role == "admin";
                                  return ActionDropdownMenu(
                                    items: _buildActionMenuItems(
                                      listingDetail,
                                      isListingStaff: isListingStaff,
                                      isStrictAdmin: isStrictAdmin,
                                    ),
                                  );
                                },
                              );
                        return SizedBox(
                          width: kToolbarHeight,
                          child: Center(child: actionMenu),
                        );
                      },
                    );
                  },
                ),
              ],
              automaticallyImplyLeading: false,
            ),
            body: BlocSelector<ListingDetailBloc, ListingDetailState,
                _ListingDetailBodyData>(
              selector: (state) => state.map(
                initial: (_) => const _ListingDetailBodyData(
                  isLoading: true,
                  hasError: false,
                  errorMessage: "",
                  listingDetail: null,
                ),
                loading: (_) => const _ListingDetailBodyData(
                  isLoading: true,
                  hasError: false,
                  errorMessage: "",
                  listingDetail: null,
                ),
                loaded: (loadedState) => _ListingDetailBodyData(
                  isLoading: false,
                  hasError: false,
                  errorMessage: "",
                  listingDetail: loadedState.listingDetail,
                ),
                error: (errorState) => _ListingDetailBodyData(
                  isLoading: false,
                  hasError: true,
                  errorMessage: errorState.message,
                  listingDetail: null,
                ),
              ),
              builder: (context, data) {
                if (data.isLoading) {
                  return data.listingDetail == null
                      ? _buildInitialState()
                      : _buildLoadingState();
                }
                if (data.hasError) {
                  return _buildErrorState(data.errorMessage);
                }
                // Only rebuild the big static body when a field it directly uses
                // changes. The 3 hot sub-sections below (owner toolbar,
                // compatibility, complaints) have their own BlocSelectors that
                // rebuild surgically on the relevant fields only, so we exclude
                // those from the outer buildWhen.
                return BlocBuilder<ListingDetailPageBloc,
                    ListingDetailPageState>(
                  buildWhen: (prev, curr) =>
                      prev.ownerName != curr.ownerName ||
                      prev.ownerAvatarUrl != curr.ownerAvatarUrl,
                  builder: (context, pageState) =>
                      _buildLoadedStateWithFloatingGroupChat(
                    data.listingDetail!,
                    pageState,
                  ),
                );
              },
            ),
            bottomNavigationBar: _buildContactActionBar(),
          );
        },
      ),
    );
  }

  Widget _buildLoadedStateWithFloatingGroupChat(
    ListingDetail listingDetail,
    ListingDetailPageState pageState,
  ) {
    final content = _buildLoadedState(listingDetail, pageState);
    final groupMembers = pageState.groupMembers;
    if (!_canShowFloatingGroupActions(listingDetail)) {
      return content;
    }

    final showShortlist = _canShowGroupShortlistPill(listingDetail);
    final showChat = _canShowFloatingGroupChatButton(listingDetail);
    final showParticipants =
        _canShowFloatingGroupParticipantsButton(listingDetail);
    final groupProgress = ListingGroupProgress.fromListingDetail(listingDetail);
    final pendingRequestsCount =
        listingDetail.groupContext?.pendingJoinRequestCount ?? 0;
    final participantLabel = groupProgress != null
        ? L10n.getWithParams(
            "group_floating_chat_label",
            params: {
              "current": "${groupProgress.current}",
              "target": "${groupProgress.target}",
            },
          )
        : L10n.get("group_open_chat");

    return Stack(
      children: [
        Positioned.fill(child: content),
        Positioned(
          right: _floatingGroupActionsBottomInset,
          bottom: _floatingGroupActionsBottomInset +
              MediaQuery.paddingOf(context).bottom,
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showShortlist)
                  GroupShortlistPillButton(
                    groupListingId: listingDetail.id,
                    isOwner: listingDetail.groupContext?.isOwner == true,
                    groupListingDetail: listingDetail,
                    onChanged: _reloadListingDetail,
                    compact: true,
                  ),
                if (showShortlist && showParticipants)
                  const SizedBox(height: _floatingGroupActionsGap),
                if (showParticipants)
                  _FloatingGroupParticipantsButton(
                    members: groupMembers,
                    memberCount: groupProgress?.current ?? groupMembers.length,
                    currentUserId: _sessionUserId,
                    showDot: pendingRequestsCount > 0,
                    dotTrigger: pendingRequestsCount,
                    onPressed: () {
                      HapticFeedbackUtils.impact();
                      unawaited(
                        _openGroupMemberProfiles(
                          listingDetail,
                          groupMembers,
                          isOwner: _isListingOwner(listingDetail.user.id),
                        ),
                      );
                    },
                  ),
                if ((showShortlist || showParticipants) && showChat)
                  const SizedBox(height: _floatingGroupActionsGap),
                if (showChat)
                  ListenableBuilder(
                    listenable: UnreadMessagesState(),
                    builder: (context, _) {
                      return _FloatingGroupChatButton(
                        label: participantLabel,
                        hasUnread: _hasUnreadGroupChat(listingDetail),
                        unreadTrigger: UnreadMessagesState().unreadCount,
                        onPressed: () {
                          HapticFeedbackUtils.impact();
                          _openGroupChat(listingDetail);
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Sticky bottom action bar with "Message in chat" + "View profile" so
  /// contacting the listing owner is always one tap away, independent of
  /// whether the compatibility section is expanded/collapsed.
  Widget? _buildContactActionBar() {
    return BlocSelector<ListingDetailBloc, ListingDetailState,
        _ListingDetailBodyData>(
      selector: (state) => state.map(
        initial: (_) => const _ListingDetailBodyData(
          isLoading: true,
          hasError: false,
          errorMessage: "",
          listingDetail: null,
        ),
        loading: (_) => const _ListingDetailBodyData(
          isLoading: true,
          hasError: false,
          errorMessage: "",
          listingDetail: null,
        ),
        loaded: (loadedState) => _ListingDetailBodyData(
          isLoading: false,
          hasError: false,
          errorMessage: "",
          listingDetail: loadedState.listingDetail,
        ),
        error: (errorState) => _ListingDetailBodyData(
          isLoading: false,
          hasError: true,
          errorMessage: errorState.message,
          listingDetail: null,
        ),
      ),
      builder: (context, data) {
        final listingDetail = data.listingDetail;
        if (data.isLoading || data.hasError || listingDetail == null) {
          return const SizedBox.shrink();
        }
        // Group-forming CTAs are inline at the bottom of the scroll body.
        if (_isGroupFormingListing(listingDetail)) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder<bool>(
          valueListenable: ClientListingContactsConfig.showListingContacts,
          builder: (context, showContacts, _) {
            return ListenableBuilder(
              listenable: UserListingState(),
              builder: (context, _) {
                final isOwner = _isListingOwner(listingDetail.user.id);
                final telegramHandle =
                    listingDetail.contactTelegram?.trim() ?? "";
                final telegramAvailable =
                    showContacts && telegramHandle.isNotEmpty;
                final onTelegram = telegramAvailable
                    ? () => _openTelegramChat(listingDetail.contactTelegram!)
                    : null;

                if (isOwner) {
                  if (telegramHandle.isEmpty) return const SizedBox.shrink();
                  return FutureBuilder<String?>(
                    future: _userRoleFuture,
                    builder: (context, snapshot) {
                      if (snapshot.data != "admin") {
                        return const SizedBox.shrink();
                      }
                      return ListingDetailContactActionBar(
                        onTelegram: () =>
                            _openTelegramChat(listingDetail.contactTelegram!),
                      );
                    },
                  );
                }

                return BlocSelector<ListingDetailPageBloc,
                    ListingDetailPageState, String>(
                  selector: (pageState) => _resolvedListingOwnerDisplayLabel(
                    listingDetail,
                    pageState,
                  ),
                  builder: (context, ownerResolved) {
                    final showInAppChat =
                        _canShowInAppListingChat(listingDetail);
                    if (!showInAppChat && onTelegram == null) {
                      return const SizedBox.shrink();
                    }
                    final l10n = context.l10n;
                    final chatCtaLabel = ownerResolved.isNotEmpty
                        ? l10n.chat_with(ownerResolved)
                        : l10n.uydosh_chat;
                    return ListingDetailContactActionBar(
                      onMessage: showInAppChat
                          ? () => _startConversation(listingDetail)
                          : null,
                      onTelegram: onTelegram,
                      inAppChatCtaLabel: chatCtaLabel,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInitialState() {
    return const ListingDetailLoadingBody();
  }

  Widget _buildLoadingState() {
    return ListingDetailLoadingBody(
      textStyle: TextStyle(
        color: _getLoadingTextColor(),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget? _buildCompatibilitySection(
    ListingDetail listingDetail,
  ) {
    final isOwner = _isListingOwner(listingDetail.user.id);
    // One-on-one compatibility is viewer vs owner; hide for owners. Group
    // compatibility is about the whole forming group — owners need it too.
    if (isOwner && !_isGroupFormingListing(listingDetail)) return null;

    if (_isGroupFormingListing(listingDetail) &&
        !ListingGroupProgress.canShowGroupCompatibility(listingDetail)) {
      return null;
    }

    // Scoped to the compatibility fields of pageState so async compatibility
    // calculation emissions only rebuild this section.
    return BlocSelector<
        ListingDetailPageBloc,
        ListingDetailPageState,
        ({
          int? compatibilityPercent,
          bool isLoadingCompatibility,
          String? compatibilityError,
          List<CompatibilityMatch> matches,
          List<CompatibilityDifference> differences,
          List<CompatibilityDifference> dealbreakers,
          int compatibilityScoredFieldCount,
          int compatibilityTotalFieldCount,
          String? ownerAvatarUrl,
          String? currentUserAvatarUrl,
          bool isGroupCompatibility,
          List<ConversationMemberSummary> groupMembers,
          List<GroupCompatibilityFullMatch> groupFullMatches,
          List<GroupCompatibilityPartialMatch> groupPartialMatches,
          List<GroupCompatibilityDiscussItem> groupDiscussItems,
          List<GroupPreferenceMatrixRow> groupPreferenceMatrix,
          Map<int, GroupMemberCompatibilitySummary> groupMemberCompatibility,
          bool canViewGroupCompatibilityDetails,
        })>(
      selector: (s) => (
        compatibilityPercent: s.compatibilityPercent,
        isLoadingCompatibility: s.isLoadingCompatibility,
        compatibilityError: s.compatibilityError,
        matches: s.compatibilityMatches,
        differences: s.compatibilityDifferences,
        dealbreakers: s.compatibilityDealbreakers,
        compatibilityScoredFieldCount: s.compatibilityScoredFieldCount,
        compatibilityTotalFieldCount: s.compatibilityTotalFieldCount,
        ownerAvatarUrl: s.ownerAvatarUrl,
        currentUserAvatarUrl: s.currentUserAvatarUrl,
        isGroupCompatibility: s.isGroupCompatibility,
        groupMembers: s.groupMembers,
        groupFullMatches: s.groupFullMatches,
        groupPartialMatches: s.groupPartialMatches,
        groupDiscussItems: s.groupDiscussItems,
        groupPreferenceMatrix: s.groupPreferenceMatrix,
        groupMemberCompatibility: s.groupMemberCompatibility,
        canViewGroupCompatibilityDetails: s.canViewGroupCompatibilityDetails,
      ),
      builder: (context, compat) => ListingDetailCompatibilitySection(
        listingDetail: listingDetail,
        scrollController: _scrollController,
        sectionKey: _compatibilitySectionKey,
        compatibilityPercent: compat.compatibilityPercent,
        isLoadingCompatibility: compat.isLoadingCompatibility,
        compatibilityError: compat.compatibilityError,
        matches: compat.matches,
        differences: compat.differences,
        dealbreakers: compat.dealbreakers,
        scoredFieldCount: compat.compatibilityScoredFieldCount,
        totalFieldCount: compat.compatibilityTotalFieldCount,
        currentUserAvatarUrl: compat.currentUserAvatarUrl,
        ownerAvatarUrl: compat.ownerAvatarUrl,
        isGroupCompatibility: compat.isGroupCompatibility,
        groupMembers: compat.groupMembers,
        groupFullMatches: compat.groupFullMatches,
        groupPartialMatches: compat.groupPartialMatches,
        groupDiscussItems: compat.groupDiscussItems,
        groupPreferenceMatrix: compat.groupPreferenceMatrix,
        memberCompatibility: compat.groupMemberCompatibility,
        canViewGroupCompatibilityDetails:
            compat.canViewGroupCompatibilityDetails,
        currentUserId: _sessionUserId,
        telegramHandle: listingDetail.contactTelegram,
        phoneNumber: listingDetail.contactPhone,
        onTelegram: (listingDetail.contactTelegram?.trim().isNotEmpty ?? false)
            ? () => _openTelegramChat(listingDetail.contactTelegram!)
            : null,
        onPhone: (listingDetail.contactPhone?.trim().isNotEmpty ?? false)
            ? () => _makePhoneCall(listingDetail.contactPhone!)
            : null,
        onViewProfile: () => _navigateToProfile(listingDetail.user.id),
        onCompleteProfile: _navigateToOwnProfile,
      ),
    );
  }

  Widget _metaBadgesTile(ListingDetail listingDetail) {
    return ListingDetailMetaAndPriceTile(listingDetail: listingDetail);
  }

  Widget _room3dTile(ListingDetail listingDetail) {
    return ListingRoom3dTile(
      listingDetail: listingDetail,
      isLoading: _isOpeningRoom3d,
      onTap: _isOpeningRoom3d ? null : () => _openRoom3dViewer(listingDetail),
    );
  }

  static int _roundToStep(int value, int step) {
    if (step <= 0) return value;
    return ((value + (step / 2)).floor() ~/ step) * step;
  }

  ({double min, double max})? _similarPriceRange(ListingDetail listingDetail) {
    final p = listingDetail.price;
    if (p <= 0) return null;

    // Default band: ±20% with a minimum absolute width.
    // For Tashkent listings this avoids overly narrow ranges for low prices.
    final delta = (p * 0.20).round().clamp(0, 1 << 30);
    final absFloor = 100000; // UZS-ish floor; tweak later when needed.
    final d = delta < absFloor ? absFloor : delta;

    final minRaw = (p - d) < 0 ? 0 : (p - d);
    final maxRaw = p + d;
    const step = 10000;
    final minRounded = _roundToStep(minRaw, step);
    final maxRounded = _roundToStep(maxRaw, step);
    if (maxRounded <= 0 || maxRounded < minRounded) return null;
    return (min: minRounded.toDouble(), max: maxRounded.toDouble());
  }

  void _openNearbyMatches(ListingDetail listingDetail) {
    final filters =
        ListingDetailNearbyMatchesHelper.searchFilters(listingDetail);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ListingsBloc(getIt<IListingService>()),
          child: HomeScreen(
            listingTypeId: filters.complementaryListingTypeId,
            subwayStationId: filters.subwayStationId,
            locationId: filters.locationId,
            gender: filters.gender,
            isSearchMode: true,
            useExplicitFiltersOnly: true,
            isHomeTabActive: false,
          ),
        ),
      ),
    );
  }

  void _openSimilarResults(ListingDetail listingDetail) {
    final listingTypeId = listingDetail.listingTypeId;
    final gender = listingDetail.gender;
    final stationId = listingDetail.subwayStation?.id;
    final locationId = listingDetail.location?.id;
    final price = _similarPriceRange(listingDetail);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ListingsBloc(getIt<IListingService>()),
          child: HomeScreen(
            listingTypeId: listingTypeId,
            subwayStationId: stationId,
            locationId: stationId == null ? locationId : null,
            gender: gender,
            minPrice: price?.min,
            maxPrice: price?.max,
            isSearchMode: true,
            useExplicitFiltersOnly: true,
            isHomeTabActive: false,
          ),
        ),
      ),
    );
  }

  Widget _nearbyMatchesTile(ListingDetail listingDetail) {
    return ListingDetailNearbyMatchesTile(
      listingDetail: listingDetail,
      onTap: () {
        HapticFeedbackUtils.impact();
        _openNearbyMatches(listingDetail);
      },
    );
  }

  Widget _viewSimilarTile(ListingDetail listingDetail) {
    return ListingDetailViewSimilarTile(
      onTap: () {
        HapticFeedbackUtils.impact();
        _openSimilarResults(listingDetail);
      },
    );
  }

  Widget _nearbyStoresCard(ListingDetail listingDetail) {
    final stores = listingDetail.nearbyStores ?? const <ListingNearbyStore>[];
    return ListingDetailNearbyStoresCard(
      stores: stores,
      onStoreTap: (store) {
        HapticFeedbackUtils.impact();
        _openStoreInYandexMaps(store);
      },
    );
  }

  Widget _buildLoadedState(
    ListingDetail listingDetail,
    ListingDetailPageState pageState,
  ) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        final currentLanguage = LanguageState().currentLanguage;
        final compatibilitySection = _buildCompatibilitySection(listingDetail);

        // Pre-compute outside build: dates (avoids DateTime.parse in content card)
        final formattedMoveIn = listingDetail.moveInDate != null &&
                listingDetail.moveInDate!.isNotEmpty
            ? ListingDetailDateUtils.formatMoveInDate(
                listingDetail.moveInDate!,
                currentLanguage,
              )
            : null;
        final formattedPub = ListingDetailDateUtils.formatPublicationDate(
          context,
          listingDetail.createdAt,
        );

        // Build the list of top-level section widgets once per LanguageState
        // rebuild. Rendering them as discrete slivers (via SliverList) lets
        // Flutter skip layout/paint for sections that are scrolled off-screen
        // — a meaningful win on this screen because the owner toolbar, photo
        // carousel, compatibility panel, and map card all do non-trivial
        // work per frame when visible.
        final isOwner = _isListingOwner(listingDetail.user.id);
        final hasPhotos =
            listingDetail.photos != null && listingDetail.photos!.isNotEmpty;
        final show3d = (kIsWeb || isIOSDevice) &&
            (listingDetail.pointCloudUrl?.isNotEmpty ?? false);
        final groupFormingBottomPad =
            _groupFormingFloatingActionsBottomPad(listingDetail);

        final sections = <Widget>[
          if (isOwner)
            BlocSelector<ListingDetailPageBloc, ListingDetailPageState,
                ({int? viewCount, bool isLoadingViewCount, bool isToggling})>(
              selector: (s) => (
                viewCount: s.viewCount,
                isLoadingViewCount: s.isLoadingViewCount,
                isToggling: s.isToggling,
              ),
              builder: (context, ownerState) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ListingDetailOwnerToolbar(
                  listingDetail: listingDetail,
                  viewCount: ownerState.viewCount,
                  isLoadingViewCount: ownerState.isLoadingViewCount,
                  isToggling: ownerState.isToggling,
                  onToggleFeature: _toggleFeatureListing,
                ),
              ),
            ),
          if (hasPhotos)
            ListingDetailPhotoSection(
              photos: listingDetail.photos!,
              orderedPhotos:
                  _getOrderedPhotos(listingDetail.photos!).cast<Photo>(),
              pageController: _pageController,
              buildPhotoUrl: _buildPhotoUrl,
              onPhotoTap: _openFullScreenPhotoViewer,
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _metaBadgesTile(listingDetail),
          ),
          if (show3d)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _room3dTile(listingDetail),
            ),
          ListingDetailContentCard(
            listingDetail: listingDetail,
            currentLanguage: currentLanguage,
            formattedMoveInDate: formattedMoveIn,
            formattedPublicationDate: formattedPub,
            getLocalizedName: _getLocalizedName,
            ownerName: pageState.ownerName,
            ownerAvatarUrl: pageState.ownerAvatarUrl,
            onOpenInYandexMaps: () => _confirmOpenInYandexMaps(listingDetail),
            onAuthorTap: () => _navigateToProfile(listingDetail.user.id),
          ),
          if (listingDetail.listingType.code == "roommate_needed" &&
              (listingDetail.nearbyStores?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _nearbyStoresCard(listingDetail),
            ),
          if (compatibilitySection != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: compatibilitySection,
            ),
          if (ListingDetailNearbyMatchesHelper.canShowForListing(listingDetail))
            BlocSelector<ListingDetailPageBloc, ListingDetailPageState,
                ({int? count, int? listingId})>(
              selector: (s) => (
                count: s.nearbyMatchesCount,
                listingId: s.nearbyMatchesCountListingId,
              ),
              builder: (context, matches) {
                final isFresh = matches.listingId == listingDetail.id;
                if (isFresh && (matches.count ?? -1) <= 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _nearbyMatchesTile(listingDetail),
                );
              },
            ),
          BlocSelector<ListingDetailPageBloc, ListingDetailPageState,
              ({int? count, int? listingId})>(
            selector: (s) => (
              count: s.similarListingsCount,
              listingId: s.similarListingsCountListingId,
            ),
            builder: (context, sim) {
              // Hide the tile only when we know for certain there are no
              // other matching listings for this listing. While the count
              // is loading or unknown we keep the tile visible to avoid
              // layout flicker.
              final isFresh = sim.listingId == listingDetail.id;
              if (isFresh && (sim.count ?? -1) <= 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _viewSimilarTile(listingDetail),
              );
            },
          ),
          BlocSelector<ListingDetailPageBloc, ListingDetailPageState,
              ({int? count, bool isLoading})>(
            selector: (s) => (
              count: s.complaintsCount,
              isLoading: s.isLoadingComplaintsCount,
            ),
            builder: (context, cs) {
              if ((cs.count ?? 0) <= 0) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ListingDetailComplaintsCard(
                    complaintsLabel: _buildComplaintsButtonLabel(
                      cs.isLoading,
                      cs.count,
                    ),
                    onPressed: () => _viewListingComplaints(listingDetail.id),
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: FutureBuilder<String?>(
              future: _userRoleFuture,
              builder: (context, snapshot) {
                if (snapshot.data != "admin") {
                  return const SizedBox.shrink();
                }
                return ListenableBuilder(
                  listenable: ClientAdminListingConversationsConfig.enabled,
                  builder: (context, _) {
                    if (!ClientAdminListingConversationsConfig.enabled.value) {
                      return const SizedBox.shrink();
                    }
                    return ListingDetailListingOwnerMessagesCard(
                      onPressed: () =>
                          _openAdminListingOwnerConversations(listingDetail),
                    );
                  },
                );
              },
            ),
          ),
          // Admin-as-owner contact card. Pinned to the bottom of the body
          // so it sits below all the listing's regular content — admins
          // are the only audience and they're typically scrolling through
          // the listing first. Non-admin owners (the common case)
          // intentionally don't see contact controls; the FutureBuilder
          // gates this on `role == "admin"` (e.g. the Telegram-import
          // worker imports listings under an admin account, so the
          // contacts here belong to the original poster).
          if (isOwner &&
              ((listingDetail.contactTelegram?.trim().isNotEmpty ?? false) ||
                  (listingDetail.contactPhone?.trim().isNotEmpty ?? false)))
            FutureBuilder<String?>(
              future: _userRoleFuture,
              builder: (context, snapshot) {
                if (snapshot.data != "admin") {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ListingDetailAdminContactInfo(
                    contactTelegram: listingDetail.contactTelegram,
                    contactPhone: listingDetail.contactPhone,
                    onTelegram: _openTelegramChat,
                    onPhone: _makePhoneCall,
                  ),
                );
              },
            ),
          if (_buildGroupHousingContextSection(listingDetail)
              case final section?)
            section,
          if (_isGroupFormingListing(listingDetail))
            ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Padding(
                padding:
                    EdgeInsets.only(top: 16, bottom: groupFormingBottomPad),
                child: _buildGroupFormingActionBar(
                  listingDetail,
                  isOwner: isOwner,
                  onViewMemberProfiles: null,
                ),
              ),
            ),
        ];

        final themeState = ThemeState();
        final topPad = 8.0 + themeState.mainShellGlassExtraTopInset(context);
        // Reserve space for the sticky contact bar unless group-forming CTAs
        // are inline at the bottom of the scroll content.
        final bottomPad = _isGroupFormingListing(listingDetail)
            ? 0.0
            : 36.0 + MediaQuery.paddingOf(context).bottom;
        return _wrapListingDetailPullToRefresh(
          // Publishes whether the body is actively being scrolled so the glass
          // tiles inside can drop their expensive [BackdropFilter] blur while
          // moving (see [ListingDetailTileShell]).
          FeedScrollScopeHost(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  // When the liquid glass app bar is active the body renders
                  // behind the header, so we add [mainShellGlassExtraTopInset]
                  // to keep content clear of the transparent toolbar.
                  padding: EdgeInsets.fromLTRB(12.0, topPad, 12.0, bottomPad),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => sections[index],
                      childCount: sections.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return _wrapListingDetailPullToRefresh(
      CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ListingDetailFetchErrorBody(
              onRetry: () {
                context.read<ListingDetailBloc>().add(
                      ListingDetailEvent.fetchListingDetail(
                        id: widget.listingId,
                      ),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOwnProfile() => context.pushProfile();

  void _navigateToProfile(int userId, {String? phoneNumber}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => ListingOwnerProfileBloc(
            getIt<IUserProfileService>(),
            getIt<IFollowService>(),
          ),
          child: ListingOwnerProfileScreen(
            userId: userId,
            phoneNumber: phoneNumber,
          ),
        ),
      ),
    );
  }

  // Theme-dependent color method for app bar background
  Color _getAppBarBackgroundColor() {
    // Use the theme"s AppBar background color instead of hardcoded colors
    return Theme.of(context).appBarTheme.backgroundColor ?? AppColors.primary;
  }

  // Theme-dependent color method for loading text
  Color _getLoadingTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight; // White text for blue theme
    } else if (ThemeState().isLightTheme) {
      return Colors.black; // Black text for light theme
    } else {
      return AppColors.primary; // Primary text for non-blue theme
    }
  }

  // Helper method to get the current listing"s user ID
  int? _getCurrentListingUserId() {
    // Get the current listing detail from the bloc state
    final currentState = context.read<ListingDetailBloc>().state;
    return currentState.map(
      initial: (_) => null,
      loading: (_) => null,
      loaded: (loadedState) => loadedState.listingDetail.userId,
      error: (_) => null,
    );
  }

  // Show toggle active confirmation dialog
  void _showToggleActiveConfirmation(int listingId) {
    final currentState = context.read<ListingDetailBloc>().state;
    final isCurrentlyActive = currentState.map(
      initial: (_) => false,
      loading: (_) => false,
      loaded: (loadedState) => loadedState.listingDetail.isActive,
      error: (_) => false,
    );

    final titleKey =
        isCurrentlyActive ? "deactivate_listing" : "activate_listing";
    final messageKey = isCurrentlyActive
        ? "deactivate_listing_confirmation"
        : "activate_listing_confirmation";

    CommonConfirmationDialogs.showGenericConfirmation(
      context: context,
      titleKey: titleKey,
      messageKey: messageKey,
      confirmButtonKey: isCurrentlyActive ? "deactivate" : "activate",
      onConfirm: () => _toggleListingActive(listingId),
    );
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteConfirmation(int listingId) async {
    await DestructiveActionFlow.runAfterDeleteConfirmed(
      context: context,
      titleKey: "delete_listing",
      messageKey: "delete_listing_confirmation",
      errorToastKey: "delete_listing_error",
      onConfirmed: () => _deleteListing(listingId),
    );
  }

  // Delete listing method
  Future<void> _deleteListing(int listingId) async {
    context.read<ListingDetailPageBloc>().setDeleting(true);

    try {
      final listingService = getIt<IListingService>();

      final success = await listingService.deleteListing(listingId);

      if (success) {
        if (!mounted) return;
        ToastReporting.successKey(context, "delete_listing_success");

        HomeRefreshState().markForRefresh();
        unawaited(
          getIt<AppAnalyticsService>().refreshHasActiveListingProperty(),
        );

        Navigator.of(context).pop();
      } else {
        throw Exception("Delete operation failed");
      }
    } finally {
      if (mounted) {
        context.read<ListingDetailPageBloc>().setDeleting(false);
      }
    }
  }
}
