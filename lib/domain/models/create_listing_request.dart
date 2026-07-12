import "package:uy_dosh/base/api/client/json_encodable.dart";

class CreateListingRequest implements IJsonEncodable {
  // Make user ID optional - server might extract it from JWT token

  CreateListingRequest({
    required this.title,
    required this.listingTypeId,
    required this.price,
    required this.description,
    required this.gender,
    required this.amenityIds,
    this.minPrice,
    this.maxPrice,
    this.locationId, // Optional: omitted in metro-mode (derived from station)
    this.locationIds, // Multi-location selection (demand-side listings)
    this.cityId,
    this.subwayStationId, // Made optional
    this.subwayStationIds, // Multi-station selection (demand-side listings)
    this.subwayLineId, // Add subway line ID parameter
    this.addressText,
    this.addressLatitude,
    this.addressLongitude,
    this.moveInDate, // Add move-in date parameter
    this.privateRoom, // Add private room parameter
    this.hostResident,
    this.userId, // Add user ID parameter
    this.groupSizeTarget,
    this.contactPhone,
    this.contactTelegram,
  });
  final String title;
  final int listingTypeId;
  final int price;
  final int? minPrice;
  final int? maxPrice;
  final String description;
  final int gender;
  final int? locationId;
  final List<int>? locationIds;
  final List<int> amenityIds;
  final int? cityId;
  final int? subwayStationId; // Made optional
  final List<int>? subwayStationIds; // Multi-station selection
  final int? subwayLineId; // Add subway line ID
  final String? addressText;
  final double? addressLatitude;
  final double? addressLongitude;
  final String? moveInDate; // Add move-in date field
  final bool? privateRoom; // Add private room field
  final bool? hostResident;
  final int? userId;
  final int? groupSizeTarget;

  /// Admin-only override of the listing owner's contact info (see
  /// `EditListingScreen`'s admin contact section). `null` means "leave the
  /// currently saved value untouched" — regular (non-admin) edits never set
  /// these, so they're omitted from `toJson` below rather than clearing
  /// existing contact info. An empty string explicitly clears it server-side.
  final String? contactPhone;
  final String? contactTelegram;

  @override
  dynamic toJson() {
    final json = <String, dynamic>{
      "title": title,
      "listingTypeId": listingTypeId,
      "price": price,
      if (minPrice != null) "minPrice": minPrice,
      if (maxPrice != null) "maxPrice": maxPrice,
      "description": description,
      "gender": gender,
      if (locationId != null) "locationId": locationId,
      "cityId": cityId,
      "amenityIds": amenityIds,
      "subwayStationId":
          subwayStationId, // Always include, sends null when no metro station
      "subwayLineId":
          subwayLineId, // Always include, sends null when no metro line
      if (addressText != null) "addressText": addressText,
      if (addressLatitude != null) "addressLatitude": addressLatitude,
      if (addressLongitude != null) "addressLongitude": addressLongitude,
      "privateRoom":
          privateRoom, // Always include, sends null when no private room preference
    };

    if (hostResident != null) {
      json["hostResident"] = hostResident;
    }

    // Only include moveInDate if it's not null
    if (moveInDate != null) {
      json["moveInDate"] = moveInDate;
    }

    // Only include userId if it's not null
    if (userId != null) {
      json["userId"] = userId;
    }

    if (groupSizeTarget != null) {
      json["groupSizeTarget"] = groupSizeTarget;
    }

    // Only include when provided so omitting it (e.g. the single-screen edit
    // form) leaves any previously saved multi-station set untouched server-side.
    if (subwayStationIds != null) {
      json["subwayStationIds"] = subwayStationIds;
    }

    // Only include when provided so omitting it (e.g. the single-screen edit
    // form) leaves any previously saved multi-location set untouched server-side.
    if (locationIds != null) {
      json["locationIds"] = locationIds;
    }

    if (contactPhone != null) {
      json["contactPhone"] = contactPhone;
    }

    if (contactTelegram != null) {
      json["contactTelegram"] = contactTelegram;
    }

    return json;
  }
}
