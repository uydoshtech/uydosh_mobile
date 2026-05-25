import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/presentation/widgets/common/index.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";

/// Metro line and station selection for create/edit listing forms.
/// Displays side-by-side pickers for line (optional) and station.
class ListingFormMetroSection extends StatefulWidget {
  const ListingFormMetroSection({
    required this.selectedSubwayLine,
    required this.selectedStationIndex,
    required this.currentStations,
    required this.isLoadingStations,
    required this.metroLineScrollController,
    required this.metroStationScrollController,
    required this.onLineChanged,
    required this.onStationChanged,
    required this.onDismissKeyboard,
    this.embeddedInPlate = false,
    super.key,
  });

  final bool embeddedInPlate;
  final int selectedSubwayLine;
  final int selectedStationIndex;
  final List<SubwayStation> currentStations;
  final bool isLoadingStations;
  final FixedExtentScrollController? metroLineScrollController;
  final FixedExtentScrollController? metroStationScrollController;
  final void Function(int lineIndex) onLineChanged;
  final void Function(int stationIndex) onStationChanged;
  final VoidCallback onDismissKeyboard;

  @override
  State<ListingFormMetroSection> createState() =>
      _ListingFormMetroSectionState();
}

class _ListingFormMetroSectionState extends State<ListingFormMetroSection> {
  static Color _getLineColor(int line) => AppColors.getMetroLineColor(line);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPickerScrollPositions();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncPickerScrollPositions();
      });
    });
  }

  @override
  void didUpdateWidget(covariant ListingFormMetroSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSubwayLine != widget.selectedSubwayLine ||
        oldWidget.selectedStationIndex != widget.selectedStationIndex ||
        oldWidget.currentStations.length != widget.currentStations.length ||
        oldWidget.isLoadingStations != widget.isLoadingStations) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _syncPickerScrollPositions();
      });
    }
  }

  /// Parent-owned controllers can lose their scroll position when pickers are
  /// removed from the tree (e.g. collapsible geo tile); realign on mount.
  void _syncPickerScrollPositions() {
    if (!mounted) return;

    final lineCtrl = widget.metroLineScrollController;
    if (lineCtrl != null && lineCtrl.hasClients) {
      final targetLine = widget.selectedSubwayLine;
      if (lineCtrl.selectedItem != targetLine) {
        lineCtrl.jumpToItem(targetLine);
      }
    }

    final stationCtrl = widget.metroStationScrollController;
    if (stationCtrl != null &&
        stationCtrl.hasClients &&
        widget.selectedSubwayLine > 0 &&
        !widget.isLoadingStations &&
        widget.currentStations.isNotEmpty) {
      final maxIndex = widget.currentStations.length - 1;
      final targetStation = widget.selectedStationIndex.clamp(0, maxIndex);
      if (stationCtrl.selectedItem != targetStation) {
        stationCtrl.jumpToItem(targetStation);
      }
    }
  }

  BoxDecoration _pickerDecoration(BuildContext context) {
    if (widget.embeddedInPlate) {
      return ThreeDSurfaceStyle.wheelPickerInsetDecoration(context);
    }
    return ThreeDSurfaceStyle.wheelPickerPlateDecoration(
      context,
      theme: Theme.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LabeledFieldOverlay(
            label: L10n.get("select_metro_line_optional"),
            child: _buildLinePicker(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LabeledFieldOverlay(
            label: L10n.get("metro_station_label"),
            child: _buildStationPicker(context),
          ),
        ),
      ],
    );
  }

  Widget _buildLinePicker(BuildContext context) {
    return Container(
      decoration: _pickerDecoration(context),
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              backgroundColor: Colors.transparent,
              changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
              itemExtent: 40,
              scrollController: widget.metroLineScrollController,
              onSelectedItemChanged: (index) {
                widget.onDismissKeyboard();
                SendSoundUtils.playCupertinoWheelSound();
                widget.onLineChanged(index);
              },
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MLetterIcon(color: Colors.black, size: 20),
                      const SizedBox(width: 6),
                      Flexible(
                        child: L10n.text(
                          "select_metro_line_optional",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ThemeState().isLightTheme
                                ? Colors.black.withOpacity(0.7)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ...([1, 2, 3, 4].map((line) {
                  final name =
                      MetroCache.getLineName(line, L10n.currentLanguage);
                  return Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MLetterIcon(color: _getLineColor(line), size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ThemeState().isLightTheme
                                  ? Colors.black
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                })),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationPicker(BuildContext context) {
    if (widget.selectedSubwayLine <= 0) {
      return _buildStationPlaceholder(
        context,
        text: L10n.get("select_metro_line_title"),
      );
    }

    if (widget.isLoadingStations) {
      return _buildStationPlaceholder(
        context,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              L10n.get("loading"),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ThemeState().isLightTheme
                    ? Colors.black.withOpacity(0.7)
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.currentStations.isEmpty) {
      return _buildStationPlaceholder(
        context,
        text: L10n.get("select_metro_line_title"),
      );
    }

    if (widget.currentStations.isNotEmpty) {
      return Container(
        decoration: _pickerDecoration(context),
        height: 80,
        child: Row(
          children: [
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.transparent,
                changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
                itemExtent: 40,
                scrollController: widget.metroStationScrollController,
                onSelectedItemChanged: (index) {
                  widget.onDismissKeyboard();
                  SendSoundUtils.playCupertinoWheelSound();
                  widget.onStationChanged(index);
                },
                children: widget.currentStations
                    .map(
                      (station) {
                        final transferInfo =
                            MetroCache.getTransferStationInfo(station.id);
                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ThemeIcon(
                                Icons.train,
                                color: _getLineColor(station.line),
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  MetroCache.getStationName(
                                    station,
                                    L10n.currentLanguage,
                                  ),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ThemeState().isLightTheme
                                        ? Colors.black
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              if (transferInfo != null) ...[
                                const SizedBox(width: 4),
                                ThemeIcon(
                                  Icons.train,
                                  color: _getLineColor(
                                    transferInfo["connectedStationLine"] as int,
                                  ),
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      );
    }

    return _buildStationPlaceholder(
      context,
      text: L10n.get("select_metro_line_title"),
    );
  }

  Widget _buildStationPlaceholder(
    BuildContext context, {
    String? text,
    Widget? child,
  }) {
    return Container(
      decoration: _pickerDecoration(context),
      height: 80,
      child: Center(
        child:
            child ??
            Text(
              text ?? "",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ThemeState().isLightTheme
                    ? Colors.black.withOpacity(0.7)
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
      ),
    );
  }
}
