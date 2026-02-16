import "package:flutter/material.dart";

// Global favorites state with ChangeNotifier for reactivity
class FavoritesState extends ChangeNotifier {
  factory FavoritesState() => _instance;
  FavoritesState._internal();
  static final FavoritesState _instance = FavoritesState._internal();

  final Set<int> _favoriteListingIds = {};
  bool _isInitialized = false;

  Set<int> get favoriteListingIds => Set.from(_favoriteListingIds);
  bool get isInitialized => _isInitialized;

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

    notifyListeners();
  }

  // Add a listing to favorites
  Future<void> addToFavorites(int listingId) async {
    if (!_favoriteListingIds.contains(listingId)) {
      _favoriteListingIds.add(listingId);

      // TODO: Update database instead of local storage
      // This method should be updated to sync with the database

      notifyListeners();
    }
  }

  // Remove a listing from favorites
  Future<void> removeFromFavorites(int listingId) async {
    if (_favoriteListingIds.contains(listingId)) {
      _favoriteListingIds.remove(listingId);

      // TODO: Update database instead of local storage
      // This method should be updated to sync with the database

      notifyListeners();
    }
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    _favoriteListingIds.clear();

    // TODO: Update database instead of local storage
    // This method should be updated to sync with the database

    notifyListeners();
  }
}
