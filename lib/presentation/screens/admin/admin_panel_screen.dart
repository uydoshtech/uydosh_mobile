import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/screens/admin/admin_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_district_heatmap_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listings_with_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_users_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_subway_line_heatmap_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_subway_map_screen.dart";

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
          _buildAdminSection(
            context,
            icon: Icons.home_work_outlined,
            titleKey: "admin_panel_section_listing_complaints",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (context) =>
                          const AdminListingsWithComplaintsScreen(),
                ),
              );
            },
          ),
          _buildSectionDivider(context),
          _buildAdminSection(
            context,
            icon: Icons.map_outlined,
            titleKey: "admin_panel_section_district_heatmap",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminDistrictHeatmapScreen(),
                ),
              );
            },
          ),
          _buildAdminSection(
            context,
            icon: Icons.train,
            titleKey: "admin_panel_section_subway_heatmap",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminSubwayLineHeatmapScreen(),
                ),
              );
            },
          ),
          _buildSectionDivider(context),
          _buildAdminSection(
            context,
            icon: Icons.subway,
            titleKey: "admin_panel_section_subway_map",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminSubwayMapScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
          alpha: 0.3,
        ),
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
        leading: Icon(
          icon,
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
        ),
        title: Text(LanguageAwareStringHelper.getCurrent(context, titleKey)),
        trailing:
            onTap == null
                ? null
                : Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
        onTap:
            onTap == null
                ? null
                : () {
                  HapticFeedbackUtils.selectionClick();
                  onTap();
                },
      ),
    );
  }
}
