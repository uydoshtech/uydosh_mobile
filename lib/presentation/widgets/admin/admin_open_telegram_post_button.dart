import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/telegram_post_link.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/domain/services/listing_parser_review_admin_service.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";

/// Compact icon button for admin Telegram-listing screens that opens the
/// original scraped post in Telegram.
///
/// The listings shown on those screens only carry [Listing] data (no chat/
/// message identity), so the raw source is resolved lazily on tap via
/// `/admin/listings/{id}/parser-review` rather than being fetched for every
/// tile up front.
class AdminOpenTelegramPostButton extends StatefulWidget {
  const AdminOpenTelegramPostButton({required this.listingId, super.key});

  final int listingId;

  @override
  State<AdminOpenTelegramPostButton> createState() =>
      _AdminOpenTelegramPostButtonState();
}

class _AdminOpenTelegramPostButtonState
    extends State<AdminOpenTelegramPostButton> {
  bool _loading = false;

  Future<void> _openPost() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final bundle = await getIt<IListingParserReviewAdminService>()
          .getParserReview(widget.listingId);
      final rawSource = bundle.rawSource;
      final link = buildTelegramPostLink(
        chatKey: rawSource?.chatKey,
        telegramMessageId: rawSource?.telegramMessageId,
      );
      if (link == null) {
        if (mounted) {
          ToastReporting.errorKey(
            context,
            "admin_telegram_listing_groups_open_post_missing",
          );
        }
        return;
      }
      final opened = await openTelegramPostLink(link);
      if (!opened && mounted) {
        ToastReporting.errorKey(context, "could_not_open_telegram");
      }
    } catch (e) {
      logger.d(
        "Failed to open telegram post for listing ${widget.listingId}: $e",
      );
      if (mounted) {
        ToastReporting.errorKey(context, "could_not_open_telegram");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Blue theme's `colorScheme.primary` is a very dark navy (#1E3A5F) —
    // nearly identical to the tile background — so plain `scheme.primary`
    // renders an all-but-invisible icon there. Use the light text color
    // instead on that theme, matching other blue-theme row accents (e.g.
    // [Room3dIconBadge]).
    final isBlueTheme = ThemeState().isBlueTheme;
    final accentColor =
        isBlueTheme ? BlueThemeColors.textPrimary : scheme.primary;
    return Tooltip(
      message: L10n.get("admin_telegram_listing_groups_open_post_tooltip"),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _loading ? null : _openPost,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: UydoshLogoSpinner(size: 16),
                )
              : ThemeIcon(
                  Icons.telegram,
                  size: 16,
                  color: accentColor,
                  useThemeColor: false,
                ),
        ),
      ),
    );
  }
}
