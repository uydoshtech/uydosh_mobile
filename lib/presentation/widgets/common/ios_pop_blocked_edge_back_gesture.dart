import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

/// Re-enables iOS edge swipe when [PopScope.canPop] is false.
///
/// Flutter disables Cupertino's interactive pop when [PopScope.canPop] is
/// false, so screens with unsaved-changes guards never receive a swipe.
/// Wrap the route body and forward left-edge swipes to [onBackAttempt]
/// (typically the same handler as [PopScope.onPopInvokedWithResult]).
class IosPopBlockedEdgeBackGesture extends StatefulWidget {
  const IosPopBlockedEdgeBackGesture({
    required this.enabled,
    required this.onBackAttempt,
    required this.child,
    super.key,
  });

  final bool enabled;
  final VoidCallback onBackAttempt;
  final Widget child;

  @override
  State<IosPopBlockedEdgeBackGesture> createState() =>
      _IosPopBlockedEdgeBackGestureState();
}

class _IosPopBlockedEdgeBackGestureState
    extends State<IosPopBlockedEdgeBackGesture> {
  static const double _edgeWidth = 24;
  static const double _minDragDistance = 72;

  double _dragDistance = 0;

  bool get _active =>
      widget.enabled &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    if (!_active) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _edgeWidth,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => _dragDistance = 0,
            onHorizontalDragUpdate: (details) {
              if (details.delta.dx > 0) {
                _dragDistance += details.delta.dx;
              }
            },
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (_dragDistance >= _minDragDistance || velocity > 250) {
                widget.onBackAttempt();
              }
              _dragDistance = 0;
            },
            onHorizontalDragCancel: () => _dragDistance = 0,
          ),
        ),
      ],
    );
  }
}
