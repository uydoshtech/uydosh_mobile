import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";

/// Horizontal single-select row of metro line chips: an "M" badge per line
/// that reveals its name once selected. Mirrors the line-selection control
/// used on the web feed/create flows (`.chip-line` in the Telegram mini-app).
class MetroLineChipRow extends StatelessWidget {
  const MetroLineChipRow({
    required this.selectedLine,
    required this.onLineSelected,
    this.lines = const [1, 2, 3, 4],
    super.key,
  });

  /// 0 = no line picked, 1..4 = metro line.
  final int selectedLine;
  final List<int> lines;
  final ValueChanged<int> onLineSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final line in lines) ...[
            _MetroLineChip(
              line: line,
              isSelected: selectedLine == line,
              onTap: () {
                if (selectedLine == line) return;
                SendSoundUtils.playCupertinoWheelSound();
                onLineSelected(line);
              },
            ),
            if (line != lines.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _MetroLineChip extends StatelessWidget {
  const _MetroLineChip({
    required this.line,
    required this.isSelected,
    required this.onTap,
  });

  final int line;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lineColor = AppColors.getMetroLineColor(line);
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : Color.lerp(lineColor, theme.colorScheme.outline, 0.45)!;
    final fillColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: isSelected ? 0.10 : 0.05,
    );
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;

    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, _) {
        final language = LanguageState().currentLanguage;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 10 : 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: MLetterIcon(color: lineColor, size: 20),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  child: isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            MetroCache.getLineName(line, language),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
