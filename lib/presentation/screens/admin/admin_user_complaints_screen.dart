import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/blocs/listing_detail_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_page_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_screen.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_action_sheet_item.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class AdminUserComplaintsScreen extends StatefulWidget {
  const AdminUserComplaintsScreen({
    required this.userId, super.key,
    this.userEmail,
  });

  final int userId;
  final String? userEmail;

  @override
  State<AdminUserComplaintsScreen> createState() =>
      _AdminUserComplaintsScreenState();
}

class _AdminUserComplaintsScreenState extends State<AdminUserComplaintsScreen> {
  final List<Complaint> _complaints = [];
  final Map<int, ComplaintCategory> _categoriesById = {};

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchCategories(),
      _fetchComplaints(),
    ]);
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

  Future<void> _fetchComplaints() async {
    if (_isLoading) return;
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final response = await getIt<IComplaintService>().getUserListingComplaints(
        widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _complaints
          ..clear()
          ..addAll(response);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await _fetchComplaints();
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
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_user_complaints_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          if (widget.userEmail != null && widget.userEmail!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    "${L10n.get("admin_user_complaints_user")}: ",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.userEmail!,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ThemeIcon(
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
          L10n.get("admin_user_complaints_empty"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final grouped = _groupComplaintsByListing(_complaints);
    return CommonListView(
      padding: const EdgeInsets.all(16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
          final listingLabel = group.listingId <= 0
              ? L10n.get("not_specified")
              : group.listingId.toString();
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text(
                "${L10n.get("admin_complaints_listing_id")}: $listingLabel",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "${L10n.get("admin_user_complaints_group_count")}: ${group.complaints.length}",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              children: List.generate(group.complaints.length, (itemIndex) {
                final complaint = group.complaints[itemIndex];
                final isLast = itemIndex == group.complaints.length - 1;
                return _buildComplaintItem(complaint, showDivider: !isLast);
              }),
            ),
          );
        },
      showRefreshIndicator: true,
      onRefresh: _refresh,
    );
  }

  List<_ComplaintGroup> _groupComplaintsByListing(List<Complaint> complaints) {
    final map = <int, List<Complaint>>{};
    for (final complaint in complaints) {
      final listingId = complaint.listingId ?? -1;
      map.putIfAbsent(listingId, () => <Complaint>[]).add(complaint);
    }

    final groups =
        map.entries
            .map(
              (entry) => _ComplaintGroup(
                listingId: entry.key,
                complaints: entry.value,
              ),
            )
            .toList();

    groups.sort((a, b) => a.listingId.compareTo(b.listingId));
    return groups;
  }

  Widget _buildComplaintItem(Complaint complaint, {required bool showDivider}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
                icon: const ThemeIcon(Icons.more_vert),
                onPressed: () => _showStatusMenu(complaint),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildMetaRow(
            context,
            labelKey: "admin_complaints_listing_id",
            value: _getListingLabel(context, complaint.listingId),
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
          if (showDivider) const Divider(height: 16),
        ],
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
        return Theme.of(context).colorScheme.primary;
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

  String _getListingLabel(BuildContext context, int? listingId) {
    if (listingId == null || listingId <= 0) {
      return L10n.get("not_specified");
    }
    return listingId.toString();
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
            (context) => MultiBlocProvider(
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
}

class _ComplaintGroup {
  _ComplaintGroup({required this.listingId, required this.complaints});

  final int listingId;
  final List<Complaint> complaints;
}
