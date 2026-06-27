part of "../search_results_map_screen.dart";

class _PinSummaryTooltip extends StatelessWidget {
  const _PinSummaryTooltip({
    required this.pin,
    required this.onClose,
    required this.onOpen,
    super.key,
  });

  final ListingMapPin pin;
  final VoidCallback onClose;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 52, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PinSummaryMediaColumn(
                      pin: pin,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (pin.listingTypeCode?.isNotEmpty == true ||
                                  pin.gender != null) ...[
                                _PinSummaryBadges(
                                  listingTypeCode: pin.listingTypeCode,
                                  gender: pin.gender,
                                  compact: true,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  pin.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (pin.subtitle?.isNotEmpty == true) ...[
                            const SizedBox(height: 4),
                            Text(
                              pin.subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                          if (pin.locationLabel?.isNotEmpty == true ||
                              pin.stationLabel?.isNotEmpty == true) ...[
                            const SizedBox(height: 6),
                            _PinGeoLabelsRow(
                              locationLabel: pin.locationLabel,
                              stationLabel: pin.stationLabel,
                              lineIds: pin.subwayLineIds,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinGroupSummaryTooltip extends StatelessWidget {
  const _PinGroupSummaryTooltip({
    required this.pins,
    required this.onClose,
    required this.onOpenPin,
    super.key,
  });

  final List<ListingMapPin> pins;
  final VoidCallback onClose;
  final ValueChanged<ListingMapPin> onOpenPin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final placeLabel = _placeLabel;
    final placeStationLineIds = _placeStationLineIds;
    final countLabel = L10n.plural("listings_count", pins.length);
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 44),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PinGroupPlaceTitle(
                          label: placeLabel ?? countLabel,
                          stationLineIds: placeStationLineIds,
                        ),
                        if (placeLabel != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            countLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 148,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: pins.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final pin = pins[index];
                        return _PinGroupListingCard(
                          pin: pin,
                          onTap: () => onOpenPin(pin),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close),
                visualDensity: VisualDensity.compact,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? get _placeLabel {
    for (final pin in pins) {
      final stationLabel = pin.stationLabel;
      if (stationLabel != null && stationLabel.isNotEmpty) {
        return stationLabel;
      }
    }
    for (final pin in pins) {
      final locationLabel = pin.locationLabel;
      if (locationLabel != null && locationLabel.isNotEmpty) {
        return locationLabel;
      }
    }
    return null;
  }

  List<int> get _placeStationLineIds {
    for (final pin in pins) {
      final stationLabel = pin.stationLabel;
      if (stationLabel != null && stationLabel.isNotEmpty) {
        return pin.subwayLineIds;
      }
    }
    return const [];
  }
}

class _PinGroupPlaceTitle extends StatelessWidget {
  const _PinGroupPlaceTitle({
    required this.label,
    required this.stationLineIds,
  });

  final String label;
  final List<int> stationLineIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w900,
    );

    if (stationLineIds.isEmpty) {
      return Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return Row(
      children: [
        for (var i = 0; i < stationLineIds.length; i++) ...[
          ThemeIcon(
            Icons.train,
            color: AppColors.getMetroLineColor(stationLineIds[i]),
            size: 20,
            useThemeColor: false,
          ),
          SizedBox(width: i == stationLineIds.length - 1 ? 6 : 2),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}

class _PinGroupListingCard extends StatelessWidget {
  const _PinGroupListingCard({
    required this.pin,
    required this.onTap,
  });

  final ListingMapPin pin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 286,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.56),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PinSummaryPhoto(
                  photoUrl: pin.photoUrl,
                  listingTypeId: pin.listingTypeId,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pin.listingTypeCode?.isNotEmpty == true ||
                          pin.gender != null) ...[
                        _PinSummaryBadges(
                          listingTypeCode: pin.listingTypeCode,
                          gender: pin.gender,
                          compact: true,
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        pin.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (pin.subtitle?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(
                          pin.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      if (pin.stationLabel?.isNotEmpty == true) ...[
                        const SizedBox(height: 6),
                        _PinMetroRow(
                          lineIds: pin.subwayLineIds,
                          label: pin.stationLabel!,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinSummaryMediaColumn extends StatelessWidget {
  const _PinSummaryMediaColumn({required this.pin});

  final ListingMapPin pin;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _PinSummaryPhoto.size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PinSummaryPhoto(
            photoUrl: pin.photoUrl,
            listingTypeId: pin.listingTypeId,
          ),
        ],
      ),
    );
  }
}

class _PinSummaryBadges extends StatelessWidget {
  const _PinSummaryBadges({
    required this.listingTypeCode,
    required this.gender,
    this.compact = false,
  });

  final String? listingTypeCode;
  final int? gender;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (listingTypeCode?.isNotEmpty == true)
          ListingTypeIconBadge(
            listingTypeCode: listingTypeCode!,
            size: compact ? 13 : 14,
            padding: compact
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          ),
        if (gender != null)
          GenderBadge(
            gender: gender!,
            size: compact ? 13 : 14,
            padding: compact
                ? const EdgeInsets.all(4)
                : const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          ),
      ],
    );
  }
}

class _PinGeoLabelsRow extends StatelessWidget {
  const _PinGeoLabelsRow({
    required this.locationLabel,
    required this.stationLabel,
    required this.lineIds,
  });

  final String? locationLabel;
  final String? stationLabel;
  final List<int> lineIds;

  @override
  Widget build(BuildContext context) {
    final hasLocation = locationLabel?.isNotEmpty == true;
    final hasStation = stationLabel?.isNotEmpty == true;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasLocation)
          _PinMetaRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: locationLabel!,
          ),
        if (hasLocation && hasStation) const SizedBox(height: 4),
        if (hasStation)
          _PinMetroRow(
            lineIds: lineIds,
            label: stationLabel!,
          ),
      ],
    );
  }
}

class _PinMetaRow extends StatelessWidget {
  const _PinMetaRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = ThemeState().isLightTheme
        ? Colors.black
        : theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        ThemeIcon(icon, color: iconColor, size: 18, useThemeColor: false),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PinMetroRow extends StatelessWidget {
  const _PinMetroRow({required this.lineIds, required this.label});

  final List<int> lineIds;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = ThemeState().isLightTheme
        ? Colors.black
        : theme.colorScheme.onSurfaceVariant;
    final visibleLineIds = lineIds.isEmpty ? const [1] : lineIds;
    return Row(
      children: [
        for (var i = 0; i < visibleLineIds.length; i++) ...[
          ThemeIcon(
            Icons.train,
            color: _lineColor(visibleLineIds[i]),
            size: 18,
            useThemeColor: false,
          ),
          SizedBox(width: i == visibleLineIds.length - 1 ? 6 : 2),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Color _lineColor(int line) {
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
}

class _PinSummaryPhoto extends StatelessWidget {
  const _PinSummaryPhoto({
    required this.photoUrl,
    required this.listingTypeId,
  });

  static const String _noPhotoPlaceholderAsset =
      "assets/images/uydosh_no_photo_placeholder.png";
  static const String _noPhotoPlaceholderAssetLight =
      "assets/images/uydosh_light_no_photo_placeholder.png";
  static const String _roomNeededPlaceholderAsset =
      "assets/images/uydosh_room_needed_no_photo_placeholder.png";
  static const String _roomNeededPlaceholderAssetLight =
      "assets/images/uydosh_light_room_needed_no_photo_placeholder.png";
  static const double size = 104.0;

  final String? photoUrl;
  final int? listingTypeId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = photoUrl;
    final placeholder = _placeholder(context, scheme);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: url == null || url.isEmpty
            ? placeholder
            : Image(
                image: CachedNetworkImageProvider(url),
                width: size,
                height: size,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return ColoredBox(
                    color: scheme.onSurface.withValues(alpha: 0.08),
                  );
                },
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, ColorScheme scheme) {
    final isLight = ThemeState().isLightTheme;
    final isRoomNeeded = listingTypeId == ListingTypeIds.roomNeeded;
    final asset = isRoomNeeded
        ? (isLight
            ? _roomNeededPlaceholderAssetLight
            : _roomNeededPlaceholderAsset)
        : (isLight ? _noPhotoPlaceholderAssetLight : _noPhotoPlaceholderAsset);
    final gradient = isLight
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB1BFD5), Color(0xFFAABBD3)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3962), Color(0xFF112548)],
          );
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: ThemeIcon(
            Icons.photo_outlined,
            color: scheme.onSurfaceVariant,
            size: 24,
            useThemeColor: false,
          ),
        ),
      ),
    );
  }
}
