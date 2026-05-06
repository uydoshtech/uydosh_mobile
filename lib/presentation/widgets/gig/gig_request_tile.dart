import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Reusable card for a single open [GigRequest] in any vertical list/feed.
///
/// Tapping the tile pushes [GigRequestDetailScreen] via the
/// [GigNavigatorExtensions] helper. Used by both the standalone
/// "Open tasks" list and the inline feed on the Services hub.
class GigRequestTile extends StatelessWidget {
  const GigRequestTile({required this.request, super.key});

  final GigRequest request;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = request.category?.localizedName(language) ?? "";
    final budgetLine = request.budgetAmount != null
        ? L10n.getWithParams(
            "gigs_request_budget_fixed",
            params: {
              "amount": request.budgetAmount!.toString(),
              "currency": request.currencyCode,
            },
          )
        : L10n.get("gigs_request_budget_open");

    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      // Wrap the inner Padding in a Material+InkWell so the ripple is
      // clipped to the surface's rounded shape and matches the elevation
      // visual.
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedbackUtils.lightImpact();
            context.pushGigRequestDetail(request.id);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (categoryName.isNotEmpty)
                  Text(
                    categoryName.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: scheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  request.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  budgetLine,
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.75),
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
