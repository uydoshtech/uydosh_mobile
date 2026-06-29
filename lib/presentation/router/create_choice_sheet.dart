import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/listing_navigation.dart";
import "package:uy_dosh/presentation/router/main_navigation_widgets.dart";
import "package:uy_dosh/presentation/screens/gig/publish_gig_screen.dart"
    show GigPublishMode;
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";

/// Shared chooser for the bottom-bar "+" create action.
Future<void> showCreateChoiceSheet(BuildContext context) {
  return showAppBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
      return GlassBottomSheetSurface(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.18,
                      ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    L10n.get("create_choice_title"),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CreateChoiceTile(
                  emoji: "👥",
                  iconColor: const Color(0xFFF4C9CF),
                  title: L10n.get("create_choice_roommate_needed"),
                  subtitle: L10n.get(
                    "create_choice_roommate_needed_subtitle",
                  ),
                  onTap: () {
                    HapticFeedbackUtils.impact();
                    Navigator.of(sheetContext).pop();
                    if (!context.mounted) return;
                    context.pushCreateListing(listingTypeId: 2);
                  },
                ),
                const SizedBox(height: 12),
                CreateChoiceTile(
                  emoji: "🏠",
                  iconColor: const Color(0xFFB9DCEC),
                  title: L10n.get("create_choice_room_needed"),
                  subtitle: L10n.get("create_choice_room_needed_subtitle"),
                  onTap: () {
                    HapticFeedbackUtils.impact();
                    Navigator.of(sheetContext).pop();
                    if (!context.mounted) return;
                    context.pushCreateListing(listingTypeId: 1);
                  },
                ),
                const SizedBox(height: 12),
                CreateChoiceTile(
                  emoji: "🤝",
                  iconColor: const Color(0xFFF6C966),
                  title: L10n.get("create_choice_group_forming"),
                  subtitle: L10n.get("create_choice_group_forming_subtitle"),
                  onTap: () {
                    HapticFeedbackUtils.impact();
                    Navigator.of(sheetContext).pop();
                    if (!context.mounted) return;
                    context.pushCreateGroup();
                  },
                ),
                if (AppConfig.servicesFeatureEnabled) ...[
                  const SizedBox(height: 12),
                  CreateChoiceTile(
                    emoji: "🛠",
                    iconColor: const Color(0xFFC6D8C2),
                    title: L10n.get("create_choice_service"),
                    subtitle: L10n.get("create_choice_service_subtitle"),
                    onTap: () {
                      HapticFeedbackUtils.impact();
                      Navigator.of(sheetContext).pop();
                      if (!context.mounted) return;
                      context.pushPublishGig(
                        initialMode: GigPublishMode.service,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
