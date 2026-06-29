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
    final borderRadius = BorderRadius.circular(18);
    return _MapListingTileSurface(
      borderRadius: borderRadius,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: onOpen,
            borderRadius: borderRadius,
            child: Padding(
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
                                  color:
                                      _MapListingTileStyle.titleColor(context),
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
                              color: _MapListingTileStyle.priceColor(context),
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
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: onClose,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.close,
                color: _MapListingTileStyle.titleColor(context),
              ),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapListingTileStyle {
  const _MapListingTileStyle._();

  static const Color _blueThemeSecondary = Color(0xFFB3C0CC);
  static const Color _accentGreen = Color(0xFF35C26B);
  static const Color _accentGreenLightTheme = Color(0xFF25884B);

  static Color titleColor(BuildContext context) {
    if (ThemeState().isBlueTheme) return AppColors.textLight;
    return AppColors.textDark87;
  }

  static Color metaColor(BuildContext context) {
    if (ThemeState().isBlueTheme) return _blueThemeSecondary;
    return Colors.black;
  }

  static Color priceColor(BuildContext context) {
    return ThemeState().isLightTheme ? _accentGreenLightTheme : _accentGreen;
  }
}

class _MapListingTileSurface extends StatelessWidget {
  const _MapListingTileSurface({
    required this.child,
    required this.borderRadius,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).colorScheme.surface;
    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
        color: bg,
        child: child,
      ),
    );
  }
}

class _PinGroupSummaryTooltip extends StatefulWidget {
  const _PinGroupSummaryTooltip({
    required this.pins,
    required this.onClose,
    required this.onOpenPin,
    required this.onAllListingsViewedInCarousel,
    super.key,
  });

  final List<ListingMapPin> pins;
  final VoidCallback onClose;
  final ValueChanged<ListingMapPin> onOpenPin;
  final ValueChanged<List<ListingMapPin>> onAllListingsViewedInCarousel;

  @override
  State<_PinGroupSummaryTooltip> createState() =>
      _PinGroupSummaryTooltipState();
}

class _PinGroupSummaryTooltipState extends State<_PinGroupSummaryTooltip> {
  late final PageController _pageController;
  late final List<GlobalKey> _pageKeys;
  final Set<int> _viewedPageIndices = {};
  final Map<int, double> _pageHeights = {};
  int _currentPage = 0;
  double _carouselHeight = _PinSummaryPhoto.size + 20;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageKeys = List.generate(widget.pins.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _recordPageViewed(0);
      _scheduleMeasurePage(0);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _recordPageViewed(int index) {
    if (index < 0 || index >= widget.pins.length) return;
    if (!_viewedPageIndices.add(index)) return;
    if (_viewedPageIndices.length == widget.pins.length) {
      widget.onAllListingsViewedInCarousel(widget.pins);
    }
  }

  void _onPageChanged(int index) {
    _recordPageViewed(index);
    setState(() {
      _currentPage = index;
      _carouselHeight = _pageHeights[index] ?? _carouselHeight;
    });
    _scheduleMeasurePage(index);
  }

  void _scheduleMeasurePage(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box =
          _pageKeys[index].currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final height = box.size.height;
      _pageHeights[index] = height;
      if (index == _currentPage && (_carouselHeight - height).abs() > 0.5) {
        setState(() => _carouselHeight = height);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final showPageIndicator = widget.pins.length > 1;
    return _MapListingTileSurface(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  child: SizedBox(
                    height: _carouselHeight,
                    width: double.infinity,
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: _onPageChanged,
                      itemCount: widget.pins.length,
                      itemBuilder: (context, index) {
                        final pin = widget.pins[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: KeyedSubtree(
                              key: _pageKeys[index],
                              child: _PinGroupListingCard(
                                pin: pin,
                                onTap: () => widget.onOpenPin(pin),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (showPageIndicator) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: widget.pins.length,
                      effect: WormEffect(
                        dotColor: _pinGroupCarouselDotColor(context),
                        activeDotColor: _pinGroupCarouselDotColor(context),
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 8,
                        paintStyle: PaintingStyle.stroke,
                        strokeWidth: 1.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: widget.onClose,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.close,
                color: _MapListingTileStyle.titleColor(context),
              ),
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            ),
          ),
        ],
      ),
    );
  }

  Color _pinGroupCarouselDotColor(BuildContext context) {
    if (ThemeState().isLightTheme) return Colors.black;
    if (ThemeState().isBlueTheme) return Colors.white;
    return AppColors.primary;
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
    final borderRadius = BorderRadius.circular(14);
    return _MapListingTileSurface(
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
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
                        color: _MapListingTileStyle.titleColor(context),
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
                          color: _MapListingTileStyle.priceColor(context),
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
              color: _MapListingTileStyle.metaColor(context),
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
              color: _MapListingTileStyle.metaColor(context),
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
                    color: UiPerformancePolicy.solidColorsPreferredForDevice
                        ? scheme.surfaceContainerHighest
                        : scheme.onSurface.withValues(alpha: 0.08),
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
