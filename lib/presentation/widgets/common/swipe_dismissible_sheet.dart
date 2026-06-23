import "package:flutter/material.dart";

/// A drop-in replacement for [showModalBottomSheet] that adds
/// **swipe-anywhere-outside to dismiss** on top of the standard barrier-tap
/// and drag-the-sheet-down behaviours.
///
/// The helper wraps the supplied [builder]'s widget in a
/// [SwipeDismissibleSheetShell] that paints a transparent gesture-catching
/// layer between the top of the screen and the visible sheet card. Any tap or
/// pan gesture on that layer pops the route immediately — so a flick / drag in
/// any direction over the dimmed area dismisses the sheet just like a tap on
/// the barrier already does.
///
/// To make the shell cover the entire empty area regardless of how tall the
/// caller's content is, the modal is always opened with
/// `isScrollControlled: true`. The Flutter-rendered drag handle is also forced
/// off (it would otherwise be drawn at the very top of the full-screen shell
/// rather than above the card); pass [showDragHandle] to have an equivalent
/// handle painted by the shell directly above the card instead.
///
/// The modal's own [backgroundColor] is forced to [Colors.transparent] so the
/// full-height shell does not leak a solid colour over the barrier. When a
/// caller would have relied on the default sheet surface, pass [cardColor]
/// (and optionally [cardShape]) so the visible card receives that fill.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool useSafeArea = true,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRootNavigator = false,
  bool showDragHandle = false,
  Color? cardColor,
  ShapeBorder? cardShape,
  Color? barrierColor,
  double? elevation,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
  String? barrierLabel,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: useSafeArea,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRootNavigator,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    barrierColor: barrierColor,
    elevation: elevation,
    clipBehavior: clipBehavior,
    constraints: constraints,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
    barrierLabel: barrierLabel,
    builder: (sheetContext) {
      return SwipeDismissibleSheetShell(
        showDragHandle: showDragHandle,
        cardColor: cardColor,
        cardShape: cardShape,
        child: builder(sheetContext),
      );
    },
  );
}

/// Wraps a bottom-sheet card so that the empty space above it dismisses the
/// route on tap **or any swipe direction**.
///
/// Use this directly when you cannot go through [showAppBottomSheet] (e.g.
/// you push a custom [ModalBottomSheetRoute] or you need the shell inside a
/// `showCupertinoModalPopup`). For normal call sites prefer the helper above.
///
/// The shell expects to live inside a route whose builder receives full-screen
/// (or otherwise tall) height constraints — i.e. the modal must be opened
/// with `isScrollControlled: true`. The visible [child] is anchored to the
/// bottom; the gesture-catching layer fills everything above it.
class SwipeDismissibleSheetShell extends StatelessWidget {
  const SwipeDismissibleSheetShell({
    required this.child,
    super.key,
    this.showDragHandle = false,
    this.cardColor,
    this.cardShape,
  });

  /// The visible sheet content. Anchored to the bottom of the available
  /// height; everything above is the gesture-catching dismiss area.
  final Widget child;

  /// Paint a small drag handle directly above the card. Use this for sheets
  /// that previously relied on `showModalBottomSheet(showDragHandle: true)`
  /// and do not already render their own handle inside [child].
  final bool showDragHandle;

  /// Optional fill for the visible card. When non-null the shell wraps [child]
  /// in a [Material] of this colour with [cardShape] (defaulting to a 20pt
  /// top-rounded rectangle). Leave null when [child] already paints its own
  /// surface (e.g. a glass plate).
  final Color? cardColor;

  /// Optional shape for the colored wrapper applied when [cardColor] is set.
  /// Ignored when [cardColor] is null.
  final ShapeBorder? cardShape;

  @override
  Widget build(BuildContext context) {
    void dismiss() {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) navigator.pop();
    }

    Widget cardLayer = child;
    if (cardColor != null) {
      final shape = cardShape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          );
      cardLayer = Material(
        color: cardColor,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: child,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: dismiss,
            // Any pan in any direction dismisses on the first move.
            onPanStart: (_) => dismiss(),
            child: showDragHandle
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ShellDragHandle(),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
        cardLayer,
      ],
    );
  }
}

class _ShellDragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
