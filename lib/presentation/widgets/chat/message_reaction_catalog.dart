import "package:flutter/material.dart";

/// Server-side `message_reactions.reaction` values for user ↔ user chat.
abstract final class MessageReactionCatalog {
  static const List<String> ids = <String>[
    "thumbs_up",
    "thumbs_down",
    "heart",
    "lightning",
  ];

  /// Filled, rounded Material glyphs — same weight as the posted badge, picker, strip.
  static IconData iconForBubbleBadge(String reaction) {
    switch (reaction) {
      case "thumbs_up":
        return Icons.thumb_up_alt_rounded;
      case "thumbs_down":
        return Icons.thumb_down_alt_rounded;
      case "heart":
        return Icons.favorite_rounded;
      case "lightning":
        return Icons.electric_bolt_rounded;
      default:
        return Icons.emoji_emotions_outlined;
    }
  }

  /// Warm “emoji 👍” yellow for thumbs / lightning; heart stays red.
  static const Color emojiAccentYellow = Color(0xFFFFD54F);

  /// Icon tint for reactions on bubbles, picker, and strips.
  static Color accentIconColor(String reactionId, Color fallback) {
    switch (reactionId) {
      case "heart":
        return const Color(0xFFE53935);
      case "thumbs_up":
      case "thumbs_down":
      case "lightning":
        return emojiAccentYellow;
      default:
        return fallback.withValues(alpha: 0.95);
    }
  }
}
