import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/pending_listing_moderation_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/moderation_staff_utils.dart";
import "package:uy_dosh/presentation/screens/admin/admin_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_content_moderation_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_district_heatmap_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listing_creation_analytics_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_gig_moderation_queue_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listing_moderation_queue_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listings_with_complaints_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_search_analytics_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_subway_line_heatmap_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_support_chat_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_telegram_listing_groups_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_telegram_sync_screen.dart";
import "package:uy_dosh/presentation/screens/admin/admin_users_screen.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

const _kAdminCategoryExpandDuration = Duration(milliseconds: 200);

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  /// Cached so expanding/collapsing does not restart [FutureBuilder] with a new
  /// future on every [setState] (which briefly showed the loading scaffold).
  late final Future<String?> _userRoleFuture = SessionManager.getUserRole();

  /// Expanded category indices (0–3: management, maps, analytics, settings).
  final Set<int> _expandedCategories = {0};

  final ScrollController _scrollController = ScrollController();
  Timer? _scrollToEndTimer;

  @override
  void initState() {
    super.initState();
    unawaited(PendingListingModerationState().refresh());
  }

  @override
  void dispose() {
    _scrollToEndTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openListingModerationQueue() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AdminListingModerationQueueScreen(),
      ),
    );
    if (!mounted) return;
    unawaited(PendingListingModerationState().refresh());
  }

  void _toggleCategory(int index, {required bool isLastBlock}) {
    HapticFeedbackUtils.selectionClick();
    final wasExpanded = _expandedCategories.contains(index);
    setState(() {
      if (wasExpanded) {
        _expandedCategories.remove(index);
      } else {
        _expandedCategories.add(index);
      }
    });

    if (isLastBlock && !wasExpanded) {
      _scrollToEndAfterExpand();
    }
  }

  void _scrollToEndAfterExpand() {
    _scrollToEndTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollToEndTimer = Timer(_kAdminCategoryExpandDuration, () {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    final appBar = UydoshAppBar(
      leading: ThreeDAppBarIconButton.backLeading(context),
      title: Text(
        L10n.get("admin_panel_title"),
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );

    return FutureBuilder<String?>(
      future: _userRoleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: appBar,
            body: const Center(child: HouseLoadingIndicator()),
          );
        }
        final role = snapshot.data;
        if (!ModerationStaffUtils.isModerationStaff(role)) {
          return Scaffold(
            appBar: appBar,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  L10n.get("error_access_denied"),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        final isAdmin = role == "admin";

        return Scaffold(
          appBar: appBar,
          body: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20.0),
            children: [
              _AdminCategoryCard(
                variant: _AdminCategoryHeaderVariant.moderation,
                headerIcon: Icons.manage_accounts,
                titleKey: "admin_panel_category_management",
                expanded: _expandedCategories.contains(0),
                onHeaderTap: () => _toggleCategory(0, isLastBlock: !isAdmin),
                children: [
                  if (isAdmin) ...[
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
                            builder: (context) =>
                                const AdminSupportChatScreen(),
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
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      PendingListingModerationState(),
                      ThemeState(),
                    ]),
                    builder: (context, _) {
                      final pendingState = PendingListingModerationState();
                      return _AdminMenuRow(
                        icon: Icons.verified_outlined,
                        titleKey: "admin_panel_section_listing_moderation",
                        iconColor: iconColor,
                        showNotificationDot: pendingState.hasPendingListings,
                        notificationDotTrigger: pendingState.dotTrigger,
                        onTap: _openListingModerationQueue,
                      );
                    },
                  ),
                  if (AppConfig.servicesFeatureEnabled)
                    _AdminMenuRow(
                      icon: Icons.work_outline,
                      titleKey: "admin_panel_section_gig_moderation",
                      iconColor: iconColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminGigModerationQueueScreen(),
                          ),
                        );
                      },
                    ),
                ],
              ),
              if (isAdmin) ...[
                const SizedBox(height: 12),
                _AdminCategoryCard(
                  variant: _AdminCategoryHeaderVariant.maps,
                  headerIcon: Icons.map_outlined,
                  titleKey: "admin_panel_category_maps",
                  expanded: _expandedCategories.contains(1),
                  onHeaderTap: () => _toggleCategory(1, isLastBlock: false),
                  children: [
                    _AdminMenuRow(
                      icon: Icons.map_outlined,
                      titleKey: "admin_panel_section_district_heatmap",
                      iconColor: iconColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminDistrictHeatmapScreen(),
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
                            builder: (context) =>
                                const AdminSubwayLineHeatmapScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _AdminCategoryCard(
                  variant: _AdminCategoryHeaderVariant.analytics,
                  headerIcon: Icons.insights_outlined,
                  titleKey: "admin_panel_category_analytics",
                  expanded: _expandedCategories.contains(2),
                  onHeaderTap: () => _toggleCategory(2, isLastBlock: false),
                  children: [
                    _AdminMenuRow(
                      icon: Icons.analytics_outlined,
                      titleKey: "admin_panel_section_search_analytics",
                      iconColor: iconColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminSearchAnalyticsScreen(),
                          ),
                        );
                      },
                    ),
                    _AdminMenuRow(
                      icon: Icons.trending_up,
                      titleKey:
                          "admin_panel_section_listing_creation_analytics",
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
                  variant: _AdminCategoryHeaderVariant.settings,
                  headerIcon: Icons.settings_outlined,
                  titleKey: "admin_panel_category_settings",
                  expanded: _expandedCategories.contains(3),
                  onHeaderTap: () => _toggleCategory(3, isLastBlock: true),
                  children: [
                    _AdminMenuRow(
                      icon: Icons.import_export,
                      titleKey: "admin_panel_section_telegram_sync",
                      iconColor: iconColor,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminTelegramSyncScreen(),
                          ),
                        );
                        if (!mounted) return;
                        unawaited(PendingListingModerationState().refresh());
                      },
                    ),
                    _AdminMenuRow(
                      icon: Icons.groups_outlined,
                      titleKey: "admin_panel_section_telegram_listing_groups",
                      iconColor: iconColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminTelegramListingGroupsScreen(),
                          ),
                        );
                      },
                    ),
                    _AdminMenuRow(
                      icon: Icons.tune_outlined,
                      titleKey: "admin_panel_section_content_moderation",
                      iconColor: iconColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const AdminContentModerationScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

enum _AdminCategoryHeaderVariant {
  moderation,
  maps,
  analytics,
  settings;

  Color accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (this) {
      case _AdminCategoryHeaderVariant.moderation:
        return isDark ? const Color(0xFF82B1FF) : const Color(0xFF1565C0);
      case _AdminCategoryHeaderVariant.maps:
        return isDark ? const Color(0xFF69F0AE) : const Color(0xFF00897B);
      case _AdminCategoryHeaderVariant.analytics:
        return isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100);
      case _AdminCategoryHeaderVariant.settings:
        return isDark ? const Color(0xFFCE93D8) : const Color(0xFF6A1B9A);
    }
  }
}

class _AdminCategoryCard extends StatelessWidget {
  const _AdminCategoryCard({
    required this.variant,
    required this.headerIcon,
    required this.titleKey,
    required this.expanded,
    required this.onHeaderTap,
    required this.children,
  });

  static const BorderRadius _tileBorderRadius = BorderRadius.all(
    Radius.circular(16),
  );

  final _AdminCategoryHeaderVariant variant;
  final IconData headerIcon;
  final String titleKey;
  final bool expanded;
  final VoidCallback onHeaderTap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final accent = variant.accent(context);
    final dividerColor =
        theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
    final baseSurface = theme.colorScheme.surface;
    final headerSplashRadius = expanded
        ? const BorderRadius.vertical(top: Radius.circular(16))
        : _tileBorderRadius;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _tileBorderRadius,
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseSurface),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Material(
        color: Colors.transparent,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: _tileBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: onHeaderTap,
              borderRadius: headerSplashRadius,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      accent.withValues(alpha: expanded ? 0.14 : 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.45),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.lerp(accent, Colors.white, 0.18)!,
                              accent,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          color: accent.withValues(alpha: 0.22),
                          border: Border.all(
                            color: accent.withValues(alpha: 0.42),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: ThemeIcon(
                            headerIcon,
                            size: 22,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          L10n.get(titleKey),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.25,
                            color: onSurface,
                            height: 1.2,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: _kAdminCategoryExpandDuration,
                        child: ThemeIcon(
                          Icons.keyboard_arrow_down,
                          color: accent.withValues(alpha: 0.9),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: _kAdminCategoryExpandDuration,
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
    this.showNotificationDot = false,
    this.notificationDotTrigger = 0,
  });

  final IconData icon;
  final String titleKey;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showNotificationDot;
  final int notificationDotTrigger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadColor = ThemeState().unreadIndicatorColor;
    final dotBorderColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface
        : Colors.white;

    return InkWell(
      onTap: () {
        HapticFeedbackUtils.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ThemeIcon(icon, size: 24, color: iconColor),
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
            if (showNotificationDot) ...[
              PulseThenBlinkDotWidget(
                trigger: notificationDotTrigger,
                color: unreadColor,
                size: 20,
                blinkDuration: const Duration(milliseconds: 750),
                borderColor: dotBorderColor,
                borderWidth: 1.5,
              ),
              const SizedBox(width: 8),
            ],
            ThemeIcon(
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
