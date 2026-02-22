import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_action_sheet_item.dart";
import "package:uy_dosh/base/localization/l10n.dart";

class AdminComplaintsScreen extends StatefulWidget {
  const AdminComplaintsScreen({super.key});

  @override
  State<AdminComplaintsScreen> createState() => _AdminComplaintsScreenState();
}

class _AdminComplaintsScreenState extends State<AdminComplaintsScreen> {
  final List<Complaint> _complaints = [];
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
  final Map<int, ComplaintCategory> _categoriesById = {};

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

  Future<void> _refresh() async {
    _pageNumber = 1;
    _hasMore = true;
    _complaints.clear();
    await Future.wait([
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

  Future<void> _updateStatus(Complaint complaint, String status) async {
    try {
      final updated = await getIt<IComplaintService>().updateComplaintStatus(
        complaint.id ?? 0,
        status,
      );
      if (!mounted) return;
      setState(() {
        final index = _complaints.indexWhere((item) => item.id == updated.id);
        if (index != -1) {
          if (_statusFilter != null && updated.status != _statusFilter) {
            _complaints.removeAt(index);
          } else {
            _complaints[index] = updated;
          }
        }
      });
      _fetchStatusCounts();
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_complaints_status_updated"),
      );
    } catch (e) {
      ToastTheme.showError(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          L10n.get("admin_complaints_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildFilterRow(context),
          Expanded(
            child:
                _isLoading
                    ? CenteredHouseLoadingIndicator(
                      text: L10n.get("admin_complaints_loading"),
                    )
                    : _hasError
                    ? _buildErrorState(context)
                    : _buildComplaintsList(context),
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
        child: Row(
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
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String? status,
    String label,
  ) {
    final isSelected = _statusFilter == status;
    final selectedColor = _getFilterSelectedColor();
    final isBlueTheme = ThemeState().isBlueTheme;
    final backgroundColor = isSelected
        ? selectedColor
        : (isBlueTheme ? BlueThemeColors.card : Colors.grey[200]);
    final borderColor = isSelected
        ? selectedColor
        : (isBlueTheme ? BlueThemeColors.cardBorder : Colors.grey[400]!);
    final textColor = isSelected
        ? Colors.white
        : (isBlueTheme ? BlueThemeColors.textPrimary : Colors.grey[700]!);
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
  Color _getFilterSelectedColor() {
    if (ThemeState().isBlueTheme) {
      return BlueThemeColors.buttonPrimary;
    } else if (ThemeState().isLightTheme) {
      return Colors.black;
    } else {
      return Colors.black;
    }
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
            L10n.get("admin_complaints_error"),
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
            onPressed: _refresh,
            child: Text(
              L10n.get("retry"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(BuildContext context) {
    if (_complaints.isEmpty) {
      return Center(
        child: Text(
L10n.get("admin_complaints_empty"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return CommonListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _complaints.length,
      itemBuilder: (context, index) {
        final complaint = _complaints[index];
        return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getCategoryLabel(complaint),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusChip(context, complaint.status),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showStatusMenu(complaint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildMetaRow(
                    context,
                    labelKey: "admin_complaints_listing_id",
                    value: complaint.listingId.toString(),
                  ),
                  _buildMetaRow(
                    context,
                    labelKey: "admin_complaints_complainant_id",
                    value: complaint.complainantId.toString(),
                  ),
                  _buildMetaRow(
                    context,
                    labelKey: "admin_complaints_status_label",
                    value: _getStatusLabel(context, complaint.status),
                  ),
                  if (complaint.text != null && complaint.text!.isNotEmpty)
                    _buildTextSection(context, complaint.text!),
                  _buildMetaRow(
                    context,
                    labelKey: "admin_complaints_created_at",
                    value: _formatDate(complaint.createdAt, context),
                  ),
                ],
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

  Widget _buildTextSection(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${L10n.get("admin_complaints_text")}: ",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            style: const TextStyle(fontSize: 13),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required String labelKey,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            "${L10n.get(labelKey)}: ",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final color = _getStatusColor(context, status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusLabel(context, status),
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case "resolved":
        return Colors.green;
      case "dismissed":
        return Colors.grey;
      case "pending":
      default:
        return Colors.red;
    }
  }

  String _getStatusLabel(BuildContext context, String status) {
    switch (status) {
      case "resolved":
        return L10n.get("admin_complaints_status_resolved");
      case "dismissed":
        return L10n.get("admin_complaints_status_dismissed");
      case "pending":
      default:
        return L10n.get("admin_complaints_status_pending");
    }
  }

  String _getCategoryLabel(Complaint complaint) {
    final category = complaint.category ?? _categoriesById[complaint.categoryId];
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

  String _formatDate(String? value, BuildContext context) {
    if (value == null || value.isEmpty) {
      return L10n.get("not_specified");
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return value;
    }
    final local = parsed.toLocal();
    final year = local.year.toString();
    final month = local.month.toString().padLeft(2, "0");
    final day = local.day.toString().padLeft(2, "0");
    return "$year-$month-$day";
  }

  void _showStatusMenu(Complaint complaint) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UydoshActionSheetItem(
                icon: Icons.open_in_new,
                title: Text(
                  L10n.get("view_listing"),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _openListing(complaint.listingId);
                },
              ),
              const Divider(height: 1),
              UydoshActionSheetItem(
                title: Text(
                  L10n.get("admin_complaints_update_status"),
                ),
              ),
              UydoshActionSheetItem(
                icon: Icons.pending_actions,
                title: Text(
                  L10n.get("admin_complaints_status_pending"),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _updateStatus(complaint, "pending");
                },
              ),
              UydoshActionSheetItem(
                icon: Icons.check_circle_outline,
                title: Text(
                  L10n.get("admin_complaints_status_resolved"),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _updateStatus(complaint, "resolved");
                },
              ),
              UydoshActionSheetItem(
                icon: Icons.block_outlined,
                title: Text(
                  L10n.get("admin_complaints_status_dismissed"),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _updateStatus(complaint, "dismissed");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openListing(int? listingId) {
    if (listingId == null || listingId <= 0) {
      ToastTheme.showError(
        context,
        message: L10n.get("error_generic"),
      );
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => BlocProvider(
              create: (context) => ListingDetailBloc(getIt<IListingService>()),
              child: ListingDetailScreen(listingId: listingId),
            ),
      ),
    );
  }
}
