part of "../search_results_map_screen.dart";

/// Swipeable carousel through every listing pin currently visible on the map
/// (its viewport), starting on [selectedListingId]. Dragging between pages
/// updates the map's selected/highlighted marker via [onPageChanged], while
/// [onClose] hides the whole carousel and [onOpen] opens listing detail.
class _PinSummaryCarousel extends StatefulWidget {
  const _PinSummaryCarousel({
    required this.pins,
    required this.selectedListingId,
    required this.onPageChanged,
    required this.onClose,
    required this.onOpen,
    required this.onHeightChanged,
    super.key,
  });

  final List<ListingMapPin> pins;
  final int? selectedListingId;
  final ValueChanged<ListingMapPin> onPageChanged;
  final VoidCallback onClose;
  final ValueChanged<ListingMapPin> onOpen;
  final ValueChanged<double> onHeightChanged;

  @override
  State<_PinSummaryCarousel> createState() => _PinSummaryCarouselState();
}

class _PinSummaryCarouselState extends State<_PinSummaryCarousel> {
  static const double _estimatedInitialHeight =
      _SearchMapLayoutMetrics.singlePinTooltipFallbackHeight;

  late final PageController _controller;
  late int _currentIndex;
  late List<double> _heights;

  /// Guards against feeding a programmatic [PageController.jumpToPage] (used
  /// to follow external selection, e.g. tapping a different marker) back
  /// into [widget.onPageChanged] as if the user had swiped.
  bool _suppressPageCallback = false;

  int _indexForListing(int? listingId) {
    if (listingId == null || widget.pins.isEmpty) return 0;
    final index = widget.pins.indexWhere((pin) => pin.listingId == listingId);
    return index < 0 ? 0 : index;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = _indexForListing(widget.selectedListingId);
    _controller = PageController(initialPage: _currentIndex);
    _heights = List<double>.filled(widget.pins.length, _estimatedInitialHeight);
  }

  @override
  void didUpdateWidget(covariant _PinSummaryCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_pinIdsEqual(oldWidget.pins, widget.pins)) {
      final nextHeights = List<double>.filled(
        widget.pins.length,
        _estimatedInitialHeight,
      );
      for (var i = 0; i < widget.pins.length; i++) {
        final oldIndex = oldWidget.pins.indexWhere(
          (pin) => pin.listingId == widget.pins[i].listingId,
        );
        if (oldIndex >= 0 && oldIndex < _heights.length) {
          nextHeights[i] = _heights[oldIndex];
        }
      }
      _heights = nextHeights;
    }

    final targetIndex = _indexForListing(widget.selectedListingId);
    if (targetIndex == _currentIndex || widget.pins.isEmpty) return;
    _currentIndex = targetIndex;
    if (!_controller.hasClients) return;
    _suppressPageCallback = true;
    _controller.jumpToPage(targetIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _suppressPageCallback = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _pinIdsEqual(List<ListingMapPin> a, List<ListingMapPin> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].listingId != b[i].listingId) return false;
    }
    return true;
  }

  void _setHeight(int index, double height) {
    if (index < 0 || index >= _heights.length) return;
    if ((_heights[index] - height).abs() < 0.5) return;
    setState(() => _heights[index] = height);
  }

  double get _currentHeight {
    if (_heights.isEmpty) return _estimatedInitialHeight;
    final index = _currentIndex.clamp(0, _heights.length - 1);
    return _heights[index];
  }

  void _handlePageChanged(int index) {
    setState(() => _currentIndex = index);
    if (_suppressPageCallback) return;
    if (index < 0 || index >= widget.pins.length) return;
    widget.onPageChanged(widget.pins[index]);
  }

  @override
  Widget build(BuildContext context) {
    final pins = widget.pins;
    if (pins.isEmpty) return const SizedBox.shrink();
    final currentIndex = _currentIndex.clamp(0, pins.length - 1);

    return _MapListingTooltipHeightReporter(
      onHeightChanged: widget.onHeightChanged,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: _currentHeight,
            child: PageView.builder(
              controller: _controller,
              itemCount: pins.length,
              onPageChanged: _handlePageChanged,
              itemBuilder: (context, index) {
                final pin = pins[index];
                return _PinCarouselPageMeasurer(
                  onSizeChanged: (size) => _setHeight(index, size.height),
                  child: _PinSummaryTooltip(
                    key: ValueKey("pin-${pin.listingId}"),
                    pin: pin,
                    onClose: widget.onClose,
                    onOpen: () => widget.onOpen(pin),
                  ),
                );
              },
            ),
          ),
          if (pins.length > 1)
            Positioned(
              // Matches the close button's 40×40 tap target (top: 0, right:
              // 0, 8px padding + 24px icon) so the pill's vertical center
              // lines up with the X regardless of the pill's own height.
              top: 0,
              right: 44,
              height: _closeButtonTapTargetSize,
              child: IgnorePointer(
                child: Center(
                  child: _PinCarouselCounterBadge(
                    index: currentIndex,
                    count: pins.length,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Reports its child's laid-out size to [onSizeChanged] after each layout
/// pass, letting [_PinSummaryCarouselState] size each carousel page's
/// container to the currently displayed card without an inner scroll.
class _PinCarouselPageMeasurer extends SingleChildRenderObjectWidget {
  const _PinCarouselPageMeasurer({
    required this.onSizeChanged,
    required super.child,
  });

  final ValueChanged<Size> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _PinCarouselPageMeasurerRenderObject(onSizeChanged);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _PinCarouselPageMeasurerRenderObject renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _PinCarouselPageMeasurerRenderObject extends RenderProxyBox {
  _PinCarouselPageMeasurerRenderObject(this.onSizeChanged);

  ValueChanged<Size> onSizeChanged;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSizeChanged(newSize);
    });
  }
}

/// Matches the close button's [IconButton] tap target (8px padding + 24px
/// icon) in [_PinSummaryTooltip], used to vertically center the counter
/// pill against it.
const double _closeButtonTapTargetSize = 40;

class _PinCarouselCounterBadge extends StatelessWidget {
  const _PinCarouselCounterBadge({required this.index, required this.count});

  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassPlate(
      // Always the dark frosted variant: this pill sits over the tooltip's
      // photo/text content (not the map tiles), so it needs guaranteed
      // contrast for its white text regardless of the app theme or the
      // map's own day/night mode.
      mapNightModeEnabled: true,
      borderRadius: BorderRadius.circular(999),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(
        "${index + 1}/$count",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          height: 1.0,
        ),
      ),
    );
  }
}

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
                        _PinSummaryBadgesPriceRow(
                          listingTypeCode: pin.listingTypeCode,
                          gender: pin.gender,
                          hostResident: pin.hostResident,
                          priceLabel: pin.subtitle,
                          priceStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: _MapListingTileStyle.priceColor(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_PinSummaryBadgesPriceRow.hasContent(
                          listingTypeCode: pin.listingTypeCode,
                          gender: pin.gender,
                          priceLabel: pin.subtitle,
                        ))
                          const SizedBox(height: 4),
                        Text(
                          pin.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: _MapListingTileStyle.titleColor(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (pin.locationLabel?.isNotEmpty == true ||
                            pin.stationLabel?.isNotEmpty == true ||
                            pin.createdAt?.isNotEmpty == true) ...[
                          const SizedBox(height: 4),
                          _PinGeoLabelsRow(
                            locationLabel: pin.locationLabel,
                            stationLabel: pin.stationLabel,
                            lineIds: pin.subwayLineIds,
                            createdAt: pin.createdAt,
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

  static Color borderColor(BuildContext context) {
    final theme = Theme.of(context);
    if (ThemeState().isBlueTheme) {
      return Colors.white.withValues(alpha: 0.16);
    }
    return theme.colorScheme.outline.withValues(alpha: 0.22);
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
    return Material(
      color: bg,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: _MapListingTileStyle.borderColor(context),
          width: 1,
        ),
      ),
      child: child,
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
            gender: pin.gender,
          ),
        ],
      ),
    );
  }
}

class _PinSummaryBadgesPriceRow extends StatelessWidget {
  const _PinSummaryBadgesPriceRow({
    required this.listingTypeCode,
    required this.gender,
    required this.hostResident,
    required this.priceLabel,
    required this.priceStyle,
  });

  final String? listingTypeCode;
  final int? gender;
  final bool? hostResident;
  final String? priceLabel;
  final TextStyle? priceStyle;

  static bool hasContent({
    required String? listingTypeCode,
    required int? gender,
    required String? priceLabel,
  }) {
    return listingTypeCode?.isNotEmpty == true ||
        gender != null ||
        priceLabel?.isNotEmpty == true;
  }

  @override
  Widget build(BuildContext context) {
    final hasBadges =
        listingTypeCode?.isNotEmpty == true || gender != null;
    final hasPrice = priceLabel?.isNotEmpty == true;
    if (!hasBadges && !hasPrice) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (hasBadges)
          _PinSummaryBadges(
            listingTypeCode: listingTypeCode,
            gender: gender,
            hostResident: hostResident,
            compact: true,
          ),
        if (hasBadges && hasPrice) const SizedBox(width: 8),
        if (hasPrice)
          Expanded(
            child: Text(
              priceLabel!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: priceStyle,
            ),
          ),
      ],
    );
  }
}

class _PinSummaryBadges extends StatelessWidget {
  const _PinSummaryBadges({
    required this.listingTypeCode,
    required this.gender,
    this.hostResident,
    this.compact = false,
  });

  final String? listingTypeCode;
  final int? gender;
  final bool? hostResident;
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
            hostResident: hostResident,
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
    this.createdAt,
  });

  static const double _inlineIconSize = 16;

  final String? locationLabel;
  final String? stationLabel;
  final List<int> lineIds;
  final String? createdAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLocation = locationLabel?.isNotEmpty == true;
    final hasStation = stationLabel?.isNotEmpty == true;
    final publicationDate = ListingDetailDateUtils.formatPublicationDate(
      context,
      createdAt,
    );
    final metaStyle = theme.textTheme.bodySmall?.copyWith(
      color: _MapListingTileStyle.metaColor(context),
      fontWeight: FontWeight.w600,
    );
    final dateStyle = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );

    final geoLabels = <Widget>[
      if (hasLocation)
        _PinInlineMetaLabel(
          icon: Icons.location_on,
          iconColor: AppColors.error,
          label: locationLabel!,
          style: metaStyle,
        ),
      if (hasStation)
        _PinInlineMetroLabel(
          lineIds: lineIds,
          label: stationLabel!,
          style: metaStyle,
        ),
    ];
    if (geoLabels.isEmpty && publicationDate == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (geoLabels.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: geoLabels,
          ),
        if (publicationDate != null) ...[
          if (geoLabels.isNotEmpty) const SizedBox(height: 4),
          _PinInlineMetaLabel(
            icon: Icons.schedule,
            iconColor: theme.colorScheme.onSurfaceVariant,
            label: publicationDate,
            style: dateStyle,
          ),
        ],
      ],
    );
  }
}

class _PinInlineMetaLabel extends StatelessWidget {
  const _PinInlineMetaLabel({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ThemeIcon(
          icon,
          color: iconColor,
          size: _PinGeoLabelsRow._inlineIconSize,
          useThemeColor: false,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ],
    );
  }
}

class _PinInlineMetroLabel extends StatelessWidget {
  const _PinInlineMetroLabel({
    required this.lineIds,
    required this.label,
    required this.style,
  });

  final List<int> lineIds;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final visibleLineIds = lineIds.isEmpty ? const [1] : lineIds;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < visibleLineIds.length; i++) ...[
          ThemeIcon(
            Icons.train,
            color: _lineColor(visibleLineIds[i]),
            size: _PinGeoLabelsRow._inlineIconSize,
            useThemeColor: false,
          ),
          SizedBox(width: i == visibleLineIds.length - 1 ? 4 : 2),
        ],
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
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
    required this.gender,
  });

  static const String _noPhotoPlaceholderAsset =
      "assets/images/uydosh_no_photo_placeholder.png";
  static const String _noPhotoPlaceholderAssetLight =
      "assets/images/uydosh_light_no_photo_placeholder.png";
  static const String _roomNeededPlaceholderMaleAsset =
      "assets/images/uydosh_no_photo_room_needed_male.jpg";
  static const String _roomNeededPlaceholderFemaleAsset =
      "assets/images/uydosh_no_photo_room_needed_female.jpg";
  static const String _roommateNeededPlaceholderMaleAsset =
      "assets/images/uydosh_no_photo_roommate_needed_male.jpg";
  static const String _roommateNeededPlaceholderFemaleAsset =
      "assets/images/uydosh_no_photo_roommate_needed_female.jpg";
  static const double size = 104.0;

  final String? photoUrl;
  final int? listingTypeId;
  final int? gender;

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

  /// Gendered "no photo yet" illustration for `room_needed` /
  /// `roommate_needed` pins, or `null` when the type + gender combo has no
  /// dedicated artwork (matches [ListingTileState._genderedPlaceholderAsset]).
  String? _genderedPlaceholderAsset() {
    if (gender != 1 && gender != 2) return null;
    switch (listingTypeId) {
      case ListingTypeIds.roomNeeded:
        return gender == 1
            ? _roomNeededPlaceholderMaleAsset
            : _roomNeededPlaceholderFemaleAsset;
      case ListingTypeIds.roommateNeeded:
        return gender == 1
            ? _roommateNeededPlaceholderMaleAsset
            : _roommateNeededPlaceholderFemaleAsset;
      default:
        return null;
    }
  }

  Widget _placeholder(BuildContext context, ColorScheme scheme) {
    Widget errorBuilder(BuildContext context, Object error, StackTrace? st) {
      return Center(
        child: ThemeIcon(
          Icons.photo_outlined,
          color: scheme.onSurfaceVariant,
          size: 24,
          useThemeColor: false,
        ),
      );
    }

    final genderedAsset = _genderedPlaceholderAsset();
    if (genderedAsset != null) {
      return Image.asset(
        genderedAsset,
        fit: BoxFit.cover,
        errorBuilder: errorBuilder,
      );
    }

    final isLight = ThemeState().isLightTheme;
    final asset =
        isLight ? _noPhotoPlaceholderAssetLight : _noPhotoPlaceholderAsset;
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
        errorBuilder: errorBuilder,
      ),
    );
  }
}

class _MapListingTooltipHeightReporter extends SingleChildRenderObjectWidget {
  const _MapListingTooltipHeightReporter({
    required this.onHeightChanged,
    required super.child,
  });

  final ValueChanged<double> onHeightChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MapListingTooltipHeightReporterRenderObject(onHeightChanged);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _MapListingTooltipHeightReporterRenderObject renderObject,
  ) {
    renderObject.onHeightChanged = onHeightChanged;
  }
}

class _MapListingTooltipHeightReporterRenderObject extends RenderProxyBox {
  _MapListingTooltipHeightReporterRenderObject(this.onHeightChanged);

  ValueChanged<double> onHeightChanged;
  Size? _oldSize;
  bool _reportScheduled = false;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    if (newSize.height <= 0) return;
    // Reporting synchronously from performLayout mutates state that feeds
    // back into this same subtree's positioning (the FAB lift above the
    // tooltip). Deferring to a post-frame callback avoids relying on the
    // rebuild it triggers being flushed before paint, which is not
    // guaranteed and can leave the FABs under-lifted for a frame (or, on
    // some platforms/renderers, longer) — visible as buttons not rising to
    // clear the tooltip when it opens.
    if (_reportScheduled) return;
    _reportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportScheduled = false;
      if (!attached) return;
      onHeightChanged(newSize.height);
    });
  }
}
