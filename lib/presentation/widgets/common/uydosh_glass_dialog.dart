import "package:flutter/material.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";

/// Frosted-glass dialog surface that gives every app popup the same "liquid
/// glass" look as the drawer and modal bottom sheets.
///
/// Lays out [title], [content] and [actions] like [AlertDialog] (same default
/// paddings, scrollable body support, right-aligned actions) but renders them
/// on a blurred, tinted glass card instead of an opaque [Material] surface.
///
/// Prefer using [UydoshAlertDialog], [ConfirmationDialog] or [UydoshInfoDialog]
/// at call sites; they all funnel through this widget so the glass treatment
/// stays consistent.
class UydoshGlassDialog extends StatelessWidget {
  const UydoshGlassDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.fallbackBackgroundColor,
    this.titlePadding = const EdgeInsets.fromLTRB(24, 24, 24, 10),
    this.contentPadding = const EdgeInsets.fromLTRB(24, 0, 24, 20),
    this.actionsPadding = const EdgeInsets.fromLTRB(16, 0, 12, 12),
    this.semanticLabel,
    this.scrollable = false,
    this.insetPadding = const EdgeInsets.symmetric(
      horizontal: 40,
      vertical: 24,
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;

  /// Solid fill used only when blur effects are disabled (reduce motion /
  /// accessibility). When null a themed translucent surface is used.
  final Color? fallbackBackgroundColor;

  final EdgeInsetsGeometry titlePadding;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry actionsPadding;
  final String? semanticLabel;
  final bool scrollable;
  final EdgeInsets insetPadding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final effectsEnabled = LiquidGlassRendering.effectsEnabled(context);

    final decoration = BoxDecoration(
      borderRadius: borderRadius,
      gradient: effectsEnabled
          ? LiquidGlassRendering.panelGradient(scheme: scheme, isDark: isDark)
          : null,
      color: effectsEnabled
          ? null
          : (fallbackBackgroundColor ??
              LiquidGlassRendering.bottomSheetFillColor(
                scheme,
                isDark: isDark,
              )),
      border: Border.all(
        color: LiquidGlassRendering.panelBorderColor(scheme.surface),
        width: 0.6,
      ),
      boxShadow: [
        BoxShadow(
          color: scheme.shadow.withValues(alpha: isDark ? 0.34 : 0.20),
          blurRadius: 28,
          spreadRadius: 0,
          offset: const Offset(0, 12),
        ),
      ],
    );

    final children = <Widget>[];

    final titleWidget = title;
    if (titleWidget != null) {
      children.add(
        Padding(
          padding: titlePadding,
          child: DefaultTextStyle.merge(
            style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ) ??
                TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
            child: titleWidget,
          ),
        ),
      );
    }

    final contentWidget = content;
    if (contentWidget != null) {
      final body = scrollable
          ? SingleChildScrollView(child: contentWidget)
          : contentWidget;
      children.add(
        Flexible(
          child: Padding(
            padding: contentPadding,
            child: DefaultTextStyle.merge(
              style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ) ??
                  TextStyle(color: scheme.onSurfaceVariant),
              child: body,
            ),
          ),
        ),
      );
    }

    final actionsWidget = actions;
    if (actionsWidget != null && actionsWidget.isNotEmpty) {
      children.add(
        Padding(
          padding: actionsPadding,
          child: OverflowBar(
            alignment: MainAxisAlignment.end,
            spacing: 8,
            overflowAlignment: OverflowBarAlignment.end,
            children: actionsWidget,
          ),
        ),
      );
    }

    final card = ClipRRect(
      borderRadius: borderRadius,
      child: LiquidGlassRendering.backdropBlur(
        enabled: effectsEnabled,
        sigma: LiquidGlassRendering.panelBlurSigma,
        child: DecoratedBox(
          decoration: decoration,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );

    return _UydoshDialogRouteTransition(
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: insetPadding,
        clipBehavior: Clip.none,
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          namesRoute: semanticLabel != null,
          label: semanticLabel,
          child: card,
        ),
      ),
    );
  }
}

class _UydoshDialogRouteTransition extends StatelessWidget {
  const _UydoshDialogRouteTransition({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return child;
    }
    if (!AnimationSettingsState().uiAnimationsEnabled) {
      return child;
    }

    final routeAnimation = ModalRoute.of(context)?.animation;
    if (routeAnimation == null) return child;

    final curvedAnimation = CurvedAnimation(
      parent: routeAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.965, end: 1).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}
