import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/profile/profile_screen.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/string_helper.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/unread_messages_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";

class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({super.key, this.showCustomHeader = true});

  final bool showCustomHeader;

  @override
  State<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends State<MessagesInboxScreen>
    with WidgetsBindingObserver {
  late MessagingBloc _messagingBloc;
  bool _hasLoadedOnce = false;
  int? _currentUserId;
  int _selectedTabIndex = 0; // 0 = incoming, 1 = outgoing

  @override
  void initState() {
    super.initState();
    _messagingBloc = MessagingBloc(getIt<IMessagingService>());
    _initializeUser();
    _loadConversations();
    WidgetsBinding.instance.addObserver(this);

    // Listen for authentication state changes to refresh conversations when user logs in
    AuthenticationState().addListener(_onAuthenticationStateChanged);
  }

  Future<void> _initializeUser() async {
    _currentUserId = await SessionManager.getUserId();
    logger.d('🔍 [MessagesInboxScreen] Current user ID: $_currentUserId');
    // Refresh conversations after getting user ID to update unread indicators
    if (mounted) {
      setState(() {});
    }
  }

  // Handle authentication state changes
  void _onAuthenticationStateChanged() {
    logger.d(
      '🔍 [MessagesInboxScreen] Authentication state changed, refreshing conversations...',
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
          '🔍 [MessagesInboxScreen] User logged out, clearing conversations...',
        );
        _messagingBloc.add(ClearConversations());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthenticationState().removeListener(_onAuthenticationStateChanged);
    _messagingBloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh conversations when app becomes active again
      _loadConversations();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh conversations when screen becomes visible (but only after initial load)
    if (_hasLoadedOnce) {
      _loadConversations();
    }
    _hasLoadedOnce = true;
  }

  void _loadConversations() {
    logger.d('🔍 [MessagesInboxScreen] Loading conversations...');
    _messagingBloc.add(RefreshConversations());
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
        final backgroundColor = _getThemeAwareBackgroundColor(themeState);

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
    return BlocProvider.value(
      value: _messagingBloc,
      child: BlocListener<MessagingBloc, MessagingState>(
        listener: (context, state) {
          // Handle unread count updates outside of build method
          state.when(
            initial: () {},
            loading: () {},
            conversationsLoaded: (conversations, hasMore, currentPage) {
              logger.d(
                '🔍 [MessagesInboxScreen] Conversations loaded: ${conversations.length} conversations',
              );

              // Calculate total unread count and update global state
              final totalUnreadCount = _calculateTotalUnreadCount(
                conversations.cast<ConversationSummary>(),
              );
              UnreadMessagesState().updateUnreadCount(totalUnreadCount);
            },
            conversationsCleared: () {
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
              initial: () => _buildLoadingState(),
              loading: () => _buildLoadingState(),
              conversationsLoaded: (conversations, hasMore, currentPage) {
                return _buildTabbedConversationsList(
                  conversations.cast<ConversationSummary>(),
                );
              },
              conversationsCleared: () => _buildEmptyState(),
              messagesLoaded:
                  (messages, hasMore, currentPage, conversationId) =>
                      _buildLoadingState(),
              conversationCreated: (conversation) => _buildLoadingState(),
              messageSent: (message) => _buildLoadingState(),
              messagesMarkedAsRead:
                  (conversationId, markedCount) => _buildLoadingState(),
              error: (message) => _buildErrorState(message),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () {
              HapticFeedbackUtils.impact();
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color:
                  Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
            ),
          ),
          // Title
          Expanded(
            child: Text(
              LanguageAwareStringHelper.getCurrent(context, "messages"),
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
          IconButton(
            onPressed: () {
              // Navigate to profile or show profile menu
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: Icon(
              Icons.person,
              color:
                  Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// Get theme-aware background color
  Color _getThemeAwareBackgroundColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White background for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.background; // Blue background for blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware text color
  Color _getThemeAwareTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.textPrimary; // White text for blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware primary color
  Color _getThemeAwarePrimaryColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black primary for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.primary; // Blue primary for blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware secondary text color
  Color _getThemeAwareSecondaryTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[600]!; // Grey text for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.textSecondary; // Light blue text for blue theme
    }
    return Colors.grey[600]!; // Default to grey
  }

  /// Get theme-aware button color
  Color _getThemeAwareButtonColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black button for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.buttonPrimary; // Blue button for blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware button text color
  Color _getThemeAwareButtonTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White text on black button for light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White text on blue button for blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware card background color
  Color _getThemeAwareCardColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.card; // Blue cards for blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware border color for selected tab buttons
  Color _getSelectedTabBorderColor() {
    final themeState = ThemeState();
    if (themeState.isLightTheme) {
      return Colors
          .black; // Black border for light theme (same as background for solid look)
    } else if (themeState.isBlueTheme) {
      return Colors
          .white; // White border for blue theme (contrast against blue background)
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware text color for selected tab buttons
  Color _getSelectedTabTextColor() {
    final themeState = ThemeState();
    if (themeState.isLightTheme) {
      return Colors.white; // White text on black background for light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White text on blue background for blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware text color for unselected tab buttons
  Color _getUnselectedTabTextColor() {
    final themeState = ThemeState();
    if (themeState.isLightTheme) {
      return Colors.black; // Black text on white background for light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White text on dark blue background for blue theme
    }
    return Colors.black; // Default to black
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
        final primaryColor = _getThemeAwarePrimaryColor(themeState);
        final secondaryTextColor = _getThemeAwareSecondaryTextColor(themeState);
        final buttonColor = _getThemeAwareButtonColor(themeState);
        final buttonTextColor = _getThemeAwareButtonTextColor(themeState);

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
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
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const AuthWizardScreen(),
                        ),
                      );
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
                      LanguageAwareStringHelper.getCurrent(context, "retry"),
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
          child: RefreshIndicator(
            onRefresh: () async {
              _loadConversations();
            },
            child:
                _selectedTabIndex == 0
                    ? _buildConversationsList(incomingConversations, "incoming")
                    : _buildConversationsList(
                      outgoingConversations,
                      "outgoing",
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
        final primaryColor = _getThemeAwarePrimaryColor(themeState);
        final textColor = _getThemeAwareTextColor(themeState);
        final secondaryTextColor = _getThemeAwareSecondaryTextColor(themeState);
        final cardColor = _getThemeAwareCardColor(themeState);

        return Container(
          padding: const EdgeInsets.all(16),
          child: _buildToggleSwitch(
            incomingCount: _getUnreadCount(incoming),
            outgoingCount: _getUnreadCount(outgoing),
            primaryColor: primaryColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            cardColor: cardColor,
          ),
        );
      },
    );
  }

  Widget _buildToggleSwitch({
    required int incomingCount,
    required int outgoingCount,
    required Color primaryColor,
    required Color textColor,
    required Color secondaryTextColor,
    required Color cardColor,
  }) {
    final selectedBorderColor = _getSelectedTabBorderColor();
    final selectedTextColor = _getSelectedTabTextColor();
    final unselectedTextColor = _getUnselectedTabTextColor();

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: secondaryTextColor.withValues(alpha: 0.3),
          width: 1,
        ),
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
                  2, // Account for padding and borders
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: selectedBorderColor, width: 1),
              ),
            ),
          ),
          // Toggle buttons
          Row(
            children: [
              // Incoming button
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = 0),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mail,
                          size: 18,
                          color:
                              _selectedTabIndex == 0
                                  ? selectedTextColor
                                  : unselectedTextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LanguageAwareStringHelper.getCurrent(
                            context,
                            "incoming",
                          ),
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
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$incomingCount',
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
                  onTap: () => setState(() => _selectedTabIndex = 1),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mail,
                          size: 18,
                          color:
                              _selectedTabIndex == 1
                                  ? selectedTextColor
                                  : unselectedTextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          LanguageAwareStringHelper.getCurrent(
                            context,
                            "outgoing",
                          ),
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
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$outgoingCount',
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
                  otherUserInitials: StringHelper.extractInitials(
                    conversation.otherUserName,
                  ),
                ),
          ),
        );
        // Refresh conversations when returning from chat screen
        // Add a small delay to ensure server has processed mark as read
        await Future.delayed(const Duration(milliseconds: 500));
        _loadConversations();
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

    return ListView.builder(
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
                      otherUserInitials: StringHelper.extractInitials(
                        conversation.otherUserName,
                      ),
                    ),
              ),
            );
            // Refresh conversations when returning from chat screen
            // Add a small delay to ensure server has processed mark as read
            await Future.delayed(const Duration(milliseconds: 500));
            _loadConversations();
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
        final textColor = _getThemeAwareTextColor(themeState);
        final secondaryTextColor = _getThemeAwareSecondaryTextColor(themeState);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == "incoming" ? Icons.inbox_outlined : Icons.send_outlined,
                size: 64,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                type == "incoming"
                    ? LanguageAwareStringHelper.getCurrent(
                      context,
                      "no_incoming_conversations",
                    )
                    : LanguageAwareStringHelper.getCurrent(
                      context,
                      "no_outgoing_conversations",
                    ),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                type == "incoming"
                    ? LanguageAwareStringHelper.getCurrent(
                      context,
                      "no_incoming_conversations_description",
                    )
                    : LanguageAwareStringHelper.getCurrent(
                      context,
                      "no_outgoing_conversations_description",
                    ),
                style: TextStyle(fontSize: 16, color: secondaryTextColor),
                textAlign: TextAlign.center,
              ),
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
        final textColor = _getThemeAwareTextColor(themeState);
        final secondaryTextColor = _getThemeAwareSecondaryTextColor(themeState);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                LanguageAwareStringHelper.getCurrent(context, "no_messages"),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                LanguageAwareStringHelper.getCurrent(
                  context,
                  "no_messages_description",
                ),
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

class ConversationTile extends StatelessWidget {
  final ConversationSummary conversation;
  final VoidCallback onTap;
  final int? currentUserId;
  final bool isGrouped;

  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.currentUserId,
    this.isGrouped = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final cardColor = _getThemeAwareCardColor(themeState);
        final textColor = _getThemeAwareCardTextColor(themeState);
        final secondaryTextColor = _getThemeAwareCardSecondaryTextColor(
          themeState,
        );
        final iconColor = _getThemeAwareCardIconColor(themeState);
        final avatarColor = _getThemeAwareAvatarColor(themeState);
        final avatarIconColor = _getThemeAwareAvatarIconColor(themeState);

        return Card(
          margin:
              isGrouped ? EdgeInsets.zero : const EdgeInsets.only(bottom: 16),
          color: cardColor,
          elevation: isGrouped ? 0 : null,
          child: ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: _buildAvatarContent(conversation, avatarIconColor),
            ),
            title:
                isGrouped
                    ? null // Hide title entirely for grouped conversations to remove empty space
                    : Text(
                      conversation.listingTitle ??
                          "Listing #${conversation.listingId}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (conversation.lastMessageContent != null) ...[
                  Text(
                    conversation.lastMessageContent!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  const SizedBox(height: 4),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(
                        context,
                        conversation.lastMessageAt ?? conversation.updatedAt,
                      ),
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Unread indicator - only show if there are unread messages AND current user is the addressee (not the sender)
                if (conversation.unreadCount != null &&
                    conversation.unreadCount! > 0 &&
                    currentUserId != null &&
                    conversation.lastMessageSenderId != currentUserId) ...[
                  Container(
                    width: conversation.unreadCount! > 1 ? 20 : 12,
                    height: conversation.unreadCount! > 1 ? 20 : 12,
                    decoration: BoxDecoration(
                      color:
                          AppColors.success, // Keep green for unread indicator
                      shape: BoxShape.circle,
                    ),
                    child:
                        conversation.unreadCount! > 1
                            ? Center(
                              child: Text(
                                '${conversation.unreadCount!}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 8),
                ],
                // Arrow icon
                if (conversation.lastMessageAt != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: iconColor.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Get theme-aware card background color
  Color _getThemeAwareCardColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.card; // Blue cards for blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware card text color
  Color _getThemeAwareCardTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .textPrimary; // White text on blue cards for blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware card secondary text color
  Color _getThemeAwareCardSecondaryTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[600]!; // Grey text on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .textSecondary; // Light blue text on blue cards for blue theme
    }
    return Colors.grey[600]!; // Default to grey
  }

  /// Get theme-aware card icon color
  Color _getThemeAwareCardIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[600]!; // Grey icons on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .iconPrimary; // White icons on blue cards for blue theme
    }
    return Colors.grey[600]!; // Default to grey
  }

  /// Get theme-aware avatar background color
  Color _getThemeAwareAvatarColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[300]!; // Light grey avatar for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.primary; // Blue avatar for blue theme
    }
    return Colors.grey[300]!; // Default to light grey
  }

  /// Get theme-aware avatar icon color
  Color _getThemeAwareAvatarIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black icon on light grey avatar for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .textPrimary; // White icon on blue avatar for blue theme
    }
    return Colors.black; // Default to black
  }

  String _formatTime(BuildContext context, String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return AppDateUtils.formatDateWithMonth(context, dateTime);
      } else if (difference.inHours > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inMinutes > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return LanguageAwareStringHelper.getCurrent(context, "now");
      }
    } catch (e) {
      return '';
    }
  }

  /// Build avatar content - first letter(s) of name or person icon
  Widget _buildAvatarContent(
    ConversationSummary conversation,
    Color iconColor,
  ) {
    final userName = conversation.otherUserName;
    final initials = StringHelper.extractInitials(userName);

    // If we have initials, show them
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    // Fallback to person icon
    return Icon(Icons.person, color: iconColor);
  }
}

class GroupedConversationsList extends StatefulWidget {
  final List<ConversationSummary> conversations;
  final int? currentUserId;
  final Function(ConversationSummary) onConversationTap;

  const GroupedConversationsList({
    super.key,
    required this.conversations,
    this.currentUserId,
    required this.onConversationTap,
  });

  @override
  State<GroupedConversationsList> createState() =>
      _GroupedConversationsListState();
}

class _GroupedConversationsListState extends State<GroupedConversationsList> {
  final Map<int, bool> _expandedGroups = {};

  @override
  Widget build(BuildContext context) {
    // Group conversations by listing ID
    final Map<int, List<ConversationSummary>> groupedConversations = {};
    for (final conversation in widget.conversations) {
      if (!groupedConversations.containsKey(conversation.listingId)) {
        groupedConversations[conversation.listingId] = [];
      }
      groupedConversations[conversation.listingId]!.add(conversation);
    }

    // Sort conversations within each group: unread messages first, then by last message time
    groupedConversations.forEach((listingId, conversations) {
      conversations.sort((a, b) {
        // Check if conversations have unread messages
        final aHasUnread =
            a.unreadCount != null &&
            a.unreadCount! > 0 &&
            widget.currentUserId != null &&
            a.lastMessageSenderId != widget.currentUserId;
        final bHasUnread =
            b.unreadCount != null &&
            b.unreadCount! > 0 &&
            widget.currentUserId != null &&
            b.lastMessageSenderId != widget.currentUserId;

        // If one has unread and the other doesn't, prioritize the one with unread
        if (aHasUnread && !bHasUnread) return -1;
        if (!aHasUnread && bHasUnread) return 1;

        // If both have same unread status, sort by last message time (most recent first)
        final aTime = a.lastMessageAt ?? a.updatedAt;
        final bTime = b.lastMessageAt ?? b.updatedAt;
        return bTime.compareTo(aTime);
      });
    });

    // Get sorted listing IDs: groups with unread messages first, then by most recent conversation
    final sortedListingIds =
        groupedConversations.keys.toList()..sort((a, b) {
          final aConversations = groupedConversations[a]!;
          final bConversations = groupedConversations[b]!;

          // Check if groups have any unread messages
          final aHasUnread = aConversations.any(
            (conv) =>
                conv.unreadCount != null &&
                conv.unreadCount! > 0 &&
                widget.currentUserId != null &&
                conv.lastMessageSenderId != widget.currentUserId,
          );
          final bHasUnread = bConversations.any(
            (conv) =>
                conv.unreadCount != null &&
                conv.unreadCount! > 0 &&
                widget.currentUserId != null &&
                conv.lastMessageSenderId != widget.currentUserId,
          );

          // If one group has unread and the other doesn't, prioritize the one with unread
          if (aHasUnread && !bHasUnread) return -1;
          if (!aHasUnread && bHasUnread) return 1;

          // If both groups have same unread status, sort by most recent conversation
          final aLatest =
              aConversations.first.lastMessageAt ??
              aConversations.first.updatedAt;
          final bLatest =
              bConversations.first.lastMessageAt ??
              bConversations.first.updatedAt;
          return bLatest.compareTo(aLatest);
        });

    // Auto-expand the first group with unread messages
    if (sortedListingIds.isNotEmpty) {
      final firstGroupId = sortedListingIds.first;
      final firstGroupConversations = groupedConversations[firstGroupId]!;
      final hasUnreadInFirstGroup = firstGroupConversations.any(
        (conv) =>
            conv.unreadCount != null &&
            conv.unreadCount! > 0 &&
            widget.currentUserId != null &&
            conv.lastMessageSenderId != widget.currentUserId,
      );

      if (hasUnreadInFirstGroup && !_expandedGroups.containsKey(firstGroupId)) {
        _expandedGroups[firstGroupId] = true;
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedListingIds.length,
      itemBuilder: (context, index) {
        final listingId = sortedListingIds[index];
        final conversations = groupedConversations[listingId]!;
        final isExpanded =
            _expandedGroups[listingId] ?? false; // Default to collapsed
        final listingTitle =
            conversations.first.listingTitle ?? "Listing #$listingId";

        return _buildGroupCard(
          listingId: listingId,
          listingTitle: listingTitle,
          conversations: conversations,
          isExpanded: isExpanded,
        );
      },
    );
  }

  Widget _buildGroupCard({
    required int listingId,
    required String listingTitle,
    required List<ConversationSummary> conversations,
    required bool isExpanded,
  }) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final cardColor = _getThemeAwareCardColor(themeState);
        final textColor = _getThemeAwareCardTextColor(themeState);
        final secondaryTextColor = _getThemeAwareCardSecondaryTextColor(
          themeState,
        );
        final iconColor = _getThemeAwareCardIconColor(themeState);

        // Get location and metro station info from the first conversation
        final firstConversation = conversations.first;
        final hasLocation =
            firstConversation.locationNameUz != null ||
            firstConversation.locationNameRu != null ||
            firstConversation.locationNameEn != null;
        final hasSubwayStation =
            firstConversation.subwayStationNameUz != null ||
            firstConversation.subwayStationNameRu != null ||
            firstConversation.subwayStationNameEn != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: cardColor,
          child: Column(
            children: [
              // Group header
              ListTile(
                onTap: () {
                  HapticFeedbackUtils.impact();
                  setState(() {
                    _expandedGroups[listingId] = !isExpanded;
                  });
                },
                title: Text(
                  listingTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${conversations.length} ${conversations.length == 1 ? LanguageAwareStringHelper.getCurrent(context, "conversation_count") : LanguageAwareStringHelper.getCurrent(context, "conversations_count")}',
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                    // Location and Metro Station Information
                    if (hasLocation || hasSubwayStation) ...[
                      const SizedBox(height: 8),
                      _buildLocationAndMetroInfoForGroup(
                        firstConversation,
                        secondaryTextColor,
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Unread count indicator for the group
                    if (_getGroupUnreadCount(conversations) > 0) ...[
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${_getGroupUnreadCount(conversations)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    AnimatedRotation(
                      turns: isExpanded ? 0.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Icon(Icons.expand_less, color: iconColor),
                    ),
                  ],
                ),
              ),
              // Group content with animation
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child:
                    isExpanded
                        ? Column(
                          children: [
                            const Divider(height: 1),
                            ...conversations.map(
                              (conversation) => ConversationTile(
                                conversation: conversation,
                                currentUserId: widget.currentUserId,
                                onTap:
                                    () =>
                                        widget.onConversationTap(conversation),
                                isGrouped:
                                    true, // Add this parameter to style differently
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getGroupUnreadCount(List<ConversationSummary> conversations) {
    return conversations.fold(0, (sum, conversation) {
      if (conversation.unreadCount != null &&
          conversation.unreadCount! > 0 &&
          widget.currentUserId != null &&
          conversation.lastMessageSenderId != widget.currentUserId) {
        return sum + conversation.unreadCount!;
      }
      return sum;
    });
  }

  /// Get theme-aware card background color
  Color _getThemeAwareCardColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.card; // Blue cards for blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware card text color
  Color _getThemeAwareCardTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .textPrimary; // White text on blue cards for blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware card secondary text color
  Color _getThemeAwareCardSecondaryTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[600]!; // Grey text on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .textSecondary; // Light blue text on blue cards for blue theme
    }
    return Colors.grey[600]!; // Default to grey
  }

  /// Get theme-aware card icon color
  Color _getThemeAwareCardIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[600]!; // Grey icons on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .iconPrimary; // White icons on blue cards for blue theme
    }
    return Colors.grey[600]!; // Default to grey
  }

  /// Build location and metro station information display
  Widget _buildLocationAndMetroInfo(
    ConversationSummary conversation,
    Color textColor,
  ) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        final hasLocation =
            conversation.locationNameUz != null ||
            conversation.locationNameRu != null ||
            conversation.locationNameEn != null;
        final hasSubwayStation =
            conversation.subwayStationNameUz != null ||
            conversation.subwayStationNameRu != null ||
            conversation.subwayStationNameEn != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location (District)
            if (hasLocation) ...[
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getLocalizedName(
                        nameUz: conversation.locationNameUz,
                        nameRu: conversation.locationNameRu,
                        nameEn: conversation.locationNameEn,
                      ),
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ),
                ],
              ),
            ],
            // Subway Station (below district)
            if (hasSubwayStation) ...[
              const SizedBox(height: 4),
              _buildSubwayStationDisplay(conversation, textColor),
            ],
            // Price range display
            if (conversation.listingMinPrice != null ||
                conversation.listingMaxPrice != null) ...[
              const SizedBox(height: 4),
              _buildPriceDisplay(conversation, textColor),
            ],
          ],
        );
      },
    );
  }

  /// Build subway station display with transfer station support
  Widget _buildSubwayStationDisplay(
    ConversationSummary conversation,
    Color textColor,
  ) {
    return Row(
      children: [
        Icon(
          Icons.train,
          color: _getLineColor(conversation.subwayStationLine ?? 1),
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _getLocalizedName(
              nameUz: conversation.subwayStationNameUz,
              nameRu: conversation.subwayStationNameRu,
              nameEn: conversation.subwayStationNameEn,
            ),
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ),
      ],
    );
  }

  /// Get the appropriate name based on current language
  String _getLocalizedName({String? nameUz, String? nameRu, String? nameEn}) {
    final currentLanguage = LanguageState().currentLanguage;

    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
    }
  }

  /// Build price display
  Widget _buildPriceDisplay(ConversationSummary conversation, Color textColor) {
    return Row(
      children: [
        Icon(Icons.attach_money, color: Colors.green, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _formatPriceRange(conversation),
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Format price range for display
  String _formatPriceRange(ConversationSummary conversation) {
    final minPrice = conversation.listingMinPrice;
    final maxPrice = conversation.listingMaxPrice;

    if (minPrice != null && maxPrice != null) {
      if (minPrice == maxPrice) {
        return minPrice.toString();
      } else {
        return "$minPrice - $maxPrice";
      }
    } else if (minPrice != null) {
      return "от $minPrice";
    } else if (maxPrice != null) {
      return "до $maxPrice";
    } else {
      return "";
    }
  }

  /// Get metro line color
  Color _getLineColor(int line) {
    switch (line) {
      case 1:
        return AppColors.metroLine1;
      case 2:
        return AppColors.metroLine2;
      case 3:
        return AppColors.metroLine3;
      case 4:
        return AppColors.metroLine4;
      default:
        return AppColors.metroLine1;
    }
  }

  /// Build location and metro station information display for grouped conversations (without price)
  Widget _buildLocationAndMetroInfoForGroup(
    ConversationSummary conversation,
    Color textColor,
  ) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        final hasLocation =
            conversation.locationNameUz != null ||
            conversation.locationNameRu != null ||
            conversation.locationNameEn != null;
        final hasSubwayStation =
            conversation.subwayStationNameUz != null ||
            conversation.subwayStationNameRu != null ||
            conversation.subwayStationNameEn != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location (District)
            if (hasLocation) ...[
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getLocalizedName(
                        nameUz: conversation.locationNameUz,
                        nameRu: conversation.locationNameRu,
                        nameEn: conversation.locationNameEn,
                      ),
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ),
                ],
              ),
            ],
            // Subway Station (below district)
            if (hasSubwayStation) ...[
              const SizedBox(height: 4),
              _buildSubwayStationDisplay(conversation, textColor),
            ],
          ],
        );
      },
    );
  }
}

class OutgoingConversationTile extends StatelessWidget {
  final ConversationSummary conversation;
  final VoidCallback onTap;
  final int? currentUserId;

  const OutgoingConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    this.currentUserId,
  });

  /// Build avatar content - first letter(s) of name or person icon
  Widget _buildAvatarContent(
    ConversationSummary conversation,
    Color iconColor,
  ) {
    final userName = conversation.otherUserName;
    final initials = StringHelper.extractInitials(userName);

    // If we have initials, show them
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    // Fallback to person icon
    return Icon(Icons.person, color: iconColor);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final cardColor = _getThemeAwareCardColor(themeState);
        final textColor = _getThemeAwareCardTextColor(themeState);
        final secondaryTextColor = _getThemeAwareCardSecondaryTextColor(
          themeState,
        );
        final iconColor = _getThemeAwareCardIconColor(themeState);
        final avatarColor = _getThemeAwareAvatarColor(themeState);
        final avatarIconColor = _getThemeAwareAvatarIconColor(themeState);

        // Check if we have location or metro station data
        final hasLocation =
            conversation.locationNameUz != null ||
            conversation.locationNameRu != null ||
            conversation.locationNameEn != null;
        final hasSubwayStation =
            conversation.subwayStationNameUz != null ||
            conversation.subwayStationNameRu != null ||
            conversation.subwayStationNameEn != null;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: cardColor,
          child: ListTile(
            onTap: onTap,
            leading: CircleAvatar(
              backgroundColor: avatarColor,
              child: _buildAvatarContent(conversation, avatarIconColor),
            ),
            title: Text(
              conversation.listingTitle ?? "Listing #${conversation.listingId}",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location and Metro Station Information
                if (hasLocation || hasSubwayStation) ...[
                  _buildLocationAndMetroInfo(conversation, secondaryTextColor),
                  const SizedBox(height: 8),
                ],
                // Last message content
                if (conversation.lastMessageContent != null) ...[
                  Text(
                    conversation.lastMessageContent!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  const SizedBox(height: 4),
                ],
                // Time and user info
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(
                        context,
                        conversation.lastMessageAt ?? conversation.updatedAt,
                      ),
                      style: TextStyle(fontSize: 12, color: secondaryTextColor),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Unread indicator - only show if there are unread messages AND current user is the addressee (not the sender)
                if (conversation.unreadCount != null &&
                    conversation.unreadCount! > 0 &&
                    currentUserId != null &&
                    conversation.lastMessageSenderId != currentUserId) ...[
                  Container(
                    width: conversation.unreadCount! > 1 ? 20 : 12,
                    height: conversation.unreadCount! > 1 ? 20 : 12,
                    decoration: BoxDecoration(
                      color:
                          AppColors.success, // Keep green for unread indicator
                      shape: BoxShape.circle,
                    ),
                    child:
                        conversation.unreadCount! > 1
                            ? Center(
                              child: Text(
                                '${conversation.unreadCount!}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : null,
                  ),
                  const SizedBox(width: 8),
                ],
                // Arrow icon
                if (conversation.lastMessageAt != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: iconColor.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build location and metro station information display
  Widget _buildLocationAndMetroInfo(
    ConversationSummary conversation,
    Color textColor,
  ) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        final hasLocation =
            conversation.locationNameUz != null ||
            conversation.locationNameRu != null ||
            conversation.locationNameEn != null;
        final hasSubwayStation =
            conversation.subwayStationNameUz != null ||
            conversation.subwayStationNameRu != null ||
            conversation.subwayStationNameEn != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location (District)
            if (hasLocation) ...[
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getLocalizedName(
                        nameUz: conversation.locationNameUz,
                        nameRu: conversation.locationNameRu,
                        nameEn: conversation.locationNameEn,
                      ),
                      style: TextStyle(fontSize: 12, color: textColor),
                    ),
                  ),
                ],
              ),
            ],
            // Subway Station (below district)
            if (hasSubwayStation) ...[
              const SizedBox(height: 4),
              _buildSubwayStationDisplay(conversation, textColor),
            ],
            // Price range display
            if (conversation.listingMinPrice != null ||
                conversation.listingMaxPrice != null) ...[
              const SizedBox(height: 4),
              _buildPriceDisplay(conversation, textColor),
            ],
          ],
        );
      },
    );
  }

  /// Build subway station display with transfer station support
  Widget _buildSubwayStationDisplay(
    ConversationSummary conversation,
    Color textColor,
  ) {
    return Row(
      children: [
        Icon(
          Icons.train,
          color: _getLineColor(conversation.subwayStationLine ?? 1),
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _getLocalizedName(
              nameUz: conversation.subwayStationNameUz,
              nameRu: conversation.subwayStationNameRu,
              nameEn: conversation.subwayStationNameEn,
            ),
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ),
      ],
    );
  }

  /// Get the appropriate name based on current language
  String _getLocalizedName({String? nameUz, String? nameRu, String? nameEn}) {
    final currentLanguage = LanguageState().currentLanguage;

    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
    }
  }

  /// Build price display
  Widget _buildPriceDisplay(ConversationSummary conversation, Color textColor) {
    return Row(
      children: [
        Icon(Icons.attach_money, color: Colors.green, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _formatPriceRange(conversation),
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Format price range for display
  String _formatPriceRange(ConversationSummary conversation) {
    final minPrice = conversation.listingMinPrice;
    final maxPrice = conversation.listingMaxPrice;

    if (minPrice != null && maxPrice != null) {
      if (minPrice == maxPrice) {
        return minPrice.toString();
      } else {
        return "$minPrice - $maxPrice";
      }
    } else if (minPrice != null) {
      return "от $minPrice";
    } else if (maxPrice != null) {
      return "до $maxPrice";
    } else {
      return "";
    }
  }

  /// Get metro line color
  Color _getLineColor(int line) {
    switch (line) {
      case 1:
        return AppColors.metroLine1;
      case 2:
        return AppColors.metroLine2;
      case 3:
        return AppColors.metroLine3;
      case 4:
        return AppColors.metroLine4;
      default:
        return AppColors.metroLine1;
    }
  }

  /// Get theme-aware card background color
  Color _getThemeAwareCardColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.card; // Blue cards for blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware card text color
  Color _getThemeAwareCardTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .textPrimary; // White text on blue cards for blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware card secondary text color
  Color _getThemeAwareCardSecondaryTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[600]!; // Grey text on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .textSecondary; // Light blue text on blue cards for blue theme
    }
    return Colors.grey[600]!; // Default to grey
  }

  /// Get theme-aware card icon color
  Color _getThemeAwareCardIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[600]!; // Grey icons on white cards for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .iconPrimary; // White icons on blue cards for blue theme
    }
    return Colors.grey[600]!; // Default to grey
  }

  /// Get theme-aware avatar background color
  Color _getThemeAwareAvatarColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey[300]!; // Light grey avatar for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.primary; // Blue avatar for blue theme
    }
    return Colors.grey[300]!; // Default to light grey
  }

  /// Get theme-aware avatar icon color
  Color _getThemeAwareAvatarIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black icon on light grey avatar for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors
          .textPrimary; // White icon on blue avatar for blue theme
    }
    return Colors.black; // Default to black
  }

  String _formatTime(BuildContext context, String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return AppDateUtils.formatDateWithMonth(context, dateTime);
      } else if (difference.inHours > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inMinutes > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return LanguageAwareStringHelper.getCurrent(context, "now");
      }
    } catch (e) {
      return '';
    }
  }
}
