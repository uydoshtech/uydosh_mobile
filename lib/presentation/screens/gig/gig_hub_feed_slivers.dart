import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";

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
      child: UydoshErrorRetryColumn(
        icon: Icons.error_outline_rounded,
        iconSize: 48,
        message: message,
        onRetry: onRetry,
        retryLabel: L10n.get("gigs_retry"),
        padding: const EdgeInsets.all(24),
      ),
    );
  }
}
