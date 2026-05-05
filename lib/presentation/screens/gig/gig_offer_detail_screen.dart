import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/state/language_state.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offer_detail_bloc.dart";

class GigOfferDetailScreen extends StatefulWidget {
  const GigOfferDetailScreen({super.key, required this.offerId});
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
            const SnackBar(content: Text("Booking created.")),
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
          appBar: AppBar(title: const Text("Service")),
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
    final offer = state.offer;
    final language = LanguageState().currentLanguage;
    final description = offer.localizedDescription(language) ?? "";
    final categoryName = offer.category?.localizedName(language) ?? "";

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            if (offer.photos.isNotEmpty)
              SizedBox(
                height: 200,
                child: PageView.builder(
                  itemCount: offer.photos.length,
                  itemBuilder: (_, i) => CachedNetworkImage(
                    imageUrl: offer.photos[i].photoUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (categoryName.isNotEmpty)
              Text(
                categoryName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              offer.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _priceLine(offer),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (offer.providerDisplayName != null)
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: offer.providerAvatarUrl != null
                        ? CachedNetworkImageProvider(offer.providerAvatarUrl!)
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (offer.providerRatingAvg != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${offer.providerRatingAvg!.toStringAsFixed(1)} "
                                "(${offer.providerRatingCount ?? 0})",
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (description.isNotEmpty) ...[
              const Text(
                "About this service",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(description),
            ],
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: state.bookingInFlight
                  ? null
                  : () => context
                      .read<GigOfferDetailBloc>()
                      .add(const BookThisOffer()),
              child: state.bookingInFlight
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Book this service"),
            ),
          ),
        ),
      ],
    );
  }

  String _priceLine(GigOffer o) {
    switch (o.pricingType) {
      case GigPricingType.hourly:
        return "${o.price} ${o.currencyCode}/hr";
      case GigPricingType.perUnit:
        return "${o.price} ${o.currencyCode}/unit";
      case GigPricingType.fixed:
        return "${o.price} ${o.currencyCode}";
    }
  }
}
