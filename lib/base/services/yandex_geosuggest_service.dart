import "dart:convert";
import "dart:math" show Random;

import "package:dio/dio.dart";
import "package:flutter/foundation.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";

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
    this.isConnectionError = false,
  });

  final List<YandexGeosuggestSuggestion> suggestions;
  final int? httpStatus;
  final String? errorMessage;
  final bool isConnectionError;

  bool get isAuthError => httpStatus == 403 || httpStatus == 503;
  bool get isConfiguredError =>
      httpStatus == 403 ||
      httpStatus == 503 ||
      (errorMessage != null &&
          errorMessage!.toLowerCase().contains("api key"));
}

/// Client for Yandex Geosuggest address hints.
///
/// Prefers the authenticated backend proxy (`GET /app/geosuggest/suggest`) so
/// the API key stays on the server. Falls back to a direct call to
/// `https://suggest-maps.yandex.ru/v1/suggest` when the proxy is unavailable
/// (older backend builds).
class YandexGeosuggestService {
  YandexGeosuggestService({
    Dio? dio,
    IOAuthApiClient? oauthApiClient,
    String? apiKey,
  })  : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                validateStatus: (status) => status != null && status < 600,
              ),
            ),
        _oauthApiClient = oauthApiClient,
        _apiKey = apiKey ?? AppConfig.yandexGeosuggestApiKey;

  static const directEndpoint = "https://suggest-maps.yandex.ru/v1/suggest";
  static const backendPath = "/app/geosuggest/suggest";

  /// Greater Tashkent — biases suggestions toward the app's primary market.
  static const defaultBBox = "69.05,41.15~69.45,41.42";

  final Dio _dio;
  final IOAuthApiClient? _oauthApiClient;
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

    final backendResult = await _fetchViaBackend(
      text: query,
      sessionToken: sessionToken,
      lang: lang,
      results: results,
    );
    if (backendResult != null) {
      return backendResult;
    }

    // Browser CORS blocks direct calls to suggest-maps.yandex.ru; only the
    // authenticated backend proxy works on Flutter Web.
    if (kIsWeb) {
      return const YandexGeosuggestFetchResult(
        suggestions: [],
        isConnectionError: true,
      );
    }

    return _fetchDirect(
      text: query,
      sessionToken: sessionToken,
      lang: lang,
      results: results,
    );
  }

  Future<YandexGeosuggestFetchResult?> _fetchViaBackend({
    required String text,
    required String sessionToken,
    required String lang,
    required int results,
  }) async {
    final oauthApiClient = _oauthApiClient;
    if (oauthApiClient == null) {
      return null;
    }

    try {
      final uri = _backendUri();
      final requestLine =
          "backend request uri=$uri text=\"$text\" lang=${_normalizeLang(lang)} "
          "session=${sessionToken.substring(0, 8)}…";
      _logTerminal(requestLine);

      final response = await oauthApiClient.dio.get<Map<String, dynamic>>(
        uri,
        queryParameters: <String, dynamic>{
          "text": text,
          "sessiontoken": sessionToken,
          "lang": _normalizeLang(lang),
          "results": results,
        },
        options: Options(
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      final status = response.statusCode;
      if (status == 404) {
        _logTerminal("backend proxy missing (HTTP 404) — falling back to direct");
        return null;
      }

      final data = response.data;
      if (status != null && status >= 200 && status < 300) {
        final suggestions = parseSuggestions(data);
        final responseLine =
            "backend response status=$status count=${suggestions.length}";
        _logTerminal(responseLine);
        return YandexGeosuggestFetchResult(suggestions: suggestions);
      }

      final message = _messageFromBackendBody(data, status);
      _logTerminal("$message body=$data");
      logger.w("Geosuggest backend failed ← status=$status body=$data");
      return YandexGeosuggestFetchResult(
        suggestions: const [],
        httpStatus: status,
        errorMessage: message,
        isConnectionError: status == null,
      );
    } on DioException catch (e, st) {
      final status = e.response?.statusCode;
      if (status == 404) {
        _logTerminal("backend proxy missing (HTTP 404) — falling back to direct");
        return null;
      }
      if (_shouldFallbackToDirect(e)) {
        _logTerminal(
          "backend unreachable (${e.type}) — falling back to direct",
        );
        return null;
      }

      final message = _messageFromBackendBody(
        e.response?.data is Map<String, dynamic>
            ? e.response!.data as Map<String, dynamic>
            : null,
        status,
      );
      _logTerminal(message);
      logger.w(
        "Geosuggest backend failed ← status=$status",
        error: e,
        stackTrace: st,
      );
      return YandexGeosuggestFetchResult(
        suggestions: const [],
        httpStatus: status,
        errorMessage: message,
        isConnectionError: e.response == null,
      );
    } catch (e, st) {
      _logTerminal("backend parse error: $e");
      logger.w("Geosuggest backend parse error", error: e, stackTrace: st);
      return null;
    }
  }

  Future<YandexGeosuggestFetchResult> _fetchDirect({
    required String text,
    required String sessionToken,
    required String lang,
    required int results,
  }) async {
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
        "text": text,
        "sessiontoken": sessionToken,
        "lang": _normalizeLang(lang),
        "results": results,
        "print_address": "1",
        "bbox": defaultBBox,
        "types": "geo,street,house,district,metro",
      };

      final logLine =
          "direct request text=\"$text\" lang=${queryParameters["lang"]} "
          "session=${sessionToken.substring(0, 8)}… "
          "key=${_maskApiKey(apiKey)}";
      _logTerminal(logLine);

      final response = await _dio.get<Map<String, dynamic>>(
        directEndpoint,
        queryParameters: queryParameters,
      );

      final status = response.statusCode;
      if (status != null && status >= 200 && status < 300) {
        final suggestions = parseSuggestions(response.data);
        final responseLine =
            "direct response status=$status count=${suggestions.length}";
        _logTerminal(responseLine);
        if (kDebugMode && response.data != null) {
          _logTerminal("raw: ${jsonEncode(response.data)}");
        }
        return YandexGeosuggestFetchResult(suggestions: suggestions);
      }

      final message = _messageForHttpStatus(status);
      _logTerminal("$message body=${response.data}");
      logger.w("Geosuggest direct failed ← status=$status body=${response.data}");
      return YandexGeosuggestFetchResult(
        suggestions: const [],
        httpStatus: status,
        errorMessage: message,
      );
    } on DioException catch (e, st) {
      final status = e.response?.statusCode;
      final message = _messageForDioException(e);
      _logTerminal("$message body=${e.response?.data}");
      logger.w(
        "Geosuggest direct failed ← status=$status body=${e.response?.data}",
        error: e,
        stackTrace: st,
      );
      return YandexGeosuggestFetchResult(
        suggestions: const [],
        httpStatus: status,
        errorMessage: message,
        isConnectionError: e.response == null,
      );
    } catch (e, st) {
      const message = "Geosuggest parse/network error";
      _logTerminal("$message: $e");
      logger.w(message, error: e, stackTrace: st);
      return const YandexGeosuggestFetchResult(
        suggestions: [],
        errorMessage: message,
        isConnectionError: true,
      );
    }
  }

  String _backendUri() {
    final base = EnvironmentUtil.basePath;
    return base.endsWith("/") ? "${base}app/geosuggest/suggest" : "$base$backendPath";
  }

  static bool _shouldFallbackToDirect(DioException error) {
    if (kIsWeb) {
      return false;
    }
    if (error.response?.statusCode == 404) {
      return true;
    }
    return error.response == null &&
        (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout);
  }

  static String _messageForHttpStatus(
    int? status, {
    bool configuredOnServer = false,
  }) {
    if (status == 403 || (status == 503 && configuredOnServer)) {
      return "Geosuggest HTTP 403 — the API key is missing or not licensed for "
          "the Geosuggest API (MapKit keys do not work here). Create a "
          "Geosuggest key at https://developer.tech.yandex.com/ and set "
          "YANDEX_GEOSUGGEST_API_KEY on the server or "
          "yandex_geosuggest_api_key in Firebase Remote Config.";
    }
    if (status == null) {
      return "Geosuggest connection failed — check your internet connection.";
    }
    return "Geosuggest failed (HTTP $status)";
  }

  static String _messageFromBackendBody(
    Map<String, dynamic>? data,
    int? status,
  ) {
    if (data != null) {
      final message = data["message"];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
      final error = data["error"];
      if (error is String && error.trim().isNotEmpty) {
        return switch (error.trim()) {
          "geosuggest_not_configured" =>
            "Geosuggest not configured on server — set YANDEX_GEOSUGGEST_API_KEY.",
          "geosuggest_forbidden" =>
            "Yandex rejected the Geosuggest API key — enable the Geosuggest product.",
          "geosuggest_network_error" =>
            "Failed to reach Yandex Geosuggest from server.",
          _ => error.trim(),
        };
      }
    }
    return _messageForHttpStatus(status);
  }

  static String _messageForDioException(DioException error) {
    final status = error.response?.statusCode;
    if (status == 403) {
      return _messageForHttpStatus(status);
    }
    if (error.response == null) {
      return _messageForHttpStatus(null);
    }
    return _messageForHttpStatus(status);
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
    logUiUx(message, tag: "Geosuggest");
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
