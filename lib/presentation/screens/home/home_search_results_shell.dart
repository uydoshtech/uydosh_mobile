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
    required this.canOpenMapView,
    required this.initialMapListings,
    required this.initialMapTotal,
    required this.alertFabBottom,
    required this.searchFiltersState,
    required this.searchButtonTutorialKey,
    required this.searchModeFiltersRibbonBuilder,
    required this.inlineFiltersRibbonBuilder,
    required this.onOpenMapView,
    required this.onOpenInlineSearch,
    required this.onOpenFeedFromMap,
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
  final bool canOpenMapView;
  final List<Listing> initialMapListings;
  final int? initialMapTotal;
  final double alertFabBottom;
  final SearchFiltersState searchFiltersState;
  final GlobalKey<TutorialTargetWrapperState> searchButtonTutorialKey;
  final WidgetBuilder searchModeFiltersRibbonBuilder;
  final WidgetBuilder inlineFiltersRibbonBuilder;
  final VoidCallback onOpenMapView;
  final VoidCallback onOpenInlineSearch;
  final void Function(BuildContext context, SearchBottomSheetResult result)
      onOpenFeedFromMap;

  @override
  State<_SearchResultsShell> createState() => _SearchResultsShellState();
}

class _SearchResultsShellState extends State<_SearchResultsShell> {
  late bool _mapHasBeenShown;

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

  @override
  Widget build(BuildContext context) {
    final listView = Stack(
      clipBehavior: Clip.none,
      children: [
        widget.listContent,
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
            showViewToggle: widget.canOpenMapView,
            onOpenMapView: widget.onOpenMapView,
            onOpenInlineSearch: widget.onOpenInlineSearch,
          ),
        ],
      );
    }

    final mapView = SearchResultsMapScreen(
      listingTypeId: widget.mapResult.listingTypeId,
      locationId: widget.mapResult.locationId,
      subwayStationId: widget.mapResult.subwayStationId,
      subwayStationIds: widget.mapResult.subwayStationIds,
      subwayLineId: widget.mapResult.subwayLineId,
      gender: widget.mapResult.gender,
      minPrice: widget.mapResult.minPrice,
      maxPrice: widget.mapResult.maxPrice,
      privateRoom: widget.mapResult.privateRoom,
      withPhoto: widget.mapResult.withPhoto,
      onOpenFeed: widget.onOpenFeedFromMap,
      embedded: true,
      initialListings: widget.initialMapListings,
      initialTotal: widget.initialMapTotal,
      embeddedSearchButtonBottom: widget.alertFabBottom,
      embeddedViewToggleBottom: _SearchResultsFabStack.viewToggleBottomFor(
        widget.alertFabBottom,
      ),
      onOpenEmbeddedSearch: widget.onOpenInlineSearch,
    );

    final paddedMapView = widget.isSearchMode
        ? mapView
        : Padding(
            padding: EdgeInsets.only(top: widget.mapTopPadding),
            child: mapView,
          );

    final isShowingMap = widget.searchResultsView == _SearchResultsView.map;
    return Stack(
      children: [
        IndexedStack(
          index: isShowingMap ? 1 : 0,
          children: [
            listView,
            paddedMapView,
          ],
        ),
        _SearchResultsFabStack(
          inSearchContext: widget.inSearchContext,
          bottom: widget.alertFabBottom,
          searchFiltersState: widget.searchFiltersState,
          searchButtonTutorialKey: widget.searchButtonTutorialKey,
          isHomeTabActive: widget.isHomeTabActive,
          isSearchMode: widget.isSearchMode,
          showViewToggle: widget.canOpenMapView && !isShowingMap,
          onOpenMapView: widget.onOpenMapView,
          onOpenInlineSearch: widget.onOpenInlineSearch,
        ),
      ],
    );
  }
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
    return searchFabBottom +
        SearchFloatingActionButton.fabSize +
        _viewToggleGap;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          if (inSearchContext && showViewToggle)
            Positioned(
              right: 16,
              bottom: viewToggleBottomFor(bottom),
              child: SearchFloatingActionButton(
                onPressed: onOpenMapView,
                iconData: Icons.map_rounded,
                tooltip: L10n.get("open_map_view"),
                width: 61.2,
                height: 34.2,
                iconSize: 22.5,
                foregroundColor: ThemeState().isBlueTheme ? Colors.white : null,
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
                      replaceCurrentRoute: isSearchMode,
                      openedFromHomeScreen: isHomeTabActive,
                      foregroundColor:
                          ThemeState().isBlueTheme && showViewToggle
                              ? Colors.white
                              : null,
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
