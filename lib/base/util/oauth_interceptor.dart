/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "dart:async";

import "package:dio/dio.dart";
import "package:uy_dosh/base/api/auth_token_repository_i.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/logger/log_config.dart";
import "package:uy_dosh/base/services/session_expired_handler.dart";

class CustomOAuthInterceptor extends Interceptor {
  const CustomOAuthInterceptor({required this.tokenRepo, required this.dio});

  static const String retryKey = "retry";
  final IAuthTokenRepository tokenRepo;
  final Dio dio;

  static bool get _shouldLogRequestResponse {
    // Never print request headers/bodies unless explicitly enabled, and
    // keep it debug-only even if someone flips flags in release.
    return LogConfig.instance.enableRequestResponse &&
        LogConfig.instance.logLevel == AppLogLevel.verbose;
  }

  static Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final redacted = <String, dynamic>{...headers};
    for (final k in headers.keys) {
      if (k.toLowerCase() == "authorization") {
        redacted[k] = "<redacted>";
      }
      if (k.toLowerCase() == "cookie") {
        redacted[k] = "<redacted>";
      }
    }
    return redacted;
  }

  /// Avoid logging multi‑MB bodies (e.g. room-scan `usdzData`) — causes freezes/OOM in debug.
  static Object? _requestDataForLog(dynamic data) {
    if (data is Map) {
      final usdz = data["usdzData"];
      if (usdz is String && usdz.length > 2000) {
        return "<Map with usdzData: ${usdz.length} chars (omitted)>";
      }
      final imageData = data["imageData"];
      if (imageData is String && imageData.length > 2000) {
        return "<Map with imageData: ${imageData.length} chars (omitted)>";
      }
    }
    if (data is String && data.length > 2000) {
      return "<String body: ${data.length} chars (omitted)>";
    }
    return data;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldLogRequestResponse) {
      logger.v(
        "🔑 OAuthInterceptor: ${options.method} ${options.path}",
      );
      logger.v("🔑 OAuthInterceptor: Full URL: ${options.uri}");
      logger.v(
        "🔑 OAuthInterceptor: Request headers before auth: ${_redactHeaders(options.headers)}",
      );
      logger.v(
        "🔑 OAuthInterceptor: Request data: ${_requestDataForLog(options.data)}",
      );
      logger.v(
        "🔑 OAuthInterceptor: Request query parameters: ${options.queryParameters}",
      );
    }

    await _addAuth(options);

    if (_shouldLogRequestResponse) {
      logger.v(
        "🔑 OAuthInterceptor: Request headers after auth: ${_redactHeaders(options.headers)}",
      );
      final authHeader = options.headers["Authorization"];
      logger.v(
        "🔑 OAuthInterceptor: Authorization header set: ${authHeader != null && authHeader.toString().isNotEmpty ? "yes" : "no"}",
      );
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[retryKey] == true;

    if (statusCode != 401) {
      final request = <String, dynamic>{
        "method": err.requestOptions.method,
        "path": err.requestOptions.path,
      };
      if (_shouldLogRequestResponse) {
        request["headers"] = _redactHeaders(err.requestOptions.headers);
        request["data"] = _requestDataForLog(err.requestOptions.data);
        request["queryParameters"] = err.requestOptions.queryParameters;
      }
      logger.e(
        {
          "request": request,
          "statusCode": statusCode,
          "response": _shouldLogRequestResponse ? err.response?.data : "<omitted>",
        },
        error: err,
      );
      return super.onError(err, handler);
    }

    // If the user has no session token at all, a 401 is expected and should
    // NOT be treated as "session expired". This prevents forcing the auth
    // wizard right after onboarding (or for signed-out browsing on Home).
    final hasTokens = await tokenRepo.hasTokens();
    if (!hasTokens) {
      logger.d({
        "request": {
          "method": err.requestOptions.method,
          "path": err.requestOptions.path,
        },
        "statusCode": statusCode,
        "note": "401 with no local tokens — skipping session-expired redirect",
      });
      return super.onError(err, handler);
    }

    if (alreadyRetried) {
      logger.e({
        "request": {
          "method": err.requestOptions.method,
          "path": err.requestOptions.path,
        },
        "statusCode": statusCode,
        "response": err.response?.data,
        "note": "401 after retry — session is dead, forcing logout",
      }, error: err);
      unawaited(
        SessionExpiredHandler.instance.handle(
          reason: "401 after retry on ${err.requestOptions.path}",
        ),
      );
      return super.onError(err, handler);
    }

    try {
      final refreshed = await tokenRepo.refreshTokens();
      if (!refreshed) {
        logger.d(
          "🚨 OAuthInterceptor: Token refresh not possible, forcing logout",
        );
        unawaited(
          SessionExpiredHandler.instance.handle(
            reason: "refresh returned false on ${err.requestOptions.path}",
          ),
        );
        return super.onError(err, handler);
      }
      final requestOptions = err.requestOptions;
      requestOptions.extra[retryKey] = true;
      if (await _addAuth(requestOptions)) {
        final response = await dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
            extra: requestOptions.extra,
          ),
        );
        return handler.resolve(response);
      }
      logger.e(err, error: err);
      unawaited(
        SessionExpiredHandler.instance.handle(
          reason: "no token after refresh on ${err.requestOptions.path}",
        ),
      );
      return super.onError(err, handler);
    } on Exception catch (error, stackTrace) {
      logger.e(err, error: err, stackTrace: stackTrace);
      if (error is DioException) {
        if (error.response?.statusCode == 401) {
          unawaited(
            SessionExpiredHandler.instance.handle(
              reason:
                  "retry request threw 401 on ${err.requestOptions.path}",
            ),
          );
        }
        return super.onError(error, handler);
      }
    }
  }

  Future<bool> _addAuth(RequestOptions options) async {
    final accessToken = await tokenRepo.getAccessToken();
    if (_shouldLogRequestResponse) {
      logger.v(
        "🔑 OAuthInterceptor: Adding auth to ${options.method} ${options.path}",
      );
      logger.v("🔑 OAuthInterceptor: Token exists: ${accessToken != null}");
    }
    if (accessToken != null) {
      if (_shouldLogRequestResponse) {
        logger.v("🔑 OAuthInterceptor: Token length: ${accessToken.length}");
      }

      // Check if token already has "Bearer " prefix
      String authHeader;
      if (accessToken.startsWith("Bearer ")) {
        authHeader = accessToken;
        if (_shouldLogRequestResponse) {
          logger.v(
            "🔑 OAuthInterceptor: Token already has Bearer prefix, using as-is",
          );
        }
      } else {
        authHeader = "Bearer $accessToken";
        if (_shouldLogRequestResponse) {
          logger.v("🔑 OAuthInterceptor: Adding Bearer prefix to token");
        }
      }

      options.headers["Authorization"] = authHeader;
      if (_shouldLogRequestResponse) {
        logger.v("🔑 OAuthInterceptor: Authorization header updated");
      }
      return true;
    } else {
      if (_shouldLogRequestResponse) {
        logger.v("❌ OAuthInterceptor: No access token available");
      }
    }
    return false;
  }
}
