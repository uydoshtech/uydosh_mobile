import "dart:async";

import "package:app_links/app_links.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";

/// Handles deep links for sharing listings.
/// Uses https:// URLs so messengers (Telegram, WhatsApp) make them clickable.
/// Custom scheme uydosh:// is not recognized by most messengers.
class DeepLinkService {
  DeepLinkService({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;
  int? _pendingListingId;
  StreamSubscription<Uri>? _linkSubscription;

  static const String _scheme = "uydosh";
  static const String _host = "listing";

  /// Builds a shareable URL for a listing. Uses https:// so messengers
  /// (Telegram, WhatsApp) make it clickable. Falls back to custom scheme
  /// if shareWebBase is not configured.
  static String buildListingDeepLink(int listingId) =>
      "${EnvironmentUtil.shareWebBase}/listing/$listingId";

  /// Parses a URI and returns the listing ID if valid.
  /// Handles both uydosh://listing/123 and https://uydosh.app/listing/123.
  static int? parseListingId(Uri uri) {
    // Custom scheme: uydosh://listing/123
    if (uri.scheme == _scheme && uri.host == _host) {
      final segments = uri.pathSegments;
      if (segments.isEmpty) return null;
      return int.tryParse(segments.first);
    }
    // HTTPS: https://uydosh.app/listing/123
    if (uri.scheme == "https" && uri.pathSegments.length >= 2) {
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
    }

    // Handle app resumed from background with link
    _linkSubscription = appLinks.uriLinkStream.listen((uri) {
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
