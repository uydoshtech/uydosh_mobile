import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Complaints warning card for listing detail (shown when listing has complaints).
///
/// Owns its own blink animation so the controller only ticks while the card is
/// actually mounted. Previously the parent screen owned a `_warningBlinkController`
/// that started repeating in `initState` and ran for the entire lifetime of the
/// listing detail screen — including for every listing that had zero complaints
/// (i.e. the vast majority).
class ListingDetailComplaintsCard extends StatefulWidget {
  const ListingDetailComplaintsCard({
    required this.complaintsLabel,
    required this.onPressed,
    super.key,
  });

  final String complaintsLabel;
  final VoidCallback onPressed;

  @override
  State<ListingDetailComplaintsCard> createState() =>
      _ListingDetailComplaintsCardState();
}

class _ListingDetailComplaintsCardState
    extends State<ListingDetailComplaintsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
    _blinkAnimation = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListingDetailTileShell(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedbackUtils.impact();
              widget.onPressed();
            },
            icon: FadeTransition(
              opacity: _blinkAnimation,
              child: const ThemeIcon(Icons.report_outlined),
            ),
            label: FadeTransition(
              opacity: _blinkAnimation,
              child: Text(widget.complaintsLabel),
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
