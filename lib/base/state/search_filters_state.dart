import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uy_dosh/base/logger/logger.dart';

// Global search filters state with ChangeNotifier for reactivity
class SearchFiltersState extends ChangeNotifier {
  static final SearchFiltersState _instance = SearchFiltersState._internal();
  factory SearchFiltersState() => _instance;
  SearchFiltersState._internal();

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
  bool _isInitialized = false;

  int get selectedListingTypeId => _selectedListingTypeId;
  int get selectedLocationIndex => _selectedLocationIndex;
  int get selectedSubwayLine => _selectedSubwayLine;
  int get selectedStationIndex => _selectedStationIndex;
  int get selectedStationId => _selectedStationId; // Getter for station ID
  int get selectedGender => _selectedGender;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  bool get privateRoom => _privateRoom;
  bool get isInitialized => _isInitialized;

  // Initialize and load saved search filters from storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load listing type ID
      _selectedListingTypeId = prefs.getInt('search_listing_type_id') ?? 2;

      // Load location index
      _selectedLocationIndex = prefs.getInt('search_location_index') ?? 0;

      // Load subway line
      _selectedSubwayLine = prefs.getInt('search_subway_line') ?? 0;
      logger.d(
        'DEBUG: SearchFiltersState.initialize - loaded subway line from SharedPreferences: $_selectedSubwayLine',
      );

      // Load station index (for backward compatibility)
      _selectedStationIndex = prefs.getInt('search_station_index') ?? 0;
      logger.d(
        'DEBUG: SearchFiltersState.initialize - loaded station index from SharedPreferences: $_selectedStationIndex',
      );

      // Load station ID (new field)
      _selectedStationId = prefs.getInt('search_station_id') ?? 0;
      logger.d(
        'DEBUG: SearchFiltersState.initialize - loaded station ID from SharedPreferences: $_selectedStationId',
      );

      // Load gender
      _selectedGender = prefs.getInt('search_gender') ?? 1;

      // Load price range
      _minPrice = prefs.getDouble('search_min_price') ?? 10.0;
      _maxPrice = prefs.getDouble('search_max_price') ?? 500.0;

      // Load private room preference
      _privateRoom = prefs.getBool('search_private_room') ?? false;

      logger.d(
        'Loaded saved search filters: listingType=$_selectedListingTypeId, location=$_selectedLocationIndex, line=$_selectedSubwayLine, stationIndex=$_selectedStationIndex, stationId=$_selectedStationId, gender=$_selectedGender, priceRange=$_minPrice-$_maxPrice, privateRoom=$_privateRoom',
      );
    } catch (e) {
      logger.d('Error loading saved search filters: $e');
      // Keep default values if there's an error
    }

    _isInitialized = true;
    notifyListeners();
  }

  // Update listing type ID
  Future<void> setListingTypeId(int listingTypeId) async {
    _selectedListingTypeId = listingTypeId;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('search_listing_type_id', listingTypeId);
    } catch (e) {
      logger.d('Error saving listing type ID: $e');
    }

    notifyListeners();
  }

  // Update location index
  Future<void> setLocationIndex(int locationIndex) async {
    _selectedLocationIndex = locationIndex;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('search_location_index', locationIndex);
    } catch (e) {
      logger.d('Error saving location index: $e');
    }

    notifyListeners();
  }

  // Update subway line
  Future<void> setSubwayLine(int subwayLine) async {
    logger.d(
      'DEBUG: SearchFiltersState.setSubwayLine - saving subway line: $subwayLine',
    );
    _selectedSubwayLine = subwayLine;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('search_subway_line', subwayLine);
      logger.d(
        'DEBUG: SearchFiltersState.setSubwayLine - saved to SharedPreferences: $subwayLine',
      );
    } catch (e) {
      logger.d('Error saving subway line: $e');
    }

    notifyListeners();
  }

  // Update station index
  Future<void> setStationIndex(int stationIndex) async {
    logger.d(
      'DEBUG: SearchFiltersState.setStationIndex - saving station index: $stationIndex',
    );
    _selectedStationIndex = stationIndex;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('search_station_index', stationIndex);
      logger.d(
        'DEBUG: SearchFiltersState.setStationIndex - saved to SharedPreferences: $stationIndex',
      );
    } catch (e) {
      logger.d('Error saving station index: $e');
    }

    notifyListeners();
  }

  // Update station ID (new method)
  Future<void> setStationId(int stationId) async {
    logger.d(
      'DEBUG: SearchFiltersState.setStationId - saving station ID: $stationId',
    );
    _selectedStationId = stationId;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('search_station_id', stationId);
      logger.d(
        'DEBUG: SearchFiltersState.setStationId - saved to SharedPreferences: $stationId',
      );
    } catch (e) {
      logger.d('Error saving station ID: $e');
    }

    notifyListeners();
  }

  // Update gender
  Future<void> setGender(int gender) async {
    _selectedGender = gender;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('search_gender', gender);
    } catch (e) {
      logger.d('Error saving gender: $e');
    }

    notifyListeners();
  }

  // Update price range
  Future<void> setPriceRange(double minPrice, double maxPrice) async {
    _minPrice = minPrice;
    _maxPrice = maxPrice;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('search_min_price', minPrice);
      await prefs.setDouble('search_max_price', maxPrice);
    } catch (e) {
      logger.d('Error saving price range: $e');
    }

    notifyListeners();
  }

  // Update private room preference
  Future<void> setPrivateRoom(bool privateRoom) async {
    _privateRoom = privateRoom;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('search_private_room', privateRoom);
    } catch (e) {
      logger.d('Error saving private room preference: $e');
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
    _minPrice = 10.0;
    _maxPrice = 500.0;
    _privateRoom = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('search_listing_type_id');
      await prefs.remove('search_location_index');
      await prefs.remove('search_subway_line');
      await prefs.remove('search_station_index');
      await prefs.remove('search_station_id');
      await prefs.remove('search_gender');
      await prefs.remove('search_min_price');
      await prefs.remove('search_max_price');
      await prefs.remove('search_private_room');
    } catch (e) {
      logger.d('Error clearing search filters: $e');
    }

    notifyListeners();
  }
}
