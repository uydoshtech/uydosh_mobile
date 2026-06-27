import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";

/// Horizontal pill-chip ribbon matching category-chip styling on
/// [GigHubScreen] (icon + label, elevated 3D surface, active = primary fill).
class FavoritesTabRibbon extends StatelessWidget {
  const FavoritesTabRibbon({
    required this.tabController,
    required this.listingsLabel,
    required this.servicesLabel,
    required this.tasksLabel,
    super.key,
  });

  final TabController tabController;
  final String listingsLabel;
  final String servicesLabel;
  final String tasksLabel;

  /// Tall enough for the 36-px chip plus vertical breathing room for shadows.
  static const double _ribbonHeight = 44;
  static const double _chipPadTop = 8;
  static const double _chipPadBottom = 4;

  @override
  Widget build(BuildContext context) {
    final idx = tabController.index.clamp(0, 2);
    const icons = <IconData>[
      Icons.home_rounded,
      Icons.handyman_outlined,
      Icons.assignment_outlined,
    ];
    final labels = [listingsLabel, servicesLabel, tasksLabel];

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
                    for (var i = 0; i < 3; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _FavoritesPillTabChip(
                        icon: icons[i],
                        label: labels[i],
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

class _FavoritesPillTabChip extends StatelessWidget {
  const _FavoritesPillTabChip({
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
                GigCategoryIconBadge(
                  icon: icon,
                  iconColor: iconColor,
                  badgeBackgroundColor: isSelected
                      ? selectedIconBadgeBg
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
