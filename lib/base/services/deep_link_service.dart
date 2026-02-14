import "dart:async";

import "package:app_links/app_links.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";

/// Handles deep links (uydosh://listing/123) for sharing listings.
class DeepLinkService {
  DeepLinkService({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;
  int? _pendingListingId;
  StreamSubscription<Uri>? _linkSubscription;

  static const String _scheme = "uydosh";
  static const String _host = "listing";

  /// Builds a shareable deep link URL for a listing.
  static String buildListingDeepLink(int listingId) =>
      "$_scheme://$_host/$listingId";

  /// Parses a URI and returns the listing ID if valid.
  static int? parseListingId(Uri uri) {
    if (uri.scheme != _scheme || uri.host != _host) return null;
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;
    return int.tryParse(segments.first);
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

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
          create: (context) => ListingDetailBloc(getIt<IListingService>()),
          child: ListingDetailScreen(listingId: listingId),
        ),
      ),
    );
  }

  /// Handle pending link (call from MainNavigation when mounted).
  void handlePendingLink() {
    final id = consumePendingListingId();
    if (id != null) {
      _navigateToListing(id);
    }
  }
}
