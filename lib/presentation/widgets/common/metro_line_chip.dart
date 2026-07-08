import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";

/// A single metro-line pill: an "M" badge that expands to reveal the line's
/// name once selected, and collapses back to icon-only otherwise.
///
/// Split out of [MetroLineChipRow] (which used to build this inline as a
/// private, unkeyed widget) into its own component so each chip has a stable
/// identity ([ValueKey] on `line`, set by the row) independent of the other
/// chips. Without that, [MultiStationPicker] could load the right line's
/// stations while a chip's own implicit animations (border/fill/scale/size)
/// stayed tied to whichever line last happened to occupy that slot, leaving
/// the expanded/selected look stuck on the previously selected line.
class MetroLineChip extends StatefulWidget {
  const MetroLineChip({
    required this.line,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final int line;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<MetroLineChip> createState() => _MetroLineChipState();
}

class _MetroLineChipState extends State<MetroLineChip> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lineColor = AppColors.getMetroLineColor(widget.line);
    final borderColor = widget.isSelected
        ? theme.colorScheme.primary
        : Color.lerp(lineColor, theme.colorScheme.outline, 0.45)!;
    final fillColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: widget.isSelected ? 0.10 : 0.05,
    );
    final textColor = ThemeState().isBlueTheme ? Colors.white : Colors.black;

    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, _) {
        final language = LanguageState().currentLanguage;
        return InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isSelected ? 10 : 8,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: borderColor,
                width: widget.isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: widget.isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutBack,
                  child: MLetterIcon(color: lineColor, size: 20),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeInOutCubic,
                  child: widget.isSelected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            MetroCache.getLineName(widget.line, language),
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
