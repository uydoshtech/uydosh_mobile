import "dart:async";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:tutorial_coach_mark/tutorial_coach_mark.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

/// One-step spotlight that points users to the "add alert" bell in search results.
class AlertBellTutorialOverlay {
  AlertBellTutorialOverlay._();

  static TargetPosition? _clampedTargetPositionFromKey(
    BuildContext context,
    GlobalKey<TutorialTargetWrapperState> key,
  ) {
    final targetContext = key.currentContext;
    if (targetContext == null) return null;

    final renderBox = targetContext.findRenderObject();
    if (renderBox is! RenderBox) return null;

    // Compute in the same coordinate space as the root overlay.
    final overlay = Overlay.of(context, rootOverlay: true);
    final overlayBox = overlay.context.findRenderObject();

    final size = renderBox.size;
    final rawOffset = overlayBox is RenderBox
        ? renderBox.localToGlobal(Offset.zero, ancestor: overlayBox)
        : renderBox.localToGlobal(Offset.zero);

    // Clamp the focus so it cannot extend beyond the top safe area.
    // The coachmark package uses the target center + its computed radius to draw
    // the "hole". Keeping the target top below safeTop prevents the hole from
    // going offscreen even with pulse enabled.
    final safeTop = MediaQuery.of(context).padding.top;
    final minTop = safeTop + 4; // small breathing room under status bar
    final clampedDy = math.max(rawOffset.dy, minTop);

    return TargetPosition(size, Offset(rawOffset.dx, clampedDy));
  }

  static void show(
    BuildContext context, {
    required GlobalKey<TutorialTargetWrapperState> alertBellKey,
    String descriptionKey = "tutorial_alert_bell_description",
    VoidCallback? onComplete,
  }) {
    final clampedPosition = _clampedTargetPositionFromKey(
      context,
      alertBellKey,
    );

    final targets = [
      TargetFocus(
        identify: "alert_bell",
        // Use a manually clamped position so the spotlight never goes above
        // the top safe-area (AppBar actions can otherwise end up slightly
        // negative in overlay coordinates on some platforms).
        targetPosition: clampedPosition,
        keyTarget: clampedPosition == null ? alertBellKey : null,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        // Match the Home/Profile spotlight style (round focus).
        shape: ShapeLightFocus.Circle,
        paddingFocus: 6,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            builder: (context, controller) {
              final base = Theme.of(context).textTheme.titleLarge;
              return Text(
                L10n.get(descriptionKey),
                textAlign: TextAlign.center,
                style: base?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ) ??
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
              );
            },
          ),
        ],
      ),
    ];

    Timer? autoFinishTimer;

    void finishTutorial() {
      autoFinishTimer?.cancel();
      onComplete?.call();
    }

    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.92,
      hideSkip: true,
      // Match the "spotlight pulse" feel used elsewhere (home tutorial).
      pulseEnable: true,
      unFocusAnimationDuration: const Duration(milliseconds: 900),
      onFinish: finishTutorial,
      onSkip: () {
        finishTutorial();
        return true;
      },
    );

    // Use the root overlay so the AppBar action target position is computed
    // in the same coordinate space as the tutorial overlay.
    tutorial.show(context: context, rootOverlay: true);

    autoFinishTimer = Timer(const Duration(seconds: 5), () {
      if (tutorial.isShowing) {
        tutorial.finish();
      }
    });
  }
}


