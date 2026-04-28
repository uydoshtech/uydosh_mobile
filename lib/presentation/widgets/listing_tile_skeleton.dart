import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class ListingTileSkeleton extends StatelessWidget {
  const ListingTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = _getBaseSkeletonColor(context);

    final borderRadius = BorderRadius.circular(12);
    final scheme = Theme.of(context).colorScheme;
    final bg = scheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final darkShadow = Colors.black.withValues(alpha: isDark ? 0.45 : 0.20);
    final lightShadow = Colors.white.withValues(alpha: isDark ? 0.06 : 0.65);

    // Keep the skeleton's *surface* identical to `ListingTile` so the transition
    // tile -> skeleton -> tile doesn't "flash" a different background color.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(
              bg,
              scheme.onSurface,
              isDark ? 0.06 : 0.03,
            )!,
            bg,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: lightShadow,
            offset: const Offset(-3, -3),
            blurRadius: 10,
          ),
          BoxShadow(
            color: darkShadow,
            offset: const Offset(6, 6),
            blurRadius: 14,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Padding(
              // Match `ListingTile`'s vertical rhythm to avoid skeleton being taller.
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                  const SizedBox(height: 8),
                  _SkeletonBox(
                    width: double.infinity,
                    height: 14,
                    radius: 6,
                    color: baseColor,
                  ),
                  const SizedBox(height: 8),
                  _SkeletonBox(
                    width: 220,
                    height: 12,
                    radius: 6,
                    color: baseColor,
                  ),
                  const SizedBox(height: 10),
                  _SkeletonBox(
                    width: 200,
                    height: 12,
                    radius: 6,
                    color: baseColor,
                  ),
                  // Add a small optional "meta" row so the skeleton matches the
                  // average real-tile height without becoming overly tall.
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _SkeletonBox(
                        width: 18,
                        height: 18,
                        radius: 6,
                        color: baseColor,
                      ),
                      const SizedBox(width: 8),
                      _SkeletonBox(
                        width: 18,
                        height: 18,
                        radius: 6,
                        color: baseColor,
                      ),
                      const SizedBox(width: 8),
                      _SkeletonBox(
                        width: 18,
                        height: 18,
                        radius: 6,
                        color: baseColor,
                      ),
                      const SizedBox(width: 10),
                      _SkeletonBox(
                        width: 120,
                        height: 12,
                        radius: 6,
                        color: baseColor,
                      ),
                    ],
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
      ),
    );
  }

  Color _getBaseSkeletonColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Derive from `onSurface` so skeleton "ink" adapts to whichever surface
    // (blue theme / dark / light) the tile background is using.
    final onSurface = scheme.onSurface;

    // Keep the previous look for the blue theme (a bit softer).
    if (ThemeState().isBlueTheme) {
      return onSurface.withValues(alpha: 0.16);
    }

    return onSurface.withValues(alpha: isDark ? 0.16 : 0.10);
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
