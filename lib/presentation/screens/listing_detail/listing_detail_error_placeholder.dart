import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";

/// Full-screen error when listing detail fails to load (standard retry column).
///
/// Shows the actual (already-sanitized) failure [message] from the bloc when
/// available, instead of always claiming it's a connectivity problem — a 404
/// (listing removed), 401 (session expired), or 500 (server error) each need
/// different follow-up from the user, and lying about the cause makes the
/// retry button useless and support reports harder to triage.
class ListingDetailFetchErrorBody extends StatelessWidget {
  const ListingDetailFetchErrorBody({
    required this.onRetry,
    this.message,
    super.key,
  });

  final VoidCallback onRetry;

  /// Sanitized error message from [ListingDetailState.error]. Falls back to
  /// the generic "check your connection" copy when absent.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final trimmedMessage = message?.trim();
    final hasSpecificMessage =
        trimmedMessage != null && trimmedMessage.isNotEmpty;
    final networkCopy = L10n.get("error_internet_connection");
    final isNetworkMessage =
        !hasSpecificMessage || trimmedMessage == networkCopy;

    return UydoshErrorRetryColumn(
      icon: isNetworkMessage ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: L10n.get("error_loading_listing_details"),
      message: hasSpecificMessage ? trimmedMessage : networkCopy,
      padding: const EdgeInsets.all(24),
      spacingBeforeButton: 24,
      onRetry: onRetry,
    );
  }
}
