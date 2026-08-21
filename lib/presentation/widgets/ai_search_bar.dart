import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/services/ai_search_service.dart";
import "package:uy_dosh/presentation/widgets/common/listing_description_dictate_button.dart";
import "package:uy_dosh/presentation/widgets/listing_tile.dart";

/// Persistent Feed action for the AI concierge. Results deliberately reuse
/// [ListingTile] so visual behavior and navigation remain identical to feed.
class AiSearchFloatingButton extends StatelessWidget {
  const AiSearchFloatingButton({super.key});

  @override
  Widget build(BuildContext context) => Tooltip(
    message: "AI-поиск",
    child: Material(
      elevation: 6,
      shadowColor: Colors.black38,
      color: Theme.of(context).colorScheme.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => const _AiSearchSheet(),
        ),
        child: const SizedBox.square(
          dimension: 52,
          child: Icon(Icons.auto_awesome_rounded, color: Colors.white),
        ),
      ),
    ),
  );
}

class _AiSearchSheet extends StatefulWidget {
  const _AiSearchSheet();
  @override
  State<_AiSearchSheet> createState() => _AiSearchSheetState();
}

class _AiSearchSheetState extends State<_AiSearchSheet> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _text;
  List<Listing> _listings = const [];

  @override
  void dispose() {
    _controller.dispose();
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

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: .78,
    minChildSize: .5,
    maxChildSize: .95,
    builder: (context, scrollController) => Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        children: [
          const Text(
            "✨ Ask UyDosh",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: "Скажи, где и как ты хочешь жить…",
              border: const OutlineInputBorder(),
              suffixIcon: ListingDescriptionDictateButton(
                controller: _controller,
                iconOnly: true,
                enabled: !_loading,
                maxDescriptionLength: 1000,
                transcriptionContext: "ai_search",
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                [
                      "До \$300 около WIUT",
                      "Найди мне соседа",
                      "Ищу двушку в Чиланзаре до \$450 рядом с метро",
                    ]
                    .map(
                      (e) => ActionChip(
                        label: Text(e),
                        onPressed: () => _submit(e),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _loading ? null : _submit,
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Найти"),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          if (_text != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_text!),
            ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
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
  );
}
