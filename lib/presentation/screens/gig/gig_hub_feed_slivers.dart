import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";

class GigHubLoadingSliver extends StatelessWidget {
  const GigHubLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: HouseLoadingIndicator()),
      ),
    );
  }
}

class GigHubLoadingMoreFooter extends StatelessWidget {
  const GigHubLoadingMoreFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: HouseLoadingIndicator()),
    );
  }
}

class GigHubEmptySliver extends StatelessWidget {
  const GigHubEmptySliver({
    required this.icon,
    required this.message,
    required this.bottomPadding,
    super.key,
  });

  final IconData icon;
  final String message;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: UydoshEmptyColumn(icon: icon, title: message),
      ),
    );
  }
}

class GigHubErrorSliver extends StatelessWidget {
  const GigHubErrorSliver({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
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
