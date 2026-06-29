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

enum MyHubCategory { groups, listings, favorites, alerts }

class MyHubScreen extends StatefulWidget {
  const MyHubScreen({
    super.key,
    this.embedded = false,
    this.tabVisible = true,
    this.initialCategory,
  });

  final bool embedded;
  final bool tabVisible;
  final MyHubCategory? initialCategory;

  @override
  State<MyHubScreen> createState() => MyHubScreenState();
}

class MyHubScreenState extends State<MyHubScreen>
    with SingleTickerProviderStateMixin {
  static const _visibleTabs = _MyHubTabSpec.tabs;

  late TabController _tabController;

  static int indexForCategory(MyHubCategory category) {
    final index = _visibleTabs.indexWhere((tab) => tab.id == category);
    return index >= 0 ? index : 0;
  }

  void selectCategory(MyHubCategory category) {
    final index = indexForCategory(category);
    if (_tabController.index == index) return;
    _tabController.animateTo(index);
  }

  @override
  void initState() {
    super.initState();
    final initialIndex = indexForCategory(
      widget.initialCategory ?? MyHubCategory.groups,
    );
    _tabController = TabController(
      length: _visibleTabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
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

  /// Status-bar inset when embedded under [MainNavigation]'s glass app bar.
  /// Standalone routes use their own [Scaffold.appBar] (no extra top pad).
  double _shellHeaderClearance(BuildContext context) {
    if (!widget.embedded) return 0;
    return ThemeState().mainShellGlassExtraTopInset(context);
  }

  Widget _buildTabView(_MyHubTabSpec tab, int index) {
    switch (tab.id) {
      case MyHubCategory.groups:
        return const MyGroupsScreen(embedded: true);
      case MyHubCategory.listings:
        return const UserListingsScreen(embedded: true);
      case MyHubCategory.favorites:
        return FavoritesScreen(
          embedded: true,
          tabVisible: widget.tabVisible && _tabController.index == index,
        );
      case MyHubCategory.alerts:
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

        final content = Padding(
          padding: EdgeInsets.only(top: _shellHeaderClearance(context)),
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

        if (widget.embedded) {
          return content;
        }

        return Scaffold(
          backgroundColor: ThemeState().backgroundColor,
          appBar: AppBar(
            title: L10n.text("nav_my"),
          ),
          body: content,
        );
      },
    );
  }
}

class _MyHubTabSpec {
  const _MyHubTabSpec({
    required this.id,
    required this.icon,
    required this.labelKey,
    this.useIconBadge = true,
  });

  final MyHubCategory id;
  final IconData icon;
  final String labelKey;
  final bool useIconBadge;

  static const tabs = [
    _MyHubTabSpec(
      id: MyHubCategory.groups,
      icon: Icons.groups_outlined,
      labelKey: "my_hub_tab_groups",
      useIconBadge: false,
    ),
    _MyHubTabSpec(
      id: MyHubCategory.listings,
      icon: Icons.list_alt,
      labelKey: "menu_my_listings",
    ),
    _MyHubTabSpec(
      id: MyHubCategory.favorites,
      icon: Icons.favorite_border,
      labelKey: "menu_favorites",
    ),
    _MyHubTabSpec(
      id: MyHubCategory.alerts,
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

  void _scrollSelectionToVisible() {
    if (!mounted) return;
    final ctx = _itemKeys[_selectedIndex].currentContext;
    if (ctx == null) return;
    final disableMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
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
        .addPostFrameCallback((_) => _scrollSelectionToVisible());
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
        .addPostFrameCallback((_) => _scrollSelectionToVisible());
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
        .addPostFrameCallback((_) => _scrollSelectionToVisible());
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
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
