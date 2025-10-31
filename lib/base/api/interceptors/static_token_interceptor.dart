import "package:dio/dio.dart";

class StaticTokenInterceptor extends Interceptor {
  const StaticTokenInterceptor(this.token);

  final String token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers["authorization"] = "Bearer $token";
    super.onRequest(options, handler);
  }
}
