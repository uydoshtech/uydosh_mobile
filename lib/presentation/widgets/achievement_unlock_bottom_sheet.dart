import "dart:math";

import "package:confetti/confetti.dart";
import "package:flutter/material.dart";
import "package:flutter_fireworks/flutter_fireworks.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/achievement.dart";

/// Bottom sheet shown when user unlocks an achievement.
class AchievementUnlockBottomSheet extends StatefulWidget {
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
    getIt<AppAnalyticsService>().logAchievementUnlocked(
      achievementId: achievement.id,
      achievementKey: achievement.key,
      category: achievement.category.name,
    );
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

  /// Shows multiple achievements sequentially. Each sheet is displayed after
  /// the user dismisses the previous one. [onAllDismissed] is called when
  /// all achievements have been shown and dismissed.
  static Future<void> showMultiple(
    BuildContext context, {
    required List<Achievement> achievements,
    VoidCallback? onAllDismissed,
  }) async {
    if (achievements.isEmpty) {
      onAllDismissed?.call();
      return;
    }
    await show(
      context,
      achievement: achievements.first,
      onDismiss: null,
    );
    if (!context.mounted) return;
    final rest = achievements.sublist(1);
    if (rest.isEmpty) {
      onAllDismissed?.call();
      return;
    }
    await showMultiple(
      context,
      achievements: rest,
      onAllDismissed: onAllDismissed,
    );
  }

  @override
  State<AchievementUnlockBottomSheet> createState() =>
      _AchievementUnlockBottomSheetState();
}

class _AchievementUnlockBottomSheetState
    extends State<AchievementUnlockBottomSheet> {
  late final FireworksController _fireworksController;
  late final ConfettiController _confettiController;

  static const _celebrationColors = [
    Color(0xFFFF4C40), // Coral
    Color(0xFF6347A6), // Purple
    Color(0xFF7FB13B), // Green
    Color(0xFF82A0D1), // Blue
    Color(0xFFF7B3B2), // Rose
    Color(0xFFFFD033), // Yellow
    Color(0xFFFF6F7C), // Pink
    Color(0xFF008F6C), // Sea Green
  ];

  @override
  void initState() {
    super.initState();
    _fireworksController = FireworksController(
      colors: _celebrationColors,
      minExplosionDuration: 1.0,
      maxExplosionDuration: 2.5,
      minParticleCount: 80,
      maxParticleCount: 180,
      fadeOutDuration: 0.4,
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCelebration());
  }

  void _startCelebration() {
    if (!mounted) return;
    _fireworksController.fireMultipleRockets(
      minRockets: 4,
      maxRockets: 8,
      launchWindow: const Duration(milliseconds: 800),
    );
    _confettiController.play();
    _playFireworksHaptics();
  }

  void _playFireworksHaptics() {
    const delays = [
      Duration.zero,
      Duration(milliseconds: 200),
      Duration(milliseconds: 400),
      Duration(milliseconds: 600),
    ];
    for (var i = 0; i < delays.length; i++) {
      Future.delayed(delays[i], () {
        if (mounted) HapticFeedbackUtils.lightImpact();
      });
    }
  }

  @override
  void dispose() {
    _fireworksController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Path _createStarOrRibbonPath(Size size) {
    final random = Random();
    if (random.nextBool()) {
      return _drawStar(size);
    }
    return _drawRibbon(size);
  }

  Path _drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(
        halfWidth + externalRadius * cos(step),
        halfWidth + externalRadius * sin(step),
      );
      path.lineTo(
        halfWidth + internalRadius * cos(step + halfDegreesPerStep),
        halfWidth + internalRadius * sin(step + halfDegreesPerStep),
      );
    }
    path.close();
    return path;
  }

  Path _drawRibbon(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(0, 0);
    path.lineTo(w, 0);
    path.lineTo(w * 0.9, h);
    path.lineTo(w * 0.1, h);
    path.close();
    return path;
  }

  String _getDescriptionKey(String achievementKey) =>
      "${achievementKey}_desc";

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final descKey = _getDescriptionKey(widget.achievement.key);
    final description = L10n.get(descKey);
    final title = L10n.get(widget.achievement.key);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: FireworksDisplay(controller: _fireworksController),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ConfettiWidget(
                confettiController: _confettiController,
                canvas: size,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                maxBlastForce: 30,
                minBlastForce: 15,
                emissionFrequency: 0.05,
                gravity: 0.15,
                colors: _celebrationColors,
                createParticlePath: _createStarOrRibbonPath,
                minimumSize: const Size(8, 8),
                maximumSize: const Size(20, 20),
              ),
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildContent(context, title, description),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String title,
    String description,
  ) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final isLight = ThemeState().isLightTheme;
        final isBlueTheme = ThemeState().isBlueTheme;
        final badgeColor = isLight
            ? Colors.transparent
            : (isBlueTheme
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.grey[200]!);
        final badgeBorder = isLight
            ? Border.all(color: Colors.black, width: 2)
            : null;
        final iconColor = isLight
            ? Colors.black
            : (isBlueTheme
                ? Colors.white
                : Theme.of(context).colorScheme.primary);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
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
              const SizedBox(height: 14),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: badgeBorder,
                ),
                child: Icon(
                  widget.achievement.icon,
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
              const SizedBox(height: 16),
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
                  style: isBlueTheme
                      ? FilledButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                        )
                      : null,
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
