import "package:flutter/cupertino.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class PrivateRoomIcon extends StatelessWidget {
  const PrivateRoomIcon({
    super.key,
    this.size = 16,
    this.padding = const EdgeInsets.all(6),
    this.borderRadius = 8,
  });

  final double size;
  final EdgeInsets padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _getPrivateRoomBackgroundColor(),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: _getPrivateRoomBorderColor(), width: 1.0),
      ),
      child: ThemeIcon(
        CupertinoIcons.lock_fill,
        color: _getPrivateRoomIconColor(),
        size: size,
      ),
    );
  }

  // Theme-dependent color method for private room background
  Color _getPrivateRoomBackgroundColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.primary.withValues(alpha: 0.1);
    } else {
      return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  // Theme-dependent color method for private room border
  Color _getPrivateRoomBorderColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.primary;
    } else {
      return AppColors.primary;
    }
  }

  // Theme-dependent color method for private room icon
  Color _getPrivateRoomIconColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.primary;
    } else {
      return AppColors.primary;
    }
  }
}
