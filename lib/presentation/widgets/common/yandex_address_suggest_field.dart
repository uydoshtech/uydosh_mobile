import "dart:async";
import "dart:math" show max, min;

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/yandex_geosuggest_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_plate_text_form_field.dart";

/// Plate-style address field with Yandex Geosuggest autocomplete.
///
/// Suggestions float in an overlay anchored to the field. When the soft
/// keyboard would cover a below-field panel, suggestions appear above instead,
/// clamped to the visible screen area.
class YandexAddressSuggestField extends StatefulWidget {
  const YandexAddressSuggestField({
    required this.hintText,
    required this.controller,
    super.key,
    this.style,
    this.dirtyOutlineColor,
    this.decoration,
    this.geosuggestService,
    this.lang,
    this.onChanged,
    this.onEditingFinished,
    this.enabled = true,
  });

  final String hintText;
  final TextEditingController controller;
  final TextStyle? style;
  final Color? dirtyOutlineColor;
  final InputDecoration? decoration;
  final YandexGeosuggestService? geosuggestService;
  final String? lang;
  final ValueChanged<String>? onChanged;

  /// Fired once the field loses focus (including immediately after the user
  /// taps a suggestion, since selecting one also unfocuses the field) — the
  /// right moment to resolve the typed address into coordinates.
  final ValueChanged<String>? onEditingFinished;
  final bool enabled;

  @override
  State<YandexAddressSuggestField> createState() =>
      _YandexAddressSuggestFieldState();
}

class _YandexAddressSuggestFieldState extends State<YandexAddressSuggestField>
    with WidgetsBindingObserver {
  static const _debounceDuration = Duration(milliseconds: 350);
  static const _minQueryLength = 2;
  static const _panelGap = 6.0;
  static const _panelPreferredMaxHeight = 220.0;
  static const _panelMinHeight = 96.0;
  static const _screenEdgePadding = 8.0;
  static const _keyboardDoneBarHeight = 44.0;

  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldAnchorKey = GlobalKey();
  final OverlayPortalController _overlayController = OverlayPortalController();

  late final YandexGeosuggestService _geosuggestService;
  late final String _sessionToken;

  Timer? _debounceTimer;
  int _requestGeneration = 0;
  bool _loading = false;
  bool _suppressNextFetch = false;
  bool _showSuggestionsAbove = true;
  double _panelHeight = _panelPreferredMaxHeight;
  Rect? _fieldRect;
  List<YandexGeosuggestSuggestion> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _geosuggestService =
        widget.geosuggestService ?? getIt<YandexGeosuggestService>();
    _sessionToken = YandexGeosuggestService.newSessionToken();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onControllerTextChanged);
  }

  void _onControllerTextChanged() {
    _handleQueryChange(widget.controller.text);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onControllerTextChanged);
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _updateSuggestionsPlacement();
  }

  bool get _shouldShowSuggestions {
    final query = widget.controller.text.trim();
    if (query.length < _minQueryLength) {
      return false;
    }
    return widget.enabled &&
        _focusNode.hasFocus &&
        (_loading || _suggestions.isNotEmpty);
  }

  void _resetSuggestions({bool invalidateInFlight = true}) {
    _debounceTimer?.cancel();
    if (invalidateInFlight) {
      _requestGeneration++;
    }
    if (_loading || _suggestions.isNotEmpty) {
      setState(() {
        _loading = false;
        _suggestions = const [];
      });
    }
    _applyOverlayVisibility(immediate: true);
  }

  void _applyOverlayVisibility({bool immediate = false}) {
    void update() {
      if (!mounted) {
        return;
      }
      if (_shouldShowSuggestions) {
        _updateSuggestionsPlacement();
      }
      final shouldShow =
          _shouldShowSuggestions && _fieldRect != null && _panelHeight >= 48;
      if (shouldShow && !_overlayController.isShowing) {
        _overlayController.show();
      } else if (!shouldShow && _overlayController.isShowing) {
        _overlayController.hide();
      }
    }

    if (immediate) {
      update();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_shouldShowSuggestions) {
          return;
        }
        _updateSuggestionsPlacement();
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => update());
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_focusNode.hasFocus) {
          return;
        }
        _scrollFieldIntoView();
        _updateSuggestionsPlacement();
        _applyOverlayVisibility();
      });
      return;
    }

    Future<void>.delayed(const Duration(milliseconds: 180), () {
      if (!mounted || _focusNode.hasFocus) {
        return;
      }
      setState(() {
        _suggestions = const [];
        _loading = false;
      });
      _applyOverlayVisibility(immediate: true);
      widget.onEditingFinished?.call(widget.controller.text);
    });
  }

  void _scrollFieldIntoView() {
    final context = _fieldAnchorKey.currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      alignment: 0.35,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Rect? _measureFieldRect() {
    final renderBox =
        _fieldAnchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return null;
    }
    return renderBox.localToGlobal(Offset.zero) & renderBox.size;
  }

  void _updateSuggestionsPlacement() {
    if (!mounted) {
      return;
    }

    final fieldRect = _measureFieldRect();
    if (fieldRect == null) {
      return;
    }

    final mediaQuery = MediaQuery.of(context);
    final viewInsets =
        MediaQueryData.fromView(View.of(context)).viewInsets.bottom;
    final safeTop = mediaQuery.padding.top;
    final screenHeight = mediaQuery.size.height;
    final keyboardInset = viewInsets;
    final doneBarInset =
        keyboardInset > 0 ? _keyboardDoneBarHeight : 0.0;

    final spaceAbove =
        fieldRect.top - safeTop - _screenEdgePadding - _panelGap;
    final spaceBelow = screenHeight -
        fieldRect.bottom -
        keyboardInset -
        doneBarInset -
        _screenEdgePadding -
        _panelGap;

    final canShowAbove = spaceAbove >= _panelMinHeight;
    final canShowBelow = spaceBelow >= _panelMinHeight;

    var showAbove = false;
    if (keyboardInset > 0 && canShowAbove) {
      showAbove = true;
    } else if (canShowBelow && (!canShowAbove || spaceBelow >= spaceAbove)) {
      showAbove = false;
    } else if (canShowAbove) {
      showAbove = true;
    } else {
      showAbove = spaceAbove >= spaceBelow;
    }

    final availableSpace = max(0.0, showAbove ? spaceAbove : spaceBelow);
    final panelHeight = min(
      _panelPreferredMaxHeight,
      max(48.0, availableSpace),
    );

    if (_fieldRect != fieldRect ||
        _showSuggestionsAbove != showAbove ||
        _panelHeight != panelHeight) {
      setState(() {
        _fieldRect = fieldRect;
        _showSuggestionsAbove = showAbove;
        _panelHeight = panelHeight;
      });
    }
  }

  void _handleQueryChange(String value) {
    widget.onChanged?.call(value);

    if (_suppressNextFetch) {
      _suppressNextFetch = false;
      _resetSuggestions(invalidateInFlight: true);
      return;
    }

    _debounceTimer?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < _minQueryLength) {
      _resetSuggestions(invalidateInFlight: true);
      return;
    }

    setState(() => _loading = true);
    _applyOverlayVisibility(immediate: true);
    _debounceTimer = Timer(_debounceDuration, () => _fetchSuggestions(trimmed));
  }

  Future<void> _fetchSuggestions(String query) async {
    final generation = ++_requestGeneration;
    final lang = widget.lang ?? L10n.currentLanguage;
    _logUi(
      "fetch start gen=$generation query=\"$query\" lang=$lang "
      "session=${_sessionToken.substring(0, 8)}…",
    );

    final result = await _geosuggestService.fetch(
      text: query,
      sessionToken: _sessionToken,
      lang: lang,
    );

    if (!mounted || generation != _requestGeneration) {
      _logUi("fetch stale gen=$generation (current=$_requestGeneration) — ignored");
      return;
    }

    _logUi(
      "fetch done gen=$generation count=${result.suggestions.length} "
      "status=${result.httpStatus} connectionError=${result.isConnectionError} "
      "error=${result.errorMessage ?? "none"}",
    );

    setState(() {
      _loading = false;
      _suggestions = result.suggestions;
    });
    _applyOverlayVisibility(immediate: true);
  }

  void _logUi(String message) {
    logUiUx(message, tag: "AddressSuggest");
  }

  void _selectSuggestion(YandexGeosuggestSuggestion suggestion) {
    _debounceTimer?.cancel();
    _requestGeneration++;
    _suppressNextFetch = true;
    widget.controller
      ..text = suggestion.displayText
      ..selection = TextSelection.collapsed(
        offset: suggestion.displayText.length,
      );
    widget.onChanged?.call(suggestion.displayText);
    setState(() {
      _loading = false;
      _suggestions = const [];
    });
    _applyOverlayVisibility(immediate: true);
    _focusNode.unfocus();
  }

  Widget _buildSuggestionsOverlay(BuildContext context) {
    final fieldRect = _fieldRect;
    if (fieldRect == null) {
      return const SizedBox.shrink();
    }

    final top = _showSuggestionsAbove
        ? fieldRect.top - _panelGap - _panelHeight
        : fieldRect.bottom + _panelGap;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: fieldRect.left,
          top: top,
          width: fieldRect.width,
          height: _panelHeight,
          child: _SuggestionsPanel(
            loading: _loading,
            suggestions: _suggestions,
            onSelected: _selectSuggestion,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: _buildSuggestionsOverlay,
      child: KeyedSubtree(
        key: _fieldAnchorKey,
        child: UydoshPlateTextFormField(
          hintText: widget.hintText,
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          style: widget.style,
          dirtyOutlineColor: widget.dirtyOutlineColor,
          decoration: widget.decoration,
          keyboardType: TextInputType.multiline,
          minLines: 2,
          maxLines: 2,
          textInputAction: TextInputAction.done,
        ),
      ),
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.loading,
    required this.suggestions,
    required this.onSelected,
  });

  final bool loading;
  final List<YandexGeosuggestSuggestion> suggestions;
  final ValueChanged<YandexGeosuggestSuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        ThemeState().isLightTheme ? Colors.black : scheme.onSurfaceVariant;
    final secondaryTextColor = scheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.75 : 0.85,
    );

    return Material(
      type: MaterialType.transparency,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: WheelPickerPlateContainer(
        theme: Theme.of(context),
        clipBehavior: Clip.antiAlias,
        child: loading && suggestions.isEmpty
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.35),
                ),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelected(suggestion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              suggestion.displayText,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: primaryTextColor,
                              ),
                            ),
                            if (suggestion.subtitle != null &&
                                suggestion.subtitle!.isNotEmpty &&
                                suggestion.subtitle != suggestion.displayText)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  suggestion.subtitle!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
