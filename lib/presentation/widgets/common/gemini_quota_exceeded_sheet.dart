import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/screens/profile/ai_premium_placeholder_screen.dart";

/// Strong upsell when server returns `gemini_quota_exceeded`.
class GeminiQuotaExceededSheet {
  GeminiQuotaExceededSheet._();

  static Future<void> show(BuildContext context) async {
    final navigator = Navigator.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
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
              FilledButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  navigator.push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => const AiPremiumPlaceholderScreen(),
                    ),
                  );
                },
                child: Text(L10n.get("ai_allowance_upgrade_cta")),
              ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(L10n.get("ai_quota_exceeded_sheet_dismiss")),
              ),
            ],
          ),
        );
      },
    );
  }
}
