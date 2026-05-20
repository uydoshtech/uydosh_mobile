import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_assistant.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Compact “Template” action for gig description fields on the publish screen.
/// Inserts a short skeleton based on service (offer) vs task (request) + app language.
class GigDescriptionTemplateButton extends StatelessWidget {
  const GigDescriptionTemplateButton({
    required this.controller,
    required this.isOffer,
    super.key,
    this.inlineWithCounter = false,
  });

  final TextEditingController controller;

  /// `true` = service/offer, `false` = task/request.
  final bool isOffer;
  final bool inlineWithCounter;

  String _templateKey() =>
      isOffer
          ? "gig_description_template_service"
          : "gig_description_template_task";

  void _insertTemplate() {
    final next = L10n.get(_templateKey());
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = ListingDescriptionAssistant.accentColor(context);
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

    return TextButton(
      onPressed: () {
        HapticFeedbackUtils.lightImpact();
        _insertTemplate();
      },
      style: TextButton.styleFrom(
        foregroundColor: accent,
        padding: inlineWithCounter
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 0)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        alignment: Alignment.centerLeft,
      ),
      child: child,
    );
  }
}
