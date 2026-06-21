import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/deep_link_service.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/utils/group_housing_listing_fit.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

/// Plain-text payload for sharing a saved housing listing in the group chat.
abstract final class GroupShortlistDiscussMessage {
  static String build({
    required Listing listing,
    GroupHousingListingFit? fit,
  }) {
    final lines = <String>[listing.title.trim()];

    final location = _localizedLocationLabel(listing);
    if (location.isNotEmpty) {
      lines.add(
        L10n.getWithParams(
          "group_shortlist_discuss_line_location",
          params: {"location": location},
        ),
      );
    }

    final metro = _localizedMetroLabel(listing);
    if (metro.isNotEmpty) {
      lines.add(
        L10n.getWithParams(
          "group_shortlist_discuss_line_metro",
          params: {"station": metro},
        ),
      );
    }

    final perPerson = fit?.formatPerPersonPriceLabel();
    if (perPerson != null && perPerson.isNotEmpty) {
      lines.add(
        L10n.getWithParams(
          "group_shortlist_discuss_line_price_per_person",
          params: {"price": perPerson},
        ),
      );
    } else if (listing.price > 0) {
      lines.add(
        L10n.getWithParams(
          "group_shortlist_discuss_line_price",
          params: {
            "price": PriceRangeHelper.formatStoredListingPrice(
              storedPrice: listing.price,
              listingTypeCode:
                  listing.listingType?.code ?? ListingTypeCodes.roommateNeeded,
              minPrice: listing.minPrice,
              maxPrice: listing.maxPrice,
            ),
          },
        ),
      );
    }

    lines.add(
      L10n.getWithParams(
        "group_shortlist_discuss_line_link",
        params: {
          "link": DeepLinkService.buildListingDeepLink(listing.id),
        },
      ),
    );

    final body = lines.join("\n");
    final intro = L10n.get("group_shortlist_discuss_message_intro");
    if (intro.trim().isEmpty) return body;
    return "$intro\n\n$body";
  }

  static String _localizedLocationLabel(Listing listing) {
    final location = listing.location;
    if (location == null) return "";
    return _localizedName(
      nameUz: location.nameUz,
      nameRu: location.nameRu,
      nameEn: location.nameEn,
      shortNameUz: location.shortNameUz,
      shortNameRu: location.shortNameRu,
      shortNameEn: location.shortNameEn,
    );
  }

  static String _localizedMetroLabel(Listing listing) {
    final station = listing.subwayStation;
    if (station == null) return "";
    return _localizedName(
      nameUz: station.nameUz,
      nameRu: station.nameRu,
      nameEn: station.nameEn,
    );
  }

  static String _localizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
    String? shortNameUz,
    String? shortNameRu,
    String? shortNameEn,
  }) {
    switch (L10n.currentLanguage) {
      case "ru":
        return shortNameRu ?? nameRu ?? nameEn ?? nameUz ?? "";
      case "uz":
        return shortNameUz ?? nameUz ?? nameRu ?? nameEn ?? "";
      default:
        return shortNameEn ?? nameEn ?? nameRu ?? nameUz ?? "";
    }
  }
}
