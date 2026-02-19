import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/models/admin_user.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_listings_screen.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/base/localization/l10n.dart";

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

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _selectedRole = widget.user.role;
    _currentRole = widget.user.role;
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
        appBar: AppBar(
          title: Text(
            L10n.get("admin_user_detail_title"),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithResult,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(context),
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

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentUser.email ??
                  L10n.get("not_specified"),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Icon(
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
                  onPressed: _blocking ? null : _unblockUser,
                  icon: _blocking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open),
                  label: Text(
                    L10n.get("admin_user_detail_unblock"),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _blocking ? null : _showBlockDialog,
                  icon: _blocking
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.block),
                  label: Text(
                    L10n.get("admin_user_detail_block"),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error),
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
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(const Duration(days: 7)),
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
                  onPressed: () => setDialogState(() => blockedUntil = null),
                  child: Text(
L10n.get("admin_user_detail_block_permanent"),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(L10n.get("cancel")),
            ),
            ElevatedButton(
              onPressed: () {
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
      if (!mounted) return;
      setState(() {
        _blocking = false;
        _currentUser = updated;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_user_detail_blocked_success"),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _blocking = false);
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Future<void> _unblockUser() async {
    setState(() => _blocking = true);
    try {
      final updated = await getIt<IAdminUserService>().unblockUser(
        userId: _currentUser.id,
      );
      if (!mounted) return;
      setState(() {
        _blocking = false;
        _currentUser = updated;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_user_detail_unblocked_success"),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _blocking = false);
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Widget _buildRoleCard(BuildContext context, {required bool canSave}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              initialValue: _selectedRole,
              items:
                  _roleOptions(context)
                      .map(
                        (item) => DropdownMenuItem<String?>(
                          value: item.value,
                          child: Text(item.label),
                        ),
                      )
                      .toList(),
              onChanged: _saving ? null : (value) => setState(() => _selectedRole = value),
              decoration: InputDecoration(
labelText: L10n.get("admin_user_detail_role_label"),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: !_saving && canSave ? _updateRole : null,
                child:
                    _saving
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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: Text(
              L10n.get("admin_user_detail_view_listings"),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AdminUserListingsScreen(
                        userId: _currentUser.id,
                        userEmail: _currentUser.email,
                      ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: Text(
              L10n.get("admin_user_detail_view_complaints"),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AdminUserComplaintsScreen(
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
      if (!mounted) return;
      setState(() {
        _saving = false;
        _currentRole = updated.role;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_user_detail_role_updated"),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
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
}

class _RoleOption {
  const _RoleOption({required this.value, required this.label});

  final String? value;
  final String label;
}
