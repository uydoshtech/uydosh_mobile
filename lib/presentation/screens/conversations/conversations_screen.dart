import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/index.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  late MessagingBloc _messagingBloc;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _messagingBloc = MessagingBloc(getIt<IMessagingService>());
    _messagingBloc.add(FetchConversations());
    SessionManager.getUserId().then((id) {
      if (mounted) setState(() => _currentUserId = id);
    });
  }

  @override
  void dispose() {
    _messagingBloc.close();
    super.dispose();
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
              child: BlocProvider.value(
                value: _messagingBloc,
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
            ),
          ],
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
              LanguageAwareStringHelper.getCurrent(context, "conversations"),
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
          IconButton(
            onPressed: () {
              _messagingBloc.add(RefreshConversations());
            },
            icon: Icon(
              Icons.refresh,
              color:
                  Theme.of(context).appBarTheme.foregroundColor ??
                  Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: LanguageAwareStringHelper.getCurrent(context, "refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: HouseLoadingIndicator());
  }

  Widget _buildErrorState(String message) {
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
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _messagingBloc.add(RefreshConversations());
            },
            child: Text(LanguageAwareStringHelper.getCurrent(context, "retry")),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList(
    List<ConversationSummary> conversations,
    bool hasMore,
    int currentPage,
  ) {
    if (conversations.isEmpty) {
      return _buildEmptyState();
    }

    return CommonListView(
      padding: const EdgeInsets.all(16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return ConversationCard(
          conversation: conversation,
          onTap: () => _navigateToChat(conversation.id),
        );
      },
      showRefreshIndicator: true,
      onRefresh: () async {
        _messagingBloc.add(RefreshConversations());
      },
      showLoadMoreIndicator: hasMore,
      hasMore: hasMore,
      loadMoreIndicator: _buildLoadMoreButton(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            LanguageAwareStringHelper.getCurrent(context, "no_conversations"),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "start_conversation_from_listing",
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
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            // Load more conversations
            _messagingBloc.add(
              FetchConversations(page: 2),
            ); // This should be dynamic
          },
          child: Text(
            LanguageAwareStringHelper.getCurrent(context, "load_more"),
          ),
        ),
      ),
    );
  }

  void _navigateToChat(int conversationId) {
    // Find the conversation to get the listing ID
    ConversationSummary? conversation;
    _messagingBloc.state.maybeWhen(
      conversationsLoaded: (conversations, hasMore, currentPage) {
        final match = conversations.where((c) => c.id == conversationId);
        conversation = match.isEmpty ? null : match.first;
      },
      orElse: () {},
    );

    final conv = conversation;
    final otherUserId =
        conv != null && _currentUserId != null
            ? (conv.initiatorId == _currentUserId
                ? conv.participantId
                : conv.initiatorId)
            : null;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              conversationId: conversationId,
              listingId: conv?.listingId,
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        onTap: onTap,
        leading: conversation.otherUserAvatar != null
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: conversation.otherUserAvatar!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  memCacheWidth: 80,
                  memCacheHeight: 80,
                  placeholder:
                      (context, url) => Center(
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                  errorWidget:
                      (context, url, error) => Center(
                        child: Icon(
                          Icons.person,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                ),
              )
            : CircleAvatar(
                child: Icon(
                  Icons.person,
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
            if (conversation.listingTitle != null) ...[
              Text(
                conversation.listingTitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
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
        return LanguageAwareStringHelper.getCurrent(context, "now");
      }
    } catch (e) {
      return "";
    }
  }
}
