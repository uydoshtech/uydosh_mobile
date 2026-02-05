import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class ListingTileSkeleton extends StatelessWidget {
  const ListingTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = _getBaseSkeletonColor(context);
    final cardColor = _getCardColor(context);

    return Card(
      margin: EdgeInsets.zero,
      color: cardColor,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _SkeletonBox(
                      width: 28,
                      height: 28,
                      radius: 8,
                      color: baseColor,
                    ),
                    const SizedBox(width: 10),
                    _SkeletonBox(
                      width: 22,
                      height: 22,
                      radius: 11,
                      color: baseColor,
                    ),
                    const SizedBox(width: 10),
                    _SkeletonBox(
                      width: 20,
                      height: 20,
                      radius: 6,
                      color: baseColor,
                    ),
                    const Spacer(),
                    _SkeletonBox(
                      width: 24,
                      height: 24,
                      radius: 12,
                      color: baseColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SkeletonBox(
                  width: double.infinity,
                  height: 16,
                  radius: 6,
                  color: baseColor,
                ),
                const SizedBox(height: 8),
                _SkeletonBox(
                  width: 220,
                  height: 14,
                  radius: 6,
                  color: baseColor,
                ),
                const SizedBox(height: 16),
                _SkeletonBox(
                  width: 180,
                  height: 14,
                  radius: 6,
                  color: baseColor,
                ),
                const SizedBox(height: 8),
                _SkeletonBox(
                  width: 140,
                  height: 14,
                  radius: 6,
                  color: baseColor,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _SkeletonBox(
                      width: 20,
                      height: 20,
                      radius: 6,
                      color: baseColor,
                    ),
                    const SizedBox(width: 8),
                    _SkeletonBox(
                      width: 20,
                      height: 20,
                      radius: 6,
                      color: baseColor,
                    ),
                    const SizedBox(width: 8),
                    _SkeletonBox(
                      width: 20,
                      height: 20,
                      radius: 6,
                      color: baseColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SkeletonBox(
                  width: 120,
                  height: 14,
                  radius: 6,
                  color: baseColor,
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: _SkeletonBox(
                width: 16,
                height: 24,
                radius: 6,
                color: baseColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBaseSkeletonColor(BuildContext context) {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight24;
    }
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.textLight24;
    }
    return AppColors.textDark54;
  }

  Color _getCardColor(BuildContext context) {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.card;
    }
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.card;
    }
    return AppColors.cardBackground;
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.radius,
    required this.color,
  });

  final double width;
  final double height;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
