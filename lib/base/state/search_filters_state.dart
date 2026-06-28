import "dart:async" show Timer, unawaited;

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/restore_filters_state.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/search/search_filter_defaults.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/services/user_search_filters_service.dart";

// Global search filters state with ChangeNotifier for reactivity
class SearchFiltersState extends ChangeNotifier {
  factory SearchFiltersState() => _instance;
  SearchFiltersState._internal();
  static final SearchFiltersState _instance = SearchFiltersState._internal();

  int _selectedListingTypeId = 2; // Default to roommate needed
  List<int> _searchListingTypeIds = const [ListingTypeIds.roommateNeeded];
  int _selectedLocationIndex = 0;
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedStationId =
      0; // Deprecated single-station id; kept for backward compat
  // Canonical multi-station selection. Empty means "no station filter".
  // The single fields above are derived from this for legacy persistence.
  List<int> _selectedStationIds = const [];
  int _selectedGender = 1; // 1 = male, 2 = female
  double _minPrice = 10.0; // Default min price
  double _maxPrice = 500.0; // Default visible max price
  bool _privateRoom = false; // Default to false (show all)
  bool _withPhoto = false;
  bool _isInitialized = false;
  bool _profileDefaultsApplied = false;
  // Tracks whether the user had any persisted filters (local prefs or a server
  // snapshot) when this session loaded. Used by
  // [ensureDefaultFiltersBuiltAndSaved] to decide between building fresh
  // profile defaults vs. keeping the user's saved filters untouched.
  bool _hadSavedFilters = false;
  Future<void> _prefsWriteChain = Future<void>.value();
  bool _suppressRemotePersist = false;
  Timer? _remoteSaveDebounce;
  static const Duration _remoteSaveDelay = Duration(milliseconds: 1600);
  Future<void>? _hydrateFuture;

  /// Counts active "editing sessions" (e.g. the search bottom sheet) during
  /// which mutations should NOT propagate to outside listeners or to the
  /// backend. The sheet uses this so in-progress edits don't bleed into the
  /// home filter chips ribbon — they only become visible when the user
  /// taps Search (commit) or are reverted via [restoreToSnapshot] on dismiss.
  int _editingSessionDepth = 0;

  bool get _externalListenersSuppressed => _editingSessionDepth > 0;
  bool get _remotePersistGated =>
      _suppressRemotePersist || _editingSessionDepth > 0;

  /// Begin an "editing session". While active, [notifyListeners] is a no-op
  /// for outside observers and remote persist is paused. Sessions nest, so
  /// each call must be paired with [endEditingSession].
  void beginEditingSession() {
    _editingSessionDepth++;
  }

  /// Ends the current editing session. When [commit] is true, listeners are
  /// notified and a remote persist is scheduled so the latest filter values
  /// are propagated. When false, the caller is expected to follow up with
  /// [restoreToSnapshot] to revert any in-session changes.
  void endEditingSession({required bool commit}) {
    if (_editingSessionDepth > 0) _editingSessionDepth--;
    if (_editingSessionDepth == 0 && commit) {
      super.notifyListeners();
      if (!_remotePersistGated) _scheduleRemotePersist();
    }
  }

  @override
  void notifyListeners() {
    if (_externalListenersSuppressed) return;
    super.notifyListeners();
  }

  /// Clears debounce state when the backend session ends (logout / account switch).
  void onSessionEnded() {
    _remoteSaveDebounce?.cancel();
    _remoteSaveDebounce = null;
    _hydrateFuture = null;
  }

  /// Synchronously flush any pending debounced remote save so it survives a
  /// logout / account switch. Must be called BEFORE the session token is
  /// cleared (otherwise the OAuth interceptor has nothing to send and the
  /// request 401s, dropping the user's last filter changes on the floor).
  Future<void> flushPendingRemotePersist() async {
    final pending = _remoteSaveDebounce;
    if (pending == null || !pending.isActive) return;
    pending.cancel();
    _remoteSaveDebounce = null;
    await _flushRemotePersist();
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

    // Honor the user-facing "Restore filters on app start" preference: when
    // disabled, skip pulling the backend copy so this device stays "fresh".
    // The backend value itself is intentionally preserved so flipping the
    // toggle back ON re-restores prior filters.
    await RestoreFiltersState().initialize();
    if (!RestoreFiltersState().shouldRestore) return;

    _suppressRemotePersist = true;
    try {
      final map = await getIt<IUserSearchFiltersService>().fetchMe();
      final raw = map["search_filters"];
      if (raw is Map) {
        await _applyServerFiltersToStateAndPrefs(
            Map<String, dynamic>.from(raw));
        _profileDefaultsApplied = true;
        _hadSavedFilters = true;
      } else {
        // No server snapshot yet (or explicitly null). Keep filters from
        // [initialize] / device prefs — do not wipe them. Clearing here
        // made every cold start drop local filters whenever the backend row
        // was still empty (e.g. before the debounced remote persist landed).
        logger.d(
          "SearchFiltersState: hydrate skipped apply (no server map); keeping local filters",
        );
      }
    } catch (e) {
      logger.d("SearchFiltersState: hydrate failed: $e");
    } finally {
      _suppressRemotePersist = false;
    }
  }

  Future<void> _applyServerFiltersToStateAndPrefs(
      Map<String, dynamic> m) async {
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
    _searchListingTypeIds = SearchFilterListingTypeIdsCodec.fromServerJson(
      m,
      fallbackUiTypeId: _selectedListingTypeId,
    );
    _selectedLocationIndex = readInt("location_index", 0, min: 0, max: 9999);
    _selectedSubwayLine = readInt("subway_line", 0, min: 0, max: 9999);
    _selectedStationIndex = readInt("station_index", 0, min: 0, max: 9999);
    _selectedStationId = readInt("station_id", 0, min: 0, max: 999999);
    _selectedStationIds = _stationIdsFromDynamic(m["subway_station_ids"]);
    if (_selectedStationIds.isEmpty && _selectedStationId > 0) {
      _selectedStationIds = [_selectedStationId];
    }
    _selectedGender = readInt("gender", 1, min: 1, max: 2);
    _minPrice = readDouble("min_price", 10.0);
    _maxPrice = readDouble("max_price", 500.0);
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
      await prefs.setString(
        SearchFilterListingTypeIdsCodec.prefsKey,
        SearchFilterListingTypeIdsCodec.toPrefsString(_searchListingTypeIds),
      );
      await prefs.remove("search_landlord_demand_bundle");
      await prefs.setInt("search_location_index", _selectedLocationIndex);
      await prefs.setInt("search_subway_line", _selectedSubwayLine);
      await prefs.setInt("search_station_index", _selectedStationIndex);
      await prefs.setInt("search_station_id", _selectedStationId);
      await prefs.setString(
        _stationIdsPrefsKey,
        _stationIdsToPrefsString(_selectedStationIds),
      );
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
        ...?_listingTypeIdsServerPayload(),
        "location_index": _selectedLocationIndex,
        "subway_line": _selectedSubwayLine,
        "station_index": _selectedStationIndex,
        "station_id": _selectedStationId,
        if (_selectedStationIds.isNotEmpty)
          "subway_station_ids": _selectedStationIds,
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

  List<int> get searchListingTypeIdsList =>
      List<int>.unmodifiable(_searchListingTypeIds);

  /// Listing type ids sent to search APIs when searching multiple types.
  List<int>? get searchListingTypeIds {
    if (_searchListingTypeIds.length > 1) {
      return List<int>.from(_searchListingTypeIds);
    }
    return null;
  }

  int? get searchListingTypeId {
    if (_searchListingTypeIds.length > 1) return null;
    return _searchListingTypeIds.isNotEmpty ? _searchListingTypeIds.first : null;
  }
  int get selectedLocationIndex => _selectedLocationIndex;
  int get selectedSubwayLine => _selectedSubwayLine;
  int get selectedStationIndex => _selectedStationIndex;
  int get selectedStationId => _selectedStationId; // Getter for station ID

  /// All currently selected subway station ids (multi-select).
  List<int> get selectedStationIdsList =>
      List<int>.unmodifiable(_selectedStationIds);

  /// Station ids sent to search APIs, or null when none are selected.
  List<int>? get searchSubwayStationIds =>
      _selectedStationIds.isNotEmpty ? List<int>.from(_selectedStationIds) : null;

  static const String _stationIdsPrefsKey = "search_station_ids";

  static List<int> _sanitizeStationIds(Iterable<int> raw) {
    final out = <int>[];
    for (final id in raw) {
      if (id > 0 && !out.contains(id)) out.add(id);
    }
    out.sort();
    return out;
  }

  static List<int> _stationIdsFromDynamic(dynamic raw) {
    if (raw is List) {
      return _sanitizeStationIds(
        raw.map((e) => e is num ? e.toInt() : int.tryParse("$e")).whereType<int>(),
      );
    }
    return const [];
  }

  static List<int> _stationIdsFromPrefsString(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const [];
    return _sanitizeStationIds(
      raw.split(",").map((p) => int.tryParse(p.trim())).whereType<int>(),
    );
  }

  static String _stationIdsToPrefsString(List<int> ids) =>
      _sanitizeStationIds(ids).join(",");

  int get selectedGender => _selectedGender;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get privateRoom => _privateRoom;
  bool get withPhoto => _withPhoto;
  bool get isInitialized => _isInitialized;

  // Initialize and load saved search filters from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Respect the "Restore filters on app start" setting: when disabled we
    // discard locally persisted filters so the user opens to defaults each
    // launch. The backend snapshot is left untouched.
    await RestoreFiltersState().initialize();
    if (!RestoreFiltersState().shouldRestore) {
      await clearAllFilters(persistRemote: false);
      // Filters were intentionally wiped for this launch, so the user has no
      // saved filters to honor; profile defaults may be rebuilt.
      _hadSavedFilters = false;
      _isInitialized = true;
      notifyListeners();
      return;
    }

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

      // Load station ID (legacy single field)
      _selectedStationId = prefs.getInt("search_station_id") ?? 0;
      logger.d(
        "DEBUG: SearchFiltersState.initialize - loaded station ID from SharedPreferences: $_selectedStationId",
      );

      // Load multi-station selection; upgrade a legacy single id when present.
      _selectedStationIds =
          _stationIdsFromPrefsString(prefs.getString(_stationIdsPrefsKey));
      if (_selectedStationIds.isEmpty && _selectedStationId > 0) {
        _selectedStationIds = [_selectedStationId];
      }

      // Load gender - use profile default when no saved preference
      final savedGender = prefs.getInt("search_gender");
      _selectedGender = savedGender ?? 1;

      // Load price range
      _minPrice = prefs.getDouble("search_min_price") ?? 10.0;
      _maxPrice = prefs.getDouble("search_max_price") ?? 500.0;

      // Load private room preference
      _privateRoom = prefs.getBool("search_private_room") ?? false;

      _withPhoto = prefs.getBool("search_with_photo") ?? false;

      _searchListingTypeIds = _loadSearchListingTypeIdsFromPrefs(
        prefs,
        uiListingTypeId: _selectedListingTypeId,
      );

      // Mark whether we need to apply profile defaults (when no saved values)
      _profileDefaultsApplied =
          savedListingTypeId != null && savedGender != null;

      // Record whether the user already had any persisted filter so the home
      // load can decide between building fresh defaults and keeping saved ones.
      _hadSavedFilters = prefs.containsKey("search_listing_type_id") ||
          prefs.containsKey("search_location_index") ||
          prefs.containsKey("search_subway_line") ||
          prefs.containsKey("search_station_index") ||
          prefs.containsKey("search_station_id") ||
          prefs.containsKey(_stationIdsPrefsKey) ||
          prefs.containsKey("search_gender") ||
          prefs.containsKey("search_min_price") ||
          prefs.containsKey("search_max_price") ||
          prefs.containsKey("search_private_room") ||
          prefs.containsKey("search_with_photo") ||
          prefs.containsKey(SearchFilterListingTypeIdsCodec.prefsKey) ||
          prefs.containsKey("search_landlord_demand_bundle");

      logger.d(
        "Loaded saved search filters: listingType=$_selectedListingTypeId, searchListingTypeIds=$_searchListingTypeIds, location=$_selectedLocationIndex, line=$_selectedSubwayLine, stationIndex=$_selectedStationIndex, stationId=$_selectedStationId, gender=$_selectedGender, priceRange=$_minPrice-$_maxPrice, privateRoom=$_privateRoom, withPhoto=$_withPhoto",
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
        final defaults = SearchFilterDefaultsPolicy.forRole(role);
        _applySearchFilterDefaults(defaults);
        await _enqueuePrefsWrite(_persistListingTypePrefs);
        updated = true;
        logger.d(
          "SearchFiltersState: Applied profile listing type default: ${defaults.uiListingTypeId} (role: $role, searchListingTypeIds: ${defaults.searchListingTypeIds})",
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

  /// Home-load entry point. Decides between building fresh profile-derived
  /// defaults and keeping the user's existing saved filters:
  ///
  /// - When the user already has saved filters (local prefs or a hydrated
  ///   server snapshot), this is a no-op and returns `false` so the caller
  ///   applies the saved filters as-is (do NOT overwrite).
  /// - When no saved filters exist, it builds defaults from the profile
  ///   (gender), role (listing type) and the full price range, persists them
  ///   locally and to the backend, and returns `true`.
  ///
  /// Only runs for authenticated users (role/profile are required to build the
  /// defaults and to persist them remotely).
  Future<bool> ensureDefaultFiltersBuiltAndSaved() async {
    if (_hadSavedFilters) {
      await _upgradeLegacyLandlordListingTypeIdsIfNeeded();
      return false;
    }
    if (!await SessionManager.isAuthenticated()) return false;

    try {
      final role = await _getUserRole();
      final gender = await _getProfileGender();
      final defaults = SearchFilterDefaultsPolicy.forRole(
        role,
        profileGender: gender,
      );
      _applySearchFilterDefaults(defaults);

      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt("search_listing_type_id", _selectedListingTypeId);
        await prefs.setString(
          SearchFilterListingTypeIdsCodec.prefsKey,
          SearchFilterListingTypeIdsCodec.toPrefsString(_searchListingTypeIds),
        );
        await prefs.remove("search_landlord_demand_bundle");
        await prefs.setInt("search_gender", _selectedGender);
        await prefs.setDouble("search_min_price", _minPrice);
        await prefs.setDouble("search_max_price", _maxPrice);
      });

      _profileDefaultsApplied = true;
      _hadSavedFilters = true;
      notifyListeners();

      // Persist immediately so the freshly built defaults become the user's
      // saved filters (subsequent launches take the "do not overwrite" branch).
      if (!_remotePersistGated) {
        _remoteSaveDebounce?.cancel();
        _remoteSaveDebounce = null;
        await _flushRemotePersist();
      }

      logger.d(
        "SearchFiltersState: built default filters (listingType=$_selectedListingTypeId, searchListingTypeIds=$_searchListingTypeIds, gender=$_selectedGender, price=$_minPrice-$_maxPrice)",
      );
      return true;
    } catch (e) {
      logger.d("Error building default filters: $e");
      return false;
    }
  }

  void _applySearchFilterDefaults(SearchFilterDefaults defaults) {
    _selectedListingTypeId = defaults.uiListingTypeId;
    _searchListingTypeIds = List<int>.from(defaults.searchListingTypeIds);
    _minPrice = defaults.minPrice;
    _maxPrice = defaults.maxPrice;
    if (defaults.gender != null && (defaults.gender == 1 || defaults.gender == 2)) {
      _selectedGender = defaults.gender!;
    }
  }

  List<int> _loadSearchListingTypeIdsFromPrefs(
    SharedPreferences prefs, {
    required int uiListingTypeId,
  }) {
    if (prefs.containsKey(SearchFilterListingTypeIdsCodec.prefsKey)) {
      return SearchFilterListingTypeIdsCodec.fromPrefsString(
        prefs.getString(SearchFilterListingTypeIdsCodec.prefsKey),
        fallbackUiTypeId: uiListingTypeId,
      );
    }
    if (prefs.getBool("search_landlord_demand_bundle") == true) {
      return SearchFilterDefaultsPolicy.landlordDemandListingTypeIds();
    }
    return [uiListingTypeId];
  }

  Future<void> _persistListingTypePrefs(SharedPreferences prefs) async {
    await prefs.setInt("search_listing_type_id", _selectedListingTypeId);
    await prefs.setString(
      SearchFilterListingTypeIdsCodec.prefsKey,
      SearchFilterListingTypeIdsCodec.toPrefsString(_searchListingTypeIds),
    );
    await prefs.remove("search_landlord_demand_bundle");
  }

  Map<String, dynamic>? _listingTypeIdsServerPayload() {
    final ids = SearchFilterListingTypeIdsCodec.toServerJson(
      _searchListingTypeIds,
      uiListingTypeId: _selectedListingTypeId,
    );
    if (ids == null) return null;
    return {SearchFilterListingTypeIdsCodec.serverKey: ids};
  }

  /// Existing landlords who saved room_needed-only filters before multi-type
  /// ids shipped still get groups in their feed.
  Future<void> _upgradeLegacyLandlordListingTypeIdsIfNeeded() async {
    if (_searchListingTypeIds.length > 1) return;
    if (!await SessionManager.isAuthenticated()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final hadExplicitListingTypeIds =
          prefs.containsKey(SearchFilterListingTypeIdsCodec.prefsKey) ||
          prefs.containsKey("search_landlord_demand_bundle");

      final role = await _getUserRole();
      if (!SearchFilterDefaultsPolicy.shouldUpgradeLegacyLandlordSearch(
        role: role,
        uiListingTypeId: _selectedListingTypeId,
        searchListingTypeIds: _searchListingTypeIds,
        hadExplicitListingTypeIds: hadExplicitListingTypeIds,
      )) {
        return;
      }

      _searchListingTypeIds =
          SearchFilterDefaultsPolicy.landlordDemandListingTypeIds();
      await _enqueuePrefsWrite(_persistListingTypePrefs);
      notifyListeners();
      if (!_remotePersistGated) _scheduleRemotePersist();
      logger.d(
        "SearchFiltersState: upgraded landlord saved filters to multi-type ids",
      );
    } catch (e) {
      logger.d("SearchFiltersState: landlord listing-type upgrade failed: $e");
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
        final defaults = SearchFilterDefaultsPolicy.forRole(role);
        await setListingTypeId(
          defaults.uiListingTypeId,
          searchListingTypeIds: defaults.searchListingTypeIds,
        );
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
  Future<void> setListingTypeId(
    int listingTypeId, {
    List<int>? searchListingTypeIds,
  }) async {
    _selectedListingTypeId = listingTypeId;
    _searchListingTypeIds = searchListingTypeIds ?? [listingTypeId];

    try {
      await _enqueuePrefsWrite(_persistListingTypePrefs);
    } catch (e) {
      logger.d("Error saving listing type ID: $e");
    }

    notifyListeners();
    if (!_remotePersistGated) _scheduleRemotePersist();
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
    if (!_remotePersistGated) _scheduleRemotePersist();
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
    if (!_remotePersistGated) _scheduleRemotePersist();
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
    if (!_remotePersistGated) _scheduleRemotePersist();
  }

  // Update station ID (legacy single-station method).
  //
  // Setting a positive id replaces the selection with that single station.
  // Setting 0 only clears the legacy single field; it intentionally does NOT
  // wipe the multi-station selection, because legacy callers invoke
  // `setStationId(0)` to "reset the station wheel" on metro-line changes —
  // which must not clear stations the user picked on other lines.
  Future<void> setStationId(int stationId) async {
    logger.d(
      "DEBUG: SearchFiltersState.setStationId - saving station ID: $stationId",
    );
    _selectedStationId = stationId;
    if (stationId > 0) {
      _selectedStationIds = [stationId];
    }

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setInt("search_station_id", stationId);
        await prefs.setString(
          _stationIdsPrefsKey,
          _stationIdsToPrefsString(_selectedStationIds),
        );
        logger.d(
          "DEBUG: SearchFiltersState.setStationId - saved to SharedPreferences: $stationId",
        );
      });
    } catch (e) {
      logger.d("Error saving station ID: $e");
    }

    notifyListeners();
    if (!_remotePersistGated) _scheduleRemotePersist();
  }

  /// Update the multi-station selection (canonical). Keeps the legacy single
  /// `station_id` in sync (first id when exactly one is selected, else 0).
  Future<void> setStationIds(List<int> stationIds) async {
    final sanitized = _sanitizeStationIds(stationIds);
    _selectedStationIds = sanitized;
    _selectedStationId = sanitized.length == 1 ? sanitized.first : 0;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setString(
          _stationIdsPrefsKey,
          _stationIdsToPrefsString(sanitized),
        );
        await prefs.setInt("search_station_id", _selectedStationId);
      });
    } catch (e) {
      logger.d("Error saving station IDs: $e");
    }

    notifyListeners();
    if (!_remotePersistGated) _scheduleRemotePersist();
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
    if (!_remotePersistGated) _scheduleRemotePersist();
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
    if (!_remotePersistGated) _scheduleRemotePersist();
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
    if (!_remotePersistGated) _scheduleRemotePersist();
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
    if (!_remotePersistGated) _scheduleRemotePersist();
  }

  /// Clears local filter prefs and the backend snapshot when the user dismisses
  /// the home filter ribbon (X). Profile-derived defaults are rebuilt on the
  /// next [ensureDefaultFiltersBuiltAndSaved] call.
  Future<void> dismissPersistedSearchFilters() async {
    _remoteSaveDebounce?.cancel();
    _remoteSaveDebounce = null;
    await clearAllFilters(persistRemote: false);
    if (!await SessionManager.isAuthenticated()) return;
    try {
      await getIt<IUserSearchFiltersService>().clearMe();
    } catch (e) {
      logger.d("SearchFiltersState: clear remote filters failed: $e");
    }
  }

  // Clear all search filters
  Future<void> clearAllFilters({
    bool persistRemote = true,
    bool flushRemoteImmediately = false,
  }) async {
    _selectedListingTypeId = 2;
    _searchListingTypeIds = const [ListingTypeIds.roommateNeeded];
    _selectedLocationIndex = 0;
    _selectedSubwayLine = 0;
    _selectedStationIndex = 0;
    _selectedStationId = 0;
    _selectedStationIds = const [];
    _selectedGender = 1;
    _profileDefaultsApplied = false; // Allow profile defaults to re-apply
    _hadSavedFilters = false; // Allow defaults to rebuild on next home load
    _minPrice = 10.0;
    _maxPrice = 500.0;
    _privateRoom = false;
    _withPhoto = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("search_listing_type_id");
      await prefs.remove(SearchFilterListingTypeIdsCodec.prefsKey);
      await prefs.remove("search_landlord_demand_bundle");
      await prefs.remove("search_location_index");
      await prefs.remove("search_subway_line");
      await prefs.remove("search_station_index");
      await prefs.remove("search_station_id");
      await prefs.remove(_stationIdsPrefsKey);
      await prefs.remove("search_gender");
      await prefs.remove("search_min_price");
      await prefs.remove("search_max_price");
      await prefs.remove("search_private_room");
      await prefs.remove("search_with_photo");
    } catch (e) {
      logger.d("Error clearing search filters: $e");
    }

    notifyListeners();
    if (persistRemote && !_suppressRemotePersist) {
      if (flushRemoteImmediately) {
        _remoteSaveDebounce?.cancel();
        _remoteSaveDebounce = null;
        await _flushRemotePersist();
      } else {
        _scheduleRemotePersist();
      }
    }
  }

  /// Restores fields and persisted prefs after a modal temporarily changed filters
  /// (e.g. editing a search alert).
  Future<void> restoreToSnapshot(SearchFiltersSnapshot snapshot) async {
    _selectedListingTypeId = snapshot.selectedListingTypeId;
    _searchListingTypeIds = List<int>.from(snapshot.searchListingTypeIds);
    _selectedLocationIndex = snapshot.selectedLocationIndex;
    _selectedSubwayLine = snapshot.selectedSubwayLine;
    _selectedStationIndex = snapshot.selectedStationIndex;
    _selectedStationId = snapshot.selectedStationId;
    _selectedStationIds = List<int>.from(snapshot.selectedStationIds);
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
        await prefs.setString(
          SearchFilterListingTypeIdsCodec.prefsKey,
          SearchFilterListingTypeIdsCodec.toPrefsString(
            snapshot.searchListingTypeIds,
          ),
        );
        await prefs.remove("search_landlord_demand_bundle");
        await prefs.setInt(
            "search_location_index", snapshot.selectedLocationIndex);
        await prefs.setInt("search_subway_line", snapshot.selectedSubwayLine);
        await prefs.setInt(
            "search_station_index", snapshot.selectedStationIndex);
        await prefs.setInt("search_station_id", snapshot.selectedStationId);
        await prefs.setString(
          _stationIdsPrefsKey,
          _stationIdsToPrefsString(snapshot.selectedStationIds),
        );
        await prefs.setInt("search_gender", snapshot.selectedGender);
        await prefs.setDouble("search_min_price", snapshot.minPrice);
        await prefs.setDouble("search_max_price", snapshot.maxPrice);
        await prefs.setBool("search_private_room", snapshot.privateRoom);
        await prefs.setBool("search_with_photo", snapshot.withPhoto);
      });
    } catch (e) {
      logger.d("Error restoring search filters snapshot: $e");
    }

    if (!_remotePersistGated) _scheduleRemotePersist();
  }
}

/// Immutable copy of [SearchFiltersState] for restoring after ephemeral UI.
class SearchFiltersSnapshot {
  const SearchFiltersSnapshot({
    required this.selectedListingTypeId,
    required this.searchListingTypeIds,
    required this.selectedLocationIndex,
    required this.selectedSubwayLine,
    required this.selectedStationIndex,
    required this.selectedStationId,
    required this.selectedStationIds,
    required this.selectedGender,
    required this.minPrice,
    required this.maxPrice,
    required this.privateRoom,
    required this.withPhoto,
  });

  factory SearchFiltersSnapshot.capture(SearchFiltersState s) {
    return SearchFiltersSnapshot(
      selectedListingTypeId: s.selectedListingTypeId,
      searchListingTypeIds: List<int>.from(s.searchListingTypeIdsList),
      selectedLocationIndex: s.selectedLocationIndex,
      selectedSubwayLine: s.selectedSubwayLine,
      selectedStationIndex: s.selectedStationIndex,
      selectedStationId: s.selectedStationId,
      selectedStationIds: List<int>.from(s.selectedStationIdsList),
      selectedGender: s.selectedGender,
      minPrice: s.minPrice,
      maxPrice: s.maxPrice,
      privateRoom: s.privateRoom,
      withPhoto: s.withPhoto,
    );
  }

  final int selectedListingTypeId;
  final List<int> searchListingTypeIds;
  final int selectedLocationIndex;
  final int selectedSubwayLine;
  final int selectedStationIndex;
  final int selectedStationId;
  final List<int> selectedStationIds;
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
