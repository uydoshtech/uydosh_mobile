import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

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
  String? _statusFilter;
  final Map<int, ComplaintCategory> _categoriesById = {};

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchComplaints();
    _scrollController.addListener(_onScroll);
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
    await _fetchComplaints();
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
          _complaints[index] = updated;
        }
      });
      ToastTheme.showSuccess(
        context,
        message: LanguageAwareStringHelper.getCurrent(
          context,
          "admin_complaints_status_updated",
        ),
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
          LanguageAwareStringHelper.getCurrent(context, "admin_complaints_title"),
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
                      text: LanguageAwareStringHelper.getCurrent(
                        context,
                        "admin_complaints_loading",
                      ),
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
      child: Wrap(
        spacing: 8,
        children: [
          _buildFilterChip(context, null, "admin_complaints_filter_all"),
          _buildFilterChip(context, "pending", "admin_complaints_filter_pending"),
          _buildFilterChip(
            context,
            "resolved",
            "admin_complaints_filter_resolved",
          ),
          _buildFilterChip(
            context,
            "dismissed",
            "admin_complaints_filter_dismissed",
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String? status,
    String labelKey,
  ) {
    final isSelected = _statusFilter == status;
    return ChoiceChip(
      selected: isSelected,
      label: Text(LanguageAwareStringHelper.getCurrent(context, labelKey)),
      onSelected: (_) => _onStatusFilterChanged(status),
    );
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
              "admin_complaints_error",
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
            onPressed: _refresh,
            child: Text(
              LanguageAwareStringHelper.getCurrent(context, "retry"),
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
          LanguageAwareStringHelper.getCurrent(
            context,
            "admin_complaints_empty",
          ),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _complaints.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _complaints.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

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
            "${LanguageAwareStringHelper.getCurrent(context, labelKey)}: ",
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
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _getStatusLabel(BuildContext context, String status) {
    switch (status) {
      case "resolved":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "admin_complaints_status_resolved",
        );
      case "dismissed":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "admin_complaints_status_dismissed",
        );
      case "pending":
      default:
        return LanguageAwareStringHelper.getCurrent(
          context,
          "admin_complaints_status_pending",
        );
    }
  }

  String _getCategoryLabel(Complaint complaint) {
    final category = complaint.category ?? _categoriesById[complaint.categoryId];
    if (category == null) {
      return LanguageAwareStringHelper.getCurrent(
        context,
        "admin_complaints_category_unknown",
      );
    }
    final language = LanguageState().currentLanguage;
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
      return LanguageAwareStringHelper.getCurrent(context, "not_specified");
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
              ListTile(
                title: Text(
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "admin_complaints_update_status",
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.pending_actions),
                title: Text(
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "admin_complaints_status_pending",
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _updateStatus(complaint, "pending");
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "admin_complaints_status_resolved",
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _updateStatus(complaint, "resolved");
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: Text(
                  LanguageAwareStringHelper.getCurrent(
                    context,
                    "admin_complaints_status_dismissed",
                  ),
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
}
