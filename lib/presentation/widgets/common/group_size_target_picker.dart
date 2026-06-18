import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class GroupSizeTargetPicker extends StatelessWidget {
  const GroupSizeTargetPicker({
    required this.groupSizeTarget,
    required this.onChanged,
    this.scrollController,
    this.height = 120,
    super.key,
  });

  static const int minSize = 2;
  static const int maxSize = 6;

  final int groupSizeTarget;
  final ValueChanged<int> onChanged;
  final FixedExtentScrollController? scrollController;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CupertinoPicker(
        scrollController: scrollController,
        itemExtent: 40,
        onSelectedItemChanged: (index) => onChanged(index + minSize),
        children: List<Widget>.generate(
          maxSize - minSize + 1,
          (index) => _buildItem(index + minSize),
        ),
      ),
    );
  }

  Widget _buildItem(int personCount) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOverlappingPersonIcons(personCount),
            const SizedBox(width: 8),
            Text(
              L10n.plural("group_size_target_option", personCount),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlappingPersonIcons(int personCount) {
    const iconSize = 16.0;
    const overlap = 7.0;
    final step = iconSize - overlap;

    return SizedBox(
      width: iconSize + (personCount - 1) * step,
      height: iconSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(
          personCount,
          (index) => Positioned(
            left: index * step,
            child: ThemeIcon(
              index.isEven ? Icons.person_outline : Icons.person,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
