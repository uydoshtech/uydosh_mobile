import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/domain/models/complaint.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";
import "package:uy_dosh/presentation/blocs/complaint_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";

class ListingComplaintsScreen extends StatefulWidget {

  const ListingComplaintsScreen({required this.listingId, super.key});
  final int listingId;

  @override
  State<ListingComplaintsScreen> createState() =>
      _ListingComplaintsScreenState();
}

class _ListingComplaintsScreenState extends State<ListingComplaintsScreen> {
  static const double _leadingWidth = 36;
  static const double _leadingGap = 12;

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
      appBar: UydoshAppBar(
        title: BlocBuilder<ComplaintBloc, ComplaintState>(
          builder: (context, state) {
            return state.maybeMap(
              complaintsLoaded: (loadedState) {
                final title =
                    L10n.get("listing_complaints_header").replaceAll(
                      "{count}",
                      "${loadedState.complaints.length}",
                    );
                return Text(title);
              },
              orElse:
                  () => Text(
                    L10n.get("listing_complaints"),
                  ),
            );
          },
        ),
        leading: ThreeDAppBarIconButton.backLeading(
          context,
          onPressed: () => Navigator.of(context).pop(),
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
          L10n.get("no_listing_complaints"),
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      );
    }

    final groups = _groupComplaintsByCategory(complaints);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CommonListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            itemCount: groups.length,
            itemSpacing: 12,
            itemBuilder: (context, index) {
              final group = groups[index];
              return ListingDetailTileShell(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: _buildGroupBody(group),
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
      final categoryId = complaint.categoryId ?? -1;
      (grouped[categoryId] ??= <Complaint>[]).add(complaint);
    }

    final groups = grouped.entries.map((entry) {
      final items = _sortComplaintsByDateDesc(entry.value);
      return _ComplaintGroup(
        categoryId: entry.key,
        category: items.first.category,
        complaints: items,
      );
    }).toList();

    groups.sort((a, b) {
      final aDate = _parseComplaintDate(a.complaints.first.createdAt);
      final bDate = _parseComplaintDate(b.complaints.first.createdAt);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    return groups;
  }

  List<Complaint> _sortComplaintsByDateDesc(List<Complaint> complaints) {
    final sorted = [...complaints];
    sorted.sort((a, b) {
      final aDate = _parseComplaintDate(a.createdAt);
      final bDate = _parseComplaintDate(b.createdAt);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  DateTime? _parseComplaintDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawDate);
  }

  String _buildCategoryTitle(ComplaintCategory? category) {
    if (category == null) {
      return L10n.get("unknown");
    }

    final currentLanguage = L10n.currentLanguage;
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

  Widget _buildGroupBody(_ComplaintGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupHeader(group),
        const SizedBox(height: 4),
        for (int i = 0; i < group.complaints.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            )
          else
            const SizedBox(height: 8),
          _buildComplaintEntry(group.complaints[i]),
        ],
      ],
    );
  }

  Widget _buildGroupHeader(_ComplaintGroup group) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: _leadingWidth,
          child: Center(
            child: ThemeIcon(
              Icons.report_outlined,
              size: 36,
              color: AppColors.error,
            ),
          ),
        ),
        const SizedBox(width: _leadingGap),
        Expanded(
          child: Text(
            _buildCategoryTitle(group.category),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (group.complaints.length > 1) ...[
          const SizedBox(width: 8),
          _buildCountBadge(group.complaints.length),
        ],
      ],
    );
  }

  Widget _buildCountBadge(int count) {
    const double diameter = 34;
    final base = Theme.of(context).colorScheme.surface;
    return Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: ThreeDSurfaceStyle.circularElevatedOrbDecoration(
        context,
        base,
      ),
      child: Text(
        "$count",
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildComplaintEntry(Complaint complaint) {
    final complaintText = (complaint.text ?? "").trim();
    final createdAt = _parseComplaintDate(complaint.createdAt);
    final localCreatedAt = createdAt?.toLocal();
    final timeText = localCreatedAt == null
        ? L10n.get("unknown")
        : "${localCreatedAt.hour.toString().padLeft(2, '0')}:${localCreatedAt.minute.toString().padLeft(2, '0')}";
    final dateText = localCreatedAt == null
        ? L10n.get("unknown")
        : AppDateUtils.formatDateWithMonthDay(context, localCreatedAt);

    final rawName = complaint.complainant?.profile?.name?.trim();
    final displayName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : L10n.get("na");
    final initials = StringUtils.extractInitials(rawName);
    final avatarUrl = complaint.complainant?.profile?.avatarUrl;
    final complainantUserId =
        complaint.complainantId ?? complaint.complainant?.id;
    final canOpenProfile =
        complainantUserId != null && complainantUserId > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: canOpenProfile
              ? () => _openComplainantProfile(complainantUserId)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: _leadingWidth,
                  child: Center(
                    child: ChatAvatar(
                      isCurrentUser: false,
                      initials: initials.isEmpty ? null : initials,
                      avatarUrl: avatarUrl,
                    ),
                  ),
                ),
                const SizedBox(width: _leadingGap),
                Expanded(
                  child: Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: canOpenProfile
                          ? TextDecoration.underline
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (complaintText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(
              left: _leadingWidth + _leadingGap,
            ),
            child: Text(
              complaintText,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.25,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _leadingWidth,
              child: Center(
                child: ThemeIcon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: ThemeState().isBlueTheme
                      ? Colors.white
                      : AppColors.textGrey,
                ),
              ),
            ),
            const SizedBox(width: _leadingGap),
            Text(
              dateText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(width: 16),
            _buildMetaChip(Icons.access_time, timeText),
          ],
        ),
      ],
    );
  }

  void _openComplainantProfile(int userId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => ListingOwnerProfileBloc(getIt<IUserProfileService>()),
          child: ListingOwnerProfileScreen(userId: userId),
        ),
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String value) {
    final isBlueTheme = ThemeState().isBlueTheme;
    final iconColor = isBlueTheme ? Colors.white : AppColors.textGrey;
    const textColor = AppColors.textGrey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ThemeIcon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const ThemeIcon(Icons.error_outline, size: 64, color: AppColors.error),
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
              L10n.get("back_to_listing"),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplaintGroup {
  const _ComplaintGroup({
    required this.categoryId,
    required this.category,
    required this.complaints,
  });

  final int categoryId;
  final ComplaintCategory? category;
  final List<Complaint> complaints;
}
