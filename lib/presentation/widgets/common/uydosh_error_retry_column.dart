import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Centered error state column: icon + (optional) title + (optional) detail +
/// retry button. Replaces the hand-rolled `_buildErrorState` methods that are
/// repeated across chat, conversations, and admin list screens.
///
/// Two common shapes:
///
/// * **Title + detail** (admin screens): a short bold error header in
///   [ColorScheme.error], optional secondary [message] in the muted
///   [ColorScheme.onSurfaceVariant] color, and an `ElevatedButton` retry.
///
/// * **Detail only** (chat / conversations): no [title], just the error
///   [message] rendered in [TextTheme.bodyLarge]. Pass a larger
///   [messageStyle] via [messageTextTheme] or leave [title] null.
///
/// For variants with icon-label buttons (analytics screens), pass a custom
/// [retryButton] — the default button is only used when [onRetry] is set and
/// [retryButton] is null.
class UydoshErrorRetryColumn extends StatelessWidget {
  const UydoshErrorRetryColumn({
    super.key,
    this.icon = Icons.error_outline,
    this.iconColor,
    this.iconSize = 64,
    this.title,
    this.titleStyle,
    this.message,
    this.messageStyle,
    this.messageMaxLines,
    this.messageOverflow,
    this.messageTextAlign = TextAlign.center,
    this.onRetry,
    this.retryLabel,
    this.retryButton,
    this.padding,
    this.spacingAfterIcon,
    this.spacingAfterTitle = 6,
    this.spacingBeforeButton = 16,
  });

  final IconData icon;
  final Color? iconColor;
  final double iconSize;

  /// Optional bold error header (rendered in the error color by default).
  /// When null the [message] is shown as the primary text.
  final String? title;
  final TextStyle? titleStyle;

  /// Detail text. When [title] is null this becomes the primary message and
  /// uses [TextTheme.bodyLarge] by default; when [title] is present it
  /// defaults to the smaller `onSurfaceVariant` detail style.
  final String? message;
  final TextStyle? messageStyle;
  final int? messageMaxLines;
  final TextOverflow? messageOverflow;
  final TextAlign messageTextAlign;

  /// If provided, a default `ElevatedButton` retry is shown. Ignored when
  /// [retryButton] is also provided.
  final VoidCallback? onRetry;

  /// Label for the default retry button. Defaults to `L10n.get("retry")`.
  final String? retryLabel;

  /// Fully-custom retry widget (e.g. `ElevatedButton.icon`). Takes precedence
  /// over [onRetry].
  final Widget? retryButton;

  /// Outer padding around the whole column. Defaults to none.
  final EdgeInsetsGeometry? padding;

  /// Gap below the icon. Defaults to 12 when [title] is present, 16 otherwise
  /// (matches the existing admin vs chat call-site conventions).
  final double? spacingAfterIcon;

  /// Gap between title and message (only used when both are present).
  final double spacingAfterTitle;

  /// Gap between the last text widget and the retry button.
  final double spacingBeforeButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final hasTitle = title != null;
    final effectiveIconSpacing = spacingAfterIcon ?? (hasTitle ? 12.0 : 16.0);

    final children = <Widget>[
      ThemeIcon(icon, size: iconSize, color: iconColor ?? errorColor),
      SizedBox(height: effectiveIconSpacing),
    ];

    if (hasTitle) {
      children.add(
        Text(
          title!,
          textAlign: TextAlign.center,
          style: titleStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: errorColor,
              ),
        ),
      );
    }

    if (message != null) {
      if (hasTitle) {
        children.add(SizedBox(height: spacingAfterTitle));
      }
      final defaultMessageStyle = hasTitle
          ? TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            )
          : theme.textTheme.bodyLarge;
      children.add(
        Text(
          message!,
          textAlign: messageTextAlign,
          maxLines: messageMaxLines,
          overflow: messageOverflow,
          style: messageStyle ?? defaultMessageStyle,
        ),
      );
    }

    final effectiveButton = retryButton ??
        (onRetry == null
            ? null
            : ElevatedButton(
                onPressed: onRetry,
                child: Text(retryLabel ?? L10n.get("retry")),
              ));
    if (effectiveButton != null) {
      children.add(SizedBox(height: spacingBeforeButton));
      children.add(effectiveButton);
    }

    Widget column = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

    if (padding != null) {
      column = Padding(padding: padding!, child: column);
    }

    return Center(child: column);
  }
}
