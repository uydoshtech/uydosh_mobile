import "dart:async";
import "dart:ui" show ImageFilter;

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
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/domain/services/push_notification_service.dart";
import "package:uy_dosh/main.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/messages/archived_conversations_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_inbox_filters.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/message_grouping_utils.dart";
import "package:uy_dosh/presentation/widgets/common/app_bar_profile_icon.dart";
import "package:uy_dosh/presentation/widgets/common/auth_required_state.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/common_state_builder.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/roll_up_fade_out.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";
import "package:uy_dosh/presentation/widgets/conversation/grouped_conversations_list.dart";
import "package:uy_dosh/presentation/widgets/conversation/outgoing_conversation_tile.dart";
import "package:uy_dosh/presentation/widgets/messages/inbox_push_banner.dart";

class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({
    super.key,
    this.showCustomHeader = true,
    /// When non-null, used with [MainNavigation]'s bottom bar: may refresh when
    /// the user switches to this tab (IndexedStack keeps the widget mounted).
    /// Refetch runs only if [UnreadMessagesState] reports unread (e.g. green dot).
    this.mainTabSelected,
    /// Non-null on [PushedMessagesInboxScaffold] from task detail: inbox shows
    /// only `gig_request` threads tied to this request id (plus empty states).
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

  /// Conversations the user just archived but whose commit is still inside the
  /// 5s undo window. They are hidden from every list/badge computation; the
  /// real `ArchiveConversation` event only fires once the countdown elapses.
  final Set<int> _pendingArchiveIds = <int>{};

  /// Per-conversation step counter for swipe-to-archive haptics.
  final Map<int, int> _archiveSwipeHapticStepById = <int, int>{};

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
  static const Duration _pushBannerCloseDuration =
      Duration(milliseconds: 300);

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

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "messages_inbox");
    _initializeUser();
    _loadConversations();
    _refreshArchivedChatsFlag();
    WidgetsBinding.instance.addObserver(this);

    // Listen for authentication state changes to refresh conversations when user logs in
    AuthenticationState().addListener(_onAuthenticationStateChanged);

    _lastObservedUnreadCount = UnreadMessagesState().unreadCount;
    _unreadMessagesListener = _onUnreadMessagesChanged;
    UnreadMessagesState().addListener(_unreadMessagesListener);

    _refreshPushBannerVisibility();
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
        _loadConversations();
        _refreshArchivedChatsFlag();
      } else {
        // Clear conversations when user logs out
        logger.d(
          "🔍 [MessagesInboxScreen] User logged out, clearing conversations...",
        );
        context.read<MessagingBloc>().add(ClearConversations());
        if (_hasArchivedChats) {
          setState(() => _hasArchivedChats = false);
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
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
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
    _loadConversations();
    // User may have archived/unarchived from ChatScreen's overflow menu, or
    // their last archived chat may have been auto-unarchived by a reply.
    _refreshArchivedChatsFlag();
  }

  void _loadConversations() {
    logger.d("🔍 [MessagesInboxScreen] Loading conversations...");
    if (mounted) {
      context.read<MessagingBloc>().add(RefreshConversations());
    }
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
      final age =
          DateTime.now().millisecondsSinceEpoch - dismissedAtMs;
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

  /// Calculate total unread count from all conversations
  int _calculateTotalUnreadCount(List<ConversationSummary> conversations) {
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
    var list = conversations
        .where((c) => !_pendingArchiveIds.contains(c.id))
        .toList();

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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final backgroundColor = themeState.backgroundColor;

        return Scaffold(
          extendBodyBehindAppBar:
              widget.showCustomHeader &&
              (themeState.isBlueTheme || themeState.isLightTheme),
          backgroundColor: backgroundColor,
          appBar: widget.showCustomHeader ? _buildCustomHeader() : null,
          body: _buildContent(),
          floatingActionButton:
              _hasArchivedChats && widget.filterGigRequestId == null
              ? Padding(
                // Lift the pill above the main bottom bar.
                padding: const EdgeInsets.only(bottom: 24),
                child: _ArchivedChatsFab(onPressed: _openArchivedConversations),
              )
              : null,
        );
      },
    );
  }

  Widget _buildContent() {
    return BlocListener<MessagingBloc, MessagingState>(
        listener: (context, state) {
          // Handle unread count updates outside of build method
          state.when(
            initial: () {},
            loading: () {},
            conversationsLoaded: (conversations, hasMore, currentPage) {
              final visible = _visibleInboxConversations(
                conversations.cast<ConversationSummary>(),
              );
              logger.d(
                "🔍 [MessagesInboxScreen] Conversations loaded: ${conversations.length} conversations (${visible.length} with messages)",
              );

              // Cache for smooth refresh (no blink when returning to screen)
              if (mounted) {
                setState(() {
                  _lastDisplayedConversations = List<ConversationSummary>.from(
                    visible,
                  );
                });
              }

              // First load after sign-in: auto-pick the tab that has unread
              // messages so the user lands on the conversation that needs
              // their attention. If both tabs have unreads (or neither does),
              // keep the default left tab.
              _maybeApplyInitialTabRule(visible);

              // Full inbox only: task-filtered route must not overwrite the
              // shell unread badge (those threads are a subset).
              if (widget.filterGigRequestId == null) {
                final totalUnreadCount = _calculateTotalUnreadCount(visible);
                UnreadMessagesState().updateUnreadCount(totalUnreadCount);
              }
            },
            conversationsCleared: () {
              if (mounted) {
                setState(() => _lastDisplayedConversations = null);
              }
              // Clear unread count when conversations are cleared
              UnreadMessagesState().clearUnreadCount();
            },
            messagesLoaded: (messages, hasMore, currentPage, conversationId) {},
            conversationCreated: (conversation) {},
            messageSent: (message) {},
            messagesMarkedAsRead: (conversationId, markedCount) {
              // Refresh conversations to get updated unread counts
              _loadConversations();
            },
            error: (message) {
              // Archive-specific error: surface a localized toast rather
              // than the generic error screen. Other errors fall through
              // to the BlocBuilder's error state.
              if (message == archiveHasUnreadErrorCode && mounted) {
                _showArchiveWarning(L10n.get("archive_failed_has_unread"));
              }
            },
          );
        },
        child: BlocBuilder<MessagingBloc, MessagingState>(
          builder: (context, state) {
            return state.when(
              initial: _buildLoadingState,
              loading: _showCachedOrLoading,
              conversationsLoaded: (conversations, hasMore, currentPage) {
                final visible = _visibleInboxConversations(
                  conversations.cast<ConversationSummary>(),
                );
                return _buildTabbedConversationsList(visible);
              },
              conversationsCleared: _buildEmptyState,
              messagesLoaded:
                  (messages, hasMore, currentPage, conversationId) =>
                      _showCachedOrLoading(),
              conversationCreated: (conversation) => _showCachedOrLoading(),
              messageSent: (message) => _showCachedOrLoading(),
              messagesMarkedAsRead:
                  (conversationId, markedCount) => _showCachedOrLoading(),
              error: _buildErrorState,
            );
          },
        ),
    );
  }

  PreferredSizeWidget _buildCustomHeader() {
    final themeState = ThemeState();
    final useLiquidGlass = themeState.isBlueTheme || themeState.isLightTheme;
    final appBarTheme = Theme.of(context).appBarTheme;
    final appBarBackgroundColor =
        appBarTheme.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final onBarColor =
        useLiquidGlass
            ? (appBarTheme.foregroundColor ?? themeState.textColor)
            : themeState.textColor;

    return UydoshAppBar(
      toolbarHeight: standardAppBarToolbarHeight,
      leading: ThreeDAppBarIconButton.backLeading(context),
      centerTitle: true,
      title: Text(
        L10n.get("messages"),
        style:
            appBarTheme.titleTextStyle?.copyWith(
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
      backgroundColor:
          useLiquidGlass
              ? liquidGlassAppBarMaterialColor(context)
              : appBarBackgroundColor,
      surfaceTintColor:
          useLiquidGlass ? Colors.transparent : appBarTheme.surfaceTintColor,
      elevation: useLiquidGlass ? 0 : null,
      scrolledUnderElevation: useLiquidGlass ? 0 : null,
      shadowColor: useLiquidGlass ? Colors.transparent : appBarTheme.shadowColor,
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

  Color _getEmptyStateIconColor() => ThemeState().isBlueTheme
      ? AppColors.textLight
      : AppColors.textGrey400;

  Color _getEmptyStateTextColor() => ThemeState().isBlueTheme
      ? AppColors.textLight
      : AppColors.textGrey400;

  Widget _buildTabbedConversationsList(
    List<ConversationSummary> conversations,
  ) {
    if (conversations.isEmpty) {
      return _buildEmptyState();
    }

    // Filter conversations into incoming and outgoing
    final incomingConversations =
        conversations
            .where(
              (conv) =>
                  _currentUserId != null &&
                  conv.participantId == _currentUserId,
            )
            .toList();
    final outgoingConversations =
        conversations
            .where(
              (conv) =>
                  _currentUserId != null && conv.initiatorId == _currentUserId,
            )
            .toList();

    final shellGlassTop =
        widget.showCustomHeader
            ? ((ThemeState().isBlueTheme || ThemeState().isLightTheme)
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
          // List scrolls "under" the glass tab switcher.
          Positioned.fill(
            child: Padding(
              // 8 top + 48 switch + 12 bottom
              padding: const EdgeInsets.only(top: 68),
              child: UydoshRefreshIndicator.mainShell(
                onRefresh: _onInboxPullRefresh,
                // The scrollable is already positioned under the switch (68px),
                // so keep the indicator anchored to the top of this area.
                edgeOffset: 0.0,
                child: PullToRefreshStretchHaptics(
                  child:
                      _selectedTabIndex == 0
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
            child: _buildTabButtons(incomingConversations, outgoingConversations),
          ),
        ],
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

        if (!(themeState.isBlueTheme || themeState.isLightTheme)) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: switcher,
          );
        }

        const radius = BorderRadius.all(Radius.circular(20));
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scheme = Theme.of(context).colorScheme;
        final baseTint =
            isDark ? BlueThemeColors.background : scheme.surface;
        final disableAnimations =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final enableGlass =
            AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;

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
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: enableGlass ? 18 : 0,
                            sigmaY: enableGlass ? 18 : 0,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          // Match the app bar glass: subtle tint + hairline edge.
                          color: baseTint.withValues(alpha: isDark ? 0.10 : 0.12),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final innerTrack =
            (constraints.maxWidth - thumbInset * 2).clamp(0.0, double.infinity);
        final segmentWidth = innerTrack / 2;
        final thumbLeft = thumbInset + _selectedTabIndex * segmentWidth;

        return Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, cardColor),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: Stack(
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
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(innerRadius),
                    gradient: ThreeDSurfaceStyle.surfaceGradient(
                      context,
                      primaryColor,
                    ),
                    boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedbackUtils.selection();
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
                        HapticFeedbackUtils.selection();
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
          ),
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

    final incoming = visible
        .where((c) => c.participantId == _currentUserId)
        .toList();
    final outgoing = visible
        .where((c) => c.initiatorId == _currentUserId)
        .toList();

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
    if (conversations.isEmpty) {
      return _buildEmptyStateForType(type);
    }

    return _buildDayGroupedConversationsList(
      conversations,
      outgoingTiles: type == "outgoing",
    );
  }

  /// Calendar day (local midnight boundary) for last activity on a thread.
  DateTime _activityCalendarDay(ConversationSummary c) {
    final raw = c.lastMessageAt ?? c.updatedAt;
    final dt = DateTime.parse(raw).toLocal();
    return DateTime(dt.year, dt.month, dt.day);
  }

  String _activityDayKey(ConversationSummary c) {
    final d = _activityCalendarDay(c);
    return "${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}";
  }

  List<ConversationSummary> _sortConversationsForInbox(
    List<ConversationSummary> conversations,
  ) {
    return List<ConversationSummary>.from(conversations)..sort((a, b) {
      final aHasUnread =
          a.unreadCount != null &&
          a.unreadCount! > 0 &&
          _currentUserId != null &&
          a.lastMessageSenderId != _currentUserId;
      final bHasUnread =
          b.unreadCount != null &&
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

  List<_InboxListEntry> _inboxEntriesWithDayHeaders(
    List<ConversationSummary> conversations,
  ) {
    final sorted = _sortConversationsForInbox(conversations);
    final entries = <_InboxListEntry>[];
    String? lastDayKey;
    for (final c in sorted) {
      final key = _activityDayKey(c);
      if (key != lastDayKey) {
        lastDayKey = key;
        entries.add(_InboxDayHeader(_activityCalendarDay(c)));
      }
      entries.add(_InboxConversationRow(c));
    }
    return entries;
  }

  /// Incoming: calendar day headers, then collapsible listing groups for that day.
  List<_InboxListEntry> _incomingEntriesWithDaySections(
    List<ConversationSummary> conversations,
  ) {
    final sorted = _sortConversationsForInbox(conversations);
    final entries = <_InboxListEntry>[];
    String? lastDayKey;
    var dayBucket = <ConversationSummary>[];

    void flushDay() {
      if (dayBucket.isEmpty) {
        return;
      }
      entries.add(_InboxIncomingDaySection(List<ConversationSummary>.from(dayBucket)));
      dayBucket = [];
    }

    for (final c in sorted) {
      final key = _activityDayKey(c);
      if (key != lastDayKey) {
        flushDay();
        lastDayKey = key;
        entries.add(_InboxDayHeader(_activityCalendarDay(c)));
      }
      dayBucket.add(c);
    }
    flushDay();
    return entries;
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

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        final radius = const BorderRadius.vertical(top: Radius.circular(20));
        final destructive = AppColors.error;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassBottomSheetSurface(
            borderRadius: radius,
            child: Material(
              type: MaterialType.transparency,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.18),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                                L10n.get("mark_as_read", fallback: "Mark as read"),
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
    final cache = _lastDisplayedConversations;
    if (widget.filterGigRequestId == null && cache != null) {
      UnreadMessagesState().updateUnreadCount(
        _calculateTotalUnreadCount(
          cache.where((c) => !_pendingArchiveIds.contains(c.id)).toList(),
        ),
      );
    }

    // Capture refs up-front so commit() still works if the widget unmounts
    // before the timer fires (e.g. user navigates away mid-window — we want
    // the archive to land, not silently drop).
    final bloc = context.read<MessagingBloc>();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
        controller;

    bool resolved = false;

    void commit() {
      if (resolved) return;
      resolved = true;
      bloc.add(ArchiveConversation(conversationId: id));
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
        final cache = _lastDisplayedConversations;
        if (widget.filterGigRequestId == null && cache != null) {
          UnreadMessagesState().updateUnreadCount(
            _calculateTotalUnreadCount(
              cache.where((c) => !_pendingArchiveIds.contains(c.id)).toList(),
            ),
          );
        }
      }
      controller.close();
    }

    controller = messenger.showSnackBar(
      SnackBar(
        // The content drives dismissal via [commit]/[cancel]; keep the
        // SnackBar itself alive well past the 5s window so our timer wins.
        duration: const Duration(days: 1),
        // Strip SnackBar chrome — the [ThreeDElevatedSurface] below is the
        // visible banner (same neumorphic language as [ConversationTile] but
        // sized for a transient ribbon).
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: EdgeInsets.zero,
        content: _GlassySnackBarSurface(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 10, 10),
            child: _ArchiveCountdownContent(
              message: L10n.get("chat_archived"),
              undoLabel: L10n.get("undo"),
              duration: const Duration(seconds: 5),
              accentColor: AppColors.error,
              messageColor: ThemeState().cardTextColor,
              onTimeout: commit,
              onUndo: cancel,
            ),
          ),
        ),
      ),
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
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ToastTheme.showWarning(context, message: message);
  }

  /// Wrap a tile in a leading-swipe [Dismissible] that archives on release.
  /// Trailing-only swipe (end→start) — avoids conflicting with the chat list
  /// scroll and mirrors WhatsApp/Telegram iOS behavior.
  Widget _wrapWithArchiveSwipe({
    required Widget child,
    required ConversationSummary conversation,
  }) {
    final hasUnread = (conversation.unreadCount ?? 0) > 0 &&
        _currentUserId != null &&
        conversation.lastMessageSenderId != _currentUserId;

    final ts = ThemeState();
    // Blue theme uses `primaryColor == background`, so the old styling could
    // make the swipe affordance invisible. Use a high-contrast white affordance
    // on blue, and keep the existing primary-tinted affordance on light theme.
    final swipeFgColor = ts.isBlueTheme ? Colors.white : ts.primaryColor;
    final swipeBgColor = ts.isBlueTheme
        ? Colors.white.withValues(alpha: 0.14)
        : ts.primaryColor.withValues(alpha: 0.18);

    return Dismissible(
      key: ValueKey("conv-swipe-${conversation.id}"),
      direction: DismissDirection.endToStart,
      onUpdate: (details) {
        // Fire "chain" ticks as the swipe progresses (similar to pull-to-refresh
        // stretch haptics): multiple small steps instead of a single impact.
        //
        // Dismissible reports progress in [0..1]. We map it to discrete steps
        // so users feel ticks while dragging, not only after dismissal.
        final steps = 7;
        final currentStep = (details.progress * steps).floor();
        final lastStep = _archiveSwipeHapticStepById[conversation.id] ?? 0;

        if (currentStep > lastStep) {
          for (var i = lastStep; i < currentStep; i++) {
            HapticFeedbackUtils.selectionClick();
          }
          _archiveSwipeHapticStepById[conversation.id] = currentStep;
        } else if (currentStep <= 0 && lastStep != 0) {
          _archiveSwipeHapticStepById[conversation.id] = 0;
        }
      },
      confirmDismiss: (_) async {
        if (hasUnread) {
          _showArchiveWarning(L10n.get("archive_failed_has_unread"));
          return false;
        }
        return true;
      },
      onDismissed: (_) {
        _archiveSwipeHapticStepById.remove(conversation.id);
        _archiveConversation(conversation);
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        decoration: BoxDecoration(
          color: swipeBgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeIcon(Icons.archive_outlined, color: swipeFgColor),
            const SizedBox(width: 8),
            Text(
              L10n.get("archive"),
              style: TextStyle(
                color: swipeFgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: child,
    );
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
    final isGigRequest = conversation.contextType == "gig_request";
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: ChatScreen.routeName(conversation.id)),
        builder:
            (context) => ChatScreen(
              conversationId: conversation.id,
              // Listing-only fields: leave null for gig conversations so
              // ChatScreen falls back to its gig branches (no "View
              // listing" / "Complain about listing" actions, etc.).
              listingId: isGigRequest ? null : conversation.listingId,
              listingTypeId: isGigRequest ? null : conversation.listingTypeId,
              // Server convention: listing owner is always `participant_id`.
              // For gig conversations the request author is also the
              // `participant_id` (set authoritatively by the backend), so
              // this still happens to be correct — but we leave it null for
              // gig chats since the field is semantically "listing owner".
              listingOwnerUserId:
                  isGigRequest ? null : conversation.participantId,
              gigRequestId:
                  isGigRequest ? conversation.gigRequestId : null,
              gigRequestTitle:
                  isGigRequest ? conversation.gigRequestTitle : null,
              otherUserInitials: StringUtils.extractInitials(
                conversation.otherUserName,
              ),
              otherUserName: conversation.otherUserName,
              otherUserId:
                  conversation.initiatorId == _currentUserId
                      ? conversation.participantId
                      : conversation.initiatorId,
              otherUserAvatar: conversation.otherUserAvatar,
            ),
      ),
    );
  }

  Widget _buildDayGroupedConversationsList(
    List<ConversationSummary> conversations, {
    required bool outgoingTiles,
  }) {
    final entries = <_InboxListEntry>[
      if (_shouldRenderPushBannerRow) _InboxPushBannerRow(),
      ...(outgoingTiles
          ? _inboxEntriesWithDayHeaders(conversations)
          : _incomingEntriesWithDaySections(conversations)),
    ];
    return CommonListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemSpacing: 12,
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isFirstRow = index == 0;
        return switch (entry) {
          _InboxPushBannerRow() => Padding(
            // Slightly larger top breathing room so the banner doesn't kiss
            // the pinned tab toggle that floats above the list.
            padding: const EdgeInsets.only(top: 4),
            child: _pushBannerClosing
                ? RollUpFadeOut(
                    duration: _pushBannerCloseDuration,
                    child: InboxPushBanner(
                      key: const ValueKey("inbox_push_banner"),
                      status:
                          _pushStatus ?? AuthorizationStatus.notDetermined,
                      busy: _pushBannerBusy,
                      onPressed: _onPushBannerPressed,
                      onDismiss: _onPushBannerDismiss,
                    ),
                  )
                : InboxPushBanner(
                    key: const ValueKey("inbox_push_banner"),
                    status:
                        _pushStatus ?? AuthorizationStatus.notDetermined,
                    busy: _pushBannerBusy,
                    onPressed: _onPushBannerPressed,
                    onDismiss: _onPushBannerDismiss,
                  ),
          ),
          _InboxDayHeader(:final dayStart) => DateHeaderWidget(
            dateString: MessageGroupingUtils.formatDateHeader(
              dayStart,
              context,
            ),
            date: dayStart,
            padding: isFirstRow
                ? const EdgeInsets.only(top: 8, bottom: 6)
                : null,
          ),
          _InboxIncomingDaySection(:final conversations) =>
            GroupedConversationsList(
              conversations: conversations,
              currentUserId: _currentUserId,
              embedInParentScrollView: true,
              padding: EdgeInsets.zero,
              itemSpacing: 12,
              showActivityTimeOnly: true,
              onConversationTap: _openChatScreen,
              onConversationLongPress: _promptConversationActions,
            ),
          _InboxConversationRow(:final conversation) => _wrapWithArchiveSwipe(
              conversation: conversation,
              child: outgoingTiles
                  ? OutgoingConversationTile(
                      conversation: conversation,
                      currentUserId: _currentUserId,
                      showActivityTimeOnly: true,
                      onTap: () {
                        _openChatScreen(conversation);
                      },
                      onLongPress: () => _promptConversationActions(conversation),
                    )
                  : ConversationTile(
                      conversation: conversation,
                      currentUserId: _currentUserId,
                      isGrouped: false,
                      showActivityTimeOnly: true,
                      onTap: () {
                        _openChatScreen(conversation);
                      },
                      onLongPress: () => _promptConversationActions(conversation),
                    ),
            ),
        };
      },
    );
  }

  Widget _buildEmptyStateForType(String type) {
    final isIncoming = type == "incoming";
    return UydoshEmptyColumn(
      icon: isIncoming ? Icons.inbox_outlined : Icons.mail_outline,
      title: isIncoming
          ? L10n.get("no_incoming_conversations")
          : L10n.get("no_outgoing_conversations"),
      subtitle: isIncoming
          ? L10n.get("no_incoming_conversations_description")
          : null,
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

sealed class _InboxListEntry {}

/// Sentinel "row" rendered as the first item of the inbox list when the OS
/// push permission is missing. Carrying it through the same entry pipeline
/// lets it scroll away with the rest of the content (rather than steal a
/// pinned slot above the incoming/outgoing toggle).
final class _InboxPushBannerRow extends _InboxListEntry {
  _InboxPushBannerRow();
}

final class _InboxDayHeader extends _InboxListEntry {
  _InboxDayHeader(this.dayStart);
  final DateTime dayStart;
}

final class _InboxConversationRow extends _InboxListEntry {
  _InboxConversationRow(this.conversation);
  final ConversationSummary conversation;
}

final class _InboxIncomingDaySection extends _InboxListEntry {
  _InboxIncomingDaySection(this.conversations);
  final List<ConversationSummary> conversations;
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

        final iconColor = themeState.isBlueTheme ? Colors.white : themeState.cardIconColor;
        final textColor = themeState.isBlueTheme ? Colors.white : themeState.textColor;

        final disableAnimations =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final enableGlass =
            AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;

        final baseTint =
            themeState.isBlueTheme
                ? BlueThemeColors.background
                : (themeState.isLightTheme ? scheme.surface : themeState.cardColor);

        const radius = BorderRadius.all(Radius.circular(999));

        return Semantics(
          button: true,
          label: L10n.get("archived_chats"),
          child: Material(
            type: MaterialType.transparency,
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: enableGlass ? 18 : 0,
                  sigmaY: enableGlass ? 18 : 0,
                ),
                child: InkWell(
                  borderRadius: radius,
                  onTap: () {
                    HapticFeedbackUtils.selection();
                    onPressed();
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      color: baseTint.withValues(alpha: isDark ? 0.14 : 0.18),
                      border: Border.all(
                        color: (themeState.isBlueTheme ? Colors.white : scheme.onSurface)
                            .withValues(alpha: themeState.isBlueTheme ? 0.18 : 0.10),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.10),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.archive_outlined, size: 20, color: iconColor),
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
                    ThemeIcon(Icons.mail, size: 18, color: targetColor),
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
                              isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
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
                              isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
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

/// Snackbar body used for the "archive with 5s undo" ribbon.
///
/// Mirrors Telegram: the message sits on the left, a circular progress
/// indicator shrinks clockwise around an undo icon on the right, and tapping
/// anywhere on the trailing cluster (icon or label) cancels the archive.
/// The surrounding [SnackBar] uses a long duration so timing is driven here.
class _ArchiveCountdownContent extends StatefulWidget {
  const _ArchiveCountdownContent({
    required this.message,
    required this.undoLabel,
    required this.duration,
    required this.accentColor,
    required this.messageColor,
    required this.onTimeout,
    required this.onUndo,
  });

  final String message;
  final String undoLabel;
  final Duration duration;
  final Color accentColor;
  final Color messageColor;
  final VoidCallback onTimeout;
  final VoidCallback onUndo;

  @override
  State<_ArchiveCountdownContent> createState() =>
      _ArchiveCountdownContentState();
}

class _ArchiveCountdownContentState extends State<_ArchiveCountdownContent>
    with TickerProviderStateMixin {
  static const Duration _fadeOutDuration = Duration(milliseconds: 320);

  late final AnimationController _controller;
  late final AnimationController _fadeController;
  bool _fadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_fadingOut) {
          _startFadeOut();
        }
      })
      ..forward();
    _fadeController = AnimationController(
      vsync: this,
      duration: _fadeOutDuration,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startFadeOut() {
    if (_fadingOut) return;
    setState(() => _fadingOut = true);
    _fadeController.reverse().whenComplete(() {
      if (!mounted) return;
      widget.onTimeout();
    });
  }

  void _handleUndo() {
    // Disallow undo once we start fading out — archive is already committing.
    if (_fadingOut) return;
    if (_controller.isCompleted) return;
    _controller.stop();
    widget.onUndo();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.duration.inMilliseconds / 1000.0;
    final totalSecondsCeil = totalSeconds.ceil();

    return FadeTransition(
      opacity: _fadeController,
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(color: widget.messageColor, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _handleUndo,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) => SizedBox.expand(
                            child: CircularProgressIndicator(
                              // Countdown: ring drains from full → empty.
                              value: 1.0 - _controller.value,
                              strokeWidth: 2.5,
                              valueColor:
                                  AlwaysStoppedAnimation(widget.accentColor),
                              backgroundColor:
                                  widget.accentColor.withValues(alpha: 0.22),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final remaining = (totalSeconds *
                                    (1.0 - _controller.value))
                                .ceil()
                                .clamp(1, totalSecondsCeil);
                            return Text(
                              "$remaining",
                              style: TextStyle(
                                color: widget.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.undoLabel,
                    style: TextStyle(
                      color: widget.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassySnackBarSurface extends StatelessWidget {
  const _GlassySnackBarSurface({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimationSettingsState(),
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;

        final disableAnimations =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final enableGlass =
            AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;

        final baseSurface = isDark ? Colors.black : scheme.surface;
        final surfaceTint =
            Color.lerp(baseSurface, scheme.primary, isDark ? 0.06 : 0.08) ??
                baseSurface;

        final decoration = BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: isDark ? 0.06 : 0.26),
              surfaceTint.withValues(alpha: isDark ? 0.22 : 0.30),
              baseSurface.withValues(alpha: isDark ? 0.24 : 0.28),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.40),
            width: 0.7,
          ),
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.14),
                blurRadius: isDark ? 26 : 22,
                spreadRadius: isDark ? 1.5 : 1,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: enableGlass
                ? BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: isDark ? 22 : 26,
                      sigmaY: isDark ? 22 : 26,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: DecoratedBox(decoration: decoration, child: child),
                    ),
                  )
                : Material(
                    color: Colors.transparent,
                    child: DecoratedBox(decoration: decoration, child: child),
                  ),
          ),
        );
      },
    );
  }
}
