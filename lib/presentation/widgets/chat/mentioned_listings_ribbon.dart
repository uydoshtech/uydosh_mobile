import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_plate.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// A single listing entry shown in the [MentionedListingsRibbon].
class MentionedListingChip {
  const MentionedListingChip({required this.listingId, required this.title});

  final int listingId;
  final String title;
}

/// Persistent, non-closable ribbon listing every housing card mentioned in a
/// group chat. Tapping a chip jumps the chat to that listing's first mention.
///
/// Styled to match the home-screen filter ribbon: a frosted [LiquidGlassPlate]
/// holding a horizontally scrollable row of neumorphic pills.
class MentionedListingsRibbon extends StatelessWidget {
  const MentionedListingsRibbon({
    required this.items,
    required this.onTap,
    super.key,
  });

  static const double _chipHeight = 34;

  final List<MentionedListingChip> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: LiquidGlassPlate(
        borderRadius: BorderRadius.circular(18),
        sigma: 18,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: SizedBox(
          height: _chipHeight,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Icon(
                  Icons.bookmark,
                  size: 18,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final raw = item.title.trim();
                    final label =
                        raw.isEmpty ? L10n.get("group_shortlist_ref_label") : raw;
                    return _Chip(
                      label: label,
                      height: _chipHeight,
                      onTap: () {
                        HapticFeedbackUtils.impact();
                        onTap(item.listingId);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.height,
    required this.onTap,
  });

  /// Keep chips compact: long listing titles are clipped to a short, readable
  /// stub (full title is still reachable by tapping the chip).
  static const int _maxChars = 14;

  final String label;
  final double height;
  final VoidCallback onTap;

  String get _shortLabel {
    if (label.length <= _maxChars) return label;
    return "${label.substring(0, _maxChars).trimRight()}…";
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(999);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, scheme.surface),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: scheme.primary.withValues(alpha: 0.12),
          highlightColor: scheme.primary.withValues(alpha: 0.08),
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home_work_outlined,
                  size: 15,
                  color: scheme.onSurface,
                ),
                const SizedBox(width: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    _shortLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                      height: 1.0,
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
