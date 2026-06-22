import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// A single listing entry shown in the [MentionedListingsRibbon].
class MentionedListingChip {
  const MentionedListingChip({required this.listingId, required this.title});

  final int listingId;
  final String title;
}

/// Persistent, non-closable ribbon listing every housing card mentioned in a
/// group chat. Tapping a chip jumps the chat to that listing's first mention.
///
/// Styled after the filter ribbon: a single horizontally scrollable row of
/// pills sitting just under the app bar.
class MentionedListingsRibbon extends StatelessWidget {
  const MentionedListingsRibbon({
    required this.items,
    required this.onTap,
    super.key,
  });

  final List<MentionedListingChip> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
              child: Icon(
                Icons.home_work_outlined,
                size: 18,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final label = item.title.trim().isEmpty
                      ? L10n.get("group_shortlist_ref_label")
                      : item.title.trim();
                  return _Chip(
                    label: label,
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
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.place_outlined, size: 14, color: scheme.primary),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
