/*
 * Copyright (C) 2024 Finharbor DOO. - All Rights Reserved
 *
 * Unauthorized copying or redistribution of this file in source and binary forms via any medium
 * is strictly prohibited.
 */

import "package:dio/dio.dart";
import "package:injectable/injectable.dart";
import "package:uy_dosh/base/api/auth_token_repository_i.dart";
import "package:uy_dosh/base/logger/logger.dart";

@lazySingleton
class CustomOAuthInterceptor extends Interceptor {
  const CustomOAuthInterceptor({required this.tokenRepo, required this.dio});

  static const String retryKey = "retry";
  final IAuthTokenRepository tokenRepo;
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    logger.d(
      '🔑 OAuthInterceptor: onRequest called for ${options.method} ${options.path}',
    );
    logger.d('🔑 OAuthInterceptor: Full URL: ${options.uri}');
    logger.d(
      '🔑 OAuthInterceptor: Request headers before auth: ${options.headers}',
    );
    logger.d('🔑 OAuthInterceptor: Request method: ${options.method}');
    logger.d('🔑 OAuthInterceptor: Request data: ${options.data}');
    logger.d(
      '🔑 OAuthInterceptor: Request query parameters: ${options.queryParameters}',
    );

    await _addAuth(options);

    logger.d(
      '🔑 OAuthInterceptor: Request headers after auth: ${options.headers}',
    );
    logger.d(
      '🔑 OAuthInterceptor: Authorization header: ${options.headers['Authorization']}',
    );
    logger.d(
      '🔑 OAuthInterceptor: Full request options: ${options.toString()}',
    );

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401 ||
        err.requestOptions.extra[retryKey] == true) {
      logger.e({
        "request": {
          "method": err.requestOptions.method,
          "path": err.requestOptions.path,
          "headers": err.requestOptions.headers,
          "data": err.requestOptions.data,
          "queryParameters": err.requestOptions.queryParameters,
        },
        "statusCode": err.response?.statusCode,
        "response": err.response?.data,
      }, error: err);
      return super.onError(err, handler);
    }
    try {
      await tokenRepo.refreshTokens();
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
      return super.onError(err, handler);
    } on Exception catch (error, stackTrace) {
      logger.e(err, error: err, stackTrace: stackTrace);
      if (error is DioException) return super.onError(error, handler);
    }
  }

  Future<bool> _addAuth(RequestOptions options) async {
    final accessToken = await tokenRepo.getAccessToken();
    logger.d(
      '🔑 OAuthInterceptor: Adding auth to ${options.method} ${options.path}',
    );
    logger.d('🔑 OAuthInterceptor: Token exists: ${accessToken != null}');
    if (accessToken != null) {
      logger.d('🔑 OAuthInterceptor: Token length: ${accessToken.length}');
      logger.d(
        '🔑 OAuthInterceptor: Token preview: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...',
      );
      logger.d('🔑 OAuthInterceptor: Full token: $accessToken');

      // Check if token already has "Bearer " prefix
      String authHeader;
      if (accessToken.startsWith('Bearer ')) {
        authHeader = accessToken;
        logger.d(
          '🔑 OAuthInterceptor: Token already has Bearer prefix, using as-is',
        );
      } else {
        authHeader = "Bearer $accessToken";
        logger.d('🔑 OAuthInterceptor: Adding Bearer prefix to token');
      }

      options.headers["Authorization"] = authHeader;
      logger.d(
        '🔑 OAuthInterceptor: Authorization header set: ${authHeader.substring(0, authHeader.length > 20 ? 20 : authHeader.length)}...',
      );
      return true;
    } else {
      logger.d('❌ OAuthInterceptor: No access token available');
    }
    return false;
  }
}
