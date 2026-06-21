import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/utils/group_housing_budget_fit.dart";

class GroupBudgetFitChip extends StatelessWidget {
  const GroupBudgetFitChip({
    required this.fit,
    super.key,
  });

  final GroupHousingBudgetFit fit;

  @override
  Widget build(BuildContext context) {
    if (fit == GroupHousingBudgetFit.unknown) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isFits = fit == GroupHousingBudgetFit.fits;
    final color = isFits ? AppColors.success : AppColors.warning;
    final label = isFits
        ? L10n.get("group_housing_fits_budget")
        : L10n.get("group_housing_above_budget");

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isFits ? AppColors.successDark : color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
