/// Lazily-fetched translation for a chat message, managed client-side by
/// [ChatScreen] in a `Map<int, MessageTranslation>`. We intentionally keep
/// this OUT of the [Message] freezed model so new translation state can
/// flow through websocket / push refreshes without needing a codegen pass
/// on every shape tweak.
///
/// Populated from `POST /conversations/:id/translate-unseen`, which returns
/// both cached and freshly generated translations in a single payload.
class MessageTranslation {

  const MessageTranslation({
    required this.targetLanguageCode,
    required this.translatedText,
    this.sourceLanguageCode,
  });

  /// Parses the per-message entry from the backend response shape:
  /// `{"message_id": 123, "source_language_code": "ru",
  ///   "translated_text": "…"}` returning `null` for malformed entries so
  /// callers can safely `map().whereType()`.
  static MessageTranslation? fromResponseItem(
    Map<String, dynamic> item,
    String targetLanguageCode,
  ) {
    final text = item["translated_text"];
    if (text is! String || text.isEmpty) return null;
    final src = item["source_language_code"];
    return MessageTranslation(
      targetLanguageCode: targetLanguageCode,
      translatedText: text,
      sourceLanguageCode: src is String && src.isNotEmpty ? src : null,
    );
  }
  /// BCP-47 short code: "en", "ru", or "uz" (caller's preferred language).
  final String targetLanguageCode;

  /// Gemini-detected source language: "en", "ru", "uz", or null when unknown
  /// or language-agnostic (digits-only, URL-only, etc.).
  final String? sourceLanguageCode;

  /// Translated text. Never empty — callers should treat empty server
  /// responses as "no translation" and omit this object entirely.
  final String translatedText;
}
