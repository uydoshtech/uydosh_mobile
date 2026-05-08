import "package:flutter/scheduler.dart";
import "package:flutter/widgets.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";

/// Drives listing/gig favorite heart motion: a soft idle “breathing” pulse when
/// the item isn’t favorited (outline heart) plus the familiar tap “pop”.
///
/// Honors [AnimationSettingsState.uiAnimationsEnabled] for the idle loop.
class FavoriteHeartPulseController {
  FavoriteHeartPulseController({
    required TickerProvider vsync,

    /// Optional; prefer driving UI via [listenable] + [AnimatedBuilder] /
    /// [ListenableBuilder] so pulse ticks don’t rebuild whole screens or tiles.
    VoidCallback? repaint,
    Duration tapDuration = const Duration(milliseconds: 140),
    Duration idleCycle = const Duration(milliseconds: 2000),
  }) : _repaint = repaint {
    _tapCtrl = AnimationController(vsync: vsync, duration: tapDuration);
    _tapScale = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(
        parent: _tapCtrl,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _idleCtrl = AnimationController(vsync: vsync, duration: idleCycle);
    _idleScale = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut),
    );

    _tapCtrl.addListener(_onAnimTick);
    _idleCtrl.addListener(_onAnimTick);

    _settings = AnimationSettingsState();
    _settingsListener = () {
      SchedulerBinding.instance.addPostFrameCallback((_) => _syncIdlePulse());
    };
    _settings.addListener(_settingsListener);

    listenable = Listenable.merge([_tapCtrl, _idleCtrl]);
  }

  final VoidCallback? _repaint;
  late final AnimationController _tapCtrl;
  late final Animation<double> _tapScale;
  late final AnimationController _idleCtrl;
  late final Animation<double> _idleScale;
  late final AnimationSettingsState _settings;
  late final VoidCallback _settingsListener;

  late final Listenable listenable;

  bool _isFavorite = true;
  bool _disposed = false;

  void _onAnimTick() => _repaint?.call();

  /// Current scale = idle breathing × tap pop.
  double get scale => _tapScale.value * _idleScale.value;

  Future<void> playTapPulse() async {
    _tapCtrl
      ..stop()
      ..value = 0;
    await _tapCtrl.forward();
    await _tapCtrl.reverse();
  }

  void setFavoriteOutlineState({required bool isFavorite}) {
    if (_isFavorite == isFavorite) return;
    _isFavorite = isFavorite;
    // Defer: this is invoked from [ListenableBuilder] during tile build.
    // [_idleCtrl.stop] / [repeat] notify listeners synchronously -> [_repaint]
    // -> [setState] mid-build and layout exceptions.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      _syncIdlePulse();
    });
  }

  void _syncIdlePulse() {
    final enableIdle = !_isFavorite && _settings.uiAnimationsEnabled;
    if (enableIdle) {
      if (!_idleCtrl.isAnimating) {
        _idleCtrl.repeat(reverse: true);
      }
    } else {
      if (_idleCtrl.isAnimating) {
        _idleCtrl.stop();
      }
      _idleCtrl.value = 0;
      _repaint?.call();
    }
  }

  void dispose() {
    _disposed = true;
    _settings.removeListener(_settingsListener);
    _tapCtrl.dispose();
    _idleCtrl.dispose();
  }
}
