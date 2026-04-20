import "dart:math";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";

class ChatMessagesSkeleton extends StatelessWidget {
  const ChatMessagesSkeleton({super.key, this.bubbleCount = 10});

  final int bubbleCount;

  @override
  Widget build(BuildContext context) {
    final baseColor = _baseSkeletonColor(context);
    final bgColor = ThemeState().backgroundColor;

    return Container(
      color: bgColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        reverse: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: max(6, bubbleCount),
        itemBuilder: (context, index) {
          final isCurrentUser = index.isEven;
          final widthFactor = _widthFactorFor(index);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Align(
              alignment:
                  isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: _BubbleSkeleton(
                  isCurrentUser: isCurrentUser,
                  color: baseColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  double _widthFactorFor(int index) {
    // Intentional deterministic variety without randomness.
    const factors = <double>[0.42, 0.62, 0.78, 0.55, 0.68, 0.48, 0.74, 0.60];
    return factors[index % factors.length];
  }

  Color _baseSkeletonColor(BuildContext context) {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight24;
    }
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.textLight24;
    }
    return AppColors.textDark54;
  }
}

class _BubbleSkeleton extends StatelessWidget {
  const _BubbleSkeleton({
    required this.isCurrentUser,
    required this.color,
  });

  final bool isCurrentUser;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isCurrentUser ? 18 : 6),
          bottomRight: Radius.circular(isCurrentUser ? 6 : 18),
        ),
      ),
    );
  }
}

