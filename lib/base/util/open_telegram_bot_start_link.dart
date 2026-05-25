import "package:url_launcher/url_launcher.dart";

/// Opens @uydosh_bot (or any bot) with a `/start` payload in the Telegram app.
Future<bool> openTelegramBotStartLink({
  required String botUsername,
  required String startParam,
  String? httpsUrl,
}) async {
  final domain = botUsername.trim().replaceFirst(RegExp(r"^@"), "");
  if (domain.isEmpty || startParam.trim().isEmpty) return false;

  final encodedStart = Uri.encodeComponent(startParam.trim());
  final tgUri = Uri.parse("tg://resolve?domain=$domain&start=$encodedStart");
  final webUri = Uri.parse(
    httpsUrl?.trim().isNotEmpty == true
        ? httpsUrl!.trim()
        : "https://t.me/$domain?start=$encodedStart",
  );

  try {
    if (await canLaunchUrl(tgUri)) {
      final opened = await launchUrl(tgUri, mode: LaunchMode.externalApplication);
      if (opened) return true;
    }
  } catch (_) {}

  try {
    if (await canLaunchUrl(webUri)) {
      final opened =
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
      if (opened) return true;
    }
    return await launchUrl(webUri, mode: LaunchMode.platformDefault);
  } catch (_) {
    return false;
  }
}
