/// Listing type ids aligned with backend `listing_types` seed.
abstract final class ListingTypeIds {
  static const int roomNeeded = 1;
  static const int roommateNeeded = 2;
  static const int groupForming = 3;
  static const int apartmentRent = 5;

  /// Places a landlord browses: a room that needs a roommate, or a whole apartment.
  static const List<int> landlordDemandListingTypeIds = [
    roommateNeeded,
    apartmentRent,
  ];
}

abstract final class ListingTypeCodes {
  static const String roomNeeded = "room_needed";
  static const String roommateNeeded = "roommate_needed";
  static const String groupForming = "group_forming";
  static const String apartmentRent = "apartment_rent";
}
