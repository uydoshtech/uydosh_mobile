import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/achievement.dart";

/// Bottom sheet shown when user unlocks an achievement.
class AchievementUnlockBottomSheet extends StatelessWidget {
  const AchievementUnlockBottomSheet({
    required this.achievement,
    this.onDismiss,
    super.key,
  });

  final Achievement achievement;
  final VoidCallback? onDismiss;

  static Future<void> show(
    BuildContext context, {
    required Achievement achievement,
    VoidCallback? onDismiss,
  }) {
    HapticFeedbackUtils.impact();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementUnlockBottomSheet(
        achievement: achievement,
        onDismiss: onDismiss,
      ),
    ).then((_) => onDismiss?.call());
  }

  String _getDescriptionKey(String achievementKey) =>
      "${achievementKey}_desc";

  @override
  Widget build(BuildContext context) {
    final descKey = _getDescriptionKey(achievement.key);
    final description = L10n.get(descKey);
    final title = L10n.get(achievement.key);

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final isLight = ThemeState().isLightTheme;
        final isBlueTheme = ThemeState().isBlueTheme;
        final badgeColor = isLight
            ? Colors.transparent
            : Theme.of(context).colorScheme.primaryContainer;
        final badgeBorder = isLight
            ? Border.all(color: Colors.black, width: 2)
            : null;
        final iconColor = isLight
            ? Colors.black
            : (isBlueTheme ? Colors.white : Theme.of(context).colorScheme.primary);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10n.get("achievement_unlocked"),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isLight
                      ? Colors.black
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: badgeBorder,
                ),
                child: Icon(
                  achievement.icon,
                  size: 36,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(L10n.get("close")),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
