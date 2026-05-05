import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/state/language_state.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offers_bloc.dart";

class GigOffersScreen extends StatefulWidget {
  const GigOffersScreen({super.key});

  @override
  State<GigOffersScreen> createState() => _GigOffersScreenState();
}

class _GigOffersScreenState extends State<GigOffersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<GigOffersBloc>().add(const FetchGigOffers());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GigOffersBloc>().add(const LoadMoreGigOffers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browse services")),
      body: BlocBuilder<GigOffersBloc, GigOffersState>(
        builder: (context, state) {
          if (state is GigOffersLoading || state is GigOffersInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GigOffersError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<GigOffersBloc>().add(const FetchGigOffers()),
            );
          }
          if (state is GigOffersLoaded) {
            if (state.offers.isEmpty) {
              return const Center(
                child: Text("No services available yet."),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<GigOffersBloc>()
                    .add(const FetchGigOffers(refresh: true));
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: state.offers.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  if (i >= state.offers.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _OfferTile(offer: state.offers[i]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer});

  final GigOffer offer;

  @override
  Widget build(BuildContext context) {
    final language = LanguageState().currentLanguage;
    final categoryName = offer.category?.localizedName(language) ?? "";
    final photo = offer.primaryPhotoUrl();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushGigOfferDetail(offer.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: photo != null
                      ? CachedNetworkImage(
                          imageUrl: photo,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) =>
                              Container(color: Colors.grey.shade200),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryName.isNotEmpty)
                      Text(
                        categoryName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    Text(
                      offer.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(offer),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (offer.providerRatingAvg != null) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            offer.providerRatingAvg!.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (offer.providerRatingCount != null) ...[
                            Text(
                              " (${offer.providerRatingCount})",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                        ],
                        if (offer.providerDisplayName != null)
                          Expanded(
                            child: Text(
                              offer.providerDisplayName!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(GigOffer o) {
    final amount = "${o.price} ${o.currencyCode}";
    switch (o.pricingType) {
      case GigPricingType.hourly:
        return "$amount/hr";
      case GigPricingType.perUnit:
        return "$amount/unit";
      case GigPricingType.fixed:
        return amount;
    }
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}
