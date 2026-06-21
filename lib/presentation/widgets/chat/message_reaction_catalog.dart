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
    "hundred",
    "smile",
    "handshake",
    "thanks",
    "flower",
    "home",
    "warm_smile",
    "sparkles",
    "celebrate",
    "interested",
    "approved",
    "tea",
  ];

  /// Red heart ❤️: U+2764 + U+FE0F so it uses emoji presentation everywhere.
  static const String heartReactionEmoji = "\u{2764}\u{FE0F}";

  /// High voltage ⚡: U+26A1 + U+FE0F — without VS16 it often draws as a flat symbol.
  static const String lightningReactionEmoji = "\u{26A1}\u{FE0F}";

  /// Fire 🔥 (U+1F525).
  static const String fireReactionEmoji = "\u{1F525}";

  /// Hundred points 💯 (U+1F4AF).
  static const String hundredReactionEmoji = "\u{1F4AF}";

  /// Slightly smiling 🙂 (U+1F642).
  static const String smileReactionEmoji = "\u{1F642}";

  /// Handshake 🤝 (U+1F91D).
  static const String handshakeReactionEmoji = "\u{1F91D}";

  /// Folded hands 🙏 (U+1F64F).
  static const String thanksReactionEmoji = "\u{1F64F}";

  /// Cherry blossom 🌸 (U+1F338).
  static const String flowerReactionEmoji = "\u{1F338}";

  /// House 🏠 (U+1F3E0).
  static const String homeReactionEmoji = "\u{1F3E0}";

  /// Smiling face with smiling eyes 😊 (U+1F60A).
  static const String warmSmileReactionEmoji = "\u{1F60A}";

  /// Sparkles ✨ (U+2728).
  static const String sparklesReactionEmoji = "\u{2728}";

  /// Party popper 🎉 (U+1F389).
  static const String celebrateReactionEmoji = "\u{1F389}";

  /// Eyes 👀 (U+1F440).
  static const String interestedReactionEmoji = "\u{1F440}";

  /// Check mark button ✅ (U+2705).
  static const String approvedReactionEmoji = "\u{2705}";

  /// Hot beverage ☕ (U+2615).
  static const String teaReactionEmoji = "\u{2615}";

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
      case "hundred":
        return hundredReactionEmoji;
      case "smile":
        return smileReactionEmoji;
      case "handshake":
        return handshakeReactionEmoji;
      case "thanks":
        return thanksReactionEmoji;
      case "flower":
        return flowerReactionEmoji;
      case "home":
        return homeReactionEmoji;
      case "warm_smile":
        return warmSmileReactionEmoji;
      case "sparkles":
        return sparklesReactionEmoji;
      case "celebrate":
        return celebrateReactionEmoji;
      case "interested":
        return interestedReactionEmoji;
      case "approved":
        return approvedReactionEmoji;
      case "tea":
        return teaReactionEmoji;
      default:
        return "👍";
    }
  }
}
