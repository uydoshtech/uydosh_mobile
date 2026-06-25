import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/tooltips_state.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_hint_bubble.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/tooltip_fade.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";
import "package:uy_dosh/presentation/widgets/search_bottom_sheet/search_bottom_sheet_hints_config.dart";
import "package:uy_dosh/presentation/widgets/tutorial/metro_tutorial_overlay.dart";
import "package:uy_dosh/presentation/widgets/tutorial/search_tutorial_overlay.dart";

/// Metro line and station pickers section for the search bottom sheet.
class SearchBottomSheetMetroSection extends StatefulWidget {
  const SearchBottomSheetMetroSection({
    required this.searchFiltersState,
    required this.currentStations,
    required this.metroLineScrollController,
    required this.stationPickerController,
    required this.onSubwayLineChanged,
    required this.onStationChanged,
    required this.onStationsSelected,
    required this.metroLineTutorialKey,
    required this.metroStationTutorialKey,
    required this.getLocalizedName,
    super.key,
  });

  final SearchFiltersState searchFiltersState;
  final List<SubwayStation> currentStations;
  final FixedExtentScrollController? metroLineScrollController;
  final FixedExtentScrollController? stationPickerController;
  final void Function(int index) onSubwayLineChanged;
  final void Function(int index) onStationChanged;

  /// Multi-station selection callback. Receives the full set of selected
  /// station ids (across all lines) whenever the user toggles a station or the
  /// per-line "select all" control.
  final void Function(List<int> stationIds) onStationsSelected;
  final GlobalKey<TutorialTargetWrapperState> metroLineTutorialKey;
  final GlobalKey<TutorialTargetWrapperState> metroStationTutorialKey;
  final String Function({String? nameUz, String? nameRu, String? nameEn})
      getLocalizedName;

  @override
  State<SearchBottomSheetMetroSection> createState() =>
      _SearchBottomSheetMetroSectionState();
}

class _SearchBottomSheetMetroSectionState
    extends State<SearchBottomSheetMetroSection> {
  static const double _stationListItemExtent = 40;

  /// User-dismissed flag for the "search across all stations of line X" hint.
  /// Loaded from SharedPreferences so the dismissal survives across sheet
  /// re-openings and app restarts. Until prefs resolve we keep the hint
  /// hidden to avoid a flicker where it briefly shows then disappears.
  bool _allStationsHintDismissed = true;

  /// Debounce gate for the all-stations hint. Cycling through metro lines
  /// reloads stations in rapid succession; without a settle delay the hint
  /// would flicker on/off and visibly jerk the layout. We only flip this
  /// to `true` after the user has paused on a line for [_hintDebounceDelay].
  bool _hintDebounceSettled = false;
  Timer? _hintDebounceTimer;
  int _lastSeenLine = 0;
  static const Duration _hintDebounceDelay = Duration(milliseconds: 1000);

  /// Floats [NeumorphicHintBubble] above the station wheel via [OverlayPortal]
  /// — does not inflate the bottom sheet scroll area (when inline mode is off).
  final OverlayPortalController _metroAllStationsHintPortalController =
      OverlayPortalController();
  final ScrollController _stationListScrollController = ScrollController();

  static Color _getLineColor(int line) => AppColors.getMetroLineColor(line);

  @override
  void initState() {
    super.initState();
    _loadAllStationsHintDismissed();
    TooltipsState().addListener(_onTooltipsStateChanged);
    _lastSeenLine = widget.searchFiltersState.selectedSubwayLine;
    _scheduleHintDebounce(_lastSeenLine);
    _scheduleScrollSelectedStationToTop(jump: true);
  }

  @override
  void didUpdateWidget(covariant SearchBottomSheetMetroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentLine = widget.searchFiltersState.selectedSubwayLine;
    if (currentLine != _lastSeenLine) {
      _lastSeenLine = currentLine;
      _scheduleHintDebounce(currentLine);
    }
    _scheduleScrollSelectedStationToTop();

    // After the async station list mounts, [OverlayChildLayoutInfo] may need a
    // second frame before the paint transform is usable.
    final stationsArrived = oldWidget.currentStations.isEmpty &&
        widget.currentStations.isNotEmpty &&
        currentLine > 0 &&
        widget.searchFiltersState.selectedStationId == 0;
    if (stationsArrived &&
        !SearchBottomSheetHintsConfig.metroAllStationsHintUsesInlineColumn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncMetroAllStationsHintPortal();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _syncMetroAllStationsHintPortal();
        });
      });
    }
  }

  @override
  void dispose() {
    if (_metroAllStationsHintPortalController.isShowing) {
      _metroAllStationsHintPortalController.hide();
    }
    _hintDebounceTimer?.cancel();
    TooltipsState().removeListener(_onTooltipsStateChanged);
    _stationListScrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollSelectedStationToTop({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_stationListScrollController.hasClients) return;

      final selected = widget.searchFiltersState.selectedStationIdsList.toSet();
      final selectedIndex = widget.currentStations.indexWhere(
        (station) => selected.contains(station.id),
      );
      if (selectedIndex < 0) return;

      final position = _stationListScrollController.position;
      final targetOffset = (selectedIndex * _stationListItemExtent)
          .clamp(position.minScrollExtent, position.maxScrollExtent)
          .toDouble();

      if ((position.pixels - targetOffset).abs() < 0.5) return;

      if (jump) {
        _stationListScrollController.jumpTo(targetOffset);
        return;
      }

      _stationListScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// Restart the debounce window every time the user changes metro lines so
  /// rapid cycling doesn't surface the hint mid-scroll. When [line] is 0 the
  /// hint can never show, so we just clear the gate immediately.
  void _scheduleHintDebounce(int line) {
    _hintDebounceTimer?.cancel();
    if (_hintDebounceSettled) {
      setStateIfMounted(() => _hintDebounceSettled = false);
    }
    if (line <= 0) return;
    _hintDebounceTimer = Timer(_hintDebounceDelay, () {
      if (!mounted) return;
      setState(() => _hintDebounceSettled = true);
    });
  }

  void _onTooltipsStateChanged() {
    if (!mounted) return;
    _loadAllStationsHintDismissed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncMetroAllStationsHintPortal();
    });
    setStateIfMounted(() {});
  }

  /// Show or hide [OverlayPortal] — call from post-frame only.
  void _syncMetroAllStationsHintPortal() {
    if (!mounted) return;
    if (SearchBottomSheetHintsConfig.metroAllStationsHintUsesInlineColumn) {
      if (_metroAllStationsHintPortalController.isShowing) {
        _metroAllStationsHintPortalController.hide();
      }
      return;
    }
    if (_shouldShowHint) {
      _metroAllStationsHintPortalController.show();
    } else {
      if (_metroAllStationsHintPortalController.isShowing) {
        _metroAllStationsHintPortalController.hide();
      }
    }
  }

  Widget _buildMetroAllStationsHintPortalOverlay(
    BuildContext context,
    OverlayChildLayoutInfo layoutInfo,
  ) {
    if (!_shouldShowHint) {
      return const SizedBox.shrink();
    }

    final t = layoutInfo.childPaintTransform;
    final det = t.determinant();
    if (det == 0.0 || det.isNaN) {
      return const SizedBox.shrink();
    }

    final anchorTopCenter = MatrixUtils.transformPoint(
      t,
      Offset(layoutInfo.childSize.width / 2, 0),
    );

    final theme = Theme.of(context);
    final viewInsetsBottom = MediaQuery.maybeViewInsetsOf(context)?.bottom ?? 0;

    return Positioned.fill(
      bottom: viewInsetsBottom,
      child: CustomSingleChildLayout(
        delegate: _MetroAllStationsHintLayoutDelegate(
          anchorTopCenterInOverlay: anchorTopCenter,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: NeumorphicHintBubble(
              maxWidth: 280,
              tailSide: HintBubbleTailSide.bottom,
              tailHorizontalOffset: 0,
              message: _buildHintSpan(context, theme),
              onClose: _dismissAllStationsHint,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadAllStationsHintDismissed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed =
          prefs.getBool(TooltipsState.keyMetroAllStationsHintDismissed) ??
              false;
      setStateIfMounted(() => _allStationsHintDismissed = dismissed);
    } catch (_) {
      // If prefs are unavailable, keep the hint hidden by default.
    }
  }

  Future<void> _dismissAllStationsHint() async {
    setStateIfMounted(() => _allStationsHintDismissed = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncMetroAllStationsHintPortal();
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        TooltipsState.keyMetroAllStationsHintDismissed,
        true,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!SearchBottomSheetHintsConfig.metroAllStationsHintUsesInlineColumn) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncMetroAllStationsHintPortal();
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (SearchBottomSheetHintsConfig.metroAllStationsHintUsesInlineColumn)
          TooltipFade(
            visible: _shouldShowHint,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 8, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(child: SizedBox.shrink()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: NeumorphicHintBubble(
                        message: _buildHintSpan(context, theme),
                        onClose: _dismissAllStationsHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        _buildPickersRow(context, theme),
      ],
    );
  }

  Widget _buildPickersRow(BuildContext context, ThemeData theme) {
    final language = LanguageState().currentLanguage;
    final selectedStationIds =
        widget.searchFiltersState.selectedStationIdsList.toSet();
    final lineLabels = MetroCache.getAvailableLines().map((line) {
      final lineName = MetroCache.getLineName(line, language);
      final selectedCount = MetroCache.getStationsForLine(line)
          .where((station) => selectedStationIds.contains(station.id))
          .length;
      final label = selectedCount > 0 ? "$lineName [$selectedCount]" : lineName;
      return MapEntry(line, label);
    }).toList();

    return Row(
      children: [
        Expanded(
          child: TutorialTargetWrapper(
            key: widget.metroLineTutorialKey,
            child: LiquidGlassPlate(
              height: 80,
              borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      backgroundColor: Colors.transparent,
                      changeReportingBehavior:
                          ChangeReportingBehavior.onScrollEnd,
                      itemExtent: 40,
                      scrollController: widget.metroLineScrollController,
                      onSelectedItemChanged: (index) {
                        SendSoundUtils.playCupertinoWheelSound();
                        widget.onSubwayLineChanged(index);
                      },
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MLetterIcon(
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  L10n.get("select_metro_line"),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeState().isBlueTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...(lineLabels.map(
                          (lineEntry) => Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MLetterIcon(
                                  color: _getLineColor(lineEntry.key),
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    lineEntry.value,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _wrapStationPickerWithHintAnchor(
            TutorialTargetWrapper(
              key: widget.metroStationTutorialKey,
              // Smoothly grow/shrink the plate (80 -> 220) when a line is
              // selected/cleared instead of snapping to the new height.
              child: AnimatedSize(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: widget.searchFiltersState.selectedSubwayLine > 0 &&
                        widget.currentStations.isNotEmpty
                    ? _buildMetroStationPicker(context, theme)
                    : _buildMetroStationPlaceholder(context, theme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// [OverlayPortal] floats the hint above wheels when inline flag is false.
  Widget _wrapStationPickerWithHintAnchor(Widget child) {
    if (SearchBottomSheetHintsConfig.metroAllStationsHintUsesInlineColumn) {
      return child;
    }
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _metroAllStationsHintPortalController,
      overlayLocation: OverlayChildLocation.nearestOverlay,
      overlayChildBuilder: _buildMetroAllStationsHintPortalOverlay,
      child: child,
    );
  }

  bool get _shouldShowHint =>
      // Suppress entirely while the metro coach-mark tutorial is on screen so
      // the bubble doesn't fight for attention with the spotlight overlay.
      !MetroTutorialOverlay.isActive &&
      // Honor the global tooltips toggle (Settings > Tips).
      TooltipsState().enabled &&
      // Respect per-tip dismissal (small "x" in the bubble corner).
      !_allStationsHintDismissed &&
      // Only surface after the user has settled on a line (debounced) so the
      // bubble doesn't strobe in/out while they cycle through lines.
      _hintDebounceSettled &&
      widget.searchFiltersState.selectedSubwayLine > 0 &&
      widget.searchFiltersState.selectedStationIdsList.isEmpty &&
      widget.currentStations.isNotEmpty;

  TextSpan _buildHintSpan(BuildContext context, ThemeData _) {
    final raw = L10n.get("all_stations_explanation")
        .replaceAll("{count}", "${widget.currentStations.length}")
        .replaceAll(
          "{line}",
          MetroCache.getLineLabel(
            widget.searchFiltersState.selectedSubwayLine,
            LanguageState().currentLanguage,
          ),
        );

    const baseStyle = TextStyle(
      fontSize: 14.5,
      height: 1.3,
      color: Colors.black,
    );
    final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.w700);

    final spans = <TextSpan>[];
    final boldRegex = RegExp("<b>(.*?)</b>");
    var lastIndex = 0;
    for (final Match match in boldRegex.allMatches(raw)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: raw.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      spans.add(TextSpan(text: match.group(1), style: boldStyle));
      lastIndex = match.end;
    }
    if (lastIndex < raw.length) {
      spans.add(TextSpan(text: raw.substring(lastIndex), style: baseStyle));
    }
    return TextSpan(children: spans);
  }

  Widget _buildMetroStationPicker(BuildContext context, ThemeData theme) {
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;
    final selected = widget.searchFiltersState.selectedStationIdsList.toSet();
    final lineStationIds =
        widget.currentStations.map((station) => station.id).toList();
    final allSelected =
        lineStationIds.isNotEmpty && lineStationIds.every(selected.contains);
    final lineColor = widget.searchFiltersState.selectedSubwayLine > 0
        ? _getLineColor(widget.searchFiltersState.selectedSubwayLine)
        : theme.colorScheme.onSurfaceVariant;

    void emit(Set<int> next) {
      final list = next.toList()..sort();
      widget.onStationsSelected(list);
    }

    void toggleStation(int id) {
      final next = {...selected};
      if (!next.remove(id)) next.add(id);
      emit(next);
    }

    void toggleAllOnLine() {
      final next = {...selected};
      if (allSelected) {
        next.removeAll(lineStationIds);
      } else {
        next.addAll(lineStationIds);
      }
      emit(next);
    }

    Widget checkbox(bool value, Color color) => ThemeIcon(
          value ? Icons.check_box : Icons.check_box_outline_blank,
          color: value ? color : textColor.withValues(alpha: 0.5),
          size: 22,
        );

    return LiquidGlassPlate(
      height: 220,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      child: Column(
        children: [
          // "Select all on this line" toggle — populates the selection with
          // every station of the current line (whole-line search).
          InkWell(
            onTap: toggleAllOnLine,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  checkbox(allSelected, lineColor),
                  const SizedBox(width: 8),
                  ThemeIcon(Icons.train, color: lineColor, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      L10n.plural(
                        "all_stations_count",
                        widget.currentStations.length,
                      ),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: textColor.withValues(alpha: 0.12)),
          Expanded(
            child: ListView.builder(
              controller: _stationListScrollController,
              itemExtent: _stationListItemExtent,
              padding: EdgeInsets.zero,
              itemCount: widget.currentStations.length,
              itemBuilder: (context, index) {
                final station = widget.currentStations[index];
                final isSelected = selected.contains(station.id);
                final transferInfo =
                    MetroCache.getTransferStationInfo(station.id);
                return InkWell(
                  onTap: () {
                    SendSoundUtils.playCupertinoWheelSound();
                    toggleStation(station.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        checkbox(isSelected, _getLineColor(station.line)),
                        const SizedBox(width: 8),
                        ThemeIcon(
                          Icons.train,
                          color: _getLineColor(station.line),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            MetroCache.getStationName(
                              station,
                              LanguageState().currentLanguage,
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (transferInfo != null) ...[
                          const SizedBox(width: 4),
                          ThemeIcon(
                            Icons.train,
                            color: _getLineColor(
                              transferInfo["connectedStationLine"],
                            ),
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetroStationPlaceholder(BuildContext context, ThemeData theme) {
    return LiquidGlassPlate(
      height: 80,
      borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
      child: Center(
        child: Text(
          L10n.get("select_metro_line_title"),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ThemeState().isBlueTheme ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

/// Anchors “all stations” hint bubble just above top-center of the metro
/// station [OverlayPortal] child (coordinates are in overlay space).
class _MetroAllStationsHintLayoutDelegate extends SingleChildLayoutDelegate {
  const _MetroAllStationsHintLayoutDelegate({
    required this.anchorTopCenterInOverlay,
  });

  final Offset anchorTopCenterInOverlay;

  static const double _gapAboveTargetPx = 6;
  static const double _horizontalMarginPx = 8;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      minWidth: 0,
      minHeight: 0,
      maxWidth: constraints.maxWidth,
      maxHeight: constraints.maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double dxDesired = anchorTopCenterInOverlay.dx - childSize.width / 2;
    final double leftBound = _horizontalMarginPx;
    final double rightBoundCandidate =
        size.width - childSize.width - _horizontalMarginPx;
    final double rightBound =
        rightBoundCandidate < leftBound ? leftBound : rightBoundCandidate;
    final dx = dxDesired.clamp(leftBound, rightBound);
    final dy =
        anchorTopCenterInOverlay.dy - childSize.height - _gapAboveTargetPx;
    return Offset(dx, dy);
  }

  @override
  bool shouldRelayout(
          covariant _MetroAllStationsHintLayoutDelegate oldDelegate) =>
      anchorTopCenterInOverlay != oldDelegate.anchorTopCenterInOverlay;
}
