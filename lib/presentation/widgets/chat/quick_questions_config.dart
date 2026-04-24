/// Resolves which quick-question l10n keys to show in the chat composer.
///
/// There are only two listing types in the system (see
/// `src/db/seed/baseline_data.sql` in the backend):
///   - id=1 `room_needed`      → poster is a seeker ("ищу комнату")
///   - id=2 `roommate_needed`  → poster is a landlord / main tenant
///
/// The chip set depends on who the viewer is talking TO, not on the listing
/// type alone. We collapse the 2×2 matrix (listing × owner-view) into two
/// audiences:
///   - [QuestionAudience.askingAboutHousing]: counterparty offers housing,
///     viewer asks about the place (price, availability, move-in date, …).
///   - [QuestionAudience.askingAboutSeeker]: counterparty is a seeker,
///     viewer asks about the person (budget, timing, lifestyle, …).
enum QuestionAudience { askingAboutHousing, askingAboutSeeker }

/// Pure resolver. Keep free of Flutter imports so it stays trivially testable.
QuestionAudience resolveQuestionAudience({
  required int? listingTypeId,
  required bool isViewerListingOwner,
}) {
  // Fallback when the caller doesn't know the listing type yet (e.g. chat
  // opened from a push notification before the conversation payload lands).
  // Keep the legacy "asking about housing" set — matches pre-refactor UX.
  if (listingTypeId == null) return QuestionAudience.askingAboutHousing;

  const roomNeeded = 1;
  const roommateNeeded = 2;

  switch (listingTypeId) {
    case roommateNeeded:
      return isViewerListingOwner
          ? QuestionAudience.askingAboutSeeker
          : QuestionAudience.askingAboutHousing;
    case roomNeeded:
      return isViewerListingOwner
          ? QuestionAudience.askingAboutHousing
          : QuestionAudience.askingAboutSeeker;
    default:
      return QuestionAudience.askingAboutHousing;
  }
}

/// L10n keys rendered when the viewer wants to know about the listed housing.
/// Order matters: first items are most valuable; the strip scrolls horizontally
/// so no hard cap, but 3–5 is the sweet spot.
const List<String> kAskingAboutHousingKeys = [
  "quick_question_room_available",
  "quick_question_move_in_date",
  "quick_question_total_price",
  "quick_question_people_living",
  "quick_question_can_visit_soon",
];

/// L10n keys rendered when the viewer wants to learn about the seeker.
const List<String> kAskingAboutSeekerKeys = [
  "quick_question_seeker_move_in_when",
  "quick_question_seeker_budget",
  "quick_question_seeker_how_long",
  "quick_question_seeker_about_you",
];

/// Convenience: returns the full key list for a given context.
List<String> quickQuestionKeysFor({
  required int? listingTypeId,
  required bool isViewerListingOwner,
}) {
  final audience = resolveQuestionAudience(
    listingTypeId: listingTypeId,
    isViewerListingOwner: isViewerListingOwner,
  );
  switch (audience) {
    case QuestionAudience.askingAboutHousing:
      return kAskingAboutHousingKeys;
    case QuestionAudience.askingAboutSeeker:
      return kAskingAboutSeekerKeys;
  }
}
