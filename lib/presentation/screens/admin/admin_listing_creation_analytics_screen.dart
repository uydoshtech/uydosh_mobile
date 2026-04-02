import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/services/listing_creation_analytics_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/period_picker.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class AdminListingCreationAnalyticsScreen extends StatefulWidget {
  const AdminListingCreationAnalyticsScreen({super.key});

  @override
  State<AdminListingCreationAnalyticsScreen> createState() =>
      _AdminListingCreationAnalyticsScreenState();
}

class _AdminListingCreationAnalyticsScreenState
    extends State<AdminListingCreationAnalyticsScreen> {
  final IListingCreationAnalyticsService _analyticsService =
      getIt<IListingCreationAnalyticsService>();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  ListingCreationAnalyticsResponse? _analytics;
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
      final analytics =
          await _analyticsService.getListingCreationAnalytics(days: days);
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

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split("-");
      if (parts.length >= 3) {
        final year = parts[0];
        final month = parts[1];
        final day = parts[2];
        return "$day.$month.$year";
      }
    } catch (_) {}
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get("admin_listing_creation_analytics_title"),
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
              text: L10n.get("admin_listing_creation_analytics_loading"),
            );
          }
          return RefreshIndicator(
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
                          "admin_listing_creation_analytics_by_day",
                          Icons.calendar_view_day,
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
                    sliver: _buildByDaySliver(context),
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
      title: L10n.get("admin_listing_creation_analytics_time_range"),
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
            title: L10n.get("admin_listing_creation_analytics_total"),
            value: s.total.toString(),
            icon: Icons.home_work_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_listing_creation_analytics_today"),
            value: s.today.toString(),
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_listing_creation_analytics_week"),
            value: s.thisWeek.toString(),
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

  void _openListingDetail(int listingId) {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ListingDetailBloc(getIt<IListingService>()),
            ),
            BlocProvider(create: (_) => ListingDetailPageBloc()),
          ],
          child: ListingDetailScreen(listingId: listingId),
        ),
      ),
    );
  }

  Widget _buildByDayItem(BuildContext context, int index, int maxCount) {
    final item = _analytics!.byDay[index];
    final intensity =
        maxCount > 0 ? (item.count / maxCount).clamp(0.0, 1.0) : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasListingIds = item.listingIds.isNotEmpty;
    final isSingleListing = hasListingIds && item.listingIds.length == 1;
    final isMultiListing = hasListingIds && item.listingIds.length > 1;

    final leadingIcon = Icon(
      Icons.add_circle_outline,
      color: (isDark ? Colors.grey[500]! : Colors.grey[600]!)
          .withValues(alpha: 0.5 + intensity * 0.5),
    );
    final trailing = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "${item.count}",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );

    if (isSingleListing) {
      return ListTile(
        leading: leadingIcon,
        title: Text(
          _formatDate(item.date),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: trailing,
        onTap: () => _openListingDetail(item.listingIds.first),
      );
    }

    if (isMultiListing) {
      return ExpansionTile(
        leading: leadingIcon,
        title: Text(
          _formatDate(item.date),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: trailing,
        children: item.listingIds
            .map(
              (id) => ListTile(
                leading: const SizedBox(width: 24),
                title: Text("Listing #$id"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openListingDetail(id),
              ),
            )
            .toList(),
      );
    }

    return ListTile(
      leading: leadingIcon,
      title: Text(
        _formatDate(item.date),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
    );
  }

  Widget _buildByDaySliver(BuildContext context) {
    final items = _analytics!.byDay;
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptySection(
          context,
          L10n.get("admin_listing_creation_analytics_no_data"),
        ),
      );
    }
    final maxCount =
        items.map((d) => d.count).reduce((a, b) => a > b ? a : b);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index.isOdd) return const Divider(height: 1);
          return _buildByDayItem(context, index ~/ 2, maxCount);
        },
        childCount: items.length * 2 - 1,
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
              L10n.get("admin_listing_creation_analytics_error"),
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
                L10n.get("admin_listing_creation_analytics_retry"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
