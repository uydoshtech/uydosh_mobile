import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Compact “AI enhance” action for listing description fields (create / edit).
class ListingDescriptionAiEnhanceButton extends StatefulWidget {
  const ListingDescriptionAiEnhanceButton({
    required this.controller,
    super.key,
    /// When true, omit outer alignment/padding for use in a [Row] with the char counter.
    this.inlineWithCounter = false,
  });

  final TextEditingController controller;
  final bool inlineWithCounter;

  @override
  State<ListingDescriptionAiEnhanceButton> createState() =>
      _ListingDescriptionAiEnhanceButtonState();
}

class _ListingDescriptionAiEnhanceButtonState
    extends State<ListingDescriptionAiEnhanceButton> {
  bool _loading = false;

  Future<void> _onPressed() async {
    final raw = widget.controller.text.trim();
    if (raw.isEmpty) {
      ToastTheme.showError(
        context,
        message: L10n.get("listing_ai_enhance_empty"),
      );
      return;
    }
    final gemini = getIt<GeminiService>();
    if (!gemini.canEnhanceListingDescription) {
      ToastTheme.showError(
        context,
        message: L10n.get("listing_ai_enhance_unavailable"),
      );
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      final enhanced = await gemini.enhanceListingDescription(text: raw);
      if (!mounted) {
        return;
      }
      if (enhanced == null || enhanced.trim().isEmpty) {
        ToastTheme.showError(
          context,
          message: L10n.get("listing_ai_enhance_error"),
        );
        return;
      }
      var text = enhanced.trim();
      if (text.length > 1000) {
        text = text.substring(0, 1000);
      }
      widget.controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// Label with a dashed line drawn below the text (not [TextDecoration], so the gap is controllable).
  Widget _buildEnhanceLabel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = Theme.of(context).textTheme.labelLarge;
    final textStyle = (base ?? const TextStyle()).copyWith(color: scheme.primary);
    final lineColor = scheme.primary.withValues(alpha: 0.85);
    return IntrinsicWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(L10n.get("listing_ai_enhance"), style: textStyle),
          const SizedBox(height: 1),
          SizedBox(
            height: 2,
            child: CustomPaint(
              painter: _AiEnhanceDashedUnderlinePainter(color: lineColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inlineChild = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loading)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
          ),
        const SizedBox(width: 6),
        _buildEnhanceLabel(context),
      ],
    );
    final button =
        widget.inlineWithCounter
            ? TextButton(
              onPressed: _loading ? null : _onPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                alignment: Alignment.centerLeft,
              ),
              child: inlineChild,
            )
            : TextButton.icon(
              onPressed: _loading ? null : _onPressed,
              icon:
                  _loading
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                      : Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
              label: _buildEnhanceLabel(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            );
    if (widget.inlineWithCounter) {
      return button;
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: button,
      ),
    );
  }
}

class _AiEnhanceDashedUnderlinePainter extends CustomPainter {
  _AiEnhanceDashedUnderlinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 1.1
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    const dash = 4.0;
    const gap = 3.0;
    var x = 0.0;
    while (x < size.width) {
      final end = (x + dash).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(end, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _AiEnhanceDashedUnderlinePainter oldDelegate) =>
      oldDelegate.color != color;
}
