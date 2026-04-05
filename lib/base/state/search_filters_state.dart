import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";

// Global search filters state with ChangeNotifier for reactivity
class SearchFiltersState extends ChangeNotifier {
  factory SearchFiltersState() => _instance;
  SearchFiltersState._internal();
  static final SearchFiltersState _instance = SearchFiltersState._internal();

  int _selectedListingTypeId = 2; // Default to roommate needed
  int _selectedLocationIndex = 0;
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedStationId =
      0; // Store the actual station ID instead of just index
  int _selectedGender = 1; // 1 = male, 2 = female
  double _minPrice = 10.0; // Default min price
  double _maxPrice = 500.0; // Default max price
  bool _privateRoom = false; // Default to false (show all)
  bool _withPhoto = false;
  bool _isInitialized = false;
  bool _profileDefaultsApplied = false;

  int get selectedListingTypeId => _selectedListingTypeId;
  int get selectedLocationIndex => _selectedLocationIndex;
  int get selectedSubwayLine => _selectedSubwayLine;
  int get selectedStationIndex => _selectedStationIndex;
  int get selectedStationId => _selectedStationId; // Getter for station ID
  int get selectedGender => _selectedGender;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get privateRoom => _privateRoom;
  bool get withPhoto => _withPhoto;
  bool get isInitialized => _isInitialized;

  // Initialize and load saved search filters from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load listing type ID - use profile default when no saved preference
      final savedListingTypeId = prefs.getInt("search_listing_type_id");
      _selectedListingTypeId = savedListingTypeId ?? 2;

      // Load location index
      _selectedLocationIndex = prefs.getInt("search_location_index") ?? 0;

      // Load subway line
      _selectedSubwayLine = prefs.getInt("search_subway_line") ?? 0;
      logger.d(
        "DEBUG: SearchFiltersState.initialize - loaded subway line from SharedPreferences: $_selectedSubwayLine",
      );

      // Load station index (for backward compatibility)
      _selectedStationIndex = prefs.getInt("search_station_index") ?? 0;
      logger.d(
        "DEBUG: SearchFiltersState.initialize - loaded station index from SharedPreferences: $_selectedStationIndex",
      );

      // Load station ID (new field)
      _selectedStationId = prefs.getInt("search_station_id") ?? 0;
      logger.d(
        "DEBUG: SearchFiltersState.initialize - loaded station ID from SharedPreferences: $_selectedStationId",
      );

      // Load gender - use profile default when no saved preference
      final savedGender = prefs.getInt("search_gender");
      _selectedGender = savedGender ?? 1;

      // Load price range
      _minPrice = prefs.getDouble("search_min_price") ?? 10.0;
      _maxPrice = prefs.getDouble("search_max_price") ?? 500.0;

      // Load private room preference
      _privateRoom = prefs.getBool("search_private_room") ?? false;

      _withPhoto = prefs.getBool("search_with_photo") ?? false;

      // Mark whether we need to apply profile defaults (when no saved values)
      _profileDefaultsApplied = savedListingTypeId != null && savedGender != null;

      logger.d(
        "Loaded saved search filters: listingType=$_selectedListingTypeId, location=$_selectedLocationIndex, line=$_selectedSubwayLine, stationIndex=$_selectedStationIndex, stationId=$_selectedStationId, gender=$_selectedGender, priceRange=$_minPrice-$_maxPrice, privateRoom=$_privateRoom, withPhoto=$_withPhoto",
      );
    } catch (e) {
      logger.d("Error loading saved search filters: $e");
      // Keep default values if there's an error
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Applies profile-based defaults for listing type and gender when no saved
  /// preferences exist. Call after dependency injection is configured (e.g. from
  /// HomeScreen). Only applies for logged-in users.
  Future<void> ensureProfileDefaultsApplied() async {
    if (_profileDefaultsApplied) return;
    if (!await SessionManager.isAuthenticated()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedListingTypeId = prefs.getInt("search_listing_type_id");
      final savedGender = prefs.getInt("search_gender");

      var updated = false;

      // Apply listing type from profile role when no saved preference
      if (savedListingTypeId == null) {
        final role = await _getUserRole();
        final defaultType = role == "tenant" ? 2 : 1; // tenant=Need roommate (2), landlord=Needs Room (1)
        _selectedListingTypeId = defaultType;
        await prefs.setInt("search_listing_type_id", defaultType);
        updated = true;
        logger.d(
          "SearchFiltersState: Applied profile listing type default: $defaultType (role: $role)",
        );
      }

      // Apply gender from profile when no saved preference
      if (savedGender == null) {
        final gender = await _getProfileGender();
        if (gender != null && (gender == 1 || gender == 2)) {
          _selectedGender = gender;
          await prefs.setInt("search_gender", gender);
          updated = true;
          logger.d(
            "SearchFiltersState: Applied profile gender default: $gender",
          );
        }
      }

      if (updated) {
        _profileDefaultsApplied = true;
        notifyListeners();
      }
    } catch (e) {
      logger.d("Error applying profile defaults to search filters: $e");
    }
  }

  /// Fills in listing type and gender from profile only when the user has no
  /// saved search preference yet. Call before opening the search sheet so first-
  /// time users see sensible defaults; do not overwrite an explicit choice from
  /// a previous search (that caused the picker to snap back to profile gender
  /// and could reset listing type so searches returned no rows).
  Future<void> applyProfileValuesForSearchSheet() async {
    if (!await SessionManager.isAuthenticated()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedListingTypeId = prefs.getInt("search_listing_type_id");
      final savedGender = prefs.getInt("search_gender");

      if (savedListingTypeId == null) {
        final role = await _getUserRole();
        final defaultType =
            role == "tenant" ? 2 : 1; // tenant=Need roommate (2), landlord=Needs Room (1)
        await setListingTypeId(defaultType);
      }

      if (savedGender == null) {
        final gender = await _getProfileGender();
        if (gender != null && (gender == 1 || gender == 2)) {
          await setGender(gender);
        }
      }
    } catch (e) {
      logger.d("Error applying profile values for search sheet: $e");
    }
  }

  Future<String?> _getUserRole() async {
    var role = await SessionManager.getUserRole();
    if (role != null) return role;
    try {
      final response = await getIt<IOAuthApiClient>()
          .post<Map<String, dynamic>, _EmptyRequest>(
            "/users/verify-session",
            (json) => json as Map<String, dynamic>,
            data: _EmptyRequest(),
          );
      final user = response["user"];
      role = user is Map<String, dynamic> ? user["role"] as String? : null;
      if (role != null) await SessionManager.storeUserRole(role);
      return role;
    } catch (_) {
      return null;
    }
  }

  Future<int?> _getProfileGender() async {
    var profile = await SessionManager.getCachedUserProfile();
    if (profile?.gender != null &&
        (profile!.gender == 1 || profile.gender == 2)) {
      return profile.gender;
    }
    try {
      profile = await getIt<IUserProfileService>().getCurrentUserProfile();
      if (profile.gender != null &&
          (profile.gender == 1 || profile.gender == 2)) {
        return profile.gender;
      }
    } catch (_) {}
    return null;
  }

  // Update listing type ID
  Future<void> setListingTypeId(int listingTypeId) async {
    _selectedListingTypeId = listingTypeId;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("search_listing_type_id", listingTypeId);
    } catch (e) {
      logger.d("Error saving listing type ID: $e");
    }

    notifyListeners();
  }

  // Update location index
  Future<void> setLocationIndex(int locationIndex) async {
    _selectedLocationIndex = locationIndex;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("search_location_index", locationIndex);
    } catch (e) {
      logger.d("Error saving location index: $e");
    }

    notifyListeners();
  }

  // Update subway line
  Future<void> setSubwayLine(int subwayLine) async {
    logger.d(
      "DEBUG: SearchFiltersState.setSubwayLine - saving subway line: $subwayLine",
    );
    _selectedSubwayLine = subwayLine;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("search_subway_line", subwayLine);
      logger.d(
        "DEBUG: SearchFiltersState.setSubwayLine - saved to SharedPreferences: $subwayLine",
      );
    } catch (e) {
      logger.d("Error saving subway line: $e");
    }

    notifyListeners();
  }

  // Update station index
  Future<void> setStationIndex(int stationIndex) async {
    logger.d(
      "DEBUG: SearchFiltersState.setStationIndex - saving station index: $stationIndex",
    );
    _selectedStationIndex = stationIndex;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("search_station_index", stationIndex);
      logger.d(
        "DEBUG: SearchFiltersState.setStationIndex - saved to SharedPreferences: $stationIndex",
      );
    } catch (e) {
      logger.d("Error saving station index: $e");
    }

    notifyListeners();
  }

  // Update station ID (new method)
  Future<void> setStationId(int stationId) async {
    logger.d(
      "DEBUG: SearchFiltersState.setStationId - saving station ID: $stationId",
    );
    _selectedStationId = stationId;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("search_station_id", stationId);
      logger.d(
        "DEBUG: SearchFiltersState.setStationId - saved to SharedPreferences: $stationId",
      );
    } catch (e) {
      logger.d("Error saving station ID: $e");
    }

    notifyListeners();
  }

  // Update gender
  Future<void> setGender(int gender) async {
    _selectedGender = gender;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("search_gender", gender);
    } catch (e) {
      logger.d("Error saving gender: $e");
    }

    notifyListeners();
  }

  // Update price range
  Future<void> setPriceRange(double minPrice, double maxPrice) async {
    _minPrice = minPrice;
    _maxPrice = maxPrice;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble("search_min_price", minPrice);
      await prefs.setDouble("search_max_price", maxPrice);
    } catch (e) {
      logger.d("Error saving price range: $e");
    }

    notifyListeners();
  }

  // Update private room preference
  Future<void> setPrivateRoom(bool privateRoom) async {
    _privateRoom = privateRoom;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("search_private_room", privateRoom);
    } catch (e) {
      logger.d("Error saving private room preference: $e");
    }

    notifyListeners();
  }

  Future<void> setWithPhoto(bool withPhoto) async {
    _withPhoto = withPhoto;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("search_with_photo", withPhoto);
    } catch (e) {
      logger.d("Error saving with-photo preference: $e");
    }

    notifyListeners();
  }

  // Clear all search filters
  Future<void> clearAllFilters() async {
    _selectedListingTypeId = 2;
    _selectedLocationIndex = 0;
    _selectedSubwayLine = 0;
    _selectedStationIndex = 0;
    _selectedStationId = 0;
    _selectedGender = 1;
    _profileDefaultsApplied = false; // Allow profile defaults to re-apply
    _minPrice = 10.0;
    _maxPrice = 500.0;
    _privateRoom = false;
    _withPhoto = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("search_listing_type_id");
      await prefs.remove("search_location_index");
      await prefs.remove("search_subway_line");
      await prefs.remove("search_station_index");
      await prefs.remove("search_station_id");
      await prefs.remove("search_gender");
      await prefs.remove("search_min_price");
      await prefs.remove("search_max_price");
      await prefs.remove("search_private_room");
      await prefs.remove("search_with_photo");
    } catch (e) {
      logger.d("Error clearing search filters: $e");
    }

    notifyListeners();
  }
}

class _EmptyRequest implements IJsonEncodable {
  _EmptyRequest();

  @override
  Map<String, dynamic> toJson() => {};
}
