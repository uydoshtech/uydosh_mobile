import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import "package:flutter/painting.dart";

/// Server-side `message_reactions.reaction` values for user ↔ user chat.
abstract final class MessageReactionCatalog {
  static const List<String> ids = <String>[
    "thumbs_up",
    "thumbs_down",
    "heart",
    "lightning",
    "fire",
    "smile",
  ];

  /// Red heart ❤️: U+2764 + U+FE0F so it uses emoji presentation everywhere.
  static const String heartReactionEmoji = "\u{2764}\u{FE0F}";

  /// High voltage ⚡: U+26A1 + U+FE0F — without VS16 it often draws as a flat symbol.
  static const String lightningReactionEmoji = "\u{26A1}\u{FE0F}";

  /// Fire 🔥 (U+1F525).
  static const String fireReactionEmoji = "\u{1F525}";

  /// Slightly smiling 🙂 (U+1F642).
  static const String smileReactionEmoji = "\u{1F642}";

  /// Forces full-color emoji glyphs (esp. ⚡) instead of monochrome text-symbol fonts.
  static TextStyle textStyleForReactionEmoji(
    double fontSize, {
    double height = 1,
    List<Shadow>? shadows,
  }) =>
      TextStyle(
        inherit: false,
        fontFamily: _primaryEmojiFontFamily(),
        fontSize: fontSize,
        height: height,
        shadows: shadows,
        leadingDistribution: TextLeadingDistribution.even,
        fontFamilyFallback: const [
          // Order after [fontFamily] — covers cases where primary is null / missing.
          "Apple Color Emoji",
          "Segoe UI Emoji",
          "Noto Color Emoji",
          "Noto Emoji",
          "EmojiOne Mozilla",
          "Twemoji Mozilla",
        ],
      );

  /// Body font packs (Roboto, etc.) include a monochrome ⚡; use emoji font first.
  static String? _primaryEmojiFontFamily() {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return "Apple Color Emoji";
      case TargetPlatform.android:
        return "Noto Color Emoji";
      case TargetPlatform.windows:
        return "Segoe UI Emoji";
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return "Noto Color Emoji";
    }
  }

  static String emojiFor(String reactionId) {
    final id = reactionId.trim().toLowerCase();
    switch (id) {
      case "thumbs_up":
        return "👍";
      case "thumbs_down":
        return "👎";
      case "heart":
        return heartReactionEmoji;
      case "lightning":
        return lightningReactionEmoji;
      case "fire":
        return fireReactionEmoji;
      case "smile":
        return smileReactionEmoji;
      default:
        return "👍";
    }
  }
}
