import "package:flutter/material.dart";

/// Notifies only listeners for a single listing id (used by [FavoritesState.listenableFor]).
class _ListingFavoriteNotifier extends ChangeNotifier {}

// Global favorites state with ChangeNotifier for reactivity
class FavoritesState extends ChangeNotifier {
  factory FavoritesState() => _instance;
  FavoritesState._internal();
  static final FavoritesState _instance = FavoritesState._internal();

  final Set<int> _favoriteListingIds = {};
  final Map<int, _ListingFavoriteNotifier> _notifiers = {};
  bool _isInitialized = false;

  Set<int> get favoriteListingIds => Set.from(_favoriteListingIds);
  bool get isInitialized => _isInitialized;

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
