part of "home_screen.dart";

class _SearchResultsShell extends StatelessWidget {
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
    required this.viewToggleTop,
    required this.initialMapListings,
    required this.initialMapTotal,
    required this.alertFabBottom,
    required this.searchFiltersState,
    required this.bellHintLayerLink,
    required this.searchButtonTutorialKey,
    required this.bellHintDismissed,
    required this.isCreatingSearchAlert,
    required this.fabGap,
    required this.searchModeFiltersRibbonBuilder,
    required this.inlineFiltersRibbonBuilder,
    required this.onOpenMapView,
    required this.onCreateSearchAlert,
    required this.onOpenInlineSearch,
    required this.onDismissBellHint,
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
  final double viewToggleTop;
  final List<Listing> initialMapListings;
  final int? initialMapTotal;
  final double alertFabBottom;
  final SearchFiltersState searchFiltersState;
  final LayerLink bellHintLayerLink;
  final GlobalKey<TutorialTargetWrapperState> searchButtonTutorialKey;
  final bool bellHintDismissed;
  final bool isCreatingSearchAlert;
  final double fabGap;
  final WidgetBuilder searchModeFiltersRibbonBuilder;
  final WidgetBuilder inlineFiltersRibbonBuilder;
  final VoidCallback onOpenMapView;
  final VoidCallback onCreateSearchAlert;
  final VoidCallback onOpenInlineSearch;
  final VoidCallback onDismissBellHint;
  final void Function(BuildContext context, SearchBottomSheetResult result)
      onOpenFeedFromMap;

  @override
  Widget build(BuildContext context) {
    final listView = Stack(
      clipBehavior: Clip.none,
      children: [
        listContent,
        if (isSearchMode)
          Positioned(
            left: 12,
            right: 12,
            top: 0,
            height: searchRibbonHeight,
            child: searchModeFiltersRibbonBuilder(context),
          ),
        if (!isSearchMode)
          Positioned(
            left: 12,
            right: 12,
            top: inlineRibbonTop,
            child: inlineFiltersRibbonBuilder(context),
          ),
        if (inSearchContext)
          Positioned(
            right: 16,
            top: viewToggleTop,
            child: SearchFloatingActionButton(
              onPressed: onOpenMapView,
              iconData: Icons.map_rounded,
              tooltip: L10n.get("open_map_view"),
              width: 68,
              height: 38,
              elevation: ThemeState().isBlueTheme ? null : 8,
            ),
          ),
        _SearchResultsFabStack(
          inSearchContext: inSearchContext,
          bottom: alertFabBottom,
          searchFiltersState: searchFiltersState,
          bellHintLayerLink: bellHintLayerLink,
          searchButtonTutorialKey: searchButtonTutorialKey,
          isCreatingSearchAlert: isCreatingSearchAlert,
          isHomeTabActive: isHomeTabActive,
          bellHintDismissed: bellHintDismissed,
          fabGap: fabGap,
          isSearchMode: isSearchMode,
          onCreateSearchAlert: onCreateSearchAlert,
          onOpenInlineSearch: onOpenInlineSearch,
          onDismissBellHint: onDismissBellHint,
        ),
      ],
    );

    if (!inSearchContext || searchResultsView == _SearchResultsView.list) {
      return listView;
    }

    final mapView = SearchResultsMapScreen(
      listingTypeId: mapResult.listingTypeId,
      locationId: mapResult.locationId,
      subwayStationId: mapResult.subwayStationId,
      subwayStationIds: mapResult.subwayStationIds,
      subwayLineId: mapResult.subwayLineId,
      gender: mapResult.gender,
      minPrice: mapResult.minPrice,
      maxPrice: mapResult.maxPrice,
      privateRoom: mapResult.privateRoom,
      withPhoto: mapResult.withPhoto,
      onOpenFeed: onOpenFeedFromMap,
      embedded: true,
      initialListings: initialMapListings,
      initialTotal: initialMapTotal,
    );

    if (isSearchMode) return mapView;

    return Padding(
      padding: EdgeInsets.only(top: mapTopPadding),
      child: mapView,
    );
  }
}

class _SearchResultsFabStack extends StatelessWidget {
  const _SearchResultsFabStack({
    required this.inSearchContext,
    required this.bottom,
    required this.searchFiltersState,
    required this.bellHintLayerLink,
    required this.searchButtonTutorialKey,
    required this.isCreatingSearchAlert,
    required this.isHomeTabActive,
    required this.bellHintDismissed,
    required this.fabGap,
    required this.isSearchMode,
    required this.onCreateSearchAlert,
    required this.onOpenInlineSearch,
    required this.onDismissBellHint,
  });

  final bool inSearchContext;
  final double bottom;
  final SearchFiltersState searchFiltersState;
  final LayerLink bellHintLayerLink;
  final GlobalKey<TutorialTargetWrapperState> searchButtonTutorialKey;
  final bool isCreatingSearchAlert;
  final bool isHomeTabActive;
  final bool bellHintDismissed;
  final double fabGap;
  final bool isSearchMode;
  final VoidCallback onCreateSearchAlert;
  final VoidCallback onOpenInlineSearch;
  final VoidCallback onDismissBellHint;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: bottom,
      child: BlocSelector<ListingsBloc, ListingsState, _SearchAlertFabState>(
        selector: (state) {
          final loaded =
              state.maybeMap(loaded: (_) => true, orElse: () => false);
          final isEmpty = state.maybeMap(
            loaded: (s) => s.listings.isEmpty,
            orElse: () => false,
          );
          return _SearchAlertFabState(
            showFab: inSearchContext && loaded && !isEmpty,
            isEmpty: inSearchContext && isEmpty,
          );
        },
        builder: (context, fabState) {
          final showBellHint = fabState.showFab &&
              fabState.isEmpty &&
              TooltipsState().enabled &&
              !bellHintDismissed;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomRight,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (fabState.showFab) ...[
                    CompositedTransformTarget(
                      link: bellHintLayerLink,
                      child: Transform.scale(
                        scale: 0.92,
                        child: SearchFloatingActionButton(
                          searchFiltersState: searchFiltersState,
                          onPressed: isCreatingSearchAlert
                              ? null
                              : onCreateSearchAlert,
                          iconData: Icons.add_alert,
                          tooltip: L10n.get("search_alert_notify_me"),
                          replaceCurrentRoute: false,
                          openedFromHomeScreen: isHomeTabActive,
                          elevation: ThemeState().isBlueTheme ? null : 8,
                        ),
                      ),
                    ),
                    SizedBox(height: fabGap),
                  ],
                  TutorialTargetWrapper(
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
                            elevation: ThemeState().isBlueTheme ? null : 8,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              CompositedTransformFollower(
                link: bellHintLayerLink,
                showWhenUnlinked: false,
                targetAnchor: Alignment.topRight,
                followerAnchor: Alignment.bottomRight,
                offset: const Offset(0, -4),
                child: TooltipFade(
                  collapse: false,
                  duration: const Duration(milliseconds: 260),
                  visible: showBellHint,
                  child: Material(
                    type: MaterialType.transparency,
                    child: NeumorphicHintBubble(
                      maxWidth: 220,
                      tailRightInset: 28,
                      onClose: onDismissBellHint,
                      message: TextSpan(
                        text: L10n.get("search_alert_bell_hint"),
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.3,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
