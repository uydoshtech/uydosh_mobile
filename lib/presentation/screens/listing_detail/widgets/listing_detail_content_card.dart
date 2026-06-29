import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/amenity_icon_helper.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/domain/models/amenity.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_date_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_description_translation.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_geo_label_rows.dart";
import "package:uy_dosh/presentation/widgets/common/deferred_yandex_map.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

/// Main content card for listing detail (header, title, description, location, amenities, dates).
class ListingDetailContentCard extends StatefulWidget {
  const ListingDetailContentCard({
    required this.listingDetail,
    required this.currentLanguage,
    required this.getLocalizedName,
    this.onOpenInYandexMaps,
    this.formatMoveInDate,
    this.formattedMoveInDate,
    this.formattedPublicationDate,
    this.amenityChips,
    this.ownerName,
    this.ownerAvatarUrl,
    this.onAuthorTap,
    super.key,
  });

  final ListingDetail listingDetail;
  final String currentLanguage;
  final String? ownerName;
  final String? ownerAvatarUrl;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onOpenInYandexMaps;

  /// Pre-formatted move-in date (avoids DateTime.parse in build).
  final String? formattedMoveInDate;

  /// Pre-formatted publication date (avoids DateTime.parse in build).
  final String? formattedPublicationDate;

  /// Pre-built amenity chips (avoids .map().toList() in build).
  final List<Widget>? amenityChips;
  final String Function(BuildContext context, String moveInDate)?
  formatMoveInDate;
  final String Function({
    required String language,
    String? nameUz,
    String? nameRu,
    String? nameEn,
  })
  getLocalizedName;

  @override
  State<ListingDetailContentCard> createState() =>
      _ListingDetailContentCardState();
}

class _ListingDetailContentCardState extends State<ListingDetailContentCard> {
  static const List<String> _leadingAmenityCodes = <String>[
    "wifi",
    "air_conditioning",
  ];

  String _authorDisplayLabel() {
    final fromProfile = (widget.ownerName ?? "").trim();
    if (fromProfile.isNotEmpty) return fromProfile;
    final user = widget.listingDetail.user;
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    final phone = user.phone?.trim();
    if (phone != null && phone.isNotEmpty) return phone;
    return L10n.get("na");
  }

  Widget _buildAuthorAvatar() {
    const size = 24.0;
    final label = _authorDisplayLabel();
    final resolvedUrl = resolveAvatarUrl(widget.ownerAvatarUrl);
    final iconColor = ListingDetailThemeHelper.dateIconColor;

    Widget fallback() {
      final initials = StringUtils.extractInitials(label);
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Center(
          child: initials.isNotEmpty
              ? Text(
                  initials,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                )
              : ThemeIconFactory.detail(
                  icon: Icons.person_outline,
                  color: iconColor,
                  size: 16,
                ),
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: resolvedUrl != null
            ? NetworkAvatarImage(
                imageUrl: resolvedUrl,
                size: size,
                fallback: fallback(),
              )
            : fallback(),
      ),
    );
  }

  final GlobalKey _inlineLocationExpansionKey = GlobalKey();

  /// Drives [DeferredYandexMap.autoLoad]. Flipped on once the expand/scroll
  /// animation settles, and reset when the section collapses again.
  bool _mapAutoLoad = false;

  void _onMapExpansionChanged(bool isExpanded) {
    HapticFeedbackUtils.impact();
    if (!isExpanded) {
      // Collapsing removes the children (and disposes the map). Reset so the
      // next expand goes through the placeholder + settle delay again.
      if (_mapAutoLoad) setState(() => _mapAutoLoad = false);
      return;
    }

    // After [CustomScrollView] + sliver refactor, scrolling to
    // [ScrollPosition.maxScrollExtent] scrolled past this tile into sections
    // below and fought the expansion layout — use reveal for this tile only.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        // Expand/scroll animation has settled; mount the real map now so the
        // heavy native MapKit view doesn't jank the expansion.
        if (!_mapAutoLoad) setState(() => _mapAutoLoad = true);
        final ctx = _inlineLocationExpansionKey.currentContext;
        if (ctx == null || !ctx.mounted) return;
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      });
    });
  }

  String _getAmenityLocalizedName(Amenity amenity) {
    switch (widget.currentLanguage) {
      case "ru":
        return amenity.nameRu;
      case "uz":
        return amenity.nameUz;
      case "en":
      default:
        return amenity.nameEn;
    }
  }

  IconData _getAmenityIcon(Amenity amenity) {
    if (amenity.code != null && amenity.code!.isNotEmpty) {
      return AmenityIconHelper.getIcon(amenity.code!);
    }
    return Icons.home;
  }

  String _getPublicationDateText(BuildContext context) {
    if (widget.formattedPublicationDate != null) {
      return widget.formattedPublicationDate!;
    }
    final date = ListingDetailDateUtils.parseCreatedAt(
      widget.listingDetail.createdAt,
    );
    if (date != null) {
      return AppDateUtils.formatDateWithShortMonth(context, date);
    }
    return widget.listingDetail.createdAt;
  }

  void _showAmenityBubble(
    BuildContext context,
    Amenity amenity,
    Offset globalPosition,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    var removed = false;
    void removeOnce() {
      if (!removed) {
        removed = true;
        overlayEntry.remove();
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: removeOnce),
          Positioned(
            left: globalPosition.dx.clamp(
              12.0,
              MediaQuery.sizeOf(context).width - 150,
            ),
            top: globalPosition.dy - 48,
            child: GestureDetector(
              onTap: removeOnce,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ThemeState().isLightTheme
                        ? Colors.black
                        : (ThemeState().isBlueTheme
                              ? Colors.white
                              : Theme.of(context).colorScheme.inverseSurface),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getAmenityLocalizedName(amenity),
                    style: TextStyle(
                      fontSize: 14,
                      color: ThemeState().isLightTheme
                          ? Colors.white
                          : (ThemeState().isBlueTheme
                                ? Colors.black
                                : Theme.of(
                                    context,
                                  ).colorScheme.onInverseSurface),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), removeOnce);
  }

  Widget _buildAmenityChip(BuildContext context, Amenity amenity) {
    return GestureDetector(
      onTapDown: (details) =>
          _showAmenityBubble(context, amenity, details.globalPosition),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        decoration: BoxDecoration(
          color: ListingDetailThemeHelper.amenityChipBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ListingDetailThemeHelper.amenityChipBorderColor,
            width: 1,
          ),
        ),
        child: ThemeIconFactory.detail(
          icon: _getAmenityIcon(amenity),
          size: 18,
          color: ListingDetailThemeHelper.amenityIconColor,
        ),
      ),
    );
  }

  List<Amenity> _sortedAmenitiesForDetails(List<Amenity> amenities) {
    final indexedAmenities = amenities.asMap().entries.toList();

    int rank(Amenity amenity) {
      final code = amenity.code ?? "";
      final leadingIndex = _leadingAmenityCodes.indexOf(code);
      if (leadingIndex != -1) return leadingIndex;
      if (code == "pets") return _leadingAmenityCodes.length + 1;
      return _leadingAmenityCodes.length;
    }

    indexedAmenities.sort((a, b) {
      final rankCompare = rank(a.value).compareTo(rank(b.value));
      if (rankCompare != 0) return rankCompare;
      return a.key.compareTo(b.key);
    });

    return indexedAmenities.map((entry) => entry.value).toList();
  }

  Widget _buildSubwayStationDisplay(SubwayStationDetail station) {
    final transferInfo = MetroCache.getTransferStationInfo(station.id);

    if (transferInfo != null) {
      final connectedStation = SubwayStationDetail(
        id: transferInfo["connectedStationId"] as int,
        nameUz: transferInfo["connectedStationName"] as String,
        nameRu: transferInfo["connectedStationNameRu"] as String,
        nameEn: transferInfo["connectedStationNameEn"] as String,
        line: transferInfo["connectedStationLine"] as int,
      );

      return ListingMetroLabelRow(
        label: MetroCache.formatStationLabel(
          widget.getLocalizedName(
            nameUz: station.nameUz,
            nameRu: station.nameRu,
            nameEn: station.nameEn,
            language: widget.currentLanguage,
          ),
          widget.currentLanguage,
        ),
        lineColor: ListingDetailThemeHelper.lineColor(station.line),
        connectedLabel: MetroCache.formatStationLabel(
          widget.getLocalizedName(
            nameUz: connectedStation.nameUz,
            nameRu: connectedStation.nameRu,
            nameEn: connectedStation.nameEn,
            language: widget.currentLanguage,
          ),
          widget.currentLanguage,
        ),
        connectedLineColor: ListingDetailThemeHelper.lineColor(
          connectedStation.line,
        ),
      );
    }

    return ListingMetroLabelRow(
      label: MetroCache.formatStationLabel(
        widget.getLocalizedName(
          nameUz: station.nameUz,
          nameRu: station.nameRu,
          nameEn: station.nameEn,
          language: widget.currentLanguage,
        ),
        widget.currentLanguage,
      ),
      lineColor: ListingDetailThemeHelper.lineColor(station.line),
    );
  }

  List<SubwayStationDetail> _effectiveSearchStations() {
    final locations = widget.listingDetail.searchLocations;
    if (locations != null && locations.isNotEmpty) {
      return const <SubwayStationDetail>[];
    }
    final stations = widget.listingDetail.searchSubwayStations;
    if (stations != null && stations.isNotEmpty) return stations;
    final station = widget.listingDetail.subwayStation;
    return station == null ? const <SubwayStationDetail>[] : [station];
  }

  List<LocationDetail> _effectiveSearchLocations(
    List<SubwayStationDetail> stations,
  ) {
    final locations = widget.listingDetail.searchLocations;
    if (locations != null && locations.isNotEmpty) return locations;
    final stationLocations = _locationsForStations(stations);
    if (stationLocations.isNotEmpty) return stationLocations;
    final location = widget.listingDetail.location;
    return location == null ? const <LocationDetail>[] : [location];
  }

  List<LocationDetail> _locationsForStations(
    List<SubwayStationDetail> stations,
  ) {
    if (stations.isEmpty) return const <LocationDetail>[];
    final displayStations = MetroCache.dedupeTransferStationPairs(
      stations,
      (station) => station.id,
    );
    final locationIds = <int>{};
    final locations = <LocationDetail>[];
    for (final stationDetail in displayStations) {
      final locationId = MetroCache.getStationById(
        stationDetail.id,
      )?.locationId;
      if (locationId == null || !locationIds.add(locationId)) continue;
      final location = LocationCache.getLocationById(locationId);
      if (location == null) continue;
      locations.add(
        LocationDetail(
          id: location.id,
          nameUz: location.nameUz ?? location.shortNameUz ?? "",
          nameRu: location.nameRu ?? location.shortNameRu ?? "",
          nameEn: location.nameEn ?? location.shortNameEn ?? "",
          shortNameUz: location.shortNameUz ?? location.nameUz ?? "",
          shortNameRu: location.shortNameRu ?? location.nameRu ?? "",
          shortNameEn: location.shortNameEn ?? location.nameEn ?? "",
        ),
      );
    }
    return locations;
  }

  String _stationSummaryLabel(List<SubwayStationDetail> stations) {
    if (stations.length == 1) {
      return MetroCache.formatStationLabel(
        widget.getLocalizedName(
          nameUz: stations.first.nameUz,
          nameRu: stations.first.nameRu,
          nameEn: stations.first.nameEn,
          language: widget.currentLanguage,
        ),
        widget.currentLanguage,
      );
    }
    switch (widget.currentLanguage) {
      case "uz":
        return "${stations.length} bekat";
      case "en":
        return "${stations.length} stations";
      case "ru":
      default:
        return "${stations.length} станций";
    }
  }

  String _locationSummaryLabel(List<LocationDetail> locations) {
    if (locations.length == 1) {
      return widget.getLocalizedName(
        nameUz: locations.first.nameUz,
        nameRu: locations.first.nameRu,
        nameEn: locations.first.nameEn,
        language: widget.currentLanguage,
      );
    }
    return L10n.pluralForLanguage(
      "districts_count",
      locations.length,
      widget.currentLanguage,
    );
  }

  Widget _buildSubwayStationsSummary(List<SubwayStationDetail> stations) {
    final displayStations = MetroCache.dedupeTransferStationPairs(
      stations,
      (station) => station.id,
    );
    if (displayStations.length == 1) {
      return _buildSubwayStationDisplay(displayStations.first);
    }
    final lineIds = <int>[];
    for (final station in displayStations) {
      if (!lineIds.contains(station.line)) lineIds.add(station.line);
    }
    return Row(
      children: [
        for (var i = 0; i < lineIds.length; i++) ...[
          ThemeIcon(
            Icons.train,
            color: ListingDetailThemeHelper.lineColor(lineIds[i]),
            size: 20,
          ),
          SizedBox(width: i == lineIds.length - 1 ? 8 : 2),
        ],
        Expanded(
          child: Text(
            _stationSummaryLabel(displayStations),
            style: TextStyle(
              fontSize: 15,
              color: ListingDetailThemeHelper.locationTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationsSummary(List<LocationDetail> locations) {
    return ListingDistrictLabelRow(label: _locationSummaryLabel(locations));
  }

  Widget _buildExpandedGeoList({
    required List<SubwayStationDetail> stations,
    required List<LocationDetail> locations,
  }) {
    final displayStations = MetroCache.dedupeTransferStationPairs(
      stations,
      (station) => station.id,
    );
    final showStations = displayStations.length > 1;
    final showLocations = locations.length > 1;
    if (!showStations && !showLocations) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showStations)
          for (final station in displayStations) ...[
            _buildSubwayStationDisplay(station),
            const SizedBox(height: 8),
          ],
        if (showStations && showLocations)
          Divider(
            height: 16,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
          ),
        if (showLocations)
          for (final location in locations) ...[
            _buildLocationsSummary([location]),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  List<LocationDetail> _visibleInlineLocations(
    List<SubwayStationDetail> stations,
  ) {
    return _effectiveSearchLocations(stations);
  }

  bool _hasInlineLocationMapContent() {
    final stations = _effectiveSearchStations();
    final locations = _visibleInlineLocations(stations);

    return stations.isNotEmpty || locations.isNotEmpty;
  }

  Widget _buildInlineLocationMapSection() {
    final stations = _effectiveSearchStations();
    final locations = _visibleInlineLocations(stations);
    final displayStations = MetroCache.dedupeTransferStationPairs(
      stations,
      (station) => station.id,
    );
    final hasLocation = locations.isNotEmpty;
    final hasSubway = displayStations.isNotEmpty;
    final hasMap = hasLocation || hasSubway;
    final canShowInlineMap =
        displayStations.length <= 1 && locations.length <= 1;
    final canOpen = canShowInlineMap && widget.onOpenInYandexMaps != null;

    if (!hasMap) return const SizedBox.shrink();

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasSubway) _buildSubwayStationsSummary(displayStations),
        if (hasSubway && hasLocation) const SizedBox(height: 8),
        if (hasLocation) _buildLocationsSummary(locations),
      ],
    );

    return Container(
      key: _inlineLocationExpansionKey,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.35),
          ),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          initiallyExpanded: false,
          onExpansionChanged: canShowInlineMap
              ? _onMapExpansionChanged
              : (_) => HapticFeedbackUtils.impact(),
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 12),
          iconColor: ListingDetailThemeHelper.locationTextColor,
          collapsedIconColor: ListingDetailThemeHelper.locationTextColor,
          title: title,
          children: [
            _buildExpandedGeoList(stations: stations, locations: locations),
            if (canShowInlineMap)
              DeferredYandexMap(
                apiKey: AppConfig.yandexMapsApiKey,
                height: 250,
                listingDetail: widget.listingDetail,
                autoLoad: _mapAutoLoad,
                showBrandMark: false,
                showZoomControls: false,
              ),
            if (canOpen) ...[
              const SizedBox(height: 16),
              Center(
                child: UydoshLinkButton(
                  text: L10n.get("open_map_view"),
                  onPressed: () => widget.onOpenInYandexMaps?.call(),
                  color: ListingDetailThemeHelper.yandexButtonColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListingDetailTileShell(
      useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
      child: Padding(
        // Tighter top: reduces gap between image tile and title/description row only.
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.listingDetail.description == null ||
                widget.listingDetail.description!.isEmpty)
              Text(
                ListingUtils.usesPresetListingTitle(
                      widget.listingDetail.listingTypeId,
                    )
                    ? L10n.get(
                        ListingUtils.presetListingTitleL10nKey(
                          listingTypeId: widget.listingDetail.listingTypeId,
                          gender: widget.listingDetail.gender,
                        ),
                      )
                    : widget.listingDetail.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (widget.listingDetail.description != null &&
                widget.listingDetail.description!.isNotEmpty)
              ListingDescriptionTranslation(
                listingId: widget.listingDetail.id,
                listingTitle:
                    ListingUtils.usesPresetListingTitle(
                      widget.listingDetail.listingTypeId,
                    )
                    ? L10n.get(
                        ListingUtils.presetListingTitleL10nKey(
                          listingTypeId: widget.listingDetail.listingTypeId,
                          gender: widget.listingDetail.gender,
                        ),
                      )
                    : widget.listingDetail.title,
                listingTitleStyle: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                descriptionRu: widget.listingDetail.descriptionRu,
                descriptionEn: widget.listingDetail.descriptionEn,
                descriptionUz: widget.listingDetail.descriptionUz,
                originalText: widget.listingDetail.description!,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: ListingDetailThemeHelper.descriptionTextColor,
                ),
              ),
            if (widget.listingDetail.privateRoom == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ThemeIconFactory.detail(
                    icon: Icons.lock_outline,
                    color: ListingDetailThemeHelper.privateRoomIconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    L10n.get("private_room"),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ListingDetailThemeHelper.locationTextColor,
                    ),
                  ),
                ],
              ),
            ],
            if (widget.listingDetail.listingTypeId ==
                ListingTypeIds.roommateNeeded) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  ThemeIconFactory.detail(
                    icon: widget.listingDetail.hostResident == false
                        ? ListingTypeHelper.roommateAbsentHostIcon
                        : ListingTypeHelper.roommateResidentIcon,
                    color: ListingDetailThemeHelper.locationTextColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.listingDetail.hostResident == false
                        ? L10n.get("host_resident_no")
                        : L10n.get("host_resident"),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: ListingDetailThemeHelper.locationTextColor,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((widget.amenityChips != null &&
                        widget.amenityChips!.isNotEmpty) ||
                    (widget.listingDetail.amenities != null &&
                        widget.listingDetail.amenities!.isNotEmpty)) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.amenityChips ??
                        _sortedAmenitiesForDetails(
                              widget.listingDetail.amenities ?? <Amenity>[],
                            )
                            .map(
                              (amenity) => _buildAmenityChip(context, amenity),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
                if (widget.listingDetail.moveInDate != null &&
                    widget.listingDetail.moveInDate!.isNotEmpty) ...[
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Center(
                          child: ThemeIconFactory.detail(
                            icon: CupertinoIcons.square_arrow_right,
                            color: ListingDetailThemeHelper.dateIconColor,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: "${L10n.get("move_in_date_label")} ",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: ListingDetailThemeHelper.dateTextColor,
                                ),
                              ),
                              TextSpan(
                                text:
                                    widget.formattedMoveInDate ??
                                    (widget.formatMoveInDate != null
                                        ? widget.formatMoveInDate!(
                                            context,
                                            widget.listingDetail.moveInDate!,
                                          )
                                        : widget.listingDetail.moveInDate!),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: ListingDetailThemeHelper.dateTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    _buildAuthorAvatar(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "${L10n.get("author")}: ",
                            style: TextStyle(
                              fontSize: 15,
                              color: ListingDetailThemeHelper.dateTextColor,
                            ),
                          ),
                          if (widget.onAuthorTap != null)
                            UydoshLinkButton(
                              text: _authorDisplayLabel(),
                              onPressed: widget.onAuthorTap!,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: ListingDetailThemeHelper.dateTextColor,
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            )
                          else
                            Text(
                              _authorDisplayLabel(),
                              style: TextStyle(
                                fontSize: 15,
                                color: ListingDetailThemeHelper.dateTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: ThemeIconFactory.detail(
                          icon: Icons.schedule,
                          color: ListingDetailThemeHelper.dateIconColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${L10n.get("publication_date")} ${_getPublicationDateText(context)}",
                        style: TextStyle(
                          fontSize: 15,
                          color: ListingDetailThemeHelper.dateTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_hasInlineLocationMapContent()) ...[
              const SizedBox(height: 16),
              _buildInlineLocationMapSection(),
            ],
          ],
        ),
      ),
    );
  }
}
