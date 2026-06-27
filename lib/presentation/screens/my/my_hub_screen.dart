import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/favorites/favorites_screen.dart";
import "package:uy_dosh/presentation/screens/group_housing/my_group_bookmarks_screen.dart";
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
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
                      return _MyHubTabRibbon(tabController: _tabController);
                    },
                  );
                },
              ),
              const SizedBox(height: 6),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const MyGroupsScreen(embedded: true),
                    const UserListingsScreen(embedded: true),
                    const MyGroupBookmarksScreen(embedded: true),
                    FavoritesScreen(
                      embedded: true,
                      tabVisible:
                          widget.tabVisible && _tabController.index == 3,
                    ),
                    const NotificationsScreen(embedded: true),
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

class _MyHubTabSpec {
  const _MyHubTabSpec({
    required this.icon,
    required this.labelKey,
    this.iconBadgeDimension = 28.6,
    this.iconBorderColor,
    this.iconSize = 20,
    this.useIconBadge = true,
  });

  final IconData icon;
  final String labelKey;
  final double iconBadgeDimension;
  final Color? iconBorderColor;
  final double iconSize;
  final bool useIconBadge;
}

class _MyHubTabRibbon extends StatefulWidget {
  const _MyHubTabRibbon({required this.tabController});

  final TabController tabController;

  @override
  State<_MyHubTabRibbon> createState() => _MyHubTabRibbonState();
}

class _MyHubTabRibbonState extends State<_MyHubTabRibbon> {
  late final List<GlobalKey> _itemKeys;
  late int _lastIndex;

  static const double _ribbonHeight = 44;
  static const double _chipPadTop = 8;
  static const double _chipPadBottom = 4;

  static const _tabs = <_MyHubTabSpec>[
    _MyHubTabSpec(
      icon: Icons.groups_outlined,
      labelKey: "my_hub_tab_groups",
      useIconBadge: false,
    ),
    _MyHubTabSpec(icon: Icons.list_alt, labelKey: "menu_my_listings"),
    _MyHubTabSpec(
      icon: Icons.bookmark_border,
      labelKey: "my_hub_tab_bookmarks",
    ),
    _MyHubTabSpec(icon: Icons.favorite_border, labelKey: "menu_favorites"),
    _MyHubTabSpec(
      icon: Icons.notifications_none,
      labelKey: "my_hub_tab_alerts",
    ),
  ];

  int get _selectedIndex =>
      widget.tabController.index.clamp(0, _tabs.length - 1);

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
    _itemKeys = List<GlobalKey>.generate(_tabs.length, (_) => GlobalKey());
    _lastIndex = _selectedIndex;
    widget.tabController.addListener(_handleTabControllerChanged);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollSelectionToCenter());
  }

  @override
  void didUpdateWidget(covariant _MyHubTabRibbon oldWidget) {
    super.didUpdateWidget(oldWidget);
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
                    for (var i = 0; i < _tabs.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _MyHubPillTabChip(
                        key: _itemKeys[i],
                        icon: _tabs[i].icon,
                        label: L10n.get(_tabs[i].labelKey),
                        iconBadgeDimension: _tabs[i].iconBadgeDimension,
                        iconBorderColor: _tabs[i].iconBorderColor,
                        iconSize: _tabs[i].iconSize,
                        useIconBadge: _tabs[i].useIconBadge,
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
    this.iconBorderColor,
    super.key,
  });

  final IconData icon;
  final String label;
  final double iconBadgeDimension;
  final Color? iconBorderColor;
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
                    borderColor: iconBorderColor,
                    borderWidth: iconBorderColor == null ? 0 : 1.4,
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
