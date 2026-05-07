import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_feed_tile_swipe_wrapper.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_request_tile.dart";

/// Lightweight FutureBuilder-based list of open client tasks. No bloc — this
/// is a read-only browse surface that providers use to discover work.
class GigRequestsListScreen extends StatefulWidget {
  const GigRequestsListScreen({super.key});

  @override
  State<GigRequestsListScreen> createState() => _GigRequestsListScreenState();
}

class _GigRequestsListScreenState extends State<GigRequestsListScreen> {
  late Future<({List<GigRequest> requests, bool hasMore})> _future;
  final Set<int> _removedRequestIds = {};

  @override
  void initState() {
    super.initState();
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    _future = getIt<IGigService>().listRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(L10n.get("gigs_requests_title")),
      ),
      body: FutureBuilder<({List<GigRequest> requests, bool hasMore})>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: HouseLoadingIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(snap.error.toString()),
              ),
            );
          }
          final raw = snap.data?.requests ?? const <GigRequest>[];
          final requests =
              raw.where((r) => !_removedRequestIds.contains(r.id)).toList();
          if (requests.isEmpty) {
            return UydoshEmptyColumn(
              icon: Icons.assignment_outlined,
              title: L10n.get("gigs_requests_empty"),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final request = requests[i];
              return ListenableBuilder(
                listenable: UserListingState(),
                builder: (context, _) {
                  final isOwner = UserListingState().isOwner(
                        request.clientUserId,
                      ) &&
                      request.status == GigRequestStatus.open;
                  return GigFeedTileSwipeWrapper(
                    entityId: request.id,
                    enabled: isOwner,
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    dismissKeyPrefix: "gig-request-browse",
                    confirmTitleKey: "gigs_request_delete_title",
                    confirmMessageKey: "gigs_request_delete_message",
                    successMessageKey: "gigs_request_delete_success",
                    errorMessageKey: "gigs_request_delete_failed",
                    onConfirmDelete: (s) => s.cancelRequest(request.id),
                    onRemovedFromList: () {
                      setState(() {
                        _removedRequestIds.add(request.id);
                      });
                    },
                    child: GigRequestTile(
                      request: request,
                      onDetailClosed: (taskWasRemoved) {
                        if (!taskWasRemoved) return;
                        setState(() {
                          _future = getIt<IGigService>().listRequests();
                        });
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
