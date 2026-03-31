import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/gemini_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";

enum _TranslationTarget { original, en, ru, uz }

/// Description text with compact flag actions (EN / RU / UZ) via [GeminiService].
/// Controls sit **below** the text, start-aligned (left in LTR).
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

    const pillHeight = 22.0;
    const radius = 11.0;

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
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                    width: 11,
                    height: 11,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Text(flagEmoji, style: const TextStyle(fontSize: 13)),
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
        const SizedBox(height: 6),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _flagButton(
                flagEmoji: "🇬🇧",
                target: _TranslationTarget.en,
                tooltipKey: "listing_translate_tooltip_en",
              ),
              const SizedBox(width: 4),
              _flagButton(
                flagEmoji: "🇷🇺",
                target: _TranslationTarget.ru,
                tooltipKey: "listing_translate_tooltip_ru",
              ),
              const SizedBox(width: 4),
              _flagButton(
                flagEmoji: "🇺🇿",
                target: _TranslationTarget.uz,
                tooltipKey: "listing_translate_tooltip_uz",
              ),
              if (_shouldShowOriginalLink(
                waitingForTranslation: waitingForTranslation,
              )) ...[
                const SizedBox(width: 4),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _target = _TranslationTarget.original;
                      _error = null;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    L10n.get("listing_show_original_description"),
                    style: secondaryStyle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
