import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/domain/services/admin_listing_conversations_service.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/utils/conversation_listing_title.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart"
    show ThemeHelper, liquidGlassAppBarMaterialColor;

/// Lists every listing-scoped in-app conversation (owner ↔ other users) for moderation.
class AdminListingOwnerConversationsScreen extends StatefulWidget {
  const AdminListingOwnerConversationsScreen({
    required this.listingDetail,
    super.key,
  });

  final ListingDetail listingDetail;

  @override
  State<AdminListingOwnerConversationsScreen> createState() =>
      _AdminListingOwnerConversationsScreenState();
}

class _AdminListingOwnerConversationsScreenState
    extends State<AdminListingOwnerConversationsScreen> {
  bool _loading = true;
  Object? _error;
  AdminListingConversationsResult? _result;

  String _otherUserInitialLetter(ConversationSummary c) {
    final ini = StringUtils.extractInitials(c.otherUserName).trim();
    if (ini.isEmpty) return "?";
    return ini.substring(0, 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await getIt<IAdminListingConversationsService>()
          .listForListing(widget.listingDetail.id);
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _openChat(ConversationSummary c, int listingOwnerId) {
    UiFeedbackUtils.selection();
    final otherId =
        c.initiatorId == listingOwnerId ? c.participantId : c.initiatorId;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: ChatScreen.routeName(c.id)),
        builder: (context) => ChatScreen(
          conversationId: c.id,
          listingId: widget.listingDetail.id,
          listingTypeId: c.listingTypeId ?? widget.listingDetail.listingTypeId,
          listingOwnerUserId: listingOwnerId,
          conversationContextType: c.contextType,
          conversationParticipantId: c.participantId,
          listingTitle:
              resolvedListingChatTitleFromListingDetail(widget.listingDetail),
          otherUserInitials: StringUtils.extractInitials(c.otherUserName),
          otherUserName: c.otherUserName,
          otherUserId: otherId,
          otherUserAvatar: c.otherUserAvatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final useLiquidGlass =
            themeState.usesLiquidGlassChrome;
        final appBarBg = useLiquidGlass
            ? liquidGlassAppBarMaterialColor(context)
            : themeState.appBarBackgroundColor;

        final title = Text(
          L10n.get("admin_listing_owner_conversations_screen_title"),
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor ??
                themeState.textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

        final bodyChild = _loading
            ? const Center(child: HouseLoadingIndicator())
            : _error != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 72),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                L10n.get(
                                  "admin_listing_owner_conversations_error",
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _load,
                                child: Text(
                                  L10n.get(
                                    "admin_listing_owner_conversations_retry",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildList();

        return Scaffold(
          extendBodyBehindAppBar: useLiquidGlass,
          appBar: UydoshAppBar(
            leading: ThreeDAppBarIconButton.backLeading(context),
            title: title,
            backgroundColor: appBarBg,
            surfaceTintColor: useLiquidGlass
                ? Colors.transparent
                : Theme.of(context).appBarTheme.surfaceTintColor,
            elevation: useLiquidGlass ? 0 : null,
            scrolledUnderElevation: useLiquidGlass ? 0 : null,
            shadowColor: useLiquidGlass
                ? Colors.transparent
                : Theme.of(context).appBarTheme.shadowColor,
            forceMaterialTransparency: useLiquidGlass,
            flexibleSpace:
                useLiquidGlass ? const LiquidGlassAppBarFlexibleSpace() : null,
            foregroundColor: Theme.of(context).appBarTheme.foregroundColor ??
                themeState.textColor,
          ),
          body: UydoshRefreshIndicator(onRefresh: _load, child: bodyChild),
        );
      },
    );
  }

  Widget _buildList() {
    final result = _result;
    final ownerId = result?.listingUserId ?? widget.listingDetail.user.id;
    final items = result?.conversations ?? const <ConversationSummary>[];

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          Center(
            child: Text(L10n.get("admin_listing_owner_conversations_empty")),
          ),
        ],
      );
    }

    final listingTitle =
        resolvedListingChatTitleFromListingDetail(widget.listingDetail);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12, top: 4),
            child: Text(
              listingTitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.75),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
        final c = items[index - 1];
        return _conversationTile(context, c, ownerId);
      },
    );
  }

  Widget _conversationTile(
    BuildContext context,
    ConversationSummary c,
    int listingOwnerId,
  ) {
    final resolvedAvatar = resolveAvatarUrl(c.otherUserAvatar)?.trim() ?? "";
    final last = (c.lastMessageContent ?? "").trim().isEmpty
        ? "—"
        : ListingShareMessageCodec.previewText(c.lastMessageContent!.trim());

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _openChat(c, listingOwnerId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: resolvedAvatar.isNotEmpty
                    ? ClipOval(
                        child: NetworkAvatarImage(
                          imageUrl: resolvedAvatar,
                          size: 52,
                          fallback: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Text(
                              _otherUserInitialLetter(c),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: Text(
                          _otherUserInitialLetter(c),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            c.otherUserName?.trim().isNotEmpty == true
                                ? c.otherUserName!
                                : "#${c.id}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!c.isActive) ...[
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Chip(
                              label: Text(
                                L10n.get(
                                  "admin_listing_owner_conversations_closed_badge",
                                ),
                                style: const TextStyle(fontSize: 11),
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              backgroundColor:
                                  AppColors.error.withValues(alpha: 0.14),
                              side: BorderSide.none,
                              labelStyle: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      last,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Theme.of(context).colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurface.withValues(
                        alpha: 0.38,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
