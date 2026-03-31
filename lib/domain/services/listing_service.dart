import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:uy_dosh/domain/services/listing_crud_service.dart";
import "package:uy_dosh/domain/services/listing_detail_service.dart";
import "package:uy_dosh/domain/services/listing_search_service.dart";

abstract class IListingService {
  Future<PageableResponse<Listing>> getListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    int createdWithinDays = 30,
  });

  Future<List<Listing>> getListingsBySubwayStation(
    int subwayStationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = 30,
  });

  Future<List<Listing>> getListingsByLocation(
    int locationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = 30,
  });

  /// Subway station IDs that have at least one active listing (single request).
  Future<List<int>> getSubwayStationIdsWithListings({
    int createdWithinDays = 30,
  });

  Future<ListingDetail> getListingDetail(int listingId, {String? language});

  Future<void> saveDescriptionTranslation({
    required int listingId,
    required String targetLanguageCode,
    required String translatedText,
  });

  Future<ListingDetail> createListing({
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    List<String>? photoPaths,
  });

  Future<ListingDetail> updateListing({
    required int listingId,
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    List<String>? photoPaths,
  });

  Future<PageableResponse<Listing>> searchListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    int createdWithinDays = 30,
  });

  Future<PageableResponse<Listing>> getUserListings({
    int page = 1,
    int limit = 10,
    String? language,
  });

  Future<PageableResponse<Listing>> getListingsByUserId({
    required int userId,
    int page = 1,
    int limit = 10,
    String? language,
  });

  Future<bool> toggleListingActive(int listingId);
  Future<bool> deleteListing(int listingId);
  Future<bool> uploadListingPhotos({
    required int listingId,
    required List<String> photoPaths,
    required List<bool> isPrimaryFlags,
  });
  Future<bool> uploadPhoto({
    required int listingId,
    required String photoPath,
    required bool isPrimary,
  });
  Future<bool> deletePhoto({required int listingId, required int photoId});
  Future<bool> setPrimaryPhoto({required int listingId, required int photoId});
  Future<bool> featureListing(int listingId);
  Future<bool> toggleFeatureListing(int listingId, bool isCurrentlyFeatured);
  Future<void> recordListingView(int listingId);
  Future<PageableResponse<Listing>> getViewedListings({
    int page = 1,
    int limit = 50,
  });
  Future<int> getListingViewCount(int listingId);
  Future<List<Map<String, dynamic>>> getListingViewStatsByDay(
    int listingId, {
    int daysBack = 30,
  });
}

/// Facade that delegates to [IListingSearchService], [IListingCrudService],
/// and [IListingDetailService].
class ListingService implements IListingService {
  ListingService(IPublicApiClient apiClient, IOAuthApiClient oauthApiClient)
      : _searchService = ListingSearchService(apiClient, oauthApiClient),
        _crudService = ListingCrudService(oauthApiClient),
        _detailService = ListingDetailService(apiClient, oauthApiClient);

  final IListingSearchService _searchService;
  final IListingCrudService _crudService;
  final IListingDetailService _detailService;

  @override
  Future<PageableResponse<Listing>> getListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    int createdWithinDays = 30,
  }) =>
      _searchService.getListings(
        page: page,
        limit: limit,
        isActive: isActive,
        language: language,
        listingTypeId: listingTypeId,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayStationIds: subwayStationIds,
        subwayLineId: subwayLineId,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        createdWithinDays: createdWithinDays,
      );

  @override
  Future<List<Listing>> getListingsBySubwayStation(
    int subwayStationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = 30,
  }) =>
      _searchService.getListingsBySubwayStation(
        subwayStationId,
        page: page,
        limit: limit,
        language: language,
        createdWithinDays: createdWithinDays,
      );

  @override
  Future<List<Listing>> getListingsByLocation(
    int locationId, {
    int page = 1,
    int limit = 10,
    String? language,
    int createdWithinDays = 30,
  }) =>
      _searchService.getListingsByLocation(
        locationId,
        page: page,
        limit: limit,
        language: language,
        createdWithinDays: createdWithinDays,
      );

  @override
  Future<List<int>> getSubwayStationIdsWithListings({
    int createdWithinDays = 30,
  }) =>
      _searchService.getSubwayStationIdsWithListings(
        createdWithinDays: createdWithinDays,
      );

  @override
  Future<ListingDetail> getListingDetail(int listingId, {String? language}) =>
      _detailService.getListingDetail(listingId, language: language);

  @override
  Future<void> saveDescriptionTranslation({
    required int listingId,
    required String targetLanguageCode,
    required String translatedText,
  }) =>
      _detailService.saveDescriptionTranslation(
        listingId: listingId,
        targetLanguageCode: targetLanguageCode,
        translatedText: translatedText,
      );

  @override
  Future<ListingDetail> createListing({
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    List<String>? photoPaths,
  }) =>
      _crudService.createListing(
        title: title,
        listingTypeId: listingTypeId,
        price: price,
        description: description,
        gender: gender,
        locationId: locationId,
        amenityIds: amenityIds,
        subwayStationId: subwayStationId,
        subwayLineId: subwayLineId,
        moveInDate: moveInDate,
        privateRoom: privateRoom,
        photoPaths: photoPaths,
      );

  @override
  Future<ListingDetail> updateListing({
    required int listingId,
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required int locationId,
    required List<int> amenityIds,
    int? subwayStationId,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    List<String>? photoPaths,
  }) =>
      _crudService.updateListing(
        listingId: listingId,
        title: title,
        listingTypeId: listingTypeId,
        price: price,
        description: description,
        gender: gender,
        locationId: locationId,
        amenityIds: amenityIds,
        subwayStationId: subwayStationId,
        subwayLineId: subwayLineId,
        moveInDate: moveInDate,
        privateRoom: privateRoom,
        photoPaths: photoPaths,
      );

  @override
  Future<PageableResponse<Listing>> searchListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    int createdWithinDays = 30,
  }) =>
      _searchService.searchListings(
        page: page,
        limit: limit,
        isActive: isActive,
        language: language,
        listingTypeId: listingTypeId,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayStationIds: subwayStationIds,
        subwayLineId: subwayLineId,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        privateRoom: privateRoom,
        createdWithinDays: createdWithinDays,
      );

  @override
  Future<PageableResponse<Listing>> getUserListings({
    int page = 1,
    int limit = 10,
    String? language,
  }) =>
      _searchService.getUserListings(
        page: page,
        limit: limit,
        language: language,
      );

  @override
  Future<PageableResponse<Listing>> getListingsByUserId({
    required int userId,
    int page = 1,
    int limit = 10,
    String? language,
  }) =>
      _searchService.getListingsByUserId(
        userId: userId,
        page: page,
        limit: limit,
        language: language,
      );

  @override
  Future<bool> toggleListingActive(int listingId) =>
      _crudService.toggleListingActive(listingId);

  @override
  Future<bool> deleteListing(int listingId) =>
      _crudService.deleteListing(listingId);

  @override
  Future<bool> uploadListingPhotos({
    required int listingId,
    required List<String> photoPaths,
    required List<bool> isPrimaryFlags,
  }) =>
      _crudService.uploadListingPhotos(
        listingId: listingId,
        photoPaths: photoPaths,
        isPrimaryFlags: isPrimaryFlags,
      );

  @override
  Future<bool> uploadPhoto({
    required int listingId,
    required String photoPath,
    required bool isPrimary,
  }) =>
      _crudService.uploadPhoto(
        listingId: listingId,
        photoPath: photoPath,
        isPrimary: isPrimary,
      );

  @override
  Future<bool> deletePhoto({
    required int listingId,
    required int photoId,
  }) =>
      _crudService.deletePhoto(listingId: listingId, photoId: photoId);

  @override
  Future<bool> setPrimaryPhoto({
    required int listingId,
    required int photoId,
  }) =>
      _crudService.setPrimaryPhoto(listingId: listingId, photoId: photoId);

  @override
  Future<bool> featureListing(int listingId) =>
      _crudService.featureListing(listingId);

  @override
  Future<bool> toggleFeatureListing(
    int listingId,
    bool isCurrentlyFeatured,
  ) =>
      _crudService.toggleFeatureListing(listingId, isCurrentlyFeatured);

  @override
  Future<void> recordListingView(int listingId) =>
      _detailService.recordListingView(listingId);

  @override
  Future<PageableResponse<Listing>> getViewedListings({
    int page = 1,
    int limit = 50,
  }) =>
      _detailService.getViewedListings(page: page, limit: limit);

  @override
  Future<int> getListingViewCount(int listingId) =>
      _detailService.getListingViewCount(listingId);

  @override
  Future<List<Map<String, dynamic>>> getListingViewStatsByDay(
    int listingId, {
    int daysBack = 30,
  }) =>
      _detailService.getListingViewStatsByDay(listingId, daysBack: daysBack);
}
