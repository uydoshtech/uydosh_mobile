import "dart:async";

import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/config/client_listing_contact_ui_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/base/util/listing_contact_redaction.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/profile/ai_premium_placeholder_screen.dart";
import "package:uy_dosh/presentation/widgets/common/gemini_quota_exceeded_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_text_selection_context_menu.dart";

enum _TranslationTarget { original, en, ru, uz }

/// Description text with compact flag actions (UZ / RU / EN) via [GeminiService].
/// Controls sit **above** the text, start-aligned (left in LTR).
class ListingDescriptionTranslation extends StatefulWidget {
  const ListingDescriptionTranslation({
    required this.listingId,
    required this.originalText,
    required this.textStyle,
    this.descriptionRu,
    this.descriptionEn,
    this.descriptionUz,

    /// When set, title and translation controls share one row (controls at the end).
    this.listingTitle,
    this.listingTitleStyle,
    super.key,
  });

  /// Listing id for persisting new translations (server cache).
  final int listingId;
  final String originalText;

  /// Shown on the same row as translation controls, start-aligned.
  final String? listingTitle;
  final TextStyle? listingTitleStyle;

  /// Optional DB-backed translations from [GET /listings/:id] (skip Gemini when set).
  final String? descriptionRu;
  final String? descriptionEn;
  final String? descriptionUz;
  final TextStyle textStyle;

  @override
  State<ListingDescriptionTranslation> createState() =>
      _ListingDescriptionTranslationState();
}

class _ListingDescriptionTranslationState
    extends State<ListingDescriptionTranslation> {
  final GeminiService _gemini = getIt<GeminiService>();
  _TranslationTarget _target = _TranslationTarget.original;
  final Map<String, String> _cache = {};
  String? _loadingLang;
  String? _error;
  ListingAiQuotaSnapshot? _quotaSnap;
  final List<TapGestureRecognizer> _telegramRecognizers = [];

  @override
  void initState() {
    super.initState();
    _mergeDbIntoCache();
    unawaited(_loadListingAiQuotaHint());
  }

  Future<void> _loadListingAiQuotaHint() async {
    final q = await _gemini.fetchListingAiQuota();
    if (!mounted) {
      return;
    }
    setState(() => _quotaSnap = q);
  }

  @override
  void dispose() {
    for (final r in _telegramRecognizers) {
      r.dispose();
    }
    super.dispose();
  }

  void _disposeTelegramRecognizers() {
    for (final r in _telegramRecognizers) {
      r.dispose();
    }
    _telegramRecognizers.clear();
  }

  Future<void> _openTelegramFromHandle(String handle) async {
    final clean = handle.startsWith("@") ? handle.substring(1) : handle;
    final uri = Uri.parse("https://t.me/$clean");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ToastTheme.showError(context, message: "Could not open Telegram");
      }
    } catch (_) {
      if (mounted) {
        ToastTheme.showError(context, message: "Could not open Telegram");
      }
    }
  }

  Future<void> _openTelUri(String telUri) async {
    final uri = Uri.parse(telUri);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else if (mounted) {
        ToastTheme.showError(context, message: "Could not start call");
      }
    } catch (_) {
      if (mounted) {
        ToastTheme.showError(context, message: "Could not start call");
      }
    }
  }

  String? _nineDigitUzbekMobile(String digitsOnly) {
    if (digitsOnly.length >= 12 && digitsOnly.contains("998")) {
      final idx = digitsOnly.lastIndexOf("998");
      final rest = digitsOnly.substring(idx + 3);
      if (rest.length >= 9 &&
          RegExp(r"^9[0134679]\d{7}$").hasMatch(rest.substring(0, 9))) {
        return rest.substring(0, 9);
      }
    }
    if (digitsOnly.length == 9 &&
        RegExp(r"^9[0134679]\d{7}$").hasMatch(digitsOnly)) {
      return digitsOnly;
    }
    if (digitsOnly.length > 9) {
      final m = RegExp(r"(9[0134679]\d{7})$").firstMatch(digitsOnly);
      return m?.group(1);
    }
    return null;
  }

  String _formatUzbekPhoneDisplay(String rawMatch) {
    final d = rawMatch.replaceAll(RegExp(r"\D"), "");
    final nine = _nineDigitUzbekMobile(d);
    if (nine == null || nine.length != 9) return rawMatch.trim();
    return "+998 ${nine.substring(0, 2)} ${nine.substring(2, 5)} "
        "${nine.substring(5, 7)} ${nine.substring(7, 9)}";
  }

  String _telUriForPhoneMatch(String rawMatch) {
    final d = rawMatch.replaceAll(RegExp(r"\D"), "");
    final nine = _nineDigitUzbekMobile(d);
    if (nine != null && nine.length == 9) {
      return "tel:+998$nine";
    }
    return "tel:${rawMatch.replaceAll(RegExp(r"\s"), "")}";
  }

  Widget _buildDescriptionWithTelegramLinks(String content) {
    final text = StringUtils.collapseExcessiveNewlines(content);
    if (ClientListingContactUiConfig.hidePublicContactDetails) {
      final redacted = ListingContactRedaction.stripForPublicDisplay(text);
      return SelectableText(
        redacted,
        style: widget.textStyle,
        contextMenuBuilder: uydoshEditableContextMenuWithoutLiveText,
      );
    }
    _disposeTelegramRecognizers();
    final linkColor = ListingDetailThemeHelper.descriptionLinkColor;
    final linkTextStyle = TextStyle(
      color: linkColor,
      fontSize: widget.textStyle.fontSize,
      fontWeight: widget.textStyle.fontWeight,
      decoration: TextDecoration.underline,
      decorationColor: linkColor,
    );
    final spans = <InlineSpan>[];
    final matches = ListingContactRedaction.mergedContactMatches(text);
    var cursor = 0;
    for (final m in matches) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start)));
      }
      if (m.kind == "tg") {
        final r = TapGestureRecognizer()
          ..onTap = () => unawaited(_openTelegramFromHandle(m.text));
        _telegramRecognizers.add(r);
        spans.add(
          TextSpan(
            text: m.text,
            style: linkTextStyle,
            recognizer: r,
          ),
        );
      } else {
        final display = _formatUzbekPhoneDisplay(m.text);
        final tel = _telUriForPhoneMatch(m.text);
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => unawaited(_openTelUri(tel)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeIcon(
                    Icons.phone,
                    size: (widget.textStyle.fontSize ?? 16) + 1,
                    color: linkColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    display,
                    style: linkTextStyle,
                  ),
                ],
              ),
            ),
          ),
        );
      }
      cursor = m.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }
    return SelectableText.rich(
      TextSpan(style: widget.textStyle, children: spans),
      contextMenuBuilder: uydoshEditableContextMenuWithoutLiveText,
    );
  }

  @override
  void didUpdateWidget(ListingDescriptionTranslation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listingId != widget.listingId) {
      _cache.clear();
      _target = _TranslationTarget.original;
      _loadingLang = null;
      _error = null;
    }
    final originalChanged = oldWidget.listingId == widget.listingId &&
        oldWidget.originalText.trim() != widget.originalText.trim();
    if (originalChanged) {
      _cache.remove("en");
      _cache.remove("ru");
      _cache.remove("uz");
      if (_target != _TranslationTarget.original) {
        _target = _TranslationTarget.original;
      }
      _error = null;
    }
    if (oldWidget.listingId != widget.listingId ||
        oldWidget.descriptionEn != widget.descriptionEn ||
        oldWidget.descriptionRu != widget.descriptionRu ||
        oldWidget.descriptionUz != widget.descriptionUz) {
      _mergeDbIntoCache();
    }
  }

  void _mergeDbIntoCache() {
    void put(String code, String? s) {
      final t = s?.trim();
      if (t != null && t.isNotEmpty) {
        _cache[code] = t;
      }
    }

    put("en", widget.descriptionEn);
    put("ru", widget.descriptionRu);
    put("uz", widget.descriptionUz);
  }

  void _persistTranslation(String code, String text) {
    unawaited(_saveTranslationToServer(code, text));
  }

  Future<void> _saveTranslationToServer(String code, String text) async {
    try {
      await getIt<IListingService>().saveDescriptionTranslation(
        listingId: widget.listingId,
        targetLanguageCode: code,
        translatedText: text,
      );
    } catch (e, st) {
      logger.d("saveDescriptionTranslation failed: $e\n$st");
    }
  }

  String _codeForTarget(_TranslationTarget t) => switch (t) {
        _TranslationTarget.en => "en",
        _TranslationTarget.ru => "ru",
        _TranslationTarget.uz => "uz",
        _TranslationTarget.original => "",
      };

  String? get _activeCode =>
      _target == _TranslationTarget.original ? null : _codeForTarget(_target);

  Future<void> _onFlagTap(_TranslationTarget target) async {
    if (target == _TranslationTarget.original) {
      return;
    }
    // Avoid racing translations: ignore taps on other flags while one is
    // already in flight. The corresponding button is rendered in a disabled
    // state below, but guard here too in case of rapid/simultaneous taps.
    if (_loadingLang != null) {
      return;
    }
    final code = _codeForTarget(target);
    setState(() {
      _error = null;
      _target = target;
    });

    if (_cache.containsKey(code)) {
      final t = _cache[code]!;
      if (t.trim() == widget.originalText.trim()) {
        setState(() {
          _target = _TranslationTarget.original;
        });
      }
      return;
    }

    if (!_gemini.isAvailable) {
      setState(() {
        _target = _TranslationTarget.original;
        _error = L10n.get("listing_translation_unavailable");
      });
      return;
    }

    setState(() {
      _loadingLang = code;
    });

    try {
      final outcome = await _gemini.translateListingDescription(
        text: widget.originalText,
        targetLanguageCode: code,
      );
      if (!mounted) {
        return;
      }
      if (outcome.quotaExceeded) {
        unawaited(GeminiQuotaExceededSheet.show(context));
        setState(() {
          _target = _TranslationTarget.original;
          _error = null;
        });
        unawaited(_loadListingAiQuotaHint());
        return;
      }
      if (outcome.authRequired) {
        setState(() {
          _target = _TranslationTarget.original;
          _error = L10n.get("listing_translation_sign_in_required");
        });
        return;
      }
      final translated = outcome.text;
      if (translated == null || translated.trim().isEmpty) {
        setState(() {
          _target = _TranslationTarget.original;
          _error = L10n.get("listing_translation_error");
        });
        return;
      }
      setState(() {
        final t = translated.trim();
        _cache[code] = t;
        if (t == widget.originalText.trim()) {
          _target = _TranslationTarget.original;
        } else {
          _persistTranslation(code, t);
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _target = _TranslationTarget.original;
        _error = L10n.get("listing_translation_error");
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingLang = null;
        });
      }
    }
  }

  Widget _flagButton({
    required String flagEmoji,
    required _TranslationTarget target,
    required String tooltipKey,
  }) {
    final selected = _target == target;
    final code = _codeForTarget(target);
    final isLoading = code.isNotEmpty && _loadingLang == code;
    // Disable sibling flags while a translation is in flight to prevent
    // racing/interleaved requests when the user taps buttons quickly.
    final isDisabled = _loadingLang != null && !isLoading;

    const pillHeight = 28.0;
    const radius = 14.0;

    final scheme = Theme.of(context).colorScheme;
    final isBlueTheme = ThemeState().isBlueTheme;
    final baseBorder = ListingDetailThemeHelper.amenityChipBorderColor;
    final selectedBorderColor = isBlueTheme
        ? baseBorder.withValues(alpha: 0.95)
        : scheme.primary.withValues(alpha: 0.9);
    final borderColor =
        selected ? selectedBorderColor : baseBorder.withValues(alpha: 0.45);

    // Blue theme primary matches the card background — spinner would disappear.
    final progressColor =
        isBlueTheme ? ListingDetailThemeHelper.iconColor : scheme.primary;

    final baseFill = ListingDetailThemeHelper.amenityChipBackgroundColor;
    final fillColor = selected
        ? (isBlueTheme
            ? baseFill.withValues(alpha: 0.22)
            : scheme.primary.withValues(alpha: 0.14))
        : baseFill.withValues(alpha: 0.16);

    final content = Tooltip(
      message: L10n.get(tooltipKey),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : () => _onFlagTap(target),
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            height: pillHeight,
            padding: const EdgeInsets.symmetric(horizontal: 7),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor,
                width: selected ? 1.5 : 1,
              ),
              color: fillColor,
            ),
            child: isLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: progressColor,
                    ),
                  )
                : Text(flagEmoji, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );

    if (!isDisabled) {
      return content;
    }
    return IgnorePointer(
      ignoring: true,
      child: Opacity(opacity: 0.45, child: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ClientGeminiListingUiConfig.hideGeminiListingUi,
      builder: (context, hideGeminiUi, _) {
        if (hideGeminiUi) {
          if (widget.listingTitle != null && widget.listingTitle!.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listingTitle!,
                  style: widget.listingTitleStyle ??
                      const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  ListingContactRedaction.stripForPublicDisplay(
                    widget.originalText,
                  ),
                  style: widget.textStyle,
                ),
              ],
            );
          }
          return Text(
            ListingContactRedaction.stripForPublicDisplay(widget.originalText),
            style: widget.textStyle,
          );
        }
        return _buildTranslationContent(context);
      },
    );
  }

  Widget _buildTranslationContent(BuildContext context) {
    final code = _activeCode;
    final waitingForTranslation =
        code != null && _loadingLang == code && !_cache.containsKey(code);

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _flagButton(
          flagEmoji: "🇺🇿",
          target: _TranslationTarget.uz,
          tooltipKey: "listing_translate_tooltip_uz",
        ),
        const SizedBox(width: 6),
        _flagButton(
          flagEmoji: "🇷🇺",
          target: _TranslationTarget.ru,
          tooltipKey: "listing_translate_tooltip_ru",
        ),
        const SizedBox(width: 6),
        _flagButton(
          flagEmoji: "🇺🇸",
          target: _TranslationTarget.en,
          tooltipKey: "listing_translate_tooltip_en",
        ),
      ],
    );

    final titleStyle = widget.listingTitleStyle ??
        const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.listingTitle != null && widget.listingTitle!.isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  widget.listingTitle!,
                  style: titleStyle,
                ),
              ),
              const SizedBox(width: 8),
              controls,
            ],
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: controls,
          ),
        if (_quotaSnap != null && _quotaSnap!.shouldShowLowListingAiHint)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const AiPremiumPlaceholderScreen(),
                  ),
                );
              },
              child: Text(
                L10n.getWithParams(
                  "ai_allowance_inline_listing_ai_hint",
                  params: {
                    "translate": "${_quotaSnap!.translateRemaining}",
                    "enhance": "${_quotaSnap!.enhanceRemaining}",
                  },
                ),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        SizedBox(
          height: widget.listingTitle != null && widget.listingTitle!.isNotEmpty
              ? 12
              : 8,
        ),
        if (waitingForTranslation)
          _ListingDescriptionTranslationSkeleton(
            textStyle: widget.textStyle,
            layoutProxyText:
                ClientListingContactUiConfig.hidePublicContactDetails
                    ? ListingContactRedaction.stripForPublicDisplay(
                        widget.originalText,
                      )
                    : StringUtils.collapseExcessiveNewlines(
                        widget.originalText,
                      ),
          )
        else
          _buildDescriptionWithTelegramLinks(
            _target == _TranslationTarget.original
                ? widget.originalText
                : (_cache[_codeForTarget(_target)] ?? widget.originalText),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// Rounded bars while Gemini runs. Height follows a [TextPainter] layout of
/// [layoutProxyText] (the description we already show) so the block matches
/// the final [SelectableText] footprint more closely than a fixed bar stack.
class _ListingDescriptionTranslationSkeleton extends StatelessWidget {
  const _ListingDescriptionTranslationSkeleton({
    required this.textStyle,
    required this.layoutProxyText,
  });

  final TextStyle textStyle;
  final String layoutProxyText;

  static double _plainTextHeight(
    BuildContext context,
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final t = text.trim();
    if (t.isEmpty || maxWidth <= 0) {
      return 0;
    }
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      locale: Localizations.maybeLocaleOf(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    return tp.size.height;
  }

  @override
  Widget build(BuildContext context) {
    final fs = textStyle.fontSize ?? 16;
    final barHeight = (fs * 0.7).clamp(9.0, 15.0);
    final gap = (fs * 0.35).clamp(5.0, 11.0);
    final baseColor =
        (textStyle.color ?? ListingDetailThemeHelper.descriptionTextColor)
            .withValues(alpha: 0.15);
    final minStackH = 4 * barHeight + 3 * gap;
    // Translated copy is often a bit taller (e.g. RU vs EN); reserve ~1 line.
    final expansionSlack = (textStyle.height ?? 1.0) * fs * 1.15;

    return LayoutBuilder(
      builder: (context, constraints) {
        var maxW = constraints.maxWidth;
        if (!maxW.isFinite || maxW <= 0) {
          maxW = MediaQuery.sizeOf(context).width;
        }
        final measured = _plainTextHeight(
          context,
          layoutProxyText,
          textStyle,
          maxW,
        );
        final boxH = (measured > 0 ? measured + expansionSlack : minStackH)
            .clamp(minStackH, double.infinity);

        return SizedBox(
          width: double.infinity,
          height: boxH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonRule(
                height: barHeight,
                widthFactor: 1.0,
                color: baseColor,
              ),
              SizedBox(height: gap),
              _SkeletonRule(
                height: barHeight,
                widthFactor: 0.94,
                color: baseColor,
              ),
              SizedBox(height: gap),
              _SkeletonRule(
                height: barHeight,
                widthFactor: 0.88,
                color: baseColor,
              ),
              SizedBox(height: gap),
              _SkeletonRule(
                height: barHeight,
                widthFactor: 0.42,
                color: baseColor,
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonRule extends StatelessWidget {
  const _SkeletonRule({
    required this.height,
    required this.widthFactor,
    required this.color,
  });

  final double height;
  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor.clamp(0.08, 1.0),
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}
