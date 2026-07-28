import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";

class SuspiciousMessageBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<String> reasons,
    required VoidCallback onCopyPressed,
    VoidCallback? onReportPressed,
    VoidCallback? onBlockPressed,
  }) {
    final dedupedReasons =
        reasons.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet().toList();

    return showAppBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        final radius = BorderRadius.circular(18);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassBottomSheetSurface(
            borderRadius: radius,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Row(
                      children: [
                        ThemeIcon(
                          CupertinoIcons.exclamationmark_circle_fill,
                          size: 22,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(sheetContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        ThreeDAppBarIconButton(
                          iconData: Icons.close,
                          iconWidget: ThemeIcon(
                            Icons.close,
                            color: scheme.onSurface.withValues(alpha: 0.75),
                          ),
                          semanticsLabel: MaterialLocalizations.of(sheetContext)
                              .closeButtonTooltip,
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          padding: EdgeInsets.zero,
                          contentSlotSize: 22,
                        ),
                      ],
                    ),
                  ),
                  if (dedupedReasons.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.get("chat_safety_sheet_why_title"),
                            style: Theme.of(sheetContext)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 8),
                          for (final r in dedupedReasons)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: scheme.onSurface.withValues(
                                          alpha: 0.55,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      r,
                                      style: Theme.of(sheetContext)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            height: 1.25,
                                            color: scheme.onSurface.withValues(
                                              alpha: 0.86,
                                            ),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButtonFactory.iconText(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                              onCopyPressed();
                            },
                            icon: Icons.copy_rounded,
                            text: L10n.get("chat_safety_sheet_copy"),
                            iconSize: 18,
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        if (onReportPressed != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: GhostButtonFactory.iconText(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                onReportPressed();
                              },
                              icon: Icons.report_outlined,
                              text: L10n.get("chat_safety_sheet_report"),
                              iconSize: 18,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                        if (onBlockPressed != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: GhostButtonFactory.iconText(
                              onPressed: () {
                                Navigator.of(sheetContext).pop();
                                onBlockPressed();
                              },
                              icon: Icons.block,
                              text: L10n.get("chat_safety_sheet_block"),
                              iconSize: 18,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Center(
                          child: TextButtonThemed(
                            onPressed: () {
                              Navigator.of(sheetContext).pop();
                            },
                            child:
                                Text(L10n.get("chat_safety_sheet_close")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

