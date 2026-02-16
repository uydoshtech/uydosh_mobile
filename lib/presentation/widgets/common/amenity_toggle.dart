import "package:flutter/material.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/base/utils/animation_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/amenity.dart";
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
    HapticFeedbackUtils.impact();
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
    final currentLanguage =
        LanguageAwareStringHelper.getCurrentLanguage(context);
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
    final isLightTheme = theme.brightness == Brightness.light;

    // Light theme: white bg, thin grey border, black/gray icons
    final backgroundColor = isLightTheme
        ? Colors.white
        : (isSelected ? theme.colorScheme.primary : Colors.grey[200]!);
    final borderColor = isLightTheme
        ? Colors.grey[400]!
        : (isSelected ? theme.colorScheme.primary : Colors.grey[400]!);
    final iconColor = isLightTheme
        ? (isSelected ? Colors.black : Colors.grey[600]!)
        : (isSelected ? theme.colorScheme.onPrimary : Colors.grey[600]!);
    final textColor = isLightTheme
        ? (isSelected ? Colors.black : Colors.grey[600]!)
        : (isSelected ? theme.colorScheme.onPrimary : Colors.grey[600]!);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: InkWell(
            onTap: _handleTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: backgroundColor,
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIcon(widget.amenity), size: 18, color: iconColor),
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
