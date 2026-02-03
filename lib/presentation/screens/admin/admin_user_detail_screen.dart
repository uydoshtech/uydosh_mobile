import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/models/admin_user.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_listings_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_complaints_screen.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class AdminUserDetailScreen extends StatefulWidget {
  const AdminUserDetailScreen({super.key, required this.user});

  final AdminUser user;

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  String? _selectedRole;
  String? _currentRole;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    _currentRole = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _selectedRole != null && _selectedRole != _currentRole;
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop({
          "userId": widget.user.id,
          "role": _currentRole,
        });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "admin_user_detail_title",
            ),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop({
                "userId": widget.user.id,
                "role": _currentRole,
              });
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 12),
            _buildRoleCard(context, canSave: canSave),
            const SizedBox(height: 12),
            _buildActionsCard(context),
          ],
        ),
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
              widget.user.email ??
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "not_specified",
                  ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildMetaRow(
              context,
              labelKey: "admin_users_id",
              value: widget.user.id.toString(),
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
              LanguageAwareStringHelper.getCurrent(
                context,
                "admin_user_detail_role_title",
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items:
                  _roleOptions(context)
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.value,
                          child: Text(item.label),
                        ),
                      )
                      .toList(),
              onChanged: _saving ? null : (value) => setState(() => _selectedRole = value),
              decoration: InputDecoration(
                labelText: LanguageAwareStringHelper.getCurrent(
                  context,
                  "admin_user_detail_role_label",
                ),
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
                          LanguageAwareStringHelper.getCurrent(
                            context,
                            "admin_user_detail_role_save",
                          ),
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
              LanguageAwareStringHelper.getCurrent(
                context,
                "admin_user_detail_view_listings",
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AdminUserListingsScreen(
                        userId: widget.user.id,
                        userEmail: widget.user.email,
                      ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.report_problem),
            title: Text(
              LanguageAwareStringHelper.getCurrent(
                context,
                "admin_user_detail_view_complaints",
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) => AdminUserComplaintsScreen(
                        userId: widget.user.id,
                        userEmail: widget.user.email,
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
        value: "tenant",
        label: LanguageAwareStringHelper.getCurrent(context, "role_tenant"),
      ),
      _RoleOption(
        value: "landlord",
        label: LanguageAwareStringHelper.getCurrent(context, "role_landlord"),
      ),
      _RoleOption(
        value: "manager",
        label: LanguageAwareStringHelper.getCurrent(context, "role_manager"),
      ),
      _RoleOption(
        value: "admin",
        label: LanguageAwareStringHelper.getCurrent(context, "role_admin"),
      ),
    ];
  }

  String _getRoleLabel(String? role, BuildContext context) {
    switch (role) {
      case "tenant":
        return LanguageAwareStringHelper.getCurrent(context, "role_tenant");
      case "landlord":
        return LanguageAwareStringHelper.getCurrent(context, "role_landlord");
      case "manager":
        return LanguageAwareStringHelper.getCurrent(context, "role_manager");
      case "admin":
        return LanguageAwareStringHelper.getCurrent(context, "role_admin");
      default:
        return LanguageAwareStringHelper.getCurrent(context, "not_specified");
    }
  }

  Future<void> _updateRole() async {
    final role = _selectedRole;
    if (role == null) return;

    setState(() => _saving = true);
    try {
      final updated = await getIt<IAdminUserService>().updateUserRole(
        userId: widget.user.id,
        role: role,
      );
      if (!mounted) return;
      setState(() {
        _saving = false;
        _currentRole = updated.role;
      });
      ToastTheme.showSuccess(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "admin_user_detail_role_updated",
        ),
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
            "${LanguageAwareStringHelper.getCurrent(context, labelKey)}: ",
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

  final String value;
  final String label;
}
