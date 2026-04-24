import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/services/search_analytics_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/period_picker.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class AdminSearchAnalyticsScreen extends StatefulWidget {
  const AdminSearchAnalyticsScreen({super.key});

  @override
  State<AdminSearchAnalyticsScreen> createState() =>
      _AdminSearchAnalyticsScreenState();
}

class _AdminSearchAnalyticsScreenState extends State<AdminSearchAnalyticsScreen> {
  final ISearchAnalyticsService _analyticsService = getIt<ISearchAnalyticsService>();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  SearchAnalyticsResponse? _analytics;
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final days = _selectedDays > 0 ? _selectedDays : null;
      final analytics = await _analyticsService.getSearchAnalytics(days: days);
      if (!mounted) return;
      setState(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getStationName(int stationId) {
    final station = MetroCache.getStationById(stationId);
    if (station == null) return "#$stationId";
    final lang = LanguageState().currentLanguage;
    return switch (lang) {
      "ru" => station.nameRu ?? station.nameEn ?? station.nameUz ?? "#$stationId",
      "uz" => station.nameUz ?? station.nameEn ?? station.nameRu ?? "#$stationId",
      _ => station.nameEn ?? station.nameRu ?? station.nameUz ?? "#$stationId",
    };
  }

  String _getLocationName(int locationId) {
    return LocationCache.getLocationShortName(
      locationId,
      LanguageState().currentLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_search_analytics_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, child) {
          if (_hasError) {
            return _buildErrorState(context);
          }
          if (_isLoading && _analytics == null) {
            return CenteredHouseLoadingIndicator(
              text: L10n.get("admin_search_analytics_loading"),
            );
          }
          return UydoshRefreshIndicator(
            onRefresh: _loadAnalytics,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildTimeRangeSelector(context),
                      const SizedBox(height: 20),
                      if (_analytics != null) ...[
                        _buildSummaryCards(context),
                        const SizedBox(height: 24),
                        _buildSectionTitle(
                          context,
                          "admin_search_analytics_top_lines",
                          Icons.subway,
                        ),
                        const SizedBox(height: 12),
                      ] else
                        const SizedBox.shrink(),
                    ]),
                  ),
                ),
                if (_analytics != null) ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: _buildLinesSliver(context),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        _buildSectionTitle(
                          context,
                          "admin_search_analytics_top_stations",
                          Icons.train,
                        ),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: _buildStationsSliver(context),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 24),
                        _buildSectionTitle(
                          context,
                          "admin_search_analytics_top_districts",
                          Icons.location_city,
                        ),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: _buildLocationsSliver(context),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 32),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return PeriodPicker(
      title: L10n.get("admin_search_analytics_time_range"),
      selectedDays: _selectedDays,
      onChanged: (days) {
        setState(() {
          _selectedDays = days;
          _loadAnalytics();
        });
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final s = _analytics!.summary;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_search_analytics_total"),
            value: s.totalSearches.toString(),
            icon: Icons.search,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_search_analytics_today"),
            value: s.searchesToday.toString(),
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_search_analytics_week"),
            value: s.searchesThisWeek.toString(),
            icon: Icons.date_range,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = _tileBaseColor(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
        borderRadius: BorderRadius.circular(14),
        boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.22 : 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ThemeIcon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String titleKey,
    IconData icon,
  ) {
    return Row(
      children: [
        ThemeIcon(icon, size: 22, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(width: 8),
        Text(
          L10n.get(titleKey),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Color _tileBaseColor(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    // Slight blue tint so surfaces feel “on brand” without fighting elevation.
    return Color.lerp(
      scheme.surface,
      scheme.primary,
      isDark ? 0.10 : 0.06,
    )!;
  }

  BoxDecoration _softTileDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final base = _tileBaseColor(context);
    return BoxDecoration(
      gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
      borderRadius: BorderRadius.circular(14),
      boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
      border: Border.all(
        color: scheme.outlineVariant.withValues(alpha: isDark ? 0.20 : 0.26),
      ),
    );
  }

  Widget _countChip(BuildContext context, int count) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (isDark ? scheme.surfaceContainerHighest : scheme.surfaceContainerHigh)
            .withValues(alpha: isDark ? 0.32 : 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: isDark ? 0.20 : 0.22),
        ),
      ),
      child: Text(
        "$count",
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildStationTile(BuildContext context, int index) {
    final item = _analytics!.topStations[index];
    final station = MetroCache.getStationById(item.stationId);
    final lineId = station?.line ?? 1;
    final barColor = AppColors.getMetroLineColor(lineId);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _softTileDecoration(context),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 6,
          height: 36,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        title: Text(
          _getStationName(item.stationId),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: _countChip(context, item.count),
      ),
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    int index,
    int maxCount,
  ) {
    final item = _analytics!.topLocations[index];
    final intensity = maxCount > 0
        ? (item.count / maxCount).clamp(0.0, 1.0)
        : 0.0;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _softTileDecoration(context),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: ThemeIcon(
          Icons.location_on,
          color: scheme.onSurfaceVariant.withValues(
            alpha: 0.55 + intensity * 0.45,
          ),
        ),
        title: Text(
          _getLocationName(item.locationId),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: _countChip(context, item.count),
      ),
    );
  }

  Widget _buildLinesSliver(BuildContext context) {
    final lines = [..._analytics!.topLines]
      ..sort((a, b) => b.count.compareTo(a.count));
    if (lines.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptySection(
          context,
          L10n.get("admin_search_analytics_no_lines"),
        ),
      );
    }
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        // Keep tiles compact (less vertical “blockiness”).
        mainAxisExtent: 92,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = lines[index];
          final scheme = Theme.of(context).colorScheme;
          return Container(
            decoration: _softTileDecoration(context),
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ThemeIcon(
                      Icons.train,
                      color: AppColors.getMetroLineColor(item.lineId),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        MetroCache.getLineName(
                          item.lineId,
                          LanguageState().currentLanguage,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.count}",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  L10n.get("admin_search_analytics_searches"),
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
        childCount: lines.length,
      ),
    );
  }

  Widget _buildStationsSliver(BuildContext context) {
    final stations = _analytics!.topStations;
    if (stations.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptySection(
          context,
          L10n.get("admin_search_analytics_no_stations"),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildStationTile(context, index),
        childCount: stations.length,
      ),
    );
  }

  Widget _buildLocationsSliver(BuildContext context) {
    final locations = _analytics!.topLocations;
    if (locations.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptySection(
          context,
          L10n.get("admin_search_analytics_no_districts"),
        ),
      );
    }
    final maxCount =
        locations.map((l) => l.count).reduce((a, b) => a > b ? a : b);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildLocationTile(context, index, maxCount),
        childCount: locations.length,
      ),
    );
  }

  Widget _buildEmptySection(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_search_analytics_error"),
      message: _errorMessage,
      messageMaxLines: 3,
      messageOverflow: TextOverflow.ellipsis,
      padding: const EdgeInsets.all(24),
      spacingAfterTitle: 8,
      spacingBeforeButton: 20,
      retryButton: ElevatedButton.icon(
        onPressed: () {
          HapticFeedbackUtils.impact();
          _loadAnalytics();
        },
        icon: const ThemeIcon(Icons.refresh),
        label: Text(L10n.get("admin_search_analytics_retry")),
      ),
    );
  }
}
