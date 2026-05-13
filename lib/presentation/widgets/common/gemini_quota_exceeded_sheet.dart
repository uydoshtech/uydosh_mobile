import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/screens/profile/ai_premium_placeholder_screen.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";

/// Strong upsell when server returns `gemini_quota_exceeded`.
class GeminiQuotaExceededSheet {
  GeminiQuotaExceededSheet._();

  static Future<void> show(BuildContext context) async {
    final navigator = Navigator.of(context);
    final theme = Theme.of(context);
    await showAppBottomSheet<void>(
      context: context,
      showDragHandle: true,
      cardColor: theme.bottomSheetTheme.modalBackgroundColor ??
          theme.colorScheme.surfaceContainerLow,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 8, 24, bottomInset + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                L10n.get("ai_quota_exceeded_sheet_title"),
                style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                L10n.get("ai_quota_exceeded_sheet_body"),
                style: Theme.of(sheetContext).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    navigator.push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const AiPremiumPlaceholderScreen(),
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  borderRadius: BorderRadius.circular(12),
                  child: Text(L10n.get("ai_allowance_upgrade_cta")),
                ),
              ),
              Center(
                child: TextButtonThemed(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(L10n.get("ai_quota_exceeded_sheet_dismiss")),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
