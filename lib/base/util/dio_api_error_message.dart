import "package:dio/dio.dart";

/// Prefer JSON `{ "error": "..." }` from API error responses (matches backend convention).
String dioApiErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data["error"] is String) {
    final s = (data["error"] as String).trim();
    if (s.isNotEmpty) return s;
  }
  return (e.message ?? e.toString()).trim();
}

/// Display message for failures from API calls or `throw Exception(...)`.
String throwableUserMessage(Object error) {
  if (error is DioException) return dioApiErrorMessage(error);
  var raw = error.toString().trim();
  const prefix = "Exception: ";
  if (raw.startsWith(prefix)) {
    raw = raw.substring(prefix.length).trim();
  }
  return raw.isEmpty ? error.toString() : raw;
}
