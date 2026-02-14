import "package:dio/dio.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/dio/error/api_exception.dart";

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError) {
      final newError = DioException(
        requestOptions: err.requestOptions,
        message: L10n.get("error_internet_connection"),
      );
      handler.next(newError);
      return;
    }
    try {
      final apiError = ApiException.fromJson(
        err.response?.data as Map<String, dynamic>,
      );
      final newError = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        message: apiError.message,
        error: apiError,
      );
      handler.next(newError);
    } catch (_) {
      handler.next(err);
    }
  }
}
