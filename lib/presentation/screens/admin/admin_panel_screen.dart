import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/admin/admin_area_price_cache_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_content_moderation_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_district_heatmap_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listing_creation_analytics_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listings_with_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_search_analytics_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_subway_line_heatmap_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_subway_map_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_support_chat_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_telegram_sync_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_users_screen.dart";

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  /// Expanded category indices (0–3: management, maps, analytics, settings).
  final Set<int> _expandedCategories = {0};

  void _toggleCategory(int index) {
    HapticFeedbackUtils.selectionClick();
    setState(() {
      if (_expandedCategories.contains(index)) {
        _expandedCategories.remove(index);
      } else {
        _expandedCategories.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

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
          _AdminCategoryCard(
            headerIcon: Icons.manage_accounts,
            titleKey: "admin_panel_category_management",
            expanded: _expandedCategories.contains(0),
            onHeaderTap: () => _toggleCategory(0),
            iconColor: iconColor,
            children: [
              _AdminMenuRow(
                icon: Icons.people,
                titleKey: "admin_panel_section_users",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminUsersScreen(),
                    ),
                  );
                },
              ),
              _AdminMenuRow(
                icon: Icons.support_agent,
                titleKey: "admin_panel_section_support_chat",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminSupportChatScreen(),
                    ),
                  );
                },
              ),
              _AdminMenuRow(
                icon: Icons.report_problem,
                titleKey: "admin_panel_section_complaints",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminComplaintsScreen(),
                    ),
                  );
                },
              ),
              _AdminMenuRow(
                icon: Icons.home_work_outlined,
                titleKey: "admin_panel_section_listing_complaints",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const AdminListingsWithComplaintsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminCategoryCard(
            headerIcon: Icons.map_outlined,
            titleKey: "admin_panel_category_maps",
            expanded: _expandedCategories.contains(1),
            onHeaderTap: () => _toggleCategory(1),
            iconColor: iconColor,
            children: [
              _AdminMenuRow(
                icon: Icons.map_outlined,
                titleKey: "admin_panel_section_district_heatmap",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminDistrictHeatmapScreen(),
                    ),
                  );
                },
              ),
              _AdminMenuRow(
                icon: Icons.train,
                titleKey: "admin_panel_section_subway_heatmap",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminSubwayLineHeatmapScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AdminCategoryCard(
            headerIcon: Icons.insights_outlined,
            titleKey: "admin_panel_category_analytics",
            expanded: _expandedCategories.contains(2),
            onHeaderTap: () => _toggleCategory(2),
            iconColor: iconColor,
            children: [
              _AdminMenuRow(
                icon: Icons.subway,
                titleKey: "admin_panel_section_subway_map",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminSubwayMapScreen(),
                    ),
                  );
                },
              ),
              _AdminMenuRow(
                icon: Icons.analytics_outlined,
                titleKey: "admin_panel_section_search_analytics",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminSearchAnalyticsScreen(),
                    ),
                  );
                },
              ),
              _AdminMenuRow(
                icon: Icons.trending_up,
                titleKey: "admin_panel_section_listing_creation_analytics",
                iconColor: iconColor,
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
          const SizedBox(height: 12),
          _AdminCategoryCard(
            headerIcon: Icons.settings_outlined,
            titleKey: "admin_panel_category_settings",
            expanded: _expandedCategories.contains(3),
            onHeaderTap: () => _toggleCategory(3),
            iconColor: iconColor,
            children: [
              _AdminMenuRow(
                icon: Icons.import_export,
                titleKey: "admin_panel_section_telegram_sync",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminTelegramSyncScreen(),
                    ),
                  );
                },
              ),
              _AdminMenuRow(
                icon: Icons.insights_outlined,
                titleKey: "admin_panel_section_area_price_cache",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminAreaPriceCacheScreen(),
                    ),
                  );
                },
              ),
              _AdminMenuRow(
                icon: Icons.settings_outlined,
                titleKey: "admin_panel_section_content_moderation",
                iconColor: iconColor,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminContentModerationScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminCategoryCard extends StatelessWidget {
  const _AdminCategoryCard({
    required this.headerIcon,
    required this.titleKey,
    required this.expanded,
    required this.onHeaderTap,
    required this.iconColor,
    required this.children,
  });

  final IconData headerIcon;
  final String titleKey;
  final bool expanded;
  final VoidCallback onHeaderTap;
  final Color iconColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final dividerColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Icon(headerIcon, size: 24, color: onSurface),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      L10n.get(titleKey),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: onSurface,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(height: 1, thickness: 1, color: dividerColor),
                      for (var i = 0; i < children.length; i++) ...[
                        children[i],
                        if (i < children.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 52,
                            endIndent: 16,
                            color: dividerColor,
                          ),
                      ],
                    ],
                  )
                  : const SizedBox(width: double.infinity),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuRow extends StatelessWidget {
  const _AdminMenuRow({
    required this.icon,
    required this.titleKey,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String titleKey;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        HapticFeedbackUtils.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                L10n.get(titleKey),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
