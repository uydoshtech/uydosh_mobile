import "package:dio/dio.dart";
import "package:uy_dosh/base/api/auth_token_repository_i.dart";
import "package:uy_dosh/base/api/dio_configurator.dart";
import "package:uy_dosh/base/api/public_dio_configurator.dart";
import "package:uy_dosh/base/util/oauth_interceptor.dart";

abstract interface class IOAuthDioConfigurator implements IDioConfigurator {}

class OAuthDioConfigurator extends PublicDioConfigurator
    implements IOAuthDioConfigurator {
  OAuthDioConfigurator({
    required this.tokenRepo,
    bool useSentry = true,
    bool useLogger = true,
    bool useErrorInterceptor = true,
    Duration connectTimeout = const Duration(seconds: 60),
    Duration receiveTimeout = const Duration(seconds: 60),
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
    super.configure(
      dio,
      useSentry: useSentry,
      useLogger: useLogger,
      useErrorInterceptor: useErrorInterceptor,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    );
    dio.interceptors.add(
      CustomOAuthInterceptor(tokenRepo: tokenRepo, dio: dio),
    );
    return dio;
  }

  final IAuthTokenRepository tokenRepo;
}
