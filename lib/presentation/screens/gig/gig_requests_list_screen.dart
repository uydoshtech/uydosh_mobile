import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

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
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(L10n.get("gigs_requests_title"))),
      body: FutureBuilder<({List<GigRequest> requests, bool hasMore})>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(L10n.get("gigs_requests_empty")),
              ),
            );
          }
          final language = LanguageState().currentLanguage;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final r = requests[i];
              final categoryName = r.category?.localizedName(language) ?? "";
              final budgetLine = r.budgetAmount != null
                  ? L10n.getWithParams(
                      "gigs_request_budget_fixed",
                      params: {
                        "amount": r.budgetAmount!.toString(),
                        "currency": r.currencyCode,
                      },
                    )
                  : L10n.get("gigs_request_budget_open");
              return ThreeDElevatedSurface(
                baseColor: scheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                        r.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        budgetLine,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: 0.75),
                        ),
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
