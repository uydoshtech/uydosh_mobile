import "package:dio/dio.dart";
import "package:uy_dosh/base/localization/l10n.dart";

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

/// Backend code for [group_forming_max_active_memberships] exceeded.
const kGroupMembershipLimitReached = "GROUP_MEMBERSHIP_LIMIT_REACHED";

final _legacyGroupMembershipLimitRe = RegExp(
  r"participate in up to (\d+) active groups",
  caseSensitive: false,
);

/// Localized “cannot participate in more than N groups” message, or null.
///
/// Pass [forApplicant] when the viewer is approving someone else’s join request.
String? groupMembershipLimitUserMessage(
  Object error, {
  bool forApplicant = false,
}) {
  String? code;
  int? limit;

  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      code = data["error"]?.toString();
      final rawLimit = data["limit"];
      if (rawLimit is num) {
        limit = rawLimit.toInt();
      } else if (rawLimit is String) {
        limit = int.tryParse(rawLimit);
      }
    }
  } else {
    code = throwableUserMessage(error);
  }

  if (code == null || code.isEmpty) return null;

  if (code == kGroupMembershipLimitReached) {
    // Prefer API `limit`; fall back only if the body omitted it.
    limit ??= 2;
  } else {
    final match = _legacyGroupMembershipLimitRe.firstMatch(code);
    if (match == null) return null;
    limit = int.tryParse(match.group(1)!);
  }

  if (limit == null || limit < 1) return null;

  return L10n.getWithParams(
    forApplicant
        ? "group_membership_limit_reached_applicant"
        : "group_membership_limit_reached",
    params: {"count": "$limit"},
  );
}
