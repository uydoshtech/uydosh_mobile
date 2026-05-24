import "dart:convert";

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

/// True when [url] points at Telegram-hosted profile imagery (OIDC `picture`).
bool isTelegramHostedAvatarUrl(String url) {
  final lower = url.trim().toLowerCase();
  if (lower.isEmpty) return false;
  return lower.contains("telegram.org") ||
      lower.contains("t.me/i/userpic") ||
      lower.contains("telesco.pe");
}

/// Reads the Telegram OIDC `picture` claim from a JWT [idToken] without
/// verifying the signature (caller must only use this after a successful bind).
String? telegramPictureUrlFromIdToken(String idToken) {
  try {
    final parts = idToken.split(".");
    if (parts.length < 2) return null;
    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    final map = jsonDecode(payload);
    if (map is! Map) return null;
    final picture = map["picture"];
    if (picture is! String) return null;
    final trimmed = picture.trim();
    if (trimmed.isEmpty) return null;
    return trimmed;
  } catch (_) {
    return null;
  }
}
