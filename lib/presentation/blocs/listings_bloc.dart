import "package:bloc/bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_event.dart";
import "package:uy_dosh/presentation/blocs/listings_state.dart";

class ListingsBloc extends Bloc<ListingsEvent, ListingsState> {
  ListingsBloc(this._listingService) : super(const ListingsState.initial()) {
    on<ListingsEvent>((event, emit) async {
      await event.map(
        fetchListings: (e) async => _onFetchListings(emit, e),
        loadMore: (e) async => _onLoadMore(emit, e),
        fetchListingsBySubwayStation:
            (e) async => _onFetchListingsBySubwayStation(emit, e),
        fetchListingsByLocation:
            (e) async => _onFetchListingsByLocation(emit, e),
        searchListings: (e) async => _onSearchListings(emit, e),
        fetchUserListings: (e) async => _onFetchUserListings(emit, e),
      );
    });
  }

  final IListingService _listingService;
  static const Duration _requestTimeout = Duration(seconds: 20);
  int _currentPage = 1;
  bool _hasMore = true;
  List<Listing> _currentListings = [];
  int? _totalResults;

  // Store search context for load more operations
  int? _lastListingTypeId;
  int? _lastLocationId;
  int? _lastSubwayStationId;
  int? _lastSubwayLineId;
  int? _lastGender;
  double? _lastMinPrice;
  double? _lastMaxPrice;
  bool? _lastPrivateRoom;
  bool? _lastWithPhoto;
  /// When true, load more uses getListingsBySubwayStation (station-only, no transfer expansion)
  bool _stationOnlyMode = false;

  Future<void> _onFetchListings(
    Emitter<ListingsState> emit,
    ListingsEvent event,
  ) async {
    final isRefresh = event.map(
      fetchListings: (e) => e.isRefresh,
      loadMore: (e) => false,
      fetchListingsBySubwayStation: (e) => e.isRefresh,
      fetchListingsByLocation: (e) => e.isRefresh,
      searchListings: (e) => e.isRefresh,
      fetchUserListings: (e) => e.isRefresh,
    );

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _currentListings = [];
      _totalResults = null;
    }

    emit(const ListingsState.loading());

    try {
      final page = event.map(
        fetchListings: (e) => e.page,
        loadMore: (e) => _currentPage,
        fetchListingsBySubwayStation: (e) => e.page,
        fetchListingsByLocation: (e) => e.page,
        searchListings: (e) => e.page,
        fetchUserListings: (e) => e.page,
      );

      final limit = event.map(
        fetchListings: (e) => e.limit,
        loadMore: (e) => e.limit,
        fetchListingsBySubwayStation: (e) => e.limit,
        fetchListingsByLocation: (e) => e.limit,
        searchListings: (e) => e.limit,
        fetchUserListings: (e) => e.limit,
      );

      final isActive = event.map(
        fetchListings: (e) => e.isActive,
        loadMore: (e) => e.isActive,
        fetchListingsBySubwayStation: (e) => e.isActive,
        fetchListingsByLocation: (e) => e.isActive,
        searchListings: (e) => e.isActive,
        fetchUserListings: (e) => true,
      );

      // Service now automatically uses current app language
      final response = await _listingService.getListings(
        page: page,
        limit: limit,
        isActive: isActive,
      ).timeout(_requestTimeout);

      final newListings = response.data;
      FavoritesState().syncFromListings(newListings);
      _hasMore = (page + 1) <= response.totalPages && newListings.isNotEmpty;
      _totalResults = response.total;

      if (isRefresh) {
        _currentListings = newListings;
      } else {
        _currentListings = [..._currentListings, ...newListings];
      }

      emit(
        ListingsState.loaded(
          listings: _currentListings,
          total: _totalResults,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ),
      );

      _currentPage++;
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ListingsState.error(sanitizedMessage));
    }
  }

  Future<void> _onLoadMore(
    Emitter<ListingsState> emit,
    ListingsEvent event,
  ) async {
    if (!_hasMore) {
      return;
    }

    final currentState = state;
    final currentListings = currentState.map(
      initial: (_) => <Listing>[],
      loading: (_) => <Listing>[],
      loaded: (loadedState) => loadedState.listings,
      error: (_) => <Listing>[],
    );

    if (currentListings.isEmpty) {
      return;
    }

    try {
      final limit = event.map(
        fetchListings: (e) => e.limit,
        loadMore: (e) => e.limit,
        fetchListingsBySubwayStation: (e) => e.limit,
        fetchListingsByLocation: (e) => e.limit,
        searchListings: (e) => e.limit,
        fetchUserListings: (e) => e.limit,
      );

      final isActive = event.map(
        fetchListings: (e) => e.isActive,
        loadMore: (e) => e.isActive,
        fetchListingsBySubwayStation: (e) => e.isActive,
        fetchListingsByLocation: (e) => e.isActive,
        searchListings: (e) => e.isActive,
        fetchUserListings: (e) => true,
      );

      // Station-only mode (from metro map): use getListingsBySubwayStation
      if (_stationOnlyMode && _lastSubwayStationId != null) {
        final listings = await _listingService.getListingsBySubwayStation(
          _lastSubwayStationId!,
          page: _currentPage,
          limit: limit,
        ).timeout(_requestTimeout);
        _hasMore = listings.length >= limit;
        final updatedListings = [...currentListings, ...listings];
        emit(
          ListingsState.loaded(
            listings: updatedListings,
            total: _totalResults,
            hasMore: _hasMore,
            currentPage: _currentPage,
          ),
        );
        _currentPage++;
        return;
      }

      // Check if we have stored search parameters
      if (_lastListingTypeId != null ||
          _lastLocationId != null ||
          _lastSubwayStationId != null) {
        // Use search with stored parameters
        final response = await _listingService.searchListings(
          page: _currentPage,
          limit: limit,
          isActive: isActive,
          listingTypeId: _lastListingTypeId,
          locationId: _lastLocationId,
          subwayStationId: _lastSubwayStationId,
          subwayLineId: _lastSubwayLineId,
          gender: _lastGender,
          minPrice: _lastMinPrice,
          maxPrice: _lastMaxPrice,
          privateRoom: _lastPrivateRoom,
          withPhoto: _lastWithPhoto,
        ).timeout(_requestTimeout);

        final newListings = response.data;
        FavoritesState().syncFromListings(newListings);
        _hasMore =
            (_currentPage + 1) <= response.totalPages && newListings.isNotEmpty;
        _totalResults ??= response.total;

        final updatedListings = [...currentListings, ...newListings];

        emit(
          ListingsState.loaded(
            listings: updatedListings,
            total: _totalResults,
            hasMore: _hasMore,
            currentPage: _currentPage,
          ),
        );

        _currentPage++;
      } else {
        // Fall back to regular listings
        final response = await _listingService.getListings(
          page: _currentPage,
          limit: limit,
          isActive: isActive,
        ).timeout(_requestTimeout);

        final newListings = response.data;
        FavoritesState().syncFromListings(newListings);
        _hasMore =
            (_currentPage + 1) <= response.totalPages && newListings.isNotEmpty;
        _totalResults ??= response.total;

        final updatedListings = [...currentListings, ...newListings];

        emit(
          ListingsState.loaded(
            listings: updatedListings,
            total: _totalResults,
            hasMore: _hasMore,
            currentPage: _currentPage,
          ),
        );

        _currentPage++;
      }
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ListingsState.error(sanitizedMessage));
    }
  }

  Future<void> _onFetchListingsBySubwayStation(
    Emitter<ListingsState> emit,
    ListingsEvent event,
  ) async {
    final isRefresh = event.map(
      fetchListings: (e) => e.isRefresh,
      loadMore: (e) => false,
      fetchListingsBySubwayStation: (e) => e.isRefresh,
      fetchListingsByLocation: (e) => e.isRefresh,
      searchListings: (e) => e.isRefresh,
      fetchUserListings: (e) => e.isRefresh,
    );

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _currentListings = [];
      _totalResults = null;
    }

    _stationOnlyMode = true;
    event.map(
      fetchListings: (_) {},
      loadMore: (_) {},
      fetchListingsBySubwayStation: (e) => _lastSubwayStationId = e.subwayStationId,
      fetchListingsByLocation: (_) {},
      searchListings: (_) {},
      fetchUserListings: (_) {},
    );

    if (isRefresh) {
      final subwayStationId = event.map(
        fetchListings: (e) => 0,
        loadMore: (e) => 0,
        fetchListingsBySubwayStation: (e) => e.subwayStationId,
        fetchListingsByLocation: (e) => 0,
        searchListings: (e) => 0,
        fetchUserListings: (e) => 0,
      );
      if (subwayStationId > 0) {
        getIt<AppAnalyticsService>().logSearchPerformed(
          subwayStationId: subwayStationId,
        );
      }
    }

    emit(const ListingsState.loading());

    try {
      final subwayStationId = event.map(
        fetchListings: (e) => 0,
        loadMore: (e) => 0,
        fetchListingsBySubwayStation: (e) => e.subwayStationId,
        fetchListingsByLocation: (e) => 0,
        searchListings: (e) => 0,
        fetchUserListings: (e) => 0,
      );

      final page = event.map(
        fetchListings: (e) => e.page,
        loadMore: (e) => _currentPage,
        fetchListingsBySubwayStation: (e) => e.page,
        fetchListingsByLocation: (e) => e.page,
        searchListings: (e) => e.page,
        fetchUserListings: (e) => e.page,
      );

      final limit = event.map(
        fetchListings: (e) => e.limit,
        loadMore: (e) => e.limit,
        fetchListingsBySubwayStation: (e) => e.limit,
        fetchListingsByLocation: (e) => e.limit,
        searchListings: (e) => e.limit,
        fetchUserListings: (e) => e.limit,
      );

      // Service now automatically uses current app language
      final listings = await _listingService.getListingsBySubwayStation(
        subwayStationId,
        page: page,
        limit: limit,
      ).timeout(_requestTimeout);

      FavoritesState().syncFromListings(listings);

      if (isRefresh) {
        _currentListings = listings;
      } else {
        _currentListings = [..._currentListings, ...listings];
      }

      _hasMore = listings.length >= limit;

      emit(
        ListingsState.loaded(
          listings: _currentListings,
          total: _totalResults,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ),
      );

      _currentPage++;
    } catch (error) {
      emit(ListingsState.error(error.toString()));
    }
  }

  Future<void> _onFetchListingsByLocation(
    Emitter<ListingsState> emit,
    ListingsEvent event,
  ) async {
    final isRefresh = event.map(
      fetchListings: (e) => e.isRefresh,
      loadMore: (e) => false,
      fetchListingsBySubwayStation: (e) => e.isRefresh,
      fetchListingsByLocation: (e) => e.isRefresh,
      searchListings: (e) => e.isRefresh,
      fetchUserListings: (e) => e.isRefresh,
    );

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _currentListings = [];
      _totalResults = null;
    }

    emit(const ListingsState.loading());

    try {
      final locationId = event.map(
        fetchListings: (e) => 0,
        loadMore: (e) => 0,
        fetchListingsBySubwayStation: (e) => 0,
        fetchListingsByLocation: (e) => e.locationId,
        searchListings: (e) => 0,
        fetchUserListings: (e) => 0,
      );

      final page = event.map(
        fetchListings: (e) => e.page,
        loadMore: (e) => _currentPage,
        fetchListingsBySubwayStation: (e) => e.page,
        fetchListingsByLocation: (e) => e.page,
        searchListings: (e) => e.page,
        fetchUserListings: (e) => e.page,
      );

      final limit = event.map(
        fetchListings: (e) => e.limit,
        loadMore: (e) => e.limit,
        fetchListingsBySubwayStation: (e) => e.limit,
        fetchListingsByLocation: (e) => e.limit,
        searchListings: (e) => e.limit,
        fetchUserListings: (e) => e.limit,
      );

      // Service now automatically uses current app language
      if (isRefresh) {
        getIt<AppAnalyticsService>().logSearchPerformed(locationId: locationId);
      }

      final listings = await _listingService.getListingsByLocation(
        locationId,
        page: page,
        limit: limit,
      ).timeout(_requestTimeout);

      FavoritesState().syncFromListings(listings);

      if (isRefresh) {
        _currentListings = listings;
      } else {
        _currentListings = [..._currentListings, ...listings];
      }

      _hasMore = listings.length >= limit;

      emit(
        ListingsState.loaded(
          listings: _currentListings,
          total: _totalResults,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ),
      );

      _currentPage++;
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ListingsState.error(sanitizedMessage));
    }
  }

  Future<void> _onSearchListings(
    Emitter<ListingsState> emit,
    ListingsEvent event,
  ) async {
    final isRefresh = event.map(
      fetchListings: (e) => e.isRefresh,
      loadMore: (e) => false,
      fetchListingsBySubwayStation: (e) => e.isRefresh,
      fetchListingsByLocation: (e) => e.isRefresh,
      searchListings: (e) => e.isRefresh,
      fetchUserListings: (e) => e.isRefresh,
    );

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _currentListings = [];
      _totalResults = null;
    }

    // Store search parameters for load more operations
    final searchParams = event.map(
      fetchListings: (e) => null,
      loadMore: (e) => null,
      fetchListingsBySubwayStation: (e) => null,
      fetchListingsByLocation: (e) => null,
      searchListings:
          (e) => {
            "listingTypeId": e.listingTypeId,
            "locationId": e.locationId,
            "subwayStationId": e.subwayStationId,
            "subwayLineId": e.subwayLineId,
            "gender": e.gender,
            "minPrice": e.minPrice,
            "maxPrice": e.maxPrice,
            "privateRoom": e.privateRoom,
            "withPhoto": e.withPhoto,
          },
        fetchUserListings: (e) => null,
      );

    if (searchParams != null) {
      _stationOnlyMode = false;
      _lastListingTypeId = searchParams["listingTypeId"] as int?;
      _lastLocationId = searchParams["locationId"] as int?;
      _lastSubwayStationId = searchParams["subwayStationId"] as int?;
      _lastSubwayLineId = searchParams["subwayLineId"] as int?;
      _lastGender = searchParams["gender"] as int?;
      _lastMinPrice = searchParams["minPrice"] as double?;
      _lastMaxPrice = searchParams["maxPrice"] as double?;
      _lastPrivateRoom = searchParams["privateRoom"] as bool?;
      _lastWithPhoto = searchParams["withPhoto"] as bool?;

      if (isRefresh) {
        getIt<AppAnalyticsService>().logSearchPerformed(
          listingTypeId: _lastListingTypeId,
          locationId: _lastLocationId,
          subwayStationId: _lastSubwayStationId,
          subwayLineId: _lastSubwayLineId,
          gender: _lastGender,
          hasPriceFilter: _lastMinPrice != null || _lastMaxPrice != null,
          hasGenderFilter: _lastGender != null,
        );
      }
    }

    emit(const ListingsState.loading());

    try {
      final searchParams = event.map(
        fetchListings: (e) => null,
        loadMore: (e) => null,
        fetchListingsBySubwayStation: (e) => null,
        fetchListingsByLocation: (e) => null,
        searchListings:
            (e) => {
              "listingTypeId": e.listingTypeId,
              "locationId": e.locationId,
              "subwayStationId": e.subwayStationId,
              "subwayLineId": e.subwayLineId,
              "gender": e.gender,
              "minPrice": e.minPrice,
              "maxPrice": e.maxPrice,
              "privateRoom": e.privateRoom,
              "withPhoto": e.withPhoto,
            },
        fetchUserListings: (e) => null,
      );

      final page = event.map(
        fetchListings: (e) => e.page,
        loadMore: (e) => _currentPage,
        fetchListingsBySubwayStation: (e) => e.page,
        fetchListingsByLocation: (e) => e.page,
        searchListings: (e) => e.page,
        fetchUserListings: (e) => e.page,
      );

      final limit = event.map(
        fetchListings: (e) => e.limit,
        loadMore: (e) => e.limit,
        fetchListingsBySubwayStation: (e) => e.limit,
        fetchListingsByLocation: (e) => e.limit,
        searchListings: (e) => e.limit,
        fetchUserListings: (e) => e.limit,
      );

      // Use the new comprehensive search method
      final subwayStationId = searchParams?["subwayStationId"] as int?;
      final locationId = searchParams?["locationId"] as int?;
      final listingTypeId = searchParams?["listingTypeId"] as int?;
      final subwayLineId = searchParams?["subwayLineId"] as int?;
      final gender = searchParams?["gender"] as int?;
      final minPrice = searchParams?["minPrice"] as double?;
      final maxPrice = searchParams?["maxPrice"] as double?;
      final privateRoom = searchParams?["privateRoom"] as bool?;
      final withPhoto = searchParams?["withPhoto"] as bool?;

      logger.d("=== COMPREHENSIVE SEARCH BLOC DEBUG ===");
      logger.d("Listing Type ID: $listingTypeId");
      logger.d("Location ID: $locationId");
      logger.d("Subway Station ID: $subwayStationId");
      logger.d("Subway Line ID: $subwayLineId");
      logger.d("Gender: $gender");
      logger.d("Min Price: $minPrice");
      logger.d("Max Price: $maxPrice");
      logger.d("Private Room: $privateRoom");
      logger.d("With Photo: $withPhoto");
      logger.d("==========================================");

      // Use the new comprehensive search method that includes ALL parameters
      final response = await _listingService.searchListings(
        page: page,
        limit: limit,
        isActive: true,
        listingTypeId: listingTypeId,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayLineId: subwayLineId,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        privateRoom: privateRoom,
        withPhoto: withPhoto,
      ).timeout(_requestTimeout);

      final listings = response.data;
      FavoritesState().syncFromListings(listings);

      if (isRefresh) {
        _currentListings = listings;
      } else {
        _currentListings = [..._currentListings, ...listings];
      }

      _hasMore = listings.length >= limit;
      _totalResults = response.total;

      emit(
        ListingsState.loaded(
          listings: _currentListings,
          total: _totalResults,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ),
      );

      _currentPage++;
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ListingsState.error(sanitizedMessage));
    }
  }

  Future<void> _onFetchUserListings(
    Emitter<ListingsState> emit,
    ListingsEvent event,
  ) async {
    final isRefresh = event.map(
      fetchListings: (e) => false,
      loadMore: (e) => false,
      fetchListingsBySubwayStation: (e) => false,
      fetchListingsByLocation: (e) => false,
      searchListings: (e) => false,
      fetchUserListings: (e) => e.isRefresh,
    );

    if (isRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _currentListings = [];
      _totalResults = null;
    }

    emit(const ListingsState.loading());

    try {
      final page = event.map(
        fetchListings: (e) => 1,
        loadMore: (e) => 1,
        fetchListingsBySubwayStation: (e) => 1,
        fetchListingsByLocation: (e) => 1,
        searchListings: (e) => 1,
        fetchUserListings: (e) => e.page,
      );

      final limit = event.map(
        fetchListings: (e) => 10,
        loadMore: (e) => 10,
        fetchListingsBySubwayStation: (e) => 10,
        fetchListingsByLocation: (e) => 10,
        searchListings: (e) => 10,
        fetchUserListings: (e) => e.limit,
      );

      // Use the new getUserListings method
      final response = await _listingService.getUserListings(
        page: page,
        limit: limit,
      ).timeout(_requestTimeout);

      final listings = response.data;
      _hasMore = (page + 1) <= response.totalPages && listings.isNotEmpty;
      _totalResults = response.total;

      if (isRefresh) {
        _currentListings = listings;
      } else {
        _currentListings = [..._currentListings, ...listings];
      }

      emit(
        ListingsState.loaded(
          listings: _currentListings,
          total: _totalResults,
          hasMore: _hasMore,
          currentPage: _currentPage,
        ),
      );

      _currentPage++;
    } catch (error) {
      final sanitizedMessage = ErrorMessageHelper.sanitizeErrorMessage(error);
      emit(ListingsState.error(sanitizedMessage));
    }
  }
}
