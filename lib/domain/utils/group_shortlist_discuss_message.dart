import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/utils/group_housing_listing_fit.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

class GroupShortlistDiscussPayload {
  const GroupShortlistDiscussPayload({
    required this.displayText,
    this.listingId,
  });

  final String displayText;
  final int? listingId;

  bool get hasListingFooter => listingId != null;
}

/// Plain-text payload for sharing a saved housing listing in the group chat.
abstract final class GroupShortlistDiscussMessage {
  static final RegExp _markerPattern = RegExp(
    r"\[\[uydosh:listing:(\d+)\]\]\s*$",
  );
  static final RegExp _listingUrlPattern = RegExp(
    r"https?://[^\s]*/listing/(\d+)",
  );
  static final RegExp _linkLinePattern = RegExp(
    r"^\s*🔗\s*.+\s*$",
    multiLine: true,
  );

  static String listingMarker(int listingId) => "[[uydosh:listing:$listingId]]";

  static GroupShortlistDiscussPayload parse(String content) {
    var text = content.trimRight();
    int? listingId;

    final markerMatch = _markerPattern.firstMatch(text);
    if (markerMatch != null) {
      listingId = int.tryParse(markerMatch.group(1)!);
      text = text.substring(0, markerMatch.start).trimRight();
    }

    if (listingId == null) {
      final urlMatch = _listingUrlPattern.firstMatch(text);
      listingId = urlMatch != null ? int.tryParse(urlMatch.group(1)!) : null;
    }

    text = text.replaceAll(_linkLinePattern, "").trimRight();
    text = text.replaceAll(RegExp(r"\n{3,}"), "\n\n");

    return GroupShortlistDiscussPayload(
      displayText: text,
      listingId: listingId,
    );
  }

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

    final body = lines.join("\n");
    final intro = L10n.get("group_shortlist_discuss_message_intro");
    final messageBody =
        intro.trim().isEmpty ? body : "$intro\n\n$body";
    return "$messageBody\n${listingMarker(listing.id)}";
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
