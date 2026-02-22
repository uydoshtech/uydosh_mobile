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
    VoidCallback? onComplete,
  }) {
    _cycleTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;

    // Ensure line 1 is selected so station picker is visible
    onCycleToLine(1);

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _MetroTutorialOverlayContent(
        metroLineKey: metroLineKey,
        metroStationKey: metroStationKey,
        onDismiss: () {
          _cycleTimer?.cancel();
          _cycleTimer = null;
          _overlayEntry?.remove();
          _overlayEntry = null;
          onComplete?.call();
        },
      ),
    );
    overlay.insert(_overlayEntry!);

    // Cycle through metro lines 1, 2, 3, 4 to demonstrate the feature
    var currentLine = 1;
    _cycleTimer = Timer.periodic(const Duration(milliseconds: 2000), (_) {
      onCycleToLine(currentLine);
      currentLine = currentLine >= 4 ? 1 : currentLine + 1;
    });
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
    required this.onDismiss,
  });

  final GlobalKey<TutorialTargetWrapperState> metroLineKey;
  final GlobalKey<TutorialTargetWrapperState> metroStationKey;
  final VoidCallback onDismiss;

  @override
  State<_MetroTutorialOverlayContent> createState() =>
      _MetroTutorialOverlayContentState();
}

class _MetroTutorialOverlayContentState extends State<_MetroTutorialOverlayContent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      behavior: HitTestBehavior.opaque,
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _TwoRectanglesMaskPainter(
            metroLineKey: widget.metroLineKey,
            metroStationKey: widget.metroStationKey,
            dimColor: Colors.black.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}

/// Paints a dimmed overlay with a single full-width rectangular cutout
/// spanning both metro line and metro station controls.
class _TwoRectanglesMaskPainter extends CustomPainter {
  _TwoRectanglesMaskPainter({
    required this.metroLineKey,
    required this.metroStationKey,
    required this.dimColor,
  });

  final GlobalKey<TutorialTargetWrapperState> metroLineKey;
  final GlobalKey<TutorialTargetWrapperState> metroStationKey;
  final Color dimColor;

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
    combinedRect = Rect.fromLTRB(
      combinedRect.left,
      combinedRect.top - topPadding,
      combinedRect.right,
      combinedRect.bottom + bottomPadding,
    );

    const cornerRadius = 12.0;
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(combinedRect, const Radius.circular(cornerRadius)),
      );
    final path = Path.combine(
      ui.PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
