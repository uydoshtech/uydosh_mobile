import "dart:async";

import "package:flutter/material.dart";
import "package:tutorial_coach_mark/tutorial_coach_mark.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// Wraps a widget to provide a [GlobalKey] for tutorial coach mark targeting.
/// Use this to wrap UI elements that should be highlighted during tutorials.
class TutorialTargetWrapper extends StatefulWidget {
  const TutorialTargetWrapper({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<TutorialTargetWrapper> createState() => TutorialTargetWrapperState();
}

class TutorialTargetWrapperState extends State<TutorialTargetWrapper> {
  @override
  Widget build(BuildContext context) => widget.child;
}

/// Displays an overlay tutorial that highlights the search button and explains
/// its purpose. Finishes automatically (no user interaction required).
class SearchTutorialOverlay {
  SearchTutorialOverlay._();

  /// Shows the search button tutorial overlay.
  ///
  /// [context] - BuildContext from a widget below the navigator.
  /// [searchButtonKey] - GlobalKey attached to the [TutorialTargetWrapper]
  ///   that wraps the search FAB.
  /// [profileIconKey] - Optional. When provided, after 5 seconds the spotlight
  ///   automatically moves to the profile icon in the top right corner.
  /// [onComplete] - Called when the tutorial finishes (auto or tap).
  static void show(
    BuildContext context, {
    required GlobalKey<TutorialTargetWrapperState> searchButtonKey,
    GlobalKey<TutorialTargetWrapperState>? profileIconKey,
    VoidCallback? onComplete,
  }) {
    final targets = [
      TargetFocus(
        identify: "search_button",
        keyTarget: searchButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            builder: (context, controller) {
              final base = Theme.of(context).textTheme.titleLarge;
              return Text(
                L10n.get("tutorial_search_description"),
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

    if (profileIconKey != null) {
      targets.add(
        TargetFocus(
          identify: "profile_icon",
          keyTarget: profileIconKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              builder: (context, controller) {
                final base = Theme.of(context).textTheme.titleLarge;
                return Text(
                  L10n.get("tutorial_profile_description"),
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
      );
    }

    Timer? profileTransitionTimer;
    Timer? autoFinishTimer;

    void finishTutorial() {
      profileTransitionTimer?.cancel();
      autoFinishTimer?.cancel();
      onComplete?.call();
    }

    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.92,
      hideSkip: true,
      pulseEnable: false,
      unFocusAnimationDuration: const Duration(milliseconds: 900),
      onFinish: finishTutorial,
      onSkip: () {
        finishTutorial();
        return true;
      },
    );

    tutorial.show(context: context);

    const targetDuration = Duration(seconds: 4);

    // Auto-advance to profile icon after 4 seconds (if present)
    if (profileIconKey != null) {
      profileTransitionTimer = Timer(targetDuration, () {
        if (tutorial.isShowing) {
          tutorial.next();
        }
      });
      // Finish after profile step (do not use a full-screen "expand out" target:
      // that spotlight draws huge circular masks and can leave rendering artifacts
      // on Flutter web when the overlay is removed).
      autoFinishTimer = Timer(const Duration(seconds: 8), () {
        if (tutorial.isShowing) {
          tutorial.finish();
        }
      });
    } else {
      autoFinishTimer = Timer(targetDuration, () {
        if (tutorial.isShowing) {
          tutorial.finish();
        }
      });
    }
  }
}
