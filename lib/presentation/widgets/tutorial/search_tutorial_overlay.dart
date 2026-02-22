import "dart:async";

import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
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
  /// [fullScreenKey] - Key for the main content area; used for the expand-out
  ///   animation before finishing.
  /// [onComplete] - Called when the tutorial finishes (auto or tap).
  static void show(
    BuildContext context, {
    required GlobalKey<TutorialTargetWrapperState> searchButtonKey,
    required GlobalKey<TutorialTargetWrapperState> fullScreenKey,
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
              return Text(
                L10n.get("tutorial_search_description"),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
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
                return Text(
                  L10n.get("tutorial_profile_description"),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
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

    // Final target: expand spotlight to full screen for smooth exit animation
    targets.add(
      TargetFocus(
        identify: "expand_out",
        keyTarget: fullScreenKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => const SizedBox.shrink(),
          ),
        ],
      ),
    );

    Timer? profileTransitionTimer;
    Timer? autoFinishTimer;
    Timer? finishAfterExpandTimer;

    void finishTutorial() {
      profileTransitionTimer?.cancel();
      autoFinishTimer?.cancel();
      finishAfterExpandTimer?.cancel();
      onComplete?.call();
    }

    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.85,
      hideSkip: true,
      onFinish: finishTutorial,
      onSkip: () {
        finishTutorial();
        return true;
      },
    );

    tutorial.show(context: context);

    const expandAnimationDuration = Duration(milliseconds: 600);

    const targetDuration = Duration(seconds: 4);

    // Auto-advance to profile icon after 4 seconds (if present)
    if (profileIconKey != null) {
      profileTransitionTimer = Timer(targetDuration, () {
        if (tutorial.isShowing) {
          tutorial.next();
        }
      });
      // Expand spotlight to full screen at 8 sec (4 + 4), then finish after animation
      autoFinishTimer = Timer(const Duration(seconds: 8), () {
        if (tutorial.isShowing) {
          tutorial.next(); // Transition to expand-out target
          finishAfterExpandTimer = Timer(expandAnimationDuration, () {
            if (tutorial.isShowing) {
              tutorial.finish();
            }
          });
        }
      });
    } else {
      // Expand spotlight at 4 sec, then finish after animation
      autoFinishTimer = Timer(targetDuration, () {
        if (tutorial.isShowing) {
          tutorial.next(); // Transition to expand-out target
          finishAfterExpandTimer = Timer(expandAnimationDuration, () {
            if (tutorial.isShowing) {
              tutorial.finish();
            }
          });
        }
      });
    }
  }
}
