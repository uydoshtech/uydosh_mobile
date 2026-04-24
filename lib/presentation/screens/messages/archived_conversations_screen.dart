import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_inbox_filters.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";

/// List of archived conversations, one tab for incoming (user = participant)
/// and one for outgoing (user = initiator). Fetches directly through
/// [IMessagingService] with `?archived=true` rather than through
/// [MessagingBloc] to avoid mixing inbox and archive state; the bloc owns
/// the unarchive dispatch so optimistic removal still works.
class ArchivedConversationsScreen extends StatefulWidget {
  const ArchivedConversationsScreen({super.key});

  @override
  State<ArchivedConversationsScreen> createState() =>
      _ArchivedConversationsScreenState();
}

class _ArchivedConversationsScreenState
    extends State<ArchivedConversationsScreen> {
  final IMessagingService _messagingService = getIt<IMessagingService>();
  int? _currentUserId;
  List<ConversationSummary>? _conversations;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "archived_chats");
    _init();
  }

  Future<void> _init() async {
    _currentUserId = await SessionManager.getUserId();
    await _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Fetch both sides in parallel: for the archive view we don't need the
      // two-tab split — just merge + de-dup by id, the user cares about
      // "which chats did I archive", not which role they hold.
      final responses = await Future.wait([
        _messagingService.getConversations(archived: true, limit: 100),
        _messagingService.getParticipantConversations(
          archived: true,
          limit: 100,
        ),
      ]);
      final merged = <int, ConversationSummary>{};
      for (final r in responses) {
        for (final c in r.data) {
          if (!conversationHasMessagesForInbox(c)) continue;
          merged[c.id] = c;
        }
      }
      final sorted = merged.values.toList()
        ..sort((a, b) {
          final aTime = a.lastMessageAt ?? a.updatedAt;
          final bTime = b.lastMessageAt ?? b.updatedAt;
          return bTime.compareTo(aTime);
        });
      if (!mounted) return;
      setState(() {
        _conversations = sorted;
        _loading = false;
      });
    } catch (e, stack) {
      logger.e(
        "Failed to load archived conversations",
        error: e,
        stackTrace: stack,
      );
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _unarchive(ConversationSummary conversation) {
    HapticFeedbackUtils.impact();
    context
        .read<MessagingBloc>()
        .add(UnarchiveConversation(conversationId: conversation.id));

    if (mounted) {
      setState(() {
        _conversations = _conversations
            ?.where((c) => c.id != conversation.id)
            .toList();
      });
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        // Explicit styling — under the app's blue theme the default
        // SnackBar renders its content white-on-white (invisible text).
        content: Text(
          L10n.get("chat_unarchived"),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  Future<void> _openChat(ConversationSummary conversation) async {
    HapticFeedbackUtils.impact();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: conversation.id,
          listingId: conversation.listingId,
          otherUserInitials:
              StringUtils.extractInitials(conversation.otherUserName),
          otherUserName: conversation.otherUserName,
          otherUserId: conversation.initiatorId == _currentUserId
              ? conversation.participantId
              : conversation.initiatorId,
          otherUserAvatar: conversation.otherUserAvatar,
        ),
      ),
    );
    // User may have sent a new message, which auto-unarchives on the server
    // side. Refresh so the list reflects that.
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        return Scaffold(
          backgroundColor: themeState.backgroundColor,
          appBar: UydoshAppBar(
            toolbarHeight: standardAppBarToolbarHeight,
            leading: ThreeDAppBarIconButton.backLeading(context),
            centerTitle: true,
            title: Text(L10n.get("archived_chats")),
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading && _conversations == null) {
      return const Center(child: HouseLoadingIndicator());
    }
    if (_error != null && _conversations == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ThemeIcon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ThemeState().secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final items = _conversations ?? const <ConversationSummary>[];
    if (items.isEmpty) {
      return _buildEmpty();
    }

    return UydoshRefreshIndicator.mainShell(
      onRefresh: _load,
      edgeOffset: 0,
      child: CommonListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemSpacing: 12,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final conversation = items[index];
          return Dismissible(
            key: ValueKey("archived-swipe-${conversation.id}"),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _unarchive(conversation),
            background: Container(
              alignment: AlignmentDirectional.centerEnd,
              padding: const EdgeInsetsDirectional.only(end: 24),
              decoration: BoxDecoration(
                color: ThemeState().primaryColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeIcon(
                    Icons.unarchive_outlined,
                    color: ThemeState().primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    L10n.get("unarchive"),
                    style: TextStyle(
                      color: ThemeState().primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            child: ConversationTile(
              conversation: conversation,
              currentUserId: _currentUserId,
              showActivityTimeOnly: false,
              onTap: () => _openChat(conversation),
              onLongPress: () => _promptActions(conversation),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    final themeState = ThemeState();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ThemeIcon(
              Icons.archive_outlined,
              size: 56,
              color: themeState.secondaryTextColor,
            ),
            const SizedBox(height: 12),
            Text(
              L10n.get("no_archived_conversations"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeState.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              L10n.get("no_archived_conversations_description"),
              textAlign: TextAlign.center,
              style: TextStyle(color: themeState.secondaryTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _promptActions(ConversationSummary conversation) async {
    HapticFeedbackUtils.impact();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const ThemeIcon(Icons.unarchive_outlined),
                  title: Text(L10n.get("unarchive")),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    _unarchive(conversation);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
