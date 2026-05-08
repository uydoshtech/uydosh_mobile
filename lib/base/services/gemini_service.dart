import "dart:async";
import "dart:math" show Random;

import "package:dio/dio.dart";
import "package:google_generative_ai/google_generative_ai.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/base/config/gemini_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// Result for backend-metered listing translation.
class ListingTranslateOutcome {
  const ListingTranslateOutcome({
    this.text,
    this.quotaExceeded = false,
    this.authRequired = false,
  });

  final String? text;
  final bool quotaExceeded;
  final bool authRequired;

  bool get isSuccess =>
      text != null && text!.trim().isNotEmpty && !quotaExceeded && !authRequired;
}

/// Result for backend-metered listing “improve with AI”.
class ListingEnhanceOutcome {
  const ListingEnhanceOutcome({
    this.text,
    this.quotaExceeded = false,
    this.authRequired = false,
  });

  final String? text;
  final bool quotaExceeded;
  final bool authRequired;

  bool get isSuccess =>
      text != null && text!.trim().isNotEmpty && !quotaExceeded && !authRequired;
}

/// Snapshot from `GET /app/gemini/listing-ai-quota`.
class ListingAiQuotaSnapshot {
  const ListingAiQuotaSnapshot({
    required this.translateRemaining,
    required this.enhanceRemaining,
    this.premiumUntil,
  });

  final int translateRemaining;
  final int enhanceRemaining;
  final DateTime? premiumUntil;

  factory ListingAiQuotaSnapshot.fromJson(Map<String, dynamic> m) {
    final td = m["translate"];
    final ed = m["enhance"];
    int tr = 0;
    int er = 0;
    if (td is Map<String, dynamic>) {
      final r = td["remaining"];
      tr = r is int ? r : int.tryParse("$r") ?? 0;
    }
    if (ed is Map<String, dynamic>) {
      final r = ed["remaining"];
      er = r is int ? r : int.tryParse("$r") ?? 0;
    }
    DateTime? pu;
    final ps = m["premium_until"];
    if (ps is String && ps.isNotEmpty) {
      pu = DateTime.tryParse(ps);
    }
    return ListingAiQuotaSnapshot(
      translateRemaining: tr,
      enhanceRemaining: er,
      premiumUntil: pu,
    );
  }
}

typedef _BackendGeminiOutcome = ({
  String? text,
  bool skipDirectGemini,
  bool forbidDirectFallback,
  bool quotaExceeded,
  bool authRequired,
});

/// Listing translation: authenticated `POST /app/gemini/translate-listing` when
/// [IOAuthApiClient] is registered; otherwise legacy public path (will 401 in prod).
class GeminiService {
  GeminiService({
    IPublicApiClient? publicApiClient,
    IOAuthApiClient? oauthApiClient,
  }) : _publicApiClient = publicApiClient,
       _oauthApiClient = oauthApiClient;

  final IPublicApiClient? _publicApiClient;
  final IOAuthApiClient? _oauthApiClient;

  String _newIdempotencyKey() =>
      "${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 30)}";

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

  /// True when listing translation can run (signed-in backend and/or direct SDK keys).
  bool get isAvailable => _oauthApiClient != null || GeminiConfig.isConfigured;

  /// Listing “improve” prefers the metered backend when OAuth is available.
  bool get canEnhanceListingDescription =>
      _oauthApiClient != null || GeminiConfig.isConfigured;

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
  /// Uses the metered backend when signed in; falls back to direct SDK only when
  /// the server does not forbid it (e.g. not 401/403 quota or auth).
  Future<ListingTranslateOutcome> translateListingDescription({
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
          return const ListingTranslateOutcome();
        },
      );
    } catch (e, st) {
      logger.w("Gemini translate listing: $e", error: e, stackTrace: st);
      return const ListingTranslateOutcome();
    }
  }

  static const Duration _translateListingOverallTimeout = Duration(seconds: 150);

  static const Duration _enhanceListingOverallTimeout = Duration(seconds: 90);

  static const Duration _directGenerateContentTimeout = Duration(seconds: 60);

  /// Rewrites the listing description for clarity and grammar; same language as input.
  Future<ListingEnhanceOutcome> enhanceListingDescription({required String text}) async {
    try {
      return await _enhanceListingDescriptionImpl(text: text).timeout(
        _enhanceListingOverallTimeout,
        onTimeout: () {
          logger.w(
            "Gemini enhance listing: timed out after ${_enhanceListingOverallTimeout.inSeconds}s",
          );
          return const ListingEnhanceOutcome();
        },
      );
    } catch (e, st) {
      logger.w("Gemini enhance listing: $e", error: e, stackTrace: st);
      return const ListingEnhanceOutcome();
    }
  }

  Future<ListingEnhanceOutcome> _enhanceListingDescriptionImpl({required String text}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const ListingEnhanceOutcome();
    }

    final backend = await _improveListingViaBackend(text: trimmed);
    if (backend.text != null && backend.text!.trim().isNotEmpty) {
      final s = backend.text!.trim();
      return ListingEnhanceOutcome(
        text: s.length > 1000 ? s.substring(0, 1000) : s,
      );
    }
    if (backend.forbidDirectFallback) {
      return ListingEnhanceOutcome(
        quotaExceeded: backend.quotaExceeded,
        authRequired: backend.authRequired,
      );
    }

    if (!GeminiConfig.isConfigured) {
      return const ListingEnhanceOutcome();
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
          return ListingEnhanceOutcome(
            text: s.length > 1000 ? s.substring(0, 1000) : s,
          );
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
    return const ListingEnhanceOutcome();
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

  Future<ListingTranslateOutcome> _translateListingDescriptionImpl({
    required String text,
    required String targetLanguageCode,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const ListingTranslateOutcome();
    }

    // Local shortcut avoids a round-trip; server treats this as noop without consuming quota too.
    if (targetLanguageCode == "ru" && _hasCyrillic(trimmed) && !_hasLatinLetter(trimmed)) {
      return ListingTranslateOutcome(text: trimmed);
    }

    final backend = await _translateViaBackend(
      text: trimmed,
      targetLanguageCode: targetLanguageCode,
    );
    if (backend.text != null && backend.text!.trim().isNotEmpty) {
      return ListingTranslateOutcome(text: backend.text!.trim());
    }
    if (backend.forbidDirectFallback) {
      return ListingTranslateOutcome(
        quotaExceeded: backend.quotaExceeded,
        authRequired: backend.authRequired,
      );
    }
    if (backend.skipDirectGemini) {
      return const ListingTranslateOutcome();
    }

    if (!GeminiConfig.isConfigured) {
      return const ListingTranslateOutcome();
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
          return ListingTranslateOutcome(text: out);
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
    return const ListingTranslateOutcome();
  }

  Future<_BackendGeminiOutcome> _translateViaBackend({
    required String text,
    required String targetLanguageCode,
  }) async {
    final dio = _oauthApiClient?.dio ?? _publicApiClient?.dio;
    if (dio == null) {
      return (
        text: null,
        skipDirectGemini: false,
        forbidDirectFallback: false,
        quotaExceeded: false,
        authRequired: false,
      );
    }
    final base = EnvironmentUtil.basePath;
    final uri = base.endsWith("/")
        ? "${base}app/gemini/translate-listing"
        : "$base/app/gemini/translate-listing";

    _BackendGeminiOutcome parseForbidden(int status, Object? raw) {
      if (status == 401) {
        return (
          text: null,
          skipDirectGemini: true,
          forbidDirectFallback: true,
          quotaExceeded: false,
          authRequired: true,
        );
      }
      if (status == 403 && raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final code = "${map["code"] ?? ""}";
        final quota = code == "gemini_quota_exceeded";
        return (
          text: null,
          skipDirectGemini: true,
          forbidDirectFallback: true,
          quotaExceeded: quota,
          authRequired: false,
        );
      }
      return (
        text: null,
        skipDirectGemini: true,
        forbidDirectFallback: true,
        quotaExceeded: false,
        authRequired: false,
      );
    }

    try {
      final response = await dio.post<dynamic>(
        uri,
        data: <String, dynamic>{
          "text": text,
          "targetLanguageCode": targetLanguageCode,
        },
        options: Options(
          headers: <String, dynamic>{
            "Content-Type": "application/json",
            "Idempotency-Key": _newIdempotencyKey(),
          },
          receiveTimeout: const Duration(seconds: 120),
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final status = response.statusCode ?? 0;
      final data = response.data;

      if (status == 401 || status == 403) {
        return parseForbidden(status, data);
      }

      if (status != 200) {
        final skipDirect = _backendIndicatesRateLimitedBody(data);
        if (skipDirect) {
          logger.d("Gemini backend rate limited (HTTP $status); skipping direct SDK");
        } else {
          logger.d(
            "Gemini backend HTTP $status — ${data is Map ? data["error"] : data} (trying direct Gemini)",
          );
        }
        return (
          text: null,
          skipDirectGemini: skipDirect,
          forbidDirectFallback: false,
          quotaExceeded: false,
          authRequired: false,
        );
      }

      if (data is! Map) {
        logger.w("Gemini backend: unexpected response shape");
        return (
          text: null,
          skipDirectGemini: false,
          forbidDirectFallback: false,
          quotaExceeded: false,
          authRequired: false,
        );
      }
      final map = Map<String, dynamic>.from(data);
      if (map.containsKey("error")) {
        logger.d("Gemini backend error: ${map["error"]} (trying direct Gemini)");
        return (
          text: null,
          skipDirectGemini: _backendIndicatesRateLimitedBody(map),
          forbidDirectFallback: false,
          quotaExceeded: false,
          authRequired: false,
        );
      }
      final t = map["translatedText"];
      if (t is String && t.trim().isNotEmpty) {
        return (
          text: t.trim(),
          skipDirectGemini: false,
          forbidDirectFallback: false,
          quotaExceeded: false,
          authRequired: false,
        );
      }
      return (
        text: null,
        skipDirectGemini: false,
        forbidDirectFallback: false,
        quotaExceeded: false,
        authRequired: false,
      );
    } on DioException catch (e, st) {
      final status = e.response?.statusCode ?? 0;
      final pd = e.response?.data;
      if (status == 401 || status == 403) {
        return parseForbidden(status, pd);
      }
      final skipDirect = _backendIndicatesRateLimitedBody(pd);
      if (skipDirect) {
        logger.d("Gemini backend rate limited; skipping direct SDK");
      } else {
        logger.w(
          "Gemini backend request failed: ${e.message} status=${e.response?.statusCode}",
          error: e,
          stackTrace: st,
        );
      }
      return (
        text: null,
        skipDirectGemini: skipDirect,
        forbidDirectFallback: false,
        quotaExceeded: false,
        authRequired: false,
      );
    } catch (e, st) {
      logger.w("Gemini backend: $e", error: e, stackTrace: st);
      return (
        text: null,
        skipDirectGemini: false,
        forbidDirectFallback: false,
        quotaExceeded: false,
        authRequired: false,
      );
    }
  }

  Future<_BackendGeminiOutcome> _improveListingViaBackend({required String text}) async {
    final dio = _oauthApiClient?.dio ?? _publicApiClient?.dio;
    if (dio == null) {
      return (
        text: null,
        skipDirectGemini: false,
        forbidDirectFallback: false,
        quotaExceeded: false,
        authRequired: false,
      );
    }

    final base = EnvironmentUtil.basePath;
    final uri = base.endsWith("/")
        ? "${base}app/gemini/improve-listing"
        : "$base/app/gemini/improve-listing";

    _BackendGeminiOutcome parseForbidden(int status, Object? raw) {
      if (status == 401) {
        return (
          text: null,
          skipDirectGemini: true,
          forbidDirectFallback: true,
          quotaExceeded: false,
          authRequired: true,
        );
      }
      if (status == 403 && raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final code = "${map["code"] ?? ""}";
        final quota = code == "gemini_quota_exceeded";
        return (
          text: null,
          skipDirectGemini: true,
          forbidDirectFallback: true,
          quotaExceeded: quota,
          authRequired: false,
        );
      }
      return (
        text: null,
        skipDirectGemini: true,
        forbidDirectFallback: true,
        quotaExceeded: false,
        authRequired: false,
      );
    }

    try {
      final response = await dio.post<dynamic>(
        uri,
        data: <String, dynamic>{"text": text},
        options: Options(
          headers: <String, dynamic>{
            "Content-Type": "application/json",
            "Idempotency-Key": _newIdempotencyKey(),
          },
          receiveTimeout: const Duration(seconds: 120),
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final status = response.statusCode ?? 0;
      final data = response.data;

      if (status == 401 || status == 403) {
        return parseForbidden(status, data);
      }

      if (status != 200 || data is! Map) {
        return (
          text: null,
          skipDirectGemini: false,
          forbidDirectFallback: false,
          quotaExceeded: false,
          authRequired: false,
        );
      }

      final map = Map<String, dynamic>.from(data);
      final improved = map["improvedText"];
      if (improved is String && improved.trim().isNotEmpty) {
        return (
          text: improved.trim(),
          skipDirectGemini: false,
          forbidDirectFallback: false,
          quotaExceeded: false,
          authRequired: false,
        );
      }
      return (
        text: null,
        skipDirectGemini: false,
        forbidDirectFallback: false,
        quotaExceeded: false,
        authRequired: false,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final pd = e.response?.data;
      if (status == 401 || status == 403) {
        return parseForbidden(status, pd);
      }
      return (
        text: null,
        skipDirectGemini: false,
        forbidDirectFallback: false,
        quotaExceeded: false,
        authRequired: false,
      );
    } catch (_) {
      return (
        text: null,
        skipDirectGemini: false,
        forbidDirectFallback: false,
        quotaExceeded: false,
        authRequired: false,
      );
    }
  }

  Future<ListingAiQuotaSnapshot?> fetchListingAiQuota() async {
    final dio = _oauthApiClient?.dio;
    if (dio == null) {
      return null;
    }
    final base = EnvironmentUtil.basePath;
    final uri = base.endsWith("/")
        ? "${base}app/gemini/listing-ai-quota"
        : "$base/app/gemini/listing-ai-quota";
    try {
      final response = await dio.get<dynamic>(
        uri,
        options: Options(
          validateStatus: (status) =>
              status != null && status >= 200 && status < 500,
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      if (response.statusCode == 401) {
        return null;
      }
      final raw = response.data;
      if (raw is Map) {
        return ListingAiQuotaSnapshot.fromJson(Map<String, dynamic>.from(raw));
      }
    } catch (_) {
      /* best-effort */
    }
    return null;
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
