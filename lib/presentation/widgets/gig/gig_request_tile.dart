import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_participant_avatar_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Reusable card for a single open [GigRequest] in any vertical list/feed.
///
/// Tapping the tile pushes [GigRequestDetailScreen] via the
/// [GigNavigatorExtensions] helper. Used by both the standalone
/// "Open tasks" list and the inline feed on the Services hub.
class GigRequestTile extends StatelessWidget {
  const GigRequestTile({
    required this.request,
    this.onDetailClosed,
    super.key,
  });

  final GigRequest request;

  /// Called after returning from [GigRequestDetailScreen]. [taskWasRemoved] is
  /// `true` when the owner deleted/cancelled the open task from that screen.
  final void Function(bool taskWasRemoved)? onDetailClosed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = request.category?.localizedName(language) ?? "";
    final budgetLine = request.budgetAmount != null
        ? L10n.getWithParams(
            "gigs_request_budget_fixed",
            params: {
              "amount": IntFormatUtils.withDotThousands(request.budgetAmount!),
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
          onTap: () async {
            HapticFeedbackUtils.lightImpact();
            final removed = await context.pushGigRequestDetail(request.id);
            if (!context.mounted) return;
            onDetailClosed?.call(removed == true);
          },
          borderRadius: BorderRadius.circular(16),
          // Stack so the client avatar can dock in the top-right corner
          // overlaying the right edge of the text column — matches the
          // collapsed chat-group header layout.
          child: Stack(
            children: [
              Padding(
                // Reserve right padding for the 40px avatar (+gap) so long
                // titles/category labels don't slide under it.
                padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 64, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryName.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (request.category?.icon != null) ...[
                            Icon(
                              request.category!.icon,
                              size: 14,
                              color:
                                  scheme.onSurface.withValues(alpha: 0.72),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              categoryName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.5,
                                color:
                                    scheme.onSurface.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
              PositionedDirectional(
                top: 12,
                end: 12,
                child: IgnorePointer(
                  child: GigParticipantAvatarBadge(
                    avatarUrl: request.clientAvatarUrl,
                    displayName: request.clientDisplayName,
                    ringColor: scheme.surface,
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
