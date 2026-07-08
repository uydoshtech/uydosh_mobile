import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/presentation/widgets/common/metro_line_chip.dart";

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
            MetroLineChip(
              // Keyed by line (not just position) so each chip's implicit
              // animations track "line 2's chip" rather than "whichever chip
              // is 2nd in the row" — see MetroLineChip's doc comment.
              key: ValueKey(line),
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
