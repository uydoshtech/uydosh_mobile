import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";

void main() {
  test("sanitizeErrorMessage maps connection timeout DioException", () {
    final e = DioException(
      requestOptions: RequestOptions(path: "/test"),
      type: DioExceptionType.connectionTimeout,
      message:
          "The request connection took longer than 0:01:00.000000 and it was aborted.",
    );

    final result = ErrorMessageHelper.sanitizeErrorMessage(e);
    expect(result, isNot(contains("DioException")));
    expect(result, isNot(contains("RequestOptions")));
  });

  test("sanitizeErrorMessage maps DioException string", () {
    const raw =
        "DioException [connection timeout]: The request connection took longer than 0:01:00.000000 and it was aborted.";

    final result = ErrorMessageHelper.sanitizeErrorMessage(raw);
    expect(result, isNot(contains("DioException")));
    expect(result, isNot(contains("RequestOptions")));
  });
}
