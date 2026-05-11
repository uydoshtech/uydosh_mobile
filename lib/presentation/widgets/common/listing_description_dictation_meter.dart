import "package:flutter/material.dart";

/// Drives the listing description dictation level + timer row. Owned by
/// [DescriptionCounterToolbar] and updated by [ListingDescriptionDictateButton].
class DictationMeterController extends ChangeNotifier {
  DictationMeterController({this.barCount = 28});

  final int barCount;

  bool _active = false;
  Duration _elapsed = Duration.zero;
  late List<double> _bars = List<double>.filled(barCount, 0.04);

  bool get active => _active;
  Duration get elapsed => _elapsed;
  List<double> get bars => _bars;

  void begin() {
    _active = true;
    _elapsed = Duration.zero;
    _bars = List<double>.filled(barCount, 0.04);
    notifyListeners();
  }

  void setElapsed(Duration value) {
    if (!_active) return;
    _elapsed = value;
    notifyListeners();
  }

  /// [level] is expected in 0..1 (normalized from dBFS).
  void pushLevel(double level) {
    if (!_active) return;
    final next = List<double>.from(_bars)..removeAt(0);
    next.add(level.clamp(0.0, 1.0));
    _bars = next;
    notifyListeners();
  }

  void end() {
    _active = false;
    _elapsed = Duration.zero;
    _bars = List<double>.filled(barCount, 0.04);
    notifyListeners();
  }

  @override
  void dispose() {
    _active = false;
    _elapsed = Duration.zero;
    _bars = List<double>.filled(barCount, 0.04);
    super.dispose();
  }
}

/// Full-width row: bar visualization + recording timer (mm:ss).
class ListingDescriptionDictationMeterRow extends StatelessWidget {
  const ListingDescriptionDictationMeterRow({
    required this.controller,
    super.key,
  });

  final DictationMeterController controller;

  static String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return "$m:${s.toString().padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final fill = onSurface.withValues(alpha: 0.55);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: SizedBox(
              height: 32,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(controller.barCount, (i) {
                  final h = controller.bars[i];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 80),
                          curve: Curves.easeOut,
                          height: 4 + h * 28,
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(controller.elapsed),
            style: theme.textTheme.labelMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: onSurface.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
