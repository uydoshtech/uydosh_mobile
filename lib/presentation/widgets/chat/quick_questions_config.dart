/// Resolves which quick-question l10n keys to show in the chat composer.
///
/// Chips are category-agnostic (housing, gigs, services, etc.): price, scope,
/// timing, and logistics — see [kGenericQuickQuestionKeys].
///
/// [listingTypeId] and [isViewerListingOwner] are retained for a stable API;
/// the chip list no longer depends on listing type.
library;

// Order matches UX priority on the horizontal strip.
const List<String> kGenericQuickQuestionKeys = [
  "quick_question_generic_price",
  "quick_question_generic_whats_included",
  "quick_question_generic_when_available",
  "quick_question_generic_how_soon",
  "quick_question_generic_arrangement",
  "quick_question_generic_clarify_details",
];

/// Returns the quick-question key list for the chat composer.
List<String> quickQuestionKeysFor({
  required int? listingTypeId,
  required bool isViewerListingOwner,
}) {
  return kGenericQuickQuestionKeys;
}
