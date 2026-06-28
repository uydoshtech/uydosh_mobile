import "dart:async";
import "dart:math" as math;

import "package:firebase_messaging/firebase_messaging.dart"
    show AuthorizationStatus;
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/main.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/blocs/conversations_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/screens/messages/archived_conversations_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_inbox_filters.dart";
import "package:uy_dosh/presentation/widgets/chat/vertical_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/common/app_bar_profile_icon.dart";
import "package:uy_dosh/presentation/widgets/common/auth_required_state.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_state_builder.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/roll_up_fade_out.dart";
import "package:uy_dosh/presentation/widgets/conversation/grouped_conversations_list.dart";
import "package:uy_dosh/presentation/widgets/messages/inbox_push_banner.dart";

class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({
    super.key,
    this.showCustomHeader = true,

    /// When non-null, used with [MainNavigation]'s bottom bar: may refresh when
    /// the user switches to this tab (IndexedStack keeps the widget mounted).
    /// Refetch runs only if [UnreadMessagesState] reports unread (e.g. green dot).
    this.mainTabSelected,

    /// Non-null on [PushedMessagesInboxScaffold] from task detail: lists only
    /// `gig_request` threads for this id in one scroll (no my/other toggle or
    /// day headers); the pushed scaffold omits the app bar title.
    this.filterGigRequestId,
  });

  final bool showCustomHeader;

  /// `true` when this screen is the selected main tab; `null` when opened
  /// from the drawer or another route (tab visibility does not apply).
  final bool? mainTabSelected;

  /// When set, only conversations for this open task are listed.
  final int? filterGigRequestId;

  @override
  State<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends State<MessagesInboxScreen>
    with RouteAware, WidgetsBindingObserver {
  int? _currentUserId;
  int _selectedTabIndex = 0; // 0 = incoming, 1 = outgoing
  /// Whether the user has manually picked a tab in this session. Once set,
  /// the auto-default-tab rule below stops overriding their choice on
  /// subsequent conversation refreshes.
  bool _userPickedTab = false;

  /// Whether we have already applied the "auto-pick the tab with unreads"
  /// rule for the current login session. Reset on logout so the rule
  /// re-runs on the next sign-in.
  bool _appliedInitialTabRule = false;

  /// Cached conversations to show during refresh - prevents blink when returning to screen
  List<ConversationSummary>? _lastDisplayedConversations;
  Timer? _unreadRefreshDebounce;
  late final VoidCallback _unreadMessagesListener;
  int _lastObservedUnreadCount = 0;
  bool _hasLoadedInitialInboxData = false;

  /// Conversations the user just archived but whose commit is still inside the
  /// 5s undo window. They are hidden from every list/badge computation; the
  /// real `ArchiveConversation` event only fires once the countdown elapses.
  final Set<int> _pendingArchiveIds = <int>{};

  /// Whether the user currently has at least one archived conversation. Drives
  /// visibility of the "Archive" entry points (app-bar action + pinned row) —
  /// no archive folder is exposed when the folder would be empty.
  ///
  /// Probed directly against [IMessagingService] rather than threaded through
  /// [MessagingBloc]: the bloc only hydrates the active (non-archived) list,
  /// and piping an "archived-count" concern through it would complicate every
  /// state variant for a single boolean.
  bool _hasArchivedChats = false;
  final IMessagingService _messagingService = getIt<IMessagingService>();
  List<PendingLandlordInvite> _pendingLandlordInvites = const [];
  bool _pendingLandlordInvitesLoading = false;
  bool _landlordInviteActionInFlight = false;

  /// OS-level push permission status. `null` until first probe completes (or
  /// when the platform doesn't support push at all).
  AuthorizationStatus? _pushStatus;

  /// `true` while we're awaiting the system permission sheet / settings hop;
  /// blocks duplicate taps and drives the spinner inside [InboxPushBanner].
  bool _pushBannerBusy = false;

  /// `true` once the user has tapped the close affordance recently — banner
  /// stays hidden until the cooldown stored in prefs elapses (or the
  /// permission status itself flips to authorized, which we treat as
  /// "problem solved" and reset the dismiss).
  bool _pushBannerDismissed = false;

  /// `true` while the banner is playing its roll-up + fade-out animation.
  /// Decoupled from [_pushBannerDismissed] / [_pushStatus] so we keep the
  /// underlying widget mounted until the curve finishes — same pattern used
  /// for the alerts explainer and the favorites/notifications tiles.
  bool _pushBannerClosing = false;

  /// Duration of the close animation. Matches [RollUpFadeOut]'s default so
  /// the post-anim state commit lines up exactly with the visual collapse.
  static const Duration _pushBannerCloseDuration = Duration(milliseconds: 300);

  /// `true` once we've at least attempted to load both the OS status and the
  /// dismiss timestamp — guards against showing or hiding the banner before
  /// we actually know which state we're in (avoids a flicker on first
  /// frame).
  bool _pushBannerProbed = false;

  /// SharedPreferences key for the dismiss timestamp (ms-since-epoch). Kept
  /// inline rather than in a constants file because it is only read/written
  /// from this screen.
  static const String _pushBannerDismissedAtKey =
      "inbox_push_banner_dismissed_at_ms";

  /// How long a manual dismiss suppresses the banner. Two weeks balances
  /// "don't nag" with "remind people who keep losing chat replies"; long
  /// enough to feel respectful, short enough to recover users who change
  /// their mind silently.
  static const Duration _pushBannerDismissCooldown = Duration(days: 14);

  /// Matches [HomeScreen] / [GigHubScreen] curved bar height when the shell uses
  /// [Scaffold.extendBody] and the list draws behind [CustomCurvedNavigationBar].
  static const double _kCurvedBottomBarHeight = 70.0;

  /// Extra gap after the last inbox row so content does not sit flush on the nav.
  static const double _kInboxListBottomBreathingRoom = 20.0;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "messages_inbox");
    _initializeUser();
    _loadInitialInboxDataIfVisible();
    WidgetsBinding.instance.addObserver(this);

    // Listen for authentication state changes to refresh conversations when user logs in
    AuthenticationState().addListener(_onAuthenticationStateChanged);

    _lastObservedUnreadCount = UnreadMessagesState().unreadCount;
    _unreadMessagesListener = _onUnreadMessagesChanged;
    UnreadMessagesState().addListener(_unreadMessagesListener);

    if (widget.mainTabSelected != false) {
      _refreshPushBannerVisibility();
    }
  }

  @override
  void didUpdateWidget(covariant MessagesInboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterGigRequestId != widget.filterGigRequestId) {
      setState(() => _lastDisplayedConversations = null);
      _loadConversations();
    }
    if (widget.mainTabSelected != true) {
      return;
    }
    if (oldWidget.mainTabSelected ?? false) {
      return;
    }
    if (!_hasLoadedInitialInboxData) {
      _loadInitialInboxDataIfVisible();
      _refreshPushBannerVisibility();
      return;
    }
    if (!UnreadMessagesState().hasUnreadMessages) {
      return;
    }
    _loadConversations();
  }

  Future<void> _initializeUser() async {
    _currentUserId = await SessionManager.getUserId();
    logger.d("🔍 [MessagesInboxScreen] Current user ID: $_currentUserId");
    // Refresh conversations after getting user ID to update unread indicators
    if (mounted) {
      setState(() {});
    }
  }

  // Handle authentication state changes
  void _onAuthenticationStateChanged() {
    logger.d(
      "🔍 [MessagesInboxScreen] Authentication state changed, refreshing conversations...",
    );
    if (mounted) {
      // Only refresh if user is authenticated
      final isAuthenticated = AuthenticationState().isAuthenticated;
      if (isAuthenticated) {
        // Refresh user ID and conversations when authentication state changes
        _initializeUser();
        if (_isInboxVisibleAndActive()) {
          _loadInitialInboxDataIfVisible();
          _refreshPushBannerVisibility();
        } else {
          _hasLoadedInitialInboxData = false;
        }
      } else {
        // Clear conversations when user logs out
        logger.d(
          "🔍 [MessagesInboxScreen] User logged out, clearing conversations...",
        );
        context.read<ConversationsBloc>().add(const ConversationsClear());
        if (_hasArchivedChats || _pendingLandlordInvites.isNotEmpty) {
          setState(() {
            _hasArchivedChats = false;
            _pendingLandlordInvites = const [];
          });
        }
        // Re-arm the auto-default-tab rule so the next sign-in gets a fresh
        // pick based on the new account's unread state.
        _appliedInitialTabRule = false;
        _userPickedTab = false;
      }
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    AuthenticationState().removeListener(_onAuthenticationStateChanged);
    UnreadMessagesState().removeListener(_unreadMessagesListener);
    _unreadRefreshDebounce?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.unsubscribe(this);
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isInboxVisibleAndActive()) {
      // Refresh conversations when app becomes active again
      _loadConversations();
      _refreshArchivedChatsFlag();
      // The user may have toggled the OS notifications permission while we
      // were backgrounded (e.g. they tapped "Open settings" on the inbox
      // banner). Re-probe so the banner reflects reality.
      _refreshPushBannerVisibility();
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another screen (e.g. ChatScreen)
    if (!_isInboxVisibleAndActive()) return;
    _loadConversations();
    // User may have archived/unarchived from ChatScreen's overflow menu, or
    // their last archived chat may have been auto-unarchived by a reply.
    _refreshArchivedChatsFlag();
  }

  void _loadConversations() {
    logger.d("🔍 [MessagesInboxScreen] Loading conversations...");
    if (mounted) {
      _hasLoadedInitialInboxData = true;
      context.read<ConversationsBloc>().add(const ConversationsRefresh());
      unawaited(_refreshPendingLandlordInvites());
    }
  }

  Future<void> _refreshPendingLandlordInvites() async {
    if (!AuthenticationState().isAuthenticated ||
        widget.filterGigRequestId != null ||
        _pendingLandlordInvitesLoading) {
      return;
    }
    _pendingLandlordInvitesLoading = true;
    try {
      final invites =
          await getIt<IListingGroupService>().listPendingLandlordInvites();
      if (!mounted) return;
      setState(() => _pendingLandlordInvites = invites);
    } catch (e) {
      logger.d("🔍 [MessagesInboxScreen] Pending landlord invites failed: $e");
    } finally {
      _pendingLandlordInvitesLoading = false;
    }
  }

  void _loadInitialInboxDataIfVisible() {
    if (widget.mainTabSelected == false) return;
    _loadConversations();
    _refreshArchivedChatsFlag();
  }

  /// Ask the server whether any archived conversation exists from either
  /// perspective (initiator / participant). A single hit is enough — we only
  /// need a boolean, so both probes cap at `limit: 1` to minimize payload.
  ///
  /// Failures are swallowed intentionally: a network hiccup shouldn't wipe
  /// the archive entry point. We keep the previous value so a user who
  /// already knows they have archived chats doesn't suddenly lose the row.
  Future<void> _refreshArchivedChatsFlag() async {
    if (!AuthenticationState().isAuthenticated) {
      if (!mounted) return;
      if (_hasArchivedChats) {
        setState(() => _hasArchivedChats = false);
      }
      return;
    }
    try {
      final responses = await Future.wait([
        _messagingService.getConversations(archived: true, limit: 1),
        _messagingService.getParticipantConversations(archived: true, limit: 1),
      ]);
      final hasAny = responses.any((r) => r.data.isNotEmpty);
      if (!mounted) return;
      if (_hasArchivedChats != hasAny) {
        setState(() => _hasArchivedChats = hasAny);
      }
    } catch (e, stack) {
      logger.d(
        "🔍 [MessagesInboxScreen] Archived probe failed (keeping current flag): $e\n$stack",
      );
    }
  }

  bool _isInboxVisibleAndActive() {
    // If opened as a main tab, only refresh when that tab is selected.
    final tabSelected = widget.mainTabSelected;
    if (tabSelected != null) {
      return tabSelected;
    }
    // Otherwise (pushed route / drawer), refresh only if we're the top route.
    return ModalRoute.of(context)?.isCurrent ?? true;
  }

  void _onUnreadMessagesChanged() {
    final current = UnreadMessagesState().unreadCount;
    final previous = _lastObservedUnreadCount;
    _lastObservedUnreadCount = current;

    // Only auto-refresh when this screen is actually visible.
    if (!mounted || !_isInboxVisibleAndActive()) return;
    // Avoid background fetches when not signed in (inbox will show auth error state anyway).
    if (!AuthenticationState().isAuthenticated) return;

    // Debounce rapid unread updates (multiple pushes in quick succession).
    // Refresh on any count change while visible so new dialogs appear/reorder immediately.
    if (current == previous) return;
    _unreadRefreshDebounce?.cancel();
    _unreadRefreshDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (!_isInboxVisibleAndActive()) return;
      _loadConversations();
    });
  }

  Future<void> _onInboxPullRefresh() async {
    _loadConversations();
    // Pull-to-refresh is a natural moment to also re-check push permission —
    // cheap, and lets the banner disappear without a full app restart if the
    // user enabled notifications elsewhere.
    unawaited(_refreshPushBannerVisibility());
  }

  /// Re-probe the OS push permission and the dismiss cooldown, then rebuild
  /// if the visibility decision changes. Safe to call repeatedly — the cost
  /// is one platform channel hit + one SharedPreferences read.
  ///
  /// When the new state would hide a currently-visible banner (typical
  /// path: user just granted permission via the system sheet), the underlying
  /// status update is held back behind a roll-up animation so the banner
  /// collapses gracefully instead of popping out.
  Future<void> _refreshPushBannerVisibility() async {
    final push = getIt<IPushNotificationService>();
    if (!push.isSupported) {
      if (!_pushBannerProbed) {
        setStateIfMounted(() => _pushBannerProbed = true);
      }
      return;
    }

    final status = await push.getNotificationStatus();

    final prefs = await SharedPreferences.getInstance();
    final dismissedAtMs = prefs.getInt(_pushBannerDismissedAtKey);
    final isAuthorized = status == AuthorizationStatus.authorized ||
        status == AuthorizationStatus.provisional;
    var dismissed = false;
    if (dismissedAtMs != null) {
      final age = DateTime.now().millisecondsSinceEpoch - dismissedAtMs;
      dismissed = age >= 0 && age < _pushBannerDismissCooldown.inMilliseconds;
      // Once permission is granted, a stale dismiss flag is just dead state —
      // clear it so a future revoke shows the banner without waiting two
      // weeks.
      if (isAuthorized) {
        await prefs.remove(_pushBannerDismissedAtKey);
        dismissed = false;
      }
    }

    if (!mounted) return;

    final wasVisible = _shouldShowPushBanner;
    final willBeVisible = _pushBannerVisibilityFor(
      status: status,
      dismissed: dismissed,
    );

    // Visible → hidden: roll up + fade out before committing the state, so
    // the surface doesn't disappear in a single frame.
    if (wasVisible && !willBeVisible && !_pushBannerClosing) {
      setState(() => _pushBannerClosing = true);
      await Future<void>.delayed(_pushBannerCloseDuration);
      if (!mounted) return;
    }

    setState(() {
      _pushStatus = status;
      _pushBannerDismissed = dismissed;
      _pushBannerProbed = true;
      _pushBannerClosing = false;
    });
  }

  /// Pure visibility predicate used both for the live getter and to peek at
  /// what visibility *would* be after a hypothetical state transition.
  bool _pushBannerVisibilityFor({
    required AuthorizationStatus? status,
    required bool dismissed,
  }) {
    if (dismissed) return false;
    if (status == null) return false;
    return status == AuthorizationStatus.denied ||
        status == AuthorizationStatus.notDetermined;
  }

  bool get _shouldShowPushBanner {
    if (!_pushBannerProbed) return false;
    return _pushBannerVisibilityFor(
      status: _pushStatus,
      dismissed: _pushBannerDismissed,
    );
  }

  /// Whether the banner row should be present in the entries list at all.
  /// During [_pushBannerClosing] the underlying state still satisfies
  /// [_shouldShowPushBanner] (we hold off the commit), so a single check is
  /// enough — but we expose this for clarity at the call site.
  bool get _shouldRenderPushBannerRow =>
      widget.filterGigRequestId == null &&
      (_shouldShowPushBanner || _pushBannerClosing);

  int get _leadingInboxItemCount =>
      (_pendingLandlordInvites.isNotEmpty ? 1 : 0) +
      (_shouldRenderPushBannerRow ? 1 : 0);

  Widget _buildLeadingInboxItem(BuildContext context, int index) {
    var localIndex = index;
    if (_pendingLandlordInvites.isNotEmpty) {
      if (localIndex == 0) {
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: _PendingLandlordInviteInboxCard(
            invite: _pendingLandlordInvites.first,
            busy: _landlordInviteActionInFlight,
            onAccept: _acceptPendingLandlordInvite,
            onDecline: _declinePendingLandlordInvite,
          ),
        );
      }
      localIndex -= 1;
    }

    if (_shouldRenderPushBannerRow && localIndex == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: _pushBannerClosing
            ? RollUpFadeOut(
                duration: _pushBannerCloseDuration,
                child: InboxPushBanner(
                  key: const ValueKey("inbox_push_banner"),
                  status: _pushStatus ?? AuthorizationStatus.notDetermined,
                  busy: _pushBannerBusy,
                  onPressed: _onPushBannerPressed,
                  onDismiss: _onPushBannerDismiss,
                ),
              )
            : InboxPushBanner(
                key: const ValueKey("inbox_push_banner"),
                status: _pushStatus ?? AuthorizationStatus.notDetermined,
                busy: _pushBannerBusy,
                onPressed: _onPushBannerPressed,
                onDismiss: _onPushBannerDismiss,
              ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _acceptPendingLandlordInvite() async {
    if (_pendingLandlordInvites.isEmpty || _landlordInviteActionInFlight) {
      return;
    }
    final invite = _pendingLandlordInvites.first;
    HapticFeedbackUtils.impact();
    setState(() => _landlordInviteActionInFlight = true);
    try {
      final conversationId =
          await getIt<IListingGroupService>().acceptLandlordInvite(
        groupListingId: invite.groupListingId,
        inviteId: invite.inviteId,
      );
      if (!mounted) return;
      setState(() {
        _pendingLandlordInvites =
            _pendingLandlordInvites.skip(1).toList(growable: false);
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_landlord_invite_accepted"),
      );
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: ChatScreen.routeName(conversationId)),
          builder: (_) => ChatScreen(
            conversationId: conversationId,
            listingId: invite.groupListingId,
            listingTitle: invite.groupListingTitle,
            conversationContextType: "listing_group",
          ),
        ),
      );
      if (mounted) _loadConversations();
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic_try_again"),
      );
    } finally {
      if (mounted) setState(() => _landlordInviteActionInFlight = false);
    }
  }

  Future<void> _declinePendingLandlordInvite() async {
    if (_pendingLandlordInvites.isEmpty || _landlordInviteActionInFlight) {
      return;
    }
    final invite = _pendingLandlordInvites.first;
    HapticFeedbackUtils.impact();
    setState(() => _landlordInviteActionInFlight = true);
    try {
      await getIt<IListingGroupService>().declineLandlordInvite(
        groupListingId: invite.groupListingId,
        inviteId: invite.inviteId,
      );
      if (!mounted) return;
      setState(() {
        _pendingLandlordInvites =
            _pendingLandlordInvites.skip(1).toList(growable: false);
      });
      ToastTheme.showInfo(
        context,
        message: L10n.get("group_landlord_invite_declined"),
      );
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic_try_again"),
      );
    } finally {
      if (mounted) setState(() => _landlordInviteActionInFlight = false);
    }
  }

  Future<void> _onPushBannerPressed() async {
    if (_pushBannerBusy) return;
    HapticFeedbackUtils.impact();
    setState(() => _pushBannerBusy = true);

    final push = getIt<IPushNotificationService>();
    final isDenied = _pushStatus == AuthorizationStatus.denied;

    try {
      if (isDenied) {
        // iOS won't re-prompt once the user denied — the only path is the
        // Settings app. didChangeAppLifecycleState picks up the new status
        // when they return.
        await openAppSettings();
        return;
      }

      final ok = await push.requestPermissionAndRegister();
      if (!mounted) return;
      if (ok) {
        ToastTheme.showSuccess(
          context,
          message: L10n.get("notifications_enabled"),
        );
      } else {
        // Either the user denied the system sheet (and the service already
        // bounced them to Settings) or registration failed silently. Either
        // way, point them at Settings as the next step.
        ToastTheme.showInfo(
          context,
          message: L10n.get("notifications_enable_in_settings"),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _pushBannerBusy = false);
      }
      // Always re-probe: even on the openAppSettings path the user is back
      // in-app the moment this future resolves (system Settings is a
      // separate app on iOS, so didChangeAppLifecycleState handles that
      // case; on Android it's a popup that closes synchronously).
      await _refreshPushBannerVisibility();
    }
  }

  Future<void> _onPushBannerDismiss() async {
    if (_pushBannerClosing) return;
    HapticFeedbackUtils.impact();

    // Persist immediately so a kill mid-animation still respects the
    // dismiss; the visual collapse happens in parallel.
    unawaited(() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
          _pushBannerDismissedAtKey,
          DateTime.now().millisecondsSinceEpoch,
        );
      } catch (e) {
        logger.d("📲 [InboxPushBanner] Failed to persist dismiss: $e");
      }
    }());

    setState(() => _pushBannerClosing = true);
    await Future<void>.delayed(_pushBannerCloseDuration);
    if (!mounted) return;
    setState(() {
      _pushBannerDismissed = true;
      _pushBannerClosing = false;
    });
  }

  /// Show cached conversations if available, otherwise loading - prevents blink during refresh
  Widget _showCachedOrLoading() {
    final cache = _lastDisplayedConversations;
    if (cache != null) {
      return _buildTabbedConversationsList(cache);
    }
    return _buildLoadingState();
  }

  Map<int, int> _unreadCountsByConversation(
    List<ConversationSummary> conversations,
  ) {
    final unreadCounts = <int, int>{};
    for (final conversation in conversations) {
      final unreadCount = conversation.unreadCount ?? 0;
      if (unreadCount <= 0) continue;
      if (_currentUserId != null &&
          conversation.lastMessageSenderId == _currentUserId) {
        continue;
      }
      unreadCounts[conversation.id] = unreadCount;
    }
    return unreadCounts;
  }

  bool _conversationBelongsToFilteredGigRequest(
    ConversationSummary c,
    int gigRequestId,
  ) {
    if (c.contextType != "gig_request") return false;
    final rid = c.gigRequestId ?? c.contextId;
    return rid == gigRequestId;
  }

  /// Base inbox rules: drop pending archives; optionally require at least one
  /// message (full inbox). Task-scoped view lists all matching threads so the
  /// client sees providers who opened a chat even before the first message.
  List<ConversationSummary> _visibleInboxConversations(
    List<ConversationSummary> conversations,
  ) {
    var list =
        conversations.where((c) => !_pendingArchiveIds.contains(c.id)).toList();

    final gigId = widget.filterGigRequestId;
    if (gigId != null) {
      list = list
          .where((c) => _conversationBelongsToFilteredGigRequest(c, gigId))
          .toList();
    } else {
      list = list.where(conversationHasMessagesForInbox).toList();
    }
    return list;
  }

  bool _isListingGroupConversation(ConversationSummary conversation) =>
      conversation.contextType?.trim().toLowerCase() == "listing_group";

  bool _isIncomingConversation(ConversationSummary conversation) {
    if (_currentUserId == null) return false;
    // Group chats reuse the legacy two-party columns: the backend always
    // sets `initiator_id` to the listing owner. So the owner belongs in
    // "Мои объявления"; every other member is routed to "Чужие объявления"
    // by `_isOutgoingConversation`.
    if (_isListingGroupConversation(conversation)) {
      return conversation.initiatorId == _currentUserId;
    }
    return conversation.participantId == _currentUserId;
  }

  bool _isOutgoingConversation(ConversationSummary conversation) {
    if (_currentUserId == null) return false;
    // For group chats the owner is `initiator_id`; any member that is not the
    // owner (including members that live only in `conversation_members` and
    // match neither legacy column) belongs in "Чужие объявления".
    if (_isListingGroupConversation(conversation)) {
      return conversation.initiatorId != _currentUserId;
    }
    return conversation.initiatorId == _currentUserId;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final backgroundColor = themeState.backgroundColor;

        return Scaffold(
          extendBodyBehindAppBar: widget.showCustomHeader &&
              themeState.usesLiquidGlassChrome,
          backgroundColor: backgroundColor,
          appBar: widget.showCustomHeader ? _buildCustomHeader() : null,
          body: _buildContent(),
          floatingActionButton: _hasArchivedChats &&
                  widget.filterGigRequestId == null
              ? Padding(
                  // Lift the pill above the main bottom bar.
                  padding: const EdgeInsets.only(bottom: 24),
                  child:
                      _ArchivedChatsFab(onPressed: _openArchivedConversations),
                )
              : null,
        );
      },
    );
  }

  Widget _buildContent() {
    return MultiBlocListener(
      listeners: [
        // Chat-only side effects that still come from the shared MessagingBloc.
        BlocListener<MessagingBloc, MessagingState>(
          listener: (context, state) {
            state.whenOrNull(
              messagesMarkedAsRead: (conversationId, markedCount) {
                _loadConversations();
              },
              error: (message) {
                if (message == archiveHasUnreadErrorCode && mounted) {
                  _showArchiveWarning(L10n.get("archive_failed_has_unread"));
                }
              },
            );
          },
        ),
        // Inbox caching + unread badge updates are driven by ConversationsBloc only.
        BlocListener<ConversationsBloc, ConversationsState>(
          listener: (context, state) {
            if (state is ConversationsLoaded) {
              final visible = _visibleInboxConversations(state.conversations);
              logger.d(
                "🔍 [MessagesInboxScreen] Conversations loaded: ${state.conversations.length} conversations (${visible.length} with messages)",
              );

              _lastDisplayedConversations = List<ConversationSummary>.from(
                visible,
              );

              _maybeApplyInitialTabRule(visible);

              if (widget.filterGigRequestId == null) {
                UnreadMessagesState().updateFromConversations(
                  _unreadCountsByConversation(visible),
                );
              }
            } else if (state is ConversationsCleared) {
              _lastDisplayedConversations = null;
              UnreadMessagesState().clearUnreadCount();
            }
          },
        ),
      ],
      child: BlocBuilder<ConversationsBloc, ConversationsState>(
        builder: (context, state) {
          if (state is ConversationsInitial || state is ConversationsLoading) {
            return _showCachedOrLoading();
          }
          if (state is ConversationsCleared) {
            return _buildEmptyState();
          }
          if (state is ConversationsError) {
            return _buildErrorState(state.message);
          }
          if (state is ConversationsLoaded) {
            final visible = _visibleInboxConversations(state.conversations);
            return _buildTabbedConversationsList(visible);
          }
          return _showCachedOrLoading();
        },
      ),
    );
  }

  PreferredSizeWidget _buildCustomHeader() {
    final themeState = ThemeState();
    final useLiquidGlass = themeState.usesLiquidGlassChrome;
    final appBarTheme = Theme.of(context).appBarTheme;
    final appBarBackgroundColor =
        appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final onBarColor = useLiquidGlass
        ? (appBarTheme.foregroundColor ?? themeState.textColor)
        : themeState.textColor;

    return UydoshAppBar(
      toolbarHeight: standardAppBarToolbarHeight,
      leading: ThreeDAppBarIconButton.backLeading(context),
      centerTitle: true,
      title: Text(
        L10n.get("messages"),
        style: appBarTheme.titleTextStyle?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onBarColor,
            ) ??
            TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onBarColor,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: useLiquidGlass
          ? liquidGlassAppBarMaterialColor(context)
          : appBarBackgroundColor,
      surfaceTintColor:
          useLiquidGlass ? Colors.transparent : appBarTheme.surfaceTintColor,
      elevation: useLiquidGlass ? 0 : null,
      scrolledUnderElevation: useLiquidGlass ? 0 : null,
      shadowColor:
          useLiquidGlass ? Colors.transparent : appBarTheme.shadowColor,
      forceMaterialTransparency: useLiquidGlass,
      flexibleSpace:
          useLiquidGlass ? const LiquidGlassAppBarFlexibleSpace() : null,
      foregroundColor: onBarColor,
      actions: [
        if (_hasArchivedChats)
          IconButton(
            tooltip: L10n.get("archived_chats"),
            onPressed: () {
              HapticFeedbackUtils.impact();
              _openArchivedConversations();
            },
            icon: ThemeIcon(
              Icons.archive_outlined,
              size: 24,
              color: onBarColor,
            ),
          ),
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: IconButton(
            onPressed: () {
              HapticFeedbackUtils.impact();
              context.pushProfile();
            },
            icon: AppBarProfileIcon(
              iconSize: 26,
              iconColor: onBarColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: HouseLoadingIndicator());
  }

  Widget _buildErrorState(String message) {
    final isAuthError = message.contains("401") ||
        message.contains("Unauthorized") ||
        message.contains("Invalid or expired session token") ||
        message.contains("Authentication required");

    if (isAuthError) {
      return ListenableBuilder(
        listenable: ThemeState(),
        builder: (context, _) {
          return AuthRequiredState(
            iconColor: _getEmptyStateIconColor(),
            textColor: _getEmptyStateTextColor(),
            onLogin: AuthRequiredState.logoutAndReauthenticate(context),
          );
        },
      );
    }

    // Mirror the home tab's error state (icon → "Ошибка" → sanitized detail →
    // refresh pill) so the inbox doesn't drift into a different-looking error
    // screen. Uses CommonStateBuilder exactly like home_screen so any future
    // tweak there flows here automatically.
    return CommonStateBuilder(
      isLoading: false,
      hasError: true,
      isEmpty: false,
      errorMessage: message,
      errorAction: ThreeDPillButton(
        onPressed: _loadConversations,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ThemeIcon(Icons.refresh, size: 18),
            const SizedBox(width: 8),
            Text(
              L10n.get("retry"),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      child: const SizedBox.shrink(),
    );
  }

  Color _getEmptyStateIconColor() =>
      ThemeState().isBlueTheme ? AppColors.textLight : AppColors.textGrey400;

  Color _getEmptyStateTextColor() =>
      ThemeState().isBlueTheme ? AppColors.textLight : AppColors.textGrey400;

  /// Bottom padding for inbox scroll content: safe area, plus curved nav overlap
  /// on the Messages main tab (blue shell + [extendBody]), plus
  /// [_kInboxListBottomBreathingRoom].
  double _inboxListBottomPadding(BuildContext context) {
    const baseMinimum = 16.0;
    final double inset;
    if (ThemeState().isBlueTheme && widget.mainTabSelected == true) {
      final mq = MediaQuery.of(context);
      final fromView = math.max(mq.padding.bottom, mq.viewPadding.bottom);
      final shellInset = math.max(_kCurvedBottomBarHeight, fromView);
      inset = math.max(baseMinimum, shellInset);
    } else {
      inset = math.max(baseMinimum, MediaQuery.paddingOf(context).bottom);
    }
    return inset + _kInboxListBottomBreathingRoom;
  }

  Widget _buildTabbedConversationsList(
    List<ConversationSummary> conversations,
  ) {
    if (conversations.isEmpty && _leadingInboxItemCount == 0) {
      return _buildEmptyState();
    }

    if (widget.filterGigRequestId != null) {
      return _buildGigScopedConversationsList(conversations);
    }

    // Group chats are membership-based; members beyond the legacy
    // initiator/participant pair still need a stable inbox lane.
    final incomingConversations =
        conversations.where(_isIncomingConversation).toList();
    final outgoingConversations =
        conversations.where(_isOutgoingConversation).toList();

    final hasPendingLandlordInvite = _pendingLandlordInvites.isNotEmpty;
    final showInboxTabs = (incomingConversations.isNotEmpty &&
            outgoingConversations.isNotEmpty) ||
        hasPendingLandlordInvite;
    // Without the toggle, pick the sole non-empty lane regardless of [_selectedTabIndex].
    final displayIncoming = showInboxTabs
        ? _selectedTabIndex == 0
        : incomingConversations.isNotEmpty;

    // Space under glass header / above list: tab strip (8 + 48 + 12) vs strip top only.
    const listTopWithTabs = 68.0;
    const listTopWithoutTabs = 8.0;
    final listTopInset = showInboxTabs ? listTopWithTabs : listTopWithoutTabs;

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableInboxToggleAnim =
        AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;
    const inboxToggleAnimDuration = Duration(milliseconds: 420);
    final toggleAnimDuration =
        enableInboxToggleAnim ? inboxToggleAnimDuration : Duration.zero;

    final shellGlassTop = widget.showCustomHeader
        ? (ThemeState().usesLiquidGlassChrome
            // When we render a liquid-glass app bar (transparent + blurred),
            // allow content to scroll behind it (like Home) so the header
            // actually blurs real content instead of a flat background.
            ? ThemeState().mainShellGlassExtraTopInset(context)
            : 0.0)
        : ThemeState().mainShellGlassExtraTopInset(context);

    return Padding(
      padding: EdgeInsets.only(top: shellGlassTop),
      child: Stack(
        children: [
          // List scrolls "under" the glass tab switcher (when visible).
          Positioned.fill(
            child: AnimatedPadding(
              duration: toggleAnimDuration,
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(top: listTopInset),
              child: UydoshRefreshIndicator.mainShell(
                onRefresh: _onInboxPullRefresh,
                // Scrollable inset matches tab strip animation.
                edgeOffset: 0.0,
                child: PullToRefreshStretchHaptics(
                  child: displayIncoming
                      ? _buildConversationsList(
                          incomingConversations,
                          "incoming",
                        )
                      : _buildConversationsList(
                          outgoingConversations,
                          "outgoing",
                        ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: AnimatedSwitcher(
              duration: toggleAnimDuration,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final curved = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                );
                final slide = Tween<Offset>(
                  begin: const Offset(0, -0.22),
                  end: Offset.zero,
                ).animate(curved);
                final scale = Tween<double>(
                  begin: 0.92,
                  end: 1.0,
                ).animate(curved);
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: slide,
                    child: ScaleTransition(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: child,
                    ),
                  ),
                );
              },
              child: showInboxTabs
                  ? KeyedSubtree(
                      key: const ValueKey<String>("inbox-tabs-on"),
                      child: _buildTabButtons(
                        incomingConversations,
                        outgoingConversations,
                      ),
                    )
                  : SizedBox.shrink(
                      key: const ValueKey<String>("inbox-tabs-off"),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Task-scoped inbox: same grouped-by-gig UI without my/other tabs.
  Widget _buildGigScopedConversationsList(
    List<ConversationSummary> conversations,
  ) {
    final shellGlassTop = widget.showCustomHeader
        ? (ThemeState().usesLiquidGlassChrome
            ? ThemeState().mainShellGlassExtraTopInset(context)
            : 0.0)
        : ThemeState().mainShellGlassExtraTopInset(context);

    final sorted = _sortConversationsForInbox(conversations);

    return Padding(
      padding: EdgeInsets.only(top: shellGlassTop),
      child: UydoshRefreshIndicator.mainShell(
        onRefresh: _onInboxPullRefresh,
        edgeOffset: 0.0,
        child: PullToRefreshStretchHaptics(
          child: GroupedConversationsList(
            conversations: sorted,
            currentUserId: _currentUserId,
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              _inboxListBottomPadding(context),
            ),
            itemSpacing: 12,
            showActivityTimeOnly: true,
            useOutgoingInnerTiles: false,
            onConversationTap: _openChatScreen,
            onConversationLongPress: _promptConversationActions,
          ),
        ),
      ),
    );
  }

  Widget _buildTabButtons(
    List<ConversationSummary> incoming,
    List<ConversationSummary> outgoing,
  ) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final primaryColor = themeState.primaryColor;
        final cardColor = themeState.cardColor;

        final switcher = _buildToggleSwitch(
          context,
          incomingCount: _getUnreadCount(incoming),
          outgoingCount: _getUnreadCount(outgoing),
          primaryColor: primaryColor,
          cardColor: cardColor,
        );

        if (!themeState.usesLiquidGlassChrome) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: switcher,
          );
        }

        const radius = BorderRadius.all(Radius.circular(20));
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scheme = Theme.of(context).colorScheme;
        final baseTint = isDark ? BlueThemeColors.background : scheme.surface;
        final enableGlass = LiquidGlassRendering.effectsEnabled(context);

        // Important: don't clip the switch itself, otherwise its drop shadow
        // gets cut off at the bottom. Only the glass background is clipped.
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    children: [
                      // Blur is subtle on flat backgrounds, so we also apply a clear glass tint.
                      if (enableGlass)
                        Positioned.fill(
                          child: LiquidGlassRendering.backdropBlur(
                            enabled: enableGlass,
                            sigma: LiquidGlassRendering.switchGlassBlurSigma,
                            child: const SizedBox.expand(),
                          ),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          // Match the app bar glass: subtle tint + hairline edge.
                          color:
                              baseTint.withValues(alpha: isDark ? 0.10 : 0.12),
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ],
                  ),
                ),
              ),
              switcher,
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleSwitch(
    BuildContext context, {
    required int incomingCount,
    required int outgoingCount,
    required Color primaryColor,
    required Color cardColor,
  }) {
    final themeState = ThemeState();
    final selectedTextColor =
        ThemeData.estimateBrightnessForColor(primaryColor) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final unselectedTextColor = themeState.unselectedTabTextColor;

    const height = 48.0;
    const thumbInset = 2.0;
    const innerRadius = 22.0;
    final useGlassPlate = themeState.usesLiquidGlassChrome;

    return LayoutBuilder(
      builder: (context, constraints) {
        final innerTrack =
            (constraints.maxWidth - thumbInset * 2).clamp(0.0, double.infinity);
        final segmentWidth = innerTrack / 2;
        final thumbLeft = thumbInset + _selectedTabIndex * segmentWidth;

        final thumbDecoration = useGlassPlate
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(innerRadius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withValues(alpha: 0.38),
                    primaryColor.withValues(alpha: 0.58),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 0.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 12,
                    spreadRadius: 0.4,
                    offset: const Offset(0, 4),
                  ),
                ],
              )
            : BoxDecoration(
                borderRadius: BorderRadius.circular(innerRadius),
                gradient: ThreeDSurfaceStyle.surfaceGradient(
                  context,
                  primaryColor,
                ),
                boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
              );

        final stack = Stack(
          children: [
            // Sliding thumb — same pattern as [NeumorphicSegmentedSwitch]:
            // `left` + `width` so [AnimatedPositioned] interpolates a smooth slide.
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: thumbLeft,
              top: thumbInset,
              bottom: thumbInset,
              width: segmentWidth,
              child: DecoratedBox(decoration: thumbDecoration),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      UiFeedbackUtils.selection();
                      setState(() {
                        _selectedTabIndex = 0;
                        _userPickedTab = true;
                      });
                    },
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                      child: _ToggleTabContent(
                        isSelected: _selectedTabIndex == 0,
                        label: "Мои\nобъявления",
                        badgeCount: incomingCount,
                        selectedTextColor: selectedTextColor,
                        unselectedTextColor: unselectedTextColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      UiFeedbackUtils.selection();
                      setState(() {
                        _selectedTabIndex = 1;
                        _userPickedTab = true;
                      });
                    },
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                      child: _ToggleTabContent(
                        isSelected: _selectedTabIndex == 1,
                        label: "Чужие\nобъявления",
                        badgeCount: outgoingCount,
                        selectedTextColor: selectedTextColor,
                        unselectedTextColor: unselectedTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        if (useGlassPlate) {
          return LiquidGlassPlate(
            height: height,
            borderRadius: BorderRadius.circular(height / 2),
            padding: EdgeInsets.zero,
            child: stack,
          );
        }

        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, cardColor),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: stack,
        );
      },
    );
  }

  /// Pick the initial tab on first load after sign-in based on which tab has
  /// unread messages: only-incoming → tab 0, only-outgoing → tab 1, both or
  /// neither → keep the default (tab 0). Skips if the user has already picked
  /// a tab manually, or if we have already applied the rule this session.
  void _maybeApplyInitialTabRule(List<ConversationSummary> visible) {
    if (_appliedInitialTabRule || _userPickedTab) return;
    if (_currentUserId == null) return;
    _appliedInitialTabRule = true;

    final incoming = visible.where(_isIncomingConversation).toList();
    final outgoing = visible.where(_isOutgoingConversation).toList();

    final incomingHasUnread = _getUnreadCount(incoming) > 0;
    final outgoingHasUnread = _getUnreadCount(outgoing) > 0;

    final desired = (outgoingHasUnread && !incomingHasUnread) ? 1 : 0;
    if (desired == _selectedTabIndex) return;
    if (!mounted) return;
    setState(() => _selectedTabIndex = desired);
  }

  int _getUnreadCount(List<ConversationSummary> conversations) {
    return conversations.fold(0, (sum, conversation) {
      if (conversation.unreadCount != null &&
          conversation.unreadCount! > 0 &&
          _currentUserId != null &&
          conversation.lastMessageSenderId != _currentUserId) {
        return sum + conversation.unreadCount!;
      }
      return sum;
    });
  }

  Widget _buildConversationsList(
    List<ConversationSummary> conversations,
    String type,
  ) {
    if (conversations.isEmpty && _leadingInboxItemCount == 0) {
      return _buildEmptyStateForType(type);
    }

    return _buildDayGroupedConversationsList(
      conversations,
      outgoingInnerTiles: type == "outgoing",
    );
  }

  List<ConversationSummary> _sortConversationsForInbox(
    List<ConversationSummary> conversations,
  ) {
    return List<ConversationSummary>.from(conversations)
      ..sort((a, b) {
        final aHasUnread = a.unreadCount != null &&
            a.unreadCount! > 0 &&
            _currentUserId != null &&
            a.lastMessageSenderId != _currentUserId;
        final bHasUnread = b.unreadCount != null &&
            b.unreadCount! > 0 &&
            _currentUserId != null &&
            b.lastMessageSenderId != _currentUserId;

        if (aHasUnread && !bHasUnread) return -1;
        if (!aHasUnread && bHasUnread) return 1;

        final aTime = a.lastMessageAt ?? a.updatedAt;
        final bTime = b.lastMessageAt ?? b.updatedAt;
        return bTime.compareTo(aTime);
      });
  }

  List<ConversationSummary>? _visibleConversationsFromBloc() {
    final state = context.read<ConversationsBloc>().state;
    if (state is! ConversationsLoaded) return null;
    return _visibleInboxConversations(state.conversations);
  }

  /// Show the archive/read bottom sheet for a conversation. Runs the archive
  /// flow (with unread-blocking + undo) so long-press and swipe-to-archive
  /// share the exact same path — keeps error handling in one place.
  Future<void> _promptConversationActions(
    ConversationSummary conversation,
  ) async {
    HapticFeedbackUtils.impact();
    if (!mounted) return;

    final hasUnread = (conversation.unreadCount ?? 0) > 0 &&
        _currentUserId != null &&
        conversation.lastMessageSenderId != _currentUserId;

    await showAppBottomSheet<void>(
      context: context,
      useSafeArea: false,
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        final radius = const BorderRadius.vertical(top: Radius.circular(20));
        final destructive = AppColors.error;
        return GlassBottomSheetSurface(
          borderRadius: radius,
          child: Material(
            type: MaterialType.transparency,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 10 + MediaQuery.viewPaddingOf(sheetCtx).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ListTileTheme(
                    data: ListTileThemeData(
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      minVerticalPadding: 10,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasUnread)
                          ListTile(
                            leading: const ThemeIcon(
                              Icons.mark_email_read_outlined,
                            ),
                            title: Text(
                              L10n.get("mark_as_read",
                                  fallback: "Mark as read"),
                            ),
                            onTap: () {
                              Navigator.of(sheetCtx).pop();
                              context.read<MessagingBloc>().add(
                                    MarkMessagesAsRead(
                                      conversationId: conversation.id,
                                    ),
                                  );
                            },
                          ),
                        ListTile(
                          leading: ThemeIcon(
                            Icons.archive_outlined,
                            color: hasUnread ? null : destructive,
                          ),
                          title: Text(
                            L10n.get("archive"),
                            style: TextStyle(
                              color: hasUnread ? null : destructive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          enabled: !hasUnread,
                          subtitle: hasUnread
                              ? Text(
                                  L10n.get("archive_failed_has_unread"),
                                  style: const TextStyle(fontSize: 12),
                                )
                              : null,
                          onTap: hasUnread
                              ? null
                              : () {
                                  Navigator.of(sheetCtx).pop();
                                  _archiveConversation(conversation);
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hide the chat immediately and give the user a 5s Telegram-style undo
  /// window before the archive is actually committed to the backend.
  ///
  /// While the window is open the conversation id lives in
  /// [_pendingArchiveIds] — [_visibleInboxConversations] filters it out of the
  /// list, tab counts and the global unread badge. Tapping undo cancels the
  /// timer and drops the id from the pending set (chat reappears in place).
  /// Expiring the timer dispatches [ArchiveConversation] to the bloc, which
  /// performs the real optimistic removal + API call.
  void _archiveConversation(ConversationSummary conversation) {
    HapticFeedbackUtils.tapticChain();
    SendSoundUtils.playSelectionSound();

    final id = conversation.id;

    setState(() {
      _pendingArchiveIds.add(id);
    });
    // Recompute the unread badge right away so the home tab dot disappears
    // synchronously with the ribbon, not after the bloc emits. Task-scoped
    // inbox keeps a filtered cache — do not touch global unreads.
    final cache =
        _lastDisplayedConversations ?? _visibleConversationsFromBloc();
    if (widget.filterGigRequestId == null && cache != null) {
      UnreadMessagesState().updateFromConversations(
        _unreadCountsByConversation(
          cache.where((c) => !_pendingArchiveIds.contains(c.id)).toList(),
        ),
      );
    }

    // Capture refs up-front so commit() still works if the widget unmounts
    // before the timer fires (e.g. user navigates away mid-window — we want
    // the archive to land, not silently drop).
    final bloc = context.read<MessagingBloc>();
    ToastTheme.dismissMessengerSnackBar(context);

    late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
        controller;

    bool resolved = false;

    void commit() {
      if (resolved) return;
      resolved = true;
      bloc.add(ArchiveConversation(conversationId: id));
      // Keep the conversations-only bloc in sync with the archive result.
      context.read<ConversationsBloc>().add(const ConversationsRefresh());
      // Drop the id on the next microtask so the bloc's optimistic removal
      // has already taken effect before this filter stops masking it —
      // avoids a one-frame flash where the chat pops back in.
      Future.microtask(() {
        setStateIfMounted(() {
          _pendingArchiveIds.remove(id);
          // First archive of the session: reveal the archive entry point
          // without waiting for the next probe to round-trip.
          _hasArchivedChats = true;
        });
      });
      controller.close();
    }

    void cancel() {
      if (resolved) return;
      resolved = true;
      HapticFeedbackUtils.impact();
      if (mounted) {
        setState(() {
          _pendingArchiveIds.remove(id);
        });
        // Restore the unread badge now that the chat is visible again.
        final cache =
            _lastDisplayedConversations ?? _visibleConversationsFromBloc();
        if (widget.filterGigRequestId == null && cache != null) {
          UnreadMessagesState().updateFromConversations(
            _unreadCountsByConversation(
              cache.where((c) => !_pendingArchiveIds.contains(c.id)).toList(),
            ),
          );
        }
      }
      controller.close();
    }

    controller = ToastTheme.showMessagingArchiveUndoSnackBar(
      context,
      message: L10n.get("chat_archived"),
      undoLabel: L10n.get("undo"),
      accentColor: AppColors.error,
      messageColor: ThemeState().cardTextColor,
      onTimeout: commit,
      onUndo: cancel,
    );

    // Safety net: if the SnackBar is dismissed externally (e.g. another
    // snackbar preempts it) before the timer fires, commit the archive.
    controller.closed.then((_) {
      if (!resolved) commit();
    });
  }

  /// Show an archive-related warning as the shared rolling top toast.
  ///
  /// The bottom banner is reserved for the "chat archived" confirmation (it
  /// owns the Undo countdown); other archive messages reuse [ToastTheme] for
  /// consistency with the rest of the app.
  void _showArchiveWarning(String message) {
    if (!mounted) return;
    ToastTheme.dismissMessengerSnackBar(context);
    ToastTheme.showWarning(context, message: message);
  }

  Future<void> _openArchivedConversations() async {
    HapticFeedbackUtils.impact();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ArchivedConversationsScreen(),
      ),
    );
    if (mounted) {
      _loadConversations();
      // User may have unarchived their last archived chat; re-probe so the
      // row/icon disappears if the archive is now empty.
      _refreshArchivedChatsFlag();
    }
  }

  Future<void> _openChatScreen(ConversationSummary conversation) async {
    HapticFeedbackUtils.impact();
    if (!mounted) return;
    var me = _currentUserId;
    if (me == null) {
      me = await SessionManager.getUserId();
      if (!mounted) return;
      setState(() => _currentUserId = me);
    }
    final rawCtx = conversation.contextType?.trim().toLowerCase();
    final isGigConversation = (rawCtx != null && rawCtx.startsWith("gig_")) ||
        conversation.gigRequestId != null;
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: ChatScreen.routeName(conversation.id)),
        builder: (context) => ChatScreen(
          conversationId: conversation.id,
          // Listing-only fields: leave null for gig conversations so
          // ChatScreen falls back to its gig branches (no "View
          // listing" / "Complain about listing" actions, etc.).
          listingId: isGigConversation ? null : conversation.listingId,
          listingTypeId: isGigConversation ? null : conversation.listingTypeId,
          // Server convention: listing owner is always `participant_id`.
          // For gig conversations the request author is also the
          // `participant_id` (set authoritatively by the backend), so
          // this still happens to be correct — but we leave it null for
          // gig chats since the field is semantically "listing owner".
          listingOwnerUserId:
              isGigConversation ? null : conversation.participantId,
          conversationContextType: conversation.contextType,
          conversationParticipantId: conversation.participantId,
          gigRequestId: conversation.gigRequestId,
          gigRequestTitle: conversation.gigRequestTitle,
          listingTitle: !isGigConversation
              ? resolvedConversationListingTitle(conversation)
              : null,
          otherUserInitials: StringUtils.extractInitials(
            conversation.otherUserName,
          ),
          otherUserName: conversation.otherUserName,
          otherUserId: conversationCounterpartyUserId(conversation, me),
          otherUserAvatar: conversation.otherUserAvatar,
        ),
      ),
    );
  }

  Widget _buildDayGroupedConversationsList(
    List<ConversationSummary> conversations, {
    required bool outgoingInnerTiles,
  }) {
    final sorted = _sortConversationsForInbox(conversations);
    return GroupedConversationsList(
      conversations: sorted,
      currentUserId: _currentUserId,
      padding: EdgeInsets.fromLTRB(16, 0, 16, _inboxListBottomPadding(context)),
      itemSpacing: 12,
      showActivityTimeOnly: true,
      useOutgoingInnerTiles: outgoingInnerTiles,
      onConversationTap: _openChatScreen,
      onConversationLongPress: _promptConversationActions,
      leadingItemCount: _leadingInboxItemCount,
      leadingItemBuilder:
          _leadingInboxItemCount > 0 ? _buildLeadingInboxItem : null,
    );
  }

  Widget _buildEmptyStateForType(String type) {
    final isIncoming = type == "incoming";
    return UydoshEmptyColumn(
      icon: isIncoming ? Icons.inbox_outlined : Icons.mail_outline,
      title: isIncoming
          ? L10n.get("no_incoming_conversations")
          : L10n.get("no_outgoing_conversations"),
      subtitle:
          isIncoming ? L10n.get("no_incoming_conversations_description") : null,
    );
  }

  Widget _buildEmptyState() {
    if (widget.filterGigRequestId != null) {
      return UydoshEmptyColumn(
        icon: Icons.chat_bubble_outline,
        title: L10n.get("gigs_request_messages_empty"),
        subtitle: L10n.get("gigs_request_messages_empty_subtitle"),
      );
    }
    return UydoshEmptyColumn(
      icon: Icons.chat_bubble_outline,
      title: L10n.get("no_messages"),
      subtitle: L10n.get("no_messages_description"),
    );
  }
}

class _PendingLandlordInviteInboxCard extends StatelessWidget {
  const _PendingLandlordInviteInboxCard({
    required this.invite,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  final PendingLandlordInvite invite;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final useLiquidGlass = themeState.usesLiquidGlassChrome;
    final title = invite.housingListingTitle?.trim();
    final fallbackTitle = invite.groupListingTitle?.trim();
    final bodyTextColor = themeState.isLightTheme
        ? Colors.black
        : themeState.cardSecondaryTextColor;
    final inviteBodyFontSize = (theme.textTheme.bodySmall?.fontSize ?? 12) + 1;
    final joinColor =
        themeState.isLightTheme ? AppColors.successDark : AppColors.success;
    const declineColor = AppColors.error;
    const buttonTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w700,
    );
    final inviteButtonRadius = BorderRadius.circular(12);

    return ThreeDElevatedSurface(
      baseColor:
          useLiquidGlass ? themeState.primaryColor : themeState.cardColor,
      useLiquidGlass: useLiquidGlass,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 38,
              child: Align(
                alignment: Alignment.topCenter,
                child: VerticalParticipantAvatarStack(
                  participants: invite.members,
                  avatarSize: 30,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title != null && title.isNotEmpty
                        ? title
                        : fallbackTitle == null || fallbackTitle.isEmpty
                            ? L10n.get("group_landlord_invite_chat_card_title")
                            : fallbackTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: themeState.cardTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    L10n.get("group_landlord_invite_chat_card_body"),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: bodyTextColor,
                      fontSize: inviteBodyFontSize,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GhostButtonFactory.text(
                        onPressed: busy ? null : onDecline,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        borderWidth: 1.25,
                        borderColor: declineColor,
                        textColor: declineColor,
                        textStyle: buttonTextStyle,
                        borderRadius: inviteButtonRadius,
                        text: L10n.get("group_landlord_invite_decline"),
                      ),
                      const Spacer(),
                      GhostButtonFactory.text(
                        onPressed: busy ? null : onAccept,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        borderWidth: 1.25,
                        borderColor: joinColor,
                        textColor: joinColor,
                        textStyle: buttonTextStyle,
                        borderRadius: inviteButtonRadius,
                        isLoading: busy,
                        text: L10n.get("group_landlord_invite_accept"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Floating pill button that opens [ArchivedConversationsScreen]. Surfaced
/// via [Scaffold.floatingActionButton] and gated on [_hasArchivedChats] so it
/// never leads to an empty folder. Replaces the previous Telegram-style
/// pinned first-row to keep the inbox scroll view purely message-oriented
/// (the archive entry point follows the user's scroll instead of being
/// pushed off-screen with the list).
class _ArchivedChatsFab extends StatelessWidget {
  const _ArchivedChatsFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final scheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final iconColor =
            themeState.isBlueTheme ? Colors.white : themeState.cardIconColor;
        final textColor =
            themeState.isBlueTheme ? Colors.white : themeState.textColor;

        final useGlassChrome = themeState.usesLiquidGlassChrome;
        final enableGlass = LiquidGlassRendering.effectsEnabled(context);

        final baseTint = themeState.isBlueTheme
            ? BlueThemeColors.background
            : (themeState.isLightTheme ? scheme.surface : themeState.cardColor);
        final fillColor = useGlassChrome
            ? baseTint.withValues(alpha: isDark ? 0.14 : 0.18)
            : baseTint;
        final borderColor = useGlassChrome
            ? (themeState.isBlueTheme ? Colors.white : scheme.onSurface)
                .withValues(alpha: themeState.isBlueTheme ? 0.18 : 0.10)
            : scheme.outlineVariant.withValues(alpha: 0.45);

        const radius = BorderRadius.all(Radius.circular(999));
        Widget archivePill(Widget child) {
          if (!useGlassChrome) return child;
          return LiquidGlassRendering.backdropBlur(
            enabled: enableGlass,
            sigma: LiquidGlassRendering.switchGlassBlurSigma,
            child: child,
          );
        }

        return Semantics(
          button: true,
          label: L10n.get("archived_chats"),
          child: Material(
            type: useGlassChrome ? MaterialType.transparency : MaterialType.canvas,
            color: useGlassChrome ? null : fillColor,
            child: ClipRRect(
              borderRadius: radius,
              child: archivePill(
                InkWell(
                  borderRadius: radius,
                  onTap: () {
                    UiFeedbackUtils.selection();
                    onPressed();
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: fillColor,
                      border: Border.all(
                        color: borderColor,
                        width: 0.8,
                      ),
                      boxShadow: useGlassChrome
                          ? [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.22 : 0.10),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ]
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.archive_outlined,
                              size: 20, color: iconColor),
                          const SizedBox(width: 8),
                          Text(
                            L10n.get("archived_chats"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToggleTabContent extends StatelessWidget {
  const _ToggleTabContent({
    required this.isSelected,
    required this.label,
    required this.badgeCount,
    required this.selectedTextColor,
    required this.unselectedTextColor,
  });

  final bool isSelected;
  final String label;
  final int badgeCount;
  final Color selectedTextColor;
  final Color unselectedTextColor;

  @override
  Widget build(BuildContext context) {
    final targetColor = isSelected ? selectedTextColor : unselectedTextColor;
    final iconColor = targetColor;
    final labelParts = label.split("\n");
    final isTwoLine = labelParts.length == 2;
    const twoLineFontSize = 13.0;
    const twoLineHeight = 1.15;
    final hasUnread = badgeCount > 0;
    // Matches [_SegmentedSwitchTab]: opacity + scale only (no slide).
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      opacity: isSelected ? 1.0 : 0.82,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        scale: isSelected ? 1.0 : 0.96,
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: targetColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ThemeIcon(
                      Icons.mail,
                      size: 18,
                      color: iconColor,
                      useThemeColor: false,
                    ),
                    if (hasUnread)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                if (!isTwoLine)
                  Text(label)
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        labelParts[0],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: twoLineFontSize,
                          height: twoLineHeight,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: targetColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labelParts[1],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: twoLineFontSize,
                          height: twoLineHeight,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: targetColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
