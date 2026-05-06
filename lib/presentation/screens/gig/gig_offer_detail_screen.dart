import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart" show ThemeHelper;
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offer_detail_bloc.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/detail_hosted_photo_gallery.dart";
import "package:uy_dosh/presentation/widgets/common/full_screen_photo_viewer.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";
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
  @override
  void initState() {
    super.initState();
    // Same as listings: owner checks need a loaded user id. Gigs are reachable
    // from the tab bar without visiting Home first, so initialize here.
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    context.read<GigOfferDetailBloc>().add(FetchGigOfferDetail(widget.offerId));
  }

  Future<void> _editOffer(GigOffer offer) async {
    final detailBloc = context.read<GigOfferDetailBloc>();
    final updated = await context.pushEditGigOffer(offer);
    if (updated != null && mounted) {
      detailBloc.add(FetchGigOfferDetail(offer.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserListingState(),
      builder: (context, _) {
        return BlocConsumer<GigOfferDetailBloc, GigOfferDetailState>(
          listener: (context, state) {
            if (state is GigOfferBookingCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(L10n.get("gigs_booking_created_toast"))),
              );
              context.pushMyGigBookings();
            } else if (state is GigOfferDetailError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            final offerForMenu =
                state is GigOfferDetailLoaded ? state.offer : null;
            final showOwnerActions = offerForMenu != null &&
                UserListingState().isOwner(offerForMenu.providerUserId);
            return Scaffold(
              appBar: AppBar(
                leading: ThreeDAppBarIconButton.backLeading(context),
                title: Text(L10n.get("gigs_offer_detail_title")),
                actions: [
                  if (showOwnerActions)
                    ActionDropdownMenu(
                      padding: const EdgeInsets.only(right: 12),
                      items: [
                        ActionMenuItem(
                          value: "edit_offer",
                          icon: Icons.edit_outlined,
                          textKey: "gigs_offer_edit_cta",
                          onPressed: () => unawaited(_editOffer(offerForMenu)),
                        ),
                      ],
                    ),
                ],
              ),
              body: _buildBody(context, state),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, GigOfferDetailState state) {
    if (state is GigOfferDetailLoading || state is GigOfferDetailInitial) {
      return const Center(child: CircularProgressIndicator());
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
  });
  final GigOfferDetailLoaded state;
  final Future<void> Function(GigOffer offer) onEditOffer;

  @override
  State<_OfferDetailContentStateful> createState() =>
      _OfferDetailContentStatefulState();
}

class _OfferDetailContentStatefulState
    extends State<_OfferDetailContentStateful> {
  PageController? _photoPageController;

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
    final language = LanguageState().currentLanguage;
    final description = offer.localizedDescription(language) ?? "";
    final categoryName = offer.category?.localizedName(language) ?? "";
    final orderedPhotoUrls = offer.photos.isEmpty
        ? const <String>[]
        : _orderedGigPhotoRawUrls(offer.photos);

    final topPad =
        8.0 + ThemeState().mainShellGlassExtraTopInset(context);

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16, topPad, 16, 152),
          children: [
            if (offer.photos.isNotEmpty &&
                _photoPageController != null) ...[
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
                    if (categoryName.isNotEmpty)
                      Row(
                        children: [
                          if (offer.category != null) ...[
                            Icon(
                              offer.category!.icon,
                              size: 14,
                              color: scheme.onSurface.withValues(alpha: 0.72),
                            ),
                            const SizedBox(width: 6),
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
                    const SizedBox(height: 4),
                    Text(
                      offer.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListingPaymentsOutlineBadge(
                      label: _priceLine(offer),
                    ),
                  ],
                ),
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 14),
              ThreeDElevatedSurface(
                baseColor: scheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L10n.get("gigs_offer_about"),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            _GigOfferProviderBottomTile(
              offer: offer,
              scheme: scheme,
            ),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          // Owners can't book their own offer — swap the booking CTA for
          // an edit entry point that opens the publish screen prefilled
          // from this offer. After a successful save we re-fetch the
          // detail so the screen reflects the new state immediately.
          child: UserListingState().isOwner(offer.providerUserId)
              ? PrimaryButton(
                  onPressed: () =>
                      unawaited(widget.onEditOffer(offer)),
                  height: 54,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(16),
                  child: Text(
                    L10n.get("gigs_offer_edit_cta"),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                )
              : PrimaryButton(
                  onPressed: widget.state.bookingInFlight
                      ? null
                      : () => context
                          .read<GigOfferDetailBloc>()
                          .add(const BookThisOffer()),
                  isLoading: widget.state.bookingInFlight,
                  height: 54,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(16),
                  child: Text(
                    L10n.get("gigs_offer_book_cta"),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  String _priceLine(GigOffer o) {
    final params = {"amount": o.price.toString(), "currency": o.currencyCode};
    switch (o.pricingType) {
      case GigPricingType.hourly:
        return L10n.getWithParams("gigs_price_per_hour", params: params);
      case GigPricingType.perUnit:
        return L10n.getWithParams("gigs_price_per_unit", params: params);
      case GigPricingType.fixed:
        return L10n.getWithParams("gigs_price_fixed", params: params);
    }
  }
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
                  if (offer.providerRatingAvg != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${offer.providerRatingAvg!.toStringAsFixed(1)} "
                          "(${offer.providerRatingCount ?? 0})",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
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
    );
  }
}
