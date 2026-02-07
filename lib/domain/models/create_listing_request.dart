import 'package:uy_dosh/base/api/client/json_encodable.dart';

class CreateListingRequest implements IJsonEncodable {
  final String title;
  final int listingTypeId;
  final int minPrice;
  final int maxPrice;
  final String description;
  final int gender;
  final int? subwayStationId; // Made optional
  final List<int>? subwayStationIds; // Optional list of stations
  final int? subwayLineId; // Add subway line ID
  final int? locationId;
  final List<int>? locationIds; // Optional list of locations
  final List<int> amenityIds;
  final String? moveInDate; // Add move-in date field
  final bool? privateRoom; // Add private room field
  final int?
  userId; // Make user ID optional - server might extract it from JWT token

  CreateListingRequest({
    required this.title,
    required this.listingTypeId,
    required this.minPrice,
    required this.maxPrice,
    required this.description,
    required this.gender,
    this.subwayStationId, // Made optional
    this.subwayStationIds, // Optional list of stations
    this.subwayLineId, // Add subway line ID parameter
    this.locationId,
    this.locationIds, // Optional list of locations
    required this.amenityIds,
    this.moveInDate, // Add move-in date parameter
    this.privateRoom, // Add private room parameter
    required this.userId, // Add user ID parameter
  });

  @override
  dynamic toJson() {
    final Map<String, dynamic> json = {
      'title': title,
      'listingTypeId': listingTypeId,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'description': description,
      'gender': gender,
      'amenityIds': amenityIds,
      'subwayLineId':
          subwayLineId, // Always include, sends null when no metro line
      'privateRoom':
          privateRoom, // Always include, sends null when no private room preference
    };

    final normalizedLocationIds =
        locationIds != null && locationIds!.isNotEmpty
            ? locationIds!
            : (locationId != null ? [locationId!] : null);
    if (normalizedLocationIds != null) {
      json['locationIds'] = normalizedLocationIds;
      json['locationId'] = normalizedLocationIds.first;
    }

    final normalizedStationIds =
        subwayStationIds != null && subwayStationIds!.isNotEmpty
            ? subwayStationIds!
            : (subwayStationId != null ? [subwayStationId!] : null);
    if (normalizedStationIds != null) {
      json['subwayStationIds'] = normalizedStationIds;
      json['subwayStationId'] = normalizedStationIds.first;
    }

    // Only include moveInDate if it's not null
    if (moveInDate != null) {
      json['moveInDate'] = moveInDate;
    }

    // Only include userId if it's not null
    if (userId != null) {
      json['userId'] = userId;
    }

    return json;
  }
}
