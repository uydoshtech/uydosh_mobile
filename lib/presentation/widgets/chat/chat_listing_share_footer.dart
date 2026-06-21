import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ChatListingShareFooter extends StatelessWidget {
  const ChatListingShareFooter({
    required this.onTap,
    required this.textColor,
    super.key,
  });

  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final dividerColor = textColor.withValues(alpha: 0.18);
    final labelColor = textColor.withValues(alpha: 0.92);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedbackUtils.selectionClick();
          onTap();
        },
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 2),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: dividerColor)),
          ),
          child: Row(
            children: [
              ThemeIcon(
                Icons.open_in_new_rounded,
                size: 16,
                color: labelColor,
                useThemeColor: false,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  L10n.get("group_shortlist_open_listing"),
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ThemeIcon(
                Icons.chevron_right_rounded,
                size: 18,
                color: labelColor.withValues(alpha: 0.75),
                useThemeColor: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
