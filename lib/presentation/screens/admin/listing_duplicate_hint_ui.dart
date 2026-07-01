import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/listing_duplicate_hint.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";

Future<bool?> confirmListingApproveWithDuplicateHint({
  required BuildContext context,
  required ListingDuplicateHint? duplicateHint,
}) {
  if (duplicateHint?.isHigh != true) {
    return ConfirmationDialog.show(
      context: context,
      titleKey: "admin_listing_moderation_approve_confirm_title",
      messageKey: "admin_listing_moderation_approve_confirm_message",
      confirmButtonKey: "admin_listing_moderation_approve",
      cancelButtonKey: "cancel",
    );
  }

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      return UydoshGlassDialog(
        title: Text(
          L10n.get("admin_listing_duplicate_approve_title"),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        content: Text(
          duplicateHint!.approveMessage(),
          style: TextStyle(
            fontSize: 16,
            color: ThemeState().isLightTheme
                ? Colors.black
                : scheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButtonThemed(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(L10n.get("cancel")),
          ),
          TextButtonThemed(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              L10n.get("admin_listing_moderation_approve"),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
}

Widget listingDuplicateHintBadge(
  BuildContext context,
  ListingDuplicateHint hint,
) {
  final scheme = Theme.of(context).colorScheme;
  final bg = hint.isHigh
      ? scheme.errorContainer.withValues(alpha: 0.55)
      : scheme.tertiaryContainer.withValues(alpha: 0.45);
  final fg = hint.isHigh ? scheme.onErrorContainer : scheme.onTertiaryContainer;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: fg.withValues(alpha: 0.35)),
    ),
    child: Text(
      hint.badgeLabel(),
      style: TextStyle(
        color: fg,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
