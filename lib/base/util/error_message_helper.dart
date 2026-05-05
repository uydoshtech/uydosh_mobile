import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";

class ErrorMessageHelper {
  /// Sanitizes error messages to remove technical details and provide user-friendly text
  static String sanitizeErrorMessage(dynamic error, {BuildContext? context}) {
    if (error == null) {
      return _t(
        context,
        "error_generic_try_again",
        fallback: "An unexpected error occurred. Please try again.",
      );
    }

    // Handle DioException specifically
    if (error is DioException) {
      return _handleDioException(error, context: context);
    }

    // Handle other exceptions
    if (error is Exception) {
      return _handleGenericException(error, context: context);
    }

    // Handle string errors
    if (error is String) {
      return _sanitizeStringError(error, context: context);
    }

    // Default case
    return _t(
      context,
      "error_generic_try_again",
      fallback: "An unexpected error occurred. Please try again.",
    );
  }

  /// Resolves [key] via [L10n] (which reads from the global `LanguageState`
  /// and therefore does not require a [BuildContext]). [context] is kept in
  /// the signature for callers that still pass it, but is no longer used to
  /// decide whether to localize — historically passing `null` here forced the
  /// English [fallback], which is why bloc-emitted error messages (e.g. the
  /// messaging inbox "An error occurred. Please try again.") rendered in
  /// English even when the rest of the app was in Russian.
  static String _t(BuildContext? context, String key, {required String fallback}) {
    return L10n.get(key, fallback: fallback);
  }

  /// Handles DioException and provides user-friendly messages
  static String _handleDioException(
    DioException error, {
    BuildContext? context,
  }) {
    // Handle specific HTTP status codes
    if (error.response?.statusCode != null) {
      switch (error.response!.statusCode) {
        case 400:
          return _t(
            context,
            "error_invalid_request",
            fallback: "Invalid request. Please check your input and try again.",
          );
        case 401:
          return _t(
            context,
            "error_auth_required",
            fallback: "Authentication required. Please log in again.",
          );
        case 403:
          return _t(
            context,
            "error_access_denied",
            fallback:
                "Access denied. You don't have permission to perform this action.",
          );
        case 404:
          return _t(
            context,
            "error_not_found",
            fallback: "The requested resource was not found.",
          );
        case 409:
          return _t(
            context,
            "error_conflict",
            fallback: "This resource already exists or conflicts with current data.",
          );
        case 422:
          return _t(
            context,
            "error_invalid_data",
            fallback: "Invalid data provided. Please check your input.",
          );
        case 429:
          return _t(
            context,
            "error_too_many_requests",
            fallback: "Too many requests. Please wait a moment and try again.",
          );
        case 500:
          return _t(
            context,
            "error_server_try_later",
            fallback: "Server error. Please try again later.",
          );
        case 502:
        case 503:
        case 504:
          return _t(
            context,
            "error_service_unavailable_try_later",
            fallback: "Service temporarily unavailable. Please try again later.",
          );
        default:
          break;
      }
    }

    // Handle specific DioException types
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return _t(
          context,
          "error_timeout_check_connection",
          fallback:
              "Request timed out. Please check your internet connection and try again.",
        );
      case DioExceptionType.connectionError:
        return _t(
          context,
          "error_no_internet",
          fallback: "No internet connection. Please check your network settings.",
        );
      case DioExceptionType.badResponse:
        // Use the status code handling above, or fall back to generic message
        return _t(
          context,
          "error_unable_to_complete_try_again",
          fallback: "Unable to complete the request. Please try again.",
        );
      case DioExceptionType.cancel:
        return _t(
          context,
          "error_request_cancelled",
          fallback: "Request was cancelled.",
        );
      default:
        break;
    }

    // If we have a custom message from the API, use it (but sanitize it)
    if (error.message != null && error.message!.isNotEmpty) {
      final message = error.message!;
      if (message.contains("DioException") ||
          message.contains("bad response") ||
          message.contains("status code") ||
          message.contains("RequestOptions.validateStatus")) {
        return _t(
          context,
          "error_unable_to_complete_try_again",
          fallback: "Unable to complete the request. Please try again.",
        );
      }
      return message;
    }

    return _t(
      context,
      "error_unable_to_complete_try_again",
      fallback: "Unable to complete the request. Please try again.",
    );
  }

  /// Handles generic exceptions
  static String _handleGenericException(
    Exception error, {
    BuildContext? context,
  }) {
    final errorString = error.toString();

    // Filter out technical exception details
    if (errorString.contains("Exception") &&
        (errorString.contains("bad response") ||
            errorString.contains("status code") ||
            errorString.contains("RequestOptions.validateStatus"))) {
      return _t(
        context,
        "error_unable_to_complete_try_again",
        fallback: "Unable to complete the request. Please try again.",
      );
    }

    // For other exceptions, provide a generic message
    return _t(
      context,
      "error_generic_try_again",
      fallback: "An error occurred. Please try again.",
    );
  }

  /// Sanitizes string error messages
  static String _sanitizeStringError(
    String error, {
    BuildContext? context,
  }) {
    // Filter out technical error details
    if (error.contains("DioException") ||
        error.contains("bad response") ||
        error.contains("status code") ||
        error.contains("RequestOptions.validateStatus") ||
        error.contains("This exception was thrown because")) {
      return _t(
        context,
        "error_unable_to_complete_try_again",
        fallback: "Unable to complete the request. Please try again.",
      );
    }

    return error;
  }
}
