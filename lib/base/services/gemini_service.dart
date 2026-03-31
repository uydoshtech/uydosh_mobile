import "package:dio/dio.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/config/gemini_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// Listing translation: prefers **backend** `POST /app/gemini/translate-listing`
/// (server logs `[Gemini] requestId=…` for debugging), then falls back to the
/// Google AI SDK using [GeminiConfig.apiKeys] (tries keys in order).
class GeminiService {
  GeminiService({IPublicApiClient? publicApiClient})
    : _publicApiClient = publicApiClient;

  final IPublicApiClient? _publicApiClient;

  static final List<SafetySetting> _defaultSafetySettings = [
    SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
    SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
  ];

  static final GenerationConfig _generationConfig = GenerationConfig(
    maxOutputTokens: 2048,
    temperature: 0.2,
  );

  static GenerativeModel _modelForKey(String apiKey) {
    return GenerativeModel(
      model: GeminiConfig.defaultModel,
      apiKey: apiKey,
      safetySettings: _defaultSafetySettings,
      generationConfig: _generationConfig,
    );
  }

  /// True when backend proxy or direct SDK can be used for translation.
  bool get isAvailable => _publicApiClient != null || GeminiConfig.isConfigured;

  /// Returns model text, or null if the response had no text parts.
  Future<String?> generateText(String prompt) async {
    if (!GeminiConfig.isConfigured) {
      throw StateError("Gemini is not configured (empty api key).");
    }
    Object? lastError;
    for (var i = 0; i < GeminiConfig.apiKeys.length; i++) {
      final key = GeminiConfig.apiKeys[i];
      try {
        final response = await _modelForKey(key).generateContent([Content.text(prompt)]);
        final out = _extractResponseText(response);
        if (out != null) {
          return out;
        }
      } catch (e, st) {
        lastError = e;
        logger.w(
          "Gemini generateText failed (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      }
    }
    if (lastError != null) {
      final le = lastError;
      if (le is Error) {
        throw le;
      }
      if (le is Exception) {
        throw le;
      }
      throw Exception(le.toString());
    }
    return null;
  }

  /// Same as [generateText] but does not throw when the API key is missing;
  /// returns null instead.
  Future<String?> generateTextOrNull(String prompt) async {
    if (!GeminiConfig.isConfigured) {
      return null;
    }
    try {
      return await generateText(prompt);
    } catch (_) {
      return null;
    }
  }

  /// Translates listing description to [targetLanguageCode]: `en`, `ru`, or `uz`.
  Future<String?> translateListingDescription({
    required String text,
    required String targetLanguageCode,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (targetLanguageCode == "en" && !_hasCyrillic(trimmed)) {
      return trimmed;
    }
    if (targetLanguageCode == "ru" && _hasCyrillic(trimmed) && !_hasLatinLetter(trimmed)) {
      return trimmed;
    }

    final viaBackend = await _translateViaBackend(
      text: trimmed,
      targetLanguageCode: targetLanguageCode,
    );
    if (viaBackend != null) {
      return viaBackend;
    }

    if (!GeminiConfig.isConfigured) {
      return null;
    }

    final langInstruction = switch (targetLanguageCode) {
      "en" => "English",
      "ru" => "Russian",
      "uz" =>
        "Uzbek using Latin letters (O‘zbek lotin alifbosi), as used in Uzbekistan apps",
      _ => "English",
    };
    final prompt =
        "Translate the following housing or roommate listing description "
        "into $langInstruction. If it is already in that language, output it "
        "unchanged. Preserve meaning, numbers, prices, and tone. Output only "
        "the translated text with no title, quotes, or explanation:\n\n"
        "$trimmed";

    for (var i = 0; i < GeminiConfig.apiKeys.length; i++) {
      final key = GeminiConfig.apiKeys[i];
      try {
        final response = await _modelForKey(key).generateContent([Content.text(prompt)]);
        final out = _extractResponseText(response);
        if (out != null && out.isNotEmpty) {
          return out;
        }
        logger.w("Gemini translate: empty response for $targetLanguageCode (key index $i)");
      } on GenerativeAIException catch (e, st) {
        logger.w(
          "Gemini translate failed (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      } catch (e, st) {
        logger.w(
          "Gemini translate error (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      }
    }
    return null;
  }

  Future<String?> _translateViaBackend({
    required String text,
    required String targetLanguageCode,
  }) async {
    final client = _publicApiClient;
    if (client == null) {
      return null;
    }
    const base = EnvironmentUtil.basePath;
    final uri = base.endsWith("/")
        ? "${base}app/gemini/translate-listing"
        : "$base/app/gemini/translate-listing";
    try {
      final response = await client.dio.post<dynamic>(
        uri,
        data: <String, dynamic>{
          "text": text,
          "targetLanguageCode": targetLanguageCode,
        },
        options: Options(
          headers: <String, dynamic>{"Content-Type": "application/json"},
          receiveTimeout: const Duration(seconds: 90),
        ),
      );
      final data = response.data;
      if (data is! Map) {
        logger.w("Gemini backend: unexpected response shape");
        return null;
      }
      final map = Map<String, dynamic>.from(data);
      if (map.containsKey("error")) {
        logger.w("Gemini backend error: ${map['error']}");
        return null;
      }
      final t = map["translatedText"];
      if (t is String && t.trim().isNotEmpty) {
        return t.trim();
      }
      return null;
    } on DioException catch (e, st) {
      logger.w(
        "Gemini backend HTTP failed: ${e.message} status=${e.response?.statusCode}",
        error: e,
        stackTrace: st,
      );
      return null;
    } catch (e, st) {
      logger.w("Gemini backend: $e", error: e, stackTrace: st);
      return null;
    }
  }

  static bool _hasCyrillic(String s) => RegExp("[\u0400-\u04FF]").hasMatch(s);

  static bool _hasLatinLetter(String s) => RegExp("[A-Za-z]").hasMatch(s);

  static String? _extractResponseText(GenerateContentResponse response) {
    try {
      final t = response.text;
      if (t != null && t.trim().isNotEmpty) {
        return t.trim();
      }
    } on GenerativeAIException catch (e) {
      logger.w("Gemini response.text blocked: $e");
    }
    if (response.candidates.isEmpty) {
      return null;
    }
    final parts = response.candidates.first.content.parts;
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is TextPart) {
        buffer.write(part.text);
      }
    }
    final s = buffer.toString().trim();
    return s.isEmpty ? null : s;
  }
}
