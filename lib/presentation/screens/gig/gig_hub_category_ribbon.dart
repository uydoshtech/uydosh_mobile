import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Horizontally scrollable ribbon of category filter chips. The first chip
/// is "All" (no filter); subsequent chips show each [GigCategory] with its
/// glyph from [gigCategoryIcon].
///
/// Categories come from [GigCategoryCache] (a static, admin-ordered list
/// baked into the app), so the ribbon renders synchronously on the first
/// frame with no loading state.
class GigHubCategoryRibbon extends StatefulWidget {
  const GigHubCategoryRibbon({
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
    super.key,
  });

  /// Mirrors layout constants consumed by [GigHubPinnedHeaderDelegate].
  static const double ribbonHeight = 50;

  final List<GigCategory> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onSelected;

  @override
  State<GigHubCategoryRibbon> createState() => _GigHubCategoryRibbonState();
}

class _GigHubCategoryRibbonState extends State<GigHubCategoryRibbon> {
  late List<GlobalKey> _itemKeys;

  static const double _chipPadV = 3;

  List<GlobalKey> _newItemKeys(int count) =>
      List<GlobalKey>.generate(count, (_) => GlobalKey());

  int _selectedIndex() {
    final id = widget.selectedCategoryId;
    if (id == null) return 0;
    final i = widget.categories.indexWhere((c) => c.id == id);
    if (i < 0) return 0;
    return i + 1;
  }

  void _scrollSelectionToCenter() {
    if (!mounted) return;
    final index = _selectedIndex();
    if (index < 0 || index >= _itemKeys.length) return;
    final ctx = _itemKeys[index].currentContext;
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

  @override
  void initState() {
    super.initState();
    _itemKeys = _newItemKeys(widget.categories.length + 1);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollSelectionToCenter());
  }

  @override
  void didUpdateWidget(covariant GigHubCategoryRibbon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newCount = widget.categories.length + 1;
    final categoriesLengthChanged =
        widget.categories.length != oldWidget.categories.length;
    if (newCount != _itemKeys.length) {
      _itemKeys = _newItemKeys(newCount);
    }
    if (widget.selectedCategoryId != oldWidget.selectedCategoryId ||
        categoriesLengthChanged) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollSelectionToCenter());
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageState().currentLanguage;
    return SizedBox(
      height: GigHubCategoryRibbon.ribbonHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.fromLTRB(16, _chipPadV, 16, _chipPadV),
        itemCount: widget.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return GigHubCategoryChip(
              key: _itemKeys[0],
              icon: Icons.apps_rounded,
              label: L10n.get("all"),
              isSelected: widget.selectedCategoryId == null,
              onTap: () => widget.onSelected(null),
            );
          }
          final c = widget.categories[i - 1];
          return GigHubCategoryChip(
            key: _itemKeys[i],
            icon: gigCategoryIcon(c.code),
            label: c.localizedName(language),
            isSelected: widget.selectedCategoryId == c.id,
            onTap: () => widget.onSelected(c.id),
          );
        },
      ),
    );
  }
}

class GigHubCategoryChip extends StatelessWidget {
  const GigHubCategoryChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
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
                  iconSize: 17.5,
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
