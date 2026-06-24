import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

/// Shared widgets for displaying conversation/listing info in the messages inbox.
/// Used by ConversationTile, OutgoingConversationTile, and GroupedConversationsList.

/// Whether the grouped/header budget row should show (numeric listing price or gig open budget).
bool conversationSummaryShowsBudgetBadge(ConversationSummary conversation) {
  final numeric =
      conversation.listingPrice != null && conversation.listingPrice! > 0;
  final gigOpen = conversation.contextType == 'gig_request' &&
      conversation.gigBudgetType == 'open';
  return numeric || gigOpen;
}

/// Row for gig grouped inbox headers: author / provider avatar + name.
class ConversationGigOwnerRow extends StatelessWidget {
  const ConversationGigOwnerRow({
    required this.conversation,
    required this.textColor,
    required this.mutedColor,
    required this.avatarColor,
    required this.avatarIconColor,
    super.key,
  });

  final ConversationSummary conversation;
  final Color textColor;
  final Color mutedColor;
  final Color avatarColor;
  final Color avatarIconColor;

  static const double _avatarSize = 28;

  @override
  Widget build(BuildContext context) {
    final name = conversation.gigOwnerName?.trim();
    if (name == null || name.isEmpty) return const SizedBox.shrink();

    final url = resolveAvatarUrl(conversation.gigOwnerAvatar);

    Widget fallbackAvatar() {
      final initials = StringUtils.extractInitials(name);
      return CircleAvatar(
        radius: _avatarSize / 2,
        backgroundColor: avatarColor,
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: avatarIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            : ThemeIcon(Icons.person, color: avatarIconColor, size: 16),
      );
    }

    final avatar = url != null
        ? ClipOval(
            child: NetworkAvatarImage(
              imageUrl: url,
              size: _avatarSize,
              fallback: fallbackAvatar(),
            ),
          )
        : fallbackAvatar();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        avatar,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10n.get("author"),
                style: TextStyle(
                  fontSize: 11,
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConversationAvatarContent extends StatelessWidget {
  const ConversationAvatarContent({
    required this.conversation,
    required this.iconColor,
    super.key,
    this.userNameOverride,
  });

  final ConversationSummary conversation;
  final Color iconColor;

  /// When provided, used in place of [ConversationSummary.otherUserName] to
  /// derive initials. Used to show the current user's initials when the last
  /// message in the conversation was sent by them.
  final String? userNameOverride;

  @override
  Widget build(BuildContext context) {
    final userName = userNameOverride ?? conversation.otherUserName;
    final initials = StringUtils.extractInitials(userName);

    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    return ThemeIcon(Icons.person, color: iconColor);
  }
}

/// Location and metro station info, optionally with price.
class ConversationLocationInfo extends StatelessWidget {
  const ConversationLocationInfo({
    required this.conversation,
    required this.textColor,
    this.showPrice = true,
    super.key,
  });

  final ConversationSummary conversation;
  final Color textColor;
  final bool showPrice;

  static String _getLocalizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) {
    final currentLanguage = LanguageState().currentLanguage;
    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
    }
  }

  List<SubwayStationDetail> _effectiveSearchStations() {
    final stations = conversation.searchSubwayStations;
    if (stations != null && stations.isNotEmpty) return stations;

    final hasStationName = conversation.subwayStationNameUz != null ||
        conversation.subwayStationNameRu != null ||
        conversation.subwayStationNameEn != null;
    if (!hasStationName) return const <SubwayStationDetail>[];

    return [
      SubwayStationDetail(
        id: conversation.listingSubwayStationId ?? 0,
        line: conversation.subwayStationLine ??
            conversation.listingSubwayLineId ??
            1,
        nameUz: conversation.subwayStationNameUz,
        nameRu: conversation.subwayStationNameRu,
        nameEn: conversation.subwayStationNameEn,
      ),
    ];
  }

  List<LocationDetail> _effectiveSearchLocations() {
    final locations = conversation.searchLocations;
    if (locations != null && locations.isNotEmpty) return locations;

    final hasLocationName = conversation.locationNameUz != null ||
        conversation.locationNameRu != null ||
        conversation.locationNameEn != null;
    if (!hasLocationName) return const <LocationDetail>[];

    return [
      LocationDetail(
        id: conversation.listingLocationId ?? 0,
        nameUz: conversation.locationNameUz,
        nameRu: conversation.locationNameRu,
        nameEn: conversation.locationNameEn,
        shortNameUz: conversation.locationShortNameUz,
        shortNameRu: conversation.locationShortNameRu,
        shortNameEn: conversation.locationShortNameEn,
      ),
    ];
  }

  String _stationSummaryLabel(List<SubwayStationDetail> stations) {
    if (stations.length == 1) {
      return MetroCache.formatStationLabel(
        _getLocalizedName(
          nameUz: stations.first.nameUz,
          nameRu: stations.first.nameRu,
          nameEn: stations.first.nameEn,
        ),
        LanguageState().currentLanguage,
      );
    }
    return L10n.plural("stations_count", stations.length);
  }

  String _locationSummaryLabel(List<LocationDetail> locations) {
    if (locations.length == 1) {
      return _getLocalizedName(
        nameUz: locations.first.nameUz,
        nameRu: locations.first.nameRu,
        nameEn: locations.first.nameEn,
      );
    }
    return L10n.plural("districts_count", locations.length);
  }

  List<int> _stationLineIds(List<SubwayStationDetail> stations) {
    final lineIds = <int>[];
    for (final station in stations) {
      if (!lineIds.contains(station.line)) lineIds.add(station.line);
    }
    return lineIds;
  }

  Widget _buildCompactStationRow(
    List<SubwayStationDetail> stations,
    TextStyle textStyle,
  ) {
    final lineIds = _stationLineIds(stations);
    return Row(
      children: [
        for (var i = 0; i < lineIds.length; i++) ...[
          ThemeIcon(
            Icons.train,
            color: ConversationSubwayStationDisplay._getLineColor(
              lineIds[i],
            ),
            size: 16,
          ),
          SizedBox(width: i == lineIds.length - 1 ? 4 : 2),
        ],
        Expanded(
          child: Text(
            _stationSummaryLabel(stations),
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLocationRow(
    List<LocationDetail> locations,
    TextStyle textStyle,
  ) {
    return Row(
      children: [
        const ThemeIcon(
          Icons.location_on,
          color: AppColors.error,
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _locationSummaryLabel(locations),
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactGeoRows({
    required List<SubwayStationDetail> stations,
    required List<LocationDetail> locations,
  }) {
    final hasStations = stations.isNotEmpty;
    final hasLocations = locations.isNotEmpty;

    if (!hasStations && !hasLocations) return const SizedBox.shrink();

    final textStyle = TextStyle(fontSize: 12, color: textColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasStations) _buildCompactStationRow(stations, textStyle),
        if (hasStations && hasLocations) const SizedBox(height: 4),
        if (hasLocations) _buildCompactLocationRow(locations, textStyle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        final searchStations = _effectiveSearchStations();
        final searchLocations = _effectiveSearchLocations();
        final hasLocation = searchLocations.isNotEmpty;
        final hasSubwayStation = searchStations.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasLocation || hasSubwayStation)
              _buildCompactGeoRows(
                stations: searchStations,
                locations: searchLocations,
              ),
            if (showPrice &&
                conversation.listingPrice != null &&
                conversation.listingPrice! > 0) ...[
              const SizedBox(height: 4),
              ConversationPriceDisplay(
                conversation: conversation,
                textColor: textColor,
              ),
            ] else if (showPrice &&
                conversation.contextType == 'gig_request' &&
                conversation.gigBudgetType == 'open') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const ThemeIcon(Icons.payments,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      L10n.get("gigs_request_budget_open"),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Subway station display with line color.
class ConversationSubwayStationDisplay extends StatelessWidget {
  const ConversationSubwayStationDisplay({
    required this.conversation,
    required this.textColor,
    super.key,
  });

  final ConversationSummary conversation;
  final Color textColor;

  static String _getLocalizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) {
    final currentLanguage = LanguageState().currentLanguage;
    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
    }
  }

  static Color _getLineColor(int line) {
    switch (line) {
      case 1:
        return AppColors.metroLine1;
      case 2:
        return AppColors.metroLine2;
      case 3:
        return AppColors.metroLine3;
      case 4:
        return AppColors.metroLine4;
      default:
        return AppColors.metroLine1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ThemeIcon(
          Icons.train,
          color: _getLineColor(conversation.subwayStationLine ?? 1),
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            MetroCache.formatStationLabel(
              _getLocalizedName(
                nameUz: conversation.subwayStationNameUz,
                nameRu: conversation.subwayStationNameRu,
                nameEn: conversation.subwayStationNameEn,
              ),
              LanguageState().currentLanguage,
            ),
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ),
      ],
    );
  }
}

/// Price range display.
class ConversationPriceDisplay extends StatelessWidget {
  const ConversationPriceDisplay({
    required this.conversation,
    required this.textColor,
    super.key,
  });

  final ConversationSummary conversation;
  final Color textColor;

  static String _formatPriceRange(ConversationSummary conversation) {
    final price = conversation.listingPrice;
    if (price != null && price > 0) {
      final cc = conversation.priceCurrencyCode?.trim();
      if (cc != null && cc.isNotEmpty) {
        final formatted = CurrencyDisplayUtils.formatDisplayAmount(price, cc);
        return "$formatted $cc";
      }
      final listingTypeCode = conversation.listingTypeId != null
          ? ListingTypeHelper.getCodeFromId(conversation.listingTypeId!)
          : ListingTypeCodes.roommateNeeded;
      return PriceRangeHelper.formatStoredListingPrice(
        storedPrice: price,
        listingTypeCode: listingTypeCode,
      );
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        return Row(
          children: [
            const ThemeIcon(Icons.payments, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _formatPriceRange(conversation),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
