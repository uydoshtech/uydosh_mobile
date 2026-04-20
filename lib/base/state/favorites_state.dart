import "package:flutter/material.dart";
import "package:uy_dosh/domain/models/listing.dart";

/// Notifies only listeners for a single listing id (used by [FavoritesState.listenableFor]).
class _ListingFavoriteNotifier extends ChangeNotifier {}

/// Lightweight notifier used as a "dirty" signal for Favorites screen refresh.
class _FavoritesDirtyNotifier extends ChangeNotifier {}

// Global favorites state with ChangeNotifier for reactivity
class FavoritesState extends ChangeNotifier {
  factory FavoritesState() => _instance;
  FavoritesState._internal();
  static final FavoritesState _instance = FavoritesState._internal();

  final Set<int> _favoriteListingIds = {};
  final Map<int, _ListingFavoriteNotifier> _notifiers = {};
  final _FavoritesDirtyNotifier _dirtyNotifier = _FavoritesDirtyNotifier();
  int _dirtyTick = 0;
  bool _isInitialized = false;

  Set<int> get favoriteListingIds => Set.from(_favoriteListingIds);
  bool get isInitialized => _isInitialized;

  /// Bumped when favorites need re-fetching from backend (e.g. user favorited
  /// a listing from Home; Favorites screen should refresh on next view).
  Listenable get dirtyListenable => _dirtyNotifier;

  bool get isDirty => _dirtyTick > 0;

  void markDirty() {
    _dirtyTick++;
    _dirtyNotifier.notifyListeners();
  }

  void clearDirty() {
    if (_dirtyTick == 0) return;
    _dirtyTick = 0;
    _dirtyNotifier.notifyListeners();
  }

  /// Notifies only when [listingId]'s favorite flag changes — use with [ListenableBuilder]
  /// so unrelated listing tiles do not rebuild on other favorites' toggles.
  Listenable listenableFor(int listingId) {
    return _notifiers.putIfAbsent(listingId, _ListingFavoriteNotifier.new);
  }

  void _notifyListingChanged(int listingId) {
    final n = _notifiers[listingId];
    if (n == null) return;
    n.notifyListeners();
    if (!n.hasListeners) {
      _notifiers.remove(listingId);
    }
  }

  // Check if a listing is favorited
  bool isFavorite(int listingId) {
    return _favoriteListingIds.contains(listingId);
  }

  // Initialize favorites state
  Future<void> initialize() async {
    if (_isInitialized) return;

    // TODO: Load favorites from database instead of local storage
    // This method should be updated to fetch favorites from the database

    _isInitialized = true;
    notifyListeners();
  }

  // Toggle favorite status for a listing
  Future<void> toggleFavorite(int listingId) async {
    if (_favoriteListingIds.contains(listingId)) {
      _favoriteListingIds.remove(listingId);
    } else {
      _favoriteListingIds.add(listingId);
    }

    // TODO: Update database instead of local storage
    // This method should be updated to sync with the database

    _notifyListingChanged(listingId);
  }

  // Add a listing to favorites
  Future<void> addToFavorites(int listingId) async {
    if (!_favoriteListingIds.contains(listingId)) {
      _favoriteListingIds.add(listingId);

      // TODO: Update database instead of local storage
      // This method should be updated to sync with the database

      _notifyListingChanged(listingId);
    }
  }

  // Remove a listing from favorites
  Future<void> removeFromFavorites(int listingId) async {
    if (_favoriteListingIds.contains(listingId)) {
      _favoriteListingIds.remove(listingId);

      // TODO: Update database instead of local storage
      // This method should be updated to sync with the database

      _notifyListingChanged(listingId);
    }
  }

  /// Seeds the favorites set from a batch of listings that carry the server-side
  /// [Listing.isFavorited] flag (e.g. home feed response). Listings whose
  /// [Listing.isFavorited] is null are ignored (endpoints that don't enrich the
  /// field should leave existing local state untouched).
  void syncFromListings(Iterable<Listing> listings) {
    for (final listing in listings) {
      final flag = listing.isFavorited;
      if (flag == null) continue;
      final wasFavorite = _favoriteListingIds.contains(listing.id);
      if (flag && !wasFavorite) {
        _favoriteListingIds.add(listing.id);
        _notifyListingChanged(listing.id);
      } else if (!flag && wasFavorite) {
        _favoriteListingIds.remove(listing.id);
        _notifyListingChanged(listing.id);
      }
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    final affected = List<int>.from(_favoriteListingIds);
    _favoriteListingIds.clear();

    // TODO: Update database instead of local storage
    // This method should be updated to sync with the database

    for (final id in affected) {
      _notifyListingChanged(id);
    }
    notifyListeners();
  }
}
