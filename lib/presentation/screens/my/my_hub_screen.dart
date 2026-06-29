import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/favorites/favorites_screen.dart";
import "package:uy_dosh/presentation/screens/group_housing/my_groups_screen.dart";
import "package:uy_dosh/presentation/screens/profile/notifications_screen.dart";
import "package:uy_dosh/presentation/screens/user_listings/user_listings_screen.dart";
import "package:uy_dosh/presentation/widgets/common/auth_required_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class MyHubScreen extends StatefulWidget {
  const MyHubScreen({
    super.key,
    this.embedded = false,
    this.tabVisible = true,
  });

  final bool embedded;
  final bool tabVisible;

  @override
  State<MyHubScreen> createState() => _MyHubScreenState();
}

class _MyHubScreenState extends State<MyHubScreen>
    with SingleTickerProviderStateMixin {
  static const _visibleTabs = _MyHubTabSpec.tabs;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _visibleTabs.length, vsync: this);
    _tabController.addListener(_handleTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildTabView(_MyHubTabSpec tab, int index) {
    switch (tab.id) {
      case _MyHubTabId.groups:
        return const MyGroupsScreen(embedded: true);
      case _MyHubTabId.listings:
        return const UserListingsScreen(embedded: true);
      case _MyHubTabId.favorites:
        return FavoritesScreen(
          embedded: true,
          tabVisible: widget.tabVisible && _tabController.index == index,
        );
      case _MyHubTabId.alerts:
        return const NotificationsScreen(embedded: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthenticationState(),
      builder: (context, _) {
        if (!AuthenticationState().isAuthenticated) {
          return AuthRequiredState(
            onLogin: () => context.pushReplaceAuthWizard(),
          );
        }

        final themeState = ThemeState();
        final topPadding = widget.embedded
            ? themeState.mainShellGlassExtraTopInset(context)
            : 0.0;

        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListenableBuilder(
                listenable: LanguageState(),
                builder: (context, _) {
                  return AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      return _MyHubTabRibbon(
                        tabController: _tabController,
                        tabs: _visibleTabs,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 6),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    for (final (index, tab) in _visibleTabs.indexed)
                      _buildTabView(tab, index),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _MyHubTabId { groups, listings, favorites, alerts }

class _MyHubTabSpec {
  const _MyHubTabSpec({
    required this.id,
    required this.icon,
    required this.labelKey,
    this.useIconBadge = true,
  });

  final _MyHubTabId id;
  final IconData icon;
  final String labelKey;
  final bool useIconBadge;

  static const tabs = [
    _MyHubTabSpec(
      id: _MyHubTabId.groups,
      icon: Icons.groups_outlined,
      labelKey: "my_hub_tab_groups",
      useIconBadge: false,
    ),
    _MyHubTabSpec(
      id: _MyHubTabId.listings,
      icon: Icons.list_alt,
      labelKey: "menu_my_listings",
    ),
    _MyHubTabSpec(
      id: _MyHubTabId.favorites,
      icon: Icons.favorite_border,
      labelKey: "menu_favorites",
    ),
    _MyHubTabSpec(
      id: _MyHubTabId.alerts,
      icon: Icons.notifications_none,
      labelKey: "my_hub_tab_alerts",
    ),
  ];
}

class _MyHubTabRibbon extends StatefulWidget {
  const _MyHubTabRibbon({
    required this.tabController,
    required this.tabs,
  });

  final TabController tabController;
  final List<_MyHubTabSpec> tabs;

  @override
  State<_MyHubTabRibbon> createState() => _MyHubTabRibbonState();
}

class _MyHubTabRibbonState extends State<_MyHubTabRibbon> {
  late List<GlobalKey> _itemKeys;
  late int _lastIndex;

  static const double _ribbonHeight = 44;
  static const double _chipPadTop = 8;
  static const double _chipPadBottom = 4;

  int get _selectedIndex =>
      widget.tabController.index.clamp(0, widget.tabs.length - 1);

  void _scrollSelectionToCenter() {
    if (!mounted) return;
    final ctx = _itemKeys[_selectedIndex].currentContext;
    if (ctx == null) return;
    final disableMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration:
          disableMotion ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _handleTabControllerChanged() {
    final index = _selectedIndex;
    if (index == _lastIndex) return;
    _lastIndex = index;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollSelectionToCenter());
  }

  @override
  void initState() {
    super.initState();
    _itemKeys = List<GlobalKey>.generate(
      widget.tabs.length,
      (_) => GlobalKey(),
    );
    _lastIndex = _selectedIndex;
    widget.tabController.addListener(_handleTabControllerChanged);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollSelectionToCenter());
  }

  @override
  void didUpdateWidget(covariant _MyHubTabRibbon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabs.length != oldWidget.tabs.length) {
      _itemKeys = List<GlobalKey>.generate(
        widget.tabs.length,
        (_) => GlobalKey(),
      );
    }
    if (widget.tabController == oldWidget.tabController) return;
    oldWidget.tabController.removeListener(_handleTabControllerChanged);
    _lastIndex = _selectedIndex;
    widget.tabController.addListener(_handleTabControllerChanged);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollSelectionToCenter());
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_handleTabControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final idx = _selectedIndex;

    return SizedBox(
      height: _ribbonHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          _chipPadTop,
          16,
          _chipPadBottom,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < widget.tabs.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _MyHubPillTabChip(
                        key: _itemKeys[i],
                        icon: widget.tabs[i].icon,
                        label: L10n.get(widget.tabs[i].labelKey),
                        iconBadgeDimension: 28.6,
                        iconSize: 20,
                        useIconBadge: widget.tabs[i].useIconBadge,
                        isSelected: idx == i,
                        onTap: () {
                          if (widget.tabController.index != i) {
                            widget.tabController.animateTo(i);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MyHubPillTabChip extends StatelessWidget {
  const _MyHubPillTabChip({
    required this.icon,
    required this.label,
    required this.iconBadgeDimension,
    required this.iconSize,
    required this.useIconBadge,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final double iconBadgeDimension;
  final double iconSize;
  final bool useIconBadge;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final activeBg = themeState.primaryColor;
        final inactiveBg = themeState.cardColor;
        final activeFg =
            ThemeData.estimateBrightnessForColor(activeBg) == Brightness.dark
                ? Colors.white
                : Colors.black;
        final inactiveFg = themeState.unselectedTabTextColor;
        final radius = const BorderRadius.all(Radius.circular(22));
        final selectedIconBadgeBg = themeState.isLightTheme
            ? Colors.black
            : activeFg.withValues(alpha: 0.16);
        final selectedIconColor =
            themeState.isLightTheme ? Colors.white : activeFg;
        final iconColor =
            isSelected ? selectedIconColor : inactiveFg.withValues(alpha: 0.85);
        final labelStyle = TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          color: isSelected ? activeFg : inactiveFg.withValues(alpha: 0.9),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            UiFeedbackUtils.selection();
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (useIconBadge)
                  GigCategoryIconBadge(
                    icon: icon,
                    iconColor: iconColor,
                    badgeBackgroundColor: isSelected
                        ? selectedIconBadgeBg
                        : inactiveFg.withValues(alpha: 0.12),
                    borderWidth: 0,
                    dimension: iconBadgeDimension,
                    iconSize: iconSize,
                  )
                else
                  SizedBox.square(
                    dimension: iconBadgeDimension,
                    child: Center(
                      child: Icon(icon, size: iconSize, color: iconColor),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(label, style: labelStyle),
              ],
            ),
          ),
        );
      },
    );
  }
}
