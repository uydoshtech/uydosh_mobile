import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_inbox_filters.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/index.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_listing_title_with_category_icon.dart";

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MessagingBloc>().add(FetchConversations());
      }
    });
    SessionManager.getUserId().then((id) {
      if (mounted) setState(() => _currentUserId = id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildCustomHeader(),
            // Content
            Expanded(
              child: BlocBuilder<MessagingBloc, MessagingState>(
                  builder: (context, state) {
                    return state.when(
                      initial: _buildLoadingState,
                      loading: _buildLoadingState,
                      conversationsLoaded:
                          _buildConversationsList,
                      conversationsCleared: _buildEmptyState,
                      messagesLoaded:
                          (messages, hasMore, currentPage, conversationId) =>
                              _buildLoadingState(), // This shouldn't happen in conversations screen
                      conversationCreated:
                          (conversation) => _buildLoadingState(),
                      messageSent: (message) => _buildLoadingState(),
                      messagesMarkedAsRead:
                          (conversationId, markedCount) => _buildLoadingState(),
                      error: _buildErrorState,
                    );
                  },
                ),
              ),
          ],
        ),
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
                L10n.get("conversations"),
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
            // Refresh button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {
                  HapticFeedbackUtils.impact();
                  context.read<MessagingBloc>().add(RefreshConversations());
                },
                icon: ThemeIcon(
                  Icons.refresh,
                  color:
                      Theme.of(context).appBarTheme.foregroundColor ??
                      Theme.of(context).colorScheme.onSurface,
                ),
                tooltip: L10n.get("refresh"),
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
    return UydoshErrorRetryColumn(
      message: message,
      onRetry: () {
        context.read<MessagingBloc>().add(RefreshConversations());
      },
    );
  }

  Widget _buildConversationsList(
    List<ConversationSummary> conversations,
    bool hasMore,
    int currentPage,
  ) {
    final visible =
        conversations.where(conversationHasMessagesForInbox).toList();
    if (visible.isEmpty) {
      return _buildEmptyState();
    }

    return CommonListView(
      padding: const EdgeInsets.all(16),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final conversation = visible[index];
        return ConversationCard(
          conversation: conversation,
          onTap: () => unawaited(_navigateToChat(conversation.id)),
        );
      },
      showRefreshIndicator: true,
      onRefresh: () async {
        context.read<MessagingBloc>().add(RefreshConversations());
      },
      showLoadMoreIndicator: hasMore,
      hasMore: hasMore,
      loadMoreIndicator: _buildLoadMoreButton(),
    );
  }

  Widget _buildEmptyState() {
    return UydoshEmptyColumn(
      icon: Icons.chat_bubble_outline,
      title: L10n.get("no_conversations"),
      subtitle: L10n.get("start_conversation_from_listing"),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            HapticFeedbackUtils.impact();
            // Load more conversations
            context.read<MessagingBloc>().add(
              FetchConversations(page: 2),
            ); // This should be dynamic
          },
          child: Text(
            L10n.get("load_more"),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToChat(int conversationId) async {
    var me = _currentUserId;
    if (me == null) {
      me = await SessionManager.getUserId();
      if (mounted) setState(() => _currentUserId = me);
    }
    // Find the conversation to get the listing ID
    ConversationSummary? conversation;
    context.read<MessagingBloc>().state.maybeWhen(
      conversationsLoaded: (conversations, hasMore, currentPage) {
        final match = conversations.where((c) => c.id == conversationId);
        conversation = match.isEmpty ? null : match.first;
      },
      orElse: () {},
    );

    final conv = conversation;
    final otherUserId =
        conv != null ? conversationCounterpartyUserId(conv, me) : null;
    final rawCtx = conv?.contextType?.trim().toLowerCase();
    final isGigConversation =
        (rawCtx != null && rawCtx.startsWith("gig_")) ||
        (conv?.gigRequestId != null);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: ChatScreen.routeName(conversationId)),
        builder:
            (context) => ChatScreen(
              conversationId: conversationId,
              listingId: isGigConversation ? null : conv?.listingId,
              listingTypeId:
                  isGigConversation ? null : conv?.listingTypeId,
              // Server convention: listing owner is always `participant_id`.
              listingOwnerUserId:
                  isGigConversation ? null : conv?.participantId,
              conversationContextType: conv?.contextType,
              conversationParticipantId: conv?.participantId,
              gigRequestId: conv?.gigRequestId,
              gigRequestTitle: conv?.gigRequestTitle,
              listingTitle:
                  conv != null && !isGigConversation
                      ? resolvedConversationListingTitle(conv)
                      : null,
              otherUserInitials:
                  conv != null
                      ? StringUtils.extractInitials(conv.otherUserName)
                      : null,
              otherUserName: conv?.otherUserName,
              otherUserId: otherUserId,
              otherUserAvatar: conv?.otherUserAvatar,
            ),
      ),
    );
  }
}

class ConversationCard extends StatelessWidget {

  const ConversationCard({
    required this.conversation, required this.onTap, super.key,
  });
  final ConversationSummary conversation;
  final VoidCallback onTap;
  static const _avatarSize = 40.0;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatarUrl = resolveAvatarUrl(conversation.otherUserAvatar);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: resolvedAvatarUrl != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: resolvedAvatarUrl,
                  width: _avatarSize,
                  height: _avatarSize,
                  fit: BoxFit.cover,
                  memCacheWidth: 80,
                  memCacheHeight: 80,
                  placeholder:
                      (context, url) => SizedBox(
                        width: _avatarSize,
                        height: _avatarSize,
                        child: Center(
                          child: ThemeIcon(
                            Icons.person,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => SizedBox(
                        width: _avatarSize,
                        height: _avatarSize,
                        child: Center(
                          child: ThemeIcon(
                            Icons.person,
                            size: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                ),
              )
            : CircleAvatar(
                child: ThemeIcon(
                  Icons.person,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
        title: Text(
          conversation.otherUserName ?? "Unknown User",
          style: TextStyle(
            fontWeight:
                conversation.unreadCount != null &&
                        conversation.unreadCount! > 0
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.listingTitle != null ||
                (conversation.listingTypeId != null &&
                    (conversation.listingTypeId == 1 ||
                        conversation.listingTypeId == 2))) ...[
              ConversationListingTitleWithCategoryIcon(
                conversation: conversation,
                textStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                iconColor: Theme.of(context).colorScheme.primary,
                iconSize: 18,
              ),
              const SizedBox(height: 2),
            ],
            if (conversation.lastMessageContent != null)
              Text(
                conversation.lastMessageContent!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                      conversation.unreadCount != null &&
                              conversation.unreadCount! > 0
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (conversation.lastMessageAt != null)
              Text(
                _formatTime(context, conversation.lastMessageAt!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            if (conversation.unreadCount != null &&
                conversation.unreadCount! > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  conversation.unreadCount.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return "${difference.inDays}d";
      } else if (difference.inHours > 0) {
        return "${difference.inHours}h";
      } else if (difference.inMinutes > 0) {
        return "${difference.inMinutes}m";
      } else {
        return L10n.get("now");
      }
    } catch (e) {
      return "";
    }
  }
}
