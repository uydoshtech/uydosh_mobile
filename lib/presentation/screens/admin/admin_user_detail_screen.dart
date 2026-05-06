import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/apple_device_model_name.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/models/admin_user.dart";
import "package:uy_dosh/domain/models/admin_user_device.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_listings_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_search_alerts_screen.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({required this.user, super.key});

  final AdminUser user;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  String? _selectedRole;
  String? _currentRole;
  bool _saving = false;
  late AdminUser _currentUser;
  bool _blocking = false;
  String? _avatarUrl;
  String? _profileName;

  List<AdminUserDevice>? _devices;
  bool _devicesLoading = false;
  String? _devicesError;
  bool _devicesExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _selectedRole = widget.user.role;
    _currentRole = widget.user.role;
    _loadProfile();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    if (_currentUser.id <= 0) return;
    setState(() {
      _devicesLoading = true;
      _devicesError = null;
    });
    try {
      final devices = await getIt<IAdminUserService>().getUserDevices(
        userId: _currentUser.id,
      );
      setStateIfMounted(() {
        _devices = devices;
        _devicesLoading = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _devicesError = e.toString();
        _devicesLoading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    if (_currentUser.id <= 0) return;
    try {
      final profile =
          await getIt<IUserProfileService>().getUserProfile(_currentUser.id);
      setStateIfMounted(() {
        _avatarUrl = profile.avatarUrl;
        _profileName = profile.name;
      });
    } catch (_) {
      // Non-critical: leave avatar/name empty if profile fetch fails.
    }
  }

  void _popWithResult() {
    Navigator.of(context).pop({
      "userId": _currentUser.id,
      "role": _currentRole,
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _selectedRole != null && _selectedRole != _currentRole;
    return Scaffold(
      appBar: UydoshAppBar(
        title: Text(
          L10n.get("admin_user_detail_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: ThreeDAppBarIconButton.backLeading(
          context,
          onPressed: _popWithResult,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(context),
          const SizedBox(height: 12),
          _buildDevicesCard(context),
          const SizedBox(height: 12),
          _buildBlockCard(context),
          const SizedBox(height: 12),
          _buildRoleCard(context, canSave: canSave),
          const SizedBox(height: 12),
          _buildActionsCard(context),
        ],
      ),
    );
  }

  Widget _buildDevicesCard(BuildContext context) {
    final theme = Theme.of(context);
    final subtleColor = theme.colorScheme.onSurfaceVariant;
    final count = _devices?.length ?? 0;
    final hasDevices = count > 0;

    return _NeumorphicTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () =>
                setState(() => _devicesExpanded = !_devicesExpanded),
            borderRadius: _devicesExpanded
                ? const BorderRadius.vertical(top: Radius.circular(16))
                : const BorderRadius.all(Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          L10n.get("admin_user_detail_devices_title"),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hasDevices) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: L10n.get("retry"),
                    icon: const ThemeIcon(Icons.refresh, size: 18),
                    onPressed: _devicesLoading
                        ? null
                        : () {
                            HapticFeedbackUtils.impact();
                            _loadDevices();
                          },
                  ),
                  AnimatedRotation(
                    turns: _devicesExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: ThemeIcon(
                      Icons.keyboard_arrow_down,
                      color: subtleColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _devicesExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildDevicesBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesBody(BuildContext context) {
    final theme = Theme.of(context);
    final subtleColor = theme.colorScheme.onSurfaceVariant;
    if (_devicesLoading && _devices == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_devicesError != null) {
      return Text(
        _devicesError!,
        style: TextStyle(fontSize: 12, color: theme.colorScheme.error),
      );
    }
    if (_devices == null || _devices!.isEmpty) {
      return Text(
        L10n.get("admin_user_detail_devices_empty"),
        style: TextStyle(fontSize: 13, color: subtleColor),
      );
    }
    return Column(
      children: [
        for (int i = 0; i < _devices!.length; i++) ...[
          if (i > 0)
            Divider(
              height: 16,
              color: theme.dividerColor.withValues(alpha: 0.15),
            ),
          _buildDeviceRow(context, _devices![i]),
        ],
      ],
    );
  }

  Widget _buildDeviceRow(BuildContext context, AdminUserDevice device) {
    final theme = Theme.of(context);
    final subtleColor = theme.colorScheme.onSurfaceVariant;
    final platform = (device.platform ?? "").toLowerCase();
    final IconData platformIcon;
    if (platform == "ios") {
      platformIcon = Icons.phone_iphone;
    } else if (platform == "android") {
      platformIcon = Icons.phone_android;
    } else {
      platformIcon = Icons.devices;
    }
    final rawModel = (device.deviceModel ?? "").trim();
    final modelLine = rawModel.isNotEmpty
        ? (platform == "ios" ? AppleDeviceModelName.format(rawModel) : rawModel)
        : L10n.get("admin_user_detail_devices_model_unknown");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: ThemeIcon(platformIcon, size: 22, color: subtleColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                modelLine,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _composeDeviceSubtitle(device),
                style: TextStyle(fontSize: 12, color: subtleColor),
              ),
              if (device.lastSeenAt != null) ...[
                const SizedBox(height: 2),
                Text(
                  "${L10n.get("admin_user_detail_devices_last_seen")}: ${_formatDateTime(device.lastSeenAt!)}",
                  style: TextStyle(fontSize: 11, color: subtleColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _composeDeviceSubtitle(AdminUserDevice device) {
    final parts = <String>[];
    final os = (device.osVersion ?? "").trim();
    if (os.isNotEmpty) parts.add(os);
    final app = (device.appVersion ?? "").trim();
    if (app.isNotEmpty) {
      parts.add("${L10n.get("admin_user_detail_devices_app_prefix")} $app");
    }
    if (parts.isEmpty) {
      return L10n.get("admin_user_detail_devices_details_unknown");
    }
    return parts.join(" · ");
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final locale = LanguageState().currentLanguage;
    try {
      return _capitalizeMonth(
        DateFormat("dd/MMMM/yyyy HH:mm", locale).format(local),
      );
    } catch (_) {
      return _capitalizeMonth(DateFormat("dd/MMMM/yyyy HH:mm").format(local));
    }
  }

  String _capitalizeMonth(String dateText) {
    final parts = dateText.split("/");
    if (parts.length < 2) {
      return dateText;
    }
    final month = parts[1];
    if (month.isEmpty) {
      return dateText;
    }
    parts[1] = "${month.substring(0, 1).toUpperCase()}${month.substring(1)}";
    return parts.join("/");
  }

  Widget _buildInfoCard(BuildContext context) {
    return _NeumorphicTile(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _AdminUserAvatar(
                  avatarUrl: _avatarUrl,
                  initials: _buildUserInitials(
                    name: _profileName,
                    email: _currentUser.email,
                  ),
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentUser.email ?? L10n.get("not_specified"),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_profileName != null &&
                          _profileName!.trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _profileName!.trim(),
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildMetaRow(
              context,
              labelKey: "admin_users_id",
              value: _currentUser.id.toString(),
            ),
            _buildMetaRow(
              context,
              labelKey: "admin_users_role",
              value: _getRoleLabel(_currentRole, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockCard(BuildContext context) {
    final blocked = _currentUser.isCurrentlyBlocked;
    return _NeumorphicTile(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.get("admin_user_detail_block_title"),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (blocked) ...[
              Row(
                children: [
                  ThemeIcon(
                    Icons.block,
                    color: Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    L10n.get("admin_user_detail_blocked"),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (_currentUser.blockedReason != null &&
                  _currentUser.blockedReason!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "${L10n.get("admin_user_detail_block_reason")}: ${_currentUser.blockedReason}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              if (_currentUser.blockedUntil != null) ...[
                const SizedBox(height: 4),
                Text(
                  "${L10n.get("admin_user_detail_block_until")}: ${_currentUser.blockedUntil!.toIso8601String().split("T")[0]}",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _blocking
                      ? null
                      : () {
                          HapticFeedbackUtils.impact();
                          _unblockUser();
                        },
                  icon: _blocking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const ThemeIcon(Icons.lock_open),
                  label: Text(
                    L10n.get("admin_user_detail_unblock"),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _blocking
                      ? null
                      : () {
                          HapticFeedbackUtils.impact();
                          _showBlockDialog();
                        },
                  icon: _blocking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : ThemeIcon(
                          Icons.block,
                          color: Theme.of(context).colorScheme.error,
                        ),
                  label: Text(
                    L10n.get("admin_user_detail_block"),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side:
                        BorderSide(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBlockDialog() {
    final reasonController = TextEditingController();
    DateTime? blockedUntil;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(
            L10n.get("admin_user_detail_block"),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: L10n.get("admin_user_detail_block_reason"),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    L10n.get("admin_user_detail_block_until"),
                  ),
                  subtitle: Text(
                    blockedUntil != null
                        ? blockedUntil!.toIso8601String().split("T")[0]
                        : L10n.get("admin_user_detail_block_permanent"),
                  ),
                  trailing: IconButton(
                    icon: const ThemeIcon(Icons.calendar_today),
                    onPressed: () async {
                      HapticFeedbackUtils.impact();
                      final date = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() => blockedUntil = date);
                      }
                    },
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedbackUtils.impact();
                    setDialogState(() => blockedUntil = null);
                  },
                  child: Text(
                    L10n.get("admin_user_detail_block_permanent"),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedbackUtils.impact();
                Navigator.of(ctx).pop();
              },
              child: Text(L10n.get("cancel")),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedbackUtils.impact();
                Navigator.of(ctx).pop();
                _blockUser(
                  reason: reasonController.text.trim().isEmpty
                      ? null
                      : reasonController.text.trim(),
                  blockedUntil: blockedUntil,
                );
              },
              child: Text(L10n.get("admin_user_detail_block_confirm")),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _blockUser({String? reason, DateTime? blockedUntil}) async {
    setState(() => _blocking = true);
    try {
      final updated = await getIt<IAdminUserService>().blockUser(
        userId: _currentUser.id,
        reason: reason,
        blockedUntil: blockedUntil,
      );
      setStateIfMounted(() {
        _blocking = false;
        _currentUser = updated;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_user_detail_blocked_success"),
      );
    } catch (e) {
      setStateIfMounted(() => _blocking = false);
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Future<void> _unblockUser() async {
    setState(() => _blocking = true);
    try {
      final updated = await getIt<IAdminUserService>().unblockUser(
        userId: _currentUser.id,
      );
      setStateIfMounted(() {
        _blocking = false;
        _currentUser = updated;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_user_detail_unblocked_success"),
      );
    } catch (e) {
      setStateIfMounted(() => _blocking = false);
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Widget _buildRoleCard(BuildContext context, {required bool canSave}) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final roleFieldFillColor = isBlueTheme
        ? theme.colorScheme.surface.withValues(alpha: 0.22)
        : null;

    return _NeumorphicTile(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.get("admin_user_detail_role_title"),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              key: ValueKey(_currentUser.id),
              value: _selectedRole,
              elevation: AppTheme.menuPanelElevation,
              items: _roleOptions(context)
                  .map(
                    (item) => DropdownMenuItem<String?>(
                      value: item.value,
                      child: Text(item.label),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _selectedRole = value),
              style: isBlueTheme
                  ? theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      )
                  : null,
              dropdownColor: isBlueTheme
                  ? Colors.blue.shade600.withValues(
                      alpha: AppTheme.menuOverlaySurfaceOpacity,
                    )
                  : theme.popupMenuTheme.color,
              decoration: InputDecoration(
                filled: roleFieldFillColor != null,
                fillColor: roleFieldFillColor,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_saving && canSave
                    ? () {
                        HapticFeedbackUtils.impact();
                        _updateRole();
                      }
                    : null,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        L10n.get("admin_user_detail_role_save"),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return _NeumorphicTile(
      child: Column(
        children: [
          ListTile(
            leading: const ThemeIcon(Icons.list_alt),
            title: Text(
              L10n.get("admin_user_detail_view_listings"),
            ),
            trailing: const ThemeIcon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminUserListingsScreen(
                    userId: _currentUser.id,
                    userEmail: _currentUser.email,
                  ),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
          ListTile(
            leading: const ThemeIcon(Icons.report_problem),
            title: Text(
              L10n.get("admin_user_detail_view_complaints"),
            ),
            trailing: const ThemeIcon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminUserComplaintsScreen(
                    userId: _currentUser.id,
                    userEmail: _currentUser.email,
                  ),
                ),
              );
            },
          ),
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
          ListTile(
            leading: const ThemeIcon(Icons.filter_alt_outlined),
            title: Text(
              L10n.get("admin_user_detail_view_alerts"),
            ),
            trailing: const ThemeIcon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdminUserSearchAlertsScreen(
                    userId: _currentUser.id,
                    userEmail: _currentUser.email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<_RoleOption> _roleOptions(BuildContext context) {
    return [
      _RoleOption(
        value: null,
        label: L10n.get("not_specified"),
      ),
      _RoleOption(
        value: "tenant",
        label: L10n.get("role_tenant"),
      ),
      _RoleOption(
        value: "landlord",
        label: L10n.get("role_landlord"),
      ),
      _RoleOption(
        value: "manager",
        label: L10n.get("role_manager"),
      ),
      _RoleOption(
        value: "admin",
        label: L10n.get("role_admin"),
      ),
    ];
  }

  String _getRoleLabel(String? role, BuildContext context) {
    switch (role) {
      case "tenant":
        return L10n.get("role_tenant");
      case "landlord":
        return L10n.get("role_landlord");
      case "manager":
        return L10n.get("role_manager");
      case "admin":
        return L10n.get("role_admin");
      default:
        return L10n.get("not_specified");
    }
  }

  Future<void> _updateRole() async {
    final role = _selectedRole;
    if (role == null) return;

    setState(() => _saving = true);
    try {
      final updated = await getIt<IAdminUserService>().updateUserRole(
        userId: _currentUser.id,
        role: role,
      );
      setStateIfMounted(() {
        _saving = false;
        _currentRole = updated.role;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_user_detail_role_updated"),
      );
    } catch (e) {
      setStateIfMounted(() => _saving = false);
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required String labelKey,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            "${L10n.get(labelKey)}: ",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String? _buildUserInitials({String? name, String? email}) {
    final source = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : (email != null && email.trim().isNotEmpty ? email.trim() : null);
    if (source == null) return null;

    final parts = source
        .replaceAll(RegExp(r"[^A-Za-zА-Яа-яЁё0-9\s]"), " ")
        .split(RegExp(r"\s+"))
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;

    if (parts.length == 1) {
      final p = parts.first;
      final first = p.isNotEmpty ? p[0] : "";
      final second = p.length >= 2 ? p[1] : "";
      final res = (first + second).toUpperCase();
      return res.trim().isEmpty ? null : res;
    }

    final res = (parts[0][0] + parts[1][0]).toUpperCase();
    return res.trim().isEmpty ? null : res;
  }
}

class _RoleOption {
  const _RoleOption({required this.value, required this.label});

  final String? value;
  final String label;
}

class _NeumorphicTile extends StatelessWidget {
  const _NeumorphicTile({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const tileRadius = BorderRadius.all(Radius.circular(16));

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: tileRadius,
        gradient: ThreeDSurfaceStyle.surfaceGradient(
          context,
          theme.colorScheme.surface,
        ),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: tileRadius),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}

class _AdminUserAvatar extends StatelessWidget {
  const _AdminUserAvatar({
    required this.avatarUrl,
    required this.initials,
    this.size = 36,
  });

  final String? avatarUrl;
  final String? initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final border = onSurface.withValues(alpha: 0.08);

    final url = resolveAvatarUrl(avatarUrl);
    final hasUrl = url != null && url.isNotEmpty;

    Widget content;
    if (hasUrl) {
      content = ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _InitialsAvatarFallback(initials: initials),
        ),
      );
    } else {
      content = _InitialsAvatarFallback(initials: initials);
    }

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(surface, onSurface, 0.02),
          border: Border.all(color: border, width: 1),
        ),
        child: Center(child: content),
      ),
    );
  }
}

class _InitialsAvatarFallback extends StatelessWidget {
  const _InitialsAvatarFallback({required this.initials});

  final String? initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = initials?.trim();
    final hasText = text != null && text.isNotEmpty;

    if (!hasText) {
      return ThemeIcon(
        Icons.person,
        size: 20,
        color: theme.colorScheme.onSurfaceVariant,
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
