import "package:dio/dio.dart";
import "package:uy_dosh/base/api/dio_configurator.dart";
import "package:uy_dosh/base/logger/pretty_dio_logger.dart";
import "package:uy_dosh/base/util/dio/error/error_interceptor.dart";

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
    if (useLogger ?? this.useLogger) {
      dio.interceptors.add(prettyDioLogger);
    }
    dio.options.connectTimeout = connectTimeout ?? this.connectTimeout;
    dio.options.receiveTimeout = receiveTimeout ?? this.receiveTimeout;
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
