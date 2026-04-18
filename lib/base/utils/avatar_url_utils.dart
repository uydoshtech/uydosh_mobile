import "package:uy_dosh/base/util/environment_util.dart";

/// Resolves a stored avatar URL to something [CachedNetworkImage] can load.
///
/// The backend stores locally-uploaded avatars as relative paths such as
/// `/images/avatars/avatar_42_1699999999.jpg`. Absolute URLs (e.g. Google
/// profile photos `https://lh3.googleusercontent.com/...`) are returned
/// unchanged. Relative paths are prefixed with [EnvironmentUtil.basePath].
///
/// Returns `null` when [raw] is null, empty, or whitespace.
String? resolveAvatarUrl(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
    return trimmed;
  }
  return "${EnvironmentUtil.basePath}$trimmed";
}
