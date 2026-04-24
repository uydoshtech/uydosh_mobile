import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// Soft informational "tip" card used at the top of screens to surface
/// transient guidance (e.g. the notifications explainer, archived chats tip).
///
/// Layout: a rounded rectangle tinted with [ColorScheme.surfaceContainerHighest]
/// at 55% alpha, containing a leading [Icons.info_outline] icon and a body
/// built from [message] (+ optional [extra] below it), with an optional close
/// button pinned to the top-right.
///
/// Set [onClose] to render the close `IconButton`; it will also expand the
/// right padding to reserve room for the icon. Leave [onClose] `null` to hide
/// it (and reduce right padding accordingly).
class UydoshInfoCalloutCard extends StatelessWidget {
  const UydoshInfoCalloutCard({
    required this.message,
    super.key,
    this.extra,
    this.onClose,
    this.icon = Icons.info_outline,
    this.iconSize = 17,
    this.iconColor,
    this.backgroundColor,
    this.borderRadius = 14,
    this.closeTooltip,
  });

  /// Primary message body (typically a [Text] widget).
  final Widget message;

  /// Optional widget rendered below [message] inside a [Column] (e.g. an
  /// inline CTA).
  final Widget? extra;

  final VoidCallback? onClose;
  final IconData icon;
  final double iconSize;

  /// Defaults to [ColorScheme.onSurfaceVariant].
  final Color? iconColor;

  /// Defaults to [ColorScheme.surfaceContainerHighest] at 55% alpha.
  final Color? backgroundColor;

  final double borderRadius;

  /// Tooltip for the close button. Defaults to the platform close label.
  final String? closeTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = iconColor ?? theme.colorScheme.onSurfaceVariant;
    final bg = backgroundColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final rightPad = onClose != null ? 40.0 : 16.0;

    Widget body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: iconSize, color: fg),
        ),
        const SizedBox(width: 8),
        Expanded(child: message),
      ],
    );

    if (extra != null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [body, extra!],
      );
    }

    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16, 12, rightPad, 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: body,
    );

    if (onClose == null) return card;

    return Stack(
      children: [
        card,
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            tooltip: closeTooltip ??
                MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () {
              HapticFeedbackUtils.impact();
              onClose!();
            },
            icon: Icon(Icons.close, size: 18, color: fg),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            splashRadius: 18,
          ),
        ),
      ],
    );
  }
}
