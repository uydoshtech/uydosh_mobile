import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";

/// Matches native 3D viewer: SF `rectangle` → [Icons.rectangle_outlined],
/// `arrow.up.and.down` → [Icons.height], `rectangle.on.rectangle` →
/// [Icons.flip_to_front_outlined] (overlapping rects).
Widget _room3dDimensionMetricRow({
  required BuildContext context,
  required IconData icon,
  required String text,
}) {
  final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
      );
  final iconColor = style?.color ?? Theme.of(context).colorScheme.onSurface;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, size: 18, color: iconColor.withValues(alpha: 0.92)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: style)),
    ],
  );
}

/// Self-contained "View room in 3D" tile.
///
/// Owns its rotating-icon controller so the controller only ticks while the
/// tile is actually mounted (i.e. only when the listing has a 3D scan).
class ListingRoom3dTile extends StatefulWidget {
  const ListingRoom3dTile({
    required this.listingDetail,
    required this.onTap,
    this.isLoading = false,
    super.key,
  });

  final ListingDetail listingDetail;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  State<ListingRoom3dTile> createState() => _ListingRoom3dTileState();
}

class _ListingRoom3dTileState extends State<ListingRoom3dTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncRotation();
  }

  void _syncRotation() {
    final enabled = UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        TickerMode.of(context);
    if (enabled) {
      if (!_rotateController.isAnimating) {
        _rotateController.repeat();
      }
    } else {
      _rotateController.stop();
      _rotateController.value = 0;
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.listingDetail;
    final fl = d.roomScanFloorLongM;
    final fs = d.roomScanFloorShortM;
    final h = d.roomScanHeightM;
    final area = d.roomScanFloorAreaM2;
    String? line1;
    String? lineHeight;
    String? line2;
    if (fl != null && fs != null && h != null && area != null) {
      line1 = L10n.getWithParams(
        "room_3d_dimensions_line1_template",
        params: <String, String>{
          "floorLong": fl.toStringAsFixed(1),
          "floorShort": fs.toStringAsFixed(1),
        },
      );
      lineHeight = L10n.getWithParams(
        "room_3d_dimensions_height_template",
        params: <String, String>{
          "height": h.toStringAsFixed(1),
        },
      );
      line2 = L10n.getWithParams(
        "room_3d_dimensions_line2_template",
        params: <String, String>{
          "floorArea": area.toStringAsFixed(1),
        },
      );
    }
    final hasDimensions = line1 != null && lineHeight != null && line2 != null;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return SizedBox(
      width: double.infinity,
      child: ListingDetailTileShell(
        useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RotationTransition(
                            turns: _rotateController,
                            child: ThemeIcon(
                              Icons.view_in_ar,
                              color: ThemeState().isBlueTheme
                                  ? BlueThemeColors.textPrimary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              L10n.get("view_room_3d"),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.hardEdge,
                          child: hasDimensions
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      _room3dDimensionMetricRow(
                                        context: context,
                                        icon: Icons.rectangle_outlined,
                                        text: line1,
                                      ),
                                      const SizedBox(height: 4),
                                      _room3dDimensionMetricRow(
                                        context: context,
                                        icon: Icons.height,
                                        text: lineHeight,
                                      ),
                                      const SizedBox(height: 4),
                                      _room3dDimensionMetricRow(
                                        context: context,
                                        icon: Icons.flip_to_front_outlined,
                                        text: line2,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.isLoading)
                  UydoshInlineSpinner(color: variant, dimension: 20)
                else
                  ThemeIcon(
                    Icons.chevron_right,
                    color: variant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
