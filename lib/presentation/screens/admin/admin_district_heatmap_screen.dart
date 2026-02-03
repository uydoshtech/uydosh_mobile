import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/models/location.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class AdminDistrictHeatmapScreen extends StatefulWidget {
  const AdminDistrictHeatmapScreen({super.key});

  @override
  State<AdminDistrictHeatmapScreen> createState() =>
      _AdminDistrictHeatmapScreenState();
}

class _AdminDistrictHeatmapScreenState
    extends State<AdminDistrictHeatmapScreen> {
  static const int _perDistrictLimit = 1000;

  final List<Location> _locations = LocationCache.getAllLocations();
  final Map<int, int> _districtCounts = {};

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait(
        _locations.map((location) async {
          try {
            final listings =
                await getIt<IListingService>().getListingsByLocation(
                  location.id,
                  page: 1,
                  limit: _perDistrictLimit,
                );
            return MapEntry(location.id, listings.length);
          } catch (_) {
            return MapEntry(location.id, -1);
          }
        }),
      );

      if (!mounted) return;
      setState(() {
        _districtCounts
          ..clear()
          ..addEntries(results);
        _hasError = _districtCounts.values
            .where((count) => count >= 0)
            .isEmpty;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _maxCount {
    final values = _districtCounts.values.where((count) => count >= 0);
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  int get _totalCount {
    return _districtCounts.values
        .where((count) => count >= 0)
        .fold(0, (sum, count) => sum + count);
  }

  List<Location> _getSortedLocations() {
    final language = LanguageState().currentLanguage;
    final sorted = [..._locations];
    sorted.sort((a, b) {
      final aCount = _districtCounts[a.id] ?? -2;
      final bCount = _districtCounts[b.id] ?? -2;
      if (aCount != bCount) {
        return bCount.compareTo(aCount);
      }
      final aName = LocationCache.getLocationShortName(a.id, language);
      final bName = LocationCache.getLocationShortName(b.id, language);
      return aName.compareTo(bName);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(
            context,
            "admin_district_heatmap_title",
          ),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, child) {
          if (_isLoading) {
            return CenteredHouseLoadingIndicator(
              text: LanguageAwareStringHelper.getCurrent(
                context,
                "admin_district_heatmap_loading",
              ),
            );
          }
          if (_hasError) {
            return _buildErrorState(context);
          }
          if (_locations.isEmpty) {
            return _buildEmptyState(context);
          }
          final sortedLocations = _getSortedLocations();
          return RefreshIndicator(
            onRefresh: _loadCounts,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "admin_district_heatmap_description",
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(context),
                const SizedBox(height: 16),
                _buildLegend(context),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedLocations.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final location = sortedLocations[index];
                    final count = _districtCounts[location.id];
                    return _buildDistrictTile(context, location, count);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    final summaryTextStyle = TextStyle(
      fontSize: 12,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            title: LanguageAwareStringHelper.getCurrent(
              context,
              "admin_district_heatmap_total",
            ),
            value: _totalCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: LanguageAwareStringHelper.getCurrent(
              context,
              "admin_district_heatmap_max",
            ),
            value: _maxCount.toString(),
            valueStyle: summaryTextStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style:
                valueStyle ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surfaceVariant;
    final high = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageAwareStringHelper.getCurrent(
            context,
            "admin_district_heatmap_count_label",
          ),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 10,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              colors: [surface, high],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "0",
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              _maxCount.toString(),
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistrictTile(
    BuildContext context,
    Location location,
    int? count,
  ) {
    final language = LanguageState().currentLanguage;
    final title = LocationCache.getLocationShortName(location.id, language);
    final resolvedCount = count;
    final backgroundColor = _resolveTileColor(
      context,
      location.id,
      resolvedCount,
    );
    final textColor = _resolveTextColor(context, backgroundColor);
    final valueText =
        resolvedCount == null
            ? LanguageAwareStringHelper.getCurrent(
              context,
              "admin_users_listings_count_loading",
            )
            : resolvedCount >= 0
            ? resolvedCount.toString()
            : LanguageAwareStringHelper.getCurrent(
              context,
              "admin_district_heatmap_unavailable",
            );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDistrictListings(context, location.id),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                LanguageAwareStringHelper.getCurrent(
                  context,
                  "admin_district_heatmap_count_label",
                ),
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDistrictListings(BuildContext context, int locationId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (context) => ListingsBloc(getIt<IListingService>()),
              child: HomeScreen(locationId: locationId, isSearchMode: true),
            ),
      ),
    );
  }

  Color _resolveTileColor(BuildContext context, int locationId, int? count) {
    final baseColor = _getDistrictBaseColor(locationId);
    const minAlpha = 0.35;
    if (count == null) {
      return baseColor.withValues(alpha: minAlpha);
    }
    if (count < 0) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    final max = _maxCount;
    if (max <= 0) {
      return baseColor.withValues(alpha: minAlpha);
    }
    final t = (count / max).clamp(minAlpha, 1.0);
    return Color.lerp(
          baseColor.withValues(alpha: minAlpha),
          baseColor,
          t,
        ) ??
        baseColor;
  }

  Color _getDistrictBaseColor(int locationId) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[locationId % colors.length];
  }

  Color _resolveTextColor(BuildContext context, Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    if (luminance > 0.55) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return Theme.of(context).colorScheme.onPrimary;
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
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
              "admin_district_heatmap_error",
            ),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCounts,
            child: Text(
              LanguageAwareStringHelper.getCurrent(
                context,
                "admin_district_heatmap_retry",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        LanguageAwareStringHelper.getCurrent(
          context,
          "admin_district_heatmap_no_data",
        ),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
