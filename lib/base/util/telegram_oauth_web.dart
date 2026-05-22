// ignore: avoid_web_libraries_in_flutter
import "dart:html" as html;

/// Origin (+ path) of the Flutter web app for Telegram OAuth `return_to`.
String? telegramOAuthWebReturnTo() {
  final base = Uri.parse(html.window.location.href);
  return Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: base.path.isEmpty ? "/" : base.path,
  ).toString();
}

/// Strip Telegram OAuth query params after the app consumes them.
void clearTelegramOAuthQueryFromBrowserUrl() {
  final base = Uri.parse(html.window.location.href);
  if (!base.queryParameters.containsKey("session_token") &&
      !base.queryParameters.containsKey("error")) {
    return;
  }
  final cleaned = Uri(
    scheme: base.scheme,
    host: base.host,
    port: base.hasPort ? base.port : null,
    path: base.path,
    fragment: base.fragment,
  );
  html.window.history.replaceState(null, "", cleaned.toString());
}
