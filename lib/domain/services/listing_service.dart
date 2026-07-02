import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/api/client/public_api_client.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/listing_map_pin_data.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:uy_dosh/domain/services/listing_crud_service.dart";
import "package:uy_dosh/domain/services/listing_detail_service.dart";
import "package:uy_dosh/domain/services/listing_search_service.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";

abstract class IListingService {
  Future<PageableResponse<Listing>> getListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    int createdWithinDays = 30,
  });

  Future<List<Listing>> getListingsByLocation(
    int locationId, {
    int page = 1,
    int limit = 10,
    String? language,
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
    required List<int> amenityIds,
    int? locationId,
    List<int>? locationIds,
    int? minPrice,
    int? maxPrice,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    String? addressText,
    double? addressLatitude,
    double? addressLongitude,
    String? moveInDate,
    bool? privateRoom,
    bool? hostResident,
    List<String>? photoPaths,
    int? groupSizeTarget,
  });

  Future<ListingDetail> updateListing({
    required int listingId,
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required List<int> amenityIds,
    int? locationId,
    List<int>? locationIds,
    int? minPrice,
    int? maxPrice,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    bool? hostResident,
    List<String>? photoPaths,
    int? groupSizeTarget,
  });

  Future<PageableResponse<Listing>> searchListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    int createdWithinDays = 30,
    List<int>? excludeUserIds,
  });

  Future<PageableResponse<ListingMapPinData>> searchMapListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    int createdWithinDays = 30,
    List<int>? excludeUserIds,
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
  Future<List<int>> uploadListingPhotos({
    required int listingId,
    required List<String> photoPaths,
    required List<bool> isPrimaryFlags,
  });
  Future<int> uploadPhoto({
    required int listingId,
    required String photoPath,
    required bool isPrimary,
  });
  Future<bool> deletePhoto({required int listingId, required int photoId});
  Future<bool> setPrimaryPhoto({required int listingId, required int photoId});
  Future<bool> reorderPhotos({
    required int listingId,
    required List<int> photoIds,
  });
  Future<void> uploadRoomScan({
    required int listingId,
    required String usdzFilePath,
    RoomScanMetrics? roomScanMetrics,
  });
  Future<void> patchRoomScanMetricsIfMissing({
    required int listingId,
    required RoomScanMetrics metrics,
  });
  Future<void> patchRoomScanNorthCorrection({
    required int listingId,
    required double? northCorrectionDeg,
  });
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
        _detailService = ListingDetailService(oauthApiClient);

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
    List<int>? listingTypeIds,
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
        listingTypeIds: listingTypeIds,
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
    required List<int> amenityIds,
    int? locationId,
    List<int>? locationIds,
    int? minPrice,
    int? maxPrice,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    String? addressText,
    double? addressLatitude,
    double? addressLongitude,
    String? moveInDate,
    bool? privateRoom,
    bool? hostResident,
    List<String>? photoPaths,
    int? groupSizeTarget,
  }) =>
      _crudService.createListing(
        title: title,
        listingTypeId: listingTypeId,
        price: price,
        description: description,
        gender: gender,
        locationId: locationId,
        locationIds: locationIds,
        amenityIds: amenityIds,
        minPrice: minPrice,
        maxPrice: maxPrice,
        subwayStationId: subwayStationId,
        subwayStationIds: subwayStationIds,
        subwayLineId: subwayLineId,
        addressText: addressText,
        addressLatitude: addressLatitude,
        addressLongitude: addressLongitude,
        moveInDate: moveInDate,
        privateRoom: privateRoom,
        hostResident: hostResident,
        photoPaths: photoPaths,
        groupSizeTarget: groupSizeTarget,
      );

  @override
  Future<ListingDetail> updateListing({
    required int listingId,
    required String title,
    required int listingTypeId,
    required int price,
    required String description,
    required int gender,
    required List<int> amenityIds,
    int? locationId,
    List<int>? locationIds,
    int? minPrice,
    int? maxPrice,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    String? moveInDate,
    bool? privateRoom,
    bool? hostResident,
    List<String>? photoPaths,
    int? groupSizeTarget,
  }) =>
      _crudService.updateListing(
        listingId: listingId,
        title: title,
        listingTypeId: listingTypeId,
        price: price,
        description: description,
        gender: gender,
        locationId: locationId,
        locationIds: locationIds,
        amenityIds: amenityIds,
        minPrice: minPrice,
        maxPrice: maxPrice,
        subwayStationId: subwayStationId,
        subwayStationIds: subwayStationIds,
        subwayLineId: subwayLineId,
        moveInDate: moveInDate,
        privateRoom: privateRoom,
        hostResident: hostResident,
        photoPaths: photoPaths,
        groupSizeTarget: groupSizeTarget,
      );

  @override
  Future<PageableResponse<Listing>> searchListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    int createdWithinDays = 30,
    List<int>? excludeUserIds,
  }) =>
      _searchService.searchListings(
        page: page,
        limit: limit,
        isActive: isActive,
        language: language,
        listingTypeId: listingTypeId,
        listingTypeIds: listingTypeIds,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayStationIds: subwayStationIds,
        subwayLineId: subwayLineId,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        privateRoom: privateRoom,
        withPhoto: withPhoto,
        createdWithinDays: createdWithinDays,
        excludeUserIds: excludeUserIds,
      );

  @override
  Future<PageableResponse<ListingMapPinData>> searchMapListings({
    int page = 1,
    int limit = 10,
    bool isActive = true,
    String? language,
    int? listingTypeId,
    List<int>? listingTypeIds,
    int? locationId,
    int? subwayStationId,
    List<int>? subwayStationIds,
    int? subwayLineId,
    int? gender,
    double? minPrice,
    double? maxPrice,
    bool? privateRoom,
    bool? withPhoto,
    int createdWithinDays = 30,
    List<int>? excludeUserIds,
  }) =>
      _searchService.searchMapListings(
        page: page,
        limit: limit,
        isActive: isActive,
        language: language,
        listingTypeId: listingTypeId,
        listingTypeIds: listingTypeIds,
        locationId: locationId,
        subwayStationId: subwayStationId,
        subwayStationIds: subwayStationIds,
        subwayLineId: subwayLineId,
        gender: gender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        privateRoom: privateRoom,
        withPhoto: withPhoto,
        createdWithinDays: createdWithinDays,
        excludeUserIds: excludeUserIds,
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
  Future<List<int>> uploadListingPhotos({
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
  Future<int> uploadPhoto({
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
  Future<bool> reorderPhotos({
    required int listingId,
    required List<int> photoIds,
  }) =>
      _crudService.reorderPhotos(listingId: listingId, photoIds: photoIds);

  @override
  Future<void> uploadRoomScan({
    required int listingId,
    required String usdzFilePath,
    RoomScanMetrics? roomScanMetrics,
  }) =>
      _crudService.uploadRoomScan(
        listingId: listingId,
        usdzFilePath: usdzFilePath,
        roomScanMetrics: roomScanMetrics,
      );

  @override
  Future<void> patchRoomScanMetricsIfMissing({
    required int listingId,
    required RoomScanMetrics metrics,
  }) =>
      _crudService.patchRoomScanMetricsIfMissing(
        listingId: listingId,
        metrics: metrics,
      );

  @override
  Future<void> patchRoomScanNorthCorrection({
    required int listingId,
    required double? northCorrectionDeg,
  }) =>
      _crudService.patchRoomScanNorthCorrection(
        listingId: listingId,
        northCorrectionDeg: northCorrectionDeg,
      );

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
