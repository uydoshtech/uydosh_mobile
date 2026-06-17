import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";

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
      useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            onPressed: () {
              HapticFeedbackUtils.impact();
              widget.onPressed();
            },
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            surfaceGradientBase: AppColors.error,
            textColor: AppColors.textLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _blinkAnimation,
                  child: Icon(
                    Icons.report_outlined,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: FadeTransition(
                    opacity: _blinkAnimation,
                    child: Text(
                      widget.complaintsLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
