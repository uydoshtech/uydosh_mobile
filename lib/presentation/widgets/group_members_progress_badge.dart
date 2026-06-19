import "package:flutter/material.dart";
import "package:uy_dosh/domain/constants/listing_type_ids.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";

/// Compact `current/target` pill for `group_forming` listing tiles.
class GroupMembersProgressBadge extends StatelessWidget {
  const GroupMembersProgressBadge({
    required this.current,
    required this.target,
    super.key,
    this.size = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    this.labelFontSize = 13,
    this.borderRadius = 8,
  });

  final int current;
  final int target;
  final double size;
  final EdgeInsets padding;
  final double labelFontSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final style = ListingTypeHelper.getBadgeStyle(ListingTypeCodes.groupForming);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: style.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(
            ListingTypeHelper.getIcon(ListingTypeCodes.groupForming),
            color: style.foreground,
            size: size,
          ),
          const SizedBox(width: 5),
          Text(
            "$current/$target",
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              color: style.foreground,
            ),
          ),
        ],
      ),
    );
  }
}
