import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";

const _listingDislikeReasons = [
  (
    code: "too_expensive",
    labelKey: "group_shortlist_dislike_reason_expensive",
  ),
  (code: "too_far", labelKey: "group_shortlist_dislike_reason_far"),
  (
    code: "bad_condition",
    labelKey: "group_shortlist_dislike_reason_condition",
  ),
  (
    code: "owner_doubts",
    labelKey: "group_shortlist_dislike_reason_owner",
  ),
  (
    code: "not_enough_space",
    labelKey: "group_shortlist_dislike_reason_space",
  ),
  (
    code: "bad_neighborhood",
    labelKey: "group_shortlist_dislike_reason_neighborhood",
  ),
];

const _ratingCategories = [
  (
    code: "price",
    titleKey: "listing_rating_category_price",
    subtitleKey: "listing_rating_category_price_subtitle",
    icon: Icons.attach_money_rounded,
    color: Color(0xFF34C759),
  ),
  (
    code: "location",
    titleKey: "listing_rating_category_location",
    subtitleKey: "listing_rating_category_location_subtitle",
    icon: Icons.location_on_rounded,
    color: Color(0xFF2F80ED),
  ),
  (
    code: "condition",
    titleKey: "listing_rating_category_condition",
    subtitleKey: "listing_rating_category_condition_subtitle",
    icon: Icons.home_rounded,
    color: Color(0xFF8E5CF7),
  ),
  (
    code: "group",
    titleKey: "listing_rating_category_group",
    subtitleKey: "listing_rating_category_group_subtitle",
    icon: Icons.groups_rounded,
    color: Color(0xFFF2994A),
  ),
  (
    code: "landlord",
    titleKey: "listing_rating_category_landlord",
    subtitleKey: "listing_rating_category_landlord_subtitle",
    icon: Icons.person_rounded,
    color: Color(0xFFEB5757),
  ),
];

class ListingRatingDialogResult {
  const ListingRatingDialogResult({
    required this.stars,
    required this.reasons,
    required this.categoryRatings,
    required this.verdict,
  });

  final int stars;
  final List<String> reasons;
  final Map<String, int> categoryRatings;
  final String verdict;
}

Future<ListingRatingDialogResult?> showListingRatingDialog({
  required BuildContext context,
  required int currentStars,
  Set<String> initialReasonCodes = const {},
  Map<String, int> initialCategoryRatings = const {},
  bool prefillMissingCategoryRatings = true,
}) {
  return showDialog<ListingRatingDialogResult>(
    context: context,
    builder: (dialogContext) {
      var selected = currentStars.clamp(0, 5).toInt();
      final categoryRatings = List<int>.generate(
        _ratingCategories.length,
        (index) {
          final value = initialCategoryRatings[_ratingCategories[index].code];
          if (value != null) return value.clamp(1, 5).toInt();
          return prefillMissingCategoryRatings ? selected : 0;
        },
      );
      final selectedReasonCodes = {...initialReasonCodes};
      return StatefulBuilder(
        builder: (context, setDialogState) {
          final scheme = Theme.of(context).colorScheme;
          final theme = Theme.of(context);
          return UydoshGlassDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 22,
            ),
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            actionsPadding: EdgeInsets.zero,
            scrollable: true,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.get("listing_rating_screen_title"),
                            style: TextStyle(
                              fontSize: 22,
                              height: 1.05,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L10n.get("listing_rating_screen_subtitle"),
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...List.generate(_ratingCategories.length, (index) {
                  final category = _ratingCategories[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _ratingCategories.length - 1 ? 0 : 7,
                    ),
                    child: _RatingCategoryCard(
                      title: L10n.get(category.titleKey),
                      subtitle: L10n.get(category.subtitleKey),
                      icon: category.icon,
                      color: category.color,
                      stars: categoryRatings[index],
                      onChanged: (value) {
                        HapticFeedbackUtils.selectionClick();
                        setDialogState(() {
                          categoryRatings[index] = value;
                          selected = _averageSelectedCategoryStars(
                                categoryRatings,
                              ) ??
                              selected;
                        });
                      },
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    text: L10n.get("listing_rating_reasons_title"),
                    children: [
                      TextSpan(
                        text: " (${L10n.get("listing_rating_optional")})",
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: _listingDislikeReasons.map((reason) {
                    final isSelected =
                        selectedReasonCodes.contains(reason.code);
                    return ChoiceChip(
                      label: Text(L10n.get(reason.labelKey)),
                      selected: isSelected,
                      onSelected: (value) {
                        HapticFeedbackUtils.selectionClick();
                        setDialogState(() {
                          if (value) {
                            selectedReasonCodes.add(reason.code);
                          } else {
                            selectedReasonCodes.remove(reason.code);
                          }
                        });
                      },
                      selectedColor: AppColors.warning.withValues(alpha: 0.16),
                      backgroundColor:
                          scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      showCheckmark: false,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.warning.withValues(alpha: 0.55)
                            : scheme.outlineVariant.withValues(alpha: 0.45),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(
                    ListingRatingDialogResult(
                      stars: selected,
                      reasons: selectedReasonCodes.toList(),
                      categoryRatings: {
                        for (var i = 0; i < _ratingCategories.length; i++)
                          if (categoryRatings[i] > 0)
                            _ratingCategories[i].code: categoryRatings[i],
                      },
                      verdict: _verdictForStars(selected),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: Text(L10n.get("listing_rating_submit")),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

int? _averageSelectedCategoryStars(List<int> ratings) {
  final selectedRatings = ratings.where((rating) => rating > 0).toList();
  if (selectedRatings.isEmpty) return null;
  return (selectedRatings.reduce((a, b) => a + b) / selectedRatings.length)
      .round()
      .clamp(1, 5)
      .toInt();
}

String _verdictForStars(int stars) {
  if (stars >= 5) return "yes";
  if (stars >= 3) return "maybe";
  return "no";
}

class _RatingCategoryCard extends StatelessWidget {
  const _RatingCategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.stars,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int stars;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: color.withValues(alpha: 0.20),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 15,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  _InlineStars(stars: stars, onChanged: onChanged),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _ratingLabel(stars),
              style: TextStyle(
                color: _ratingLabelColor(stars),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _ratingLabel(int stars) {
    if (stars <= 0) return "";
    if (stars >= 5) return L10n.get("listing_rating_label_excellent");
    if (stars >= 4) return L10n.get("listing_rating_label_good");
    if (stars >= 3) return L10n.get("listing_rating_label_normal");
    return L10n.get("listing_rating_label_bad");
  }

  static Color _ratingLabelColor(int stars) {
    if (stars >= 5) return AppColors.success;
    if (stars >= 4) return AppColors.success;
    if (stars >= 3) return AppColors.warning;
    return AppColors.error;
  }
}

class _InlineStars extends StatelessWidget {
  const _InlineStars({
    required this.stars,
    required this.onChanged,
  });

  final int stars;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final value = index + 1;
        final filled = stars >= value;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(value),
          child: Padding(
            padding: const EdgeInsets.only(right: 2),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 25,
              color: filled ? AppColors.warning : scheme.onSurfaceVariant,
            ),
          ),
        );
      }),
    );
  }
}
