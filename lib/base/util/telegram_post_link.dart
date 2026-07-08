import "package:url_launcher/url_launcher.dart";

/// A resolved Telegram post link: an in-app `tg://` deep link plus the
/// universal `https://t.me/...` fallback.
class TelegramPostLink {
  const TelegramPostLink({required this.appUri, required this.webUri});

  final Uri appUri;
  final Uri webUri;
}

/// Builds the deep link + web fallback for a specific Telegram message, from
/// the raw ingestion metadata captured at scrape time (`chatKey` +
/// `telegramMessageId` on `ParserRawSource`). Mirrors the link formats from
/// https://core.telegram.org/api/links#message-links.
///
/// - Public channels: `chatKey` is an `@handle` (with or without the `@`) ->
///   `tg://resolve?domain=<handle>&post=<id>` / `https://t.me/<handle>/<id>`.
/// - Private channels/supergroups: `chatKey` is the bot-API chat id in
///   `-100xxxxxxxxxx` form -> `tg://privatepost?channel=<id>&post=<id>` /
///   `https://t.me/c/<id>/<id>`.
///
/// Returns `null` when either piece of metadata is missing (e.g. the listing
/// wasn't scraped from Telegram, or the raw source was never captured).
TelegramPostLink? buildTelegramPostLink({
  required String? chatKey,
  required String? telegramMessageId,
}) {
  final key = chatKey?.trim();
  final messageId = telegramMessageId?.trim();
  if (key == null || key.isEmpty || messageId == null || messageId.isEmpty) {
    return null;
  }

  final privateMatch = RegExp(r"^-100(\d+)$").firstMatch(key);
  if (privateMatch != null) {
    final internalId = privateMatch.group(1)!;
    return TelegramPostLink(
      appUri: Uri.parse(
        "tg://privatepost?channel=$internalId&post=$messageId",
      ),
      webUri: Uri.parse("https://t.me/c/$internalId/$messageId"),
    );
  }

  final handle = key.replaceFirst(RegExp(r"^@+"), "");
  if (handle.isEmpty) return null;
  return TelegramPostLink(
    appUri: Uri.parse("tg://resolve?domain=$handle&post=$messageId"),
    webUri: Uri.parse("https://t.me/$handle/$messageId"),
  );
}

/// Opens a resolved [TelegramPostLink], preferring the native app and
/// falling back to the browser. Returns whether anything was launched.
Future<bool> openTelegramPostLink(TelegramPostLink link) async {
  try {
    if (await canLaunchUrl(link.appUri)) {
      final opened = await launchUrl(
        link.appUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return true;
    }
  } catch (_) {}

  try {
    if (await canLaunchUrl(link.webUri)) {
      final opened = await launchUrl(
        link.webUri,
        mode: LaunchMode.externalApplication,
      );
      if (opened) return true;
    }
    return await launchUrl(link.webUri, mode: LaunchMode.platformDefault);
  } catch (_) {
    return false;
  }
}
