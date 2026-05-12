import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/screens/gig/gig_hub_category_ribbon.dart";
import "package:uy_dosh/presentation/screens/gig/gig_hub_feed.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";

/// Pinned header at the top of [GigHubScreen]: stacks the feed segmented
/// switch (Services / Tasks) above the horizontally scrollable category
/// ribbon.
class GigHubPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  GigHubPinnedHeaderDelegate({
    required this.topPadding,
    required this.feed,
    required this.onFeedChanged,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.backgroundColor,
  });

  final double topPadding;
  final GigHubFeed feed;
  final ValueChanged<GigHubFeed> onFeedChanged;
  final List<GigCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;
  final Color backgroundColor;

  static const double _switchHeight = 135 * 60 / 145;

  static const double _togglePadTop = 8;
  static const double _togglePadBottom = 8;

  static const double _toggleSectionHeight =
      _togglePadTop + _switchHeight + _togglePadBottom;

  static const double _ribbonBottomGap = 12;

  double get _height =>
      topPadding +
      _toggleSectionHeight +
      GigHubCategoryRibbon.ribbonHeight +
      _ribbonBottomGap;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.only(top: topPadding, bottom: _ribbonBottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              _togglePadTop,
              16,
              _togglePadBottom,
            ),
            child: ListenableBuilder(
              listenable: ThemeState(),
              builder: (context, _) {
                final themeState = ThemeState();
                return NeumorphicSegmentedSwitch<GigHubFeed>(
                  liquidGlass:
                      themeState.isBlueTheme || themeState.isLightTheme,
                  height: _switchHeight,
                  value: feed,
                  onChanged: onFeedChanged,
                  entries: [
                    SegmentedSwitchEntry(
                      value: GigHubFeed.services,
                      label: L10n.get("gigs_hub_feed_services"),
                      subtitle: L10n.get("gigs_publish_mode_service_subtitle"),
                      icon: Icons.handyman_outlined,
                    ),
                    SegmentedSwitchEntry(
                      value: GigHubFeed.tasks,
                      label: L10n.get("gigs_hub_feed_tasks"),
                      subtitle: L10n.get("gigs_publish_mode_task_subtitle"),
                      icon: Icons.assignment_outlined,
                    ),
                  ],
                );
              },
            ),
          ),
          GigHubCategoryRibbon(
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            onSelected: onCategorySelected,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(GigHubPinnedHeaderDelegate oldDelegate) {
    return topPadding != oldDelegate.topPadding ||
        feed != oldDelegate.feed ||
        selectedCategoryId != oldDelegate.selectedCategoryId ||
        backgroundColor != oldDelegate.backgroundColor ||
        !identical(categories, oldDelegate.categories);
  }
}
