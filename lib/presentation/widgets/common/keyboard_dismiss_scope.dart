import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// Wraps any subtree containing text inputs to give users **three** smooth ways
/// to dismiss the soft keyboard:
///
/// 1. **Tap anywhere outside an interactive control** — tap on empty space in
///    the form closes the keyboard. The outer tap-catcher uses translucent hit
///    behaviour so buttons, pills, dropdowns and the focused text field itself
///    still receive their taps as today.
/// 2. **Swipe-down on a scrollable** — pass
///    [KeyboardDismissScope.scrollBehavior] to the enclosed scroll view's
///    `keyboardDismissBehavior` so that starting a scroll drag dismisses the
///    keyboard.
/// 3. **Floating "Done" bar above the keyboard** — when the soft keyboard is
///    on screen, a thin bar slides up flush with the keyboard top edge with a
///    Done button that unfocuses the current field on tap. The bar is rendered
///    via an [OverlayPortal] so it sits above any in-page chrome (e.g. inline
///    navigation buttons) and tracks the keyboard regardless of how the host
///    [Scaffold] is configured.
///
/// Each affordance can be opted out individually via [dismissOnTapOutside] and
/// [showDoneBar]. The scroll affordance is opt-in by the caller wiring the
/// constant into their scrollable, so it stays explicit at the call site.
///
/// Designed to compose with `UydoshFormScrollBody` and any plain
/// [SingleChildScrollView] / [ListView] used by form screens.
///
/// ### Example
///
/// ```dart
/// KeyboardDismissScope(
///   child: SingleChildScrollView(
///     keyboardDismissBehavior: KeyboardDismissScope.scrollBehavior,
///     child: Column(children: [TextField(...), ...]),
///   ),
/// )
/// ```
class KeyboardDismissScope extends StatefulWidget {
  const KeyboardDismissScope({
    required this.child,
    super.key,
    this.dismissOnTapOutside = true,
    this.showDoneBar = true,
  });

  /// Convenience constant for the recommended scroll-dismiss behavior. Pass
  /// this to the enclosed scroll view's `keyboardDismissBehavior` to enable
  /// swipe-down-to-dismiss without the caller having to import
  /// [ScrollViewKeyboardDismissBehavior] directly.
  static const ScrollViewKeyboardDismissBehavior scrollBehavior =
      ScrollViewKeyboardDismissBehavior.onDrag;

  final Widget child;

  /// When true (default), an invisible tap-catcher dismisses the keyboard
  /// when the user taps empty regions of the scope. Translucent hit behaviour
  /// means real controls (buttons, text fields, dropdowns) keep working
  /// exactly as today — they win the gesture arena and the outer detector
  /// only fires when no descendant claims the tap.
  final bool dismissOnTapOutside;

  /// When true (default), a floating Done bar appears flush with the keyboard
  /// top whenever the soft keyboard is on screen.
  final bool showDoneBar;

  /// Public entry point so screens (e.g. submit handlers) can dismiss the
  /// keyboard the same way the scope does, without having to remember which
  /// `FocusScope` API to use.
  static void dismiss() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  State<KeyboardDismissScope> createState() => _KeyboardDismissScopeState();
}

class _KeyboardDismissScopeState extends State<KeyboardDismissScope>
    with WidgetsBindingObserver {
  final OverlayPortalController _portalController = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cover the (rare) case where the keyboard is already on screen by the
    // time we mount — e.g. when navigating to a screen with autofocus.
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncBarVisibility());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _syncBarVisibility();
  }

  @override
  void didUpdateWidget(covariant KeyboardDismissScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showDoneBar != widget.showDoneBar) {
      _syncBarVisibility();
    }
  }

  /// Toggles the [OverlayPortal] in lockstep with the OS keyboard. We read
  /// the raw view-level keyboard inset (unaffected by Scaffold's
  /// `resizeToAvoidBottomInset` zeroing of the local [MediaQuery]) so we
  /// detect the keyboard regardless of how the host scaffold is configured.
  void _syncBarVisibility() {
    if (!mounted) {
      return;
    }
    final double rawKeyboardInset =
        MediaQueryData.fromView(View.of(context)).viewInsets.bottom;
    final bool shouldShow = rawKeyboardInset > 0 && widget.showDoneBar;
    if (shouldShow && !_portalController.isShowing) {
      _portalController.show();
    } else if (!shouldShow && _portalController.isShowing) {
      _portalController.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget tapCatcher = widget.dismissOnTapOutside
        ? GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: KeyboardDismissScope.dismiss,
            child: widget.child,
          )
        : widget.child;

    if (!widget.showDoneBar) {
      return tapCatcher;
    }

    return OverlayPortal(
      controller: _portalController,
      overlayChildBuilder: _buildDoneBar,
      child: tapCatcher,
    );
  }

  /// Builds the Done bar inside the root [Overlay]. The overlay child context
  /// resolves [MediaQuery] from the app root, which still carries the live
  /// keyboard inset (Scaffold only zeroes it within its own body). Reading
  /// viewInsets here therefore positions the bar flush with the keyboard top
  /// across iOS / Android / web, regardless of host chrome.
  Widget _buildDoneBar(BuildContext overlayContext) {
    final MediaQueryData mq = MediaQuery.of(overlayContext);
    final ColorScheme scheme = Theme.of(overlayContext).colorScheme;
    final bool isDark = Theme.of(overlayContext).brightness == Brightness.dark;

    return Positioned(
      left: 0,
      right: 0,
      bottom: mq.viewInsets.bottom,
      child: Material(
        type: MaterialType.transparency,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            border: Border(
              top: BorderSide(
                color: scheme.outlineVariant.withValues(
                  alpha: isDark ? 0.4 : 0.6,
                ),
                width: 0.5,
              ),
            ),
          ),
          child: SizedBox(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    HapticFeedbackUtils.impact();
                    KeyboardDismissScope.dismiss();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.onSurface,
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 8),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    minimumSize: const Size(64, 36),
                  ),
                  child: Text(L10n.get("done")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
