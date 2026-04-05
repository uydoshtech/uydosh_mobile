import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";

/// Same preset hashtag as create-listing when type/gender are present on the summary.
String resolvedConversationListingTitle(ConversationSummary c) {
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
