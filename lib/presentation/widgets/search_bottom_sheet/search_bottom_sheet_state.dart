part of "../search_bottom_sheet.dart";

class _SearchBottomSheetContentState extends State<_SearchBottomSheetContent> {
  final SearchFiltersState _searchFiltersState = SearchFiltersState();
  final GlobalKey<TutorialTargetWrapperState> _metroLineTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();
  final GlobalKey<TutorialTargetWrapperState> _metroStationTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();
  List<SubwayStation> _currentStations = [];
  final List<Location> _currentLocations = [];
  FixedExtentScrollController? _stationPickerController;
  FixedExtentScrollController? _metroLineScrollController;
  FixedExtentScrollController? _locationScrollController;
  Timer? _blinkTimer;
  bool _isBlinking = true;
  double? _cachedSheetHeight;

  @override
  void initState() {
    super.initState();

    logger.d(
      "DEBUG: SearchBottomSheet initState - widget.currentSubwayStationId: ${widget.currentSubwayStationId}, widget.currentSubwayLineId: ${widget.currentSubwayLineId}",
    );
    logger.d(
      "DEBUG: SearchBottomSheet initState - global subwayLine: ${_searchFiltersState.selectedSubwayLine}, global stationId: ${_searchFiltersState.selectedStationId}",
    );

    // Initialize the station picker controller only once
    // Don"t set initialItem here to avoid forcing position 0
    _stationPickerController = FixedExtentScrollController();
    _metroLineScrollController = FixedExtentScrollController(
      initialItem: _searchFiltersState.selectedSubwayLine,
    );
    _locationScrollController = FixedExtentScrollController(
      initialItem: _getInitialLocationItem(),
    );

    // Initialize blink timer
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isBlinking = !_isBlinking;
        });
      }
    });

    // Use the current search parameters to restore the correct state
    if (widget.currentListingTypeId != null) {
      _searchFiltersState.setListingTypeId(widget.currentListingTypeId!);
    }

    if (widget.currentLocationId != null) {
      _searchFiltersState.setLocationIndex(widget.currentLocationId!);
    }

    if (widget.currentSubwayLineId != null) {
      _searchFiltersState.setSubwayLine(widget.currentSubwayLineId!);
    }

    if (widget.currentSubwayStationId != null) {
      _searchFiltersState.setStationId(widget.currentSubwayStationId!);
    }

    if (widget.currentGender != null) {
      _searchFiltersState.setGender(widget.currentGender!);
    }

    // Restore price range if provided
    if (widget.currentMinPrice != null && widget.currentMaxPrice != null) {
      _searchFiltersState.setPriceRange(
        widget.currentMinPrice!,
        widget.currentMaxPrice!,
      );
    }

    // Load stations if there"s a saved subway line
    if (_searchFiltersState.selectedSubwayLine > 0) {
      final subwayBloc = context.read<SubwayStationsBloc>();
      subwayBloc.add(
        SubwayStationsEvent.fetchSubwayStationsByLine(
          line: _searchFiltersState.selectedSubwayLine,
        ),
      );
      setState(() {});
    }

    // Ensure station selection is reset when opening with only metro line (no specific station)
    if (widget.currentSubwayLineId != null &&
        widget.currentSubwayLineId! > 0 &&
        widget.currentSubwayStationId == null) {
      _searchFiltersState.setStationIndex(0);
      _searchFiltersState.setStationId(0);
    }

    // Show metro tutorial only when opened from home screen, onboarding toggle is ON,
    // user is logged in, and not yet completed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        if (widget.openedFromHomeScreen &&
            AuthenticationState().isAuthenticated &&
            OnboardingState().showOnboarding &&
            !TutorialState().hasCompletedMetroTutorial) {
          _showMetroTutorial();
        }
      });
    });
  }

  void _showMetroTutorial() {
    if (!mounted) return;
    MetroTutorialOverlay.show(
      context,
      metroLineKey: _metroLineTutorialKey,
      metroStationKey: _metroStationTutorialKey,
      onCycleToLine: _animateToMetroLine,
      onCycleToStation: _animateToStation,
      getStationCount: () =>
          _searchFiltersState.selectedSubwayLine == 4 && _currentStations.isNotEmpty
              ? _currentStations.length + 1
              : 0,
      onComplete: () {
        _animateToMetroLine(0);
        TutorialState().markMetroTutorialCompleted();
        // Turn toggle OFF after both tutorials shown so it won't show on next app start
        OnboardingState().setShowOnboarding(false);
      },
    );
  }

  void _animateToMetroLine(int lineIndex) {
    if (!mounted) return;
    setState(() {
      _searchFiltersState.setSubwayLine(lineIndex);
      if (lineIndex > 0) {
        _resetLocationPicker();
        _loadStationsForLine(lineIndex);
      } else {
        _currentStations = [];
        _searchFiltersState.setStationIndex(0);
        _searchFiltersState.setStationId(0);
      }
    });
    _metroLineScrollController?.animateToItem(
      lineIndex,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _animateToStation(int stationIndex) {
    if (!mounted) return;
    final maxIndex = _currentStations.isEmpty ? 0 : _currentStations.length;
    final clampedIndex = stationIndex.clamp(0, maxIndex);
    setState(() {
      if (clampedIndex == 0) {
        _searchFiltersState.setStationIndex(0);
        _searchFiltersState.setStationId(0);
      } else {
        final index = clampedIndex - 1;
        if (index < _currentStations.length) {
          final station = _currentStations[index];
          _searchFiltersState.setStationIndex(index);
          _searchFiltersState.setStationId(station.id);
        }
      }
    });
    if (_stationPickerController?.hasClients ?? false) {
      _stationPickerController!.animateToItem(
        clampedIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    MetroTutorialOverlay.stopCycling();
    _stationPickerController?.dispose();
    _metroLineScrollController?.dispose();
    _locationScrollController?.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  int? _getSelectedLocationId() {
    // selectedLocationIndex > 0 means a location is selected (0 = "Select location")
    if (_searchFiltersState.selectedLocationIndex > 0) {
      // selectedLocationIndex now stores the actual location ID directly
      return _searchFiltersState.selectedLocationIndex;
    }
    return null;
  }

  int _getInitialLocationItem() {
    // If no location is selected, return 0 (first item: "Select location")
    if (_searchFiltersState.selectedLocationIndex <= 0) {
      return 0;
    }

    // Find the index of the selected location ID in the wheel picker
    final selectedLocationId = _searchFiltersState.selectedLocationIndex;
    final locationIndex = _currentLocations.indexWhere(
      (location) => location.id == selectedLocationId,
    );

    // Return the wheel picker index (0 = "Select location", 1 = first location, etc.)
    return locationIndex >= 0 ? locationIndex + 1 : 0;
  }

  int _getLocationIndexFromId(int locationId, List<Location> locations) {
    // If no location is selected, return -1 (unselected)
    if (locationId <= 0) {
      return -1;
    }

    // Find the index of the selected location ID in the provided locations list
    final locationIndex = locations.indexWhere(
      (location) => location.id == locationId,
    );

    // Return the location index (-1 for unselected, 0+ for selected)
    return locationIndex >= 0 ? locationIndex : -1;
  }

  int? _getSelectedSubwayStationId() {
    // Only return station ID if it"s explicitly set and greater than 0
    if (_searchFiltersState.selectedStationId > 0) {
      return _searchFiltersState.selectedStationId;
    }

    // Don"t fall back to index-based selection to prevent auto-selecting first station
    return null;
  }

  // New method to get the initial station item for the wheel picker
  int _getInitialStationItem() {
    logger.d(
      "DEBUG: _getInitialStationItem called - selectedStationId: ${_searchFiltersState.selectedStationId}, stations count: ${_currentStations.length}",
    );

    // If no station is selected or no stations are loaded, return 0 (first item: "Select station")
    if (_searchFiltersState.selectedStationId <= 0 ||
        _currentStations.isEmpty) {
      logger.d(
        "DEBUG: Returning 0 (Select station) - no station selected or no stations loaded",
      );
      return 0;
    }

    // Find the index of the selected station ID in the current stations list
    final selectedStationId = _searchFiltersState.selectedStationId;
    final stationIndex = _currentStations.indexWhere(
      (station) => station.id == selectedStationId,
    );

    // Return the wheel picker index (0 = "Select station", 1 = first station, etc.)
    final result = stationIndex >= 0 ? stationIndex + 1 : 0;
    logger.d(
      "DEBUG: Found station at index $stationIndex, returning wheel picker index: $result",
    );
    return result;
  }

  void _loadStationsForLine(int line) {
    setState(() {
      _searchFiltersState.setSubwayLine(line);
      _searchFiltersState.setStationIndex(0);
      _searchFiltersState.setStationId(0);
    });

    // When changing metro lines, smoothly reset to position 0
    if (_stationPickerController != null &&
        _stationPickerController!.hasClients) {
      logger.d("DEBUG: Metro line changed, smoothly resetting to position 0");
      _stationPickerController!.animateToItem(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    // Trigger the BLoC to fetch stations for the selected line
    context.read<SubwayStationsBloc>().add(
      SubwayStationsEvent.fetchSubwayStationsByLine(line: line),
    );
  }

  /// Resets the location picker to its initial state (no location selected)
  /// and forces a rebuild of the wheel pickers to ensure proper visual reset
  void _resetLocationPicker() {
    setState(() {
      _searchFiltersState.setLocationIndex(0);
    });
    _forceRebuildWheelPickers();
  }

  /// Resets all metro-related filters (line and station) to their initial state
  /// and forces a rebuild of the wheel pickers to ensure proper visual reset
  void _resetMetroPickers() {
    setState(() {
      _searchFiltersState.setSubwayLine(0);
      _searchFiltersState.setStationIndex(0);
      _searchFiltersState.setStationId(0);
      _currentStations = [];
    });
    _resetWheelPickerControllers();
    _forceRebuildWheelPickers();
  }

  void _forceRebuildWheelPickers() {
    // Force rebuild by triggering setState
    setState(() {});
  }

  void _resetWheelPickerControllers() {
    // Only create a new controller if one doesn"t exist
    if (_stationPickerController == null) {
      logger.d(
        "DEBUG: Creating new station picker controller, stations count: ${_currentStations.length}",
      );
      _stationPickerController = FixedExtentScrollController();
    } else {
      logger.d(
        "DEBUG: Keeping existing station picker controller to preserve scroll position",
      );
    }
  }

  /// Restores the picker to the correct position without disrupting scrolling
  void _restoreStationPickerPosition() {
    logger.d("DEBUG: _restoreStationPickerPosition called");
    logger.d("DEBUG: Controller exists: ${_stationPickerController != null}");
    logger.d(
      "DEBUG: Controller has clients: ${_stationPickerController?.hasClients}",
    );
    logger.d(
      "DEBUG: Current selectedStationId: ${_searchFiltersState.selectedStationId}",
    );
    logger.d(
      "DEBUG: Current selectedStationIndex: ${_searchFiltersState.selectedStationIndex}",
    );

    if (_stationPickerController != null &&
        _stationPickerController!.hasClients) {
      final targetPosition = _getInitialStationItem();
      logger.d("DEBUG: Restoring station picker to position: $targetPosition");

      // Use animateToItem for smooth scrolling to the target position
      _stationPickerController!.animateToItem(
        targetPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      logger.d(
        "DEBUG: Cannot restore position - controller is null or has no clients",
      );
    }
  }

  void _onStationsLoaded(List<SubwayStation> stations) {
    logger.d(
      "DEBUG: _onStationsLoaded called with ${stations.length} stations",
    );
    logger.d(
      "DEBUG: _onStationsLoaded - widget.currentSubwayStationId: ${widget.currentSubwayStationId}",
    );
    logger.d(
      "DEBUG: _onStationsLoaded - global stationId: ${_searchFiltersState.selectedStationId}",
    );

    setState(() {
      _currentStations = stations;

      // Restore station selection based on available data
      if (stations.isNotEmpty) {
        if (widget.currentSubwayStationId != null) {
          // Case 1: We have a specific station ID from the current search
          final targetStationId = widget.currentSubwayStationId!;
          logger.d(
            "DEBUG: Trying to restore station with ID: $targetStationId",
          );

          // Find this station in the loaded stations list
          final correctIndex = stations.indexWhere(
            (station) => station.id == targetStationId,
          );
          if (correctIndex >= 0) {
            // Update both the index and ID to keep them in sync
            _searchFiltersState.setStationIndex(correctIndex);
            _searchFiltersState.setStationId(targetStationId);
            logger.d(
              "DEBUG: Restored station at index $correctIndex with ID $targetStationId",
            );
          } else {
            _searchFiltersState.setStationIndex(0);
            _searchFiltersState.setStationId(0);
            logger.d("DEBUG: Station not found, reset to index 0");
          }
        } else if (_searchFiltersState.selectedStationId > 0) {
          // Case 2: No widget parameter but we have a global station ID (opening from curved navigation)
          final targetStationId = _searchFiltersState.selectedStationId;
          logger.d(
            "DEBUG: No widget parameter, trying to restore from global state - station ID: $targetStationId",
          );

          // Find this station in the loaded stations list
          final correctIndex = stations.indexWhere(
            (station) => station.id == targetStationId,
          );
          if (correctIndex >= 0) {
            // Update the index to match the current stations list
            _searchFiltersState.setStationIndex(correctIndex);
            logger.d(
              "DEBUG: Restored station from global state at index $correctIndex with ID $targetStationId",
            );
          } else {
            // Station not found in current list, reset
            _searchFiltersState.setStationIndex(0);
            _searchFiltersState.setStationId(0);
            logger.d(
              "DEBUG: Station from global state not found, reset to index 0",
            );
          }
        } else {
          // Case 3: No specific station to restore, keep station unselected
          _searchFiltersState.setStationIndex(0);
          _searchFiltersState.setStationId(0);
          logger.d("DEBUG: No specific station to restore, reset to index 0");
        }
      }
    });

    logger.d(
      "DEBUG: After setState - selectedStationId: ${_searchFiltersState.selectedStationId}, selectedStationIndex: ${_searchFiltersState.selectedStationIndex}",
    );

    // Don"t reset the controller here - it causes scrolling issues
    // Instead, restore the picker to the correct position smoothly
    // Use addPostFrameCallback to ensure setState has completed
    logger.d("DEBUG: Stations loaded, scheduling picker position restoration");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.d("DEBUG: Post frame callback - restoring picker position");
      _restoreStationPickerPosition();
    });
  }

  String _getLocalizedName({String? nameUz, String? nameRu, String? nameEn}) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SubwayStationsBloc, SubwayStationsState>(
      listener: (context, state) {
        state.map(
          initial: (_) {},
          loading: (_) {},
          loaded: (loadedState) => _onStationsLoaded(loadedState.stations),
          error: (_) {},
        );
      },
      child: Container(
        height: _cachedSheetHeight ??= MediaQuery.of(context).size.height * 0.7 + 30,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Search header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      L10n.get("search_listings"),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Search filters
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Listing Type and Gender Selection
                          SearchBottomSheetPrimaryFilters(
                            searchFiltersState: _searchFiltersState,
                            onListingTypeChanged: (listingTypeId) {
                              _searchFiltersState.setListingTypeId(
                                listingTypeId,
                              );
                              setState(() {});
                            },
                            onGenderChanged: (gender) {
                              _searchFiltersState.setGender(gender);
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 10),

                          // Location filter - Wheel Picker
                          SearchBottomSheetLocationSection(
                            searchFiltersState: _searchFiltersState,
                            locationScrollController: _locationScrollController,
                            getLocationIndexFromId: _getLocationIndexFromId,
                            onLocationChanged: (locationId) {
                              setState(() {
                                if (locationId == null) {
                                  _searchFiltersState.setLocationIndex(0);
                                } else {
                                  _searchFiltersState.setLocationIndex(
                                    locationId,
                                  );
                                }
                              });
                            },
                            onMetroReset: _resetMetroPickers,
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              L10n.get("search_location_or_metro_hint"),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Metro Line and Station Selection - Side by Side Wheel Pickers
                          SearchBottomSheetMetroSection(
                            searchFiltersState: _searchFiltersState,
                            currentStations: _currentStations,
                            metroLineScrollController: _metroLineScrollController,
                            stationPickerController: _stationPickerController,
                            metroLineTutorialKey: _metroLineTutorialKey,
                            metroStationTutorialKey: _metroStationTutorialKey,
                            getLocalizedName: _getLocalizedName,
                            onSubwayLineChanged: (index) {
                              setState(() {
                                _searchFiltersState.setSubwayLine(index);
                                if (index > 0) {
                                  _resetLocationPicker();
                                }
                              });
                              if (index > 0) {
                                _loadStationsForLine(index);
                              } else {
                                setState(() {
                                  _currentStations = [];
                                  _searchFiltersState.setStationIndex(0);
                                  _searchFiltersState.setStationId(0);
                                });
                              }
                            },
                            onStationChanged: (index) {
                              setState(() {
                                if (index == 0) {
                                  _searchFiltersState.setStationIndex(0);
                                  _searchFiltersState.setStationId(0);
                                } else {
                                  final stationIndex = index - 1;
                                  if (stationIndex < _currentStations.length) {
                                    final selectedStationId =
                                        _currentStations[stationIndex].id;
                                    _searchFiltersState
                                        .setStationIndex(stationIndex);
                                    _searchFiltersState
                                        .setStationId(selectedStationId);
                                  }
                                }
                              });
                            },
                          ),

                          // Explanatory text container - always reserved to prevent interface jerking
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                height: 20, // Fixed height to reserve space

                                child:
                                    _searchFiltersState.selectedSubwayLine >
                                                0 &&
                                            _searchFiltersState
                                                    .selectedStationId ==
                                                0
                                        ? _buildRichTextExplanation(
                                          context,
                                          theme,
                                        )
                                        : const SizedBox.shrink(), // Empty space when text shouldn"t show
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Price, Private Room, Search button
                          SearchBottomSheetSecondaryFilters(
                            searchFiltersState: _searchFiltersState,
                            onPriceRangeChanged: (minPrice, maxPrice) {
                              _searchFiltersState.setPriceRange(
                                minPrice,
                                maxPrice,
                              );
                              setState(() {});
                            },
                            onPrivateRoomChanged: (value) {
                              _searchFiltersState.setPrivateRoom(value);
                              setState(() {});
                            },
                            onWithPhotoChanged: (value) {
                              _searchFiltersState.setWithPhoto(value);
                              setState(() {});
                            },
                            onSearchPressed: _performSearch,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    HapticFeedbackUtils.impact();

    // Get all current filter values
    final listingTypeId = _searchFiltersState.selectedListingTypeId;
    final locationId = _getSelectedLocationId();
    final subwayStationId = _getSelectedSubwayStationId();
    final subwayLine = _searchFiltersState.selectedSubwayLine;
    final gender = _searchFiltersState.selectedGender;
    final minPrice = _searchFiltersState.minPrice;
    final maxPrice = _searchFiltersState.maxPrice;
    final privateRoom = _searchFiltersState.privateRoom;
    final withPhoto = _searchFiltersState.withPhoto;

    // Debug logging to see what values are being passed
    logger.d(
      "SearchBottomSheet._performSearch - subwayStationId: $subwayStationId, subwayLine: $subwayLine, priceRange: $minPrice-$maxPrice",
    );

    // Debug logging to see what will be passed to HomeScreen
    logger.d(
      "SearchBottomSheet._performSearch - Will create HomeScreen with subwayLineId: $subwayLine, priceRange: $minPrice-$maxPrice",
    );

    // Navigate to home screen with search parameters
    Navigator.pop(context);

    if (widget.replaceCurrentRoute) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => ListingsBloc(getIt<IListingService>()),
                child: HomeScreen(
                  listingTypeId: listingTypeId,
                  locationId: locationId,
                  subwayStationId: subwayStationId,
                  subwayLineId: subwayLine,
                  gender: gender > 0 ? gender : null,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  privateRoom: privateRoom,
                  withPhoto: withPhoto,
                  isSearchMode: true,
                ),
              ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create: (context) => ListingsBloc(getIt<IListingService>()),
                child: HomeScreen(
                  listingTypeId: listingTypeId,
                  locationId: locationId,
                  subwayStationId: subwayStationId,
                  subwayLineId: subwayLine,
                  gender: gender > 0 ? gender : null,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  privateRoom: privateRoom,
                  withPhoto: withPhoto,
                  isSearchMode: true,
                ),
              ),
        ),
      );
    }
  }

  /// Builds a RichText widget that supports bold formatting for the explanation text
  Widget _buildRichTextExplanation(BuildContext context, ThemeData theme) {
    final explanationText = L10n.get("all_stations_explanation")
        .replaceAll("{count}", "${_currentStations.length}")
        .replaceAll(
          "{line}",
          MetroCache.getLineName(
            _searchFiltersState.selectedSubwayLine,
            LanguageState().currentLanguage,
          ),
        );

    // Parse the text and create TextSpans for bold formatting
    final spans = <TextSpan>[];
    final boldRegex = RegExp("<b>(.*?)</b>");
    var lastIndex = 0;

    for (final Match match in boldRegex.allMatches(explanationText)) {
      // Add text before the bold tag
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: explanationText.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.normal,
            ),
          ),
        );
      }

      // Add bold and underlined text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
            decorationThickness: 1.0,
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after the last bold tag
    if (lastIndex < explanationText.length) {
      spans.add(
        TextSpan(
          text: explanationText.substring(lastIndex),
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.normal,
          ),
        ),
      );
    }

    return AnimatedOpacity(
      opacity: _isBlinking ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: RichText(
        text: TextSpan(children: spans),
        textAlign: TextAlign.center,
      ),
    );
  }
}
