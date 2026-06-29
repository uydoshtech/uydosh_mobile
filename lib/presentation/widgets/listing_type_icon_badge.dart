import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";

/// A simple icon-only badge for displaying listing type information
/// Shows only the icon without any text, perfect for compact displays
class ListingTypeIconBadge extends StatelessWidget {
  const ListingTypeIconBadge({
    required this.listingTypeCode,
    super.key,
    this.hostResident,
    this.size = 24,
    this.padding = const EdgeInsets.all(8),
    this.label,
    this.labelFontSize = 13,
    this.borderRadius = 8,
  });

  final String listingTypeCode;
  final bool? hostResident;
  final double size;
  final EdgeInsets padding;

  /// Optional text shown next to the icon (e.g. "Сосед" / "Комната").
  final String? label;
  final double labelFontSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final style = ListingTypeHelper.getBadgeStyle(listingTypeCode);
    final icon = ListingTypeHelper.getIcon(
      listingTypeCode,
      hostResident: hostResident,
    );

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
          ThemeIcon(icon, color: style.foreground, size: size),
          if (label != null && label!.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(
              label!,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: style.foreground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
