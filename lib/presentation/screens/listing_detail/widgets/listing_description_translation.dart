import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_gemini_listing_ui_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";

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
    super.key,
  });

  /// Listing id for persisting new translations (server cache).
  final int listingId;
  final String originalText;
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

  @override
  void initState() {
    super.initState();
    _mergeDbIntoCache();
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
      final translated = await _gemini.translateListingDescription(
        text: widget.originalText,
        targetLanguageCode: code,
      );
      if (!mounted) {
        return;
      }
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

    const pillHeight = 28.0;
    const radius = 14.0;

    final borderColor = selected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.85)
        : ListingDetailThemeHelper.amenityChipBorderColor.withValues(alpha: 0.45);

    return Tooltip(
      message: L10n.get(tooltipKey),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onFlagTap(target),
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
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.2),
            ),
            child: isLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Text(flagEmoji, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  /// Same pill shape / border as [_flagButton] (unselected style).
  Widget _originalPillButton(BuildContext context, TextStyle labelStyle) {
    const pillHeight = 28.0;
    const radius = 14.0;
    final borderColor =
        ListingDetailThemeHelper.amenityChipBorderColor.withValues(alpha: 0.45);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _target = _TranslationTarget.original;
            _error = null;
          });
        },
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: pillHeight,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 1),
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.2),
          ),
          child: Text(
            L10n.get("listing_show_original_description"),
            style: labelStyle,
          ),
        ),
      ),
    );
  }

  /// "Original" only when the user is viewing a **different** string than the
  /// listing’s source (or while a translation is still loading).
  bool _shouldShowOriginalLink({
    required bool waitingForTranslation,
  }) {
    if (_target == _TranslationTarget.original) {
      return false;
    }
    if (waitingForTranslation) {
      return true;
    }
    final code = _codeForTarget(_target);
    final shown = _cache[code];
    if (shown == null) {
      return true;
    }
    return shown.trim() != widget.originalText.trim();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ClientGeminiListingUiConfig.hideGeminiListingUi,
      builder: (context, hideGeminiUi, _) {
        if (hideGeminiUi) {
          return Text(widget.originalText, style: widget.textStyle);
        }
        return _buildTranslationContent(context);
      },
    );
  }

  Widget _buildTranslationContent(BuildContext context) {
    final code = _activeCode;
    final waitingForTranslation = code != null &&
        _loadingLang == code &&
        !_cache.containsKey(code);

    final secondaryStyle = widget.textStyle.copyWith(
      fontSize: (widget.textStyle.fontSize ?? 16) * 0.85,
      color: ListingDetailThemeHelper.descriptionTextColor.withValues(
        alpha: 0.85,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
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
              if (_shouldShowOriginalLink(
                waitingForTranslation: waitingForTranslation,
              )) ...[
                const SizedBox(width: 4),
                _originalPillButton(context, secondaryStyle),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (waitingForTranslation)
          Text(
            L10n.get("listing_translating_description"),
            style: widget.textStyle.copyWith(
              fontStyle: FontStyle.italic,
              color: ListingDetailThemeHelper.descriptionTextColor,
            ),
          )
        else
          Text(
            _target == _TranslationTarget.original
                ? widget.originalText
                : (_cache[_codeForTarget(_target)] ?? widget.originalText),
            style: widget.textStyle,
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
