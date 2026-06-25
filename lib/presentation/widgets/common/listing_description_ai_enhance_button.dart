import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/gemini_quota_exceeded_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_assistant.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Signature for callbacks that take the current trimmed text and return an
/// improved version (or `null` on failure / unavailable).
typedef DescriptionEnhanceCallback = Future<String?> Function(String text);

/// Compact “AI enhance” action for listing/gig description fields (create /
/// edit). Defaults to housing-listing copy + [GeminiService.enhanceListingDescription];
/// callers can override [enhance] / [canEnhance] / [errorKey] to plug the same
/// affordance into a different domain (e.g. gigs). Validation and failure toasts
/// go through [ListingDescriptionAssistant].
class ListingDescriptionAiEnhanceButton extends StatefulWidget {
  const ListingDescriptionAiEnhanceButton({
    required this.controller,
    super.key,

    /// When true, omit outer alignment/padding for use in a [Row] with the char counter.
    this.inlineWithCounter = false,
    this.enhance,
    this.canEnhance,
    this.errorKey,
  });

  final TextEditingController controller;
  final bool inlineWithCounter;

  /// Override the default "improve this listing" call. Receives the trimmed
  /// input text; should return the improved text or `null` if the model
  /// failed / produced nothing.
  final DescriptionEnhanceCallback? enhance;

  /// Override the default availability check (defaults to
  /// [GeminiService.canEnhanceListingDescription]).
  final bool Function()? canEnhance;

  /// Localization key for the toast shown when the model fails. Defaults to
  /// `listing_ai_enhance_error` for housing-listing copy.
  final String? errorKey;

  @override
  State<ListingDescriptionAiEnhanceButton> createState() =>
      _ListingDescriptionAiEnhanceButtonState();
}

class _ListingDescriptionAiEnhanceButtonState
    extends State<ListingDescriptionAiEnhanceButton>
    with SingleTickerProviderStateMixin {
  bool _loading = false;

  /// High-contrast label/icon on dark inputs (blue theme) and light inputs (light theme).
  /// Uses [ColorScheme.onSurface] (app primary text: white / black), not [ColorScheme.primary]
  /// or default [TextButton] blue, which are low-contrast on this field’s fill.
  Color _accentColor(BuildContext context) {
    return ListingDescriptionAssistant.accentColor(context);
  }

  late final AnimationController _sparkleBlinkController;
  late final Animation<double> _sparkleOpacity;

  @override
  void initState() {
    super.initState();
    // Attention burst: blink a few cycles after first paint, then settle at
    // full opacity and stop ticking. Previously this repeated forever
    // (`repeat(reverse: true)`), driving a 60 fps animation for the entire
    // lifetime of the create/edit listing screen even though the sparkle is
    // purely decorative and the user understands the affordance after a
    // glance.
    _sparkleBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );
    // 4.5 cycles of fade ramp 0.45 → 1.0 → 0.45 → 1.0 → ... → 1.0 (rest).
    // Implemented as a TweenSequence so the controller runs once, end-to-end,
    // and stops; no infinite ticker.
    _sparkleOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.45)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.45, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.45)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.45, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 1,
      ),
    ]).animate(_sparkleBlinkController);
    _sparkleBlinkController.forward();
  }

  @override
  void dispose() {
    _sparkleBlinkController.dispose();
    super.dispose();
  }

  Widget _blinkingSparkleIcon(BuildContext context) {
    return FadeTransition(
      opacity: _sparkleOpacity,
      child:
          ThemeIcon(Icons.auto_awesome, size: 18, color: _accentColor(context)),
    );
  }

  Future<void> _onPressed() async {
    HapticFeedbackUtils.impact();
    final raw = widget.controller.text.trim();
    if (raw.isEmpty) {
      ListingDescriptionAssistant.toastAiEnhanceEmpty(context);
      return;
    }
    final gemini = getIt<GeminiService>();
    final canEnhance =
        widget.canEnhance?.call() ?? gemini.canEnhanceListingDescription;
    if (!canEnhance) {
      ListingDescriptionAssistant.toastAiEnhanceUnavailable(context);
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      final ListingEnhanceOutcome outcome;
      if (widget.enhance != null) {
        final t = await widget.enhance!.call(raw);
        outcome = ListingEnhanceOutcome(text: t);
      } else {
        outcome = await gemini.enhanceListingDescription(text: raw);
      }
      if (!mounted) {
        return;
      }
      if (outcome.quotaExceeded) {
        unawaited(GeminiQuotaExceededSheet.show(context));
        return;
      }
      if (outcome.authRequired) {
        ListingDescriptionAssistant.toastSignInRequired(context);
        return;
      }
      final enhanced = outcome.text;
      if (enhanced == null || enhanced.trim().isEmpty) {
        ListingDescriptionAssistant.toastAiEnhanceFailed(
          context,
          errorKey: widget.errorKey ?? "listing_ai_enhance_error",
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

  /// Label text for the “AI enhance” action.
  Widget _buildEnhanceLabel(BuildContext context) {
    final accent = _accentColor(context);
    final base = Theme.of(context).textTheme.labelLarge;
    final textStyle = (base ?? const TextStyle()).copyWith(color: accent);
    return Text(L10n.get("listing_ai_enhance"), style: textStyle);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ClientGeminiListingUiConfig.hideGeminiListingUi,
      builder: (context, hideGeminiUi, _) {
        if (hideGeminiUi) {
          return const SizedBox.shrink();
        }
        final button = _buildButton(context);

        if (widget.inlineWithCounter) {
          return button;
        }
        final columnChildren = <Widget>[button];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: columnChildren,
        );
      },
    );
  }

  Widget _buildButton(BuildContext context) {
    final accent = _accentColor(context);
    final inlineChild = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_loading)
          ListingDescriptionAssistant.inlineProgress(
            context,
            size: 16,
            padding: const EdgeInsets.only(top: 2),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _blinkingSparkleIcon(context),
          ),
        const SizedBox(width: 6),
        _buildEnhanceLabel(context),
      ],
    );
    final button = widget.inlineWithCounter
        ? TextButton(
            onPressed: _loading ? null : _onPressed,
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              alignment: Alignment.centerLeft,
            ),
            child: inlineChild,
          )
        : TextButton.icon(
            onPressed: _loading ? null : _onPressed,
            icon: _loading
                ? ListingDescriptionAssistant.inlineProgress(context, size: 16)
                : _blinkingSparkleIcon(context),
            label: _buildEnhanceLabel(context),
            style: TextButton.styleFrom(
              foregroundColor: accent,
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
