part of "home_screen.dart";

class _SearchResultsShell extends StatefulWidget {
  const _SearchResultsShell({
    required this.listContent,
    required this.inSearchContext,
    required this.isSearchMode,
    required this.isHomeTabActive,
    required this.searchResultsView,
    required this.mapResult,
    required this.searchRibbonHeight,
    required this.inlineRibbonTop,
    required this.mapTopPadding,
    required this.mapBottomInset,
    required this.initialMapListings,
    required this.initialMapTotal,
    required this.feedListingsRevision,
    required this.alertFabBottom,
    required this.searchFiltersState,
    required this.searchButtonTutorialKey,
    required this.searchModeFiltersRibbonBuilder,
    required this.inlineFiltersRibbonBuilder,
    required this.onOpenMapView,
    required this.onOpenInlineSearch,
    required this.onOpenMapSearch,
    required this.onOpenFeedFromMap,
    this.focusListingId,
    this.onDismissMapFilterRibbon,
  });

  final Widget listContent;
  final bool inSearchContext;
  final bool isSearchMode;
  final bool isHomeTabActive;
  final _SearchResultsView searchResultsView;
  final SearchBottomSheetResult mapResult;
  final double searchRibbonHeight;
  final double inlineRibbonTop;
  final double mapTopPadding;
  final double mapBottomInset;
  final List<Listing> initialMapListings;
  final int? initialMapTotal;
  final int feedListingsRevision;

  /// When set (opened via [MainNavigation.openHomeMapView] with a target
  /// listing, e.g. from a listing-detail screen), the embedded map selects
  /// and camera-focuses this listing's pin once loaded.
  final int? focusListingId;
  final double alertFabBottom;
  final SearchFiltersState searchFiltersState;
  final GlobalKey<TutorialTargetWrapperState> searchButtonTutorialKey;
  final WidgetBuilder searchModeFiltersRibbonBuilder;
  final WidgetBuilder inlineFiltersRibbonBuilder;
  final VoidCallback onOpenMapView;
  final VoidCallback onOpenInlineSearch;
  final VoidCallback onOpenMapSearch;
  final void Function(
    BuildContext context,
    SearchBottomSheetResult result, {
    bool mapFilterRibbonDismissed,
  })
  onOpenFeedFromMap;
  final VoidCallback? onDismissMapFilterRibbon;

  @override
  State<_SearchResultsShell> createState() => _SearchResultsShellState();
}

class _SearchResultsShellState extends State<_SearchResultsShell> {
  late bool _mapHasBeenShown;
  List<Listing>? _aiListings;
  String? _aiQuery;
  AiSearchFilters? _aiFilters;
  AiSearchActivity? _aiSearchActivity;

  @override
  void initState() {
    super.initState();
    _mapHasBeenShown = _isShowingMap(widget);
  }

  @override
  void didUpdateWidget(covariant _SearchResultsShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.inSearchContext) {
      _mapHasBeenShown = false;
      return;
    }
    if (_isShowingMap(widget)) {
      _mapHasBeenShown = true;
    }
  }

  bool _isShowingMap(_SearchResultsShell shell) {
    return shell.inSearchContext &&
        shell.searchResultsView == _SearchResultsView.map;
  }

  void _showAiResults(String query, AiSearchResponse result) {
    final filters = result.filters;
    if (filters != null) {
      _applyAiFilters(filters);
    }
    setState(() {
      _aiQuery = query;
      _aiListings = result.listings;
      _aiFilters = result.filters;
      _aiSearchActivity = null;
    });
  }

  void _applyAiFilters(AiSearchFilters filters) {
    final state = widget.searchFiltersState;
    state.clearPersistedFiltersDismissed();
    if (filters.listingTypeId != null) {
      unawaited(state.setListingTypeId(filters.listingTypeId!));
    }
    if (filters.locationId != null) {
      unawaited(state.setLocationIndex(filters.locationId!));
    }
    if (filters.minPrice != null || filters.maxPrice != null) {
      unawaited(
        state.setPriceRange(
          filters.minPrice ?? state.minPrice,
          filters.maxPrice ?? state.maxPrice,
        ),
      );
    }
    if (filters.gender != null) {
      unawaited(state.setGender(filters.gender!));
    }
    if (filters.privateRoom == true) {
      unawaited(state.setPrivateRoom(true));
    }
  }

  void _clearAiResults() {
    setState(() {
      _aiQuery = null;
      _aiListings = null;
      _aiFilters = null;
    });
  }

  void _setAiSearchActivity(AiSearchActivity? value) {
    if (!mounted || _aiSearchActivity == value) return;
    setState(() => _aiSearchActivity = value);
  }

  @override
  Widget build(BuildContext context) {
    final listView = Stack(
      clipBehavior: Clip.none,
      children: [
        _aiListings == null
            ? widget.listContent
            : _AiSearchResultsFeed(
                query: _aiQuery ?? "",
                listings: _aiListings!,
                amenityCodes: _aiFilters?.amenityCodes ?? const [],
                onClear: _clearAiResults,
                topInset: widget.isSearchMode
                    ? widget.searchRibbonHeight + 12
                    : widget.inlineRibbonTop + 68,
              ),
        if (widget.isSearchMode)
          Positioned(
            left: 12,
            right: 12,
            top: 0,
            height: widget.searchRibbonHeight,
            child: widget.searchModeFiltersRibbonBuilder(context),
          ),
        if (!widget.isSearchMode)
          Positioned(
            left: 12,
            right: 12,
            top: widget.inlineRibbonTop,
            child: widget.inlineFiltersRibbonBuilder(context),
          ),
        if (_aiListings == null)
          Positioned(
            right: 16,
            top: widget.isSearchMode
                ? widget.searchRibbonHeight + 8
                : widget.inlineRibbonTop + 56 + 8,
            child: AiSearchFloatingButton(
              onResults: _showAiResults,
              onSearchStateChanged: _setAiSearchActivity,
            ),
          ),
        if (_aiSearchActivity != null)
          Positioned(
            left: 24,
            right: 24,
            top: widget.isSearchMode
                ? widget.searchRibbonHeight + 76
                : widget.inlineRibbonTop + 132,
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      _aiSearchActivity == AiSearchActivity.transcribing
                          ? "Распознаю речь…"
                          : "Ищу подходящие варианты…",
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    if (!widget.inSearchContext || !_mapHasBeenShown) {
      return Stack(
        children: [
          listView,
          _SearchResultsFabStack(
            inSearchContext: widget.inSearchContext,
            bottom: widget.alertFabBottom,
            searchFiltersState: widget.searchFiltersState,
            searchButtonTutorialKey: widget.searchButtonTutorialKey,
            isHomeTabActive: widget.isHomeTabActive,
            isSearchMode: widget.isSearchMode,
            showViewToggle: true,
            onOpenMapView: widget.onOpenMapView,
            onOpenInlineSearch: widget.onOpenInlineSearch,
          ),
        ],
      );
    }

    final mapView = SearchResultsMapScreen(
      listingTypeId: widget.mapResult.listingTypeId,
      listingTypeIds: widget.mapResult.listingTypeIds,
      locationId: widget.mapResult.locationId,
      subwayStationId: widget.mapResult.subwayStationId,
      subwayStationIds: widget.mapResult.subwayStationIds,
      subwayLineId: widget.mapResult.subwayLineId,
      gender: widget.mapResult.gender,
      minPrice: widget.mapResult.minPrice,
      maxPrice: widget.mapResult.maxPrice,
      privateRoom: widget.mapResult.privateRoom,
      withPhoto: widget.mapResult.withPhoto,
      has3dTour: widget.mapResult.has3dTour,
      onOpenFeed: widget.onOpenFeedFromMap,
      embedded: true,
      initialListings: widget.initialMapListings,
      initialTotal: widget.initialMapTotal,
      feedListingsRevision: widget.feedListingsRevision,
      initialFocusListingId: widget.focusListingId,
      embeddedMapBottomInset: widget.mapBottomInset,
      embeddedSearchButtonBottom: widget.alertFabBottom,
      embeddedViewToggleBottom: _SearchResultsFabStack.viewToggleBottomFor(
        widget.alertFabBottom,
      ),
      onOpenEmbeddedSearch: widget.onOpenMapSearch,
      onDismissFilterRibbon: widget.onDismissMapFilterRibbon,
    );

    final paddedMapView = widget.isSearchMode
        ? mapView
        : Padding(
            padding: EdgeInsets.only(top: widget.mapTopPadding),
            child: mapView,
          );

    final isShowingMap = widget.searchResultsView == _SearchResultsView.map;
    final shouldMountMap =
        isShowingMap && (widget.isSearchMode || widget.isHomeTabActive);
    if (!shouldMountMap) {
      return Stack(
        children: [
          listView,
          if (!isShowingMap)
            _SearchResultsFabStack(
              inSearchContext: widget.inSearchContext,
              bottom: widget.alertFabBottom,
              searchFiltersState: widget.searchFiltersState,
              searchButtonTutorialKey: widget.searchButtonTutorialKey,
              isHomeTabActive: widget.isHomeTabActive,
              isSearchMode: widget.isSearchMode,
              showViewToggle: true,
              onOpenMapView: widget.onOpenMapView,
              onOpenInlineSearch: widget.onOpenInlineSearch,
            ),
        ],
      );
    }

    return Stack(children: [Positioned.fill(child: paddedMapView)]);
  }
}

class _AiSearchResultsFeed extends StatelessWidget {
  const _AiSearchResultsFeed({
    required this.query,
    required this.listings,
    required this.amenityCodes,
    required this.onClear,
    required this.topInset,
  });

  final String query;
  final List<Listing> listings;
  final List<String> amenityCodes;
  final VoidCallback onClear;
  final double topInset;

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: EdgeInsets.fromLTRB(12, topInset, 12, 96),
    itemCount: listings.length + 1,
    itemBuilder: (context, index) {
      if (index == 0) {
        final resultLabel = listings.isEmpty
            ? "AI-поиск: ничего не найдено"
            : "AI-поиск · ${listings.length} вариантов";
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resultLabel,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (query.isNotEmpty)
                          Text(
                            query,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (amenityCodes.isNotEmpty)
                          Text(
                            amenityCodes
                                .map((code) {
                                  final amenity =
                                      AmenitiesCache.getAmenityByCode(code);
                                  if (amenity == null) return code;
                                  return switch (L10n.currentLanguage) {
                                    "uz" => amenity.nameUz,
                                    "en" => amenity.nameEn,
                                    _ => amenity.nameRu,
                                  };
                                })
                                .join(" · "),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ListingTile(
          listing: listings[index - 1],
          feedOptimized: true,
          forceFavorite: false,
          showHeartIcon: false,
          showFavoriteIndicator: true,
          onFavoriteRemoved: null,
        ),
      );
    },
  );
}

class _SearchResultsFabStack extends StatelessWidget {
  const _SearchResultsFabStack({
    required this.inSearchContext,
    required this.bottom,
    required this.searchFiltersState,
    required this.searchButtonTutorialKey,
    required this.isHomeTabActive,
    required this.isSearchMode,
    required this.showViewToggle,
    required this.onOpenMapView,
    required this.onOpenInlineSearch,
  });

  static const double _viewToggleGap = 12.0;
  static const double compactButtonWidth = 61.2;
  static const double compactButtonHeight = 44.2;
  static const double compactButtonIconSize = 22.5;
  static const _feedOverlayPanelColor = Colors.white;
  static const _feedOverlayButtonBorder = BorderSide(
    color: Colors.black,
    width: 1,
  );

  final bool inSearchContext;
  final double bottom;
  final SearchFiltersState searchFiltersState;
  final GlobalKey<TutorialTargetWrapperState> searchButtonTutorialKey;
  final bool isHomeTabActive;
  final bool isSearchMode;
  final bool showViewToggle;
  final VoidCallback onOpenMapView;
  final VoidCallback onOpenInlineSearch;

  static double viewToggleBottomFor(double searchFabBottom) {
    return searchFabBottom + compactButtonHeight + _viewToggleGap;
  }

  @override
  Widget build(BuildContext context) {
    final useLightFeedOverlayStyle = ThemeState().isLightTheme;

    return Positioned.fill(
      child: Stack(
        children: [
          if (showViewToggle)
            Positioned(
              right: 16,
              bottom: viewToggleBottomFor(bottom),
              child: SearchFloatingActionButton(
                onPressed: onOpenMapView,
                iconData: Icons.map_rounded,
                tooltip: L10n.get("open_map_view"),
                width: compactButtonWidth,
                height: compactButtonHeight,
                iconSize: compactButtonIconSize,
                backgroundColor: useLightFeedOverlayStyle
                    ? _feedOverlayPanelColor
                    : null,
                foregroundColor: useLightFeedOverlayStyle
                    ? Colors.black
                    : (ThemeState().isBlueTheme ? Colors.white : null),
                borderSide: useLightFeedOverlayStyle
                    ? _feedOverlayButtonBorder
                    : null,
                mapOverlay: useLightFeedOverlayStyle,
                elevation: ThemeState().isBlueTheme ? null : 8,
              ),
            ),
          Positioned(
            right: 16,
            bottom: bottom,
            child: TutorialTargetWrapper(
              key: searchButtonTutorialKey,
              child: ListenableBuilder(
                listenable: AnimationSettingsState(),
                builder: (context, _) {
                  return TutorialPulseWrapper(
                    enabled: false,
                    variant: TutorialPulseVariant.floatingActionButton,
                    child: SearchFloatingActionButton(
                      searchFiltersState: searchFiltersState,
                      onPressed: isSearchMode ? null : onOpenInlineSearch,
                      iconData: Icons.search,
                      width: compactButtonWidth,
                      height: compactButtonHeight,
                      iconSize: compactButtonIconSize,
                      replaceCurrentRoute: isSearchMode,
                      openedFromHomeScreen: isHomeTabActive,
                      backgroundColor: useLightFeedOverlayStyle
                          ? _feedOverlayPanelColor
                          : null,
                      foregroundColor: useLightFeedOverlayStyle
                          ? Colors.black
                          : (ThemeState().isBlueTheme && showViewToggle
                                ? Colors.white
                                : null),
                      borderSide: useLightFeedOverlayStyle
                          ? _feedOverlayButtonBorder
                          : null,
                      mapOverlay: useLightFeedOverlayStyle,
                      elevation: ThemeState().isBlueTheme ? null : 8,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
