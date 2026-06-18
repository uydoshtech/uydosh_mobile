import "package:uy_dosh/domain/models/listing_detail.dart";

/// Cross-type "nearby matches" search derived from a listing detail screen.
///
/// A seeker listing (`room_needed`) surfaces roommate offers; an offer listing
/// (`roommate_needed`) surfaces seekers in the same area.
class ListingDetailNearbyMatchesHelper {
  ListingDetailNearbyMatchesHelper._();

  static int? complementaryListingTypeId(int listingTypeId) {
    switch (listingTypeId) {
      case 1:
        return 2;
      case 2:
        return 1;
      default:
        return null;
    }
  }

  static bool hasGeoAnchor(ListingDetail listing) {
    return _subwayStationId(listing) != null || _locationId(listing) != null;
  }

  static bool canShowForListing(ListingDetail listing) {
    return complementaryListingTypeId(listing.listingTypeId) != null &&
        hasGeoAnchor(listing);
  }

  /// AppStrings / L10n key for the tile label based on the current listing type.
  static String labelKeyForListing(ListingDetail listing) {
    switch (listing.listingType.code) {
      case "room_needed":
        return "listing_detail_nearby_room_offers";
      case "roommate_needed":
        return "listing_detail_nearby_room_seekers";
      default:
        return "listing_detail_nearby_matches";
    }
  }

  static ({
    int complementaryListingTypeId,
    int? subwayStationId,
    int? locationId,
    int? gender,
  }) searchFilters(ListingDetail listing) {
    final stationId = _subwayStationId(listing);
    return (
      complementaryListingTypeId:
          complementaryListingTypeId(listing.listingTypeId)!,
      subwayStationId: stationId,
      locationId: stationId == null ? _locationId(listing) : null,
      gender: listing.gender,
    );
  }

  static int? _subwayStationId(ListingDetail listing) {
    return listing.subwayStation?.id ?? listing.subwayStationId;
  }

  static int? _locationId(ListingDetail listing) {
    return listing.location?.id ?? listing.locationId;
  }
}
