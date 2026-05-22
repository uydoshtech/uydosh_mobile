import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/yandex_geosuggest_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_plate_text_form_field.dart";

/// Plate-style address field with Yandex Geosuggest autocomplete.
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
  final bool enabled;

  @override
  State<YandexAddressSuggestField> createState() =>
      _YandexAddressSuggestFieldState();
}

class _YandexAddressSuggestFieldState extends State<YandexAddressSuggestField> {
  static const _debounceDuration = Duration(milliseconds: 350);
  static const _minQueryLength = 2;

  final FocusNode _focusNode = FocusNode();
  late final YandexGeosuggestService _geosuggestService;
  late final String _sessionToken;

  Timer? _debounceTimer;
  int _requestGeneration = 0;
  bool _loading = false;
  bool _suppressNextFetch = false;
  String? _fetchErrorMessage;
  List<YandexGeosuggestSuggestion> _suggestions = const [];

  @override
  void initState() {
    super.initState();
    _geosuggestService = widget.geosuggestService ?? getIt<YandexGeosuggestService>();
    _sessionToken = YandexGeosuggestService.newSessionToken();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onControllerTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onControllerTextChanged);
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerTextChanged() {
    _onTextChanged(widget.controller.text);
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      Future<void>.delayed(const Duration(milliseconds: 180), () {
        if (!mounted || _focusNode.hasFocus) {
          return;
        }
        setState(() {
          _suggestions = const [];
          _loading = false;
        });
      });
    }
  }

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);

    if (_suppressNextFetch) {
      _suppressNextFetch = false;
      return;
    }

    _debounceTimer?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < _minQueryLength) {
      setState(() {
        _loading = false;
        _fetchErrorMessage = null;
        _suggestions = const [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _fetchErrorMessage = null;
    });
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
      // Suggestions are best-effort; avoid surfacing raw API errors in the UI.
      _fetchErrorMessage =
          kDebugMode && result.suggestions.isEmpty
              ? _debugErrorMessage(result)
              : null;
    });
  }

  void _logUi(String message) {
    if (!kDebugMode) {
      return;
    }
    debugPrint("[AddressSuggest] $message");
    logger.d("[AddressSuggest] $message");
  }

  String? _debugErrorMessage(YandexGeosuggestFetchResult result) {
    final parts = <String>[
      if (result.httpStatus != null) "HTTP ${result.httpStatus}",
      if (result.isConnectionError) "connectionError",
      if (result.errorMessage != null && result.errorMessage!.isNotEmpty)
        result.errorMessage!,
    ];
    if (parts.isNotEmpty) {
      return parts.join(" · ");
    }
    return _userFacingError(result);
  }

  String? _userFacingError(YandexGeosuggestFetchResult result) {
    final message = result.errorMessage;
    if (message == null || message.isEmpty) {
      return null;
    }
    if (result.isConnectionError) {
      return L10n.get(
        "address_suggest_connection_error",
        fallback: "Could not load address suggestions. Check your connection.",
      );
    }
    if (result.isAuthError || result.isConfiguredError) {
      return L10n.get(
        "address_suggest_unavailable",
        fallback: "Address suggestions are temporarily unavailable.",
      );
    }
    return L10n.get(
      "address_suggest_failed",
      fallback: "Could not load address suggestions.",
    );
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
      _fetchErrorMessage = null;
      _suggestions = const [];
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions =
        widget.enabled &&
        _focusNode.hasFocus &&
        (_loading || _suggestions.isNotEmpty || _fetchErrorMessage != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UydoshPlateTextFormField(
          hintText: widget.hintText,
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          style: widget.style,
          dirtyOutlineColor: widget.dirtyOutlineColor,
          decoration: widget.decoration,
          textInputAction: TextInputAction.done,
          onChanged: _onTextChanged,
        ),
        if (showSuggestions) ...[
          const SizedBox(height: 6),
          _SuggestionsPanel(
            loading: _loading,
            suggestions: _suggestions,
            errorMessage: _fetchErrorMessage,
            onSelected: _selectSuggestion,
          ),
        ],
      ],
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.loading,
    required this.suggestions,
    required this.onSelected,
    this.errorMessage,
  });

  final bool loading;
  final List<YandexGeosuggestSuggestion> suggestions;
  final ValueChanged<YandexGeosuggestSuggestion> onSelected;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor =
        ThemeState().isLightTheme ? Colors.black : scheme.onSurfaceVariant;
    final secondaryTextColor = scheme.onSurfaceVariant.withValues(
      alpha: isDark ? 0.75 : 0.85,
    );

    return WheelPickerPlateContainer(
      theme: Theme.of(context),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 220),
        child: loading && suggestions.isEmpty && errorMessage == null
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : errorMessage != null && suggestions.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: scheme.error.withValues(alpha: 0.9),
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
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
