import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";

/// Full-screen error when listing detail fails to load (standard retry column).
class ListingDetailFetchErrorBody extends StatelessWidget {
  const ListingDetailFetchErrorBody({
    required this.onRetry,
    super.key,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return UydoshErrorRetryColumn(
      icon: Icons.wifi_off_rounded,
      title: L10n.get("error_loading_listing_details"),
      message: L10n.get("error_internet_connection"),
      padding: const EdgeInsets.all(24),
      spacingBeforeButton: 24,
      onRetry: onRetry,
    );
  }
}
