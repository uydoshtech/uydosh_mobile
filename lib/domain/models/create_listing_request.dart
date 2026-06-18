import "package:uy_dosh/base/api/client/json_encodable.dart";

class CreateListingRequest implements IJsonEncodable { // Make user ID optional - server might extract it from JWT token

  CreateListingRequest({
    required this.title,
    required this.listingTypeId,
    required this.price,
    required this.description,
    required this.gender,
    required this.locationId,
    required this.amenityIds,
    this.cityId,
    this.subwayStationId, // Made optional
    this.subwayLineId, // Add subway line ID parameter
    this.moveInDate, // Add move-in date parameter
    this.privateRoom, // Add private room parameter
    this.userId, // Add user ID parameter
    this.groupSizeTarget,
  });
  final String title;
  final int listingTypeId;
  final int price;
  final String description;
  final int gender;
  final int locationId;
  final List<int> amenityIds;
  final int? cityId;
  final int? subwayStationId; // Made optional
  final int? subwayLineId; // Add subway line ID
  final String? moveInDate; // Add move-in date field
  final bool? privateRoom; // Add private room field
  final int? userId;
  final int? groupSizeTarget;

  @override
  dynamic toJson() {
    final json = <String, dynamic>{
      "title": title,
      "listingTypeId": listingTypeId,
      "price": price,
      "description": description,
      "gender": gender,
      "locationId": locationId,
      "cityId": cityId,
      "amenityIds": amenityIds,
      "subwayStationId":
          subwayStationId, // Always include, sends null when no metro station
      "subwayLineId":
          subwayLineId, // Always include, sends null when no metro line
      "privateRoom":
          privateRoom, // Always include, sends null when no private room preference
    };

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

    return json;
  }
}
