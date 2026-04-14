import "package:tutorial_coach_mark/tutorial_coach_mark.dart";

/// Ensures only one tutorial overlay is shown at a time.
///
/// Without this, two different screens can trigger separate `TutorialCoachMark`
/// instances and the user ends up seeing multiple spotlights concurrently.
class TutorialOverlayManager {
  factory TutorialOverlayManager() => _instance;
  TutorialOverlayManager._internal();

  static final TutorialOverlayManager _instance =
      TutorialOverlayManager._internal();

  TutorialCoachMark? _active;

  void setActive(TutorialCoachMark tutorial) {
    // Always dismiss any previous overlay first.
    dismissActive();
    _active = tutorial;
  }

  void clearIfActive(TutorialCoachMark tutorial) {
    if (identical(_active, tutorial)) {
      _active = null;
    }
  }

  void dismissActive() {
    final t = _active;
    _active = null;
    if (t == null) return;
    try {
      if (t.isShowing) {
        t.finish();
      }
    } catch (_) {
      // Best-effort; overlay might already be disposed.
    }
  }
}

