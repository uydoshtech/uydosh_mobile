import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

class AdminListingsWithComplaintsScreen extends StatefulWidget {
  const AdminListingsWithComplaintsScreen({super.key});

  @override
  State<AdminListingsWithComplaintsScreen> createState() =>
      _AdminListingsWithComplaintsScreenState();
}

class _AdminListingsWithComplaintsScreenState
    extends State<AdminListingsWithComplaintsScreen> {
  final List<Complaint> _complaints = [];
  final List<_ListingComplaintGroup> _groups = [];
  final Map<int, ComplaintCategory> _categoriesById = {};
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  int _pageNumber = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String? _statusFilter = "pending";
  Map<String, int> _statusCounts = {
    "pending": 0,
    "resolved": 0,
    "dismissed": 0,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchCategories(),
      _fetchStatusCounts(),
      _fetchComplaints(),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _fetchComplaints(loadMore: true);
    }
  }

  Future<void> _fetchComplaints({bool loadMore = false}) async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _hasError = false;
      _errorMessage = null;
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final response = await getIt<IComplaintService>().getComplaints(
        page: _pageNumber,
        limit: _pageSize,
        status: _statusFilter,
      );
      if (!mounted) return;
      setState(() {
        _complaints.addAll(response);
        _hasMore = response.length >= _pageSize;
        if (_hasMore) {
          _pageNumber += 1;
        }
        _rebuildGroups();
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
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories =
          await getIt<IComplaintService>().getComplaintCategories();
      if (!mounted) return;
      setState(() {
        _categoriesById
          ..clear()
          ..addEntries(categories.map((cat) => MapEntry(cat.id ?? 0, cat)));
      });
    } catch (_) {}
  }

  Future<void> _refresh() async {
    _pageNumber = 1;
    _hasMore = true;
    _complaints.clear();
    _groups.clear();
    await Future.wait([
      _fetchCategories(),
      _fetchStatusCounts(),
      _fetchComplaints(),
    ]);
  }

  void _onStatusFilterChanged(String? status) {
    setState(() {
      _statusFilter = status;
    });
    _refresh();
  }

  Future<void> _fetchStatusCounts() async {
    try {
      final service = getIt<IComplaintService>();
      final counts = await Future.wait([
        service.getComplaintsCount(status: "pending"),
        service.getComplaintsCount(status: "resolved"),
        service.getComplaintsCount(status: "dismissed"),
      ]);
      if (!mounted) return;
      setState(() {
        _statusCounts = {
          "pending": counts[0],
          "resolved": counts[1],
          "dismissed": counts[2],
        };
      });
    } catch (_) {}
  }

  void _rebuildGroups() {
    final map = <int, _ListingComplaintGroup>{};
    for (final complaint in _complaints) {
      final listingId = complaint.listingId ?? -1;
      final current = map[listingId];
      if (current == null) {
        map[listingId] = _ListingComplaintGroup.fromComplaint(
          listingId,
          complaint,
        );
      } else {
        current.addComplaint(complaint);
      }
    }

    _groups
      ..clear()
      ..addAll(map.values);

    _groups.sort((a, b) {
      final countCompare = b.count.compareTo(a.count);
      if (countCompare != 0) {
        return countCompare;
      }
      final aDate = a.latestDate;
      final bDate = b.latestDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_listing_complaints_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFilterRow(context),
          Expanded(
            child: _isLoading
                ? CenteredHouseLoadingIndicator(
                    text: L10n.get("admin_complaints_loading"),
                  )
                : _hasError
                    ? _buildErrorState(context)
                    : _buildListingsList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterChip(
                context,
                "pending",
                _buildStatusFilterLabel(
                  context,
                  "pending",
                  "admin_complaints_filter_pending",
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                "resolved",
                _buildStatusFilterLabel(
                  context,
                  "resolved",
                  "admin_complaints_filter_resolved",
                ),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                "dismissed",
                _buildStatusFilterLabel(
                  context,
                  "dismissed",
                  "admin_complaints_filter_dismissed",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String? status,
    String label,
  ) {
    final isSelected = _statusFilter == status;
    final isBlueTheme = ThemeState().isBlueTheme;
    final selectedColor = isBlueTheme
        ? BlueThemeColors.buttonPrimary
        : Theme.of(context).colorScheme.primary;
    final backgroundColor = isSelected
        ? selectedColor
        : (isBlueTheme ? Colors.transparent : Colors.grey[200]);
    final borderColor = isSelected
        ? selectedColor
        : (isBlueTheme ? Colors.white : Colors.grey[400]!);
    final textColor =
        isSelected ? Colors.white : (isBlueTheme ? Colors.white : Colors.grey[700]!);
    return InkWell(
      onTap: () => _onStatusFilterChanged(status),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }

  String _buildStatusFilterLabel(
    BuildContext context,
    String status,
    String labelKey,
  ) {
    final label = L10n.get(labelKey);
    final count = _statusCounts[status];
    if (count == null) return label;
    return "$label ($count)";
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_listing_complaints_error"),
      message: _errorMessage,
      onRetry: _refresh,
    );
  }

  Widget _buildListingsList(BuildContext context) {
    if (_groups.isEmpty) {
      return Center(
        child: Text(
          L10n.get("admin_listing_complaints_empty"),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
      );
    }

    return CommonListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemSpacing: 8,
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        final theme = Theme.of(context);
        const tileRadius = BorderRadius.all(Radius.circular(16));
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: tileRadius,
            gradient: ThreeDSurfaceStyle.surfaceGradient(
              context,
              theme.colorScheme.surface,
            ),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: Material(
            color: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: const RoundedRectangleBorder(borderRadius: tileRadius),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              tileColor: Colors.transparent,
              leading: ThemeIcon(
                Icons.home_work_outlined,
                color: ThemeState().isBlueTheme
                    ? Colors.white
                    : theme.colorScheme.primary,
              ),
              title: Text(
                "${L10n.get("admin_complaints_listing_id")}: ${_getListingLabel(context, group.listingId)}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    _buildComplaintsCountLabel(context, group.count),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._buildCategoryWidgets(context, group),
                  if (group.latestDate != null) const SizedBox.shrink(),
                ],
              ),
              trailing: ThemeIcon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onTap: () => _openListing(group.listingId),
            ),
          ),
        );
      },
      showRefreshIndicator: true,
      onRefresh: _refresh,
      showLoadMoreIndicator: _isLoadingMore,
      hasMore: _isLoadingMore,
      loadMoreIndicator: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _buildComplaintsCountLabel(BuildContext context, int count) {
    return L10n.get("complaints_count_short").replaceAll("{count}", "$count");
  }

  List<Widget> _buildCategoryWidgets(
    BuildContext context,
    _ListingComplaintGroup group,
  ) {
    if (group.categoryCounts.isEmpty) {
      return [
        Text(
          L10n.get("admin_listing_complaints_categories_empty"),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ];
    }

    final sortedIds = group.categoryCounts.keys.toList()
      ..sort((a, b) {
        final countCompare = (group.categoryCounts[b] ?? 0).compareTo(
          group.categoryCounts[a] ?? 0,
        );
        if (countCompare != 0) {
          return countCompare;
        }
        final aLabel = _getCategoryLabel(context, group, a);
        final bLabel = _getCategoryLabel(context, group, b);
        return aLabel.compareTo(bLabel);
      });

    return sortedIds.map((categoryId) {
      final label = _getCategoryLabel(context, group, categoryId);
      final count = group.categoryCounts[categoryId] ?? 0;
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ThemeIcon(
                Icons.circle,
                size: 6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "$label ($count)",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _getCategoryLabel(
    BuildContext context,
    _ListingComplaintGroup group,
    int categoryId,
  ) {
    final category =
        group.categoryById[categoryId] ?? _categoriesById[categoryId];
    if (category == null) {
      return L10n.get("admin_complaints_category_unknown");
    }
    final language = L10n.currentLanguage;
    switch (language) {
      case "ru":
        return category.nameRu;
      case "uz":
        return category.nameUz;
      case "en":
      default:
        return category.nameEn;
    }
  }

  String _getListingLabel(BuildContext context, int listingId) {
    if (listingId <= 0) {
      return L10n.get("not_specified");
    }
    return listingId.toString();
  }

  void _openListing(int listingId) {
    if (listingId <= 0) {
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic"),
      );
      return;
    }
    if (!mounted) return;
    context.pushListingDetail(listingId);
  }
}

class _ListingComplaintGroup {
  _ListingComplaintGroup({
    required this.listingId,
    required this.count,
    required this.latestCreatedAt,
    Map<int, int>? categoryCounts,
    Map<int, ComplaintCategory?>? categoryById,
  })  : categoryCounts = categoryCounts ?? <int, int>{},
        categoryById = categoryById ?? <int, ComplaintCategory?>{};

  final int listingId;
  int count;
  String? latestCreatedAt;
  final Map<int, int> categoryCounts;
  final Map<int, ComplaintCategory?> categoryById;

  DateTime? get latestDate => _parseDate(latestCreatedAt);

  static _ListingComplaintGroup fromComplaint(
    int listingId,
    Complaint complaint,
  ) {
    return _ListingComplaintGroup(
      listingId: listingId,
      count: 0,
      latestCreatedAt: complaint.createdAt,
    )..addComplaint(complaint);
  }

  void addComplaint(Complaint complaint) {
    count += 1;
    final incoming = _parseDate(complaint.createdAt);
    final current = _parseDate(latestCreatedAt);
    if (incoming != null && (current == null || incoming.isAfter(current))) {
      latestCreatedAt = complaint.createdAt;
    }
    final categoryId = complaint.categoryId ?? -1;
    categoryCounts[categoryId] = (categoryCounts[categoryId] ?? 0) + 1;
    if (complaint.category != null) {
      categoryById[categoryId] = complaint.category;
    }
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
