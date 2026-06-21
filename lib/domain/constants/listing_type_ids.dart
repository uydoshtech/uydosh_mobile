/// Listing type ids aligned with backend `listing_types` seed.
abstract final class ListingTypeIds {
  static const int roomNeeded = 1;
  static const int roommateNeeded = 2;
  static const int groupForming = 3;

  /// Demand-side types shown together in the landlord home feed by default.
  static const List<int> landlordDemandListingTypeIds = [
    roomNeeded,
    groupForming,
  ];
}

abstract final class ListingTypeCodes {
  static const String roomNeeded = "room_needed";
  static const String roommateNeeded = "roommate_needed";
  static const String groupForming = "group_forming";
}
