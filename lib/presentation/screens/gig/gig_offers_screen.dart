import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offers_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_feed_tile_swipe_wrapper.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_offer_tile.dart";

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
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    _scrollController.addListener(_onScroll);
    context.read<GigOffersBloc>().add(const FetchGigOffers());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<GigOffersBloc>().add(const LoadMoreGigOffers());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(L10n.get("gigs_browse_title")),
      ),
      body: BlocBuilder<GigOffersBloc, GigOffersState>(
        builder: (context, state) {
          if (state is GigOffersLoading || state is GigOffersInitial) {
            return const Center(child: HouseLoadingIndicator());
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
              return UydoshEmptyColumn(
                icon: Icons.handyman_outlined,
                title: L10n.get("gigs_browse_empty"),
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: state.offers.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (_, i) {
                  if (i >= state.offers.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: HouseLoadingIndicator()),
                    );
                  }
                  final offer = state.offers[i];
                  return ListenableBuilder(
                    listenable: UserListingState(),
                    builder: (context, _) {
                      return GigFeedTileSwipeWrapper(
                        entityId: offer.id,
                        enabled: UserListingState().isOwner(offer.providerUserId),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                        dismissKeyPrefix: "gig-offer-browse",
                        confirmTitleKey: "gigs_offer_delete_title",
                        confirmMessageKey: "gigs_offer_delete_message",
                        successMessageKey: "gigs_offer_delete_success",
                        errorMessageKey: "gigs_offer_delete_failed",
                        onConfirmDelete: (s) => s.deleteOffer(offer.id),
                        onRemovedFromList: () {
                          context.read<GigOffersBloc>().add(
                                RemoveGigOfferFromList(offer.id),
                              );
                        },
                        child: GigOfferTile(offer: offer),
                      );
                    },
                  );
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
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PrimaryButtonFactory.text(
              onPressed: onRetry,
              text: L10n.get("gigs_retry"),
            ),
          ],
        ),
      ),
    );
  }
}
