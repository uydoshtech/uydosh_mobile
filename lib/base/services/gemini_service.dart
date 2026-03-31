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

  static const Duration _directGenerateContentTimeout = Duration(seconds: 60);

  Future<String?> _translateListingDescriptionImpl({
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
