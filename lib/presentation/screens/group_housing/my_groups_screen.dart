import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/conversation/conversation_tile.dart";

class MyGroupsScreen extends StatefulWidget {
  const MyGroupsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  static const int _conversationLimit = 100;

  int? _currentUserId;
  bool _loading = true;
  String? _errorMessage;
  List<ConversationSummary> _groups = const [];
  Map<int, ListingGroupContext> _groupContexts = const {};

  @override
  void initState() {
    super.initState();
    unawaited(_loadGroups());
  }

  Future<void> _loadGroups({bool isRefresh = false}) async {
    if (!isRefresh) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final userId = await SessionManager.getUserId();
      final response = await getIt<IMessagingService>()
          .getConversations(limit: _conversationLimit);
      final groups = response.data
          .where((c) => c.contextType?.trim().toLowerCase() == "listing_group")
          .toList()
        ..sort((a, b) => _activityTime(b).compareTo(_activityTime(a)));
      final groupContexts = await _loadGroupContexts(groups);

      if (!mounted) return;
      setState(() {
        _currentUserId = userId;
        _groups = groups;
        _groupContexts = groupContexts;
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

  Future<Map<int, ListingGroupContext>> _loadGroupContexts(
    List<ConversationSummary> groups,
  ) async {
    final entries = await Future.wait(
      groups.map((group) async {
        final listingId = group.listingId;
        if (listingId == null) return null;
        try {
          final detail = await getIt<IListingService>().getListingDetail(
            listingId,
          );
          final groupContext = detail.groupContext;
          if (groupContext == null) return null;
          return MapEntry(group.id, groupContext);
        } catch (_) {
          return null;
        }
      }),
    );

    return Map.fromEntries(
      entries.whereType<MapEntry<int, ListingGroupContext>>(),
    );
  }

  Future<void> _openGroup(ConversationSummary conversation) async {
    HapticFeedbackUtils.impact();
    final listingId = conversation.listingId;
    if (listingId == null) {
      ToastTheme.showError(context, message: L10n.get("error_generic"));
      return;
    }

    await context.pushListingDetail(listingId);
  }

  Future<void> _openChat(ConversationSummary conversation) async {
    HapticFeedbackUtils.impact();
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: ChatScreen.routeName(conversation.id)),
        builder: (_) => ChatScreen(
          conversationId: conversation.id,
          listingId: conversation.listingId,
          listingTypeId: conversation.listingTypeId,
          listingTitle: resolvedConversationListingTitle(conversation),
          conversationContextType: "listing_group",
          conversationParticipantId: conversation.participantId,
        ),
      ),
    );
  }

  Future<void> _refresh() => _loadGroups(isRefresh: true);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        if (widget.embedded) {
          return ColoredBox(
            color: themeState.backgroundColor,
            child: _buildBody(),
          );
        }

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
    if (_loading && _groups.isEmpty && _errorMessage == null) {
      return CenteredHouseLoadingIndicator(
        text: L10n.get("loading"),
      );
    }

    final errorMessage = _errorMessage;
    if (errorMessage != null && _groups.isEmpty) {
      return UydoshErrorRetryColumn(
        message: errorMessage,
        onRetry: () => _loadGroups(),
      );
    }

    if (_groups.isEmpty) {
      return UydoshRefreshIndicator.mainShell(
        onRefresh: _refresh,
        edgeOffset: 0,
        child: PullToRefreshStretchHaptics(
          child: UydoshEmptyColumn(
            icon: Icons.groups_outlined,
            title: L10n.get("menu_my_groups"),
            subtitle: L10n.get("my_groups_empty_subtitle"),
            fillViewportForRefresh: true,
          ),
        ),
      );
    }

    return UydoshRefreshIndicator.mainShell(
      onRefresh: _refresh,
      edgeOffset: 0,
      child: PullToRefreshStretchHaptics(
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
              groupContext: _groupContexts[group.id],
              onTap: () => _openGroup(group),
              onChatTap: () => _openChat(group),
            );
          },
        ),
      ),
    );
  }
}
