import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";

/// Snackbar body used for the "archive with countdown + undo" ribbon.
///
/// Mirrors Telegram: the message sits on the left, a circular progress
/// indicator counts down around undo on the right, and tapping Undo cancels.
/// The surrounding [SnackBar] should use a long duration so timing is driven here.
class MessagingArchiveUndoCountdownContent extends StatefulWidget {
  const MessagingArchiveUndoCountdownContent({
    required this.message,
    required this.undoLabel,
    required this.duration,
    required this.accentColor,
    required this.messageColor,
    required this.onTimeout,
    required this.onUndo,
    super.key,
  });

  final String message;
  final String undoLabel;
  final Duration duration;
  final Color accentColor;
  final Color messageColor;
  final VoidCallback onTimeout;
  final VoidCallback onUndo;

  @override
  State<MessagingArchiveUndoCountdownContent> createState() =>
      _MessagingArchiveUndoCountdownContentState();
}

class _MessagingArchiveUndoCountdownContentState
    extends State<MessagingArchiveUndoCountdownContent>
    with TickerProviderStateMixin {
  static const Duration _fadeOutDuration = Duration(milliseconds: 320);

  late final AnimationController _controller;
  late final AnimationController _fadeController;
  bool _fadingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_fadingOut) {
          _startFadeOut();
        }
      })
      ..forward();
    _fadeController = AnimationController(
      vsync: this,
      duration: _fadeOutDuration,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startFadeOut() {
    if (_fadingOut) return;
    setState(() => _fadingOut = true);
    _fadeController.reverse().whenComplete(() {
      if (!mounted) return;
      widget.onTimeout();
    });
  }

  void _handleUndo() {
    if (_fadingOut) return;
    if (_controller.isCompleted) return;
    _controller.stop();
    widget.onUndo();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.duration.inMilliseconds / 1000.0;
    final totalSecondsCeil = totalSeconds.ceil();

    return FadeTransition(
      opacity: _fadeController,
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(color: widget.messageColor, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _handleUndo,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) => SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: 1.0 - _controller.value,
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(
                                widget.accentColor,
                              ),
                              backgroundColor:
                                  widget.accentColor.withValues(alpha: 0.22),
                            ),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, _) {
                            final remaining =
                                (totalSeconds * (1.0 - _controller.value))
                                    .ceil()
                                    .clamp(1, totalSecondsCeil);
                            return Text(
                              "$remaining",
                              style: TextStyle(
                                color: widget.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.undoLabel,
                    style: TextStyle(
                      color: widget.accentColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassy/neumorphic chrome for the messaging archive undo ribbon.
class GlassyMessagingArchiveUndoSurface extends StatelessWidget {
  const GlassyMessagingArchiveUndoSurface({
    required this.child,
    required this.borderRadius,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimationSettingsState(),
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final useGlassChrome = ThemeState().usesLiquidGlassChrome;

        final enableGlass = LiquidGlassRendering.effectsEnabled(context);

        final baseSurface = isDark ? Colors.black : scheme.surface;
        final surfaceTint =
            Color.lerp(baseSurface, scheme.primary, isDark ? 0.06 : 0.08) ??
                baseSurface;

        final decoration = useGlassChrome
            ? BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.06 : 0.26),
                    surfaceTint.withValues(alpha: isDark ? 0.22 : 0.30),
                    baseSurface.withValues(alpha: isDark ? 0.24 : 0.28),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.16 : 0.40),
                  width: 0.7,
                ),
              )
            : BoxDecoration(
                borderRadius: borderRadius,
                color: baseSurface,
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.5),
                  width: 0.7,
                ),
              );

        return Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.14),
                blurRadius: isDark ? 26 : 22,
                spreadRadius: isDark ? 1.5 : 1,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: LiquidGlassRendering.backdropBlur(
              enabled: enableGlass,
              sigma: isDark ? 22 : 26,
              child: Material(
                color: Colors.transparent,
                child: DecoratedBox(decoration: decoration, child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}
