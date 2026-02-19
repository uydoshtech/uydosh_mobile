import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/subway_station.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";

/// Metro line and station selection for create/edit listing forms.
/// Displays side-by-side pickers for line (optional) and station.
class ListingFormMetroSection extends StatelessWidget {
  const ListingFormMetroSection({
    required this.selectedSubwayLine,
    required this.selectedStationIndex,
    required this.currentStations,
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

  Color _getControlBackgroundColor(BuildContext context) {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.surface;
    }
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildLinePicker(context),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStationPicker(context),
        ),
      ],
    );
  }

  Widget _buildLinePicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeState().isBlueTheme
            ? BlueThemeColors.surface
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      height: 80,
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              itemExtent: 40,
              scrollController: metroLineScrollController,
              onSelectedItemChanged: (index) {
                onDismissKeyboard();
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                onLineChanged(index);
              },
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MLetterIcon(color: Colors.grey, size: 20),
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
    if (selectedSubwayLine > 0 && currentStations.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
          ),
          color: ThemeState().isBlueTheme
              ? BlueThemeColors.surface
              : Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        height: 80,
        child: Row(
          children: [
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: metroStationScrollController,
                onSelectedItemChanged: (index) {
                  onDismissKeyboard();
                  HapticFeedbackUtils.impact();
                  SendSoundUtils.playSelectionSound();
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
                              Icon(
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
                                Icon(
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
        ),
        color: _getControlBackgroundColor(context).withValues(alpha: 0.5),
      ),
      height: 80,
      child: Center(
        child: Text(
          L10n.get("select_metro_line_title"),
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
