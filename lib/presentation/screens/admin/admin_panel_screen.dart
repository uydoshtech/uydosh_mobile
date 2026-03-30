import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/screens/admin/admin_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_content_moderation_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_district_heatmap_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listing_creation_analytics_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listings_with_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_search_analytics_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_subway_line_heatmap_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_subway_map_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_support_chat_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_users_screen.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_card_tile.dart";

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get("admin_panel_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
            L10n.get("admin_panel_description"),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminSection(
            context,
            icon: Icons.photo_filter_outlined,
            titleKey: "admin_panel_section_content_moderation",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminContentModerationScreen(),
                ),
              );
            },
          ),
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
            icon: Icons.support_agent,
            titleKey: "admin_panel_section_support_chat",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminSupportChatScreen(),
                ),
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
          _buildAdminSection(
            context,
            icon: Icons.analytics_outlined,
            titleKey: "admin_panel_section_search_analytics",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminSearchAnalyticsScreen(),
                ),
              );
            },
          ),
          _buildAdminSection(
            context,
            icon: Icons.trending_up,
            titleKey: "admin_panel_section_listing_creation_analytics",
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const AdminListingCreationAnalyticsScreen(),
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
    return UydoshCardTile(
      icon: icon,
      title: Text(L10n.get(titleKey)),
      onTap: onTap,
    );
  }
}
