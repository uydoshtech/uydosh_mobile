// ignore: avoid_web_libraries_in_flutter
import "dart:html" as html;

/// Web browser hint for the notifications push-enable banner.
enum PushBannerWebBrowser { chrome, safari, firefox, edge, unknown }

PushBannerWebBrowser detectPushBannerWebBrowser() {
  final ua = html.window.navigator.userAgent;
  if (ua.isEmpty) return PushBannerWebBrowser.unknown;

  if (ua.contains("Edg/")) return PushBannerWebBrowser.edge;
  if (ua.contains("Firefox/")) return PushBannerWebBrowser.firefox;

  // Chrome desktop / Chromium; CriOS = Chrome on iOS.
  if (ua.contains("Chrome/") || ua.contains("CriOS/")) {
    return PushBannerWebBrowser.chrome;
  }

  // Safari (does not include Chrome/ or CriOS/ in typical UA strings).
  if (ua.contains("Safari/")) {
    return PushBannerWebBrowser.safari;
  }

  return PushBannerWebBrowser.unknown;
}
