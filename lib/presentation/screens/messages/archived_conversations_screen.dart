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
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_inbox_filters.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_info_callout_card.dart";
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
  final Map<int, int> _unarchiveSwipeHapticStepById = <int, int>{};

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
      setStateIfMounted(() => _showTip = !dismissed);
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
    setStateIfMounted(() {
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
      setStateIfMounted(() {
        _conversations = sorted;
        _loading = false;
      });
    } catch (e, stack) {
      logger.e(
        "Failed to load archived conversations",
        error: e,
        stackTrace: stack,
      );
      setStateIfMounted(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _unarchive(ConversationSummary conversation) {
    HapticFeedbackUtils.tapticChain();
    context
        .read<MessagingBloc>()
        .add(UnarchiveConversation(conversationId: conversation.id));

    if (mounted) {
      setState(() {
        _conversations =
            _conversations?.where((c) => c.id != conversation.id).toList();
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
          listingTypeId: conversation.listingTypeId,
          // Server convention: listing owner is always `participant_id`.
          listingOwnerUserId: conversation.participantId,
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
            onUpdate: (details) {
              final steps = 7;
              final currentStep = (details.progress * steps).floor();
              final lastStep =
                  _unarchiveSwipeHapticStepById[conversation.id] ?? 0;

              if (currentStep > lastStep) {
                for (var i = lastStep; i < currentStep; i++) {
                  HapticFeedbackUtils.selectionClick();
                }
                _unarchiveSwipeHapticStepById[conversation.id] = currentStep;
              } else if (currentStep <= 0 && lastStep != 0) {
                _unarchiveSwipeHapticStepById[conversation.id] = 0;
              }
            },
            onDismissed: (_) {
              _unarchiveSwipeHapticStepById.remove(conversation.id);
              _unarchive(conversation);
            },
            background: _buildUnarchiveSwipeBackground(),
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

  Widget _buildUnarchiveSwipeBackground() {
    final themeState = ThemeState();
    // Use a bright/contrasting tint so the indicator is actually visible on
    // the dark blue canvas (primaryColor is near the background hue there).
    final accent = themeState.isLightTheme ? Colors.black : Colors.white;
    return Container(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            top: 0,
            bottom: 0,
            end: 20,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.unarchive_outlined,
                    color: accent,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    L10n.get("unarchive"),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w700,
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

  Widget _buildTip(ThemeData theme) {
    final fg = theme.colorScheme.onSurfaceVariant;
    return UydoshInfoCalloutCard(
      onClose: _dismissTip,
      message: Text(
        L10n.get("archived_chats_tip"),
        style: TextStyle(color: fg, fontSize: 14, height: 1.25),
      ),
    );
  }

  Widget _buildEmpty() {
    final themeState = ThemeState();
    return UydoshEmptyColumn(
      icon: Icons.archive_outlined,
      iconSize: 56,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      title: L10n.get("no_archived_conversations"),
      subtitle: L10n.get("no_archived_conversations_description"),
      titleStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: themeState.textColor,
      ),
      subtitleStyle: TextStyle(color: themeState.secondaryTextColor),
    );
  }

  Future<void> _promptActions(ConversationSummary conversation) async {
    HapticFeedbackUtils.impact();
    if (!mounted) return;
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
        final sheetMinHeight = MediaQuery.sizeOf(sheetCtx).height * 0.32;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassBottomSheetSurface(
            borderRadius: radius,
            child: Material(
              type: MaterialType.transparency,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: sheetMinHeight),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // When `showDragHandle` is true, Flutter draws the handle in
                      // the sheet's Material. We render our own so it sits on the
                      // glass surface consistently.
                      const SizedBox(height: 10),
                      Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      ListTile(
                        leading: const ThemeIcon(Icons.unarchive_outlined),
                        title: Text(L10n.get("unarchive")),
                        onTap: () {
                          Navigator.of(sheetCtx).pop();
                          _unarchive(conversation);
                        },
                      ),
                      SizedBox(height: sheetMinHeight * 0.35),
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
}
