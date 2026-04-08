import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Reusable chat avatar with initials or person icon.
/// Used in user messaging (chat) and support chat screens.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    required this.isCurrentUser,
    this.initials,
    super.key,
  });

  /// Whether this is the current user's avatar (black bg) vs other user (white bg).
  final bool isCurrentUser;

  /// User initials to display (e.g. "AM"). If null or empty, shows person icon.
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final bgColor = isCurrentUser ? Colors.black : Colors.white;
    final iconColor = isCurrentUser ? Colors.white : Colors.black;
    final borderColor = isCurrentUser ? Colors.white : Colors.black;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: bgColor,
        child: initials != null && initials!.isNotEmpty
            ? Text(
                initials!,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            : ThemeIcon(Icons.person, size: 16, color: iconColor),
      ),
    );
  }
}
