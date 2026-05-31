import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class GenderBadge extends StatelessWidget {
  const GenderBadge({
    required this.gender, super.key,
    this.size = 20,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    this.label,
    this.labelFontSize = 13,
    this.borderRadius = 8,
  });

  final int gender;
  final double size;
  final EdgeInsets padding;

  /// Optional text shown next to the icon (e.g. "Муж." / "Жен.").
  final String? label;
  final double labelFontSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final color = _getGenderColor(gender);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(
            _getGenderIcon(gender),
            color: color,
            size: size,
          ),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(
              label!,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getGenderColor(int gender) {
    switch (gender) {
      case 1: // Male
        return AppColors.genderMale;
      case 2: // Female
        return AppColors.genderFemale;
      default:
        return AppColors.genderOther;
    }
  }

  IconData _getGenderIcon(int gender) {
    switch (gender) {
      case 1: // Male
        return Icons.male;
      case 2: // Female
        return Icons.female;
      default:
        return Icons.person;
    }
  }
}
