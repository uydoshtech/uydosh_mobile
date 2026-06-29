part of "package:uy_dosh/presentation/widgets/search_bottom_sheet.dart";

class _SearchBottomSheetContentState extends State<_SearchBottomSheetContent> {
  final SearchFiltersState _searchFiltersState = SearchFiltersState();
  final GlobalKey<TutorialTargetWrapperState> _metroLineTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();
  final GlobalKey<TutorialTargetWrapperState> _metroStationTutorialKey =
      GlobalKey<TutorialTargetWrapperState>();
  List<SubwayStation> _currentStations = [];
  FixedExtentScrollController? _stationPickerController;
  FixedExtentScrollController? _metroLineScrollController;
  FixedExtentScrollController? _locationScrollController;
  bool _metroLineChangedInThisSession = false;
  bool _isCreatingSearchAlert = false;
  int _searchAlertCelebrationTick = 0;
  bool _showDeferredSections = false;

  @override
  void initState() {
    super.initState();

    _stationPickerController = FixedExtentScrollController();
    _metroLineScrollController = FixedExtentScrollController(
      initialItem:
          widget.currentSubwayLineId ?? _searchFiltersState.selectedSubwayLine,
    );
    _locationScrollController = FixedExtentScrollController();

    _searchFiltersState.seedFromSheetOpenParams(
      listingTypeId: widget.currentListingTypeId,
      // `null` means "no district filter" — coalesce so we clear any stale
      // singleton location instead of skipping the seed (map passes null).
      locationId: widget.metroOnly ? null : (widget.currentLocationId ?? 0),
      subwayLineId: widget.currentSubwayLineId,
      subwayStationId: widget.currentSubwayStationId,
      subwayStationIds: widget.currentSubwayStationIds,
      gender: widget.currentGender,
      minPrice: widget.currentMinPrice,
      maxPrice: widget.currentMaxPrice,
      privateRoom: widget.currentPrivateRoom,
      withPhoto: widget.currentWithPhoto,
    );

    if (_searchFiltersState.selectedSubwayLine > 0) {
      _onStationsLoaded(
        MetroCache.getStationsForLine(_searchFiltersState.selectedSubwayLine),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showDeferredSections = true);
    });

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
      getStationCount: () => _searchFiltersState.selectedSubwayLine == 4 &&
              _currentStations.isNotEmpty
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
    setStateIfMounted(() {
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

  Future<void> _addAlertFromCurrentSearch() async {
    if (!AuthFlow.requireAuth(context)) return;

    final locationId = _getSelectedLocationId();
    final stationIds = _searchFiltersState.selectedStationIdsList;
    final subwayStationId = stationIds.length == 1
        ? stationIds.first
        : _getSelectedSubwayStationId();
    final hasStationFilter = stationIds.isNotEmpty ||
        (subwayStationId != null && subwayStationId > 0);
    final subwayLineId =
        hasStationFilter && _searchFiltersState.selectedSubwayLine > 0
            ? _searchFiltersState.selectedSubwayLine
            : null;

    final hasAnyLocationConstraint = (locationId != null && locationId > 0) ||
        (subwayLineId != null && subwayLineId > 0) ||
        stationIds.isNotEmpty ||
        (subwayStationId != null && subwayStationId > 0);
    if (!hasAnyLocationConstraint) {
      ToastTheme.showError(context, message: L10n.get("search_alert_too_wide"));
      return;
    }

    setState(() => _isCreatingSearchAlert = true);
    try {
      final err =
          await getIt<ISearchAlertService>().createAlertForCurrentSearch(
        listingTypeId: _searchFiltersState.selectedListingTypeId,
        locationId: locationId,
        subwayStationId: stationIds.length > 1 ? null : subwayStationId,
        subwayStationIds: stationIds.length > 1 ? stationIds : null,
        subwayLineId: subwayLineId,
        gender: _searchFiltersState.selectedGender,
        minPrice: _searchFiltersState.minPrice,
        maxPrice: _searchFiltersState.maxPrice,
        privateRoomOnly: _searchFiltersState.privateRoom,
        withPhotoOnly: _searchFiltersState.withPhoto,
      );

      if (!mounted) return;

      if (err != null) {
        if (err == SearchAlertService.alreadyExistsErrorToken) {
          ToastTheme.showWarning(context,
              message: L10n.get("search_alert_already_exists"),
              leadingIcon: Icons.notifications_active_outlined);
        } else {
          ToastTheme.showError(
            context,
            message: err == "error" ? L10n.get("search_alert_failed") : err,
          );
        }
        return;
      }

      if (mounted) {
        setState(() => _searchAlertCelebrationTick++);
      }

      await ActiveSearchAlertsState().refresh();

      // Ensure notifications are enabled. The gate surfaces our rationale
      // screen before any OS prompt so the user understands why we want
      // the permission (without it the search alert can never reach them),
      // and falls back to a Settings deep-link when permission was
      // previously denied.
      if (getIt<IPushNotificationService>().isSupported) {
        final ok = await NotificationPermissionGate.ensure(context);
        if (!mounted) return;
        if (!ok) {
          ToastTheme.showWarning(context,
              message: L10n.get("search_alert_permission"));
        }
      }

      ToastTheme.showSuccess(context,
          message: L10n.get("search_alert_created"));
    } finally {
      if (mounted) setState(() => _isCreatingSearchAlert = false);
    }
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

    void resetStationWheelToZero() {
      final ctrl = _stationPickerController;
      if (!mounted || ctrl == null || !ctrl.hasClients) return;
      if (ctrl.selectedItem != 0) {
        logger.d("DEBUG: Metro line changed, resetting station wheel to 0");
        ctrl.jumpToItem(0);
      }
    }

    // When changing metro lines, force station wheel to 0.
    // The controller may temporarily have no clients during rebuilds.
    resetStationWheelToZero();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resetStationWheelToZero();
    });

    _onStationsLoaded(MetroCache.getStationsForLine(line));
  }

  /// Resets the location picker to its initial state (no location selected)
  /// and forces a rebuild of the wheel pickers to ensure proper visual reset
  void _resetLocationPicker() {
    setState(() {
      _searchFiltersState.setLocationIndex(0);
    });
  }

  void _resetMetroPicker() {
    final hasMetroSelection = _searchFiltersState.selectedSubwayLine > 0 ||
        _searchFiltersState.selectedStationIndex > 0 ||
        _searchFiltersState.selectedStationId > 0 ||
        _searchFiltersState.selectedStationIdsList.isNotEmpty ||
        _currentStations.isNotEmpty;
    if (!hasMetroSelection) return;

    setState(() {
      _currentStations = [];
      unawaited(_searchFiltersState.setSubwayLine(0));
      unawaited(_searchFiltersState.setStationIndex(0));
      unawaited(_searchFiltersState.setStationId(0));
      unawaited(_searchFiltersState.setStationIds(const []));
    });

    final metroController = _metroLineScrollController;
    if (metroController != null &&
        metroController.hasClients &&
        metroController.selectedItem != 0) {
      metroController.animateToItem(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }

    final stationController = _stationPickerController;
    if (stationController != null &&
        stationController.hasClients &&
        stationController.selectedItem != 0) {
      stationController.jumpToItem(0);
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
    if (_searchFiltersState.selectedSubwayLine <= 0) {
      return;
    }
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

      // If user changed metro line while this sheet is open, never restore a
      // previously-selected station. Always keep the wheel at item 0 ("Select station").
      if (_metroLineChangedInThisSession) {
        _searchFiltersState.setStationIndex(0);
        _searchFiltersState.setStationId(0);
        logger.d(
          "DEBUG: Metro line changed in-session; forcing station reset to 0",
        );
        return;
      }

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
    final mq = MediaQuery.of(context);
    // Cap the glass sheet while letting it shrink to the actual filter content.
    final maxSheetHeight = (mq.size.height - mq.viewInsets.bottom) * 0.9;
    final radius = const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      child: GlassBottomSheetSurface(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Search header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  ThemeIcon(
                    Icons.search,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      L10n.get(
                        "search_listings",
                      ),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: _isCreatingSearchAlert ? 0.55 : 1,
                    child: NotifySearchAlertAppBarButton(
                      tooltip: L10n.get("search_alert_notify_me"),
                      enabled: !_isCreatingSearchAlert,
                      celebrationTick: _searchAlertCelebrationTick,
                      onPressed: () {
                        if (_isCreatingSearchAlert) return;
                        unawaited(_addAlertFromCurrentSearch());
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ThreeDAppBarIconButton(
                    iconData: Icons.close,
                    onPressed: () => Navigator.pop(context),
                    semanticsLabel:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
                  ),
                ],
              ),
            ),

            // Search filters
            Padding(
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

                  if (!widget.metroOnly) ...[
                    // Location filter - Wheel Picker
                    RepaintBoundary(
                      child: SearchBottomSheetLocationSection(
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
                        onMetroReset: _resetMetroPicker,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Metro Line and Station Selection - Side by Side Wheel Pickers
                  RepaintBoundary(
                    child: SearchBottomSheetMetroSection(
                      searchFiltersState: _searchFiltersState,
                      currentStations: _currentStations,
                      metroLineScrollController: _metroLineScrollController,
                      stationPickerController: _stationPickerController,
                      metroLineTutorialKey: _metroLineTutorialKey,
                      metroStationTutorialKey: _metroStationTutorialKey,
                      getLocalizedName: _getLocalizedName,
                      onSubwayLineChanged: (index) {
                        _metroLineChangedInThisSession = true;
                        // Location and metro now coexist; changing the line no
                        // longer resets the chosen district.
                        setState(() {
                          _searchFiltersState.setSubwayLine(index);
                        });
                        if (index > 0) {
                          _loadStationsForLine(index);
                        } else {
                          setState(() {
                            _currentStations = [];
                            _searchFiltersState.setStationIndex(0);
                          });
                        }
                      },
                      onStationChanged: (index) {},
                      onStationsSelected: (stationIds) {
                        setState(() {
                          _searchFiltersState.setStationIds(stationIds);
                          if (stationIds.isNotEmpty &&
                              _searchFiltersState.selectedLocationIndex > 0) {
                            _searchFiltersState.setLocationIndex(0);
                          }
                        });
                        if (stationIds.isNotEmpty) {
                          final locationCtrl = _locationScrollController;
                          if (locationCtrl != null &&
                              locationCtrl.hasClients &&
                              locationCtrl.selectedItem != 0) {
                            locationCtrl.jumpToItem(0);
                          }
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_showDeferredSections)
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
                      onPrimaryPressed: () => _performSearch(
                        action: widget.primaryAction,
                      ),
                      primaryLabelKey: widget.primaryLabelKey,
                      primaryIcon: widget.primaryIcon,
                    )
                  else
                    const SizedBox(height: 88),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch({
    SearchBottomSheetAction action = SearchBottomSheetAction.feed,
  }) {
    HapticFeedbackUtils.impact();

    if (widget.commitFiltersOnApply) {
      // Tell SearchBottomSheetWidget.show() to commit the in-session edits.
      // Must happen BEFORE Navigator.pop so the show() caller (which awaits
      // the modal future) sees a true flag when the future resolves.
      widget.onCommit?.call();
    }

    // Get all current filter values
    final listingTypeId = _searchFiltersState.selectedListingTypeId;
    final subwayStationIds = _searchFiltersState.selectedStationIdsList;
    final subwayStationId = subwayStationIds.length == 1
        ? subwayStationIds.first
        : _getSelectedSubwayStationId();
    final subwayLine = _searchFiltersState.selectedSubwayLine;
    final hasStationFilter = subwayStationIds.isNotEmpty ||
        (subwayStationId != null && subwayStationId > 0);
    // Location and metro are mutually exclusive in search results; when the
    // user picks a station, drop any district filter so reopening the sheet
    // does not resurrect a stale location.
    final locationId =
        hasStationFilter ? null : _getSelectedLocationId();
    if (hasStationFilter && _searchFiltersState.selectedLocationIndex > 0) {
      _searchFiltersState.setLocationIndex(0);
    }
    final effectiveSubwayLineId =
        hasStationFilter && subwayLine > 0 ? subwayLine : null;
    final gender = _searchFiltersState.selectedGender;
    final minPrice = _searchFiltersState.minPrice;
    final maxPrice = _searchFiltersState.maxPrice;
    final privateRoom = _searchFiltersState.privateRoom;
    final withPhoto = _searchFiltersState.withPhoto;

    // Debug logging to see what values are being passed
    logger.d(
      "SearchBottomSheet._performSearch - subwayStationId: $subwayStationId, subwayLine: $effectiveSubwayLineId, priceRange: $minPrice-$maxPrice",
    );

    // Debug logging to see what will be passed to HomeScreen
    logger.d(
      "SearchBottomSheet._performSearch - Will create HomeScreen with subwayLineId: $effectiveSubwayLineId, priceRange: $minPrice-$maxPrice",
    );

    // Navigate to home screen with search parameters
    Navigator.pop(context);

    final apply = widget.onApply;
    if (apply != null) {
      apply(
        SearchBottomSheetResult(
          listingTypeId: listingTypeId,
          gender: gender > 0 ? gender : null,
          locationId: locationId,
          subwayStationId: subwayStationId,
          subwayStationIds: subwayStationIds,
          subwayLineId: effectiveSubwayLineId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          privateRoom: privateRoom,
          withPhoto: withPhoto,
          action: action,
        ),
      );
      return;
    }

    if (action == SearchBottomSheetAction.map) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => ListingsBloc(getIt<IListingService>()),
            child: HomeScreen(
              listingTypeId: listingTypeId,
              locationId: locationId,
              subwayStationId: subwayStationId,
              subwayStationIds: subwayStationIds,
              subwayLineId: effectiveSubwayLineId,
              gender: gender > 0 ? gender : null,
              minPrice: minPrice,
              maxPrice: maxPrice,
              privateRoom: privateRoom,
              withPhoto: withPhoto,
              isSearchMode: true,
              useExplicitFiltersOnly: true,
              isHomeTabActive: false,
              showMapInitially: true,
            ),
          ),
        ),
      );
    } else if (widget.replaceCurrentRoute) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => ListingsBloc(getIt<IListingService>()),
            child: HomeScreen(
              listingTypeId: listingTypeId,
              locationId: locationId,
              subwayStationId: subwayStationId,
              subwayStationIds: subwayStationIds,
              subwayLineId: effectiveSubwayLineId,
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
          builder: (context) => BlocProvider(
            create: (context) => ListingsBloc(getIt<IListingService>()),
            child: HomeScreen(
              listingTypeId: listingTypeId,
              locationId: locationId,
              subwayStationId: subwayStationId,
              subwayStationIds: subwayStationIds,
              subwayLineId: effectiveSubwayLineId,
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
}

/// Returns a 4x5 color matrix that scales the saturation of a source image
/// around its luminance. Values > 1 boost saturation (Apple "vibrancy"
/// effect), 1.0 is identity, 0.0 produces grayscale.
///
/// Standard Rec. 601 luminance weights are used: 0.2126 R, 0.7152 G,
/// 0.0722 B.
