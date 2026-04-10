import "dart:async";

import "package:flutter/material.dart";
import "package:tutorial_coach_mark/tutorial_coach_mark.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

/// One-step spotlight that points users to the "add alert" bell in search results.
class AlertBellTutorialOverlay {
  AlertBellTutorialOverlay._();

  static void show(
    BuildContext context, {
    required GlobalKey<TutorialTargetWrapperState> alertBellKey,
    VoidCallback? onComplete,
  }) {
    final targets = [
      TargetFocus(
        identify: "alert_bell",
        keyTarget: alertBellKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            builder: (context, controller) {
              final base = Theme.of(context).textTheme.titleLarge;
              return Text(
                L10n.get("tutorial_alert_bell_description"),
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

    tutorial.show(context: context);

    autoFinishTimer = Timer(const Duration(seconds: 5), () {
      if (tutorial.isShowing) {
        tutorial.finish();
      }
    });
  }
}

