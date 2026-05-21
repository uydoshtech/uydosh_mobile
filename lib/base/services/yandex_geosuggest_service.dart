import "dart:convert";
import "dart:math" show Random;

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// A single address hint from Yandex Geosuggest.
class YandexGeosuggestSuggestion {
  const YandexGeosuggestSuggestion({
    required this.displayText,
    this.subtitle,
  });

  final String displayText;
  final String? subtitle;
}

/// Result of a single Geosuggest fetch (suggestions may be empty on error).
class YandexGeosuggestFetchResult {
  const YandexGeosuggestFetchResult({
    required this.suggestions,
    this.httpStatus,
    this.errorMessage,
  });

  final List<YandexGeosuggestSuggestion> suggestions;
  final int? httpStatus;
  final String? errorMessage;

  bool get isAuthError => httpStatus == 403;
  bool get isConfiguredError =>
      httpStatus == 403 ||
      (errorMessage != null &&
          errorMessage!.toLowerCase().contains("api key"));
}

/// Client for `https://suggest-maps.yandex.ru/v1/suggest`.
///
/// Requires a **Geosuggest API** key from [Yandex Developer Console](https://developer.tech.yandex.com/).
/// MapKit / JS Maps keys return HTTP 403 on this endpoint.
class YandexGeosuggestService {
  YandexGeosuggestService({Dio? dio, String? apiKey})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
              ),
            ),
        _apiKey = apiKey ?? AppConfig.yandexGeosuggestApiKey;

  static const endpoint = "https://suggest-maps.yandex.ru/v1/suggest";

  /// Greater Tashkent — biases suggestions toward the app's primary market.
  static const defaultBBox = "69.05,41.15~69.45,41.42";

  final Dio _dio;
  final String _apiKey;

  /// Random token for a single user typing session (Yandex billing grouping).
  static String newSessionToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).join();
  }

  Future<List<YandexGeosuggestSuggestion>> suggest({
    required String text,
    required String sessionToken,
    String lang = "ru",
    int results = 6,
  }) async {
    final result = await fetch(
      text: text,
      sessionToken: sessionToken,
      lang: lang,
      results: results,
    );
    return result.suggestions;
  }

  Future<YandexGeosuggestFetchResult> fetch({
    required String text,
    required String sessionToken,
    String lang = "ru",
    int results = 6,
  }) async {
    final query = text.trim();
    if (query.length < 2) {
      return const YandexGeosuggestFetchResult(suggestions: []);
    }

    final apiKey = _apiKey.trim();
    if (apiKey.isEmpty) {
      const message =
          "Geosuggest API key is empty — set yandex_geosuggest_api_key "
          "in Remote Config or YANDEX_GEOSUGGEST_API_KEY dart-define";
      _logTerminal(message);
      logger.w(message);
      return const YandexGeosuggestFetchResult(
        suggestions: [],
        errorMessage: message,
      );
    }

    try {
      final queryParameters = <String, dynamic>{
        "apikey": apiKey,
        "text": query,
        "sessiontoken": sessionToken,
        "lang": _normalizeLang(lang),
        "results": results,
        "print_address": "1",
        "bbox": defaultBBox,
        "types": "geo,street,house,district,metro",
      };

      final logLine =
          "request text=\"$query\" lang=${queryParameters["lang"]} "
          "session=${sessionToken.substring(0, 8)}… "
          "key=${_maskApiKey(apiKey)}";
      _logTerminal(logLine);
      logger.d("Geosuggest $logLine");

      final response = await _dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: queryParameters,
      );

      final suggestions = parseSuggestions(response.data);
      final responseLine =
          "response status=${response.statusCode} count=${suggestions.length}";
      _logTerminal(responseLine);
      logger.d("Geosuggest $responseLine");
      if (kDebugMode && response.data != null) {
        logger.d("Geosuggest raw: ${jsonEncode(response.data)}");
      }

      return YandexGeosuggestFetchResult(suggestions: suggestions);
    } on DioException catch (e, st) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      final message = status == 403
          ? "Geosuggest HTTP 403 — the API key is missing or not licensed for "
              "the Geosuggest API (MapKit keys do not work here). Create a "
              "Geosuggest key at https://developer.tech.yandex.com/ and set "
              "yandex_geosuggest_api_key in Firebase Remote Config."
          : "Geosuggest failed (HTTP $status)";
      _logTerminal("$message body=$body");
      logger.w(
        "Geosuggest failed ← status=$status body=$body",
        error: e,
        stackTrace: st,
      );
      return YandexGeosuggestFetchResult(
        suggestions: const [],
        httpStatus: status,
        errorMessage: message,
      );
    } catch (e, st) {
      const message = "Geosuggest parse/network error";
      _logTerminal("$message: $e");
      logger.w(message, error: e, stackTrace: st);
      return const YandexGeosuggestFetchResult(
        suggestions: [],
        errorMessage: message,
      );
    }
  }

  /// Geosuggest accepts two-letter ISO 639-1 codes (`ru`, `en`, …).
  static String _normalizeLang(String lang) {
    final code = lang.trim().toLowerCase();
    if (code.isEmpty) {
      return "ru";
    }
    return code.length >= 2 ? code.substring(0, 2) : "ru";
  }

  static void _logTerminal(String message) {
    if (kDebugMode) {
      debugPrint("[Geosuggest] $message");
    }
  }

  static List<YandexGeosuggestSuggestion> parseSuggestions(
    Map<String, dynamic>? data,
  ) {
    if (data == null) {
      return const [];
    }

    final rawResults = data["results"];
    if (rawResults is! List) {
      return const [];
    }

    final suggestions = <YandexGeosuggestSuggestion>[];
    for (final item in rawResults) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final parsed = _parseSuggestion(item);
      if (parsed != null) {
        suggestions.add(parsed);
      }
    }
    return suggestions;
  }

  static YandexGeosuggestSuggestion? _parseSuggestion(Map<String, dynamic> item) {
    final address = item["address"];
    String? formattedAddress;
    if (address is Map<String, dynamic>) {
      final formatted = address["formatted_address"];
      if (formatted is String && formatted.trim().isNotEmpty) {
        formattedAddress = formatted.trim();
      }
    }

    final title = item["title"];
    String? titleText;
    if (title is Map<String, dynamic>) {
      final text = title["text"];
      if (text is String && text.trim().isNotEmpty) {
        titleText = text.trim();
      }
    }

    final displayText = formattedAddress ?? titleText;
    if (displayText == null || displayText.isEmpty) {
      return null;
    }

    final subtitle = item["subtitle"];
    String? subtitleText;
    if (subtitle is Map<String, dynamic>) {
      final text = subtitle["text"];
      if (text is String && text.trim().isNotEmpty) {
        subtitleText = text.trim();
      }
    }

    return YandexGeosuggestSuggestion(
      displayText: displayText,
      subtitle: subtitleText,
    );
  }

  static String _maskApiKey(String key) {
    if (key.length <= 8) {
      return "***";
    }
    return "${key.substring(0, 4)}…${key.substring(key.length - 4)}";
  }
}
