import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Admin-only tile that surfaces a listing's `contact_telegram` and
/// `contact_phone` even when the current user is the listing's owner.
///
/// Non-admin owners intentionally don't see contact controls (the regular
/// CTA bar / compatibility section are hidden, since you don't message
/// yourself). Admins, however, often need to verify or reach out to the
/// listing's contact channels regardless of who created the post — for
/// listings auto-imported under an admin account, the admin is the owner
/// but the contacts belong to the original poster.
///
/// Renders nothing when both contact fields are empty so we don't show an
/// empty card.
class ListingDetailAdminContactInfo extends StatelessWidget {
  const ListingDetailAdminContactInfo({
    required this.contactTelegram,
    required this.contactPhone,
    required this.onTelegram,
    required this.onPhone,
    super.key,
  });

  final String? contactTelegram;
  final String? contactPhone;
  final ValueChanged<String> onTelegram;
  final ValueChanged<String> onPhone;

  @override
  Widget build(BuildContext context) {
    final telegram = contactTelegram?.trim() ?? "";
    final phone = contactPhone?.trim() ?? "";
    if (telegram.isEmpty && phone.isEmpty) return const SizedBox.shrink();

    final dividerColor =
        Theme.of(context).dividerColor.withValues(alpha: 0.35);

    final rows = <Widget>[];
    if (telegram.isNotEmpty) {
      rows.add(
        _AdminContactRow(
          icon: Icons.telegram,
          label: telegram.startsWith("@") ? telegram : "@$telegram",
          onTap: () {
            HapticFeedbackUtils.impact();
            onTelegram(telegram);
          },
        ),
      );
    }
    if (phone.isNotEmpty) {
      if (rows.isNotEmpty) {
        rows.add(Divider(height: 1, thickness: 0.5, color: dividerColor));
      }
      rows.add(
        _AdminContactRow(
          icon: Icons.phone,
          label: phone,
          onTap: () {
            HapticFeedbackUtils.impact();
            onPhone(phone);
          },
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ListingDetailTileShell(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 6),
              child: Row(
                children: [
                  ThemeIcon(
                    Icons.shield_outlined,
                    size: 18,
                    color: ListingDetailThemeHelper.iconColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      L10n.get("admin_listing_contacts"),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 0.5, color: dividerColor),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _AdminContactRow extends StatelessWidget {
  const _AdminContactRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
        child: Row(
          children: [
            ThemeIcon(
              icon,
              color: ListingDetailThemeHelper.iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ListingDetailThemeHelper.dateTextColor,
                ),
              ),
            ),
            ThemeIcon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
