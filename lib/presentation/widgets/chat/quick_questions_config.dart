/// Resolves which quick-question l10n keys to show in the chat composer.
///
/// **Gigs** (`gig_request` / `gig_offer` / `gig_booking`): service requester chips
/// vs service provider ("offerer") chips — [kServiceNeedQuickQuestionKeys] /
/// [kServiceOfferQuickQuestionKeys].
///
/// **Housing listings** (`listingTypeId` 1 or 2): renting "need room" vs
/// "need roommate", each with one strip for the **listing author** and one
/// for everyone else (`isViewerListingAuthor` false).
library;

bool _isGigConversation(String? conversationContextType) {
  switch (conversationContextType?.trim().toLowerCase()) {
    case "gig_request":
    case "gig_offer":
    case "gig_booking":
      return true;
    default:
      return false;
  }
}

/// Viewer is looking for someone to deliver a task (messages a provider).
const List<String> kServiceNeedQuickQuestionKeys = [
  "quick_question_generic_price",
  "quick_question_generic_whats_included",
  "quick_question_generic_when_available",
  "quick_question_generic_how_soon",
  "quick_question_generic_arrangement",
  "quick_question_generic_clarify_details",
];

/// Viewer offers the service — qualify what the counterparty needs.
const List<String> kServiceOfferQuickQuestionKeys = [
  "quick_question_offerer_scope",
  "quick_question_offerer_deadline",
  "quick_question_offerer_where",
  "quick_question_offerer_budget",
  "quick_question_offerer_materials",
  "quick_question_offerer_visit",
];

/// Listing author for [listingTypeNeedRoom] asks about housing on offer.
const List<String> kNeedRoomListingAuthorQuickQuestionKeys = [
  "quick_question_room_available",
  "quick_question_move_in_date",
  "quick_question_people_living",
  "quick_question_total_price",
  "quick_question_can_visit_soon",
];

/// Counterparty chats with someone who posted "need room" — qualifies them.
const List<String> kNeedRoomCounterpartyQuickQuestionKeys = [
  "quick_question_seeker_move_in_when",
  "quick_question_seeker_budget",
  "quick_question_seeker_how_long",
  "quick_question_seeker_about_you",
];

/// Listing author for [listingTypeNeedRoommate] — roommate / household tone.
const List<String> kNeedRoommateListingAuthorQuickQuestionKeys = [
  "quick_question_roommate_still_searching",
  "quick_question_roommate_move_in_date",
  "quick_question_roommate_household",
  "quick_question_roommate_rent_terms",
  "quick_question_roommate_meet_soon",
];

/// Counterparty chats with someone who posted "need roommate".
const List<String> kNeedRoommateCounterpartyQuickQuestionKeys =
    kNeedRoomCounterpartyQuickQuestionKeys;

/// Canonical backend ids — see [ListingUtils].
const int listingTypeNeedRoom = 1;
const int listingTypeNeedRoommate = 2;

/// Returns the quick-question key list for the chat composer.
List<String> quickQuestionKeysFor({
  required String? conversationContextType,
  required int? listingTypeId,
  required bool isViewerServiceOfferer,
  required bool isViewerListingAuthor,
}) {
  if (_isGigConversation(conversationContextType)) {
    return isViewerServiceOfferer
        ? kServiceOfferQuickQuestionKeys
        : kServiceNeedQuickQuestionKeys;
  }

  if (listingTypeId == listingTypeNeedRoom) {
    return isViewerListingAuthor
        ? kNeedRoomListingAuthorQuickQuestionKeys
        : kNeedRoomCounterpartyQuickQuestionKeys;
  }
  if (listingTypeId == listingTypeNeedRoommate) {
    return isViewerListingAuthor
        ? kNeedRoommateListingAuthorQuickQuestionKeys
        : kNeedRoommateCounterpartyQuickQuestionKeys;
  }

  return isViewerServiceOfferer
      ? kServiceOfferQuickQuestionKeys
      : kServiceNeedQuickQuestionKeys;
}
