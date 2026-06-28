import "dart:async" show Completer, Timer;

import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/platform_device.dart";

enum UiPerformanceTier {
  normal,
  reduced;

  static UiPerformanceTier? parse(String? value) {
    if (value == null) return null;
    for (final tier in values) {
      if (tier.name == value) return tier;
    }
    return null;
  }
}

/// Central policy for expensive visual effects.
///
/// Android starts on the reduced-effects path until the first-launch frame
/// calibration has enough post-startup timing data to persist a normal/reduced
/// tier for later launches.
class UiPerformancePolicy extends ChangeNotifier {
  factory UiPerformancePolicy() => _instance;
  UiPerformancePolicy._internal();

  static final UiPerformancePolicy _instance = UiPerformancePolicy._internal();

  static const String _keyPerformanceTier = "ui_performance.tier";
  static const Duration _startupSettleDelay = Duration(seconds: 3);
  static const Duration _sampleWindow = Duration(seconds: 5);
  static const int _targetFrameSamples = 90;
  static const int _frameBudgetMicros = 16667;
  static const int _promoteP95BudgetMicros = 22000;
  static const double _promoteJankRatio = 0.08;

  bool _isInitialized = false;
  bool _isCalibrationRunning = false;
  UiPerformanceTier _tier =
      isAndroidDevice ? UiPerformanceTier.reduced : UiPerformanceTier.normal;

  bool get isInitialized => _isInitialized;
  UiPerformanceTier get tier => _tier;
  bool get reduceEffects => _tier == UiPerformanceTier.reduced;

  static Listenable get listenable => _instance;
  static UiPerformanceTier get currentTier => _instance.tier;
  static bool get reduceEffectsForDevice => _instance.reduceEffects;
  static bool get solidColorsPreferredForDevice => isAndroidDevice;

  static Future<void> initialize() => _instance._initialize();

  static Future<void> maybeCalibrateAfterStartup() {
    return _instance._maybeCalibrateAfterStartup();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedTier = UiPerformanceTier.parse(
        prefs.getString(_keyPerformanceTier),
      );
      _setTier(
        storedTier ??
            (isAndroidDevice
                ? UiPerformanceTier.reduced
                : UiPerformanceTier.normal),
      );
      logger.d(
        "UI performance tier initialized: ${_tier.name}"
        "${storedTier == null ? " (uncalibrated)" : ""}",
      );
    } catch (e) {
      logger.d("Error initializing UI performance tier: $e");
      _setTier(
        isAndroidDevice ? UiPerformanceTier.reduced : UiPerformanceTier.normal,
      );
    }
    _isInitialized = true;
  }

  Future<void> _maybeCalibrateAfterStartup() async {
    if (!isAndroidDevice || _isCalibrationRunning) return;

    _isCalibrationRunning = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (UiPerformanceTier.parse(prefs.getString(_keyPerformanceTier)) !=
          null) {
        return;
      }

      await Future<void>.delayed(_startupSettleDelay);
      final timings = await _collectFrameTimings();
      final calibratedTier = _tierFromFrameTimings(timings);
      _setTier(calibratedTier);
      await prefs.setString(_keyPerformanceTier, calibratedTier.name);
      logger.d(
        "UI performance calibration persisted: ${calibratedTier.name} "
        "from ${timings.length} frame samples",
      );
    } catch (e) {
      logger.d("UI performance calibration failed: $e");
    } finally {
      _isCalibrationRunning = false;
    }
  }

  Future<List<FrameTiming>> _collectFrameTimings() {
    final completer = Completer<List<FrameTiming>>();
    final timings = <FrameTiming>[];
    Timer? timer;
    late TimingsCallback callback;

    void finish() {
      if (completer.isCompleted) return;
      SchedulerBinding.instance.removeTimingsCallback(callback);
      timer?.cancel();
      completer.complete(List<FrameTiming>.unmodifiable(timings));
    }

    callback = (frameTimings) {
      timings.addAll(frameTimings);
      if (timings.length >= _targetFrameSamples) finish();
    };

    SchedulerBinding.instance.addTimingsCallback(callback);
    SchedulerBinding.instance.scheduleFrame();
    timer = Timer(_sampleWindow, finish);

    return completer.future;
  }

  UiPerformanceTier _tierFromFrameTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return UiPerformanceTier.reduced;

    final frameWorkMicros = timings
        .map((timing) =>
            timing.buildDuration.inMicroseconds +
            timing.rasterDuration.inMicroseconds)
        .toList()
      ..sort();
    final p95Index = (frameWorkMicros.length * 0.95).floor().clamp(
          0,
          frameWorkMicros.length - 1,
        );
    final slowFrames = frameWorkMicros
        .where((duration) => duration > _frameBudgetMicros)
        .length;
    final jankRatio = slowFrames / frameWorkMicros.length;

    if (frameWorkMicros[p95Index] <= _promoteP95BudgetMicros &&
        jankRatio <= _promoteJankRatio) {
      return UiPerformanceTier.normal;
    }
    return UiPerformanceTier.reduced;
  }

  void _setTier(UiPerformanceTier tier) {
    if (_tier == tier) return;
    _tier = tier;
    notifyListeners();
  }

  static bool mediaQueryDisablesAnimations(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  static bool decorativeAnimationsEnabled(BuildContext context) {
    return !reduceEffectsForDevice && !mediaQueryDisablesAnimations(context);
  }

  static bool backdropBlurEnabled(BuildContext context) {
    // Backdrop blur is disproportionately expensive on Android (Impeller/Skia
    // re-samples the layer behind every frame). Solid fills are used there
    // instead — even high-end devices promoted to the normal effects tier
    // should not pay for frosted chrome.
    if (isAndroidDevice) return false;
    return decorativeAnimationsEnabled(context);
  }

  static bool complexShadowsEnabled(BuildContext context) {
    return !reduceEffectsForDevice;
  }

  static bool compactShadowsPreferred(BuildContext context) {
    return reduceEffectsForDevice;
  }

  static Color solidColorForDevice(
    Color color, {
    required Color fallback,
  }) {
    if (!solidColorsPreferredForDevice) return color;
    if (color.a == 0) return fallback;
    return color.withValues(alpha: 1);
  }

  static MediaQueryData reducedEffectsMediaQuery(MediaQueryData data) {
    if (!reduceEffectsForDevice) return data;
    return data.copyWith(disableAnimations: true);
  }

  @visibleForTesting
  static Future<void> resetForTesting() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPerformanceTier);
    _instance._isInitialized = false;
    _instance._isCalibrationRunning = false;
    _instance._setTier(
      isAndroidDevice ? UiPerformanceTier.reduced : UiPerformanceTier.normal,
    );
  }
}

/// Uses Flutter's normal platform transitions except on Android and on
/// reduced-effects devices, where page routes swap immediately.
class UiPerformancePageTransitionsTheme extends PageTransitionsTheme {
  const UiPerformancePageTransitionsTheme();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (UiPerformancePolicy.reduceEffectsForDevice || isAndroidDevice) {
      return child;
    }
    return super.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
