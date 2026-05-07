import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_bookings_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offer_detail_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_offers_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_offer_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_request_bloc.dart";
import "package:uy_dosh/presentation/screens/gig/gig_hub_screen.dart";
import "package:uy_dosh/presentation/screens/gig/gig_offer_detail_screen.dart";
import "package:uy_dosh/presentation/screens/gig/gig_offers_screen.dart";
import "package:uy_dosh/presentation/screens/gig/gig_request_detail_screen.dart";
import "package:uy_dosh/presentation/screens/gig/gig_requests_list_screen.dart";
import "package:uy_dosh/presentation/screens/gig/my_gig_bookings_screen.dart";
import "package:uy_dosh/presentation/screens/gig/post_gig_offer_screen.dart";
import "package:uy_dosh/presentation/screens/gig/post_gig_request_screen.dart";
import "package:uy_dosh/presentation/screens/gig/publish_gig_screen.dart";

/// Navigation helpers for the gig module. Mirrors the listing pattern in
/// `navigation_extensions.dart`: each push wires the BLoCs the destination
/// screen needs from `getIt`.
extension GigNavigatorExtensions on BuildContext {
  void pushGigHub() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(builder: (_) => const GigHubScreen()),
    );
  }

  void pushGigOffersList() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => GigOffersBloc(getIt<IGigService>()),
          child: const GigOffersScreen(),
        ),
      ),
    );
  }

  void pushGigOfferDetail(int offerId) {
    Navigator.of(this).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => GigOfferDetailBloc(getIt<IGigService>()),
          child: GigOfferDetailScreen(offerId: offerId),
        ),
      ),
    );
  }

  void pushPostGigRequest() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => GigPostRequestBloc(getIt<IGigService>()),
          child: const PostGigRequestScreen(),
        ),
      ),
    );
  }

  void pushPostGigOffer() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => GigPostOfferBloc(getIt<IGigService>()),
          child: const PostGigOfferScreen(),
        ),
      ),
    );
  }

  /// Owner-only entry point: opens [PublishGigScreen] in edit mode for the
  /// given service. The screen pops with the updated [GigOffer] on success
  /// (or `null` on dismiss / cancel) so the caller can rebuild from fresh
  /// state without a follow-up GET.
  Future<GigOffer?> pushEditGigOffer(GigOffer offer) {
    return Navigator.of(this).push<GigOffer>(
      MaterialPageRoute<GigOffer>(
        builder: (_) => MultiBlocProvider(
          providers: [
            // Edit mode locks to the service flavor so the request bloc is
            // unused — but [PublishGigScreen]'s `MultiBlocListener`/builders
            // still read it. Provide a no-op instance to keep the screen
            // shape identical between create and edit.
            BlocProvider(
              create: (_) => GigPostRequestBloc(getIt<IGigService>()),
            ),
            BlocProvider(
              create: (_) => GigPostOfferBloc(getIt<IGigService>()),
            ),
          ],
          child: PublishGigScreen(
            initialMode: GigPublishMode.service,
            editingOffer: offer,
          ),
        ),
      ),
    );
  }

  /// Opens [PublishGigScreen] in edit-task mode for the request author while
  /// the task is still [GigRequestStatus.open]. Returns the updated request.
  Future<GigRequest?> pushEditGigRequest(GigRequest request) {
    return Navigator.of(this).push<GigRequest>(
      MaterialPageRoute<GigRequest>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => GigPostRequestBloc(getIt<IGigService>()),
            ),
            BlocProvider(
              create: (_) => GigPostOfferBloc(getIt<IGigService>()),
            ),
          ],
          child: PublishGigScreen(
            initialMode: GigPublishMode.task,
            editingRequest: request,
          ),
        ),
      ),
    );
  }

  /// Unified publish flow: opens [PublishGigScreen] with both the request
  /// and offer blocs in scope so the in-screen Task/Service toggle can
  /// switch flavors without re-pushing a route. The hub uses this in place
  /// of the legacy [pushPostGigRequest] / [pushPostGigOffer] entry points.
  void pushPublishGig({GigPublishMode initialMode = GigPublishMode.task}) {
    Navigator.of(this).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => GigPostRequestBloc(getIt<IGigService>()),
            ),
            BlocProvider(
              create: (_) => GigPostOfferBloc(getIt<IGigService>()),
            ),
          ],
          child: PublishGigScreen(initialMode: initialMode),
        ),
      ),
    );
  }

  void pushMyGigBookings() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => GigBookingsBloc(getIt<IGigService>()),
          child: const MyGigBookingsScreen(),
        ),
      ),
    );
  }

  void pushGigRequestsList() {
    Navigator.of(this).push(
      MaterialPageRoute<void>(
        builder: (_) => const GigRequestsListScreen(),
      ),
    );
  }

  /// Returns `true` when the request was cancelled/removed by the viewer (owner).
  Future<bool?> pushGigRequestDetail(int requestId) {
    return Navigator.of(this).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => GigRequestDetailScreen(requestId: requestId),
      ),
    );
  }
}
