import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";

/// [RefreshIndicator] with [color] and [backgroundColor] aligned to app themes
/// (blue vs light), matching home / favorites pull-to-refresh styling.
class UydoshRefreshIndicator extends StatelessWidget {
  const UydoshRefreshIndicator({
    required this.onRefresh,
    required this.child,
    super.key,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.elevation = 2.0,
  });

  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double edgeOffset;
  final ScrollNotificationPredicate notificationPredicate;
  final String? semanticsLabel;
  final String? semanticsValue;
  final double strokeWidth;
  final RefreshIndicatorTriggerMode triggerMode;
  final double elevation;

  static Color themedForegroundColor(BuildContext context) {
    if (ThemeState().currentTheme == AppTheme.blueTheme) {
      return Colors.white;
    }
    return Theme.of(context).colorScheme.primary;
  }

  static Color themedBackgroundColor(BuildContext context) {
    if (ThemeState().currentTheme == AppTheme.blueTheme) {
      return Colors.white.withValues(alpha: 0.2);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        return RefreshIndicator(
          displacement: displacement,
          edgeOffset: edgeOffset,
          onRefresh: () async {
            // Reuse the same subtle "favorites add" sound for refresh.
            SoundService().playLike();
            await onRefresh();
          },
          color: color ?? themedForegroundColor(context),
          backgroundColor: backgroundColor ?? themedBackgroundColor(context),
          notificationPredicate: notificationPredicate,
          semanticsLabel: semanticsLabel,
          semanticsValue: semanticsValue,
          strokeWidth: strokeWidth,
          triggerMode: triggerMode,
          elevation: elevation,
          child: child,
        );
      },
    );
  }
}
