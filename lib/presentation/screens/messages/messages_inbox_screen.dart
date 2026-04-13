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
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
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

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "messages_inbox");
    _initializeUser();
    _loadConversations();
    WidgetsBinding.instance.addObserver(this);

    // Listen for authentication state changes to refresh conversations when user logs in
    AuthenticationState().addListener(_onAuthenticationStateChanged);
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

  Future<void> _onInboxPullRefresh() async {
    _loadConversations();
  }

  /// Show cached conversations if available, otherwise loading - prevents blink during refresh
  Widget _showCachedOrLoading() {
    if (_lastDisplayedConversations != null &&
        _lastDisplayedConversations!.isNotEmpty) {
      return _buildTabbedConversationsList(_lastDisplayedConversations!);
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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final backgroundColor = themeState.backgroundColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          body:
              widget.showCustomHeader
                  ? SafeArea(
                    child: Column(
                      children: [
                        // Custom Header
                        _buildCustomHeader(),
                        // Content
                        Expanded(child: _buildContent()),
                      ],
                    ),
                  )
                  : _buildContent(),
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
              logger.d(
                "🔍 [MessagesInboxScreen] Conversations loaded: ${conversations.length} conversations",
              );

              // Cache for smooth refresh (no blink when returning to screen)
              if (mounted) {
                setState(() {
                  _lastDisplayedConversations =
                      List<ConversationSummary>.from(
                        conversations.cast<ConversationSummary>(),
                      );
                });
              }

              // Calculate total unread count and update global state
              final totalUnreadCount = _calculateTotalUnreadCount(
                conversations.cast<ConversationSummary>(),
              );
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
                return _buildTabbedConversationsList(
                  conversations.cast<ConversationSummary>(),
                );
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

  Widget _buildCustomHeader() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        height: standardAppBarToolbarHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ThreeDAppBarIconButton.backLeading(context),
            // Title
            Expanded(
              child: Text(
                L10n.get("messages"),
                style:
                    Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ) ??
                    TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            // Profile button (matching the original design)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () => context.pushProfile(),
                icon: ThemeIcon(
                  Icons.person,
                  color:
                      Theme.of(context).appBarTheme.foregroundColor ??
                      Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
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
                  ElevatedButton(
                    onPressed: _loadConversations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                    ),
                    child: Text(
                      L10n.get("retry"),
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

    return Column(
      children: [
        // Tab buttons
        _buildTabButtons(incomingConversations, outgoingConversations),
        // Tab content
        Expanded(
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
      ],
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

        return Container(
          padding: const EdgeInsets.all(16),
          child: _buildToggleSwitch(
            context,
            incomingCount: _getUnreadCount(incoming),
            outgoingCount: _getUnreadCount(outgoing),
            primaryColor: primaryColor,
            cardColor: cardColor,
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
    final selectedTextColor = themeState.selectedTabTextColor;
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThemeIcon(
                          Icons.mail,
                          size: 18,
                          color:
                              _selectedTabIndex == 0
                                  ? selectedTextColor
                                  : unselectedTextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          L10n.get("incoming"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                _selectedTabIndex == 0
                                    ? selectedTextColor
                                    : unselectedTextColor,
                          ),
                        ),
                        if (incomingCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "$incomingCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThemeIcon(
                          Icons.mail,
                          size: 18,
                          color:
                              _selectedTabIndex == 1
                                  ? selectedTextColor
                                  : unselectedTextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          L10n.get("outgoing"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color:
                                _selectedTabIndex == 1
                                    ? selectedTextColor
                                    : unselectedTextColor,
                          ),
                        ),
                        if (outgoingCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "$outgoingCount",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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

    // For outgoing messages, show individual conversations without grouping
    if (type == "outgoing") {
      return _buildIndividualConversationsList(conversations);
    }

    // For incoming messages, use grouped view
    return GroupedConversationsList(
      conversations: conversations,
      currentUserId: _currentUserId,
      onConversationTap: (conversation) async {
        HapticFeedbackUtils.impact();
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
        // didPopNext handles refresh when returning from chat screen
      },
    );
  }

  Widget _buildIndividualConversationsList(
    List<ConversationSummary> conversations,
  ) {
    // Sort conversations: unread messages first, then by last message time (most recent first)
    final sortedConversations = List<ConversationSummary>.from(
      conversations,
    )..sort((a, b) {
      // Check if conversations have unread messages
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

      // If one has unread and the other doesn't, prioritize the one with unread
      if (aHasUnread && !bHasUnread) return -1;
      if (!aHasUnread && bHasUnread) return 1;

      // If both have same unread status, sort by last message time (most recent first)
      final aTime = a.lastMessageAt ?? a.updatedAt;
      final bTime = b.lastMessageAt ?? b.updatedAt;
      return bTime.compareTo(aTime);
    });

    return CommonListView(
      padding: const EdgeInsets.all(16),
      itemCount: sortedConversations.length,
      itemBuilder: (context, index) {
        final conversation = sortedConversations[index];
        return OutgoingConversationTile(
          conversation: conversation,
          currentUserId: _currentUserId,
          onTap: () async {
            HapticFeedbackUtils.impact();
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
            // didPopNext handles refresh when returning from chat screen
          },
        );
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
                type == "incoming" ? Icons.inbox_outlined : Icons.send_outlined,
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
