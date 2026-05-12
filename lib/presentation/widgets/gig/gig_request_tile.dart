import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/gig_favorites_state.dart";
import "package:uy_dosh/base/services/sound_service.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_pulse_controller.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_participant_avatar_badge.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Reusable card for a single open [GigRequest] in any vertical list/feed.
///
/// Tapping the tile pushes [GigRequestDetailScreen] via the
/// [GigNavigatorExtensions] helper. Used by both the standalone
/// "Open tasks" list and the inline feed on the Services hub.
class GigRequestTile extends StatefulWidget {
  const GigRequestTile({
    required this.request,
    this.onDetailClosed,
    this.showFavoriteIndicator = false,
    this.forceFavorite,
    this.onFavoriteRemoved,
    this.onFavoriteRemovalFailed,
    super.key,
  });

  final GigRequest request;

  /// Called after returning from [GigRequestDetailScreen]. [feedNeedsRefresh]
  /// is `true` when the owner cancelled the task there or edited it and left
  /// the screen — parent lists should refetch.
  final void Function(bool feedNeedsRefresh)? onDetailClosed;

  final bool showFavoriteIndicator;
  final bool? forceFavorite;
  final VoidCallback? onFavoriteRemoved;
  final VoidCallback? onFavoriteRemovalFailed;

  @override
  State<GigRequestTile> createState() => _GigRequestTileState();
}

class _GigRequestTileState extends State<GigRequestTile>
    with TickerProviderStateMixin {
  bool _isTogglingFavorite = false;
  late Listenable _favoriteListenable;
  FavoriteHeartPulseController? _favoritePulse;

  @override
  void initState() {
    super.initState();
    _favoriteListenable = Listenable.merge([
      GigFavoritesState().listenableForRequest(widget.request.id),
    ]);
    if (widget.showFavoriteIndicator) {
      _favoritePulse = FavoriteHeartPulseController(vsync: this);
    }
  }

  @override
  void didUpdateWidget(GigRequestTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.id != widget.request.id) {
      _favoriteListenable = Listenable.merge([
        GigFavoritesState().listenableForRequest(widget.request.id),
      ]);
    }
    final need = widget.showFavoriteIndicator;
    final had = oldWidget.showFavoriteIndicator;
    if (need && !had) {
      _favoritePulse = FavoriteHeartPulseController(vsync: this);
    } else if (!need && had) {
      _favoritePulse?.dispose();
      _favoritePulse = null;
    }
  }

  @override
  void dispose() {
    _favoritePulse?.dispose();
    super.dispose();
  }

  Future<void> _handleFavoriteTap(BuildContext context) async {
    if (_isTogglingFavorite) return;
    HapticFeedbackUtils.impact();
    SoundService().playLike();
    final gigFav = GigFavoritesState();
    final favScreen = FavoritesState();
    final wasFavorite =
        widget.forceFavorite ?? gigFav.isRequestFavorite(widget.request.id);
    gigFav.toggleRequestLocal(widget.request.id);
    if (!wasFavorite) {
      unawaited(_favoritePulse?.playTapPulse());
      favScreen.markDirty();
    }
    setState(() => _isTogglingFavorite = true);
    _favoritePulse?.setNetworkBusy(true);
    try {
      await getIt<IGigService>().toggleFavoriteRequest(widget.request.id);
      if (wasFavorite && widget.onFavoriteRemoved != null) {
        widget.onFavoriteRemoved!();
      }
    } catch (_) {
      gigFav.toggleRequestLocal(widget.request.id);
      widget.onFavoriteRemovalFailed?.call();
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("favorite_toggle_error"),
        );
      }
    } finally {
      _favoritePulse?.setNetworkBusy(false);
      if (mounted) {
        setState(() => _isTogglingFavorite = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = widget.request.category?.localizedName(language) ?? "";
    final rightPad = widget.showFavoriteIndicator ? 100.0 : 64.0;

    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            HapticFeedbackUtils.lightImpact();
            final refreshFeeds =
                await context.pushGigRequestDetail(widget.request.id);
            if (!context.mounted) return;
            widget.onDetailClosed?.call(refreshFeeds == true);
          },
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16, 16, rightPad, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryName.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.request.category?.icon != null) ...[
                            GigCategoryIconBadge(
                              icon: widget.request.category!.icon,
                              iconColor:
                                  scheme.onSurface.withValues(alpha: 0.72),
                              badgeBackgroundColor:
                                  scheme.onSurface.withValues(alpha: 0.12),
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
                                color: scheme.onSurface.withValues(alpha: 0.72),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Text(
                      widget.request.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ListenableBuilder(
                      listenable: PriceDisplaySettingsState(),
                      builder: (context, _) => Text(
                        _formatGigRequestTileBudget(widget.request),
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.75),
                        ),
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
                    avatarUrl: widget.request.clientAvatarUrl,
                    displayName: widget.request.clientDisplayName,
                    ringColor: scheme.surface,
                  ),
                ),
              ),
              if (widget.showFavoriteIndicator)
                PositionedDirectional(
                  top: 8,
                  end: 52,
                  child: ListenableBuilder(
                    listenable: _favoriteListenable,
                    builder: (context, child) {
                      if (!AuthenticationState().isAuthenticated) {
                        _favoritePulse?.setFavoriteOutlineState(
                          isFavorite: true,
                        );
                        return const SizedBox.shrink();
                      }
                      if (UserListingState()
                          .isOwner(widget.request.clientUserId)) {
                        _favoritePulse?.setFavoriteOutlineState(
                          isFavorite: true,
                        );
                        return const SizedBox.shrink();
                      }
                      final isFavorite = widget.forceFavorite ??
                          GigFavoritesState()
                              .isRequestFavorite(widget.request.id);
                      _favoritePulse?.setFavoriteOutlineState(
                        isFavorite: isFavorite,
                      );
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isTogglingFavorite
                              ? null
                              : () => _handleFavoriteTap(context),
                          borderRadius: BorderRadius.circular(22),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: Center(
                                child: AnimatedBuilder(
                                  animation: _favoritePulse!.listenable,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _favoritePulse!.scale,
                                      child: child,
                                    );
                                  },
                                  child: ThemeIcon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? AppColors.favoriteActive
                                        : AppColors.favoriteInactive,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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

String _formatGigRequestTileBudget(GigRequest request) {
  final amount = request.budgetAmount;
  if (amount == null) return L10n.get("gigs_request_budget_open");
  final display = CurrencyDisplayUtils.gigAmountForDisplay(
    amount: amount,
    currencyCode: request.currencyCode,
  );
  return CurrencyDisplayUtils.stripEmptyCurrencyArtifacts(
    L10n.getWithParams(
      "gigs_request_budget_fixed",
      params: {
        "amount": IntFormatUtils.withDotThousands(display.amount),
        "currency": CurrencyDisplayUtils.isoCodeForBadge(display.currencyCode),
      },
    ),
  );
}
