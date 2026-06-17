import "dart:async";

import "package:app_links/app_links.dart";
import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/constants/app_domains.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";

/// Payload for `uydosh://auth/telegram-bind` after linking Telegram in the browser.
class TelegramBindDeepLink {
  const TelegramBindDeepLink.ok({this.telegramUsername})
    : errorMessage = null;

  const TelegramBindDeepLink.error(this.errorMessage) : telegramUsername = null;

  final String? errorMessage;
  final String? telegramUsername;

  bool get isError => errorMessage != null && errorMessage!.isNotEmpty;
}

/// Payload for `uydosh://auth/telegram` after Telegram OAuth completes in the browser.
class TelegramAuthDeepLink {
  const TelegramAuthDeepLink.ok({
    required this.sessionToken,
    required this.userId,
    required this.profileExists,
  }) : errorMessage = null;

  const TelegramAuthDeepLink.error(this.errorMessage)
    : sessionToken = null,
      userId = null,
      profileExists = false;

  final String? errorMessage;
  final String? sessionToken;
  final int? userId;
  final bool profileExists;

  bool get isError => errorMessage != null && errorMessage!.isNotEmpty;
}

/// Handles deep links for sharing listings.
/// Uses https:// URLs so messengers (Telegram, WhatsApp) make them clickable.
/// Custom scheme uydosh:// is not recognized by most messengers.
class DeepLinkService {
  DeepLinkService({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;
  int? _pendingListingId;
  TelegramAuthDeepLink? _pendingTelegramAuth;
  StreamSubscription<Uri>? _linkSubscription;

  /// Optional listener for Telegram Login (browser OAuth → app deep link).
  void Function(TelegramAuthDeepLink link)? onTelegramAuthLink;

  /// Optional listener for Telegram account linking (browser OAuth → app deep link).
  void Function(TelegramBindDeepLink link)? onTelegramBindLink;

  static const String _scheme = "uydosh";
  static const String _host = "listing";
  static const String _authHost = "auth";
  static const String _telegramSegment = "telegram";
  static const String _telegramBindSegment = "telegram-bind";

  /// Parses `uydosh://auth/telegram-bind?...` after browser OAuth bind completes.
  static TelegramBindDeepLink? tryParseTelegramBind(Uri uri) {
    if (uri.scheme != _scheme || uri.host != _authHost) return null;
    if (uri.pathSegments.length != 1 ||
        uri.pathSegments.first != _telegramBindSegment) {
      return null;
    }
    return _parseTelegramBindQuery(uri.queryParameters);
  }

  static TelegramBindDeepLink? tryParseTelegramBindFromCurrentLocation() {
    if (!kIsWeb) return null;
    return _parseTelegramBindQuery(Uri.base.queryParameters);
  }

  static TelegramBindDeepLink? _parseTelegramBindQuery(
    Map<String, String> queryParameters,
  ) {
    final bindError = queryParameters["telegram_bind_error"];
    if (bindError != null && bindError.isNotEmpty) {
      return TelegramBindDeepLink.error(bindError);
    }
    final err = queryParameters["error"];
    if (err != null && err.isNotEmpty) {
      return TelegramBindDeepLink.error(err);
    }
    if (queryParameters["telegram_bind"] == "success" ||
        queryParameters["success"] == "1") {
      final username = queryParameters["telegram_username"] ??
          queryParameters["telegram"];
      return TelegramBindDeepLink.ok(
        telegramUsername: username?.trim().isNotEmpty == true
            ? username!.trim()
            : null,
      );
    }
    return null;
  }

  /// Parses `uydosh://auth/telegram?...` returned after OIDC callback.
  static TelegramAuthDeepLink? tryParseTelegramAuth(Uri uri) {
    if (uri.scheme != _scheme || uri.host != _authHost) return null;
    if (uri.pathSegments.length != 1 || uri.pathSegments.first != _telegramSegment) {
      return null;
    }
    return _parseTelegramAuthQuery(uri.queryParameters);
  }

  /// Parses Telegram OAuth query params on Flutter web after backend redirect.
  static TelegramAuthDeepLink? tryParseTelegramAuthFromCurrentLocation() {
    if (!kIsWeb) return null;
    return _parseTelegramAuthQuery(Uri.base.queryParameters);
  }

  static TelegramAuthDeepLink? _parseTelegramAuthQuery(
    Map<String, String> queryParameters,
  ) {
    final err = queryParameters["error"];
    if (err != null && err.isNotEmpty) {
      return TelegramAuthDeepLink.error(err);
    }
    final token = queryParameters["session_token"];
    final uid = int.tryParse(queryParameters["user_id"] ?? "");
    final pe = queryParameters["profile_exists"] == "1";
    if (token == null || token.isEmpty || uid == null) {
      return null;
    }
    return TelegramAuthDeepLink.ok(
      sessionToken: token,
      userId: uid,
      profileExists: pe,
    );
  }

  /// Builds a shareable URL for a listing. Uses https:// so messengers
  /// (Telegram, WhatsApp) make it clickable. Falls back to custom scheme
  /// if shareWebBase is not configured.
  static String buildListingDeepLink(int listingId) =>
      "${EnvironmentUtil.shareWebBase}/listing/$listingId";

  /// Parses a URI and returns the listing ID if valid.
  /// Handles both uydosh://listing/123 and https://api.uydosh.com/listing/123.
  static int? parseListingId(Uri uri) {
    // Custom scheme: uydosh://listing/123
    if (uri.scheme == _scheme && uri.host == _host) {
      final segments = uri.pathSegments;
      if (segments.isEmpty) return null;
      return int.tryParse(segments.first);
    }
    // HTTPS: https://api.uydosh.com/listing/123 (also legacy web hosts)
    if ((uri.scheme == "https" || uri.scheme == "http") &&
        uri.pathSegments.length >= 2 &&
        AppDomains.isListingLinkHost(uri.host)) {
      if (uri.pathSegments.first == _host) {
        return int.tryParse(uri.pathSegments[1]);
      }
    }
    return null;
  }

  /// Initialize listener. Call from main() after configureDependencies.
  Future<void> initialize() async {
    final appLinks = AppLinks();

    // Handle cold start: app opened from link
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      final id = parseListingId(initialUri);
      if (id != null) {
        _pendingListingId = id;
      }
      final tg = tryParseTelegramAuth(initialUri);
      if (tg != null) {
        _pendingTelegramAuth = tg;
      }
    }

    // Handle app resumed from background with link
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
      final tgBind = tryParseTelegramBind(uri);
      if (tgBind != null) {
        onTelegramBindLink?.call(tgBind);
        return;
      }
      final tg = tryParseTelegramAuth(uri);
      if (tg != null) {
        onTelegramAuthLink?.call(tg);
        return;
      }
      final id = parseListingId(uri);
      if (id != null) {
        getIt<AppAnalyticsService>().logDeepLinkOpened(
          listingId: id,
          source: "background",
        );
        _navigateToListing(id);
      }
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Returns and clears the pending listing ID (for cold start handling).
  int? consumePendingListingId() {
    final id = _pendingListingId;
    _pendingListingId = null;
    return id;
  }

  /// Returns and clears pending Telegram auth deep link (cold start).
  TelegramAuthDeepLink? consumePendingTelegramAuth() {
    final p = _pendingTelegramAuth;
    _pendingTelegramAuth = null;
    return p;
  }

  /// Stores a Telegram auth payload for the next auth wizard mount (Flutter web OAuth return).
  void stagePendingTelegramAuth(TelegramAuthDeepLink link) {
    _pendingTelegramAuth = link;
  }

  /// Navigate to listing detail screen.
  void _navigateToListing(int listingId) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    context.pushListingDetail(listingId);
  }

  /// Handle pending link (call from MainNavigation when mounted).
  void handlePendingLink() {
    final id = consumePendingListingId();
    if (id != null) {
      getIt<AppAnalyticsService>().logDeepLinkOpened(
        listingId: id,
        source: "cold_start",
      );
      _navigateToListing(id);
    }
  }
}
