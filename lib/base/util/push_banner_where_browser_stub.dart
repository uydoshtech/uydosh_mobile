/// Web browser hint for the notifications push-enable banner (stub).
enum PushBannerWebBrowser { chrome, safari, firefox, edge, unknown }

PushBannerWebBrowser detectPushBannerWebBrowser() =>
    PushBannerWebBrowser.unknown;
