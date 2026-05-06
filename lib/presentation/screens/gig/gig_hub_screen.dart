import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/gig_category_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offers_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_requests_bloc.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_offer_tile.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_request_tile.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Which inline feed the Services hub is showing.
enum GigHubFeed { services, tasks }

/// Entry point into the gig economy module: a segmented switch flips between
/// a feed of all posted services ([GigOffer]s) and a feed of open tasks
/// ([GigRequest]s) so users can browse both in one place. Plus a quick link
/// into "My bookings".
///
/// Reachable from the main app via `context.pushGigHub()` (see
/// `gig_navigation.dart`) or as the Services tab in the bottom navigation
/// bar (rendered with [embedded] = true so it doesn't draw its own
/// [Scaffold]/[AppBar]).
class GigHubScreen extends StatelessWidget {
  const GigHubScreen({super.key, this.embedded = false});

  /// When true, the screen renders only its body content, suitable for use
  /// inside a tab host (e.g. `MainNavigation`) that already provides the
  /// surrounding [Scaffold] and [AppBar].
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    // Always wrap in fresh blocs so the feeds work whether the screen is
    // hosted in `MainNavigation` (embedded) or pushed standalone.
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              GigOffersBloc(getIt<IGigService>())..add(const FetchGigOffers()),
        ),
        BlocProvider(
          create: (_) => GigRequestsBloc(getIt<IGigService>())
            ..add(const FetchGigRequests()),
        ),
      ],
      child: _GigHubBody(embedded: embedded),
    );
  }
}

class _GigHubBody extends StatefulWidget {
  const _GigHubBody({required this.embedded});

  final bool embedded;

  @override
  State<_GigHubBody> createState() => _GigHubBodyState();
}

class _GigHubBodyState extends State<_GigHubBody> {
  final ScrollController _scrollController = ScrollController();
  GigHubFeed _feed = GigHubFeed.services;

  /// Single source of truth for the category filter applied to both feeds.
  /// `null` = "All", which corresponds to "no `category_id` query param".
  int? _selectedCategoryId;

  /// Category list comes from [GigCategoryCache] — a static, admin-ordered
  /// snapshot of `gig_categories` shipped with the app. Synchronous, so
  /// the chip ribbon renders on the first frame with no loading state.
  final List<GigCategory> _categories = GigCategoryCache.getOrdered();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      switch (_feed) {
        case GigHubFeed.services:
          context.read<GigOffersBloc>().add(const LoadMoreGigOffers());
        case GigHubFeed.tasks:
          context.read<GigRequestsBloc>().add(const LoadMoreGigRequests());
      }
    }
  }

  void _onFeedChanged(GigHubFeed next) {
    if (next == _feed) return;
    setState(() => _feed = next);
    // Jump back to the top when switching feeds so the user lands at the
    // start of the new list rather than at a stale offset.
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    // If the destination feed's bloc was loaded under a different category
    // (e.g. user changed category on the active feed but never visited the
    // other), refetch so it reflects the current filter.
    _ensureFeedMatchesSelectedCategory(next);
  }

  void _ensureFeedMatchesSelectedCategory(GigHubFeed feed) {
    switch (feed) {
      case GigHubFeed.services:
        final s = context.read<GigOffersBloc>().state;
        if (s is GigOffersLoaded && s.categoryId == _selectedCategoryId) {
          return;
        }
        context.read<GigOffersBloc>().add(
              FetchGigOffers(categoryId: _selectedCategoryId),
            );
      case GigHubFeed.tasks:
        final s = context.read<GigRequestsBloc>().state;
        if (s is GigRequestsLoaded && s.categoryId == _selectedCategoryId) {
          return;
        }
        context.read<GigRequestsBloc>().add(
              FetchGigRequests(categoryId: _selectedCategoryId),
            );
    }
  }

  void _onCategorySelected(int? categoryId) {
    if (categoryId == _selectedCategoryId) return;
    setState(() => _selectedCategoryId = categoryId);
    HapticFeedbackUtils.selection();
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    // Refetch the active feed immediately for instant feedback; the inactive
    // feed self-heals via [_ensureFeedMatchesSelectedCategory] when the user
    // switches to it.
    switch (_feed) {
      case GigHubFeed.services:
        context.read<GigOffersBloc>().add(
              FetchGigOffers(categoryId: categoryId),
            );
      case GigHubFeed.tasks:
        context.read<GigRequestsBloc>().add(
              FetchGigRequests(categoryId: categoryId),
            );
    }
  }

  Future<void> _onRefresh() async {
    switch (_feed) {
      case GigHubFeed.services:
        context.read<GigOffersBloc>().add(
              FetchGigOffers(
                refresh: true,
                categoryId: _selectedCategoryId,
              ),
            );
      case GigHubFeed.tasks:
        context.read<GigRequestsBloc>().add(
              FetchGigRequests(
                refresh: true,
                categoryId: _selectedCategoryId,
              ),
            );
    }
  }

  /// Empty-state icon: category glyph when a filter chip is selected, otherwise
  /// the generic feed icon ("All").
  IconData _emptyStateIcon({required IconData allFeedIcon}) {
    final id = _selectedCategoryId;
    if (id == null) {
      return allFeedIcon;
    }
    for (final c in _categories) {
      if (c.id == id) {
        return gigCategoryIcon(c.code);
      }
    }
    return allFeedIcon;
  }

  @override
  Widget build(BuildContext context) {
    // When hosted inside `MainNavigation`, the shell uses
    // `extendBodyBehindAppBar`, so this body would render under the app bar
    // unless we offset by the device top padding the same way other main
    // tabs (e.g. Favorites, Home) do.
    // Match [MessagesInboxScreen._buildTabbedConversationsList]: outer
    // `Padding(top: mainShellGlassExtraTopInset)` only — the first 8 px below
    // the shell header come from `EdgeInsets.fromLTRB(16, 8, 16, 12)` around
    // the toggle (not duplicated here).
    final topPad = widget.embedded
        ? ThemeState().mainShellGlassExtraTopInset(context)
        : 16.0;

    final body = ListenableBuilder(
      listenable: AuthenticationState(),
      builder: (context, _) {
        final signedIn = AuthenticationState().isAuthenticated;
        final bottomClearance = signedIn ? 96.0 : 16.0;

        final scrollable = UydoshRefreshIndicator.mainShell(
          onRefresh: _onRefresh,
          edgeOffset: topPad,
          child: PullToRefreshStretchHaptics(
            child: CustomScrollView(
              controller: _scrollController,
              // Allow pull-to-refresh even when the body is short / empty.
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Pinned header keeps the feed switch + category ribbon visible
                // while the underlying list scrolls, so users can change feed or
                // category without scrolling back to the top first.
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _GigHubPinnedHeaderDelegate(
                    topPadding: topPad,
                    feed: _feed,
                    onFeedChanged: _onFeedChanged,
                    categories: _categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: _onCategorySelected,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
                ..._buildFeedSlivers(context, bottomClearance),
                // Bottom padding scaled so the last feed item clears the floating
                // "My bookings" FAB without being covered by it (signed-in only).
                SliverPadding(
                  padding: EdgeInsets.only(bottom: bottomClearance),
                ),
              ],
            ),
          ),
        );

        // Place the FAB ourselves (instead of using `Scaffold.floatingActionButton`)
        // so it works identically whether the screen is embedded inside the
        // tab host's `Scaffold` or pushed standalone.
        return Stack(
          children: [
            Positioned.fill(child: scrollable),
            if (signedIn)
              Positioned(
                right: 16,
                bottom: 16,
                child: _MyBookingsFab(),
              ),
          ],
        );
      },
    );

    if (widget.embedded) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(L10n.get("gigs_hub_title")),
      ),
      body: body,
    );
  }

  List<Widget> _buildFeedSlivers(
    BuildContext context,
    double bottomClearanceForFab,
  ) {
    switch (_feed) {
      case GigHubFeed.services:
        return _servicesFeedSlivers(bottomClearanceForFab);
      case GigHubFeed.tasks:
        return _tasksFeedSlivers(bottomClearanceForFab);
    }
  }

  List<Widget> _servicesFeedSlivers(double bottomClearanceForFab) {
    return [
      BlocBuilder<GigOffersBloc, GigOffersState>(
        builder: (context, state) {
          if (state is GigOffersLoading || state is GigOffersInitial) {
            return const _LoadingSliver();
          }
          if (state is GigOffersError) {
            return _ErrorSliver(
              message: state.message,
              onRetry: () =>
                  context.read<GigOffersBloc>().add(const FetchGigOffers()),
            );
          }
          if (state is GigOffersLoaded) {
            if (state.offers.isEmpty) {
              return _EmptySliver(
                icon: _emptyStateIcon(allFeedIcon: Icons.handyman_outlined),
                message: L10n.get("gigs_browse_empty"),
                bottomPadding: bottomClearanceForFab,
              );
            }
            final itemCount =
                state.offers.length + (state.hasMore ? 1 : 0);
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList.separated(
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= state.offers.length) {
                    return const _LoadingMoreFooter();
                  }
                  return GigOfferTile(offer: state.offers[i]);
                },
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }

  List<Widget> _tasksFeedSlivers(double bottomClearanceForFab) {
    return [
      BlocBuilder<GigRequestsBloc, GigRequestsState>(
        builder: (context, state) {
          if (state is GigRequestsLoading || state is GigRequestsInitial) {
            return const _LoadingSliver();
          }
          if (state is GigRequestsError) {
            return _ErrorSliver(
              message: state.message,
              onRetry: () => context
                  .read<GigRequestsBloc>()
                  .add(const FetchGigRequests()),
            );
          }
          if (state is GigRequestsLoaded) {
            if (state.requests.isEmpty) {
              return _EmptySliver(
                icon: _emptyStateIcon(allFeedIcon: Icons.assignment_outlined),
                message: L10n.get("gigs_requests_empty"),
                bottomPadding: bottomClearanceForFab,
              );
            }
            final itemCount =
                state.requests.length + (state.hasMore ? 1 : 0);
            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              sliver: SliverList.separated(
                itemCount: itemCount,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= state.requests.length) {
                    return const _LoadingMoreFooter();
                  }
                  return GigRequestTile(request: state.requests[i]);
                },
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    ];
  }
}

/// Pinned header at the top of [GigHubScreen]: stacks the feed segmented
/// switch (Services / Tasks) above the horizontally scrollable category
/// ribbon. Painted on top of the scaffold background so feed items
/// scrolling underneath don't bleed through.
class _GigHubPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  _GigHubPinnedHeaderDelegate({
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

  /// Segmented switch height (matches [NeumorphicSegmentedSwitch] default and
  /// [MessagesInboxScreen] toggle).
  static const double _switchHeight = 48;

  /// Vertical padding around the primary toggle (matches messages inbox).
  static const double _togglePadTop = 8;
  static const double _togglePadBottom = 12;

  /// Total height of the toggle row including inbox-style vertical margins.
  static const double _toggleSectionHeight =
      _togglePadTop + _switchHeight + _togglePadBottom;

  /// Height of the category ribbon (mirrors [_CategoryRibbon._ribbonHeight]).
  static const double _ribbonHeight = 56;

  /// Spacing below the ribbon, before the first feed item.
  static const double _ribbonBottomGap = 12;

  double get _height =>
      topPadding +
      _toggleSectionHeight +
      _ribbonHeight +
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
                final switchWidget = NeumorphicSegmentedSwitch<GigHubFeed>(
                  height: _switchHeight,
                  value: feed,
                  onChanged: onFeedChanged,
                  entries: [
                    SegmentedSwitchEntry(
                      value: GigHubFeed.services,
                      label: L10n.get("gigs_hub_feed_services"),
                      icon: Icons.handyman_outlined,
                    ),
                    SegmentedSwitchEntry(
                      value: GigHubFeed.tasks,
                      label: L10n.get("gigs_hub_feed_tasks"),
                      icon: Icons.assignment_outlined,
                    ),
                  ],
                );

                if (!(themeState.isBlueTheme || themeState.isLightTheme)) {
                  return switchWidget;
                }

                const radius = BorderRadius.all(Radius.circular(20));
                final isDark = Theme.of(context).brightness == Brightness.dark;
                final scheme = Theme.of(context).colorScheme;
                final baseTint =
                    isDark ? BlueThemeColors.background : scheme.surface;
                final disableAnimations =
                    MediaQuery.maybeOf(context)?.disableAnimations ?? false;
                final enableGlass =
                    AnimationSettingsState().uiAnimationsEnabled &&
                        !disableAnimations;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: radius,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: enableGlass ? 18 : 0,
                                  sigmaY: enableGlass ? 18 : 0,
                                ),
                                child: const SizedBox.expand(),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: radius,
                                color: baseTint.withValues(
                                  alpha: isDark ? 0.10 : 0.12,
                                ),
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    switchWidget,
                  ],
                );
              },
            ),
          ),
          _CategoryRibbon(
            categories: categories,
            selectedCategoryId: selectedCategoryId,
            onSelected: onCategorySelected,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_GigHubPinnedHeaderDelegate oldDelegate) {
    return topPadding != oldDelegate.topPadding ||
        feed != oldDelegate.feed ||
        selectedCategoryId != oldDelegate.selectedCategoryId ||
        backgroundColor != oldDelegate.backgroundColor ||
        !identical(categories, oldDelegate.categories);
  }
}

/// Horizontally scrollable ribbon of category filter chips. The first chip
/// is "All" (no filter); subsequent chips show each [GigCategory] with its
/// glyph from [gigCategoryIcon].
///
/// Categories come from [GigCategoryCache] (a static, admin-ordered list
/// baked into the app), so the ribbon renders synchronously on the first
/// frame with no loading state.
class _CategoryRibbon extends StatelessWidget {
  const _CategoryRibbon({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final List<GigCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  /// Tall enough to seat a 36-px chip (`vertical: 8` × 2 + ~20 line height)
  /// plus 8 px of vertical breathing room above and below so shadows from
  /// the active chip don't get clipped by the host viewport.
  static const double _ribbonHeight = 56;
  static const double _chipPadV = 8;

  @override
  Widget build(BuildContext context) {
    final language = LanguageState().currentLanguage;
    return SizedBox(
      height: _ribbonHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Default `Clip.hardEdge` slices the active chip's drop shadow
        // (and even the anti-aliased edge of the rounded corners) at
        // the viewport bounds. The ribbon is only as tall as the chip
        // plus a few px of vertical padding, so we let children draw
        // outside the listview bounds and rely on the host scroll
        // view to clip at a safer outer boundary.
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(16, _chipPadV, 16, _chipPadV),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _CategoryChip(
              icon: Icons.apps_rounded,
              label: L10n.get("all"),
              isSelected: selectedCategoryId == null,
              onTap: () => onSelected(null),
            );
          }
          final c = categories[i - 1];
          return _CategoryChip(
            icon: gigCategoryIcon(c.code),
            label: c.localizedName(language),
            isSelected: selectedCategoryId == c.id,
            onTap: () => onSelected(c.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        // Match [NeumorphicSegmentedSwitch] colors so chip selection reads as
        // the same affordance: `primaryColor` thumb on `cardColor` ground,
        // with text color picked by background brightness.
        final activeBg = themeState.primaryColor;
        final inactiveBg = themeState.cardColor;
        final activeFg =
            ThemeData.estimateBrightnessForColor(activeBg) == Brightness.dark
                ? Colors.white
                : Colors.black;
        final inactiveFg = themeState.unselectedTabTextColor;
        final radius = const BorderRadius.all(Radius.circular(22));

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedbackUtils.selection();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: ThreeDSurfaceStyle.surfaceGradient(
                context,
                isSelected ? activeBg : inactiveBg,
              ),
              boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? activeFg
                      : inactiveFg.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? activeFg
                        : inactiveFg.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Extended pill FAB styled to match [SearchFloatingActionButton]: liquid-glass
/// plate on blue/light themes, neumorphic [ThreeDSurfaceStyle] elsewhere.
class _MyBookingsFab extends StatefulWidget {
  @override
  State<_MyBookingsFab> createState() => _MyBookingsFabState();
}

class _MyBookingsFabState extends State<_MyBookingsFab> {
  static const double _height = 56.0;

  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  void _onTap() {
    HapticFeedbackUtils.lightImpact();
    context.pushMyGigBookings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final useLiquidGlass = themeState.isBlueTheme || themeState.isLightTheme;
    final fg = themeState.isBlueTheme ? Colors.white : Colors.black;
    final base = theme.colorScheme.surface;
    final radius = const BorderRadius.all(Radius.circular(999));
    final label = L10n.get("gigs_hub_my_bookings_title");

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note_rounded, color: fg, size: 22),
          const SizedBox(width: 10),
          Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final liquidBody = SizedBox(
      height: _height,
      child: LiquidGlassPlate(
        height: _height,
        borderRadius: radius,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: _onTap,
          child: Center(child: content),
        ),
      ),
    );

    final shadows = _pressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);

    final legacyBody = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        onTap: _onTap,
        onHighlightChanged: _setPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: _height,
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: shadows,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          child: useLiquidGlass ? liquidBody : legacyBody,
        ),
      ),
    );
  }
}

class _LoadingSliver extends StatelessWidget {
  const _LoadingSliver();

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: HouseLoadingIndicator()),
      ),
    );
  }
}

class _LoadingMoreFooter extends StatelessWidget {
  const _LoadingMoreFooter();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: HouseLoadingIndicator()),
    );
  }
}

class _EmptySliver extends StatelessWidget {
  const _EmptySliver({
    required this.icon,
    required this.message,
    required this.bottomPadding,
  });

  final IconData icon;
  final String message;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    // Fill the rest of the viewport so the column's `Center` can vertically
    // center it between the category ribbon and the bottom of the screen,
    // rather than parking it just below the ribbon. Bottom padding keeps the
    // text from sitting under the floating "My bookings" pill when signed in.
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: UydoshEmptyColumn(icon: icon, title: message),
      ),
    );
  }
}

class _ErrorSliver extends StatelessWidget {
  const _ErrorSliver({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButtonFactory.text(
              onPressed: onRetry,
              text: L10n.get("gigs_retry"),
            ),
          ],
        ),
      ),
    );
  }
}
