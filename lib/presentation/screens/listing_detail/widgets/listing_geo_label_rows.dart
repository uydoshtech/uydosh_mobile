import "package:flutter/material.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ListingDistrictLabelRow extends StatelessWidget {
  const ListingDistrictLabelRow({
    required this.label,
    super.key,
    this.fontSize = 15,
  });

  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ThemeIconFactory.detail(
          icon: Icons.location_on,
          color: Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              color: ListingDetailThemeHelper.locationTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class ListingMetroLabelRow extends StatelessWidget {
  const ListingMetroLabelRow({
    required this.label,
    required this.lineColor,
    super.key,
    this.connectedLabel,
    this.connectedLineColor,
    this.fontSize = 15,
  });

  final String label;
  final Color lineColor;
  final String? connectedLabel;
  final Color? connectedLineColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final secondLabel = connectedLabel;
    final secondLineColor = connectedLineColor;
    if (secondLabel != null && secondLineColor != null) {
      return Row(
        children: [
          ThemeIcon(Icons.train, color: lineColor, size: 20),
          const SizedBox(width: 4),
          Flexible(child: _GeoLabelText(label: label, fontSize: fontSize)),
          const SizedBox(width: 4),
          ThemeIcon(
            Icons.swap_horiz,
            color: ListingDetailThemeHelper.locationTextColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          ThemeIcon(Icons.train, color: secondLineColor, size: 20),
          const SizedBox(width: 4),
          Flexible(
              child: _GeoLabelText(label: secondLabel, fontSize: fontSize)),
        ],
      );
    }

    return Row(
      children: [
        ThemeIcon(Icons.train, color: lineColor, size: 20),
        const SizedBox(width: 8),
        Expanded(child: _GeoLabelText(label: label, fontSize: fontSize)),
      ],
    );
  }
}

class _GeoLabelText extends StatelessWidget {
  const _GeoLabelText({required this.label, required this.fontSize});

  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: ListingDetailThemeHelper.locationTextColor,
      ),
    );
  }
}
