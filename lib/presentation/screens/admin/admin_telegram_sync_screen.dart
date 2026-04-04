import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/services/admin_telegram_sync_service.dart";

class AdminTelegramSyncScreen extends StatefulWidget {
  const AdminTelegramSyncScreen({super.key});

  @override
  State<AdminTelegramSyncScreen> createState() => _AdminTelegramSyncScreenState();
}

class _AdminTelegramSyncScreenState extends State<AdminTelegramSyncScreen> {
  final IAdminTelegramSyncService _service = getIt<IAdminTelegramSyncService>();
  final _chatController = TextEditingController(text: "@roommateuz");
  final _limitController = TextEditingController(text: "6");
  final _importUserController = TextEditingController(text: "86");

  bool _newestFirst = true;
  bool _skipListingImport = false;
  bool _running = false;
  String? _resultText;
  String? _errorText;

  @override
  void dispose() {
    _chatController.dispose();
    _limitController.dispose();
    _importUserController.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    final chat = _chatController.text.trim();
    final limit = int.tryParse(_limitController.text.trim());
    int? importUserId;
    final importRaw = _importUserController.text.trim();
    if (importRaw.isNotEmpty) {
      importUserId = int.tryParse(importRaw);
      if (importUserId == null || importUserId < 1) {
        setState(() {
          _errorText = L10n.get("admin_telegram_sync_invalid_import_user");
          _resultText = null;
        });
        return;
      }
    }

    if (chat.isEmpty || limit == null || limit < 1) {
      setState(() {
        _errorText = L10n.get("admin_telegram_sync_invalid_chat_limit");
        _resultText = null;
      });
      return;
    }

    setState(() {
      _running = true;
      _errorText = null;
      _resultText = null;
    });

    try {
      final r = await _service.runSync(
        chat: chat,
        limit: limit,
        newestFirst: _newestFirst,
        skipListingImport: _skipListingImport,
        importUserId: importUserId,
      );
      if (!mounted) return;
      final buf = StringBuffer();
      buf.writeln(L10n.get("admin_telegram_sync_sync_section"));
      buf.writeln(
        "scanned=${r.sync.scanned}, skippedNoPeer=${r.sync.skippedNoPeer}, "
        "skippedBroadcast=${r.sync.skippedBroadcast}, batches=${r.sync.batches}",
      );
      buf.writeln(
        "duplicatePolicy=${r.sync.duplicatePolicy}, chatKey=${r.sync.chatKey ?? "—"}",
      );
      if (r.sync.missingIds.isNotEmpty) {
        buf.writeln("missingIds=${r.sync.missingIds.join(", ")}");
      }
      if (r.listingImportNote != null) {
        buf.writeln();
        buf.writeln(r.listingImportNote);
      }
      final li = r.listingImport;
      if (li != null) {
        buf.writeln();
        buf.writeln(L10n.get("admin_telegram_sync_listing_section"));
        buf.writeln(
          "groups=${li.groupsTotal}, created=${li.imported}, "
          "skippedEmpty=${li.skippedEmpty}, skippedBroadcast=${li.skippedBroadcast}, "
          "skippedNoType=${li.skippedNoListingType}, skippedFailed=${li.skippedFailed}",
        );
        if (li.errors.isNotEmpty) {
          buf.writeln("errors:");
          for (final e in li.errors.take(12)) {
            buf.writeln("  • $e");
          }
          if (li.errors.length > 12) {
            buf.writeln("  … (${li.errors.length - 12} more)");
          }
        }
      }
      setState(() {
        _resultText = buf.toString();
        _running = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _running = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get("admin_telegram_sync_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            L10n.get("admin_telegram_sync_intro"),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _chatController,
            decoration: InputDecoration(
              labelText: L10n.get("admin_telegram_sync_chat_label"),
              border: const OutlineInputBorder(),
            ),
            autocorrect: false,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _limitController,
            decoration: InputDecoration(
              labelText: L10n.get("admin_telegram_sync_limit_label"),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _importUserController,
            decoration: InputDecoration(
              labelText: L10n.get("admin_telegram_sync_import_user_label"),
              helperText: L10n.get("admin_telegram_sync_import_user_helper"),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(L10n.get("admin_telegram_sync_newest_first")),
            value: _newestFirst,
            onChanged: _running
                ? null
                : (v) => setState(() => _newestFirst = v),
          ),
          SwitchListTile(
            title: Text(L10n.get("admin_telegram_sync_skip_listing_import")),
            value: _skipListingImport,
            onChanged: _running
                ? null
                : (v) => setState(() => _skipListingImport = v),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _running ? null : _run,
            icon: _running
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: Text(
              _running
                  ? L10n.get("admin_telegram_sync_running")
                  : L10n.get("admin_telegram_sync_run"),
            ),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 16),
            SelectableText(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_resultText != null) ...[
            const SizedBox(height: 20),
            Text(
              L10n.get("admin_telegram_sync_result_header"),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SelectableText(_resultText!),
          ],
        ],
      ),
    );
  }
}
