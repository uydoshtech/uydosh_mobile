import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";

/// Housing / marketplace listing threads (anything not under the gig chat
/// surfaces).
bool conversationSummaryIsListingMarketplaceChat(ConversationSummary c) {
  final t = c.contextType;
  return t != "gig_request" && t != "gig_offer" && t != "gig_booking";
}

/// Same resolution as [resolvedConversationListingTitle] but from full listing
/// detail when opening chat from [ListingDetailScreen].
String resolvedListingChatTitleFromListingDetail(ListingDetail d) {
  final tid = d.listingTypeId;
  if (ListingUtils.usesPresetListingTitle(tid)) {
    return L10n.get(
      ListingUtils.presetListingTitleL10nKey(
        listingTypeId: tid,
        gender: d.gender,
      ),
    );
  }
  return d.title;
}

/// Resolves the human-readable title shown on a conversation tile / group
/// header.
///
/// Branches on `contextType` so the inbox renders the right thing for each
/// chat surface:
///   - `'gig_request'` → the request's title (or a localized fallback when
///     the server hasn't hydrated it yet, e.g. older builds).
///   - typed listings with a preset title → the preset hashtag string.
///   - everything else → the listing's title, or a `Listing #<id>` fallback
///     for legacy rows that somehow lost their title.
String resolvedConversationListingTitle(ConversationSummary c) {
  if (c.contextType == "gig_request") {
    return c.gigRequestTitle ?? L10n.get("gigs_request_detail_title");
  }
  final tid = c.listingTypeId;
  if (tid != null && ListingUtils.usesPresetListingTitle(tid)) {
    return L10n.get(
      ListingUtils.presetListingTitleL10nKey(
        listingTypeId: tid,
        gender: c.listingGender,
      ),
    );
  }
  return c.listingTitle ?? "Listing #${c.listingId}";
}
