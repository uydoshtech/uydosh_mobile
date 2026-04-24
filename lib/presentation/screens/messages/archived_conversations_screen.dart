import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
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
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
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
  bool _showTip = false;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "archived_chats");
    _loadTipVisibility();
    _init();
  }

  Future<void> _init() async {
    _currentUserId = await SessionManager.getUserId();
    await _load();
  }

  Future<void> _loadTipVisibility() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(TooltipsState.keyArchivedChatsTipDismissed)) {
        await prefs.setBool(TooltipsState.keyArchivedChatsTipDismissed, false);
      }
      final dismissed =
          prefs.getBool(TooltipsState.keyArchivedChatsTipDismissed) ?? false;
      if (!mounted) return;
      setState(() => _showTip = !dismissed);
    } catch (_) {
      // If prefs are unavailable, keep default (hidden).
    }
  }

  Future<void> _dismissTip() async {
    setState(() => _showTip = false);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(TooltipsState.keyArchivedChatsTipDismissed, true);
    } catch (_) {}
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

    // The bottom snackbar is reserved for the archive flow (it carries the
    // Undo action). For the simple "moved back to inbox" confirmation we reuse
    // the app-wide rolling top toast.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ToastTheme.showSuccess(
      context,
      message: L10n.get("chat_unarchived"),
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

    final showTip = TooltipsState().enabled && _showTip;
    final headerOffset = showTip ? 1 : 0;

    return UydoshRefreshIndicator.mainShell(
      onRefresh: _load,
      edgeOffset: 0,
      child: CommonListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemSpacing: 12,
        itemCount: items.length + headerOffset,
        itemBuilder: (context, index) {
          if (showTip && index == 0) {
            return _buildTip(Theme.of(context));
          }
          final conversation = items[index - headerOffset];
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

  Widget _buildTip(ThemeData theme) {
    final fg = theme.colorScheme.onSurfaceVariant;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 40, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.55,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(Icons.info_outline, size: 17, color: fg),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L10n.get("archived_chats_tip"),
                  style: TextStyle(
                    color: fg,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: _dismissTip,
            icon: Icon(Icons.close, size: 18, color: fg),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            splashRadius: 18,
          ),
        ),
      ],
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
