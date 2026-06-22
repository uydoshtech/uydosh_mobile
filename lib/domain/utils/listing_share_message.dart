import "dart:convert";

import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/utils/group_housing_listing_fit.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

const listingShareMessagePrefix = "[[uydosh:listing_share]]";

class ListingShareMessagePayload {
  const ListingShareMessagePayload({
    required this.listingId,
    required this.title,
    this.intro,
    this.location,
    this.metro,
    this.metroLine,
    this.priceLabel,
    this.ownerUserId,
    this.ownerName,
    this.ownerAvatarUrl,
  });

  final int listingId;
  final String title;
  final String? intro;
  final String? location;
  final String? metro;
  final int? metroLine;
  final String? priceLabel;
  final int? ownerUserId;
  final String? ownerName;
  final String? ownerAvatarUrl;

  Map<String, dynamic> toJson() => {
        "v": 1,
        "listing_id": listingId,
        "intro": intro,
        "title": title,
        "location": location,
        "metro": metro,
        if (metroLine != null) "metro_line": metroLine,
        "price_label": priceLabel,
        if (ownerUserId != null) "owner_user_id": ownerUserId,
        if (ownerName != null && ownerName!.trim().isNotEmpty)
          "owner_name": ownerName!.trim(),
        if (ownerAvatarUrl != null && ownerAvatarUrl!.trim().isNotEmpty)
          "owner_avatar_url": ownerAvatarUrl!.trim(),
      };

  factory ListingShareMessagePayload.fromJson(Map<String, dynamic> json) {
    return ListingShareMessagePayload(
      listingId: (json["listing_id"] as num).toInt(),
      title: json["title"] as String? ?? "",
      intro: json["intro"] as String?,
      location: json["location"] as String?,
      metro: json["metro"] as String?,
      metroLine: (json["metro_line"] as num?)?.toInt(),
      priceLabel: json["price_label"] as String?,
      ownerUserId: (json["owner_user_id"] as num?)?.toInt(),
      ownerName: json["owner_name"] as String?,
      ownerAvatarUrl: json["owner_avatar_url"] as String?,
    );
  }
}

abstract final class ListingShareMessageCodec {
  static bool isListingShareContent(String content) {
    if (content.startsWith(listingShareMessagePrefix)) return true;
    return RegExp(r"/listing/\d+", caseSensitive: false).hasMatch(content);
  }

  static ListingShareMessagePayload? parse(String content) {
    if (content.startsWith(listingShareMessagePrefix)) {
      try {
        final decoded = jsonDecode(
          content.substring(listingShareMessagePrefix.length).trim(),
        );
        if (decoded is! Map) return null;
        final payload = ListingShareMessagePayload.fromJson(
          Map<String, dynamic>.from(decoded),
        );
        if (payload.listingId <= 0 || payload.title.trim().isEmpty) {
          return null;
        }
        return payload;
      } catch (_) {
        return null;
      }
    }

    final linkMatch =
        RegExp(r"/listing/(\d+)", caseSensitive: false).firstMatch(content);
    if (linkMatch == null) return null;
    final listingId = int.tryParse(linkMatch.group(1)!);
    if (listingId == null || listingId <= 0) return null;

    final lines = content
        .split("\n")
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String? intro;
    String? title;
    String? location;
    String? metro;
    String? priceLabel;

    for (final line in lines) {
      if (line.startsWith("🔗") || line.contains("http")) continue;
      if (line.startsWith("📍")) {
        location = line.replaceFirst(RegExp(r"^📍\s*"), "").trim();
        continue;
      }
      if (line.startsWith("🚇")) {
        metro = line.replaceFirst(RegExp(r"^🚇\s*"), "").trim();
        continue;
      }
      if (line.startsWith("💰")) {
        priceLabel = line.replaceFirst(RegExp(r"^💰\s*"), "").trim();
        continue;
      }
      if (title == null && intro == null) {
        intro = line;
        continue;
      }
      title ??= line;
    }

    title ??= intro;
    intro = title == intro ? null : intro;
    if (title == null || title.trim().isEmpty) return null;

    return ListingShareMessagePayload(
      listingId: listingId,
      title: title.trim(),
      intro: intro?.trim(),
      location: location?.trim().isEmpty == true ? null : location?.trim(),
      metro: metro?.trim().isEmpty == true ? null : metro?.trim(),
      priceLabel:
          priceLabel?.trim().isEmpty == true ? null : priceLabel?.trim(),
    );
  }

  static String encode(ListingShareMessagePayload payload) {
    return "$listingShareMessagePrefix${jsonEncode(payload.toJson())}";
  }

  /// Human-readable one-line preview for an inbox / notification snippet.
  ///
  /// Listing-share messages are stored as an encoded payload
  /// ([listingShareMessagePrefix] + JSON); printing that raw string leaks
  /// braces and quotes into the conversation list. When [content] decodes to a
  /// share payload we render a localized "shared a listing" line with the
  /// listing title; otherwise the original content is returned untouched.
  static String previewText(String content) {
    if (!isListingShareContent(content)) return content;
    final payload = parse(content);
    if (payload == null) return content;
    final title = payload.title.trim();
    if (title.isEmpty) {
      return L10n.get("messages_preview_shared_listing_no_title");
    }
    return L10n.getWithParams(
      "messages_preview_shared_listing",
      params: {"title": title},
    );
  }
}

abstract final class GroupShortlistDiscussMessage {
  static String buildContent({
    required Listing listing,
    GroupHousingListingFit? fit,
    String? ownerName,
    String? ownerAvatarUrl,
  }) {
    final intro = L10n.get("group_shortlist_discuss_message_intro").trim();

    return ListingShareMessageCodec.encode(
      ListingShareMessagePayload(
        listingId: listing.id,
        title: listing.title.trim(),
        intro: intro.isEmpty ? null : intro,
        location: _localizedLocationLabel(listing).isEmpty
            ? null
            : _localizedLocationLabel(listing),
        metro: _localizedMetroLabel(listing).isEmpty
            ? null
            : _localizedMetroLabel(listing),
        metroLine: listing.subwayStation?.line ?? listing.subwayLineId,
        priceLabel: _priceLabel(listing),
        ownerUserId: listing.userId,
        ownerName: ownerName,
        ownerAvatarUrl: ownerAvatarUrl,
      ),
    );
  }

  /// Legacy plain-text builder kept for tests / fallbacks.
  static String buildPlainText({
    required Listing listing,
    GroupHousingListingFit? fit,
  }) {
    final payload = ListingShareMessageCodec.parse(
      buildContent(listing: listing, fit: fit),
    );
    if (payload == null) return listing.title;
    final lines = <String>[
      if (payload.intro != null && payload.intro!.isNotEmpty) payload.intro!,
      payload.title,
      if (payload.location != null)
        L10n.getWithParams(
          "group_shortlist_discuss_line_location",
          params: {"location": payload.location!},
        ),
      if (payload.metro != null)
        L10n.getWithParams(
          "group_shortlist_discuss_line_metro",
          params: {"station": payload.metro!},
        ),
    ];
    return lines.join("\n");
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

  static String _priceLabel(Listing listing) {
    final listingTypeCode = listing.listingType?.code ?? "";
    final amount = PriceRangeHelper.formatStoredListingPrice(
      storedPrice: listing.price,
      listingTypeCode: listingTypeCode,
      minPrice: listing.minPrice,
      maxPrice: listing.maxPrice,
    );
    final currency = PriceDisplaySettingsState().currency;
    final monthlyUnit = L10n.get(
      currency == PriceDisplayCurrency.usd
          ? "price_unit_usd_per_month"
          : "price_unit_uzs_per_month",
    );
    final currencyMarker = monthlyUnit.split("/").first.trim();
    if (currencyMarker.isEmpty) return amount;
    if (currency == PriceDisplayCurrency.usd) return "$currencyMarker$amount";
    return "$amount $currencyMarker";
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
