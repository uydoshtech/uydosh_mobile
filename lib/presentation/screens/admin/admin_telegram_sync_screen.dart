import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/admin_user.dart";
import "package:uy_dosh/domain/services/admin_telegram_sync_service.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

class AdminTelegramSyncScreen extends StatefulWidget {
  const AdminTelegramSyncScreen({super.key});

  @override
  State<AdminTelegramSyncScreen> createState() => _AdminTelegramSyncScreenState();
}

class _AdminTelegramSyncScreenState extends State<AdminTelegramSyncScreen> {
  /// Default listing owner after Telegram sync (Uydoshtech@gmail.com in production).
  static const int _kDefaultListingOwnerUserId = 86;

  /// Preset sync sizes (matches admin UX: small counts, then round hundreds).
  static const List<int> _kMessageLimitChoices = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
    20, 30, 50, 100, 200, 500, 1000,
  ];

  static const BorderRadius _kFieldBorderRadius =
      BorderRadius.all(Radius.circular(8));

  final IAdminTelegramSyncService _service = getIt<IAdminTelegramSyncService>();
  final IAdminUserService _adminUserService = getIt<IAdminUserService>();
  final _chatController = TextEditingController(text: "@roommateuz");
  final _exportMaxRowsController = TextEditingController(text: "100000");

  final List<AdminUser> _adminUsers = [];
  bool _loadingAdmins = true;
  String? _adminsError;
  int? _selectedImportUserId;
  int _selectedMessageLimit = 20;

  late final FixedExtentScrollController _messageLimitScrollController;

  bool _newestFirst = true;
  bool _skipListingImport = false;
  bool _running = false;
  bool _exporting = false;
  String? _resultText;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final limitIndex = _kMessageLimitChoices.indexOf(_selectedMessageLimit);
    _messageLimitScrollController = FixedExtentScrollController(
      initialItem: limitIndex >= 0 ? limitIndex : 0,
    );
    _loadAdmins();
  }

  @override
  void dispose() {
    _messageLimitScrollController.dispose();
    _chatController.dispose();
    _exportMaxRowsController.dispose();
    super.dispose();
  }

  Future<void> _loadAdmins() async {
    setState(() {
      _loadingAdmins = true;
      _adminsError = null;
    });
    try {
      final list = await _adminUserService.getUsers(
        pageNumber: 1,
        pageSize: 200,
        role: "admin",
      );
      if (!mounted) return;
      setState(() {
        _adminUsers
          ..clear()
          ..addAll(list);
        _loadingAdmins = false;
        _selectedImportUserId = _defaultOwnerIdAfterLoad(list);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingAdmins = false;
        _adminsError = e.toString();
        _selectedImportUserId = null;
      });
    }
  }

  int? _defaultOwnerIdAfterLoad(List<AdminUser> admins) {
    if (admins.any((u) => u.id == _kDefaultListingOwnerUserId)) {
      return _kDefaultListingOwnerUserId;
    }
    if (admins.isNotEmpty) {
      return admins.first.id;
    }
    return null;
  }

  String _adminDropdownLabel(AdminUser u) {
    final mail = (u.email ?? "").trim();
    if (mail.isEmpty) {
      return "#${u.id}";
    }
    return "$mail · #${u.id}";
  }

  Future<void> _run() async {
    final chat = _chatController.text.trim();
    final importUserId = _selectedImportUserId;

    if (chat.isEmpty) {
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
        limit: _selectedMessageLimit,
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
      final idScope = r.sync.syncedTelegramMessageIdsCount;
      if (idScope != null) {
        buf.writeln("syncedTelegramMessageIdsCount=$idScope");
      }
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
        final scoped = li.scopedToTelegramMessageIds;
        if (scoped != null) {
          buf.writeln("scopedToTelegramMessageIds=$scoped");
        }
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

  Future<void> _downloadExport() async {
    final maxRows = int.tryParse(_exportMaxRowsController.text.trim());
    if (maxRows == null || maxRows < 1 || maxRows > 500000) {
      setState(() {
        _errorText = L10n.get("admin_telegram_export_invalid_max_rows");
      });
      return;
    }
    setState(() {
      _exporting = true;
      _errorText = null;
    });
    try {
      await _service.downloadIngestedExport(
        chatKeyFilter: null,
        maxRows: maxRows,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.get("admin_telegram_export_done"))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
        });
      }
    }
  }

  /// Blue theme uses white [InputDecorationTheme.fillColor] with white label styles
  /// from [TextTheme], so defaults break. Match profile/location controls: dark fill,
  /// light text, visible borders.
  Widget _expansionSectionTitle(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final isBlue = ThemeState().isBlueTheme;
    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: isBlue
          ? BlueThemeColors.textPrimary
          : Theme.of(context).colorScheme.onSurface,
    );
    return Row(
      children: [
        ThemeIcon(
          icon,
          color: isBlue
              ? BlueThemeColors.textPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: titleStyle)),
      ],
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String labelText,
    String? helperText,
  }) {
    final theme = Theme.of(context);
    if (!ThemeState().isBlueTheme) {
      return InputDecoration(
        labelText: labelText,
        helperText: helperText,
        border: const OutlineInputBorder(),
      );
    }
    final outline = theme.colorScheme.outline;
    return InputDecoration(
      labelText: labelText,
      helperText: helperText,
      filled: true,
      fillColor: BlueThemeColors.surface,
      labelStyle: const TextStyle(color: BlueThemeColors.textSecondary),
      floatingLabelStyle: const TextStyle(color: BlueThemeColors.primaryLight),
      helperStyle: const TextStyle(color: BlueThemeColors.textHint),
      border: OutlineInputBorder(
        borderRadius: _kFieldBorderRadius,
        borderSide: BorderSide(color: outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _kFieldBorderRadius,
        borderSide: BorderSide(color: outline),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: _kFieldBorderRadius,
        borderSide: BorderSide(
          color: BlueThemeColors.inputFocused,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _kFieldBorderRadius,
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBlue = ThemeState().isBlueTheme;
    final fieldStyle = isBlue
        ? const TextStyle(color: BlueThemeColors.textPrimary, fontSize: 16)
        : null;
    final primaryFullWidthStyle = isBlue
        ? FilledButton.styleFrom(
            backgroundColor: BlueThemeColors.buttonPrimary,
            foregroundColor: BlueThemeColors.textPrimary,
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          )
        : FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          );

    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_telegram_sync_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_errorText != null) ...[
            SelectableText(
              _errorText!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
          ],
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                maintainState: true,
                initiallyExpanded: true,
                onExpansionChanged: (expanded) {
                  if (expanded) HapticFeedbackUtils.impact();
                },
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                collapsedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: _expansionSectionTitle(
                  context,
                  title: L10n.get("admin_telegram_sync_title"),
                  icon: Icons.sync,
                ),
                children: [
                  TextField(
                    controller: _chatController,
                    style: fieldStyle,
                    decoration: _fieldDecoration(
                      context,
                      labelText: L10n.get("admin_telegram_sync_chat_label"),
                    ),
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  if (_loadingAdmins)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              L10n.get("admin_telegram_sync_admins_loading"),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_adminsError != null) ...[
                    Text(
                      L10n.get("admin_telegram_sync_admins_error"),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      _adminsError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    FilledButton.icon(
                      style: primaryFullWidthStyle,
                      onPressed: _loadAdmins,
                      icon: const ThemeIcon(Icons.refresh),
                      label: Text(L10n.get("admin_telegram_sync_admins_retry")),
                    ),
                  ] else ...[
                    if (_adminUsers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          L10n.get("admin_telegram_sync_admins_empty"),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    DropdownButtonFormField<int?>(
                      // Controlled after async load; `value` is required (`initialValue` resets on rebuild).
                      // ignore: deprecated_member_use
                      value: _selectedImportUserId,
                      items: [
                        DropdownMenuItem<int?>(
                          value: null,
                          child: Text(
                            L10n.get("admin_telegram_sync_import_user_sync_only"),
                          ),
                        ),
                        ..._adminUsers.map(
                          (u) => DropdownMenuItem<int?>(
                            value: u.id,
                            child: Text(
                              _adminDropdownLabel(u),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: _running
                          ? null
                          : (v) => setState(() => _selectedImportUserId = v),
                      decoration: _fieldDecoration(
                        context,
                        labelText: L10n.get("admin_telegram_sync_import_user_label"),
                        helperText: L10n.get("admin_telegram_sync_import_user_helper"),
                      ),
                      style: fieldStyle,
                      isExpanded: true,
                      dropdownColor: isBlue ? BlueThemeColors.surface : null,
                      iconEnabledColor: isBlue ? BlueThemeColors.textPrimary : null,
                    ),
                  ],
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(L10n.get("admin_telegram_sync_newest_first")),
                    value: _newestFirst,
                    onChanged: _running
                        ? null
                        : (v) => setState(() => _newestFirst = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(L10n.get("admin_telegram_sync_skip_listing_import")),
                    value: _skipListingImport,
                    onChanged: _running
                        ? null
                        : (v) => setState(() => _skipListingImport = v),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      L10n.get("admin_telegram_sync_limit_label"),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isBlue
                            ? BlueThemeColors.textSecondary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  IgnorePointer(
                    ignoring: _running,
                    child: Opacity(
                      opacity: _running ? 0.5 : 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: isBlue
                              ? BlueThemeColors.surface
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        height: 80,
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: _messageLimitScrollController,
                          onSelectedItemChanged: (index) {
                            HapticFeedbackUtils.impact();
                            SendSoundUtils.playSelectionSound();
                            setState(() {
                              _selectedMessageLimit = _kMessageLimitChoices[index];
                            });
                          },
                          children: _kMessageLimitChoices
                              .map(
                                (n) => Center(
                                  child: Text(
                                    "$n",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isBlue
                                          ? BlueThemeColors.textPrimary
                                          : (ThemeState().isLightTheme
                                              ? Colors.black
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: primaryFullWidthStyle,
                    onPressed: _running ? null : _run,
                    icon: _running
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isBlue
                                  ? BlueThemeColors.textPrimary
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const ThemeIcon(Icons.sync),
                    label: Text(
                      _running
                          ? L10n.get("admin_telegram_sync_running")
                          : L10n.get("admin_telegram_sync_run"),
                    ),
                  ),
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
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                onExpansionChanged: (expanded) {
                  if (expanded) HapticFeedbackUtils.impact();
                },
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                collapsedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                title: _expansionSectionTitle(
                  context,
                  title: L10n.get("admin_telegram_export_section_title"),
                  icon: Icons.download_outlined,
                ),
                children: [
                  Text(
                    L10n.get("admin_telegram_export_intro"),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _exportMaxRowsController,
                    style: fieldStyle,
                    decoration: _fieldDecoration(
                      context,
                      labelText: L10n.get("admin_telegram_export_max_rows_label"),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    enabled: !_exporting,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    style: primaryFullWidthStyle,
                    onPressed: (_running || _exporting) ? null : _downloadExport,
                    icon: _exporting
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isBlue
                                  ? BlueThemeColors.textPrimary
                                  : Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const ThemeIcon(Icons.download_outlined),
                    label: Text(
                      _exporting
                          ? L10n.get("admin_telegram_export_running")
                          : L10n.get("admin_telegram_export_download"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
