import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

class MyGroupBookmarksScreen extends StatefulWidget {
  const MyGroupBookmarksScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MyGroupBookmarksScreen> createState() => _MyGroupBookmarksScreenState();
}

class _MyGroupBookmarksScreenState extends State<MyGroupBookmarksScreen> {
  static const int _conversationLimit = 100;

  bool _loading = true;
  String? _errorMessage;
  List<_GroupBookmarkRow> _rows = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final conversations = await getIt<IMessagingService>().getConversations(
        limit: _conversationLimit,
      );
      final groups = conversations.data
          .where((c) => c.contextType?.trim().toLowerCase() == "listing_group")
          .where((c) => c.listingId != null)
          .toList(growable: false);

      final rows = <_GroupBookmarkRow>[];
      for (final group in groups) {
        final groupListingId = group.listingId;
        if (groupListingId == null) continue;

        final items = await getIt<IListingGroupService>().listShortlist(
          groupListingId: groupListingId,
        );
        GroupShortlistState().setShortlistCountForGroup(
          groupListingId,
          items.length,
        );
        for (final item in items) {
          final listingJson = item.listingJson;
          if (listingJson == null) continue;
          try {
            rows.add(
              _GroupBookmarkRow(
                group: group,
                item: item,
                listing: Listing.fromJson(listingJson),
              ),
            );
          } catch (_) {}
        }
      }

      rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (!mounted) return;
      setState(() {
        _rows = rows;
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

  Future<void> _openListing(_GroupBookmarkRow row) async {
    HapticFeedbackUtils.impact();
    await context.pushListingDetail(
      row.listing.id,
      groupHousingContextListingId: row.groupListingId,
    );
  }

  Future<void> _remove(_GroupBookmarkRow row) async {
    try {
      await getIt<IListingGroupService>().removeFromShortlist(
        groupListingId: row.groupListingId,
        housingListingId: row.listing.id,
      );
      GroupShortlistState().seedShortlisted(
        groupListingId: row.groupListingId,
        housingListingId: row.listing.id,
        isShortlisted: false,
      );
      unawaited(GroupShortlistState().refreshCount(row.groupListingId));
      if (!mounted) return;
      setState(() {
        _rows = _rows
            .where(
              (candidate) =>
                  candidate.groupListingId != row.groupListingId ||
                  candidate.listing.id != row.listing.id,
            )
            .toList(growable: false);
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_shortlist_removed"),
      );
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(context, message: L10n.get("error_generic"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final body = ColoredBox(
          color: themeState.backgroundColor,
          child: _buildBody(),
        );

        if (widget.embedded) return body;

        return Scaffold(
          backgroundColor: themeState.backgroundColor,
          appBar: CommonAppBar(
            title: L10n.get("my_hub_tab_bookmarks"),
            showBackButton: true,
          ),
          body: body,
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
        onRetry: _load,
      );
    }

    if (_rows.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: UydoshEmptyColumn(
          icon: Icons.bookmark_border,
          title: L10n.get("group_shortlist_empty_title"),
          subtitle: L10n.get("group_shortlist_empty_subtitle"),
          fillViewportForRefresh: true,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: _rows.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final row = _rows[index];
          return ListingTile(
            key: ValueKey(
              "group-bookmark-${row.groupListingId}-${row.listing.id}",
            ),
            listing: row.listing,
            showHeartIcon: false,
            footerContent: _GroupBookmarkFooter(row: row),
            trailingAction: IconButton(
              tooltip: L10n.get("group_shortlist_remove"),
              onPressed: () => _remove(row),
              icon: const Icon(Icons.bookmark_remove_outlined),
            ),
            onTap: () => _openListing(row),
          );
        },
      ),
    );
  }
}

class _GroupBookmarkFooter extends StatelessWidget {
  const _GroupBookmarkFooter({required this.row});

  final _GroupBookmarkRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Icon(
            Icons.groups_outlined,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              L10n.getWithParams(
                "group_shortlist_saved_for_group",
                params: {"name": row.groupLabel},
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupBookmarkRow {
  const _GroupBookmarkRow({
    required this.group,
    required this.item,
    required this.listing,
  });

  final ConversationSummary group;
  final ListingGroupShortlistItem item;
  final Listing listing;

  int get groupListingId => item.groupListingId;

  DateTime get createdAt =>
      DateTime.tryParse(item.createdAt) ??
      DateTime.fromMillisecondsSinceEpoch(0);

  String get groupLabel {
    final title = group.listingTitle?.trim();
    if (title != null && title.isNotEmpty) return title;
    return "#$groupListingId";
  }
}
