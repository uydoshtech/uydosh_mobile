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
    this.notificationPredicate = _defaultUydoshNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.elevation = 2.0,
  });

  /// Preset for screens hosted under the main shell "glass" header/tab stacks.
  ///
  /// - Uses high-contrast colors (black/white) like Home.
  /// - Allows deeper notification depths (tab shells / nested stacks).
  /// - Offsets the spinner via [edgeOffset] so it isn't hidden behind headers.
  const UydoshRefreshIndicator.mainShell({
    required this.onRefresh,
    required this.child,
    required this.edgeOffset,
    super.key,
    this.notificationPredicate = _mainShellNotificationPredicate,
    this.displacement = 28.0,
    this.triggerMode = RefreshIndicatorTriggerMode.anywhere,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth = RefreshProgressIndicator.defaultStrokeWidth,
    this.elevation = 2.0,
  })  : color = null,
        backgroundColor = null;

  /// In app shells (bottom tabs, stacked navigators) the primary scrollable can
  /// end up with `depth > 0`, which makes Flutter's default predicate ignore it.
  /// Accept depth 0-2 to keep pull-to-refresh working in nested layouts.
  static bool _defaultUydoshNotificationPredicate(ScrollNotification n) =>
      n.depth <= 2;

  /// Main navigation shell composition can make depth fairly deep.
  static bool _mainShellNotificationPredicate(ScrollNotification n) =>
      n.depth <= 6;

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
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final themeState = ThemeState();

    // In the blue theme, the app often uses very light / glassy surfaces where a
    // white spinner becomes effectively invisible. Prefer the theme primary there.
    final primary = scheme.primary;
    if (themeState.currentTheme == AppTheme.blueTheme) {
      return primary;
    }

    // If primary is similar brightness to the page background, fallback to onSurface
    // so the spinner remains visible while dragging (when background is subtle).
    final primaryBrightness = ThemeData.estimateBrightnessForColor(primary);
    final bgBrightness = ThemeData.estimateBrightnessForColor(bg);
    if (primaryBrightness == bgBrightness) {
      return scheme.onSurface;
    }
    return primary;
  }

  static Color themedBackgroundColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final themeState = ThemeState();

    // Always give the indicator its own "surface" so it can't disappear against
    // white/glass headers in any theme.
    final mix = themeState.currentTheme == AppTheme.blueTheme ? 0.10 : 0.06;
    final base = Color.lerp(scheme.surface, scheme.primary, mix) ?? scheme.surface;
    return base.withValues(alpha: 0.96);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final isMainShell = color == null && backgroundColor == null;
        final highContrastColor =
            Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black;
        final highContrastBg =
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.white;

        return RefreshIndicator(
          displacement: displacement,
          edgeOffset: edgeOffset,
          onRefresh: () async {
            // Reuse the same subtle "favorites add" sound for refresh.
            SoundService().playLike();
            await onRefresh();
          },
          color: isMainShell
              ? highContrastColor
              : (color ?? themedForegroundColor(context)),
          backgroundColor: isMainShell
              ? highContrastBg
              : (backgroundColor ?? themedBackgroundColor(context)),
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
