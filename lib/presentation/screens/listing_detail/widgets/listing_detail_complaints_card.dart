import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Complaints warning card for listing detail (shown when listing has complaints).
class ListingDetailComplaintsCard extends StatelessWidget {
  const ListingDetailComplaintsCard({
    required this.complaintsLabel,
    required this.onPressed,
    required this.warningBlinkAnimation,
    super.key,
  });

  final String complaintsLabel;
  final VoidCallback onPressed;
  final Animation<double> warningBlinkAnimation;

  @override
  Widget build(BuildContext context) {
    return ListingDetailTileShell(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: FadeTransition(
              opacity: warningBlinkAnimation,
              child: const ThemeIcon(Icons.report_outlined),
            ),
            label: FadeTransition(
              opacity: warningBlinkAnimation,
              child: Text(complaintsLabel),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}
