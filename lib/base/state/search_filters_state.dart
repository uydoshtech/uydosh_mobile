import "dart:async" show Timer, unawaited;

import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/home_inline_search_state.dart";
import "package:uy_dosh/base/state/restore_filters_state.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/search/search_filter_defaults.dart";
import "package:uy_dosh/domain/services/user_search_filters_service.dart";

// Global search filters state with ChangeNotifier for reactivity
class SearchFiltersState extends ChangeNotifier {
  factory SearchFiltersState() => _instance;
  SearchFiltersState._internal();
  static final SearchFiltersState _instance = SearchFiltersState._internal();

  // 0 = no listing-type filter (show all types), otherwise a real
  // ListingTypeIds value. Same "start empty until explicitly chosen"
  // treatment as gender — never auto-derived from the user's role/profile.
  int _selectedListingTypeId = 0;
  List<int> _searchListingTypeIds = const [];
  int _selectedLocationIndex = 0;
  int _selectedSubwayLine = 0;
  int _selectedStationIndex = 0;
  int _selectedStationId =
      0; // Deprecated single-station id; kept for backward compat
  // Canonical multi-station selection. Empty means "no station filter".
  // The single fields above are derived from this for legacy persistence.
  List<int> _selectedStationIds = const [];
  // 0 = no gender filter (show all), 1 = male, 2 = female. Never
  // auto-derived from the user's own profile — search filters start empty
  // until the user explicitly picks one, same as location/metro/price.
  int _selectedGender = 0;
  double _minPrice = 10.0; // Default min price
  double _maxPrice = 500.0; // Default visible max price
  bool _privateRoom = false; // Default to false (show all)
  bool _withPhoto = false;
  bool _has3dTour = false;
  bool _isInitialized = false;
  Future<void> _prefsWriteChain = Future<void>.value();
  bool _suppressRemotePersist = false;
  Timer? _remoteSaveDebounce;
  static const Duration _remoteSaveDelay = Duration(milliseconds: 1600);
  Future<void>? _hydrateFuture;
  Future<void>? _initializeFuture;
  Future<void>? _coldStartBootstrapFuture;

  /// Cold-start bootstrap: hydrate dismiss prefs, load local filters, pull
  /// server snapshot, build defaults. [main] and [HomeScreen] must share this
  /// future so parallel callers cannot race [initialize].
  Future<void> bootstrapColdStart() {
    return _coldStartBootstrapFuture ??= _bootstrapColdStartImpl();
  }

  Future<void> _bootstrapColdStartImpl() async {
    await RestoreFiltersState().initialize();
    final authenticated = await SessionManager.isAuthenticated();
    await HomeInlineSearchState().hydrateRibbonDismissedFromPrefs(
      awaitUserScope: authenticated,
    );
    if (HomeInlineSearchState().ribbonDismissedByUser) {
      markPersistedFiltersDismissed();
      // Heal a stale `users.search_filters` row left from before dismiss
      // reliably cleared the backend (e.g. failed network, quick app kill).
      if (authenticated) {
        await _clearRemoteSearchFilters();
      }
    }
    await initialize();
    if (!authenticated) return;
    if (HomeInlineSearchState().ribbonDismissedByUser) return;
    await hydrateFromBackendForCurrentUser();
  }

  /// Set when the user dismisses the home filter ribbon (X). Blocks backend
  /// hydrate, default-filter rebuild, and debounced remote saves until the user
  /// commits a new search from the bottom sheet.
  bool _persistedFiltersDismissed = false;

  /// Bumped on dismiss to drop in-flight debounced remote saves that would
  /// otherwise overwrite a backend clear.
  int _remotePersistGeneration = 0;

  /// Counts active "editing sessions" (e.g. the search bottom sheet) during
  /// which mutations should NOT propagate to outside listeners or to the
  /// backend. The sheet uses this so in-progress edits don't bleed into the
  /// home filter chips ribbon — they only become visible when the user
  /// taps Search (commit) or are reverted via [restoreToSnapshot] on dismiss.
  int _editingSessionDepth = 0;

  bool get _externalListenersSuppressed => _editingSessionDepth > 0;
  bool get _remotePersistGated =>
      _suppressRemotePersist ||
      _editingSessionDepth > 0 ||
      _persistedFiltersDismissed;

  /// Marks persisted filters as intentionally cleared (ribbon X). Synchronous
  /// so hydrate / bootstrap cannot restore stale data in the same frame.
  /// Also kicks off an immediate backend wipe so `users.search_filters` cannot
  /// resurrect filters on the next cold start.
  void markPersistedFiltersDismissed() {
    if (_persistedFiltersDismissed) return;
    _persistedFiltersDismissed = true;
    _remotePersistGeneration++;
    _remoteSaveDebounce?.cancel();
    _remoteSaveDebounce = null;
    unawaited(_clearRemoteSearchFilters());
  }

  bool get persistedFiltersDismissed => _persistedFiltersDismissed;

  /// Called when the user commits a new search from the bottom sheet.
  void clearPersistedFiltersDismissed() {
    if (!_persistedFiltersDismissed) return;
    _persistedFiltersDismissed = false;
    _remotePersistGeneration++;
  }

  Future<bool> _shouldSkipPersistedFilterRestore() async {
    if (_persistedFiltersDismissed) return true;
    await HomeInlineSearchState().hydrateRibbonDismissedFromPrefs(
      awaitUserScope: await SessionManager.isAuthenticated(),
    );
    if (HomeInlineSearchState().ribbonDismissedByUser) {
      markPersistedFiltersDismissed();
      return true;
    }
    return false;
  }

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
      unawaited(_persistCurrentFiltersToPrefs());
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
    _initializeFuture = null;
    _coldStartBootstrapFuture = null;
    _persistedFiltersDismissed = false;
    _remotePersistGeneration++;
  }

  /// Synchronously flush any pending debounced remote save so it survives a
  /// logout / account switch. Must be called BEFORE the session token is
  /// cleared (otherwise the OAuth interceptor has nothing to send and the
  /// request 401s, dropping the user's last filter changes on the floor).
  Future<void> flushPendingRemotePersist() async {
    if (_persistedFiltersDismissed) return;
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
    if (await _shouldSkipPersistedFilterRestore()) return;

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

    _selectedListingTypeId = readInt("listing_type_id", 0, min: 0, max: 99);
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
    _selectedGender = readInt("gender", 0, min: 0, max: 2);
    _minPrice = readDouble("min_price", 10.0);
    _maxPrice = readDouble("max_price", 500.0);
    if (_minPrice > _maxPrice) {
      final t = _minPrice;
      _minPrice = _maxPrice;
      _maxPrice = t;
    }
    _privateRoom = readBool("private_room", false);
    _withPhoto = readBool("with_photo", false);
    _has3dTour = readBool("has_3d_tour", false);

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
      await prefs.setBool("search_has_3d_tour", _has3dTour);
    });
  }

  void _scheduleRemotePersist() {
    if (_suppressRemotePersist || _persistedFiltersDismissed) return;
    _remoteSaveDebounce?.cancel();
    final generation = _remotePersistGeneration;
    _remoteSaveDebounce = Timer(_remoteSaveDelay, () {
      _remoteSaveDebounce = null;
      if (generation != _remotePersistGeneration) return;
      unawaited(_flushRemotePersist(expectedGeneration: generation));
    });
  }

  Future<void> _flushRemotePersist({int? expectedGeneration}) async {
    if (_persistedFiltersDismissed) return;
    if (expectedGeneration != null &&
        expectedGeneration != _remotePersistGeneration) {
      return;
    }
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
        "has_3d_tour": _has3dTour,
      };
      await getIt<IUserSearchFiltersService>().saveMe(payload);
    } catch (e) {
      logger.d("SearchFiltersState: remote persist failed: $e");
    }
  }

  /// PATCH `users.search_filters` → null so cold-start hydrate cannot reload
  /// a snapshot the user explicitly dismissed.
  Future<void> _clearRemoteSearchFilters() async {
    if (!await SessionManager.isAuthenticated()) return;
    try {
      await getIt<IUserSearchFiltersService>().clearMe();
      logger.d("SearchFiltersState: cleared remote search_filters");
    } catch (e) {
      logger.d("SearchFiltersState: clear remote filters failed: $e");
    }
  }

  /// Serializes SharedPreferences writes to avoid races between un-awaited
  /// setter calls (common from modal sheets) and later restores.
  Future<void> _enqueuePrefsWrite(
    Future<void> Function(SharedPreferences prefs) write,
  ) {
    if (_editingSessionDepth > 0) {
      return Future<void>.value();
    }
    _prefsWriteChain = _prefsWriteChain.then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await write(prefs);
    });
    return _prefsWriteChain;
  }

  Future<void> _persistCurrentFiltersToPrefs() async {
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
      await prefs.setBool("search_has_3d_tour", _has3dTour);
    });
  }

  /// Seeds in-memory filter fields when opening the search sheet. Skips disk
  /// I/O and listener notifications — callers run inside an editing session.
  void seedFromSheetOpenParams({
    int? listingTypeId,
    int? locationId,
    int? subwayLineId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    bool? has3dTour,
  }) {
    if (listingTypeId != null) {
      _selectedListingTypeId = listingTypeId;
      _searchListingTypeIds = [listingTypeId];
    }

    if (locationId != null) {
      _selectedLocationIndex = locationId;
    }

    if (subwayLineId != null) {
      _selectedSubwayLine = subwayLineId;
    }

    if (subwayStationId != null) {
      _selectedStationId = subwayStationId;
      if (subwayStationId > 0) {
        _selectedStationIds = [subwayStationId];
      }
    }

    if (subwayStationIds != null) {
      _selectedStationIds = List<int>.from(subwayStationIds);
      _selectedStationId =
          subwayStationIds.length == 1 ? subwayStationIds.first : 0;
    }

    if (gender != null) {
      _selectedGender = gender;
    }

    if (minPrice != null && maxPrice != null) {
      _minPrice = minPrice;
      _maxPrice = maxPrice;
    }

    if (privateRoom != null) {
      _privateRoom = privateRoom;
    }

    if (withPhoto != null) {
      _withPhoto = withPhoto;
    }

    if (has3dTour != null) {
      _has3dTour = has3dTour;
    }

    if (subwayLineId != null &&
        subwayLineId > 0 &&
        subwayStationId == null &&
        (subwayStationIds == null || subwayStationIds.isEmpty)) {
      _selectedStationIndex = 0;
      _selectedStationId = 0;
      _selectedStationIds = const [];
    }
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

  /// True when search targets group-forming listings only (not bundled with
  /// room_needed or other types).
  bool get isGroupFormingOnlySearch =>
      _searchListingTypeIds.length == 1 &&
      _searchListingTypeIds.first == ListingTypeIds.groupForming;

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
  bool get has3dTour => _has3dTour;
  bool get isInitialized => _isInitialized;

  // Initialize and load saved search filters from storage
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (_initializeFuture != null) {
      await _initializeFuture;
      return;
    }
    final run = _initializeImpl();
    _initializeFuture = run;
    try {
      await run;
    } finally {
      if (_initializeFuture == run) {
        _initializeFuture = null;
      }
    }
  }

  Future<void> _initializeImpl() async {
    if (_isInitialized) return;

    // Respect the "Restore filters on app start" setting: when disabled we
    // discard locally persisted filters so the user opens to defaults each
    // launch. The backend snapshot is left untouched.
    await RestoreFiltersState().initialize();
    if (!RestoreFiltersState().shouldRestore) {
      await clearAllFilters(persistRemote: false);
      _isInitialized = true;
      notifyListeners();
      return;
    }

    if (await _shouldSkipPersistedFilterRestore()) {
      await clearAllFilters(persistRemote: false);
      _isInitialized = true;
      notifyListeners();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load listing type ID - no filter (0 = all types) when nothing was
      // saved yet, never derived from the user's role/profile.
      final savedListingTypeId = prefs.getInt("search_listing_type_id");
      _selectedListingTypeId = savedListingTypeId ?? 0;

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

      // Load gender - no filter (0 = all) when nothing was saved yet.
      final savedGender = prefs.getInt("search_gender");
      _selectedGender = savedGender ?? 0;

      // Load price range
      _minPrice = prefs.getDouble("search_min_price") ?? 10.0;
      _maxPrice = prefs.getDouble("search_max_price") ?? 500.0;

      // Load private room preference
      _privateRoom = prefs.getBool("search_private_room") ?? false;

      _withPhoto = prefs.getBool("search_with_photo") ?? false;

      _has3dTour = prefs.getBool("search_has_3d_tour") ?? false;

      _searchListingTypeIds = _loadSearchListingTypeIdsFromPrefs(
        prefs,
        uiListingTypeId: _selectedListingTypeId,
      );

      logger.d(
        "Loaded saved search filters: listingType=$_selectedListingTypeId, searchListingTypeIds=$_searchListingTypeIds, location=$_selectedLocationIndex, line=$_selectedSubwayLine, stationIndex=$_selectedStationIndex, stationId=$_selectedStationId, gender=$_selectedGender, priceRange=$_minPrice-$_maxPrice, privateRoom=$_privateRoom, withPhoto=$_withPhoto, has3dTour=$_has3dTour",
      );
    } catch (e) {
      logger.d("Error loading saved search filters: $e");
      // Keep default values if there's an error
    }

    _isInitialized = true;
    notifyListeners();
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
    return uiListingTypeId > 0 ? [uiListingTypeId] : [];
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

  // Update listing type ID
  Future<void> setListingTypeId(
    int listingTypeId, {
    List<int>? searchListingTypeIds,
  }) async {
    _selectedListingTypeId = listingTypeId;
    _searchListingTypeIds =
        searchListingTypeIds ?? (listingTypeId > 0 ? [listingTypeId] : []);

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

  // Update 3D tour ("3D View") preference
  Future<void> setHas3dTour(bool has3dTour) async {
    _has3dTour = has3dTour;

    try {
      await _enqueuePrefsWrite((prefs) async {
        await prefs.setBool("search_has_3d_tour", has3dTour);
      });
    } catch (e) {
      logger.d("Error saving 3D tour preference: $e");
    }

    notifyListeners();
    if (!_remotePersistGated) _scheduleRemotePersist();
  }

  /// Clears local filter prefs and the backend snapshot when the user dismisses
  /// the home filter ribbon (X). Profile-derived defaults are rebuilt only after
  /// the user commits a new search.
  Future<void> dismissPersistedSearchFilters() async {
    markPersistedFiltersDismissed();
    final dismissGeneration = _remotePersistGeneration;

    // Wait for in-flight pref writes (e.g. from the search sheet) so they
    // cannot resurrect cleared values after we remove keys.
    await _prefsWriteChain;
    if (dismissGeneration != _remotePersistGeneration) return;

    // Wipe the DB row first — server wins on cold start, so null here prevents
    // re-hydrate even if local clear is interrupted.
    await _clearRemoteSearchFilters();

    await clearAllFilters(persistRemote: false);
  }

  /// Resets in-memory filter fields immediately. Used when dismissing the home
  /// map ribbon so embedded map props update in the same frame.
  void clearAllFiltersInMemory() {
    _selectedListingTypeId = 0;
    _searchListingTypeIds = const [];
    _selectedLocationIndex = 0;
    _selectedSubwayLine = 0;
    _selectedStationIndex = 0;
    _selectedStationId = 0;
    _selectedStationIds = const [];
    _selectedGender = 0;
    _minPrice = 10.0;
    _maxPrice = 500.0;
    _privateRoom = false;
    _withPhoto = false;
    _has3dTour = false;
    notifyListeners();
  }

  // Clear all search filters
  Future<void> clearAllFilters({
    bool persistRemote = true,
    bool flushRemoteImmediately = false,
  }) async {
    clearAllFiltersInMemory();

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
      await prefs.remove("search_has_3d_tour");
    } catch (e) {
      logger.d("Error clearing search filters: $e");
    }

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
    _has3dTour = snapshot.has3dTour;

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
        await prefs.setBool("search_has_3d_tour", snapshot.has3dTour);
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
    required this.has3dTour,
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
      has3dTour: s.has3dTour,
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
  final bool has3dTour;
}
