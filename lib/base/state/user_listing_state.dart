import "package:flutter/material.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";

// Global user listing state with ChangeNotifier for reactivity
class UserListingState extends ChangeNotifier {
  factory UserListingState() => _instance;
  UserListingState._internal();
  static final UserListingState _instance = UserListingState._internal();

  int? _currentUserId;
  bool _isInitialized = false;

  int? get currentUserId => _currentUserId;
  bool get isInitialized => _isInitialized;

  // Initialize and load current user ID
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _currentUserId = await SessionManager.getUserId();
      logger.d("UserListingState initialized with user ID: $_currentUserId");
    } catch (e) {
      logger.d("Error initializing UserListingState: $e");
      _currentUserId = null;
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Check if current user is the owner of a specific listing
  bool isOwner(int listingUserId) {
    if (!_isInitialized || _currentUserId == null) {
      return false;
    }
    return _currentUserId == listingUserId;
  }

  // Check if current user can add a listing to favorites
  // Owners cannot add their own listings to favorites
  bool canAddToFavorites(int listingUserId) {
    if (!_isInitialized || _currentUserId == null) {
      return false;
    }
    return _currentUserId != listingUserId;
  }

  // Check if current user can edit a listing
  // Only owners can edit their own listings
  bool canEdit(int listingUserId) {
    if (!_isInitialized || _currentUserId == null) {
      return false;
    }
    return _currentUserId == listingUserId;
  }

  // Refresh current user ID (useful after login/logout)
  Future<void> refreshUserId() async {
    try {
      _currentUserId = await SessionManager.getUserId();
      logger.d("UserListingState refreshed with user ID: $_currentUserId");
      notifyListeners();
    } catch (e) {
      logger.d("Error refreshing user ID: $e");
      _currentUserId = null;
      notifyListeners();
    }
  }

  // Clear user ID (useful after logout)
  void clearUserId() {
    _currentUserId = null;
    _isInitialized = false;
    notifyListeners();
  }
}
