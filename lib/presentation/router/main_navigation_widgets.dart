import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/home_inline_search_state.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart"
    show LanguageState;

/// Animated Housing title with optional inline search hit count.
class HomeListingsAppBarTitle extends StatefulWidget {
  const HomeListingsAppBarTitle({required this.titleStyle, super.key});

  final TextStyle titleStyle;

  @override
  State<HomeListingsAppBarTitle> createState() =>
      _HomeListingsAppBarTitleState();
}

class _HomeListingsAppBarTitleState extends State<HomeListingsAppBarTitle> {
  bool _countReady = false;

  /// Fine vertical tuning for inline [WidgetSpan]s (logical px; +Y is down).
  static const double _bulletDiscDy = 0.5;
  static const double _countTallyDy = 1;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: HomeInlineSearchState(),
      builder: (context, _) {
        final inlineActive = HomeInlineSearchState().isActive;

        return ListenableBuilder(
          listenable: LanguageState(),
          builder: (context, _) {
            return BlocConsumer<ListingsBloc, ListingsState>(
              listener: (context, state) {
                final isInlineActive = HomeInlineSearchState().isActive;
                final nextReady = state.maybeMap(
                  loaded: (_) => isInlineActive,
                  orElse: () => false,
                );
                if (nextReady != _countReady && mounted) {
                  setState(() => _countReady = nextReady);
                }
              },
              builder: (context, state) {
                final total =
                    state.maybeMap(loaded: (s) => s.total, orElse: () => null);
                final showCount =
                    inlineActive && _countReady && total != null && total > 0;

                // “•” uses title size; digits are smaller for hierarchy.
                final titleFs = widget.titleStyle.fontSize ?? 20;
                final countStyle = widget.titleStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: widget.titleStyle.color?.withValues(alpha: 0.72),
                );
                final countNumberStyle =
                    countStyle.copyWith(fontSize: titleFs - 5);

                return Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: L10n.get("nav_housing"),
                        style: widget.titleStyle,
                      ),
                      if (showCount) ...[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Transform.translate(
                            offset: const Offset(0, _bulletDiscDy),
                            child: Text(
                              " \u2022 ",
                              style: countStyle,
                            ),
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Transform.translate(
                            offset: const Offset(0, _countTallyDy),
                            child: Text(
                              "$total",
                              style: countNumberStyle,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  strutStyle: StrutStyle.fromTextStyle(
                    widget.titleStyle,
                    forceStrutHeight: true,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Notifications glyph with optional shake when alerts become active.
class NotificationsBellIcon extends StatefulWidget {
  const NotificationsBellIcon({required this.active, super.key});

  final bool active;

  @override
  State<NotificationsBellIcon> createState() => _NotificationsBellIconState();
}

class _NotificationsBellIconState extends State<NotificationsBellIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _turns;
  int _shakeRequestId = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    _turns = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0.10).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 18,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.10, end: -0.09).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.09, end: 0.055).chain(
          CurveTween(curve: Curves.easeInOut),
        ),
        weight: 22,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.055, end: 0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 40,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant NotificationsBellIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.active && widget.active) {
      // Icon swap first, then shake shortly after to avoid jerking.
      final requestId = ++_shakeRequestId;
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (!mounted) return;
        if (_shakeRequestId != requestId) return;
        if (!widget.active) return;
        _controller.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _turns.value * 2 * math.pi,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 160),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: Transform.translate(
          key: ValueKey<bool>(widget.active),
          // Notification glyphs sit optically high vs. neighbor icons in the
          // fixed 28px app-bar slot.
          offset: const Offset(0, 1),
          child: ThemeIcon(
            widget.active
                ? Icons.notifications_active
                : Icons.notifications_none_outlined,
            size: 26,
          ),
        ),
      ),
    );
  }
}

/// Row tile for the bottom-bar "+" create action sheet.
class CreateChoiceTile extends StatelessWidget {
  const CreateChoiceTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: theme.colorScheme.surface.withValues(
        alpha: LiquidGlassRendering.nestedTileFillAlpha(isDark: isDark),
      ),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
