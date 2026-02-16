import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class ListingViewsStatsScreen extends StatefulWidget {
  const ListingViewsStatsScreen({
    required this.listingId, super.key,
  });

  final int listingId;

  @override
  State<ListingViewsStatsScreen> createState() => _ListingViewsStatsScreenState();
}

class _ListingViewsStatsScreenState extends State<ListingViewsStatsScreen> {
  List<Map<String, dynamic>> _stats = [];
  bool _isLoading = true;
  String? _error;

  Color _getTextColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight;
      default:
        return Colors.black;
    }
  }

  Color _getSecondaryTextColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight70;
      default:
        return Colors.grey[600]!;
    }
  }

  Color _getIconColor() {
    final currentTheme = ThemeState().currentTheme;
    switch (currentTheme) {
      case AppTheme.blueTheme:
        return AppColors.textLight;
      default:
        return Colors.black;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final stats = await getIt<IListingService>().getListingViewStatsByDay(
        widget.listingId,
        daysBack: 30,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(
            context,
            "listing_views_stats_title",
          ),
          style: TextStyle(color: _getTextColor()),
        ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: _getIconColor()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, _) {
          if (_isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: _getIconColor()),
                  const SizedBox(height: 16),
                  Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "loading_listing_details",
                    ),
                    style: TextStyle(color: _getSecondaryTextColor()),
                  ),
                ],
              ),
            );
          }

          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 48,
                      color: _getSecondaryTextColor(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      LanguageAwareStringHelper.getCurrent(
                        context,
                        "error_loading_view_stats",
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _getTextColor()),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _loadStats,
                      child: Text(
                        LanguageAwareStringHelper.getCurrent(
                          context,
                          "retry",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_stats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.eye,
                    size: 64,
                    color: _getSecondaryTextColor(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "listing_views_stats_empty",
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _getSecondaryTextColor(),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            itemCount: _stats.length,
            itemBuilder: (context, index) {
              final item = _stats[index];
              final dateStr = item["date"] as String? ?? "";
              final count = (item["count"] is num)
                  ? (item["count"] as num).toInt()
                  : 0;

              DateTime? date;
              try {
                date = DateTime.parse(dateStr);
              } catch (_) {}

              final dateDisplay = date != null
                  ? AppDateUtils.formatDateWithMonthDay(context, date)
                  : dateStr;

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    CupertinoIcons.eye,
                    color: _getIconColor(),
                    size: 24,
                  ),
                  title: Text(
                    dateDisplay,
                    style: TextStyle(
                      color: _getTextColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "listing_views_by_others",
                    ).replaceAll("{count}", count.toString()),
                    style: TextStyle(
                      color: _getSecondaryTextColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
