import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/util/dio_api_error_message.dart";
import "package:uy_dosh/domain/services/admin_entity_ownership_service.dart";
import "package:uy_dosh/domain/services/admin_moderation_user_picker_service.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_text_field.dart";
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
    ToastTheme.showSuccess(
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
  int _searchRequestId = 0;

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
    final requestId = ++_searchRequestId;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final list = await _picker.search(
        q: q.isEmpty ? null : q,
        limit: 40,
        excludeUserId: widget.fromUserId,
      );
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _users = list;
        _loading = false;
        if (_selected != null &&
            !_users.any((u) => u.id == _selected!.id)) {
          _selected = null;
        }
      });
    } catch (e) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _loadError = throwableUserMessage(e);
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
      ToastTheme.showErrorSimple(context, message: throwableUserMessage(e));
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              L10n.get("admin_reassign_owner_dialog_title"),
              style: theme.dialogTheme.titleTextStyle ??
                  theme.textTheme.titleLarge,
            ),
          ),
          ThreeDAppBarIconButton(
            iconData: Icons.close,
            onPressed: () {
              if (_submitting) return;
              HapticFeedbackUtils.selectionClick();
              Navigator.of(context).pop(false);
            },
            semanticsLabel:
                MaterialLocalizations.of(context).closeButtonTooltip,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            iconSize: 18,
            contentSlotSize: 20,
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        height: MediaQuery.sizeOf(context).height * 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    L10n.getWithParams(
                      "admin_reassign_owner_from_user",
                      params: {"id": "${widget.fromUserId}"},
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    "·",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    L10n.getWithParams(
                      "admin_reassign_owner_entity_label",
                      params: {
                        "entity": widget.entityType.apiValue,
                        "id": "${widget.entityId}",
                      },
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ThreeDTextField(
              controller: _searchController,
              hintText:
                  L10n.get("admin_reassign_owner_search_placeholder"),
              borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
              textInputAction: TextInputAction.search,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 42,
                minHeight: 40,
              ),
              prefixIcon: Icon(
                Icons.search,
                size: 22,
                color: ThemeState().isBlueTheme
                    ? Colors.white
                    : theme.colorScheme.primary,
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
                        final titleStyle = theme.textTheme.titleMedium?.copyWith(
                          color: selected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                        );
                        final subtitleStyle =
                            theme.textTheme.bodySmall?.copyWith(
                          color: selected
                              ? theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.9)
                              : theme.colorScheme.onSurfaceVariant,
                        );
                        return ListTile(
                          selected: selected,
                          selectedTileColor: theme.colorScheme.primaryContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      color: selected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : null,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(u.displayLabel, style: titleStyle),
                          subtitle: Text(
                            "#${u.id} · ${u.email ?? "—"}",
                            style: subtitleStyle,
                          ),
                          onTap: _submitting
                              ? null
                              : () => setState(() => _selected = u),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            PrimaryButtonFactory.iconTextCentered(
              onPressed: (_selected == null || _submitting) ? null : _submit,
              icon: Icons.swap_horiz,
              text: L10n.get("admin_reassign_ownership_submit"),
              isLoading: _submitting,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
