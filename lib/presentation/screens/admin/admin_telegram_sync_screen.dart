import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/pending_listing_moderation_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/admin_user.dart";
import "package:uy_dosh/domain/services/admin_area_price_cache_service.dart";
import "package:uy_dosh/domain/services/admin_telegram_sync_service.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/presentation/widgets/common/keyboard_dismiss_scope.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_inset_container.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_alert_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_dropdown.dart";

class AdminTelegramSyncScreen extends StatefulWidget {
  const AdminTelegramSyncScreen({super.key});

  @override
  State<AdminTelegramSyncScreen> createState() =>
      _AdminTelegramSyncScreenState();
}

class _AdminTelegramSyncScreenState extends State<AdminTelegramSyncScreen> {
  static const BorderRadius _kTileBorderRadius =
      BorderRadius.all(Radius.circular(12));

  /// Soft raised panel: same neumorphic chrome as listing-detail tiles
  /// ([ThreeDSurfaceStyle]), with a base color close to the page so shadows read.
  Widget _neumorphicTile({
    required BuildContext context,
    required Widget child,
    Clip clipBehavior = Clip.none,
  }) {
    final theme = Theme.of(context);
    final baseColor = ThemeState().isBlueTheme
        ? theme.colorScheme.surface
        : (theme.cardTheme.color ?? theme.colorScheme.surface);
    final margin = theme.cardTheme.margin ?? EdgeInsets.zero;
    final cardShape = theme.cardTheme.shape;
    final ShapeBorder shape;
    final BorderRadius borderRadius;
    if (cardShape is RoundedRectangleBorder) {
      shape = cardShape;
      borderRadius = cardShape.borderRadius.resolve(Directionality.of(context));
    } else {
      shape = const RoundedRectangleBorder(borderRadius: _kTileBorderRadius);
      borderRadius = _kTileBorderRadius;
    }

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
          boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
        ),
        child: Material(
          color: Colors.transparent,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          shape: shape,
          clipBehavior: clipBehavior,
          child: child,
        ),
      ),
    );
  }

  /// Default listing owner after Telegram sync (admin user id 1 in production).
  static const int _kDefaultListingOwnerUserId = 1;

  /// Fallback Telegram channels for the import dropdown while the admin-managed
  /// list is loading or unavailable.
  static const List<String> _kDefaultKnownChannels = [
    "@roommateuz",
    "@tashkentpodselenie",
  ];

  /// Sentinel value for the "Custom…" entry in the chat dropdown: switches the
  /// UI to a free-text [TextField] so an admin can still target ad-hoc chats
  /// that aren't part of the scheduled set.
  static const String _kCustomChannelSentinel = "__custom__";

  /// Preset sync sizes (matches admin UX: small counts, then round hundreds,
  /// then +1000 steps up to 20000 for large backfills).
  static const List<int> _kMessageLimitChoices = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    20,
    30,
    50,
    100,
    200,
    500,
    1000,
    2000,
    3000,
    4000,
    5000,
    6000,
    7000,
    8000,
    9000,
    10000,
    11000,
    12000,
    13000,
    14000,
    15000,
    16000,
    17000,
    18000,
    19000,
    20000,
  ];

  static const BorderRadius _kFieldBorderRadius =
      BorderRadius.all(Radius.circular(8));

  final IAdminTelegramSyncService _service = getIt<IAdminTelegramSyncService>();
  final IAdminUserService _adminUserService = getIt<IAdminUserService>();
  final IAdminAreaPriceCacheService _areaPriceCacheService =
      getIt<IAdminAreaPriceCacheService>();
  final _chatController =
      TextEditingController(text: _kDefaultKnownChannels.first);
  final _exportMaxRowsController = TextEditingController(text: "100000");

  /// Current selection in the chat dropdown. Holds either a handle from
  /// [_knownChannels] or [_kCustomChannelSentinel] when the admin wants to
  /// type a one-off chat target.
  String _selectedChannel = _kDefaultKnownChannels.first;
  final List<String> _knownChannels = [..._kDefaultKnownChannels];

  final List<AdminUser> _adminUsers = [];
  bool _loadingChannels = false;
  String? _channelsError;
  bool _loadingAdmins = true;
  String? _adminsError;
  int? _selectedImportUserId;
  int _selectedMessageLimit = 20;

  late final FixedExtentScrollController _messageLimitScrollController;

  bool _newestFirst = true;
  bool _skipListingImport = false;
  bool _running = false;
  bool _addingChannel = false;
  bool _exporting = false;
  bool _clearingListings = false;
  bool _clearingIngested = false;
  TelegramSyncRunResult? _lastResult;
  String? _errorText;

  bool _refreshingAreaPriceCache = false;
  AreaPriceCacheRefreshResult? _areaPriceCacheResult;
  String? _areaPriceCacheErrorText;

  @override
  void initState() {
    super.initState();
    final limitIndex = _kMessageLimitChoices.indexOf(_selectedMessageLimit);
    _messageLimitScrollController = FixedExtentScrollController(
      initialItem: limitIndex >= 0 ? limitIndex : 0,
    );
    _loadTelegramChannels();
    _loadAdmins();
  }

  @override
  void dispose() {
    _messageLimitScrollController.dispose();
    _chatController.dispose();
    _exportMaxRowsController.dispose();
    super.dispose();
  }

  Future<void> _loadTelegramChannels() async {
    setState(() {
      _loadingChannels = true;
      _channelsError = null;
    });
    try {
      final response = await _service.getChannels();
      final channels = response.channels.isNotEmpty
          ? response.channels
          : _kDefaultKnownChannels;
      setStateIfMounted(() {
        _knownChannels
          ..clear()
          ..addAll(channels);
        _loadingChannels = false;
        if (_selectedChannel != _kCustomChannelSentinel &&
            !_knownChannels.contains(_selectedChannel)) {
          _selectKnownChannel(_knownChannels.first);
        }
      });
    } catch (e) {
      setStateIfMounted(() {
        _loadingChannels = false;
        _channelsError = e.toString();
      });
    }
  }

  void _selectKnownChannel(String channel) {
    _selectedChannel = channel;
    _chatController.text = channel;
    _chatController.selection = TextSelection.fromPosition(
      TextPosition(offset: channel.length),
    );
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
      setStateIfMounted(() {
        _adminUsers
          ..clear()
          ..addAll(list);
        _loadingAdmins = false;
        _selectedImportUserId = _defaultOwnerIdAfterLoad(list);
      });
    } catch (e) {
      setStateIfMounted(() {
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

  String _normalizeTelegramChannelInput(String raw) {
    var value = raw.trim();
    value = value.replaceFirst(
        RegExp(r"^https?://t\.me/", caseSensitive: false), "");
    value = value.replaceFirst(RegExp(r"^t\.me/", caseSensitive: false), "");
    value = value
        .split(RegExp(r"[?#]"))
        .first
        .replaceFirst(RegExp(r"^/+"), "")
        .trim();
    if (value.isEmpty) return "";
    if (!value.startsWith("@") &&
        RegExp(r"^[a-zA-Z][a-zA-Z0-9_]{4,31}$").hasMatch(value)) {
      return "@$value";
    }
    return value;
  }

  Future<void> _showAddChannelDialog() async {
    final controller = TextEditingController();
    String? errorText;
    final channel = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return UydoshAlertDialog(
              title: Text(L10n.get("admin_telegram_sync_add_channel_title")),
              content: TextField(
                controller: controller,
                autofocus: true,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: L10n.get(
                    "admin_telegram_sync_add_channel_label",
                  ),
                  helperText: L10n.get(
                    "admin_telegram_sync_add_channel_helper",
                  ),
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButtonThemed(
                  onPressed: () {
                    HapticFeedbackUtils.impact();
                    Navigator.of(ctx).pop();
                  },
                  child: Text(L10n.get("cancel")),
                ),
                PrimaryButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  surfaceGradientBase: ThemeState().isBlueTheme
                      ? BlueThemeColors.buttonPrimary
                      : ThemeState().cardColor,
                  textColor: ThemeState().isBlueTheme
                      ? BlueThemeColors.textPrimary
                      : theme.colorScheme.onSurface,
                  onPressed: () {
                    HapticFeedbackUtils.impact();
                    final normalized =
                        _normalizeTelegramChannelInput(controller.text);
                    if (normalized.isEmpty ||
                        normalized.length > 128 ||
                        RegExp(r"\s").hasMatch(normalized)) {
                      setDialogState(() {
                        errorText = L10n.get(
                          "admin_telegram_sync_add_channel_invalid",
                        );
                      });
                      return;
                    }
                    Navigator.of(ctx).pop(normalized);
                  },
                  child: Text(L10n.get("admin_telegram_sync_add_channel_save")),
                ),
              ],
            );
          },
        );
      },
    );
    controller.dispose();
    if (channel == null) return;
    await _addTelegramChannel(channel);
  }

  Future<void> _addTelegramChannel(String channel) async {
    setStateIfMounted(() {
      _addingChannel = true;
      _channelsError = null;
      _errorText = null;
    });
    try {
      final response = await _service.addChannel(channel);
      final channels = response.channels.isNotEmpty
          ? response.channels
          : [..._knownChannels, channel];
      final requestedSelection = response.channel ?? channel;
      final selected = channels.firstWhere(
        (item) => item.toLowerCase() == requestedSelection.toLowerCase(),
        orElse: () => requestedSelection,
      );
      setStateIfMounted(() {
        _knownChannels
          ..clear()
          ..addAll(channels);
        _selectKnownChannel(selected);
        _addingChannel = false;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.getWithParams(
          "admin_telegram_sync_add_channel_done",
          params: {"channel": selected},
        ),
      );
    } catch (e) {
      setStateIfMounted(() {
        _addingChannel = false;
        _channelsError = e.toString();
        _errorText = e.toString();
      });
    }
  }

  Future<void> _run() async {
    final chat = _chatController.text.trim();
    final importUserId = _selectedImportUserId;

    if (chat.isEmpty) {
      setState(() {
        _errorText = L10n.get("admin_telegram_sync_invalid_chat_limit");
        _lastResult = null;
      });
      return;
    }

    setState(() {
      _running = true;
      _errorText = null;
      _lastResult = null;
    });

    try {
      final r = await _service.runSync(
        chat: chat,
        limit: _selectedMessageLimit,
        newestFirst: _newestFirst,
        skipListingImport: _skipListingImport,
        importUserId: importUserId,
      );
      if ((r.listingImport?.imported ?? 0) > 0) {
        await PendingListingModerationState().refresh();
      }
      setStateIfMounted(() {
        _lastResult = r;
        _running = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _errorText = e.toString();
        _running = false;
      });
    }
  }

  Future<bool> _confirmDestructive({
    required String title,
    required String body,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return UydoshAlertDialog(
          scrollable: true,
          title: Text(title),
          content: Text(body),
          actions: [
            TextButtonThemed(
              onPressed: () {
                HapticFeedbackUtils.impact();
                Navigator.of(ctx).pop(false);
              },
              child: Text(L10n.get("cancel")),
            ),
            PrimaryButton(
              surfaceGradientBase: theme.colorScheme.error,
              textColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onPressed: () {
                HapticFeedbackUtils.impact();
                Navigator.of(ctx).pop(true);
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _clearAllListings() async {
    final confirmed = await _confirmDestructive(
      title: L10n.get("admin_data_import_clear_listings_confirm_title"),
      body: L10n.get("admin_data_import_clear_listings_confirm_body"),
      confirmLabel: L10n.get("admin_data_import_clear_confirm_action"),
    );
    if (!confirmed) return;

    setStateIfMounted(() {
      _clearingListings = true;
      _errorText = null;
    });
    try {
      final r = await _service.clearAllListings();
      ToastTheme.showSuccess(
        context,
        message: L10n.getWithParams(
          "admin_data_import_clear_listings_done",
          params: {
            "listings_str": L10n.plural(
              "listings_count",
              r.listingsDeleted,
            ),
            "ingested_str": L10n.plural(
              "ingested_messages_count",
              r.ingestedMessagesDeleted,
            ),
          },
        ),
      );
    } catch (e) {
      setStateIfMounted(() {
        _errorText = e.toString();
      });
    } finally {
      setStateIfMounted(() => _clearingListings = false);
    }
  }

  Future<void> _clearIngestedMessages() async {
    final confirmed = await _confirmDestructive(
      title: L10n.get("admin_data_import_clear_ingested_confirm_title"),
      body: L10n.get("admin_data_import_clear_ingested_confirm_body"),
      confirmLabel: L10n.get("admin_data_import_clear_confirm_action"),
    );
    if (!confirmed) return;

    setStateIfMounted(() {
      _clearingIngested = true;
      _errorText = null;
    });
    try {
      final r = await _service.clearAllIngestedMessages();
      ToastTheme.showSuccess(
        context,
        message: L10n.getWithParams(
          "admin_data_import_clear_ingested_done",
          params: {
            "ingested_str": L10n.plural(
              "ingested_messages_count",
              r.ingestedMessagesDeleted,
            ),
          },
        ),
      );
    } catch (e) {
      setStateIfMounted(() {
        _errorText = e.toString();
      });
    } finally {
      setStateIfMounted(() => _clearingIngested = false);
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
      ToastTheme.showSuccessSimple(
        context,
        message: L10n.get("admin_telegram_export_done"),
      );
    } catch (e) {
      setStateIfMounted(() {
        _errorText = e.toString();
      });
    } finally {
      setStateIfMounted(() => _exporting = false);
    }
  }

  Future<void> _refreshAreaPriceCache() async {
    setState(() {
      _refreshingAreaPriceCache = true;
      _areaPriceCacheErrorText = null;
      _areaPriceCacheResult = null;
    });
    try {
      final r = await _areaPriceCacheService.refreshCache();
      setStateIfMounted(() {
        _areaPriceCacheResult = r;
        _refreshingAreaPriceCache = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _areaPriceCacheErrorText = e.toString();
        _refreshingAreaPriceCache = false;
      });
    }
  }

  Widget _bulletLine(
    String text, {
    EdgeInsetsGeometry padding = const EdgeInsets.only(bottom: 6),
    double indent = 0,
  }) {
    final theme = Theme.of(context);
    final bulletColor = theme.colorScheme.onSurfaceVariant;
    const discSize = 6.0;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: indent),
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: discSize,
              height: discSize,
              decoration:
                  BoxDecoration(color: bulletColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: SelectableText(text)),
        ],
      ),
    );
  }

  Widget _resultView(TelegramSyncRunResult r) {
    final theme = Theme.of(context);
    final li = r.listingImport;
    final created = li?.imported ?? 0;

    final sectionTitleStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );

    final dbSyncSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          L10n.get("admin_telegram_sync_sync_section"),
          style: sectionTitleStyle,
        ),
        const SizedBox(height: 8),
        _bulletLine(
            "${L10n.get("admin_telegram_sync_log_scanned")}: ${r.sync.scanned}"),
        _bulletLine("${L10n.get("admin_telegram_sync_log_created")}: $created"),
        _bulletLine(
          "${L10n.get("admin_telegram_sync_log_skipped_no_peer")}: ${r.sync.skippedNoPeer}",
        ),
        _bulletLine(
          "${L10n.get("admin_telegram_sync_log_skipped_broadcast")}: ${r.sync.skippedBroadcast}",
        ),
      ],
    );

    final listingImportSection = li == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                L10n.get("admin_telegram_sync_listing_section"),
                style: sectionTitleStyle,
              ),
              const SizedBox(height: 8),
              _bulletLine(
                "${L10n.get("admin_telegram_sync_log_created")}: ${li.imported}",
              ),
              _bulletLine(
                "${L10n.get("admin_telegram_sync_log_skipped_empty")}: ${li.skippedEmpty}",
              ),
              _bulletLine(
                "${L10n.get("admin_telegram_sync_log_skipped_broadcast")}: ${li.skippedBroadcast}",
              ),
              _bulletLine(
                "${L10n.get("admin_telegram_sync_log_skipped_no_type")}: ${li.skippedNoListingType}",
              ),
              _bulletLine(
                "${L10n.get("admin_telegram_sync_log_skipped_failed")}: ${li.skippedFailed}",
              ),
              if (li.errors.isNotEmpty) ...[
                const SizedBox(height: 8),
                SelectableText(
                  L10n.get("admin_telegram_sync_log_errors_title"),
                  style: sectionTitleStyle,
                ),
                const SizedBox(height: 6),
                ...li.errors.take(12).map((e) => _bulletLine(e, indent: 12)),
                if (li.errors.length > 12)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 2),
                    child: SelectableText(
                      L10n.getWithParams(
                        "admin_telegram_sync_log_more",
                        params: {
                          "count": (li.errors.length - 12).toString(),
                        },
                      ),
                    ),
                  ),
              ],
            ],
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (li == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dbSyncSection,
            ],
          );
        }

        // Prefer true 2-column layout on phones/tablets. On very narrow widths,
        // fall back to a single column to avoid cramped/overflowing bullets.
        const gap = 24.0;
        final maxWidth = constraints.maxWidth;
        if (maxWidth < 320) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dbSyncSection,
              const SizedBox(height: 12),
              listingImportSection,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: dbSyncSection),
            const SizedBox(width: gap),
            Expanded(child: listingImportSection),
          ],
        );
      },
    );
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
    // We render fields inside [NeumorphicInsetContainer], so borders must be
    // transparent and compact.
    return InputDecoration(
      labelText: labelText,
      helperText: helperText,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
      filled: false,
      fillColor: Colors.transparent,
      labelStyle: TextStyle(
        color: ThemeState().isBlueTheme
            ? BlueThemeColors.textSecondary
            : theme.colorScheme.onSurfaceVariant,
      ),
      floatingLabelStyle: TextStyle(
        color: ThemeState().isBlueTheme
            ? BlueThemeColors.primaryLight
            : theme.colorScheme.primary,
      ),
      helperStyle: TextStyle(
        color: ThemeState().isBlueTheme
            ? BlueThemeColors.textHint
            : theme.colorScheme.onSurfaceVariant,
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: _kFieldBorderRadius,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
        borderRadius: _kFieldBorderRadius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBlue = ThemeState().isBlueTheme;
    final fieldStyle = isBlue
        ? const TextStyle(color: BlueThemeColors.textPrimary, fontSize: 16)
        : null;
    final primaryButtonBase =
        isBlue ? BlueThemeColors.buttonPrimary : ThemeState().cardColor;
    final primaryButtonText = isBlue
        ? BlueThemeColors.textPrimary
        : Theme.of(context).colorScheme.onSurface;
    final primaryButtonPadding =
        const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_telegram_sync_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: KeyboardDismissScope(
        child: ListView(
          padding: const EdgeInsets.all(20),
          keyboardDismissBehavior: KeyboardDismissScope.scrollBehavior,
          children: [
            if (_errorText != null) ...[
              SelectableText(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 16),
            ],
            _neumorphicTile(
              context: context,
              // Don't clip: TextField floating labels can extend upward slightly.
              clipBehavior: Clip.none,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: const ExpansionTileThemeData(
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                  ),
                ),
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
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  // Extra top padding prevents any label overlap in tight layouts.
                  childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  title: _expansionSectionTitle(
                    context,
                    title: L10n.get("admin_telegram_sync_title"),
                    icon: Icons.sync,
                  ),
                  children: [
                    NeumorphicInsetContainer(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      backgroundColor: isBlue ? BlueThemeColors.surface : null,
                      child: UydoshDropdownFormField<String>(
                        value: _selectedChannel,
                        decoration: _fieldDecoration(
                          context,
                          labelText: L10n.get("admin_telegram_sync_chat_label"),
                        ),
                        style: fieldStyle,
                        isExpanded: true,
                        materialMenuOverlay: true,
                        menuOverlayColor:
                            isBlue ? BlueThemeColors.surface : null,
                        dropdownIconColor:
                            isBlue ? BlueThemeColors.textPrimary : null,
                        items: [
                          for (final handle in _knownChannels)
                            DropdownMenuItem<String>(
                              value: handle,
                              child: Text(
                                handle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          DropdownMenuItem<String>(
                            value: _kCustomChannelSentinel,
                            child: Text(
                              L10n.get("admin_telegram_sync_channel_custom"),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        onChanged: _running
                            ? null
                            : (v) {
                                if (v == null) return;
                                setState(() {
                                  _selectedChannel = v;
                                  if (v != _kCustomChannelSentinel) {
                                    _selectKnownChannel(v);
                                  } else {
                                    _chatController.clear();
                                  }
                                });
                              },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GhostButtonFactory.iconTextCentered(
                        onPressed:
                            (_running || _addingChannel || _loadingChannels)
                                ? null
                                : _showAddChannelDialog,
                        icon: Icons.add,
                        text: _loadingChannels
                            ? L10n.get("admin_telegram_sync_channels_loading")
                            : L10n.get("admin_telegram_sync_add_channel"),
                        isLoading: _addingChannel,
                        height: 44,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        neumorphicSoftUi: true,
                        neumorphicFillColor:
                            isBlue ? BlueThemeColors.surface : null,
                      ),
                    ),
                    if (_channelsError != null) ...[
                      const SizedBox(height: 8),
                      SelectableText(
                        _channelsError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (_selectedChannel == _kCustomChannelSentinel) ...[
                      const SizedBox(height: 12),
                      NeumorphicInsetContainer(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        backgroundColor:
                            isBlue ? BlueThemeColors.surface : null,
                        child: TextField(
                          controller: _chatController,
                          style: fieldStyle,
                          decoration: _fieldDecoration(
                            context,
                            labelText: L10n.get(
                                "admin_telegram_sync_chat_custom_label"),
                          ),
                          autocorrect: false,
                          enabled: !_running,
                        ),
                      ),
                    ],
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
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
                      PrimaryButtonFactory.iconTextCentered(
                        onPressed: _loadAdmins,
                        icon: Icons.refresh,
                        text: L10n.get("admin_telegram_sync_admins_retry"),
                        width: double.infinity,
                        height: 48,
                        padding: primaryButtonPadding,
                        surfaceGradientBase: primaryButtonBase,
                        textColor: primaryButtonText,
                      ),
                    ] else ...[
                      if (_adminUsers.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            L10n.get("admin_telegram_sync_admins_empty"),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      NeumorphicInsetContainer(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                        backgroundColor:
                            isBlue ? BlueThemeColors.surface : null,
                        child: UydoshDropdownFormField<int?>(
                          value: _selectedImportUserId,
                          decoration: _fieldDecoration(
                            context,
                            labelText: L10n.get(
                                "admin_telegram_sync_import_user_label"),
                          ),
                          style: fieldStyle,
                          isExpanded: true,
                          materialMenuOverlay: true,
                          menuOverlayColor:
                              isBlue ? BlueThemeColors.surface : null,
                          dropdownIconColor:
                              isBlue ? BlueThemeColors.textPrimary : null,
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(
                                L10n.get(
                                    "admin_telegram_sync_import_user_sync_only"),
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
                              : (v) {
                                  setState(() => _selectedImportUserId = v);
                                },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(L10n.get("admin_telegram_sync_newest_first")),
                      trailing: NeumorphicThemeAwareToggle(
                        value: _newestFirst,
                        enabled: !_running,
                        onChanged: (v) => setState(() => _newestFirst = v),
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          L10n.get("admin_telegram_sync_skip_listing_import")),
                      trailing: NeumorphicThemeAwareToggle(
                        value: _skipListingImport,
                        enabled: !_running,
                        onChanged: (v) =>
                            setState(() => _skipListingImport = v),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        L10n.get("admin_telegram_sync_limit_label"),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isBlue
                                  ? BlueThemeColors.textSecondary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    IgnorePointer(
                      ignoring: _running,
                      child: Opacity(
                        opacity: _running ? 0.5 : 1,
                        child: Container(
                          decoration:
                              ThreeDSurfaceStyle.wheelPickerPlateDecoration(
                            context,
                            theme: Theme.of(context),
                          ),
                          height: 80,
                          child: CupertinoPicker(
                            backgroundColor: Colors.transparent,
                            changeReportingBehavior:
                                ChangeReportingBehavior.onScrollEnd,
                            itemExtent: 40,
                            scrollController: _messageLimitScrollController,
                            onSelectedItemChanged: (index) {
                              SendSoundUtils.playCupertinoWheelSound();
                              setState(() {
                                _selectedMessageLimit =
                                    _kMessageLimitChoices[index];
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
                    PrimaryButton(
                      onPressed: _running ? null : _run,
                      width: double.infinity,
                      height: 48,
                      padding: primaryButtonPadding,
                      surfaceGradientBase: primaryButtonBase,
                      textColor: primaryButtonText,
                      isLoading: _running,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ThemeIcon(Icons.sync),
                          const SizedBox(width: 8),
                          Text(
                            _running
                                ? L10n.get("admin_telegram_sync_running")
                                : L10n.get("admin_telegram_sync_run"),
                          ),
                        ],
                      ),
                    ),
                    if (_lastResult != null) ...[
                      const SizedBox(height: 20),
                      _resultView(_lastResult!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _neumorphicTile(
              context: context,
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: const ExpansionTileThemeData(
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                  ),
                ),
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
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  title: _expansionSectionTitle(
                    context,
                    title: L10n.get("admin_area_price_cache_section_title"),
                    icon: Icons.analytics_outlined,
                  ),
                  children: [
                    Text(
                      L10n.get("admin_area_price_cache_screen_body"),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      onPressed: _refreshingAreaPriceCache
                          ? null
                          : _refreshAreaPriceCache,
                      width: double.infinity,
                      height: 48,
                      padding: primaryButtonPadding,
                      surfaceGradientBase: primaryButtonBase,
                      textColor: primaryButtonText,
                      isLoading: _refreshingAreaPriceCache,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ThemeIcon(Icons.analytics_outlined),
                          const SizedBox(width: 8),
                          Text(
                            _refreshingAreaPriceCache
                                ? L10n.get("admin_area_price_cache_running")
                                : L10n.get("admin_area_price_cache_run"),
                          ),
                        ],
                      ),
                    ),
                    if (_areaPriceCacheErrorText != null) ...[
                      const SizedBox(height: 16),
                      SelectableText(
                        _areaPriceCacheErrorText!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ],
                    if (_areaPriceCacheResult != null) ...[
                      const SizedBox(height: 16),
                      SelectableText(
                        L10n.get("admin_telegram_sync_result_header"),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _bulletLine(
                        "• Duration: ${_areaPriceCacheResult!.durationMs} ms",
                        padding: const EdgeInsets.only(bottom: 4),
                      ),
                      _bulletLine(
                        "• Cache rows: ${_areaPriceCacheResult!.rowCount}",
                        padding: const EdgeInsets.only(bottom: 4),
                      ),
                      _bulletLine(
                        "• Source listings: ${_areaPriceCacheResult!.listingCount}",
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _neumorphicTile(
              context: context,
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: const ExpansionTileThemeData(
                    backgroundColor: Colors.transparent,
                    collapsedBackgroundColor: Colors.transparent,
                  ),
                ),
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
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    NeumorphicInsetContainer(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      backgroundColor: isBlue ? BlueThemeColors.surface : null,
                      child: TextField(
                        controller: _exportMaxRowsController,
                        style: fieldStyle,
                        decoration: _fieldDecoration(
                          context,
                          labelText:
                              L10n.get("admin_telegram_export_max_rows_label"),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        enabled: !_exporting,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      onPressed:
                          (_running || _exporting) ? null : _downloadExport,
                      width: double.infinity,
                      height: 48,
                      padding: primaryButtonPadding,
                      surfaceGradientBase: primaryButtonBase,
                      textColor: primaryButtonText,
                      isLoading: _exporting,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const ThemeIcon(Icons.download_outlined),
                          const SizedBox(width: 8),
                          Text(
                            _exporting
                                ? L10n.get("admin_telegram_export_running")
                                : L10n.get("admin_telegram_export_download"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDangerZone(context, isBlue: isBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, {required bool isBlue}) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    final busy =
        _running || _exporting || _clearingListings || _clearingIngested;
    final pad = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return _neumorphicTile(
      context: context,
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
          ),
        ),
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
          title: Row(
            children: [
              ThemeIcon(Icons.warning_amber_rounded, color: errorColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L10n.get("admin_data_import_danger_section_title"),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: errorColor,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Text(
              L10n.get("admin_data_import_danger_intro"),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            GhostButtonFactory.iconTextCentered(
              onPressed: busy ? null : _clearAllListings,
              icon: Icons.delete_sweep_outlined,
              text: _clearingListings
                  ? L10n.get("admin_data_import_clear_listings_running")
                  : L10n.get("admin_data_import_clear_listings_button"),
              width: double.infinity,
              height: 48,
              padding: pad,
              borderColor: errorColor,
              textColor: errorColor,
              iconColor: errorColor,
              isLoading: _clearingListings,
            ),
            const SizedBox(height: 12),
            GhostButtonFactory.iconTextCentered(
              onPressed: busy ? null : _clearIngestedMessages,
              icon: Icons.delete_outline,
              text: _clearingIngested
                  ? L10n.get("admin_data_import_clear_ingested_running")
                  : L10n.get("admin_data_import_clear_ingested_button"),
              width: double.infinity,
              height: 48,
              padding: pad,
              borderColor: errorColor,
              textColor: errorColor,
              iconColor: errorColor,
              isLoading: _clearingIngested,
            ),
          ],
        ),
      ),
    );
  }
}
