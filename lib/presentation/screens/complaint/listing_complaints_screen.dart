import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class ListingComplaintsScreen extends StatefulWidget {
  final int listingId;

  const ListingComplaintsScreen({super.key, required this.listingId});

  @override
  State<ListingComplaintsScreen> createState() =>
      _ListingComplaintsScreenState();
}

class _ListingComplaintsScreenState extends State<ListingComplaintsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ComplaintBloc>().add(
      ComplaintEvent.fetchListingComplaints(widget.listingId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "listing_complaints"),
        ),
        leading: IconButton(
          icon: const ThemeIcon(icon: Icons.arrow_back),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocListener<ComplaintBloc, ComplaintState>(
        listener: (context, state) {
          state.map(
            initial: (_) {},
            loading: (_) {},
            categoriesLoaded: (_) {},
            complaintCreated: (_) {},
            complaintsLoaded: (_) {},
            complaintUpdated: (_) {},
            complaintDeleted: (_) {},
            error: (errorState) {
              ToastTheme.showError(context, message: errorState.message);
            },
          );
        },
        child: BlocBuilder<ComplaintBloc, ComplaintState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => const Center(child: CircularProgressIndicator()),
              loading: (_) => const Center(child: CircularProgressIndicator()),
              categoriesLoaded: (_) => const SizedBox.shrink(),
              complaintCreated: (_) => const SizedBox.shrink(),
              complaintsLoaded:
                  (loadedState) => _buildComplaintsList(
                    loadedState.complaints,
                  ),
              complaintUpdated: (_) => const SizedBox.shrink(),
              complaintDeleted: (_) => const SizedBox.shrink(),
              error:
                  (errorState) => _buildErrorState(
                    context,
                    errorState.message,
                  ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildComplaintsList(List<Complaint> complaints) {
    if (complaints.isEmpty) {
      return Center(
        child: Text(
          LanguageAwareStringHelper.getCurrent(
            context,
            "no_listing_complaints",
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: complaints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return Card(
          child: ListTile(
            leading: const ThemeIcon(icon: Icons.report_outlined),
            title: Text(_buildComplaintTitle(complaint)),
            subtitle: _buildComplaintSubtitle(complaint),
            trailing: _buildStatusChip(complaint.status),
          ),
        );
      },
    );
  }

  String _buildComplaintTitle(Complaint complaint) {
    final category = complaint.category;
    if (category == null) {
      final complaintId = complaint.id ?? 0;
      return "${LanguageAwareStringHelper.getCurrent(context, "complaint_id")}: $complaintId";
    }

    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(
      context,
    );
    switch (currentLanguage) {
      case "ru":
        return category.nameRu;
      case "uz":
        return category.nameUz;
      case "en":
      default:
        return category.nameEn;
    }
  }

  Widget _buildComplaintSubtitle(Complaint complaint) {
    final dateText = _formatComplaintDate(complaint);
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: AppColors.textGrey,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            dateText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  String _formatComplaintDate(Complaint complaint) {
    if (complaint.createdAt == null || complaint.createdAt!.isEmpty) {
      return LanguageAwareStringHelper.getCurrent(context, "unknown");
    }
    final date = DateTime.tryParse(complaint.createdAt!);
    if (date == null) {
      return complaint.createdAt!;
    }
    return AppDateUtils.formatDateWithShortMonth(context, date);
  }

  Widget _buildStatusChip(String status) {
    final normalized = status.toLowerCase();
    final label = _getStatusLabel(normalized);
    final color = _getStatusColor(normalized);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case "pending":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "complaint_status_pending",
        );
      case "resolved":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "complaint_status_resolved",
        );
      case "dismissed":
        return LanguageAwareStringHelper.getCurrent(
          context,
          "complaint_status_dismissed",
        );
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "pending":
        return AppColors.warning;
      case "resolved":
        return AppColors.success;
      case "dismissed":
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          GhostButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              LanguageAwareStringHelper.getCurrent(context, "back_to_listing"),
            ),
          ),
        ],
      ),
    );
  }
}
