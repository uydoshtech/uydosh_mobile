import "dart:async";

import "package:dio/dio.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/config/gemini_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

typedef _BackendTranslateOutcome = ({String? text, bool skipDirectGemini});

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

  /// Lower temperature so the model keeps the source language instead of translating.
  static final GenerationConfig _enhanceGenerationConfig = GenerationConfig(
    maxOutputTokens: 2048,
    temperature: 0.12,
  );

  static GenerativeModel _modelForKey(String apiKey) {
    return GenerativeModel(
      model: GeminiConfig.defaultModel,
      apiKey: apiKey,
      safetySettings: _defaultSafetySettings,
      generationConfig: _generationConfig,
    );
  }

  static GenerativeModel _modelForEnhanceKey(String apiKey) {
    return GenerativeModel(
      model: GeminiConfig.defaultModel,
      apiKey: apiKey,
      safetySettings: _defaultSafetySettings,
      generationConfig: _enhanceGenerationConfig,
    );
  }

  /// True when backend proxy or direct SDK can be used for translation.
  bool get isAvailable => _publicApiClient != null || GeminiConfig.isConfigured;

  /// AI “enhance” uses the Google AI SDK only (no backend proxy yet).
  bool get canEnhanceListingDescription => GeminiConfig.isConfigured;

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
  ///
  /// Bounded by [_translateListingOverallTimeout] so the UI never waits forever
  /// (e.g. hung SDK or long server-side 429 retry chains).
  Future<String?> translateListingDescription({
    required String text,
    required String targetLanguageCode,
  }) async {
    try {
      return await _translateListingDescriptionImpl(
        text: text,
        targetLanguageCode: targetLanguageCode,
      ).timeout(
        _translateListingOverallTimeout,
        onTimeout: () {
          logger.w(
            "Gemini translate listing: timed out after ${_translateListingOverallTimeout.inSeconds}s",
          );
          return null;
        },
      );
    } catch (e, st) {
      logger.w("Gemini translate listing: $e", error: e, stackTrace: st);
      return null;
    }
  }

  static const Duration _translateListingOverallTimeout = Duration(seconds: 150);

  static const Duration _enhanceListingOverallTimeout = Duration(seconds: 90);

  static const Duration _directGenerateContentTimeout = Duration(seconds: 60);

  /// Rewrites the listing description for clarity and grammar; same language as input.
  Future<String?> enhanceListingDescription({required String text}) async {
    try {
      return await _enhanceListingDescriptionImpl(text: text).timeout(
        _enhanceListingOverallTimeout,
        onTimeout: () {
          logger.w(
            "Gemini enhance listing: timed out after ${_enhanceListingOverallTimeout.inSeconds}s",
          );
          return null;
        },
      );
    } catch (e, st) {
      logger.w("Gemini enhance listing: $e", error: e, stackTrace: st);
      return null;
    }
  }

  Future<String?> _enhanceListingDescriptionImpl({required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (!GeminiConfig.isConfigured) {
      return null;
    }
    final prompt = _buildEnhancePrompt(trimmed);

    for (var i = 0; i < GeminiConfig.apiKeys.length; i++) {
      final key = GeminiConfig.apiKeys[i];
      try {
        final response = await _modelForEnhanceKey(key)
            .generateContent([Content.text(prompt)])
            .timeout(_directGenerateContentTimeout);
        final out = _extractResponseText(response);
        if (out != null && out.isNotEmpty) {
          final s = out.trim();
          return s.length > 1000 ? s.substring(0, 1000) : s;
        }
        logger.w("Gemini enhance: empty response (key index $i)");
      } on TimeoutException catch (e, st) {
        logger.w(
          "Gemini enhance timed out (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      } on GenerativeAIException catch (e, st) {
        logger.w(
          "Gemini enhance failed (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      } catch (e, st) {
        logger.w(
          "Gemini enhance error (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      }
    }
    return null;
  }

  /// Same contract as [enhanceListingDescription] but tuned for gig posts
  /// (services someone offers, or tasks someone needs done) instead of
  /// housing/roommate listings. The prompt nudges the model away from the
  /// roommate-listing voice and toward concise, neutral service copy.
  Future<String?> enhanceGigDescription({
    required String text,
    required bool isOffer,
  }) async {
    try {
      return await _enhanceGigDescriptionImpl(
        text: text,
        isOffer: isOffer,
      ).timeout(
        _enhanceListingOverallTimeout,
        onTimeout: () {
          logger.w(
            "Gemini enhance gig: timed out after ${_enhanceListingOverallTimeout.inSeconds}s",
          );
          return null;
        },
      );
    } catch (e, st) {
      logger.w("Gemini enhance gig: $e", error: e, stackTrace: st);
      return null;
    }
  }

  Future<String?> _enhanceGigDescriptionImpl({
    required String text,
    required bool isOffer,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (!GeminiConfig.isConfigured) {
      return null;
    }
    final prompt = _buildGigEnhancePrompt(trimmed, isOffer: isOffer);

    for (var i = 0; i < GeminiConfig.apiKeys.length; i++) {
      final key = GeminiConfig.apiKeys[i];
      try {
        final response = await _modelForEnhanceKey(key)
            .generateContent([Content.text(prompt)])
            .timeout(_directGenerateContentTimeout);
        final out = _extractResponseText(response);
        if (out != null && out.isNotEmpty) {
          final s = out.trim();
          return s.length > 1000 ? s.substring(0, 1000) : s;
        }
        logger.w("Gemini enhance gig: empty response (key index $i)");
      } on TimeoutException catch (e, st) {
        logger.w(
          "Gemini enhance gig timed out (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      } on GenerativeAIException catch (e, st) {
        logger.w(
          "Gemini enhance gig failed (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      } catch (e, st) {
        logger.w(
          "Gemini enhance gig error (key index $i): $e",
          error: e,
          stackTrace: st,
        );
      }
    }
    return null;
  }

  static String _buildGigEnhancePrompt(String trimmed, {required bool isOffer}) {
    final langBlock = _languagePreserveInstruction(trimmed);
    final domainHint = isOffer
        ? "a service the user offers (e.g. cleaning, repair, tutoring, design)"
        : "a task the user needs done (e.g. furniture assembly, moving help, "
            "translation, photography)";
    return "You edit short gig-marketplace descriptions for a mobile app. "
        "The text describes $domainHint.\n\n"
        "$langBlock\n\n"
        "TASK: Improve clarity, grammar, and punctuation only. Fix typos. "
        "Do NOT translate, do NOT switch languages, and do NOT summarize.\n"
        "Preserve meaning, numbers, prices, addresses, and tone.\n"
        "CASE RULE: For any word written in ALL CAPS (two or more consecutive uppercase letters), "
        "convert it to Pascal case — capitalize only the first letter and lowercase the rest "
        "(e.g. \"BEAUTIFUL APARTMENT\" -> \"Beautiful Apartment\", \"СРОЧНО\" -> \"Срочно\"). "
        "EXCEPTIONS — keep ALL CAPS unchanged for: proper names, place names, brand/company names, "
        "person names, and well-known acronyms/initialisms (e.g. USA, USSR, Wi-Fi, TV, AC, ID, NYC, "
        "BMW, IKEA, ТЦ, ЖК, СНТ, метро). When unsure whether a word is an acronym or a proper name, keep it as written.\n"
        "Do not add a title, quotation marks, labels, or any text before or after the description.\n"
        "Maximum length 1000 characters.\n"
        "Output ONLY the improved description text, nothing else.\n\n"
        "---\n"
        "GIG TEXT:\n"
        "$trimmed";
  }

  /// Heuristic language hint + strict “no translation” instructions for enhance.
  static String _buildEnhancePrompt(String trimmed) {
    final langBlock = _languagePreserveInstruction(trimmed);
    return "You edit housing or roommate listing descriptions for a mobile app.\n\n"
        "$langBlock\n\n"
        "TASK: Improve clarity, grammar, and punctuation only. Fix typos. "
        "Do NOT translate, do NOT switch languages, and do NOT summarize.\n"
        "Preserve meaning, numbers, prices, addresses, and tone.\n"
        "CASE RULE: For any word written in ALL CAPS (two or more consecutive uppercase letters), "
        "convert it to Pascal case — capitalize only the first letter and lowercase the rest "
        "(e.g. \"BEAUTIFUL APARTMENT\" -> \"Beautiful Apartment\", \"СРОЧНО\" -> \"Срочно\"). "
        "EXCEPTIONS — keep ALL CAPS unchanged for: proper names, place names, brand/company names, "
        "person names, and well-known acronyms/initialisms (e.g. USA, USSR, Wi-Fi, TV, AC, ID, NYC, "
        "BMW, IKEA, ТЦ, ЖК, СНТ, метро). When unsure whether a word is an acronym or a proper name, keep it as written.\n"
        "Do not add a title, quotation marks, labels, or any text before or after the listing.\n"
        "Maximum length 1000 characters.\n"
        "Output ONLY the improved listing text, nothing else.\n\n"
        "---\n"
        "LISTING TEXT:\n"
        "$trimmed";
  }

  /// Uses script heuristics so the model keeps Russian vs Latin-only text in the right language.
  static String _languagePreserveInstruction(String trimmed) {
    final hasCy = _hasCyrillic(trimmed);
    final hasLat = _hasLatinLetter(trimmed);
    if (hasCy && !hasLat) {
      return "DETECTED: The text is Russian (Cyrillic).\n"
          "RULE: Your entire response MUST be in Russian. Never use English or Uzbek. "
          "This is an edit, not a translation.";
    }
    if (hasCy && hasLat) {
      return "DETECTED: The text mixes Cyrillic (Russian) and Latin script.\n"
          "RULE: Keep Russian parts in Russian and Latin parts in their original language. "
          "Do not rewrite everything in English.";
    }
    if (!hasCy && hasLat) {
      return "DETECTED: The text uses Latin letters (English and/or Uzbek Latin).\n"
          "RULE: Decide from vocabulary whether it is English or Uzbek (O‘zbek lotin). "
          "Rewrite ONLY in that same language — do not translate Russian-to-English or Uzbek-to-English.";
    }
    return "DETECTED: Script is ambiguous.\n"
        "RULE: Rewrite in the same language as the input. Do not translate.";
  }

  Future<String?> _translateListingDescriptionImpl({
    required String text,
    required String targetLanguageCode,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    // Never shortcut Latin script → "already English": Uzbek Latin uses the same
    // letters as English but is not English (mirrors chat translate-unseen).
    if (targetLanguageCode == "ru" && _hasCyrillic(trimmed) && !_hasLatinLetter(trimmed)) {
      return trimmed;
    }

    final backend = await _translateViaBackend(
      text: trimmed,
      targetLanguageCode: targetLanguageCode,
    );
    if (backend.text != null) {
      return backend.text;
    }
    if (backend.skipDirectGemini) {
      return null;
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
        final response = await _modelForKey(key)
            .generateContent([Content.text(prompt)])
            .timeout(_directGenerateContentTimeout);
        final out = _extractResponseText(response);
        if (out != null && out.isNotEmpty) {
          return out;
        }
        logger.w("Gemini translate: empty response for $targetLanguageCode (key index $i)");
      } on TimeoutException catch (e, st) {
        logger.w(
          "Gemini translate timed out (key index $i): $e",
          error: e,
          stackTrace: st,
        );
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

  Future<_BackendTranslateOutcome> _translateViaBackend({
    required String text,
    required String targetLanguageCode,
  }) async {
    final client = _publicApiClient;
    if (client == null) {
      return (text: null, skipDirectGemini: false);
    }
    final base = EnvironmentUtil.basePath;
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
          receiveTimeout: const Duration(seconds: 120),
          // Avoid DioException on 502/429 — we fall back to direct Gemini; not an app fault.
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final status = response.statusCode ?? 0;
      final data = response.data;

      if (status != 200) {
        final skipDirect = _backendIndicatesRateLimitedBody(data);
        if (skipDirect) {
          logger.d("Gemini backend rate limited (HTTP $status); skipping direct SDK");
        } else {
          logger.d(
            "Gemini backend HTTP $status — ${data is Map ? data['error'] : data} (trying direct Gemini)",
          );
        }
        return (text: null, skipDirectGemini: skipDirect);
      }

      if (data is! Map) {
        logger.w("Gemini backend: unexpected response shape");
        return (text: null, skipDirectGemini: false);
      }
      final map = Map<String, dynamic>.from(data);
      if (map.containsKey("error")) {
        logger.d("Gemini backend error: ${map['error']} (trying direct Gemini)");
        return (
          text: null,
          skipDirectGemini: _backendIndicatesRateLimitedBody(map),
        );
      }
      final t = map["translatedText"];
      if (t is String && t.trim().isNotEmpty) {
        return (text: t.trim(), skipDirectGemini: false);
      }
      return (text: null, skipDirectGemini: false);
    } on DioException catch (e, st) {
      final skipDirect = _backendIndicatesRateLimitedBody(e.response?.data);
      if (skipDirect) {
        logger.d("Gemini backend rate limited; skipping direct SDK");
      } else {
        logger.w(
          "Gemini backend request failed: ${e.message} status=${e.response?.statusCode}",
          error: e,
          stackTrace: st,
        );
      }
      return (text: null, skipDirectGemini: skipDirect);
    } catch (e, st) {
      logger.w("Gemini backend: $e", error: e, stackTrace: st);
      return (text: null, skipDirectGemini: false);
    }
  }

  static bool _backendIndicatesRateLimitedBody(Object? data) {
    if (data is Map) {
      final err = data["error"];
      if (err == "gemini_rate_limited") {
        return true;
      }
    }
    return false;
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
