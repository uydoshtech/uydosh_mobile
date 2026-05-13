import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";

/// Profile discovery card for AI monthly quotas and premium upsell.
class AiAllowanceUpsellBanner extends StatelessWidget {
  const AiAllowanceUpsellBanner({
    required this.snapshot,
    required this.isLoading,
    required this.hideListingGeminiUi,
    required this.onUpgradeTap,
    super.key,
  });

  final ListingAiQuotaSnapshot? snapshot;
  final bool isLoading;
  final bool hideListingGeminiUi;
  final VoidCallback onUpgradeTap;

  String _formatPremiumEnd(DateTime d) {
    final lang = L10n.currentLanguage;
    final locale = lang == "uz" ? "uz_UZ" : lang;
    try {
      return DateFormat.yMMMd(locale).format(d.toLocal());
    } catch (_) {
      return DateFormat.yMMMd().format(d.toLocal());
    }
  }

  bool _allMetersUnlimited(ListingAiQuotaSnapshot s) {
    return s.isUnlimitedMeter(s.translateRemaining) &&
        s.isUnlimitedMeter(s.enhanceRemaining) &&
        s.isUnlimitedMeter(s.chatTranslateRemaining);
  }

  /// True when [build] will lay out non-zero height (loading placeholder or card).
  static bool willShowContent({
    required ListingAiQuotaSnapshot? snapshot,
    required bool isLoading,
  }) {
    if (isLoading) {
      return true;
    }
    final snap = snapshot;
    if (snap == null) {
      return false;
    }
    return !(snap.isUnlimitedMeter(snap.translateRemaining) &&
        snap.isUnlimitedMeter(snap.enhanceRemaining) &&
        snap.isUnlimitedMeter(snap.chatTranslateRemaining));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return ListingDetailTileShell(
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 56,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
          ),
        ),
      );
    }

    final snap = snapshot;
    if (snap == null) {
      return const SizedBox.shrink();
    }

    if (_allMetersUnlimited(snap)) {
      return const SizedBox.shrink();
    }

    final premiumActive = snap.isPremiumActive;

    final rows = <Widget>[];

    if (premiumActive && snap.premiumUntil != null) {
      rows.add(
        Text(
          L10n.getWithParams(
            "ai_allowance_premium_active_until",
            params: {"date": _formatPremiumEnd(snap.premiumUntil!)},
          ),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    }

    void addMeterLine(String key, int remaining) {
      if (snap.isUnlimitedMeter(remaining)) {
        rows.add(
          Text(
            "${L10n.get(key)} · ${L10n.get("ai_allowance_meter_unlimited")}",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
        return;
      }
      rows.add(
        Text(
          L10n.getWithParams(
            key,
            params: {"count": "$remaining"},
          ),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    if (!hideListingGeminiUi) {
      addMeterLine("ai_allowance_meter_translate", snap.translateRemaining);
      addMeterLine("ai_allowance_meter_enhance", snap.enhanceRemaining);
    }
    addMeterLine("ai_allowance_meter_chat", snap.chatTranslateRemaining);

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final showUpgrade = !premiumActive;

    return ListingDetailTileShell(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.get("ai_allowance_banner_title"),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1) const SizedBox(height: 4),
            ],
            if (rows.isNotEmpty) const SizedBox(height: 6),
            Text(
              L10n.get("ai_allowance_month_reset_note"),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            if (showUpgrade) ...[
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: GhostButton(
                  onPressed: onUpgradeTap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  borderWidth: 1.5,
                  child: Text(
                    L10n.get("ai_allowance_upgrade_cta"),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
