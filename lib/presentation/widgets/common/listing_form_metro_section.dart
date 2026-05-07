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
class ListingFormMetroSection extends StatelessWidget {
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
    super.key,
  });

  final int selectedSubwayLine;
  final int selectedStationIndex;
  final List<SubwayStation> currentStations;
  final bool isLoadingStations;
  final FixedExtentScrollController? metroLineScrollController;
  final FixedExtentScrollController? metroStationScrollController;
  final void Function(int lineIndex) onLineChanged;
  final void Function(int stationIndex) onStationChanged;
  final VoidCallback onDismissKeyboard;

  static Color _getLineColor(int line) => AppColors.getMetroLineColor(line);

  static String _getLocalizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) {
    final lang = L10n.currentLanguage;
    switch (lang) {
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
    final theme = Theme.of(context);
    return Container(
      decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
        context,
        theme: theme,
      ),
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              backgroundColor: Colors.transparent,
              changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
              itemExtent: 40,
              scrollController: metroLineScrollController,
              onSelectedItemChanged: (index) {
                onDismissKeyboard();
                SendSoundUtils.playCupertinoWheelSound();
                onLineChanged(index);
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
                  final name = MetroCache.getLineName(line, L10n.currentLanguage);
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
    if (selectedSubwayLine <= 0) {
      return _buildStationPlaceholder(
        context,
        text: L10n.get("select_metro_line_title"),
      );
    }

    if (isLoadingStations) {
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

    if (currentStations.isEmpty) {
      return _buildStationPlaceholder(
        context,
        text: L10n.get("select_metro_line_title"),
      );
    }

    if (currentStations.isNotEmpty) {
      return Container(
        decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
          context,
          theme: Theme.of(context),
        ),
        height: 80,
        child: Row(
          children: [
            Expanded(
              child: CupertinoPicker(
                backgroundColor: Colors.transparent,
                changeReportingBehavior: ChangeReportingBehavior.onScrollEnd,
                itemExtent: 40,
                scrollController: metroStationScrollController,
                onSelectedItemChanged: (index) {
                  onDismissKeyboard();
                  SendSoundUtils.playCupertinoWheelSound();
                  onStationChanged(index);
                },
                children: currentStations
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
                                  _getLocalizedName(
                                    nameUz: station.nameUz,
                                    nameRu: station.nameRu,
                                    nameEn: station.nameEn,
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
      decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
        context,
        theme: Theme.of(context),
      ),
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
