import "dart:async" show Timer, unawaited;

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/services/user_search_filters_service.dart";

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
  double _maxPrice = 1000.0; // Default max price
  bool _privateRoom = false; // Default to false (show all)
  bool _withPhoto = false;
  bool _isInitialized = false;
  bool _profileDefaultsApplied = false;
  Future<void> _prefsWriteChain = Future<void>.value();
  bool _suppressRemotePersist = false;
  Timer? _remoteSaveDebounce;
  static const Duration _remoteSaveDelay = Duration(milliseconds: 1600);
  Future<void>? _hydrateFuture;

  /// Clears debounce state when the backend session ends (logout / account switch).
  void onSessionEnded() {
    _remoteSaveDebounce?.cancel();
    _remoteSaveDebounce = null;
    _hydrateFuture = null;
  }

  /// Loads filters from `users.search_filters` for the signed-in user (server wins).
  Future<void> hydrateFromBackendForCurrentUser() async {
    if (_hydrateFuture != null) {
      await _hydrateFuture;
      return;
    }
    final run = _hydrateFromBackendImpl();
    _hydrateFuture = run;
    try {
      await run;
    } finally {
      if (_hydrateFuture == run) {
        _hydrateFuture = null;
      }
    }
  }

  Future<void> _hydrateFromBackendImpl() async {
    if (!await SessionManager.isAuthenticated()) return;

    _suppressRemotePersist = true;
    try {
      final map = await getIt<IUserSearchFiltersService>().fetchMe();
      final raw = map["search_filters"];
      if (raw is Map) {
        await _applyServerFiltersToStateAndPrefs(Map<String, dynamic>.from(raw));
        _profileDefaultsApplied = true;
      } else {
        await clearAllFilters(persistRemote: false);
      }
    } catch (e) {
      logger.d("SearchFiltersState: hydrate failed: $e");
    } finally {
      _suppressRemotePersist = false;
    }
  }

  Future<void> _applyServerFiltersToStateAndPrefs(Map<String, dynamic> m) async {
    int readInt(String key, int fallback, {int min = 0, int max = 999999}) {
      final v = m[key];
      if (v is num) {
        final i = v.toInt();
        if (i >= min && i <= max) return i;
      }
      return fallback;
    }

    double readDouble(String key, double fallback) {
      final v = m[key];
      if (v is num) return v.toDouble();
      return fallback;
    }

    bool readBool(String key, bool fallback) {
      final v = m[key];
      if (v is bool) return v;
      return fallback;
    }

    _selectedListingTypeId = readInt("listing_type_id", 2, min: 1, max: 99);
    _selectedLocationIndex = readInt("location_index", 0, min: 0, max: 9999);
    _selectedSubwayLine = readInt("subway_line", 0, min: 0, max: 9999);
    _selectedStationIndex = readInt("station_index", 0, min: 0, max: 9999);
    _selectedStationId = readInt("station_id", 0, min: 0, max: 999999);
    _selectedGender = readInt("gender", 1, min: 1, max: 2);
    _minPrice = readDouble("min_price", 10.0);
    _maxPrice = readDouble("max_price", 1000.0);
    if (_minPrice > _maxPrice) {
      final t = _minPrice;
      _minPrice = _maxPrice;
      _maxPrice = t;
    }
    _privateRoom = readBool("private_room", false);
    _withPhoto = readBool("with_photo", false);

    notifyListeners();

    await _enqueuePrefsWrite((prefs) async {
      await prefs.setInt("search_listing_type_id", _selectedListingTypeId);
      await prefs.setInt("search_location_index", _selectedLocationIndex);
      await prefs.setInt("search_subway_line", _selectedSubwayLine);
      await prefs.setInt("search_station_index", _selectedStationIndex);
      await prefs.setInt("search_station_id", _selectedStationId);
      await prefs.setInt("search_gender", _selectedGender);
      await prefs.setDouble("search_min_price", _minPrice);
      await prefs.setDouble("search_max_price", _maxPrice);
      await prefs.setBool("search_private_room", _privateRoom);
      await prefs.setBool("search_with_photo", _withPhoto);
    });
  }

  void _scheduleRemotePersist() {
    if (_suppressRemotePersist) return;
    _remoteSaveDebounce?.cancel();
    _remoteSaveDebounce = Timer(_remoteSaveDelay, () {
      _remoteSaveDebounce = null;
      unawaited(_flushRemotePersist());
    });
  }

  Future<void> _flushRemotePersist() async {
    if (!await SessionManager.isAuthenticated()) return;
    try {
      final payload = <String, dynamic>{
        "listing_type_id": _selectedListingTypeId,
        "location_index": _selectedLocationIndex,
        "subway_line": _selectedSubwayLine,
        "station_index": _selectedStationIndex,
        "station_id": _selectedStationId,
        "gender": _selectedGender,
        "min_price": _minPrice,
        "max_price": _maxPrice,
        "private_room": _privateRoom,
        "with_photo": _withPhoto,
      };
      await getIt<IUserSearchFiltersService>().saveMe(payload);
    } catch (e) {
      logger.d("SearchFiltersState: remote persist failed: $e");
    }
  }

  /// Serializes SharedPreferences writes to avoid races between un-awaited
  /// setter calls (common from modal sheets) and later restores.
  Future<void> _enqueuePrefsWrite(
    Future<void> Function(SharedPreferences prefs) write,
  ) {
    _prefsWriteChain = _prefsWriteChain.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await write(prefs);
    });
    return _prefsWriteChain;
  }

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
      _maxPrice = prefs.getDouble("search_max_price") ?? 1000.0;

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
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt("search_listing_type_id", listingTypeId);
      });
    } catch (e) {
      logger.d("Error saving listing type ID: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  // Update location index
  Future<void> setLocationIndex(int locationIndex) async {
    _selectedLocationIndex = locationIndex;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt("search_location_index", locationIndex);
      });
    } catch (e) {
      logger.d("Error saving location index: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  // Update subway line
  Future<void> setSubwayLine(int subwayLine) async {
    logger.d(
      "DEBUG: SearchFiltersState.setSubwayLine - saving subway line: $subwayLine",
    );
    _selectedSubwayLine = subwayLine;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt("search_subway_line", subwayLine);
        logger.d(
          "DEBUG: SearchFiltersState.setSubwayLine - saved to SharedPreferences: $subwayLine",
        );
      });
    } catch (e) {
      logger.d("Error saving subway line: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  // Update station index
  Future<void> setStationIndex(int stationIndex) async {
    logger.d(
      "DEBUG: SearchFiltersState.setStationIndex - saving station index: $stationIndex",
    );
    _selectedStationIndex = stationIndex;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt("search_station_index", stationIndex);
        logger.d(
          "DEBUG: SearchFiltersState.setStationIndex - saved to SharedPreferences: $stationIndex",
        );
      });
    } catch (e) {
      logger.d("Error saving station index: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  // Update station ID (new method)
  Future<void> setStationId(int stationId) async {
    logger.d(
      "DEBUG: SearchFiltersState.setStationId - saving station ID: $stationId",
    );
    _selectedStationId = stationId;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt("search_station_id", stationId);
        logger.d(
          "DEBUG: SearchFiltersState.setStationId - saved to SharedPreferences: $stationId",
        );
      });
    } catch (e) {
      logger.d("Error saving station ID: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  // Update gender
  Future<void> setGender(int gender) async {
    _selectedGender = gender;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt("search_gender", gender);
      });
    } catch (e) {
      logger.d("Error saving gender: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  // Update price range
  Future<void> setPriceRange(double minPrice, double maxPrice) async {
    _minPrice = minPrice;
    _maxPrice = maxPrice;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setDouble("search_min_price", minPrice);
        await prefs.setDouble("search_max_price", maxPrice);
      });
    } catch (e) {
      logger.d("Error saving price range: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  // Update private room preference
  Future<void> setPrivateRoom(bool privateRoom) async {
    _privateRoom = privateRoom;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setBool("search_private_room", privateRoom);
      });
    } catch (e) {
      logger.d("Error saving private room preference: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  Future<void> setWithPhoto(bool withPhoto) async {
    _withPhoto = withPhoto;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setBool("search_with_photo", withPhoto);
      });
    } catch (e) {
      logger.d("Error saving with-photo preference: $e");
    }

    notifyListeners();
    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }

  // Clear all search filters
  Future<void> clearAllFilters({bool persistRemote = true}) async {
    _selectedListingTypeId = 2;
    _selectedLocationIndex = 0;
    _selectedSubwayLine = 0;
    _selectedStationIndex = 0;
    _selectedStationId = 0;
    _selectedGender = 1;
    _profileDefaultsApplied = false; // Allow profile defaults to re-apply
    _minPrice = 10.0;
    _maxPrice = 1000.0;
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
    if (persistRemote && !_suppressRemotePersist) _scheduleRemotePersist();
  }

  /// Restores fields and persisted prefs after a modal temporarily changed filters
  /// (e.g. editing a search alert).
  Future<void> restoreToSnapshot(SearchFiltersSnapshot snapshot) async {
    _selectedListingTypeId = snapshot.selectedListingTypeId;
    _selectedLocationIndex = snapshot.selectedLocationIndex;
    _selectedSubwayLine = snapshot.selectedSubwayLine;
    _selectedStationIndex = snapshot.selectedStationIndex;
    _selectedStationId = snapshot.selectedStationId;
    _selectedGender = snapshot.selectedGender;
    _minPrice = snapshot.minPrice;
    _maxPrice = snapshot.maxPrice;
    _privateRoom = snapshot.privateRoom;
    _withPhoto = snapshot.withPhoto;

    notifyListeners();

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt(
          "search_listing_type_id",
          snapshot.selectedListingTypeId,
        );
        await prefs.setInt("search_location_index", snapshot.selectedLocationIndex);
        await prefs.setInt("search_subway_line", snapshot.selectedSubwayLine);
        await prefs.setInt("search_station_index", snapshot.selectedStationIndex);
        await prefs.setInt("search_station_id", snapshot.selectedStationId);
        await prefs.setInt("search_gender", snapshot.selectedGender);
        await prefs.setDouble("search_min_price", snapshot.minPrice);
        await prefs.setDouble("search_max_price", snapshot.maxPrice);
        await prefs.setBool("search_private_room", snapshot.privateRoom);
        await prefs.setBool("search_with_photo", snapshot.withPhoto);
      });
    } catch (e) {
      logger.d("Error restoring search filters snapshot: $e");
    }

    if (!_suppressRemotePersist) _scheduleRemotePersist();
  }
}

/// Immutable copy of [SearchFiltersState] for restoring after ephemeral UI.
class SearchFiltersSnapshot {
  const SearchFiltersSnapshot({
    required this.selectedListingTypeId,
    required this.selectedLocationIndex,
    required this.selectedSubwayLine,
    required this.selectedStationIndex,
    required this.selectedStationId,
    required this.selectedGender,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
  });

  factory SearchFiltersSnapshot.capture(SearchFiltersState s) {
    return SearchFiltersSnapshot(
      selectedListingTypeId: s.selectedListingTypeId,
      selectedLocationIndex: s.selectedLocationIndex,
      selectedSubwayLine: s.selectedSubwayLine,
      selectedStationIndex: s.selectedStationIndex,
      selectedStationId: s.selectedStationId,
      selectedGender: s.selectedGender,
      minPrice: s.minPrice,
      maxPrice: s.maxPrice,
      privateRoom: s.privateRoom,
      withPhoto: s.withPhoto,
    );
  }

  final int selectedListingTypeId;
  final int selectedLocationIndex;
  final int selectedSubwayLine;
  final int selectedStationIndex;
  final int selectedStationId;
  final int selectedGender;
  final double minPrice;
  final double maxPrice;
  final bool privateRoom;
  final bool withPhoto;
}

class _EmptyRequest implements IJsonEncodable {
  _EmptyRequest();

  @override
  Map<String, dynamic> toJson() => {};
}
