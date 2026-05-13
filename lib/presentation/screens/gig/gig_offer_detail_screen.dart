import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/gig_hub_feeds_refresh_notifier.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/gig_favorites_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/util/theme_helper.dart" show ThemeHelper;
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/moderation_staff_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/peer_interaction_eligibility.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/utils/conversation_entry_flow.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offer_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_date_utils.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/presentation/utils/destructive_action_flow.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/detail_hosted_photo_gallery.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/full_screen_photo_viewer.dart";
import "package:uy_dosh/presentation/widgets/common/glass_green_chat_cta_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_pulse_controller.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class GigOfferDetailScreen extends StatefulWidget {
  const GigOfferDetailScreen({required this.offerId, super.key});
  final int offerId;

  @override
  State<GigOfferDetailScreen> createState() => _GigOfferDetailScreenState();
}

class _GigOfferDetailScreenState extends State<GigOfferDetailScreen> {
  String? _sessionRole;

  @override
  void initState() {
    super.initState();
    // Same as listings: owner checks need a loaded user id. Gigs are reachable
    // from the tab bar without visiting Home first, so initialize here.
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    unawaited(_hydrateSessionRole());
    context.read<GigOfferDetailBloc>().add(FetchGigOfferDetail(widget.offerId));
  }

  Future<void> _hydrateSessionRole() async {
    final r = await SessionManager.getUserRole();
    if (mounted) setState(() => _sessionRole = r);
  }

  Future<void> _persistOfferFavoriteToggle(
    BuildContext context,
    GigOffer offer,
    bool wasFavorite,
    FavoriteHeartPulseController pulse,
  ) async {
    final gigFav = GigFavoritesState();
    final screenFav = FavoritesState();
    gigFav.toggleOfferLocal(offer.id);
    if (!wasFavorite) {
      unawaited(pulse.playTapPulse());
      screenFav.markDirty();
    }
    try {
      await getIt<IGigService>().toggleFavoriteOffer(offer.id);
    } catch (_) {
      gigFav.toggleOfferLocal(offer.id);
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("favorite_toggle_error"),
        );
      }
    }
  }

  Future<void> _editOffer(GigOffer offer) async {
    final detailBloc = context.read<GigOfferDetailBloc>();
    final updated = await context.pushEditGigOffer(offer);
    if (updated != null && mounted) {
      detailBloc.add(FetchGigOfferDetail(offer.id));
    }
  }

  Future<void> _deleteOffer(GigOffer offer) async {
    await DestructiveActionFlow.runAfterDeleteConfirmed(
      context: context,
      titleKey: "gigs_offer_delete_title",
      messageKey: "gigs_offer_delete_message",
      errorToastKey: "gigs_offer_delete_failed",
      onConfirmed: () async {
        await getIt<IGigService>().deleteOffer(offer.id);
        if (!mounted) return;
        getIt<GigHubFeedsRefreshNotifier>().requestRefresh();
        ToastReporting.successKey(context, "gigs_offer_delete_success");
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserListingState(),
      builder: (context, _) {
        return BlocListener<GigOfferDetailBloc, GigOfferDetailState>(
          listenWhen: (previous, current) =>
              previous is GigOfferDetailLoaded &&
              current is GigOfferDetailLoaded &&
              previous.bookingInFlight &&
              !current.bookingInFlight &&
              current.activeClientBookingForOffer != null,
          listener: (context, state) {
            ToastTheme.showSuccess(
              context,
              message: L10n.get("gigs_booking_created_toast"),
              leadingIcon: Icons.add_rounded,
            );
            context.pushMyGigBookings();
          },
          child: BlocConsumer<GigOfferDetailBloc, GigOfferDetailState>(
            listener: (context, state) {
              if (state is GigOfferDetailLoaded) {
                GigFavoritesState().syncFromOffers([state.offer]);
              } else if (state is GigOfferDetailError) {
                ToastTheme.showError(context, message: state.message);
              }
            },
            builder: (context, state) {
              final offerForMenu =
                  state is GigOfferDetailLoaded ? state.offer : null;
              final showOwnerActions = offerForMenu != null &&
                  (UserListingState().isOwner(offerForMenu.providerUserId) ||
                      ModerationStaffUtils.isModerationStaff(_sessionRole));
              final canFavoriteOffer = offerForMenu != null &&
                  PeerInteractionEligibility.mayInteractWithPublisher(
                    publisherUserId: offerForMenu.providerUserId,
                  );
              return Scaffold(
                appBar: AppBar(
                  leading: ThreeDAppBarIconButton.backLeading(context),
                  title: Text(L10n.get("gigs_offer_detail_title")),
                  actions: [
                    if (canFavoriteOffer)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FavoriteHeartToggle(
                          listenable: GigFavoritesState()
                              .listenableForOffer(offerForMenu.id),
                          shouldShow: (_) => true,
                          resolveIsFavorite: (_) => GigFavoritesState()
                              .isOfferFavorite(offerForMenu.id),
                          hiddenBuilder: (_) => const SizedBox.shrink(),
                          onToggle: (ctx, wasFavorite, pulse) =>
                              _persistOfferFavoriteToggle(
                            ctx,
                            offerForMenu,
                            wasFavorite,
                            pulse,
                          ),
                          builder: (context, ui) => IconButton(
                            onPressed: ui.onTap,
                            icon: AnimatedBuilder(
                              animation: ui.pulse.listenable,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: ui.pulse.scale,
                                  child: child,
                                );
                              },
                              child: Icon(
                                ui.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: ui.isFavorite
                                    ? AppColors.favoriteActive
                                    : AppColors.favoriteInactive,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (showOwnerActions)
                      ActionDropdownMenu(
                        padding: const EdgeInsets.only(right: 12),
                        items: [
                          ActionMenuItem(
                            value: "edit_offer",
                            icon: Icons.edit_outlined,
                            textKey: "gigs_offer_edit_cta",
                            onPressed: () =>
                                unawaited(_editOffer(offerForMenu)),
                          ),
                          ActionMenuItem(
                            value: "delete_offer",
                            icon: Icons.delete_outline_rounded,
                            textKey: "gigs_offer_delete_menu",
                            onPressed: () =>
                                unawaited(_deleteOffer(offerForMenu)),
                            iconColor: Colors.red,
                            textColor: Colors.red,
                          ),
                        ],
                      ),
                  ],
                ),
                body: _buildBody(context, state),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, GigOfferDetailState state) {
    if (state is GigOfferDetailLoading || state is GigOfferDetailInitial) {
      return const Center(child: HouseLoadingIndicator());
    }
    if (state is GigOfferDetailError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(state.message),
        ),
      );
    }
    if (state is GigOfferDetailLoaded) {
      return _OfferDetailContentStateful(
        state: state,
        onEditOffer: _editOffer,
        canStaffEditOffer:
            ModerationStaffUtils.isModerationStaff(_sessionRole),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Matches listing detail: primary first, stable [photo_order] among others.
List<String> _orderedGigPhotoRawUrls(List<GigOfferPhoto> photos) {
  final ordered = List<GigOfferPhoto>.from(photos)
    ..sort((a, b) => a.photoOrder.compareTo(b.photoOrder));
  final primaryIndex = ordered.indexWhere((p) => p.isPrimary);
  if (primaryIndex > 0) {
    final primary = ordered.removeAt(primaryIndex);
    ordered.insert(0, primary);
  }
  return List<String>.from(ordered.map((p) => p.photoUrl));
}

class _OfferDetailContentStateful extends StatefulWidget {
  const _OfferDetailContentStateful({
    required this.state,
    required this.onEditOffer,
    required this.canStaffEditOffer,
  });
  final GigOfferDetailLoaded state;
  final Future<void> Function(GigOffer offer) onEditOffer;
  final bool canStaffEditOffer;

  @override
  State<_OfferDetailContentStateful> createState() =>
      _OfferDetailContentStatefulState();
}

class _OfferDetailContentStatefulState
    extends State<_OfferDetailContentStateful> {
  PageController? _photoPageController;
  bool _bookingChatInFlight = false;

  @override
  void initState() {
    super.initState();
    _syncPhotoController(widget.state.offer.photos.length);
  }

  @override
  void didUpdateWidget(covariant _OfferDetailContentStateful oldWidget) {
    super.didUpdateWidget(oldWidget);
    final n = widget.state.offer.photos.length;
    final oldN = oldWidget.state.offer.photos.length;
    if (n != oldN) {
      _photoPageController?.dispose();
      _syncPhotoController(n);
    }
  }

  void _syncPhotoController(int photoCount) {
    if (photoCount > 0) {
      _photoPageController = PageController();
    } else {
      _photoPageController = null;
    }
  }

  String _providerDisplayName(GigOffer offer) {
    final n = offer.providerDisplayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return L10n.get("gigs_offer_provider_fallback");
  }

  Future<void> _openActiveBookingChat(
      GigBooking booking, GigOffer offer) async {
    if (_bookingChatInFlight) return;
    if (!AuthFlow.requireAuth(context)) return;
    setState(() => _bookingChatInFlight = true);
    try {
      final name = _providerDisplayName(offer);
      await ConversationEntryFlow.openGigBookingChat(
        context: context,
        gigBookingId: booking.id,
        buildChat: (conversation) => ChatScreen(
          conversationId: conversation.id,
          conversationContextType: "gig_booking",
          conversationParticipantId: booking.providerUserId,
          gigRequestId: conversation.gigRequestId,
          gigRequestTitle: conversation.gigRequestTitle,
          otherUserId: offer.providerUserId,
          otherUserName: name,
          otherUserInitials: StringUtils.extractInitials(name),
          otherUserAvatar: offer.providerAvatarUrl,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _bookingChatInFlight = false);
      }
    }
  }

  void _onBookThisServicePressed() {
    if (!AuthFlow.requireAuth(context)) return;
    if (widget.state.activeClientBookingForOffer != null) {
      return;
    }
    context.read<GigOfferDetailBloc>().add(const BookThisOffer());
  }

  @override
  void dispose() {
    _photoPageController?.dispose();
    super.dispose();
  }

  void _openFullscreenPhotos(int carouselIndex, List<String> orderedRawUrls) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => FullScreenPhotoViewer(
          photoUrls: orderedRawUrls,
          initialIndex: carouselIndex.clamp(0, orderedRawUrls.length - 1),
          baseUrl: EnvironmentUtil.basePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final offer = widget.state.offer;
    final existingBooking = widget.state.activeClientBookingForOffer;
    final language = LanguageState().currentLanguage;
    final rawDescription = offer.localizedDescription(language);
    final description = rawDescription == null || rawDescription.isEmpty
        ? ""
        : StringUtils.collapseExcessiveNewlines(rawDescription.trim());
    final categoryName = offer.category?.localizedName(language) ?? "";
    final publicationFormatted =
        ListingDetailDateUtils.formatPublicationDate(context, offer.createdAt);
    final orderedPhotoUrls = offer.photos.isEmpty
        ? const <String>[]
        : _orderedGigPhotoRawUrls(offer.photos);

    final topPad = 8.0 + ThemeState().mainShellGlassExtraTopInset(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16, topPad, 16, 160 + bottomInset),
          children: [
            if (offer.photos.isNotEmpty && _photoPageController != null) ...[
              Theme(
                data: Theme.of(context).copyWith(
                  cardTheme: Theme.of(context).cardTheme.copyWith(
                        // Listing detail tiles use ListingDetailTileShell + card
                        // margin 8 horizontally; gig body tiles are full-width inside
                        // the list (no shell margin). Drop left/right inset so the
                        // carousel matches ThreeDElevatedSurface width.
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                ),
                child: DetailHostedPhotoGallery(
                  orderedRawPhotoUrls: orderedPhotoUrls,
                  pageController: _photoPageController!,
                  buildPhotoUrl: EnvironmentUtil.hostedImageUrl,
                  onPhotoTapCarouselIndex: (carouselIndex) =>
                      _openFullscreenPhotos(carouselIndex, orderedPhotoUrls),
                ),
              ),
              // Match listing detail: photo tile margin bottom 8 + 4 before
              // the next section (see meta badges padding after carousel).
              const SizedBox(height: 4),
            ],
            ThreeDElevatedSurface(
              baseColor: scheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (categoryName.isNotEmpty)
                                Row(
                                  children: [
                                    if (offer.category != null) ...[
                                      GigCategoryIconBadge(
                                        icon: offer.category!.icon,
                                        iconColor: scheme.onSurface
                                            .withValues(alpha: 0.72),
                                        badgeBackgroundColor: scheme.onSurface
                                            .withValues(alpha: 0.12),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Expanded(
                                      child: Text(
                                        categoryName.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          letterSpacing: 0.5,
                                          color: scheme.onSurface
                                              .withValues(alpha: 0.72),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (categoryName.isNotEmpty)
                                const SizedBox(height: 4),
                              Text(
                                offer.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ListenableBuilder(
                          listenable: PriceDisplaySettingsState(),
                          builder: (context, _) => ListingPaymentsOutlineBadge(
                            label: _priceLine(offer),
                          ),
                        ),
                      ],
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (publicationFormatted != null) ...[
                      SizedBox(height: description.isNotEmpty ? 12 : 16),
                      Text(
                        "${L10n.get("publication_date")} $publicationFormatted",
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: scheme.onSurface.withValues(alpha: 0.62),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _GigOfferProviderBottomTile(
              offer: offer,
              scheme: scheme,
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          // Match gig request detail / listing-detail-style footer insets.
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: UserListingState().isOwner(offer.providerUserId) ||
                      widget.canStaffEditOffer
                  ? PrimaryButtonFactory.iconText(
                      onPressed: () => unawaited(widget.onEditOffer(offer)),
                      icon: Icons.edit_outlined,
                      text: L10n.get("gigs_offer_edit_cta"),
                      height: 54,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(16),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    )
                  : existingBooking != null
                      ? GlassGreenChatCtaButton(
                          onPressed: _bookingChatInFlight
                              ? null
                              : () => unawaited(
                                    _openActiveBookingChat(
                                      existingBooking,
                                      offer,
                                    ),
                                  ),
                          isLoading: _bookingChatInFlight,
                          label: L10n.getWithParams(
                            "gigs_offer_book_view_orders_cta",
                            params: {
                              "user_name": _providerDisplayName(offer),
                            },
                          ),
                          height: 54,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(16),
                          iconSize: 22,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        )
                      : PrimaryButtonFactory.iconText(
                          onPressed: widget.state.bookingInFlight
                              ? null
                              : _onBookThisServicePressed,
                          isLoading: widget.state.bookingInFlight,
                          icon: Icons.event_available_outlined,
                          text: L10n.get("gigs_offer_book_cta"),
                          height: 54,
                          width: double.infinity,
                          borderRadius: BorderRadius.circular(16),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
            ),
          ),
        ),
      ],
    );
  }

  String _priceLine(GigOffer o) {
    final display = CurrencyDisplayUtils.gigAmountForDisplay(
      amount: o.price,
      currencyCode: o.currencyCode,
    );
    final params = {
      "amount": IntFormatUtils.withDotThousands(display.amount),
      "currency": CurrencyDisplayUtils.isoCodeForBadge(display.currencyCode),
    };
    final String key;
    switch (o.pricingType) {
      case GigPricingType.hourly:
        key = "gigs_price_per_hour";
      case GigPricingType.perUnit:
        key = "gigs_price_per_unit";
      case GigPricingType.fixed:
        key = "gigs_price_fixed";
    }
    return CurrencyDisplayUtils.stripEmptyCurrencyArtifacts(
      L10n.getWithParams(key, params: params),
    );
  }
}

/// Matches [GigOfferTile] defaults when the API omits aggregates on detail load.
const double _kGigOfferDetailProviderPlaceholderRatingOutOfFive = 4.0;
const int _kGigOfferDetailProviderPlaceholderReviewCount = 16;

IconData _gigOfferDetailProviderStarIcon(
    double? averageOutOfFive, int starIndex) {
  if (averageOutOfFive == null) {
    return Icons.star_border_rounded;
  }
  final r = averageOutOfFive.clamp(0.0, 5.0);
  final remainder = r - starIndex;
  if (remainder >= 0.75) return Icons.star_rounded;
  if (remainder >= 0.25) return Icons.star_half_rounded;
  return Icons.star_border_rounded;
}

Widget _gigOfferDetailProviderRatingReviewsRow({
  required GigOffer offer,
  required ColorScheme scheme,
}) {
  final rating = offer.providerRatingAvg;
  final reviews = offer.providerRatingCount ?? 0;
  final reviewLabelCount =
      reviews > 0 ? reviews : _kGigOfferDetailProviderPlaceholderReviewCount;
  final placeholderStarColor = scheme.onSurface.withValues(alpha: 0.38);

  final mutedStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: scheme.onSurface.withValues(alpha: 0.72),
  );

  final segments = <Widget>[];

  void pushSep() {
    if (segments.isEmpty) return;
    segments.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text("·", style: mutedStyle),
      ),
    );
  }

  if (rating != null) {
    segments.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++) ...[
            Icon(
              _gigOfferDetailProviderStarIcon(rating, i),
              size: 16,
              color: Colors.amber,
            ),
            if (i < 4) const SizedBox(width: 2),
          ],
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  } else {
    final placeholderStarIcons = <Widget>[];
    for (var i = 0; i < 5; i++) {
      final icon = _gigOfferDetailProviderStarIcon(
        _kGigOfferDetailProviderPlaceholderRatingOutOfFive,
        i,
      );
      placeholderStarIcons.add(
        Icon(
          icon,
          size: 16,
          color: icon == Icons.star_border_rounded
              ? placeholderStarColor
              : Colors.amber,
        ),
      );
      if (i < 4) placeholderStarIcons.add(const SizedBox(width: 2));
    }
    segments.add(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: placeholderStarIcons,
      ),
    );
  }

  pushSep();
  segments.add(
    Text(
      L10n.plural("gigs_offer_tile_reviews", reviewLabelCount),
      style: reviews > 0
          ? mutedStyle
          : mutedStyle.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.45),
            ),
    ),
  );

  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    runSpacing: 6,
    children: segments,
  );
}

class _GigOfferProviderBottomTile extends StatelessWidget {
  const _GigOfferProviderBottomTile({
    required this.offer,
    required this.scheme,
  });

  final GigOffer offer;
  final ColorScheme scheme;

  int get _completedJobs =>
      offer.providerCompletedJobsCount ??
      offer.providerProfile?.completedJobsCount ??
      0;

  String get _displayName {
    final n = offer.providerDisplayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    return L10n.get("gigs_offer_provider_fallback");
  }

  @override
  Widget build(BuildContext context) {
    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: Material(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedbackUtils.selection();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) =>
                      ListingOwnerProfileBloc(getIt<IUserProfileService>()),
                  child: ListingOwnerProfileScreen(
                    userId: offer.providerUserId,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: offer.providerAvatarUrl != null
                      ? CachedNetworkImageProvider(
                          EnvironmentUtil.hostedImageUrl(
                            offer.providerAvatarUrl!,
                          ),
                        )
                      : null,
                  child: offer.providerAvatarUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: scheme.onSurface.withValues(alpha: 0.45),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _gigOfferDetailProviderRatingReviewsRow(
                        offer: offer,
                        scheme: scheme,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        L10n.getWithParams(
                          "gigs_offer_provider_completed_jobs",
                          params: {"count": _completedJobs.toString()},
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface.withValues(alpha: 0.72),
                        ),
                      ),
                    ],
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
