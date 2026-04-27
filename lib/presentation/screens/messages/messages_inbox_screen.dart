import "dart:async";
import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
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
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
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
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";
import "package:uy_dosh/presentation/widgets/conversation/grouped_conversations_list.dart";
import "package:uy_dosh/presentation/widgets/conversation/outgoing_conversation_tile.dart";

class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({
    super.key,
    this.showCustomHeader = true,
    /// When non-null, used with [MainNavigation]'s bottom bar: may refresh when
    /// the user switches to this tab (IndexedStack keeps the widget mounted).
    /// Refetch runs only if [UnreadMessagesState] reports unread (e.g. green dot).
    this.mainTabSelected,
  });

  final bool showCustomHeader;

  /// `true` when this screen is the selected main tab; `null` when opened
  /// from the drawer or another route (tab visibility does not apply).
  final bool? mainTabSelected;

  @override
  State<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends State<MessagesInboxScreen>
    with RouteAware, WidgetsBindingObserver {
  int? _currentUserId;
  int _selectedTabIndex = 0; // 0 = incoming, 1 = outgoing
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
  }

  @override
  void didUpdateWidget(covariant MessagesInboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  List<ConversationSummary> _visibleInboxConversations(
    List<ConversationSummary> conversations,
  ) => conversations
      .where(conversationHasMessagesForInbox)
      .where((c) => !_pendingArchiveIds.contains(c.id))
      .toList();

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
          floatingActionButton: _hasArchivedChats
              ? _ArchivedChatsFab(onPressed: _openArchivedConversations)
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

              // Calculate total unread count and update global state
              final totalUnreadCount = _calculateTotalUnreadCount(visible);
              UnreadMessagesState().updateUnreadCount(totalUnreadCount);
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
          final themeState = ThemeState();
          return AuthRequiredState(
            message:
                "Please log in again to view your messages. Your session may have expired.",
            buttonLabel: "Log In Again",
            iconSize: 64,
            titleFontSize: 24,
            iconColor: themeState.primaryColor,
            titleColor: themeState.primaryColor,
            messageColor: themeState.secondaryTextColor,
            onLogin: AuthRequiredState.logoutAndReauthenticate(context),
          );
        },
      );
    }

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final buttonColor = themeState.buttonColor;
        final buttonTextColor = themeState.buttonTextColor;

        return UydoshErrorRetryColumn(
          iconColor: AppColors.error,
          title: "Error",
          titleStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.error,
          ),
          message: message,
          messageStyle: TextStyle(
            fontSize: 16,
            color: themeState.secondaryTextColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32),
          spacingAfterIcon: 16,
          spacingAfterTitle: 8,
          spacingBeforeButton: 24,
          retryButton: ThreeDPillButton(
            onPressed: _loadConversations,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            backgroundColor: buttonColor,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeIcon(Icons.refresh, size: 18, color: buttonTextColor),
                const SizedBox(width: 8),
                Text(
                  L10n.get("retry"),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: buttonTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, cardColor),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Stack(
        children: [
          // Animated background slider
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _selectedTabIndex == 0 ? 2 : null,
            right: _selectedTabIndex == 1 ? 2 : null,
            top: 2,
            bottom: 2,
            child: Container(
              width:
                  (MediaQuery.of(context).size.width - 32 - 4) /
                  2, // Parent horizontal padding (16*2) and thumb inset (2*2)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: ThreeDSurfaceStyle.surfaceGradient(
                  context,
                  primaryColor,
                ),
                boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
              ),
            ),
          ),
          // Toggle buttons
          Row(
            children: [
              // Incoming button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedbackUtils.selection();
                    setState(() => _selectedTabIndex = 0);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
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
              // Outgoing button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedbackUtils.selection();
                    setState(() => _selectedTabIndex = 1);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
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
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        final radius = const BorderRadius.vertical(top: Radius.circular(20));
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassBottomSheetSurface(
            borderRadius: radius,
            child: Material(
              type: MaterialType.transparency,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.18,
                          ),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
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
                        leading: const ThemeIcon(Icons.archive_outlined),
                        title: Text(L10n.get("archive")),
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

    final id = conversation.id;

    setState(() {
      _pendingArchiveIds.add(id);
    });
    // Recompute the unread badge right away so the home tab dot disappears
    // synchronously with the ribbon, not after the bloc emits.
    final cache = _lastDisplayedConversations;
    if (cache != null) {
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
        if (cache != null) {
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
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        padding: EdgeInsets.zero,
        content: ThreeDElevatedSurface(
          baseColor: ThemeState().cardColor,
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              conversationId: conversation.id,
              listingId: conversation.listingId,
              listingTypeId: conversation.listingTypeId,
              // Server convention: listing owner is always `participant_id`.
              listingOwnerUserId: conversation.participantId,
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
    return UydoshEmptyColumn(
      icon: Icons.chat_bubble_outline,
      title: L10n.get("no_messages"),
      subtitle: L10n.get("no_messages_description"),
    );
  }
}

sealed class _InboxListEntry {}

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
        // cardColor matches the surrounding inbox tiles so the pill reads as
        // "part of this screen" rather than a flashy global CTA — archive is
        // secondary navigation, not a primary action.
        final backgroundColor = themeState.cardColor;
        final iconColor = themeState.cardIconColor;
        final textColor = themeState.textColor;

        return Semantics(
          button: true,
          label: L10n.get("archived_chats"),
          child: ThreeDPillButton(
            onPressed: () {
              HapticFeedbackUtils.selection();
              onPressed();
            },
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      opacity: isSelected ? 1.0 : 0.82,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        scale: isSelected ? 1.0 : 0.96,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          offset: isSelected ? Offset.zero : const Offset(0, 0.06),
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
                          right: -3,
                          top: -3,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
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
