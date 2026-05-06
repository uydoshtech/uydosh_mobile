import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offer_detail_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
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
    context.read<GigOfferDetailBloc>().add(FetchGigOfferDetail(widget.offerId));
  }

  @override
  Widget build(BuildContext context) {
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
        return Scaffold(
          appBar: AppBar(title: Text(L10n.get("gigs_offer_detail_title"))),
          body: _buildBody(context, state),
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
      return _OfferDetailContent(state: state);
    }
    return const SizedBox.shrink();
  }
}

class _OfferDetailContent extends StatelessWidget {
  const _OfferDetailContent({required this.state});
  final GigOfferDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final offer = state.offer;
    final language = LanguageState().currentLanguage;
    final description = offer.localizedDescription(language) ?? "";
    final categoryName = offer.category?.localizedName(language) ?? "";

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
          children: [
            if (offer.photos.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 220,
                  child: PageView.builder(
                    itemCount: offer.photos.length,
                    itemBuilder: (_, i) => CachedNetworkImage(
                      imageUrl: offer.photos[i].photoUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ThreeDElevatedSurface(
              baseColor: scheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryName.isNotEmpty)
                      Text(
                        categoryName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
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
                    Text(
                      _priceLine(offer),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (offer.providerDisplayName != null)
              ThreeDElevatedSurface(
                baseColor: scheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage: offer.providerAvatarUrl != null
                            ? CachedNetworkImageProvider(
                                offer.providerAvatarUrl!,
                              )
                            : null,
                        child: offer.providerAvatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offer.providerDisplayName!,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                            if (offer.providerRatingAvg != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${offer.providerRatingAvg!.toStringAsFixed(1)} "
                                      "(${offer.providerRatingCount ?? 0})",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: scheme.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: PrimaryButton(
            onPressed: state.bookingInFlight
                ? null
                : () => context
                    .read<GigOfferDetailBloc>()
                    .add(const BookThisOffer()),
            isLoading: state.bookingInFlight,
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
