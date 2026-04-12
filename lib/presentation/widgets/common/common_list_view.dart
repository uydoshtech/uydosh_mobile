import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";

class CommonListView extends StatelessWidget {
  /// Use [children] for small pre-built lists (e.g. loading skeletons).
  /// Use [itemCount] + [itemBuilder] for lazy loading of large lists.
  const CommonListView({
    this.children,
    this.itemCount,
    this.itemBuilder,
    super.key,
    this.controller,
    this.padding,
    this.showRefreshIndicator = false,
    this.onRefresh,
    this.showLoadMoreIndicator = false,
    this.loadMoreIndicator,
    this.hasMore = false,
    this.onLoadMore,
    this.itemSpacing,
    this.itemPadding,
    this.itemExtent,
    this.semanticChildCount,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.physics,
    this.primary,
    this.shrinkWrap = false,
    this.cacheExtent = 200.0,
    this.reverse = false,
  }) : assert(
         (children != null) != (itemBuilder != null && itemCount != null),
         "Provide either children or both itemCount and itemBuilder",
       );

  final List<Widget>? children;
  final int? itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;
  final ScrollController? controller;
  final EdgeInsets? padding;
  final bool showRefreshIndicator;
  final Future<void> Function()? onRefresh;
  final bool showLoadMoreIndicator;
  final Widget? loadMoreIndicator;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final double? itemSpacing;
  final EdgeInsets? itemPadding;
  final double? itemExtent;
  final int? semanticChildCount;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollPhysics? physics;
  final bool? primary;
  final bool shrinkWrap;
  final double cacheExtent;
  final bool reverse;

  bool get _useLazyBuilder => itemBuilder != null && itemCount != null;

  int get _contentItemCount =>
      _useLazyBuilder ? itemCount! : children!.length;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.all(16.0);
    final effectiveItemSpacing = itemSpacing ?? 16.0;
    final effectiveItemPadding = itemPadding ?? EdgeInsets.zero;
    final effectiveCacheExtent = cacheExtent;
    final contentCount = _contentItemCount;
    final totalCount =
        contentCount + (showLoadMoreIndicator && hasMore ? 1 : 0);

    final Widget listView = ListView.builder(
      controller: controller,
      padding: effectivePadding,
      itemCount: totalCount,
      addAutomaticKeepAlives: false, // Prevents keeping off-screen items alive
      addRepaintBoundaries: true, // Isolate repaints for better scroll performance
      cacheExtent: effectiveCacheExtent, // Keep items in memory
      itemExtent: itemExtent, // Fixed height for better performance
      semanticChildCount: semanticChildCount ?? contentCount,
      keyboardDismissBehavior: keyboardDismissBehavior,
      physics: physics,
      primary: primary,
      shrinkWrap: shrinkWrap,
      reverse: reverse,
      itemBuilder: (context, index) {
        // Early return for load more indicator to avoid unnecessary processing
        if (index == contentCount && showLoadMoreIndicator && hasMore) {
          return _buildLoadMoreIndicator(
            effectiveItemSpacing,
            effectivePadding,
          );
        }

        final child = _useLazyBuilder
            ? itemBuilder!(context, index)
            : children![index];

        // Early return if no padding or spacing needed
        if (effectiveItemPadding == EdgeInsets.zero &&
            effectiveItemSpacing == 0) {
          return child;
        }

        return _buildListItem(
          child,
          index,
          contentCount,
          effectiveItemSpacing,
          effectiveItemPadding,
        );
      },
    );

    if (showRefreshIndicator && onRefresh != null) {
      return UydoshRefreshIndicator(onRefresh: onRefresh!, child: listView);
    }

    return listView;
  }

  Widget _buildLoadMoreIndicator(double itemSpacing, EdgeInsets padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: itemSpacing,
        bottom:
            padding.bottom +
            32.0, // Add extra 32px padding below the house loader
      ),
      child: Center(
        child: loadMoreIndicator ?? _buildDefaultLoadMoreIndicator(),
      ),
    );
  }

  Widget _buildListItem(
    Widget child,
    int index,
    int contentCount,
    double itemSpacing,
    EdgeInsets itemPadding,
  ) {
    final spacing = index < contentCount - 1 ? itemSpacing : 0.0;
    final edgePadding = reverse
        ? EdgeInsets.only(top: spacing)
        : EdgeInsets.only(bottom: spacing);
    return Padding(
      padding: edgePadding.add(itemPadding),
      child: child,
    );
  }

  Widget _buildDefaultLoadMoreIndicator() {
    return const CenteredHouseLoadingIndicator();
  }
}
