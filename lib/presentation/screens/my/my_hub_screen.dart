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
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                    FavoritesScreen(
                      embedded: true,
                      tabVisible:
                          widget.tabVisible && _tabController.index == 2,
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
  });

  final IconData icon;
  final String labelKey;
}

class _MyHubTabRibbon extends StatelessWidget {
  const _MyHubTabRibbon({required this.tabController});

  final TabController tabController;

  static const double _ribbonHeight = 44;
  static const double _chipPadTop = 8;
  static const double _chipPadBottom = 4;

  static const _tabs = <_MyHubTabSpec>[
    _MyHubTabSpec(icon: Icons.groups_outlined, labelKey: "my_hub_tab_groups"),
    _MyHubTabSpec(icon: Icons.list_alt, labelKey: "menu_my_listings"),
    _MyHubTabSpec(
      icon: Icons.bookmark_border,
      labelKey: "my_hub_tab_bookmarks",
    ),
    _MyHubTabSpec(
      icon: Icons.notifications_none,
      labelKey: "my_hub_tab_alerts",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final idx = tabController.index.clamp(0, _tabs.length - 1);

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
                        icon: _tabs[i].icon,
                        label: L10n.get(_tabs[i].labelKey),
                        isSelected: idx == i,
                        onTap: () {
                          if (tabController.index != i) {
                            tabController.animateTo(i);
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
        final activeBg = themeState.primaryColor;
        final inactiveBg = themeState.cardColor;
        final activeFg =
            ThemeData.estimateBrightnessForColor(activeBg) == Brightness.dark
                ? Colors.white
                : Colors.black;
        final inactiveFg = themeState.unselectedTabTextColor;
        final radius = const BorderRadius.all(Radius.circular(22));
        final iconColor =
            isSelected ? activeFg : inactiveFg.withValues(alpha: 0.85);
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
                GigCategoryIconBadge(
                  icon: icon,
                  iconColor: iconColor,
                  badgeBackgroundColor: isSelected
                      ? activeFg.withValues(alpha: 0.16)
                      : inactiveFg.withValues(alpha: 0.12),
                  dimension: 28.6,
                  iconSize: 16.5,
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
