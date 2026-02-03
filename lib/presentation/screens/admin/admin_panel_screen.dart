import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/screens/admin/admin_users_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_complaints_screen.dart";

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "admin_panel_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            LanguageAwareStringHelper.getCurrent(
              context,
              "admin_panel_description",
            ),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminSection(
            context,
            icon: Icons.people,
            titleKey: "admin_panel_section_users",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdminUsersScreen()),
              );
            },
          ),
          _buildAdminSection(
            context,
            icon: Icons.report_problem,
            titleKey: "admin_panel_section_complaints",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminComplaintsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection(
    BuildContext context, {
    required IconData icon,
    required String titleKey,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(LanguageAwareStringHelper.getCurrent(context, titleKey)),
        trailing:
            onTap == null
                ? null
                : Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
        onTap: onTap,
      ),
    );
  }
}
