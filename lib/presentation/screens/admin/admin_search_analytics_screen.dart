import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/search_analytics_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/period_picker.dart";
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(
            context,
            "admin_search_analytics_title",
          ),
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
              text: LanguageAwareStringHelper.getCurrent(
                context,
                "admin_search_analytics_loading",
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _loadAnalytics,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
                  _buildLinesList(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    context,
                    "admin_search_analytics_top_stations",
                    Icons.train,
                  ),
                  const SizedBox(height: 12),
                  _buildStationsList(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(
                    context,
                    "admin_search_analytics_top_districts",
                    Icons.location_city,
                  ),
                  const SizedBox(height: 12),
                  _buildLocationsList(context),
                  const SizedBox(height: 32),
                ] else
                  const SizedBox.shrink(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeRangeSelector(BuildContext context) {
    return PeriodPicker(
      title: LanguageAwareStringHelper.getCurrent(
        context,
        "admin_search_analytics_time_range",
      ),
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
            title: LanguageAwareStringHelper.getCurrent(
              context,
              "admin_search_analytics_total",
            ),
            value: s.totalSearches.toString(),
            icon: Icons.search,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: LanguageAwareStringHelper.getCurrent(
              context,
              "admin_search_analytics_today",
            ),
            value: s.searchesToday.toString(),
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: LanguageAwareStringHelper.getCurrent(
              context,
              "admin_search_analytics_week",
            ),
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
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
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(width: 8),
        Text(
          LanguageAwareStringHelper.getCurrent(context, titleKey),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStationsList(BuildContext context) {
    final stations = _analytics!.topStations;
    if (stations.isEmpty) {
      return _buildEmptySection(
        context,
        LanguageAwareStringHelper.getCurrent(
          context,
          "admin_search_analytics_no_stations",
        ),
      );
    }
    final maxCount = stations.map((s) => s.count).reduce((a, b) => a > b ? a : b);
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stations.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = stations[index];
          final station = MetroCache.getStationById(item.stationId);
          final lineId = station?.line ?? 1;
          final barColor = AppColors.getMetroLineColor(lineId);
          return ListTile(
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${item.count}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationsList(BuildContext context) {
    final locations = _analytics!.topLocations;
    if (locations.isEmpty) {
      return _buildEmptySection(
        context,
        LanguageAwareStringHelper.getCurrent(
          context,
          "admin_search_analytics_no_districts",
        ),
      );
    }
    final maxCount = locations.map((l) => l.count).reduce((a, b) => a > b ? a : b);
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: locations.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = locations[index];
          final intensity = maxCount > 0 ? (item.count / maxCount).clamp(0.0, 1.0) : 0.0;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return ListTile(
            leading: Icon(
              Icons.location_on,
              color: (isDark ? Colors.grey[500]! : Colors.grey[600]!).withValues(
                alpha: 0.5 + intensity * 0.5,
              ),
            ),
            title: Text(
              _getLocationName(item.locationId),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${item.count}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLinesList(BuildContext context) {
    final lines = [..._analytics!.topLines]..sort((a, b) => b.count.compareTo(a.count));
    if (lines.isEmpty) {
      return _buildEmptySection(
        context,
        LanguageAwareStringHelper.getCurrent(
          context,
          "admin_search_analytics_no_lines",
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.4,
      ),
      itemCount: lines.length,
        itemBuilder: (context, index) {
        final item = lines[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Card(
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.train,
                      color: AppColors.getMetroLineColor(item.lineId),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        MetroCache.getLineName(
                          item.lineId,
                          LanguageState().currentLanguage,
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${item.count}",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "admin_search_analytics_searches",
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              LanguageAwareStringHelper.getCurrent(
                context,
                "admin_search_analytics_error",
              ),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadAnalytics,
              icon: const Icon(Icons.refresh),
              label: Text(
                LanguageAwareStringHelper.getCurrent(
                  context,
                  "admin_search_analytics_retry",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
