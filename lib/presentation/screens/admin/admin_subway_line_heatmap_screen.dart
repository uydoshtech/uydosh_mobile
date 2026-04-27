import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/search_filters_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listings_bloc.dart";
import "package:uy_dosh/presentation/screens/home/home_screen.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/listing_type_picker.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class AdminSubwayLineHeatmapScreen extends StatefulWidget {
  const AdminSubwayLineHeatmapScreen({super.key});

  @override
  State<AdminSubwayLineHeatmapScreen> createState() =>
      _AdminSubwayLineHeatmapScreenState();
}

class _AdminSubwayLineHeatmapScreenState
    extends State<AdminSubwayLineHeatmapScreen> {
  static const int _perLineLimit = 1000;

  final List<int> _lines = MetroCache.getAvailableLines();
  final Map<int, int> _lineCounts = {};
  final SearchFiltersState _searchFiltersState = SearchFiltersState();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    await _searchFiltersState.initialize();
    if (!mounted) return;
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
      final listingTypeId = _searchFiltersState.selectedListingTypeId;
      final gender = _searchFiltersState.selectedGender;
      final minPrice = _searchFiltersState.minPrice;
      final maxPrice = _searchFiltersState.maxPrice;
      final privateRoom = _searchFiltersState.privateRoom;
      final withPhoto = _searchFiltersState.withPhoto;
      final listingTypeIdParam = listingTypeId > 0 ? listingTypeId : null;
      final genderParam = gender > 0 ? gender : null;

      final results = await Future.wait(
        _lines.map((lineId) async {
          try {
            final response = await getIt<IListingService>().searchListings(
              subwayLineId: lineId,
              page: 1,
              limit: _perLineLimit,
              listingTypeId: listingTypeIdParam,
              gender: genderParam,
              minPrice: minPrice,
              maxPrice: maxPrice,
              privateRoom: privateRoom,
              withPhoto: withPhoto,
            );
            return MapEntry(lineId, response.data.length);
          } catch (_) {
            return MapEntry(lineId, -1);
          }
        }),
      );

      setStateIfMounted(() {
        _lineCounts
          ..clear()
          ..addEntries(results);
        _hasError = _lineCounts.values.where((count) => count >= 0).isEmpty;
      });
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setStateIfMounted(() {
        _isLoading = false;
      });
    }
  }

  int get _maxCount {
    final values = _lineCounts.values.where((count) => count >= 0);
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  int get _totalCount {
    return _lineCounts.values
        .where((count) => count >= 0)
        .fold(0, (sum, count) => sum + count);
  }

  List<int> _getSortedLines() {
    final language = LanguageState().currentLanguage;
    final sorted = [..._lines];
    sorted.sort((a, b) {
      final aCount = _lineCounts[a] ?? -2;
      final bCount = _lineCounts[b] ?? -2;
      if (aCount != bCount) {
        return bCount.compareTo(aCount);
      }
      final aName = MetroCache.getLineName(a, language);
      final bName = MetroCache.getLineName(b, language);
      return aName.compareTo(bName);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_subway_heatmap_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, child) {
          if (_hasError) {
            return _buildErrorState(context);
          }
          if (_lines.isEmpty) {
            return _buildEmptyState(context);
          }
          final sortedLines = _getSortedLines();
          return UydoshRefreshIndicator(
            onRefresh: _loadCounts,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        children: [
                          Expanded(
                            child: ListingTypePicker(
                              selectedListingTypeId:
                                  _searchFiltersState.selectedListingTypeId,
                              onListingTypeChanged: (listingTypeId) {
                                _searchFiltersState.setListingTypeId(
                                  listingTypeId,
                                );
                                setState(() {});
                                _loadCounts();
                              },
                              useThemeColors: true,
                              showArrows: false,
                              includeUnselected: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GenderPicker(
                              selectedGender:
                                  _searchFiltersState.selectedGender,
                              onGenderChanged: (gender) {
                                _searchFiltersState.setGender(gender);
                                setState(() {});
                                _loadCounts();
                              },
                              useThemeColors: true,
                              showArrows: false,
                              includeUnselected: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: CenteredHouseLoadingIndicator(
                            text: L10n.get("admin_subway_heatmap_loading"),
                          ),
                        )
                      else ...[
                        _buildSummaryRow(context),
                        const SizedBox(height: 16),
                      ],
                    ]),
                  ),
                ),
                if (!_isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: 128,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final lineId = sortedLines[index];
                          final count = _lineCounts[lineId];
                          return _buildLineTile(context, lineId, count);
                        },
                        childCount: sortedLines.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
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
            title: L10n.get("admin_subway_heatmap_total"),
            value: _totalCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_subway_heatmap_max"),
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

  Widget _buildLineTile(BuildContext context, int lineId, int? count) {
    final language = LanguageState().currentLanguage;
    final title = MetroCache.getLineName(lineId, language);
    final resolvedCount = count;
    final backgroundColor = _resolveTileColor(context, lineId, resolvedCount);
    final lineColor = _getThemeAwareMetroLineColor(lineId);
    final textColor = _resolveTextColor(context, backgroundColor);
    final valueText =
        resolvedCount == null
            ? L10n.get("admin_users_listings_count_loading")
            : resolvedCount >= 0
            ? resolvedCount.toString()
            : L10n.get("admin_subway_heatmap_unavailable");

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openLineListings(context, lineId),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              // Neumorphic "pressed" look on blue background:
              // darker shadow bottom-right + lighter highlight top-left.
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(8, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(-8, -8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ThemeIcon(
                    Icons.train,
                    size: 20,
                    color: lineColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                L10n.get("admin_subway_heatmap_count_label"),
                style: TextStyle(
                  fontSize: 10,
                  color: textColor.withValues(alpha: 0.8),
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

  void _openLineListings(BuildContext context, int lineId) {
    final listingTypeId = _searchFiltersState.selectedListingTypeId;
    final gender = _searchFiltersState.selectedGender;
    final listingTypeIdParam = listingTypeId > 0 ? listingTypeId : null;
    final genderParam = gender > 0 ? gender : null;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (context) => ListingsBloc(getIt<IListingService>()),
              child: HomeScreen(
                subwayLineId: lineId,
                listingTypeId: listingTypeIdParam,
                gender: genderParam,
                isSearchMode: true,
                useExplicitFiltersOnly: true,
              ),
            ),
      ),
    );
  }

  Color _resolveTileColor(BuildContext context, int lineId, int? count) {
    if (count == null) {
      return _resolveTileBaseColor(context);
    }
    if (count < 0) {
      // Keep errors readable but still within the same "card" system.
      return Color.lerp(
            _resolveTileBaseColor(context),
            Theme.of(context).colorScheme.errorContainer,
            0.35,
          ) ??
          Theme.of(context).colorScheme.errorContainer;
    }
    final max = _maxCount;
    if (max <= 0) {
      return _resolveTileBaseColor(context);
    }
    final t = (count / max).clamp(0.0, 1.0);
    final lineColor = _getThemeAwareMetroLineColor(lineId);

    // Light-blue neumorphic base + subtle line tint (so it's still a heatmap).
    final base = _resolveTileBaseColor(context);
    final tinted = Color.lerp(base, lineColor, (t * 0.45).clamp(0.0, 0.45));
    return tinted ?? base;
  }

  Color _resolveTileBaseColor(BuildContext context) {
    // Neumorphic cards should be slightly lighter than the app background.
    // Use a stable light-blue derived from the blue theme palette; for light theme
    // fall back to a very light neutral blue.
    final theme = ThemeState().currentTheme;
    if (theme == AppTheme.lightTheme) {
      return const Color(0xFFEAF2FF);
    }
    return BlueThemeColors.primaryLight.withValues(alpha: 0.28);
  }

  Color _getThemeAwareMetroLineColor(int lineId) {
    final theme = ThemeState().currentTheme;
    if (theme == AppTheme.lightTheme) {
      switch (lineId) {
        case 1:
          return LightThemeColors.metroLine1;
        case 2:
          return LightThemeColors.metroLine2;
        case 3:
          return LightThemeColors.metroLine3;
        case 4:
          return LightThemeColors.metroLine4;
        default:
          return LightThemeColors.textDisabled;
      }
    }

    // Blue/messaging themes: use the blue palette’s metro colors (they differ from the legacy ones).
    return BlueThemeColors.getMetroLineColor(lineId);
  }

  Color _resolveTextColor(BuildContext context, Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    if (luminance > 0.55) {
      return Theme.of(context).colorScheme.onSurface;
    }
    return Theme.of(context).colorScheme.onPrimary;
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_subway_heatmap_error"),
      message: _errorMessage,
      onRetry: _loadCounts,
      retryLabel: L10n.get("admin_subway_heatmap_retry"),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        L10n.get("admin_subway_heatmap_no_data"),
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
