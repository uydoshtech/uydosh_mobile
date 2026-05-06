import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
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
                              color: scheme.secondary,
                            ),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              categoryName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                letterSpacing: 0.5,
                                color: scheme.secondary,
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
                  child: _OwnerAvatar(
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

/// Compact circular avatar for the request owner (client). Falls back to
/// initials when no avatar URL is available, then to a person icon when
/// the display name is missing/blank. Mirrors the avatar pipeline used in
/// the grouped conversations list (ClipOval + thin separator ring).
class _OwnerAvatar extends StatelessWidget {
  const _OwnerAvatar({
    required this.avatarUrl,
    required this.displayName,
    required this.ringColor,
  });

  static const double _size = 40;

  final String? avatarUrl;
  final String? displayName;
  final Color ringColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = resolveAvatarUrl(avatarUrl);
    final cacheExtent = (_size * MediaQuery.devicePixelRatioOf(context)).round();

    Widget fallback() {
      final initials = StringUtils.extractInitials(displayName ?? "");
      return Container(
        color: scheme.primaryContainer,
        alignment: Alignment.center,
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )
            : Icon(
                Icons.person,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
      );
    }

    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipOval(
              child: url != null
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      memCacheWidth: cacheExtent,
                      memCacheHeight: cacheExtent,
                      placeholder: (_, __) => fallback(),
                      errorWidget: (_, __, ___) => fallback(),
                    )
                  : fallback(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
