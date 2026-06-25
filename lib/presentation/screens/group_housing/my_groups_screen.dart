import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_inbox_filters.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";

class MyGroupsScreen extends StatefulWidget {
  const MyGroupsScreen({super.key});

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  static const int _conversationLimit = 100;

  int? _currentUserId;
  bool _loading = true;
  String? _errorMessage;
  List<ConversationSummary> _groups = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadGroups());
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final userId = await SessionManager.getUserId();
      final response = await getIt<IMessagingService>()
          .getConversations(limit: _conversationLimit);
      final groups = response.data
          .where((c) => c.contextType?.trim().toLowerCase() == "listing_group")
          .toList()
        ..sort((a, b) => _activityTime(b).compareTo(_activityTime(a)));

      if (!mounted) return;
      setState(() {
        _currentUserId = userId;
        _groups = groups;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = L10n.get("error_generic_try_again");
        _loading = false;
      });
    }
  }

  DateTime _activityTime(ConversationSummary conversation) {
    return DateTime.tryParse(
          conversation.lastMessageAt ?? conversation.updatedAt,
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _openGroup(ConversationSummary conversation) async {
    HapticFeedbackUtils.impact();
    final userId = _currentUserId ?? await SessionManager.getUserId();
    if (!mounted) return;
    if (_currentUserId == null) {
      setState(() => _currentUserId = userId);
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: ChatScreen.routeName(conversation.id)),
        builder: (context) => ChatScreen(
          conversationId: conversation.id,
          listingId: conversation.listingId,
          listingTypeId: conversation.listingTypeId,
          listingOwnerUserId: conversation.participantId,
          conversationContextType: conversation.contextType,
          conversationParticipantId: conversation.participantId,
          listingTitle: resolvedConversationListingTitle(conversation),
          otherUserInitials: StringUtils.extractInitials(
            conversation.otherUserName,
          ),
          otherUserName: conversation.otherUserName,
          otherUserId: conversationCounterpartyUserId(conversation, userId),
          otherUserAvatar: conversation.otherUserAvatar,
        ),
      ),
    );
  }

  Future<void> _refresh() => _loadGroups();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        return Scaffold(
          backgroundColor: themeState.backgroundColor,
          appBar: CommonAppBar(
            title: L10n.get("menu_my_groups"),
            showBackButton: true,
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: HouseLoadingIndicator());
    }

    final errorMessage = _errorMessage;
    if (errorMessage != null) {
      return UydoshErrorRetryColumn(
        message: errorMessage,
        onRetry: _loadGroups,
      );
    }

    if (_groups.isEmpty) {
      return UydoshEmptyColumn(
        icon: Icons.groups_outlined,
        title: L10n.get("menu_my_groups"),
        subtitle: L10n.get("my_groups_empty_subtitle"),
        fillViewportForRefresh: true,
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
        itemCount: _groups.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final group = _groups[index];
          return ConversationTile(
            conversation: group,
            currentUserId: _currentUserId,
            useFeedTileSurface: true,
            surfaceMargin: EdgeInsets.zero,
            showParticipantAvatarStack: true,
            onTap: () => _openGroup(group),
          );
        },
      ),
    );
  }
}
