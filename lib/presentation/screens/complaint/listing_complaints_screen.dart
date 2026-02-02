import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
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
        title: BlocBuilder<ComplaintBloc, ComplaintState>(
          builder: (context, state) {
            return state.maybeMap(
              complaintsLoaded: (loadedState) {
                final title =
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "listing_complaints_header",
                    ).replaceAll(
                      "{count}",
                      "${loadedState.complaints.length}",
                    );
                return Text(title);
              },
              orElse:
                  () => Text(
                    LanguageAwareStringHelper.getCurrent(
                      context,
                      "listing_complaints",
                    ),
                  ),
            );
          },
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
              initial: (_) => const CenteredHouseLoadingIndicator(),
              loading: (_) => const CenteredHouseLoadingIndicator(),
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

    final complaintGroups = _groupComplaintsByCategory(complaints);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            itemCount: complaintGroups.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final group = complaintGroups[index];
              return Card(
                child: ListTile(
                  leading: const ThemeIcon(
                    icon: Icons.report_outlined,
                    size: 28,
                    color: AppColors.error,
                  ),
                  title: Text(
                    _buildGroupTitle(group),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: _buildGroupSubtitle(group),
                  trailing: _buildCountChip(group.count),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<_ComplaintGroup> _groupComplaintsByCategory(
    List<Complaint> complaints,
  ) {
    final grouped = <int, List<Complaint>>{};
    for (final complaint in complaints) {
      final categoryId = complaint.categoryId;
      final bucket = grouped[categoryId] ?? <Complaint>[];
      bucket.add(complaint);
      grouped[categoryId] = bucket;
    }

    final groups =
        grouped.entries.map((entry) {
          final items = entry.value;
          final latestComplaint = _getLatestComplaint(items);
          return _ComplaintGroup(
            categoryId: entry.key,
            category: items.first.category,
            complaints: items,
            latestComplaint: latestComplaint,
          );
        }).toList();

    groups.sort((a, b) {
      final aDate = _parseComplaintDate(a.latestComplaint?.createdAt);
      final bDate = _parseComplaintDate(b.latestComplaint?.createdAt);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return groups;
  }

  Complaint? _getLatestComplaint(List<Complaint> complaints) {
    Complaint? latest;
    DateTime? latestDate;
    for (final complaint in complaints) {
      final parsed = _parseComplaintDate(complaint.createdAt);
      if (parsed == null) {
        continue;
      }
      if (latestDate == null || parsed.isAfter(latestDate)) {
        latestDate = parsed;
        latest = complaint;
      }
    }
    return latest ?? (complaints.isNotEmpty ? complaints.first : null);
  }

  DateTime? _parseComplaintDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawDate);
  }

  String _buildGroupTitle(_ComplaintGroup group) {
    final category = group.category;
    if (category == null) {
      return LanguageAwareStringHelper.getCurrent(context, "unknown");
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

  Widget _buildGroupSubtitle(_ComplaintGroup group) {
    final dateText = _formatComplaintDate(group.latestComplaint);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
        ),
      ],
    );
  }

  String _formatComplaintDate(Complaint? complaint) {
    if (complaint?.createdAt == null || complaint!.createdAt!.isEmpty) {
      return LanguageAwareStringHelper.getCurrent(context, "unknown");
    }
    final date = DateTime.tryParse(complaint.createdAt!);
    if (date == null) {
      return complaint.createdAt!;
    }
    return AppDateUtils.formatDateWithShortMonth(context, date);
  }

  Widget _buildCountChip(int count) {
    final color = AppColors.primary;
    final label =
        LanguageAwareStringHelper.getCurrent(
          context,
          "complaints_count_short",
        ).replaceAll("{count}", "$count");

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

class _ComplaintGroup {
  final int categoryId;
  final ComplaintCategory? category;
  final List<Complaint> complaints;
  final Complaint? latestComplaint;

  _ComplaintGroup({
    required this.categoryId,
    required this.category,
    required this.complaints,
    required this.latestComplaint,
  });

  int get count => complaints.length;
}
