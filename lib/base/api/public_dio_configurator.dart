import "package:dio/dio.dart";
import "package:dio_cache_interceptor/dio_cache_interceptor.dart";
import "package:flutter/foundation.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";
import "package:uy_dosh/base/api/app_cache.dart";
import "package:uy_dosh/base/api/dio_configurator.dart";
import "package:uy_dosh/base/util/dio/error/error_interceptor.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

abstract interface class IPublicDioConfigurator implements IDioConfigurator {}

class PublicDioConfigurator implements IPublicDioConfigurator {
  PublicDioConfigurator({
    this.useSentry = true,
    this.useLogger = true,
    this.useErrorInterceptor = true,
    this.connectTimeout = const Duration(seconds: 60),
    this.receiveTimeout = const Duration(seconds: 60),
  });

  @override
  Dio configure(
    Dio dio, {
    bool? useSentry,
    bool? useLogger,
    bool? useErrorInterceptor,
    Duration? connectTimeout,
    Duration? receiveTimeout,
  }) {
    // Add x-language header so backend returns localized content (universities, etc.)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final language = LanguageState().currentLanguage;
          options.headers["x-language"] = language;
          handler.next(options);
        },
      ),
    );
    // Wrapping in `if (kDebugMode)` lets the Dart AOT tree-shaker drop the
    // entire `package:pretty_dio_logger` from release binaries. The package
    // is still in `dependencies:` (it would fail to compile if it weren't),
    // but with this guard there's no reachable construction site in release
    // mode, so its classes never make it into `libapp.so`.
    if (kDebugMode && (useLogger ?? this.useLogger)) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: false,
          responseBody: false,
          responseHeader: false,
          compact: true,
          maxWidth: 120,
          logPrint: (e) => debugPrint(e.toString()),
        ),
      );
    }
    dio.options.connectTimeout = connectTimeout ?? this.connectTimeout;
    dio.options.receiveTimeout = receiveTimeout ?? this.receiveTimeout;
    // Install the HTTP response cache. Global policy honors server cache
    // directives, so no endpoint is cached by default (the backend doesn't
    // send Cache-Control). Individual requests opt in via
    // `AppCache.longGetOptions()` / `AppCache.shortGetOptions()`.
    dio.interceptors.add(
      DioCacheInterceptor(options: AppCache.defaultOptions),
    );
    if (useErrorInterceptor ?? this.useErrorInterceptor) {
      dio.interceptors.add(ErrorInterceptor());
    }
    return dio;
  }

  final bool useSentry;
  final bool useLogger;
  final bool useErrorInterceptor;
  final Duration connectTimeout;
  final Duration receiveTimeout;
}
