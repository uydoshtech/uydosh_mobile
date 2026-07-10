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
/// - Channels/supergroups: the ingest worker stores `chatKey` as GramJS's
///   `<type>:<id>` pair (see `serializePeer` in `serializeMessage.ts`), e.g.
///   `"channel:2183690589"` — NOT the Bot API's `-100`-prefixed chat id.
///   `<id>` is already the raw internal id needed by the private-post link
///   formats -> `tg://privatepost?channel=<id>&post=<id>` /
///   `https://t.me/c/<id>/<id>`. GramJS's `channel` peer type covers both
///   broadcast channels and supergroups/megagroups, which is exactly the set
///   `t.me/c/...` message links support.
/// - Bot-API-style `-100xxxxxxxxxx` ids and bare `@handle`s are also
///   accepted as a fallback, in case `chatKey` is ever populated from
///   elsewhere (e.g. manual entry) in that form.
///
/// Returns `null` when either piece of metadata is missing (e.g. the listing
/// wasn't scraped from Telegram, or the raw source was never captured), or
/// when `chatKey` identifies a basic group (`"chat:<id>"`) or private 1:1
/// chat (`"user:<id>"`) — Telegram has no public message-link format for
/// either (`t.me/c/...` only resolves for channels/supergroups).
TelegramPostLink? buildTelegramPostLink({
  required String? chatKey,
  required String? telegramMessageId,
}) {
  final key = chatKey?.trim();
  final messageId = telegramMessageId?.trim();
  if (key == null || key.isEmpty || messageId == null || messageId.isEmpty) {
    return null;
  }

  final typedChannelMatch = RegExp(r"^channel:(\d+)$").firstMatch(key);
  final privateMatch =
      typedChannelMatch ?? RegExp(r"^-100(\d+)$").firstMatch(key);
  if (privateMatch != null) {
    final internalId = privateMatch.group(1)!;
    return TelegramPostLink(
      appUri: Uri.parse(
        "tg://privatepost?channel=$internalId&post=$messageId",
      ),
      webUri: Uri.parse("https://t.me/c/$internalId/$messageId"),
    );
  }

  // `chat:<id>` (basic group) and `user:<id>` (private 1:1 chat) have no
  // shareable post link.
  if (RegExp(r"^(?:chat|user):\d+$").hasMatch(key)) return null;

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
