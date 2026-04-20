import "package:cached_network_image/cached_network_image.dart";
import "dart:async";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/presentation/blocs/current_user_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/complaint/create_complaint_screen.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_header.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_input.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_messages_skeleton.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_security_ribbon.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_safety_warning_ribbon.dart";
import "package:uy_dosh/presentation/widgets/chat/date_header_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/message_bubble.dart";
import "package:uy_dosh/presentation/widgets/chat/message_grouping_utils.dart";
import "package:uy_dosh/presentation/widgets/chat/quick_questions_widget.dart";
import "package:uy_dosh/presentation/widgets/chat/suspicious_message_bottom_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
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
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late FocusNode _messageFocusNode;
  int? _currentUserId;
  List<Message> _messages = [];
  bool _isSendingMessage = false;
  bool _hasLoadedMessagesForConversation = false; // Track if we've completed initial fetch (avoids loading when bloc is overwritten by RefreshConversations)
  final Set<int> _newMessageIds = {}; // Track which messages are new in this session
  UserProfile? _currentUserProfile; // Store the current user's profile
  bool _showSecurityRibbon = true;
  String? _safetyWarningTitle;
  String? _safetyWarningBody;
  ChatSafetyWarningSeverity _safetyWarningSeverity =
      ChatSafetyWarningSeverity.medium;
  final Map<int, String> _messageRiskById = {}; // messageId -> 'medium'|'high'
  final Map<int, String> _messageSafetyReasonById = {}; // messageId -> localized reason
  DateTime? _lastSafetyCheckAt;
  bool _safetyCheckInFlight = false;
  bool _showRefreshSkeleton = false;
  DateTime? _refreshSkeletonStartedAt;
  Completer<void>? _refreshCompleter;

  static const Duration _minSkeletonDuration = Duration(milliseconds: 450);

  /// Memoized output of [MessageGroupingUtils.groupMessagesAsItems] — invalidated when
  /// [messages] reference, [_currentUserId], or [_newMessageIds] meaningfully change.
  List<MessageGroupListItem>? _cachedGroupedItems;
  List<Message>? _groupedCacheMessagesRef;
  int? _groupedCacheCurrentUserId;
  int _groupedCacheNewMessageIdsFingerprint = 0;

  int _fingerprintNewMessageIds(Set<int> ids) {
    if (ids.isEmpty) return 0;
    final sorted = ids.toList()..sort();
    return Object.hashAll(sorted);
  }

  List<MessageGroupListItem> _groupedItemsFor(List<Message> messages) {
    final fp = _fingerprintNewMessageIds(_newMessageIds);
    if (_cachedGroupedItems != null &&
        identical(messages, _groupedCacheMessagesRef) &&
        _currentUserId == _groupedCacheCurrentUserId &&
        fp == _groupedCacheNewMessageIdsFingerprint) {
      return _cachedGroupedItems!;
    }
    final items = MessageGroupingUtils.groupMessagesAsItems(
      messages,
      _currentUserId,
      _newMessageIds,
    );
    _groupedCacheMessagesRef = messages;
    _groupedCacheCurrentUserId = _currentUserId;
    _groupedCacheNewMessageIdsFingerprint = fp;
    _cachedGroupedItems = items;
    return items;
  }

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "chat");
    getIt<AppAnalyticsService>().logChatOpened(
      conversationId: widget.conversationId,
      listingId: widget.listingId,
    );
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _messageFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeChat());
    _loadSecurityRibbonState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (!mounted) return;
    try {
      // Get current user ID
      _currentUserId = await SessionManager.getUserId();

      // Fetch current user profile and messages using shared blocs
      context.read<CurrentUserProfileBloc>().add(
            const CurrentUserProfileEvent.fetchProfile(),
          );
      context.read<MessagingBloc>().add(
            FetchMessages(conversationId: widget.conversationId),
          );
    } catch (e) {
      logger.d("❌ [ChatScreen] Error initializing chat: $e");
    }
  }

  Future<void> _loadSecurityRibbonState() async {
    try {
      final dismissed = await SessionManager.isChatSecurityRibbonDismissed();
      if (!mounted) return;
      setState(() => _showSecurityRibbon = !dismissed);
    } catch (_) {
      // If prefs fail, keep ribbon visible.
    }
  }

  Future<void> _dismissSecurityRibbon() async {
    HapticFeedbackUtils.impact();
    if (mounted) setState(() => _showSecurityRibbon = false);
    try {
      await SessionManager.dismissChatSecurityRibbon();
    } catch (_) {
      // Ignore.
    }
  }

  bool _matchesScamTrigger(String text) {
    final t = text.toLowerCase();
    // Links, off-platform, OTP, deposits, payment keywords. MVP: simple and cheap.
    final patterns = <RegExp>[
      RegExp(r'https?://', caseSensitive: false),
      RegExp(r'\b(t\.me|telegram|whatsapp|wa\.me|instagram|иг|инст)\b', caseSensitive: false),
      RegExp(r'\b(otp|code|verification|verify|парол|код|смс|sms)\b', caseSensitive: false),
      RegExp(r'\b(deposit|prepay|advance|pay now|bank|card|iban|swift|crypto|wallet|usdt|ton)\b', caseSensitive: false),
      RegExp(r'\b(предоплат|задаток|депозит|оплат|перевод|карта|банк)\b', caseSensitive: false),
    ];
    return patterns.any((p) => p.hasMatch(t));
  }

  String _localizedSafetyReason(String reason) {
    final normalized = reason.trim();
    final lower = normalized.toLowerCase();

    // Backend can return English "reason" strings. Map known reasons to localized text.
    if (lower.contains("deposit") && lower.contains("reserve")) {
      return L10n.get("chat_safety_reason_deposit_to_reserve_room");
    }

    if (lower.contains("suspicious") && lower.contains("link")) {
      return L10n.get("chat_safety_reason_suspicious_link");
    }

    if (lower.contains("off-platform") ||
        lower.contains("off platform") ||
        lower.contains("move the conversation") ||
        (lower.contains("telegram") || lower.contains("whatsapp"))) {
      return L10n.get("chat_safety_reason_off_platform");
    }

    if (lower.contains("otp") ||
        lower.contains("verification") ||
        (lower.contains("code") && lower.contains("sms"))) {
      return L10n.get("chat_safety_reason_otp_code");
    }

    if (lower.contains("prepay") ||
        lower.contains("advance") ||
        lower.contains("deposit") ||
        lower.contains("card") ||
        lower.contains("iban") ||
        lower.contains("swift") ||
        lower.contains("crypto") ||
        lower.contains("wallet")) {
      return L10n.get("chat_safety_reason_payment_request");
    }

    return normalized;
  }

  Future<void> _maybeRunSafetyCheck({required String triggerText}) async {
    if (_safetyCheckInFlight) return;

    // debounce / rate-limit: at most once per 15 seconds
    final now = DateTime.now();
    if (_lastSafetyCheckAt != null &&
        now.difference(_lastSafetyCheckAt!) < const Duration(seconds: 15)) {
      return;
    }

    if (!_matchesScamTrigger(triggerText)) return;
    _lastSafetyCheckAt = now;
    _safetyCheckInFlight = true;

    try {
      final service = getIt<IMessagingService>();
      final resp = await service.safetyCheckConversation(
        conversationId: widget.conversationId,
        limit: 8,
      );

      final data = resp["data"];
      if (data is Map) {
        final risk = (data["risk_level"] as String?)?.toLowerCase();
        final reason = data["reason"] as String?;
        final evidence = data["evidence_message_ids"];

        if ((risk == "medium" || risk == "high") && evidence is List) {
          final ids =
              evidence.map((e) => e is int ? e : int.tryParse("$e")).whereType<int>();
          if (mounted) {
            setState(() {
              for (final id in ids) {
                _messageRiskById[id] = risk!;
                if (reason != null && reason.trim().isNotEmpty) {
                  _messageSafetyReasonById[id] = _localizedSafetyReason(reason);
                }
              }
            });
          }
        }
        if (risk == "medium" || risk == "high") {
          if (!mounted) return;
          setState(() {
            _safetyWarningSeverity =
                risk == "high"
                    ? ChatSafetyWarningSeverity.high
                    : ChatSafetyWarningSeverity.medium;
            _safetyWarningTitle =
                risk == "high"
                    ? L10n.get("chat_safety_warning_title_high")
                    : L10n.get("chat_safety_warning_title_medium");
            _safetyWarningBody =
                (reason != null && reason.trim().isNotEmpty)
                    ? _localizedSafetyReason(reason)
                    : L10n.get("chat_safety_warning_fallback");
          });
        }
      }
    } catch (_) {
      // Ignore safety check failures (non-blocking).
    } finally {
      _safetyCheckInFlight = false;
    }
  }

  void _dismissSafetyWarning() {
    setState(() {
      _safetyWarningTitle = null;
      _safetyWarningBody = null;
      _safetyWarningSeverity = ChatSafetyWarningSeverity.medium;
    });
  }

  String _titleForRiskLevel(String? riskLevel) {
    final rl = (riskLevel ?? "").toLowerCase();
    if (rl == "high") return L10n.get("chat_safety_warning_title_high");
    return L10n.get("chat_safety_warning_title_medium");
  }

  Future<void> _openSuspiciousMessageSheet({
    required Message message,
    required String riskLevel,
  }) async {
    final reason = _messageSafetyReasonById[message.id] ??
        L10n.get("chat_safety_warning_fallback");

    await SuspiciousMessageBottomSheet.show(
      context,
      title: _titleForRiskLevel(riskLevel),
      reasons: [reason],
      onCopyPressed: () async {
        await Clipboard.setData(ClipboardData(text: message.content));
        if (!mounted) return;
        ToastTheme.showSuccess(
          context,
          message: L10n.get("chat_safety_sheet_copied"),
        );
      },
      onReportPressed: widget.listingId == null ? null : _createComplaint,
    );
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
        final backgroundColor = themeState.backgroundColor;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: ChatHeader(
            headerTitle: _getHeaderTitle(context),
            onRefresh: () {
              _refreshMessagesWithSkeleton();
            },
            actionMenuItems: _buildActionMenuItems(),
          ),
          body: GestureDetector(
            onTap: () {
              // Hide keyboard when tapping outside of text input
              FocusScope.of(context).unfocus();
            },
            child: Column(
                children: [
                  if (_showSecurityRibbon)
                    ChatSecurityRibbon(onClose: _dismissSecurityRibbon),
                  if (_safetyWarningTitle != null && _safetyWarningBody != null)
                    ChatSafetyWarningRibbon(
                      title: _safetyWarningTitle!,
                      body: _safetyWarningBody!,
                      severity: _safetyWarningSeverity,
                      onClose: _dismissSafetyWarning,
                    ),
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
                                  _hasLoadedMessagesForConversation = true;
                                  // Don't mark any messages as new when initially loading
                                  // _newMessageIds remains empty for initial load
                                });
                                _finishRefreshSkeletonIfNeeded();
                                // Mark messages as read after they're loaded
                                context.read<MessagingBloc>().add(
                                      MarkMessagesAsRead(
                                        conversationId: conversationId,
                                      ),
                                    );

                                // MVP1: client trigger → server safety check (non-blocking)
                                final latestMessage =
                                    messages.isNotEmpty ? messages.last : null;
                                final latest = latestMessage?.content;
                                final latestSenderId = latestMessage?.senderId;
                                // Only warn the potential victim: trigger checks on incoming messages.
                                if (latest != null &&
                                    latestSenderId != null &&
                                    _currentUserId != null &&
                                    latestSenderId != _currentUserId) {
                                  _maybeRunSafetyCheck(triggerText: latest);
                                }
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
                              error: (message) {
                                _finishRefreshSkeletonIfNeeded();
                              },
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
                        buildWhen: (previous, current) {
                          if (_messages.isNotEmpty) {
                            return false;
                          }
                          return previous != current;
                        },
                        builder: (context, state) {
                          if (_showRefreshSkeleton) {
                            return const ChatMessagesSkeleton();
                          }
                          // Once we have messages, always show them - the shared
                          // MessagingBloc can be overwritten by MessagesInboxScreen
                          // (e.g. RefreshConversations on messagesMarkedAsRead),
                          // which would otherwise cause a blink and infinite loading.
                          if (_messages.isNotEmpty) {
                            return _buildMessagesList(_messages);
                          }
                          return state.when(
                            initial: _buildLoadingState,
                            loading: _buildLoadingState,
                            conversationsLoaded:
                                (conversations, hasMore, currentPage) =>
                                    _hasLoadedMessagesForConversation
                                        ? _buildMessagesList(_messages)
                                        : _buildLoadingState(),
                            conversationsCleared: _buildEmptyState,
                            messagesLoaded:
                                (
                                  messages,
                                  hasMore,
                                  currentPage,
                                  conversationId,
                                ) => _buildMessagesList(messages),
                            conversationCreated:
                                (conversation) =>
                                    _hasLoadedMessagesForConversation
                                        ? _buildMessagesList(_messages)
                                        : _buildLoadingState(),
                            messageSent:
                                (message) => _buildEmptyState(),
                            messagesMarkedAsRead:
                                (conversationId, markedCount) =>
                                    _buildEmptyState(),
                            error: _buildErrorState,
                          );
                        },
                      ),
                    ),
                  ),
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
                          setState(() {
                            _isSendingMessage = false;
                          });
                          HapticFeedbackUtils.impact();
                        },
                        messagesMarkedAsRead:
                            (conversationId, markedCount) {},
                        error: (message) {
                          setState(() {
                            _isSendingMessage = false;
                          });
                          if (message.contains("USER_BLOCKED")) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          );
                        },
                      );
                    },
                    child: ChatMessageInput(
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      onSend: _sendMessage,
                      isSendingMessage: _isSendingMessage,
                    ),
                  ),
                  QuickQuestionsWidget(onQuestionTap: _onQuestionTap),
                ],
              ),
          ),
        );
      },
    );
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
          ThemeIcon(
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
              context.read<MessagingBloc>().add(
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
      return UydoshRefreshIndicator(
        onRefresh: () async {
          await _refreshMessagesWithSkeleton();
        },
        child: _buildEmptyState(),
      );
    }

    // Group messages by date for lazy building (memoized across rebuilds)
    final groupedItems = _groupedItemsFor(messages);

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
                riskLevel: _messageRiskById[message.id],
                riskReason: _messageSafetyReasonById[message.id],
                onRiskBadgeTap: () {
                  final riskLevel = _messageRiskById[message.id];
                  if (riskLevel == null) return;
                  _openSuspiciousMessageSheet(
                    message: message,
                    riskLevel: riskLevel,
                  );
                },
                onAnimationComplete: () {
                  if (!mounted) return;
                  setState(() => _newMessageIds.remove(message.id));
                },
                currentUserProfile: _currentUserProfile,
                otherUserInitials: widget.otherUserInitials,
                otherUserAvatarUrl: widget.otherUserAvatar,
              ),
          };
        },
      showRefreshIndicator: true,
      onRefresh: () async {
        await _refreshMessagesWithSkeleton();
      },
    );
  }

  Future<void> _refreshMessagesWithSkeleton() async {
    // Coalesce multiple taps/gestures into a single refresh.
    if (_refreshCompleter != null && !(_refreshCompleter!.isCompleted)) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<void>();
    _refreshSkeletonStartedAt = DateTime.now();
    if (mounted) {
      setState(() => _showRefreshSkeleton = true);
    }

    context.read<MessagingBloc>().add(
          RefreshMessages(conversationId: widget.conversationId),
        );

    return _refreshCompleter!.future;
  }

  void _finishRefreshSkeletonIfNeeded() {
    final completer = _refreshCompleter;
    if (completer == null || completer.isCompleted) return;

    final startedAt = _refreshSkeletonStartedAt;
    final elapsed =
        startedAt == null ? Duration.zero : DateTime.now().difference(startedAt);
    final remaining =
        elapsed >= _minSkeletonDuration ? Duration.zero : _minSkeletonDuration - elapsed;

    Future<void>.delayed(remaining, () {
      if (!mounted) return;
      setState(() => _showRefreshSkeleton = false);
      if (!completer.isCompleted) completer.complete();
      _refreshCompleter = null;
      _refreshSkeletonStartedAt = null;
    });
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
              ThemeIcon(
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

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSendingMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    _messageController.clear();

    // Haptic + sound feedback on send (same as splash - always fires, bypasses app setting)
    HapticFeedback.mediumImpact();
    SendSoundUtils.playSendSound();

    getIt<AppAnalyticsService>().logMessageSent(
      conversationId: widget.conversationId,
    );
    context.read<MessagingBloc>().add(
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
    FocusScope.of(context).requestFocus(_messageFocusNode);
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
              (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create:
                        (context) => ListingDetailBloc(getIt<IListingService>()),
                  ),
                  BlocProvider(create: (_) => ListingDetailPageBloc()),
                ],
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
    final resolvedAvatarUrl = resolveAvatarUrl(widget.otherUserAvatar);
    if (resolvedAvatarUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: resolvedAvatarUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          memCacheWidth: 48,
          memCacheHeight: 48,
          placeholder: (context, url) => const ThemeIcon(Icons.person, size: 20),
          errorWidget: (context, url, error) => const ThemeIcon(Icons.person, size: 20),
        ),
      );
    }
    return const ThemeIcon(Icons.person, size: 20);
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
