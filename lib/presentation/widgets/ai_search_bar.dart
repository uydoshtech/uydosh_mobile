import "package:flutter/material.dart";
import "package:uy_dosh/base/config/client_listing_dictation_meter_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/ai_search_service.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_dictate_button.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_dictation_meter.dart";
import "package:uy_dosh/presentation/widgets/common/dictation_trigger_controller.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

enum AiSearchActivity { transcribing, searching }

/// Persistent Feed action for the AI concierge. Results deliberately reuse
/// [ListingTile] so visual behavior and navigation remain identical to feed.
class AiSearchFloatingButton extends StatefulWidget {
  const AiSearchFloatingButton({
    required this.onResults,
    required this.onSearchStateChanged,
    super.key,
  });

  final void Function(String query, AiSearchResponse result) onResults;
  final ValueChanged<AiSearchActivity?> onSearchStateChanged;

  @override
  State<AiSearchFloatingButton> createState() => _AiSearchFloatingButtonState();
}

class _AiSearchFloatingButtonState extends State<AiSearchFloatingButton> {
  final _controller = TextEditingController();
  final _dictationMeter = DictationMeterController();
  final _dictationTrigger = DictationTriggerController();
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    _dictationMeter.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final query = _controller.text.trim();
    if (query.isEmpty || _loading) return;
    setState(() => _loading = true);
    widget.onSearchStateChanged(AiSearchActivity.searching);
    try {
      final result = await getIt<IAiSearchService>().search(query);
      if (mounted) widget.onResults(query, result);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Не удалось выполнить AI-поиск. Попробуйте ещё раз."),
          ),
        );
      }
    } finally {
      widget.onSearchStateChanged(null);
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startVoiceSearch() {
    if (_loading) return;
    if (_dictationMeter.active) {
      _dictationTrigger.toggle();
      return;
    }
    _controller.clear();
    _dictationTrigger.start();
  }

  void _onTranscriptionChanged(bool transcribing) {
    if (transcribing) {
      widget.onSearchStateChanged(AiSearchActivity.transcribing);
    } else if (!_loading) {
      widget.onSearchStateChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Offstage(
        child: ListingDescriptionDictateButton(
          controller: _controller,
          iconOnly: true,
          enabled: !_loading,
          maxDescriptionLength: 1000,
          transcriptionContext: "ai_search",
          dictationMeter: _dictationMeter,
          triggerController: _dictationTrigger,
          onTranscriptInserted: _submit,
          onTranscriptionChanged: _onTranscriptionChanged,
        ),
      ),
      ListenableBuilder(
        listenable: _dictationMeter,
        builder: (context, _) {
          final listening = _dictationMeter.active;
          final foreground = Theme.of(context).colorScheme.onPrimary;
          return Tooltip(
            message: listening ? "Слушаю…" : "AI-поиск голосом",
            child: Material(
              elevation: 6,
              shadowColor: Colors.black38,
              color: Theme.of(context).colorScheme.primary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _startVoiceSearch,
                child: SizedBox.square(
                  dimension: 52,
                  child: Center(
                    child: _loading
                        ? SizedBox.square(
                            dimension: 22,
                            child: CircularProgressIndicator(
                              color: foreground,
                              strokeWidth: 2.4,
                            ),
                          )
                        : listening
                        ? _AiVoiceEqualizer(
                            bars: _dictationMeter.bars,
                            color: foreground,
                          )
                        : Icon(Icons.auto_awesome_rounded, color: foreground),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ],
  );
}

class _AiVoiceEqualizer extends StatelessWidget {
  const _AiVoiceEqualizer({required this.bars, required this.color});

  final List<double> bars;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final visibleBars = bars.length <= 5 ? bars : bars.sublist(bars.length - 5);
    return SizedBox(
      width: 26,
      height: 26,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: visibleBars.map((level) {
          final height = 5 + level.clamp(0.0, 1.0) * 19;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 72),
                curve: Curves.easeOut,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AiSearchSheet extends StatefulWidget {
  const _AiSearchSheet();
  @override
  State<_AiSearchSheet> createState() => _AiSearchSheetState();
}

class _AiSearchSheetState extends State<_AiSearchSheet> {
  final _controller = TextEditingController();
  final _dictationMeter = DictationMeterController();
  final _dictationTrigger = DictationTriggerController();
  bool _loading = false;
  String? _text;
  List<Listing> _listings = const [];

  @override
  void dispose() {
    _controller.dispose();
    _dictationMeter.dispose();
    super.dispose();
  }

  Future<void> _submit([String? example]) async {
    final message = (example ?? _controller.text).trim();
    if (message.isEmpty) return;
    _controller.text = message;
    setState(() => _loading = true);
    try {
      final result = await getIt<IAiSearchService>().search(message);
      if (mounted)
        setState(() {
          _text = result.text;
          _listings = result.listings;
        });
    } catch (_) {
      if (mounted)
        setState(
          () => _text = "Не удалось выполнить AI-поиск. Попробуйте ещё раз.",
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startVoiceSearchOrSubmit() {
    if (_controller.text.trim().isEmpty) {
      _dictationTrigger.start();
      return;
    }
    _submit();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _dictationMeter,
    builder: (context, _) => _buildSheet(context),
  );

  Widget _buildSheet(BuildContext context) {
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.viewInsetsOf(context).bottom;
    final hasResults = _listings.isNotEmpty;
    final sheetHeight = hasResults
        ? availableHeight * .9
        : _text != null || _loading
        ? 280.0
        : _dictationMeter.active
        ? 250.0
        : _controller.text.trim().isNotEmpty
        ? 230.0
        : 180.0;
    final resultsHeight = (sheetHeight - 260).clamp(180.0, 480.0);

    return SizedBox(
      height: sheetHeight,
      child: GlassBottomSheetSurface(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            6,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 16,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ThemeIcon(
                    Icons.auto_awesome_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      L10n.get("ai_search_title"),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_controller.text.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _controller.text.trim(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              // Recording is controlled by the primary CTA; this hidden
              // widget owns the shared recorder and Whisper transcription flow.
              Offstage(
                child: ListingDescriptionDictateButton(
                  controller: _controller,
                  iconOnly: true,
                  enabled: !_loading,
                  maxDescriptionLength: 1000,
                  transcriptionContext: "ai_search",
                  dictationMeter: _dictationMeter,
                  triggerController: _dictationTrigger,
                  onTranscriptInserted: _submit,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable:
                    ClientListingDictationMeterConfig.dictationMeterDisabled,
                builder: (context, disabled, _) => ListenableBuilder(
                  listenable: _dictationMeter,
                  builder: (context, _) => disabled || !_dictationMeter.active
                      ? const SizedBox.shrink()
                      : ListingDescriptionDictationMeterRow(
                          controller: _dictationMeter,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              ListenableBuilder(
                listenable: _dictationMeter,
                builder: (context, _) {
                  final recording = _dictationMeter.active;
                  final hasText = _controller.text.trim().isNotEmpty;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading || recording
                          ? null
                          : _startVoiceSearchOrSubmit,
                      icon: Icon(
                        recording
                            ? Icons.mic_rounded
                            : hasText
                            ? Icons.auto_awesome
                            : Icons.mic_none_outlined,
                      ),
                      label: Text(
                        L10n.get(
                          recording
                              ? "ai_search_listening_cta"
                              : hasText
                              ? "ai_search_find_cta"
                              : "ai_search_voice_cta",
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              // Listing cards are the result UI. Hide any legacy model prose
              // (especially numbered duplicates) whenever real cards exist.
              if (_text != null && _listings.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(_text!),
                ),
              if (hasResults)
                SizedBox(
                  height: resultsHeight,
                  child: ListView.builder(
                    itemCount: _listings.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListingTile(
                        listing: _listings[i],
                        feedOptimized: true,
                        forceFavorite: false,
                        showHeartIcon: false,
                        showFavoriteIndicator: true,
                        onFavoriteRemoved: null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
