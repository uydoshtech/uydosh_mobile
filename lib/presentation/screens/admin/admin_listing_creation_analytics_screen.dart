import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/listing_creation_analytics_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/period_picker.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

sealed class _MonthGroupedListItem {}

final class _MonthHeaderItem extends _MonthGroupedListItem {
  _MonthHeaderItem(this.label);
  final String label;
}

final class _DayIndexItem extends _MonthGroupedListItem {
  _DayIndexItem(this.index);
  final int index;
}

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
  final Map<String, bool> _expandedByDate = <String, bool>{};

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
      setStateIfMounted(() {
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setStateIfMounted(() {
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
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
                          "admin_listing_creation_analytics_by_month",
                          Icons.calendar_month,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: ThreeDSurfaceStyle.surfaceGradient(
          context,
          colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
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

  BoxDecoration _softTileDecoration(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      gradient: ThreeDSurfaceStyle.surfaceGradient(context, scheme.surface),
      borderRadius: BorderRadius.circular(14),
      boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
    );
  }

  Widget _countChip(BuildContext context, int count) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        "$count",
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
    );
  }

  String _monthLabel(DateTime date) {
    final monthKey = switch (date.month) {
      1 => "january",
      2 => "february",
      3 => "march",
      4 => "april",
      5 => "may",
      6 => "june",
      7 => "july",
      8 => "august",
      9 => "september",
      10 => "october",
      11 => "november",
      12 => "december",
      _ => "january",
    };
    return "${L10n.get(monthKey)} ${date.year}";
  }

  Widget _monthSeparator(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: ThreeDSurfaceStyle.surfaceGradient(
                context,
                scheme.surface,
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
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
    final scheme = Theme.of(context).colorScheme;
    final hasListingIds = item.listingIds.isNotEmpty;
    final isSingleListing = hasListingIds && item.listingIds.length == 1;
    final isMultiListing = hasListingIds && item.listingIds.length > 1;

    final leadingIcon = ThemeIcon(
      Icons.calendar_today,
      size: 20,
      color: scheme.onSurfaceVariant.withValues(alpha: 0.55 + intensity * 0.45),
    );

    if (isSingleListing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: _softTileDecoration(context),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: leadingIcon,
          title: Text(
            _formatDate(item.date),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _countChip(context, item.count),
              const SizedBox(width: 10),
              const ThemeIcon(Icons.chevron_right),
            ],
          ),
          onTap: () => _openListingDetail(item.listingIds.first),
        ),
      );
    }

    if (isMultiListing) {
      final expanded = _expandedByDate[item.date] ?? false;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: _softTileDecoration(context),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: PageStorageKey<String>("listing_creation_analytics_${item.date}"),
            initiallyExpanded: expanded,
            onExpansionChanged: (v) => setState(() => _expandedByDate[item.date] = v),
            tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
            leading: leadingIcon,
            title: Text(
              _formatDate(item.date),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _countChip(context, item.count),
                const SizedBox(width: 10),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  child: const ThemeIcon(Icons.expand_more),
                ),
              ],
            ),
            children: item.listingIds
                .map(
                  (id) => Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      title: Text(
                        "Listing #$id",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: const ThemeIcon(Icons.chevron_right),
                      onTap: () => _openListingDetail(id),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _softTileDecoration(context),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: leadingIcon,
        title: Text(
          _formatDate(item.date),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: _countChip(context, item.count),
      ),
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

    final listItems = <_MonthGroupedListItem>[];
    String? lastMonthKey;
    for (var i = 0; i < items.length; i++) {
      final d = items[i];
      DateTime? dt;
      try {
        dt = DateTime.parse(d.date);
      } catch (_) {
        dt = null;
      }
      final monthKey = dt != null ? "${dt.year}-${dt.month}" : null;
      if (dt != null && monthKey != null && monthKey != lastMonthKey) {
        listItems.add(_MonthHeaderItem(_monthLabel(dt)));
        lastMonthKey = monthKey;
      }
      listItems.add(_DayIndexItem(i));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final it = listItems[index];
          return switch (it) {
            _MonthHeaderItem(:final label) => _monthSeparator(context, label),
            _DayIndexItem(:final index) => _buildByDayItem(context, index, maxCount),
          };
        },
        childCount: listItems.length,
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
      title: L10n.get("admin_listing_creation_analytics_error"),
      message: _errorMessage,
      messageMaxLines: 3,
      messageOverflow: TextOverflow.ellipsis,
      padding: const EdgeInsets.all(24),
      spacingAfterTitle: 8,
      spacingBeforeButton: 20,
      retryButton: PrimaryButtonFactory.iconText(
        onPressed: () {
          HapticFeedbackUtils.impact();
          _loadAnalytics();
        },
        icon: Icons.refresh,
        text: L10n.get("admin_listing_creation_analytics_retry"),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
