import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Compact “Template” action for listing description fields (create / edit).
/// Inserts a short, non-personal template based on listing type + gender + app language.
class ListingDescriptionTemplateButton extends StatelessWidget {
  const ListingDescriptionTemplateButton({
    required this.controller,
    required this.listingTypeId,
    required this.gender,
    super.key,
    this.inlineWithCounter = false,
  });

  final TextEditingController controller;
  /// App convention: 1 = room needed, 2 = roommate needed.
  final int listingTypeId;
  /// App convention: 1 = male, 2 = female.
  final int gender;
  final bool inlineWithCounter;

  String _templateKey() {
    final isRoomNeeded = listingTypeId == 1;
    if (isRoomNeeded) {
      return "listing_description_template_room_needed";
    }
    return gender == 2
        ? "listing_description_template_roommate_needed_female"
        : "listing_description_template_roommate_needed_male";
  }

  void _insertTemplate(BuildContext context) {
    final next = L10n.get(_templateKey());
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.onSurface;
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ThemeIcon(Icons.article_outlined, size: 18, color: accent),
        ),
        const SizedBox(width: 6),
        Text(
          L10n.get("listing_description_template_label"),
          style: (Theme.of(context).textTheme.labelLarge ?? const TextStyle())
              .copyWith(color: accent),
        ),
      ],
    );

    final button = TextButton(
      onPressed: () {
        HapticFeedbackUtils.lightImpact();
        _insertTemplate(context);
      },
      style: TextButton.styleFrom(
        foregroundColor: accent,
        padding: inlineWithCounter
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 0)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: inlineWithCounter ? const Size(0, 44) : Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        alignment: Alignment.centerLeft,
      ),
      child: child,
    );

    return button;
  }
}

