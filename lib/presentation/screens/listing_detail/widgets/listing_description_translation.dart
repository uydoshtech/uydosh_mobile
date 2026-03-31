import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";

enum _TranslationTarget { original, en, ru, uz }

/// Description text with flag buttons (EN / RU / UZ) to translate via [GeminiService].
class ListingDescriptionTranslation extends StatefulWidget {
  const ListingDescriptionTranslation({
    required this.originalText,
    required this.textStyle,
    super.key,
  });

  final String originalText;
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
          _loadingLang = null;
          _target = _TranslationTarget.original;
          _error = L10n.get("listing_translation_error");
        });
        return;
      }
      setState(() {
        _cache[code] = translated.trim();
        _loadingLang = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingLang = null;
        _target = _TranslationTarget.original;
        _error = L10n.get("listing_translation_error");
      });
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

    return Tooltip(
      message: L10n.get(tooltipKey),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onFlagTap(target),
          borderRadius: BorderRadius.circular(radius),
          child: Container(
            height: pillHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : ListingDetailThemeHelper.amenityChipBorderColor,
                width: selected ? 2 : 1,
              ),
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.35),
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

  @override
  Widget build(BuildContext context) {
    final code = _activeCode;
    final waitingForTranslation = code != null &&
        _loadingLang == code &&
        !_cache.containsKey(code);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _flagButton(
              flagEmoji: "🇬🇧",
              target: _TranslationTarget.en,
              tooltipKey: "listing_translate_tooltip_en",
            ),
            _flagButton(
              flagEmoji: "🇷🇺",
              target: _TranslationTarget.ru,
              tooltipKey: "listing_translate_tooltip_ru",
            ),
            _flagButton(
              flagEmoji: "🇺🇿",
              target: _TranslationTarget.uz,
              tooltipKey: "listing_translate_tooltip_uz",
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_target != _TranslationTarget.original)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _target = _TranslationTarget.original;
                  _error = null;
                });
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(L10n.get("listing_show_original_description")),
            ),
          ),
        if (waitingForTranslation) ...[
          Text(
            L10n.get("listing_translating_description"),
            style: widget.textStyle.copyWith(
              fontStyle: FontStyle.italic,
              color: ListingDetailThemeHelper.descriptionTextColor,
            ),
          ),
        ] else
          Text(
            _target == _TranslationTarget.original
                ? widget.originalText
                : (_cache[_codeForTarget(_target)] ?? widget.originalText),
            style: widget.textStyle,
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
