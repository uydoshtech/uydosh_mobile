import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";

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
      appBar: AppBar(title: const Text("Open tasks")),
      body: FutureBuilder<({List<GigRequest> requests, bool hasMore})>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          final requests = snap.data?.requests ?? const <GigRequest>[];
          if (requests.isEmpty) {
            return const Center(child: Text("No open tasks right now."));
          }
          final language = LanguageState().currentLanguage;
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final r = requests[i];
              final categoryName = r.category?.localizedName(language) ?? "";
              return Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categoryName.isNotEmpty) Text(categoryName),
                      Text(
                        r.budgetAmount != null
                            ? "Budget: ${r.budgetAmount} ${r.currencyCode}"
                            : "Open budget",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
