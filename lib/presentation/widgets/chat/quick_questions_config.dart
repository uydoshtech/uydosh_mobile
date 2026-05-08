/// Resolves which quick-question l10n keys to show in the chat composer.
///
/// Seeker/client side: price, scope, timing, logistics —
/// see [kGenericQuickQuestionKeys].
///
/// Listing owner / gig service provider side: prompts to qualify the job —
/// see [kOffererQuickQuestionKeys].
///
/// [listingTypeId] is retained for a stable API; chips do not depend on it.
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

/// Quick questions when the viewer is the offerer (listing author or gig provider).
const List<String> kOffererQuickQuestionKeys = [
  "quick_question_offerer_scope",
  "quick_question_offerer_deadline",
  "quick_question_offerer_where",
  "quick_question_offerer_budget",
  "quick_question_offerer_materials",
  "quick_question_offerer_visit",
];

/// Returns the quick-question key list for the chat composer.
List<String> quickQuestionKeysFor({
  required int? listingTypeId,
  required bool isViewerServiceOfferer,
}) {
  if (isViewerServiceOfferer) return kOffererQuickQuestionKeys;
  return kGenericQuickQuestionKeys;
}
