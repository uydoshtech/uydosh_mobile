import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:dio/dio.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/services/admin_entity_ownership_service.dart";
import "package:uy_dosh/domain/services/admin_moderation_user_picker_service.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Modal to pick a new owner (moderation staff). Returns `true` if reassigned.
Future<bool> showReassignOwnerDialog(
  BuildContext context, {
  required AdminEntityOwnershipType entityType,
  required int entityId,
  required int fromUserId,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ReassignOwnerDialog(
      entityType: entityType,
      entityId: entityId,
      fromUserId: fromUserId,
    ),
  );
  final success = ok == true;
  if (success && context.mounted) {
    ToastTheme.showSuccessSimple(
      context,
      message: L10n.get("admin_reassign_ownership_success"),
    );
  }
  return success;
}

class _ReassignOwnerDialog extends StatefulWidget {
  const _ReassignOwnerDialog({
    required this.entityType,
    required this.entityId,
    required this.fromUserId,
  });

  final AdminEntityOwnershipType entityType;
  final int entityId;
  final int fromUserId;

  @override
  State<_ReassignOwnerDialog> createState() => _ReassignOwnerDialogState();
}

class _ReassignOwnerDialogState extends State<_ReassignOwnerDialog> {
  final IAdminModerationUserPickerService _picker =
      getIt<IAdminModerationUserPickerService>();
  final IAdminEntityOwnershipService _ownership =
      getIt<IAdminEntityOwnershipService>();
  final TextEditingController _searchController = TextEditingController();

  List<ModerationUserPickerUser> _users = const [];
  ModerationUserPickerUser? _selected;
  bool _loading = true;
  bool _submitting = false;
  String? _loadError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    unawaited(_loadUsers(""));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers(String q) async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final list = await _picker.search(q: q.isEmpty ? null : q, limit: 40);
      final filtered =
          list.where((u) => u.id != widget.fromUserId).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _users = filtered;
        _loading = false;
        if (_selected != null &&
            !_users.any((u) => u.id == _selected!.id)) {
          _selected = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      var msg = e.toString();
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data["error"] is String) {
          msg = data["error"] as String;
        }
      }
      setState(() {
        _loadError = msg;
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_loadUsers(value.trim()));
    });
  }

  Future<void> _submit() async {
    final target = _selected;
    if (target == null || _submitting) return;
    setState(() => _submitting = true);
    try {
      await _ownership.reassignOwnership(
        entityType: widget.entityType,
        entityId: widget.entityId,
        toUserId: target.id,
        fromUserId: widget.fromUserId,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      var msg = e.toString();
      if (msg.startsWith("Exception: ")) {
        msg = msg.substring("Exception: ".length);
      }
      ToastTheme.showErrorSimple(context, message: msg);
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(L10n.get("admin_reassign_owner_dialog_title")),
      content: SizedBox(
        width: 420,
        height: MediaQuery.sizeOf(context).height * 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              L10n.getWithParams(
                "admin_reassign_owner_from_user",
                params: {"id": "${widget.fromUserId}"},
              ),
              style: theme.textTheme.bodySmall,
            ),
            Text(
              L10n.getWithParams(
                "admin_reassign_owner_entity_label",
                params: {
                  "entity": widget.entityType.apiValue,
                  "id": "${widget.entityId}",
                },
              ),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: L10n.get("admin_reassign_owner_search_placeholder"),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _loadError != null
                  ? Center(
                      child: Text(
                        _loadError!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _users.isEmpty
                  ? Center(
                      child: Text(
                        L10n.get("admin_reassign_owner_empty"),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, i) {
                        final u = _users[i];
                        final selected = _selected?.id == u.id;
                        final avatarUrl = resolveAvatarUrl(u.avatarUrl);
                        return ListTile(
                          selected: selected,
                          leading: CircleAvatar(
                            radius: 22,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            backgroundImage: avatarUrl != null
                                ? CachedNetworkImageProvider(avatarUrl)
                                : null,
                            child: avatarUrl == null
                                ? Text(
                                    u.displayLabel.isNotEmpty
                                        ? u.displayLabel[0].toUpperCase()
                                        : "?",
                                    style: theme.textTheme.titleMedium,
                                  )
                                : null,
                          ),
                          title: Text(u.displayLabel),
                          subtitle: Text("#${u.id} · ${u.email ?? "—"}"),
                          onTap: _submitting
                              ? null
                              : () => setState(() => _selected = u),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _submitting ? null : () => Navigator.of(context).pop(false),
          child: Text(L10n.get("cancel")),
        ),
        PrimaryButtonFactory.text(
          onPressed: (_selected == null || _submitting) ? null : _submit,
          text: L10n.get("admin_reassign_ownership_submit"),
          isLoading: _submitting,
        ),
      ],
    );
  }
}
