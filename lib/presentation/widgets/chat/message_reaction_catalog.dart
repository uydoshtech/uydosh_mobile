import "package:flutter/material.dart";

/// Server-side `message_reactions.reaction` values for user ↔ user chat.
abstract final class MessageReactionCatalog {
  static const List<String> ids = <String>[
    "thumbs_up",
    "thumbs_down",
    "heart",
    "lightning",
  ];

  static IconData iconFor(String reaction) {
    switch (reaction) {
      case "thumbs_up":
        return Icons.thumb_up_outlined;
      case "thumbs_down":
        return Icons.thumb_down_outlined;
      case "heart":
        return Icons.favorite_border;
      case "lightning":
        return Icons.bolt_outlined;
      default:
        return Icons.emoji_emotions_outlined;
    }
  }

  /// Filled icons for the overlapping bubble badge (active reaction).
  static IconData iconForBubbleBadge(String reaction) {
    switch (reaction) {
      case "thumbs_up":
        return Icons.thumb_up;
      case "thumbs_down":
        return Icons.thumb_down;
      case "heart":
        return Icons.favorite;
      case "lightning":
        return Icons.bolt;
      default:
        return Icons.emoji_emotions_outlined;
    }
  }
}
