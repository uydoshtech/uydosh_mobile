import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/complaint/create_complaint_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/message_grouping_utils.dart";
import "package:uy_dosh/presentation/widgets/chat/quick_questions_widget.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class ChatScreen extends StatefulWidget {

  const ChatScreen({
    required this.conversationId, super.key,
    this.listingId,
    this.otherUserInitials,
    this.otherUserName,
    this.otherUserId,
    this.otherUserAvatar,
  }) : assert(conversationId > 0, "Conversation ID must be positive");
  final int conversationId;
  final int? listingId;
  final String? otherUserInitials;
  final String? otherUserName;
  final int? otherUserId;
  final String? otherUserAvatar;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late MessagingBloc _messagingBloc;
  late CurrentUserProfileBloc _currentUserProfileBloc;
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  int? _currentUserId;
  List<Message> _messages = [];
  bool _isSendingMessage = false;
  final Set<int> _newMessageIds = {}; // Track which messages are new in this session
  UserProfile? _currentUserProfile; // Store the current user's profile

  @override
  void initState() {
    super.initState();
    _messagingBloc = MessagingBloc(getIt<IMessagingService>());
    _currentUserProfileBloc = CurrentUserProfileBloc(
      getIt<IUserProfileService>(),
    );
    _messageController = TextEditingController();
    _scrollController = ScrollController();

    _initializeChat();
  }

  @override
  void dispose() {
    _messagingBloc.close();
    _currentUserProfileBloc.close();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      // Get current user ID
      _currentUserId = await SessionManager.getUserId();

      // Fetch current user profile
      _currentUserProfileBloc.add(const CurrentUserProfileEvent.fetchProfile());

      // Fetch messages
      _messagingBloc.add(FetchMessages(conversationId: widget.conversationId));
    } catch (e) {
      logger.d("❌ [ChatScreen] Error initializing chat: $e");
    }
  }

  String _getHeaderTitle(BuildContext context) {
    final name = widget.otherUserName?.trim();
    if (name != null && name.isNotEmpty) {
      return L10n.getWithParams(
        "chat_with",
        params: {"name": name},
        fallback: "Chat with $name",
      );
    }
    return L10n.get("chat");
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final backgroundColor = _getThemeAwareBackgroundColor(themeState);
        final appBarBackgroundColor = _getThemeAwareAppBarBackgroundColor(
          themeState,
        );
        final textColor = _getThemeAwareTextColor(themeState);

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Row(
              children: [
                // Title on the left
                Expanded(
                  child: Text(
                    _getHeaderTitle(context),
                    style: TextStyle(color: textColor),
                  ),
                ),
              ],
            ),
            backgroundColor: appBarBackgroundColor,
            foregroundColor: textColor,
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: textColor),
                tooltip: L10n.get("refresh"),
                onPressed: () {
                  _messagingBloc.add(
                    RefreshMessages(conversationId: widget.conversationId),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ActionDropdownMenu(
                  items: _buildActionMenuItems(),
                  icon: Icons.more_vert,
                  iconColor: textColor,
                  tooltip: L10n.get("actions"),
                ),
              ),
            ],
          ),
          body: GestureDetector(
            onTap: () {
              // Hide keyboard when tapping outside of text input
              FocusScope.of(context).unfocus();
            },
            child: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: _messagingBloc),
                BlocProvider.value(value: _currentUserProfileBloc),
              ],
              child: Column(
                children: [
                  Expanded(
                    child: MultiBlocListener(
                      listeners: [
                        BlocListener<MessagingBloc, MessagingState>(
                          listener: (context, state) {
                            state.when(
                              initial: () {},
                              loading: () {},
                              conversationsLoaded:
                                  (conversations, hasMore, currentPage) {},
                              conversationsCleared: () {},
                              messagesLoaded: (
                                messages,
                                hasMore,
                                currentPage,
                                conversationId,
                              ) {
                                // Store messages in widget state
                                setState(() {
                                  _messages = messages;
                                  // Don't mark any messages as new when initially loading
                                  // _newMessageIds remains empty for initial load
                                });
                                // Mark messages as read after they're loaded
                                _messagingBloc.add(
                                  MarkMessagesAsRead(
                                    conversationId: conversationId,
                                  ),
                                );
                              },
                              conversationCreated: (conversation) {},
                              messageSent: (message) {
                                // Add the new message to the local messages list
                                setState(() {
                                  _messages = [..._messages, message];
                                  // Clear all previous new message IDs and only mark the newest one
                                  _newMessageIds.clear();
                                  _newMessageIds.add(
                                    message.id,
                                  ); // Mark this message as new for animation
                                });
                                // Clear the input and scroll to bottom
                                _messageController.clear();
                                _scrollToBottom();
                                // Haptic feedback (sound plays on send button press)
                                HapticFeedbackUtils.impact();
                              },
                              messagesMarkedAsRead:
                                  (conversationId, markedCount) {},
                              error: (message) {},
                            );
                          },
                        ),
                        BlocListener<
                          CurrentUserProfileBloc,
                          CurrentUserProfileState
                        >(
                          listener: (context, state) {
                            state.when(
                              initial: () {},
                              loading: () {},
                              loaded: (profile) {
                                setState(() {
                                  _currentUserProfile = profile;
                                });
                              },
                              error: (message) {
                                logger.d(
                                  "❌ [ChatScreen] Error loading current user profile: $message",
                                );
                              },
                            );
                          },
                        ),
                      ],
                      child: BlocBuilder<MessagingBloc, MessagingState>(
                        builder: (context, state) {
                          return state.when(
                            initial: _buildLoadingState,
                            loading: _buildLoadingState,
                            conversationsLoaded:
                                (conversations, hasMore, currentPage) =>
                                    _buildLoadingState(),
                            conversationsCleared: _buildEmptyState,
                            messagesLoaded:
                                (
                                  messages,
                                  hasMore,
                                  currentPage,
                                  conversationId,
                                ) => _buildMessagesList(messages),
                            conversationCreated:
                                (conversation) => _buildLoadingState(),
                            messageSent:
                                (message) =>
                                    _messages.isNotEmpty
                                        ? _buildMessagesList(_messages)
                                        : _buildEmptyState(),
                            messagesMarkedAsRead:
                                (conversationId, markedCount) =>
                                    _messages.isNotEmpty
                                        ? _buildMessagesList(_messages)
                                        : _buildEmptyState(),
                            error: _buildErrorState,
                          );
                        },
                      ),
                    ),
                  ),
                  _buildMessageInput(),
                  QuickQuestionsWidget(onQuestionTap: _onQuestionTap),
                ],
              ),
            ),
          ),
        );
      },
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

  /// Get theme-aware app bar background color
  Color _getThemeAwareAppBarBackgroundColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White app bar for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.background; // Blue app bar for blue theme
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

  /// Get theme-aware send button color
  Color _getThemeAwareSendButtonColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black send button for light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White send button for blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware input background color
  Color _getThemeAwareInputBackgroundColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White input background for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.background; // Blue input background for blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware border color
  Color _getThemeAwareBorderColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.grey.withValues(
        alpha: 0.2,
      ); // Light grey border for light theme
    } else if (themeState.isBlueTheme) {
      return BlueThemeColors.divider; // Blue border for blue theme
    }
    return Colors.grey.withValues(alpha: 0.2); // Default to light grey
  }

  Widget _buildLoadingState() {
    return const Center(child: HouseLoadingIndicator());
  }

  Widget _buildErrorState(String message) {
    final displayMessage = message.contains("USER_BLOCKED")
        ? L10n.get("user_blocked_violation_message",
            )
            : (message.contains("DioException") ||
                message.contains("bad response") ||
                message.contains("status code"))
            ? L10n.get("error_generic",
                )
            : message;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              displayMessage,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _messagingBloc.add(
                RefreshMessages(conversationId: widget.conversationId),
              );
            },
            child: Text(L10n.get("retry")),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<Message> messages) {
    if (messages.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          _messagingBloc.add(
            RefreshMessages(conversationId: widget.conversationId),
          );
        },
        child: _buildEmptyState(),
      );
    }

    // Group messages by date for lazy building
    final groupedItems = MessageGroupingUtils.groupMessagesAsItems(
      messages,
      _currentUserId,
      _newMessageIds,
    );

    return CommonListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      reverse: true, // Show newest messages at bottom
      itemSpacing: 0, // Message grouping handles spacing
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
          // Since we're using reverse: true, we need to reverse the index
          final itemIndex = groupedItems.length - 1 - index;
          final item = groupedItems[itemIndex];

          return switch (item) {
            DateHeaderListItem(:final date) => DateHeaderWidget(
                dateString:
                    MessageGroupingUtils.formatDateHeader(date, context),
                date: date,
              ),
            MessageListItem(
              :final message,
              :final isCurrentUser,
              :final isLatest,
            ) =>
              MessageBubble(
                key: ValueKey("message_${message.id}_${message.createdAt}"),
                message: message,
                isCurrentUser: isCurrentUser,
                isLatest: isLatest,
                onAnimationComplete: () {
                  setState(() {
                    _newMessageIds.remove(message.id);
                  });
                },
                currentUserProfile: _currentUserProfile,
                otherUserInitials: widget.otherUserInitials,
              ),
          };
        },
      showRefreshIndicator: true,
      onRefresh: () async {
        _messagingBloc.add(
          RefreshMessages(conversationId: widget.conversationId),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                L10n.get("no_messages"),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                L10n.get("send_first_message",
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final inputBackgroundColor = _getThemeAwareInputBackgroundColor(
          themeState,
        );
        final sendButtonColor = _getThemeAwareSendButtonColor(themeState);
        final borderColor = _getThemeAwareBorderColor(themeState);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: inputBackgroundColor,
            border: Border(top: BorderSide(color: borderColor)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(
                    color: Colors.black, // Always use black text for visibility
                  ),
                  decoration: InputDecoration(
                    hintText: L10n.get("type_message"),
                    hintStyle: TextStyle(
                      color: Colors.grey[600], // Grey hint text
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              const SizedBox(width: 8),
              BlocListener<MessagingBloc, MessagingState>(
                listener: (context, state) {
                  state.when(
                    initial: () {},
                    loading: () {},
                    conversationsLoaded:
                        (conversations, hasMore, currentPage) {},
                    conversationsCleared: () {},
                    messagesLoaded:
                        (messages, hasMore, currentPage, conversationId) {},
                    conversationCreated: (conversation) {},
                    messageSent: (message) {
                      // Reset sending state when message is sent successfully
                      setState(() {
                        _isSendingMessage = false;
                      });
                      // Trigger light haptic feedback
                      HapticFeedbackUtils.impact();
                    },
                    messagesMarkedAsRead: (conversationId, markedCount) {},
                    error: (message) {
                      // Reset sending state when there's an error
                      setState(() {
                        _isSendingMessage = false;
                      });

                      // Don't show SnackBar for USER_BLOCKED - the main error state already displays it
                      if (message.contains("USER_BLOCKED")) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    },
                  );
                },
                child: IconButton(
                  onPressed: _isSendingMessage ? null : _sendMessage,
                  icon:
                      _isSendingMessage
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                sendButtonColor,
                              ),
                            ),
                          )
                          : Icon(Icons.send, color: sendButtonColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSendingMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    _messageController.clear();

    // Play sound immediately on send for reliable feedback
    SendSoundUtils.playSendSound();

    _messagingBloc.add(
      SendMessage(conversationId: widget.conversationId, content: content),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onQuestionTap(String question) {
    // Add appropriate greeting based on current language
    final greeting = _getGreetingForCurrentLanguage();
    // Lowercase the first letter of the question
    final lowercasedQuestion =
        question.isEmpty
            ? question
            : question[0].toLowerCase() + question.substring(1);
    _messageController.text = "$greeting $lowercasedQuestion";
    // Focus the text field to show the inserted text
    FocusScope.of(context).requestFocus(FocusNode());
  }

  String _getGreetingForCurrentLanguage() {
    // Get current language using the same method as the app
    final language = LanguageState().currentLanguage;
    switch (language) {
      case "ru":
        return "Привет,";
      case "uz":
        return "Salom,";
      default:
        return "Hi,";
    }
  }

  void _navigateToListingDetail() {
    if (widget.listingId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create:
                    (context) => ListingDetailBloc(getIt<IListingService>()),
                child: ListingDetailScreen(listingId: widget.listingId!),
              ),
        ),
      );
    }
  }

  void _navigateToUserProfile() {
    // Prefer widget.otherUserId, fall back to deriving from messages
    final otherUserId =
        widget.otherUserId ?? _getOtherUserIdFromMessages();
    if (otherUserId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create:
                    (context) =>
                        ListingOwnerProfileBloc(getIt<IUserProfileService>()),
                child: ListingOwnerProfileScreen(userId: otherUserId),
              ),
        ),
      );
    }
  }

  Future<void> _createComplaint() async {
    if (widget.listingId == null) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider<ComplaintBloc>(
              create: (context) => ComplaintBloc(getIt<IComplaintService>()),
              child: CreateComplaintScreen(listingId: widget.listingId!),
            ),
      ),
    );

    if (result == true && context.mounted) {
      ToastTheme.showSuccess(
        context,
        message: L10n.get("complaint_created_success"),
      );
    }
  }

  Widget _buildProfileMenuIcon() {
    if (widget.otherUserAvatar != null &&
        widget.otherUserAvatar!.trim().isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.otherUserAvatar!,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          memCacheWidth: 48,
          memCacheHeight: 48,
          placeholder: (context, url) => const Icon(Icons.person, size: 20),
          errorWidget: (context, url, error) => const Icon(Icons.person, size: 20),
        ),
      );
    }
    return const Icon(Icons.person, size: 20);
  }

  int? _getOtherUserIdFromMessages() {
    if (_currentUserId == null || _messages.isEmpty) return null;

    // Find the first message from someone other than the current user
    for (final message in _messages) {
      if (message.senderId != _currentUserId) {
        return message.senderId;
      }
    }

    return null;
  }

  List<ActionMenuItem> _buildActionMenuItems() {
    final items = <ActionMenuItem>[];
    final otherUserId =
        widget.otherUserId ?? _getOtherUserIdFromMessages();

    // Profile option - show when other user ID is available
    if (otherUserId != null) {
      items.add(
        ActionMenuItem(
          value: "profile",
          icon: Icons.person,
          textKey: "profile_interlocutor",
          onPressed: _navigateToUserProfile,
          iconWidget: _buildProfileMenuIcon(),
        ),
      );
    }

    // View listing option - only show when listingId is available
    if (widget.listingId != null) {
      items.add(
        ActionMenuItem(
          value: "view_listing",
          icon: Icons.article,
          textKey: "view_listing",
          onPressed: _navigateToListingDetail,
        ),
      );
    }

    // Complain option - only show when listingId is available
    if (widget.listingId != null) {
      items.add(
        ActionMenuItem(
          value: "complain",
          icon: CupertinoIcons.exclamationmark_circle_fill,
          textKey: "complain",
          onPressed: _createComplaint,
          iconColor: Colors.red,
          textColor: Colors.red,
        ),
      );
    }

    return items;
  }
}

/// Custom painter for the bubble with integrated tail pointing towards user avatar.
class _BubbleWithTailPainter extends CustomPainter {

  _BubbleWithTailPainter({
    required this.color,
    required this.borderColor,
    required this.shadowColor,
    required this.tailPointsRight,
    this.hasBorder = false,
    this.radius = 18,
  });
  final Color color;
  final Color borderColor;
  final Color shadowColor;
  final bool hasBorder;
  final bool tailPointsRight;
  final double radius;
  static const double _tailWidth = 10;
  static const double _tailHeight = 16;

  Path _createBubblePath(Size size) {
    final w = size.width;
    final h = size.height;
    final r = radius;
    final centerY = h / 2;

    if (tailPointsRight) {
      return Path()
        ..moveTo(r, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, centerY - _tailHeight / 2)
        ..lineTo(w + _tailWidth, centerY)
        ..lineTo(w, centerY + _tailHeight / 2)
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..close();
    } else {
      return Path()
        ..moveTo(r, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..lineTo(0, centerY + _tailHeight / 2)
        ..lineTo(-_tailWidth, centerY)
        ..lineTo(0, centerY - _tailHeight / 2)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..close();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _createBubblePath(size);
    canvas.drawShadow(path, shadowColor, 6, true);
    canvas.drawPath(
      path,
      Paint()..color = color..style = PaintingStyle.fill,
    );
    if (hasBorder) {
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubbleWithTailPainter oldDelegate) =>
      color != oldDelegate.color ||
      borderColor != oldDelegate.borderColor ||
      shadowColor != oldDelegate.shadowColor ||
      tailPointsRight != oldDelegate.tailPointsRight ||
      hasBorder != oldDelegate.hasBorder;
}

class MessageBubble extends StatefulWidget {

  const MessageBubble({
    required this.message, required this.isCurrentUser, super.key,
    this.isLatest = false,
    this.onAnimationComplete,
    this.currentUserProfile,
    this.otherUserInitials,
  });
  final Message message;
  final bool isCurrentUser;
  final bool isLatest;
  final VoidCallback? onAnimationComplete;
  final UserProfile? currentUserProfile;
  final String? otherUserInitials;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation controller (for the shake/elastic effect)
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Fade animation controller (for the fade-in effect)
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create a stretch and shrink animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    // Create a fade-in animation (from 0.5 to 1.0 opacity)
    _fadeAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Only start the animation if this is the latest message
    if (widget.isLatest) {
      // Start scale animation immediately
      _scaleAnimationController.forward();

      // Start fade animation with a slight delay (100ms) to create overlap
      Future.delayed(const Duration(milliseconds: 100), () {
        _fadeAnimationController.forward();
      });

      // Wait for both animations to complete (scale takes 500ms, fade starts at 100ms and takes 500ms, so total is 600ms)
      Future.delayed(const Duration(milliseconds: 600), () {
        widget.onAnimationComplete?.call();
      });
    } else {
      // For older messages, set to final state immediately
      _scaleAnimationController.value = 1.0;
      _fadeAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final ownMessageColor = _getThemeAwareOwnMessageColor(themeState);
        final ownMessageTextColor = _getThemeAwareOwnMessageTextColor(
          themeState,
        );
        final ownMessageBorderColor = _getThemeAwareOwnMessageBorderColor(
          themeState,
        );
        final otherMessageColor = _getThemeAwareOtherMessageColor(themeState);
        final otherMessageTextColor = _getThemeAwareOtherMessageTextColor(
          themeState,
        );
        final bubbleShadowColor = _getThemeAwareBubbleShadowColor(themeState);

        return AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment:
                        widget.isCurrentUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      if (!widget.isCurrentUser) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: _getThemeAwareOtherUserAvatarColor(
                              themeState,
                            ),
                            child: _buildOtherUserAvatarContent(themeState),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: widget.isCurrentUser ? 0 : 10,
                            right: widget.isCurrentUser ? 10 : 0,
                          ),
                          child: CustomPaint(
                            painter: _BubbleWithTailPainter(
                              color: widget.isCurrentUser
                                  ? ownMessageColor
                                  : otherMessageColor,
                              borderColor: widget.isCurrentUser
                                  ? ownMessageBorderColor
                                  : Colors.transparent,
                              shadowColor: bubbleShadowColor,
                              tailPointsRight: widget.isCurrentUser,
                              hasBorder: widget.isCurrentUser,
                              radius: 18,
                            ),
                            child: Container(
                              padding: EdgeInsets.only(
                                left: widget.isCurrentUser ? 16 : 20,
                                right: widget.isCurrentUser ? 20 : 16,
                                top: 12,
                                bottom: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.message.content,
                                    style: TextStyle(
                                      color: widget.isCurrentUser
                                          ? ownMessageTextColor
                                          : otherMessageTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 10,
                                        color: (widget.isCurrentUser
                                                ? ownMessageTextColor
                                                : otherMessageTextColor)
                                            .withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        _formatTime(widget.message.createdAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: (widget.isCurrentUser
                                                  ? ownMessageTextColor
                                                  : otherMessageTextColor)
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                      if (widget.isCurrentUser) ...[
                                        const SizedBox(width: 4),
                                        _buildCheckmarks(),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.isCurrentUser) ...[
                        const SizedBox(width: 8),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor:
                                _getThemeAwareCurrentUserAvatarColor(
                                  themeState,
                                ),
                            child: _buildCurrentUserAvatarContent(themeState),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Get theme-aware own message background color
  Color _getThemeAwareOwnMessageColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.white; // White background for own messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White background for own messages in blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware own message text color
  Color _getThemeAwareOwnMessageTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text for own messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors.black; // Black text for own messages in blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware own message border color
  Color _getThemeAwareOwnMessageBorderColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .grey[300]!; // Light grey border for own messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors
          .grey[300]!; // Light grey border for own messages in blue theme
    }
    return Colors.grey[300]!; // Default to light grey
  }

  /// Get theme-aware message bubble shadow color
  Color _getThemeAwareBubbleShadowColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black.withValues(alpha: 0.12);
    } else if (themeState.isBlueTheme) {
      return Colors.black.withValues(alpha: 0.18);
    }
    return Colors.black.withValues(alpha: 0.12);
  }

  /// Get theme-aware other message background color
  Color _getThemeAwareOtherMessageColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .grey[200]!; // Light grey background for other messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors
          .grey[700]!; // Dark grey background for other messages in blue theme
    }
    return Colors.grey[200]!; // Default to light grey
  }

  /// Get theme-aware other message text color
  Color _getThemeAwareOtherMessageTextColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black text for other messages in light theme
    } else if (themeState.isBlueTheme) {
      return Colors.white; // White text for other messages in blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware current user avatar background color
  Color _getThemeAwareCurrentUserAvatarColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors.black; // Black avatar for current user in light theme
    } else if (themeState.isBlueTheme) {
      return Colors.black; // Black avatar for current user in blue theme
    }
    return Colors.black; // Default to black
  }

  /// Get theme-aware current user avatar icon color
  Color _getThemeAwareCurrentUserAvatarIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .white; // White icon on black avatar for current user in light theme
    } else if (themeState.isBlueTheme) {
      return Colors
          .white; // White icon on black avatar for current user in blue theme
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware other user (listing owner) avatar background color
  Color _getThemeAwareOtherUserAvatarColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .white; // White avatar for other user in light theme (inverted)
    } else if (themeState.isBlueTheme) {
      return Colors
          .white; // White avatar for other user in blue theme (inverted)
    }
    return Colors.white; // Default to white
  }

  /// Get theme-aware other user (listing owner) avatar icon color
  Color _getThemeAwareOtherUserAvatarIconColor(ThemeState themeState) {
    if (themeState.isLightTheme) {
      return Colors
          .black; // Black icon on white avatar for other user in light theme (inverted)
    } else if (themeState.isBlueTheme) {
      return Colors
          .black; // Black icon on white avatar for other user in blue theme (inverted)
    }
    return Colors.black; // Default to black
  }

  String _formatTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      // Always show only time, no date
      if (difference.inMinutes > 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else {
        return L10n.get("now");
      }
    } catch (e) {
      return "";
    }
  }

  /// Build avatar content for other user - first letter(s) of name or person icon
  Widget _buildOtherUserAvatarContent(ThemeState themeState) {
    // Use passed initials if available
    if (widget.otherUserInitials != null &&
        widget.otherUserInitials!.isNotEmpty) {
      return Text(
        widget.otherUserInitials!,
        style: TextStyle(
          color: _getThemeAwareOtherUserAvatarIconColor(themeState),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    // Fallback: Try to get the other user's name from message sender
    final sender = widget.message.sender;
    var userName = sender?.profile?.name;

    // If still no name, try to extract from sender email as fallback
    if (userName == null || userName.isEmpty) {
      if (sender?.email != null && sender!.email.isNotEmpty) {
        // Extract name from email (part before @)
        final emailParts = sender.email.split("@");
        if (emailParts.isNotEmpty) {
          userName = emailParts[0];
        }
      }
    }

    final initials = StringUtils.extractInitials(userName);

    // If we have initials, show them
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: _getThemeAwareOtherUserAvatarIconColor(themeState),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    // Fallback to person icon
    return Icon(
      Icons.person,
      size: 16,
      color: _getThemeAwareOtherUserAvatarIconColor(themeState),
    );
  }

  /// Build avatar content for current user - first letter(s) of name or person icon
  Widget _buildCurrentUserAvatarContent(ThemeState themeState) {
    // Get the current user's name from profile
    final userName = widget.currentUserProfile?.name;

    final initials = StringUtils.extractInitials(userName);

    // Debug logging (can be removed in production)
    // logger.d('🔍 [ChatScreen] Current User Avatar debug:');
    // logger.d('   - Current User Profile: ${widget.currentUserProfile}');
    // logger.d('   - UserName (final): $userName');
    // logger.d('   - Initials: $initials');

    // If we have initials, show them
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: _getThemeAwareCurrentUserAvatarIconColor(themeState),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }

    // Fallback to person icon
    return Icon(
      Icons.person,
      size: 16,
      color: _getThemeAwareCurrentUserAvatarIconColor(themeState),
    );
  }

  /// Build checkmarks for message status
  Widget _buildCheckmarks() {
    final themeState = ThemeState();
    final checkmarkColor = _getThemeAwareOwnMessageTextColor(
      themeState,
    ).withValues(alpha: 0.7);

    // For now, show single checkmark for sent messages
    // TODO: Add double checkmark when backend provides read status by other user
    return Icon(Icons.check, size: 12, color: checkmarkColor);
  }
}
