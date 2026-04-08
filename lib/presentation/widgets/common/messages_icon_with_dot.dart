import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class MessagesIconWithDot extends StatelessWidget {
  const MessagesIconWithDot({
    required this.onPressed,
    required this.hasUnreadMessages,
    super.key,
    this.iconColor,
    this.iconSize = 24.0,
    this.tooltip,
    this.padding,
  });

  /// Callback when the messages icon is pressed
  final VoidCallback onPressed;

  /// Whether to show the red dot indicator for unread messages
  final bool hasUnreadMessages;

  /// Color of the messages icon
  final Color? iconColor;

  /// Size of the messages icon
  final double iconSize;

  /// Tooltip text for the icon button
  final String? tooltip;

  /// Padding around the icon button
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(right: 8.0),
      child: Stack(
        children: [
          IconButton(
            icon: ThemeIcon(
              CupertinoIcons.bubble_left_bubble_right,
              color: iconColor,
              size: iconSize,
            ),
            onPressed: onPressed,
            tooltip:
                tooltip ??
                L10n.get("messages"),
          ),
          // Blinking red dot indicator for unread messages
          if (hasUnreadMessages)
            const Positioned(
              right: 8,
              top: 8,
              child: BlinkingDotWidget(
                color: Colors.red,
                size: 13,
                duration: Duration(milliseconds: 750),
                borderColor: Colors.white,
                borderWidth: 2,
              ),
            ),
        ],
      ),
    );
  }
}
