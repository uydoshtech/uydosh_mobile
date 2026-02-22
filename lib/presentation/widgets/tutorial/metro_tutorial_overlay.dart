import "dart:async";
import "dart:ui" as ui;

import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

/// Displays a custom overlay that dims the search bottom sheet except for a
/// single full-width rectangular window around the metro line and metro station
/// controls. Cycles through metro lines to demonstrate the feature. Tap anywhere to dismiss.
class MetroTutorialOverlay {
  MetroTutorialOverlay._();

  static Timer? _cycleTimer;
  static OverlayEntry? _overlayEntry;

  /// Shows the metro controls tutorial with two rectangular highlights.
  static void show(
    BuildContext context, {
    required GlobalKey<TutorialTargetWrapperState> metroLineKey,
    required GlobalKey<TutorialTargetWrapperState> metroStationKey,
    required void Function(int lineIndex) onCycleToLine,
    void Function(int stationIndex)? onCycleToStation,
    int Function()? getStationCount,
    VoidCallback? onComplete,
  }) {
    _cycleTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;

    // Ensure line 1 is selected so station picker is visible
    onCycleToLine(1);

    final finishRequested = ValueNotifier<bool>(false);
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _MetroTutorialOverlayContent(
        metroLineKey: metroLineKey,
        metroStationKey: metroStationKey,
        finishRequested: finishRequested,
        onDismiss: () {
          finishRequested.dispose();
          _cycleTimer?.cancel();
          _cycleTimer = null;
          _overlayEntry?.remove();
          _overlayEntry = null;
          onComplete?.call();
        },
      ),
    );
    overlay.insert(_overlayEntry!);

    // Cycle through metro lines 1, 2, 3 every 2 seconds; when we hit line 4,
    // switch to cycling metro stations every 1 second
    var currentLine = 1;
    var currentStationIndex = 0;
    const lineCycleDuration = Duration(milliseconds: 1000);
    const stationCycleDuration = Duration(milliseconds: 750);

    void onLineCycleTick(Timer timer) {
      onCycleToLine(currentLine);
      if (currentLine >= 4) {
        timer.cancel();
        _cycleTimer = null;
        if (onCycleToStation != null && getStationCount != null) {
          var stationsShown = 0;
          _cycleTimer = Timer.periodic(stationCycleDuration, (stationTimer) {
            final count = getStationCount();
            if (count > 0) {
              onCycleToStation(currentStationIndex);
              currentStationIndex = (currentStationIndex + 1) % count;
              stationsShown++;
              if (stationsShown >= count) {
                stationTimer.cancel();
                _cycleTimer = null;
                finishRequested.value = true;
              }
            }
          });
        }
      } else {
        currentLine++;
      }
    }

    _cycleTimer = Timer.periodic(lineCycleDuration, onLineCycleTick);
  }

  /// Stops the metro line cycling and removes the overlay.
  static void stopCycling() {
    _cycleTimer?.cancel();
    _cycleTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _MetroTutorialOverlayContent extends StatefulWidget {
  const _MetroTutorialOverlayContent({
    required this.metroLineKey,
    required this.metroStationKey,
    required this.finishRequested,
    required this.onDismiss,
  });

  final GlobalKey<TutorialTargetWrapperState> metroLineKey;
  final GlobalKey<TutorialTargetWrapperState> metroStationKey;
  final ValueNotifier<bool> finishRequested;
  final VoidCallback onDismiss;

  @override
  State<_MetroTutorialOverlayContent> createState() =>
      _MetroTutorialOverlayContentState();
}

class _MetroTutorialOverlayContentState extends State<_MetroTutorialOverlayContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  static const _expandOutDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _expandOutDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();

    widget.finishRequested.addListener(_onFinishRequested);
  }

  void _onFinishRequested() {
    if (widget.finishRequested.value && mounted) {
      widget.finishRequested.removeListener(_onFinishRequested);
      _animationController.reverse().then((_) {
        if (mounted) {
          widget.onDismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.finishRequested.removeListener(_onFinishRequested);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => widget.finishRequested.value = true,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) => SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TwoRectanglesMaskPainter(
                    metroLineKey: widget.metroLineKey,
                    metroStationKey: widget.metroStationKey,
                    dimColor: Colors.black.withValues(alpha: 0.75),
                    animationValue: _animation.value,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Opacity(
                      opacity: _animation.value,
                      child: Text(
                        L10n.get("metro_tutorial_search_hint"),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paints a dimmed overlay with a single full-width rectangular cutout
/// spanning both metro line and metro station controls.
/// Animates from full-screen cutout to final size when [animationValue] goes 0→1.
class _TwoRectanglesMaskPainter extends CustomPainter {
  _TwoRectanglesMaskPainter({
    required this.metroLineKey,
    required this.metroStationKey,
    required this.dimColor,
    this.animationValue = 1.0,
  });

  final GlobalKey<TutorialTargetWrapperState> metroLineKey;
  final GlobalKey<TutorialTargetWrapperState> metroStationKey;
  final Color dimColor;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final lineRect = _getRectForKey(metroLineKey);
    final stationRect = _getRectForKey(metroStationKey);

    Rect? combinedRect;
    if (lineRect != null && stationRect != null) {
      final top = lineRect.top < stationRect.top ? lineRect.top : stationRect.top;
      final bottom = lineRect.bottom > stationRect.bottom ? lineRect.bottom : stationRect.bottom;
      combinedRect = Rect.fromLTRB(0, top, size.width, bottom);
    } else if (lineRect != null) {
      combinedRect = Rect.fromLTRB(0, lineRect.top, size.width, lineRect.bottom);
    } else if (stationRect != null) {
      combinedRect = Rect.fromLTRB(0, stationRect.top, size.width, stationRect.bottom);
    }

    if (combinedRect == null) return;

    const topPadding = 4.0;
    const bottomPadding = 30.0;
    final endRect = Rect.fromLTRB(
      combinedRect.left,
      combinedRect.top - topPadding,
      combinedRect.right,
      combinedRect.bottom + bottomPadding,
    );

    final fullScreenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final animatedRect = Rect.lerp(fullScreenRect, endRect, animationValue)!;
    final cornerRadius = 12.0 * animationValue;
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          animatedRect,
          Radius.circular(cornerRadius.clamp(0.0, 12.0)),
        ),
      );
    final path = Path.combine(
      ui.PathOperation.difference,
      Path()..addRect(fullScreenRect),
      cutoutPath,
    );

    canvas.drawPath(path, Paint()..color = dimColor);
  }

  Rect? _getRectForKey(GlobalKey<TutorialTargetWrapperState> key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject == null || renderObject is! RenderBox) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  @override
  bool shouldRepaint(covariant _TwoRectanglesMaskPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
