import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class ErrorMessageHelper {
  /// Sanitizes error messages to remove technical details and provide user-friendly text
  static String sanitizeErrorMessage(dynamic error, {BuildContext? context}) {
    if (error == null) return "An unexpected error occurred";

    // Handle DioException specifically
    if (error is DioException) {
      return _handleDioException(error, context: context);
    }

    // Handle other exceptions
    if (error is Exception) {
      return _handleGenericException(error);
    }

    // Handle string errors
    if (error is String) {
      return _sanitizeStringError(error);
    }

    // Default case
    return "An unexpected error occurred";
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
          return "Invalid request. Please check your input and try again.";
        case 401:
          return "Authentication required. Please log in again.";
        case 403:
          return "Access denied. You don't have permission to perform this action.";
        case 404:
          return "The requested resource was not found.";
        case 409:
          return "This resource already exists or conflicts with current data.";
        case 422:
          return "Invalid data provided. Please check your input.";
        case 429:
          return "Too many requests. Please wait a moment and try again.";
        case 500:
          return "Server error. Please try again later.";
        case 502:
        case 503:
        case 504:
          return "Service temporarily unavailable. Please try again later.";
        default:
          break;
      }
    }

    // Handle specific DioException types
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Request timed out. Please check your internet connection and try again.";
      case DioExceptionType.connectionError:
        return "No internet connection. Please check your network settings.";
      case DioExceptionType.badResponse:
        // Use the status code handling above, or fall back to generic message
        return "Unable to complete the request. Please try again.";
      case DioExceptionType.cancel:
        return "Request was cancelled.";
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
        return "Unable to complete the request. Please try again.";
      }
      return message;
    }

    return "Unable to complete the request. Please try again.";
  }

  /// Handles generic exceptions
  static String _handleGenericException(Exception error) {
    final errorString = error.toString();

    // Filter out technical exception details
    if (errorString.contains("Exception") &&
        (errorString.contains("bad response") ||
            errorString.contains("status code") ||
            errorString.contains("RequestOptions.validateStatus"))) {
      return "Unable to complete the request. Please try again.";
    }

    // For other exceptions, provide a generic message
    return "An error occurred. Please try again.";
  }

  /// Sanitizes string error messages
  static String _sanitizeStringError(String error) {
    // Filter out technical error details
    if (error.contains("DioException") ||
        error.contains("bad response") ||
        error.contains("status code") ||
        error.contains("RequestOptions.validateStatus") ||
        error.contains("This exception was thrown because")) {
      return "Unable to complete the request. Please try again.";
    }

    return error;
  }
}
