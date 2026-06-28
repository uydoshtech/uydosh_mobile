import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/base/utils/animation_utils.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// A selectable amenity chip with icon, localized label, and tap animation.
/// Used in create/edit listing screens for amenity selection.
class AmenityToggle extends StatefulWidget {
  const AmenityToggle({
    required this.amenity,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final Amenity amenity;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<AmenityToggle> createState() => _AmenityToggleState();
}

class _AmenityToggleState extends State<AmenityToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationUtils.createAnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = AnimationUtils.createScaleAnimation(
      controller: _controller,
      begin: 1.0,
      end: 1.2,
    );
  }

  @override
  void dispose() {
    AnimationUtils.disposeAnimationController(_controller);
    super.dispose();
  }

  void _handleTap() {
    UiFeedbackUtils.tap();
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  IconData _getIcon(Amenity amenity) {
    if (amenity.code != null && amenity.code!.isNotEmpty) {
      return AmenityIconHelper.getIcon(amenity.code!);
    }
    return Icons.home;
  }

  String _getLocalizedName(BuildContext context, Amenity amenity) {
    final currentLanguage = L10n.currentLanguage;
    switch (currentLanguage) {
      case "ru":
        return amenity.nameRu;
      case "uz":
        return amenity.nameUz;
      case "en":
      default:
        return amenity.nameEn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = widget.isSelected;
    final isBlueTheme = ThemeState().isBlueTheme;

    final chipBase = isSelected
        ? (isBlueTheme
            ? BlueThemeColors.buttonPrimary
            : theme.colorScheme.primary)
        : (isBlueTheme
            ? BlueThemeColors.card
            : theme.colorScheme.surfaceContainerHighest);
    final iconColor = isBlueTheme
        ? (isSelected ? BlueThemeColors.textPrimary : theme.colorScheme.onSurfaceVariant)
        : (isSelected ? theme.colorScheme.onPrimary : Colors.grey[600]!);
    final textColor = isBlueTheme
        ? (isSelected ? BlueThemeColors.textPrimary : theme.colorScheme.onSurfaceVariant)
        : (isSelected ? theme.colorScheme.onPrimary : Colors.grey[600]!);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                gradient: ThreeDSurfaceStyle.surfaceGradient(context, chipBase),
                boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeIcon(
                    _getIcon(widget.amenity),
                    size: 18,
                    color: iconColor,
                    useThemeColor: false,
                  ),
                  const SizedBox(width: 6),
                  ListenableBuilder(
                    listenable: LanguageState(),
                    builder: (context, child) {
                      return Text(
                        _getLocalizedName(context, widget.amenity),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
