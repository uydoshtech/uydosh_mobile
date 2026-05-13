import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_pulse_controller.dart";

/// Haptic + sound for any favorite toggle (tiles, detail app bars, overflow menus).
void triggerFavoriteToggleFeedback() {
  HapticFeedbackUtils.impact();
  SoundService().playLike();
}

/// Data passed to [FavoriteHeartToggle.builder].
class FavoriteHeartToggleUi {
  const FavoriteHeartToggleUi({
    required this.isFavorite,
    required this.toggling,
    required this.pulse,
    required this.onTap,
  });

  final bool isFavorite;
  final bool toggling;
  final FavoriteHeartPulseController pulse;
  final VoidCallback? onTap;
}

/// Interactive favorite heart: pulse animation, haptics/sound, and busy styling.
///
/// Rebuilds when [listenable] notifies. When [shouldShow] is false,
/// [hiddenBuilder] runs and the pulse idle state resets (outline hidden).
///
/// [onToggle] must apply the optimistic flip, optional [pulse.playTapPulse]
/// when adding, call the API, and roll back + show errors on failure.
/// Busy / network pulse are handled here.
class FavoriteHeartToggle extends StatefulWidget {
  const FavoriteHeartToggle({
    required this.listenable,
    required this.shouldShow,
    required this.resolveIsFavorite,
    required this.onToggle,
    required this.builder,
    required this.hiddenBuilder,
    super.key,
  });

  final Listenable listenable;
  final bool Function(BuildContext context) shouldShow;
  final bool Function(BuildContext context) resolveIsFavorite;
  final Future<void> Function(
    BuildContext context,
    bool wasFavorite,
    FavoriteHeartPulseController pulse,
  ) onToggle;

  final Widget Function(BuildContext context, FavoriteHeartToggleUi data)
      builder;

  final Widget Function(BuildContext context) hiddenBuilder;

  @override
  State<FavoriteHeartToggle> createState() => _FavoriteHeartToggleState();
}

class _FavoriteHeartToggleState extends State<FavoriteHeartToggle>
    with TickerProviderStateMixin {
  late final FavoriteHeartPulseController _pulse;
  bool _toggling = false;

  @override
  void initState() {
    super.initState();
    _pulse = FavoriteHeartPulseController(vsync: this);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _handleTap(BuildContext context) async {
    if (_toggling) return;
    final wasFavorite = widget.resolveIsFavorite(context);
    triggerFavoriteToggleFeedback();
    setState(() => _toggling = true);
    _pulse.setNetworkBusy(true);
    try {
      await widget.onToggle(context, wasFavorite, _pulse);
    } finally {
      _pulse.setNetworkBusy(false);
      if (mounted) setState(() => _toggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.listenable,
      builder: (context, child) {
        if (!widget.shouldShow(context)) {
          _pulse.setFavoriteOutlineState(isFavorite: true);
          return widget.hiddenBuilder(context);
        }
        final isFavorite = widget.resolveIsFavorite(context);
        _pulse.setFavoriteOutlineState(isFavorite: isFavorite);
        return widget.builder(
          context,
          FavoriteHeartToggleUi(
            isFavorite: isFavorite,
            toggling: _toggling,
            pulse: _pulse,
            onTap: _toggling ? null : () => unawaited(_handleTap(context)),
          ),
        );
      },
    );
  }
}
