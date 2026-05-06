import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
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

  @override
  void initState() {
    super.initState();
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
          final requests = snap.data?.requests ?? const <GigRequest>[];
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
            itemBuilder: (_, i) => GigRequestTile(request: requests[i]),
          );
        },
      ),
    );
  }
}
