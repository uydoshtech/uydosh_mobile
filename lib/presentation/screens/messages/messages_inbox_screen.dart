import "dart:async";
import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/main.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_inbox_filters.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/message_grouping_utils.dart";
import "package:uy_dosh/presentation/widgets/common/app_bar_profile_icon.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
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

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "messages_inbox");
    _initializeUser();
    _loadConversations();
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
      } else {
        // Clear conversations when user logs out
        logger.d(
          "🔍 [MessagesInboxScreen] User logged out, clearing conversations...",
        );
        context.read<MessagingBloc>().add(ClearConversations());
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
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another screen (e.g. ChatScreen)
    _loadConversations();
  }

  void _loadConversations() {
    logger.d("🔍 [MessagesInboxScreen] Loading conversations...");
    if (mounted) {
      context.read<MessagingBloc>().add(RefreshConversations());
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
  ) => conversations.where(conversationHasMessagesForInbox).toList();

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
            error: (message) {},
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
      backgroundColor: useLiquidGlass ? Colors.transparent : appBarBackgroundColor,
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
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 8),
          child: IconButton(
            onPressed: () => context.pushProfile(),
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
    // Check if this is an authentication error
    final isAuthError =
        message.contains("401") ||
        message.contains("Unauthorized") ||
        message.contains("Invalid or expired session token") ||
        message.contains("Authentication required");

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final primaryColor = themeState.primaryColor;
        final secondaryTextColor = themeState.secondaryTextColor;
        final buttonColor = themeState.buttonColor;
        final buttonTextColor = themeState.buttonTextColor;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeIcon(
                  isAuthError ? Icons.lock_outline : Icons.error_outline,
                  size: 64,
                  color: isAuthError ? primaryColor : AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  isAuthError ? "Authentication Required" : "Error",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isAuthError ? primaryColor : AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  isAuthError
                      ? "Please log in again to view your messages. Your session may have expired."
                      : message,
                  style: TextStyle(fontSize: 16, color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (isAuthError) ...[
                  GhostButtonFactory.iconText(
                    onPressed: () async {
                      // Use centralized logout service
                      await LogoutService().performLogout(context);
                      // Navigate to auth wizard
                      context.pushReplaceAuthWizard();
                    },
                    icon: Icons.login,
                    text: "Log In Again",
                  ),
                ] else ...[
                  ThreeDPillButton(
                    onPressed: _loadConversations,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
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
                ],
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
              child: UydoshRefreshIndicator(
                onRefresh: _onInboxPullRefresh,
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

        final content = Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: _buildToggleSwitch(
            context,
            incomingCount: _getUnreadCount(incoming),
            outgoingCount: _getUnreadCount(outgoing),
            primaryColor: primaryColor,
            cardColor: cardColor,
          ),
        );

        if (!(themeState.isBlueTheme || themeState.isLightTheme)) {
          return content;
        }

        const radius = BorderRadius.all(Radius.circular(20));
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final scheme = Theme.of(context).colorScheme;
        final baseTint =
            isDark
                ? BlueThemeColors.background
                : (Color.lerp(scheme.surface, scheme.primary, 0.06) ??
                    scheme.surface);

        return ClipRRect(
          borderRadius: radius,
          child: Stack(
            children: [
              // Blur is subtle on flat backgrounds, so we also apply a clear glass tint.
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: const SizedBox.expand(),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  // Match the app bar glass: subtle tint + hairline edge.
                  color: baseTint.withValues(alpha: isDark ? 0.10 : 0.12),
                ),
                child: content,
              ),
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

  Future<void> _openChatScreen(ConversationSummary conversation) async {
    HapticFeedbackUtils.impact();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              conversationId: conversation.id,
              listingId: conversation.listingId,
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
    final entries =
        outgoingTiles
            ? _inboxEntriesWithDayHeaders(conversations)
            : _incomingEntriesWithDaySections(conversations);
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
                ? const EdgeInsets.only(top: 12, bottom: 10)
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
            ),
          _InboxConversationRow(:final conversation) =>
            outgoingTiles
                ? OutgoingConversationTile(
                    conversation: conversation,
                    currentUserId: _currentUserId,
                    showActivityTimeOnly: true,
                    onTap: () {
                      _openChatScreen(conversation);
                    },
                  )
                : ConversationTile(
                    conversation: conversation,
                    currentUserId: _currentUserId,
                    isGrouped: false,
                    showActivityTimeOnly: true,
                    onTap: () {
                      _openChatScreen(conversation);
                    },
                  ),
        };
      },
    );
  }

  Widget _buildEmptyStateForType(String type) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final textColor = themeState.textColor;
        final secondaryTextColor = themeState.secondaryTextColor;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ThemeIcon(
                type == "incoming" ? Icons.inbox_outlined : Icons.mail_outline,
                size: 64,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                type == "incoming"
                    ? L10n.get("no_incoming_conversations")
                    : L10n.get("no_outgoing_conversations"),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              if (type == "incoming") ...[
                const SizedBox(height: 8),
                Text(
                  L10n.get("no_incoming_conversations_description"),
                  style: TextStyle(fontSize: 16, color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final textColor = themeState.textColor;
        final secondaryTextColor = themeState.secondaryTextColor;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ThemeIcon(
                Icons.chat_bubble_outline,
                size: 64,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                L10n.get("no_messages"),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L10n.get("no_messages_description"),
                style: TextStyle(fontSize: 16, color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
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
    final unreadColor = ThemeState().unreadIndicatorColor;
    final unreadTextColor = ThemeState().unreadIndicatorTextColor;
    final labelParts = label.split("\n");
    final isTwoLine = labelParts.length == 2;
    const twoLineFontSize = 13.0;
    const twoLineHeight = 1.15;
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
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Keep the icon+text centered regardless of badge visibility.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ThemeIcon(Icons.mail, size: 18, color: targetColor),
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
                  if (badgeCount > 0)
                    PositionedDirectional(
                      // Put the badge near the left side, without affecting centering.
                      start: -34,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          scale: isSelected ? 1.0 : 0.96,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.lerp(unreadColor, Colors.white, 0.32) ??
                                      unreadColor,
                                  Color.lerp(unreadColor, Colors.black, 0.22) ??
                                      unreadColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.24),
                                  blurRadius: 6,
                                  offset: const Offset(-2, -2),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 6,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "$badgeCount",
                                style: TextStyle(
                                  color: unreadTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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
