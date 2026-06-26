import "dart:math" as math;

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/domain/utils/profile_match_scoring.dart";
import "package:uy_dosh/presentation/screens/listing_detail/group_member_compatibility_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/profile_compatibility_field_icons.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/text_button_themed.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_avatar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

const _sheetScreenMargin = 24.0;
const _sheetMinimumHeight = 280.0;
const _sheetHandleHeight = 14.0;
const _sheetHeaderHeight = 118.0;
const _sheetFullGroupHeaderExtraHeight = 55.0;
const _sheetFullGroupShortlistActionHeight = 52.0;
const _sheetListBottomPadding = 16.0;
const _sheetCardGap = 10.0;
const _sheetMeasurementSlack = 8.0;
const _sheetPendingSectionHeaderHeight = 46.0;
const _sheetLoadingRequestsHeight = 48.0;
const _memberCardBaseHeight = 82.0;
const _memberCardHighlightsHeight = 37.0;
const _memberCardLeaveActionHeight = 29.0;
const _pendingRequestCardBaseHeight = 132.0;
const _pendingRequestMessageHeight = 28.0;

class _MemberRemovalDecision {
  const _MemberRemovalDecision({this.reason});

  final String? reason;
}

class _RemoveMemberDialog extends StatefulWidget {
  const _RemoveMemberDialog({required this.member});

  final ConversationMemberSummary member;

  @override
  State<_RemoveMemberDialog> createState() => _RemoveMemberDialogState();
}

class _RemoveMemberDialogState extends State<_RemoveMemberDialog> {
  static const _otherReasonKey = "group_remove_reason_other";
  static const _reasonKeys = [
    "group_remove_reason_inactive",
    "group_remove_reason_rules",
    "group_remove_reason_not_fit",
    "group_remove_reason_member_request",
    _otherReasonKey,
  ];

  final _otherController = TextEditingController();
  String? _selectedReasonKey;

  IconData _reasonIcon(String reasonKey) {
    switch (reasonKey) {
      case "group_remove_reason_inactive":
        return Icons.schedule_rounded;
      case "group_remove_reason_rules":
        return Icons.gavel_rounded;
      case "group_remove_reason_not_fit":
        return Icons.group_remove_rounded;
      case "group_remove_reason_member_request":
        return Icons.logout_rounded;
      case _otherReasonKey:
        return Icons.more_horiz_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  String? _selectedReason() {
    final reasonKey = _selectedReasonKey;
    if (reasonKey == null) return null;
    if (reasonKey == _otherReasonKey) {
      final customReason = _otherController.text.trim();
      return customReason.isEmpty ? null : customReason;
    }
    return L10n.get(reasonKey);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return UydoshGlassDialog(
      title: Text(
        L10n.get("group_remove_member_title"),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UyDoshAvatar(
                  avatarUrl: widget.member.avatarUrl,
                  displayName: widget.member.name,
                  customSize: 30,
                  borderColor: scheme.outlineVariant.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    L10n.getWithParams(
                      "group_remove_member_message",
                      params: {"name": widget.member.name},
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: scheme.onSurfaceVariant,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              L10n.get("group_remove_reason_title"),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final reasonKey in _reasonKeys)
                  _RemovalReasonChip(
                    label: L10n.get(reasonKey),
                    icon: _reasonIcon(reasonKey),
                    isSelected: _selectedReasonKey == reasonKey,
                    onTap: () {
                      setState(() {
                        _selectedReasonKey =
                            _selectedReasonKey == reasonKey ? null : reasonKey;
                      });
                    },
                  ),
              ],
            ),
            if (_selectedReasonKey == _otherReasonKey) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _otherController,
                autofocus: true,
                maxLength: 80,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: L10n.get("group_remove_reason_other_hint"),
                  isDense: true,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButtonThemed(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
          child: Text(
            L10n.get("cancel"),
            style: const TextStyle(fontSize: 16),
          ),
        ),
        TextButtonThemed(
          onPressed: () {
            Navigator.of(context).pop(
              _MemberRemovalDecision(reason: _selectedReason()),
            );
          },
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          child: Text(
            L10n.get("group_remove_member"),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RemovalReasonChip extends StatelessWidget {
  const _RemovalReasonChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chipColor = ListingDetailThemeHelper.amenityChipBackgroundColor;
    final borderColor = ListingDetailThemeHelper.amenityChipBorderColor;
    final foregroundColor = isSelected
        ? (ThemeState().isBlueTheme ? Colors.white : scheme.primary)
        : ListingDetailThemeHelper.amenityIconColor;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          HapticFeedbackUtils.impact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? borderColor.withValues(
                    alpha: ThemeState().isBlueTheme ? 0.24 : 0.12)
                : chipColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? foregroundColor : borderColor,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeIcon(icon, size: 17, color: foregroundColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showListingGroupMemberProfilesSheet({
  required BuildContext context,
  required int listingId,
  required List<ConversationMemberSummary> members,
  required int ownerUserId,
  required void Function(int userId) onMemberTap,
  required bool isOwner,
  int? currentUserId,
  ListingGroupProgress? groupProgress,
  Map<int, GroupMemberCompatibilitySummary> memberCompatibility = const {},
  ListingDetail? groupListingDetail,
  VoidCallback? onChanged,
}) async {
  if (members.isEmpty) return false;

  final leftGroup = await showAppBottomSheet<bool>(
    context: context,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
      final bottomPadding = bottomInset + 12;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          width: MediaQuery.sizeOf(sheetContext).width,
          child: GlassBottomSheetSurface(
            borderRadius: BorderRadius.circular(18),
            child: Material(
              type: MaterialType.transparency,
              child: _ListingGroupMemberProfilesSheet(
                listingId: listingId,
                members: members,
                ownerUserId: ownerUserId,
                currentUserId: currentUserId,
                isOwner: isOwner,
                reservedBottomPadding: bottomPadding,
                groupProgress: groupProgress,
                memberCompatibility: memberCompatibility,
                groupListingDetail: groupListingDetail,
                onMemberTap: onMemberTap,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      );
    },
  );
  return leftGroup == true;
}

class _ListingGroupMemberProfilesSheet extends StatefulWidget {
  const _ListingGroupMemberProfilesSheet({
    required this.listingId,
    required this.members,
    required this.ownerUserId,
    required this.onMemberTap,
    required this.isOwner,
    required this.reservedBottomPadding,
    this.currentUserId,
    this.groupProgress,
    this.memberCompatibility = const {},
    this.groupListingDetail,
    this.onChanged,
  });

  final int listingId;
  final List<ConversationMemberSummary> members;
  final int ownerUserId;
  final int? currentUserId;
  final bool isOwner;
  final double reservedBottomPadding;
  final ListingGroupProgress? groupProgress;
  final Map<int, GroupMemberCompatibilitySummary> memberCompatibility;
  final ListingDetail? groupListingDetail;
  final void Function(int userId) onMemberTap;
  final VoidCallback? onChanged;

  @override
  State<_ListingGroupMemberProfilesSheet> createState() =>
      _ListingGroupMemberProfilesSheetState();
}

class _ListingGroupMemberProfilesSheetState
    extends State<_ListingGroupMemberProfilesSheet> {
  late List<ConversationMemberSummary> _members;
  List<ListingGroupJoinRequest> _pendingRequests = const [];
  Map<int, GroupMemberCompatibilitySummary> _pendingRequestCompatibility =
      const {};
  final Set<int> _busyRequestIds = {};
  var _isRemoving = false;
  var _isLeaving = false;
  var _loadingRequests = false;
  var _hasCheckedRequests = false;

  @override
  void initState() {
    super.initState();
    _members = List<ConversationMemberSummary>.from(widget.members);
    if (widget.isOwner) {
      _loadPendingRequests();
    }
  }

  ListingGroupProgress? get _groupProgress {
    final base = widget.groupProgress;
    if (base == null) return null;
    return ListingGroupProgress(
      current: _members.isEmpty ? 1 : _members.length,
      target: base.target,
    );
  }

  int? get _activeLandlordUserId => widget
      .groupListingDetail?.groupContext?.groupProgress?.activeLandlordUserId;

  bool get _isGroupFull {
    final progress = _groupProgress;
    return progress != null &&
        progress.target > 0 &&
        progress.current >= progress.target;
  }

  List<ConversationMemberSummary> get _sortedMembers => _sortMembersForDisplay(
        members: _members,
        ownerUserId: widget.ownerUserId,
        landlordUserId: _activeLandlordUserId,
        currentUserId: widget.currentUserId,
      );

  double _availableSheetHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return (mediaQuery.size.height -
            mediaQuery.padding.top -
            mediaQuery.padding.bottom -
            widget.reservedBottomPadding -
            _sheetScreenMargin)
        .clamp(0.0, mediaQuery.size.height)
        .toDouble();
  }

  double _estimatedSheetHeight({
    required List<ConversationMemberSummary> sortedMembers,
    required bool showPendingRequests,
  }) {
    var height = _sheetHandleHeight +
        _sheetHeaderHeight +
        _sheetListBottomPadding +
        _estimatedMemberCardsHeight(sortedMembers);

    if (_isGroupFull) {
      height += _sheetFullGroupHeaderExtraHeight +
          _sheetFullGroupShortlistActionHeight;
    }

    if (showPendingRequests) {
      height += _sheetPendingSectionHeaderHeight;
      if (_loadingRequests || _pendingRequests.isEmpty) {
        height += _sheetLoadingRequestsHeight;
      } else {
        height += _estimatedPendingRequestCardsHeight();
      }
    }

    return height;
  }

  double _estimatedMemberCardsHeight(
    List<ConversationMemberSummary> sortedMembers,
  ) {
    if (sortedMembers.isEmpty) return 0;

    var height = (sortedMembers.length - 1) * _sheetCardGap;
    for (final member in sortedMembers) {
      height += _estimatedMemberCardHeight(member);
    }
    return height;
  }

  double _estimatedMemberCardHeight(ConversationMemberSummary member) {
    final hasHighlights =
        widget.memberCompatibility[member.userId]?.fieldHighlights.isNotEmpty ??
            false;
    final hasLeaveAction = !widget.isOwner &&
        widget.currentUserId != null &&
        member.userId == widget.currentUserId &&
        member.userId != widget.ownerUserId &&
        !_isLeaving;

    return _memberCardBaseHeight +
        (hasHighlights ? _memberCardHighlightsHeight : 0) +
        (hasLeaveAction ? _memberCardLeaveActionHeight : 0);
  }

  double _estimatedPendingRequestCardsHeight() {
    if (_pendingRequests.isEmpty) return 0;

    var height = (_pendingRequests.length - 1) * _sheetCardGap;
    for (final request in _pendingRequests) {
      final hasMessage = request.message?.trim().isNotEmpty ?? false;
      height += _pendingRequestCardBaseHeight +
          (hasMessage ? _pendingRequestMessageHeight : 0);
    }
    return height;
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _loadingRequests = true);
    try {
      final rows = await getIt<IListingGroupService>().listJoinRequests(
        listingId: widget.listingId,
      );
      if (!mounted) return;
      final pendingRows =
          rows.where((request) => request.status == "pending").toList();
      setState(() {
        _pendingRequests = pendingRows;
        _loadingRequests = false;
        _hasCheckedRequests = true;
      });
      await _loadPendingRequestCompatibility(pendingRows);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingRequests = false;
        _hasCheckedRequests = true;
      });
    }
  }

  Future<void> _loadPendingRequestCompatibility(
    List<ListingGroupJoinRequest> requests,
  ) async {
    if (requests.isEmpty) {
      if (!mounted) return;
      setState(() => _pendingRequestCompatibility = const {});
      return;
    }

    try {
      final service = getIt<IUserProfileService>();
      final currentProfile = await service.getCurrentUserProfile();
      final entries = await Future.wait(
        requests.map((request) async {
          try {
            final applicantProfile =
                await service.getUserProfile(request.applicantUserId);
            return MapEntry(
              request.applicantUserId,
              GroupMemberCompatibilityHelper.summarize(
                currentProfile,
                applicantProfile,
              ),
            );
          } catch (_) {
            return MapEntry(
              request.applicantUserId,
              GroupMemberCompatibilitySummary.empty,
            );
          }
        }),
      );
      if (!mounted) return;
      setState(() {
        _pendingRequestCompatibility =
            Map<int, GroupMemberCompatibilitySummary>.fromEntries(entries);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _pendingRequestCompatibility = const {});
    }
  }

  Future<void> _approveRequest(ListingGroupJoinRequest request) async {
    if (_busyRequestIds.contains(request.id)) return;
    HapticFeedbackUtils.impact();
    setState(() => _busyRequestIds.add(request.id));
    try {
      await getIt<IListingGroupService>().approveJoinRequest(
        listingId: widget.listingId,
        requestId: request.id,
      );
      if (!mounted) return;
      setState(() {
        _pendingRequests =
            _pendingRequests.where((row) => row.id != request.id).toList();
        _pendingRequestCompatibility =
            Map<int, GroupMemberCompatibilitySummary>.from(
          _pendingRequestCompatibility,
        )..remove(request.applicantUserId);
        if (!_members.any((row) => row.userId == request.applicantUserId)) {
          _members.add(
            ConversationMemberSummary(
              userId: request.applicantUserId,
              name: request.applicantName,
              avatarUrl: request.applicantAvatar,
            ),
          );
        }
        _busyRequestIds.remove(request.id);
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_join_request_approved"),
      );
      widget.onChanged?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyRequestIds.remove(request.id));
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Future<void> _rejectRequest(ListingGroupJoinRequest request) async {
    if (_busyRequestIds.contains(request.id)) return;
    HapticFeedbackUtils.impact();
    setState(() => _busyRequestIds.add(request.id));
    try {
      await getIt<IListingGroupService>().rejectJoinRequest(
        listingId: widget.listingId,
        requestId: request.id,
      );
      if (!mounted) return;
      setState(() {
        _pendingRequests =
            _pendingRequests.where((row) => row.id != request.id).toList();
        _pendingRequestCompatibility =
            Map<int, GroupMemberCompatibilitySummary>.from(
          _pendingRequestCompatibility,
        )..remove(request.applicantUserId);
        _busyRequestIds.remove(request.id);
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_join_request_rejected"),
      );
      widget.onChanged?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() => _busyRequestIds.remove(request.id));
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Future<void> _confirmRemoveMember(ConversationMemberSummary member) async {
    if (_isRemoving) return;

    final decision = await _showRemoveMemberDialog(member);
    if (decision == null || !mounted) return;

    setState(() => _isRemoving = true);
    try {
      await getIt<IListingGroupService>().removeMember(
        listingId: widget.listingId,
        memberUserId: member.userId,
        reason: decision.reason,
      );
      if (!mounted) return;
      setState(() {
        _members.removeWhere((row) => row.userId == member.userId);
        _isRemoving = false;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_remove_member_success"),
      );
      widget.onChanged?.call();
      if (_members.isEmpty && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRemoving = false);
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Future<_MemberRemovalDecision?> _showRemoveMemberDialog(
    ConversationMemberSummary member,
  ) async {
    return showDialog<_MemberRemovalDecision>(
      context: context,
      builder: (_) {
        return _RemoveMemberDialog(member: member);
      },
    );
  }

  Future<void> _confirmLeaveGroup() async {
    if (_isLeaving) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return UydoshGlassDialog(
          title: Text(
            L10n.get("group_leave_group_title"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          content: Text(
            L10n.get("group_leave_group_message"),
            style: TextStyle(
              fontSize: 16,
              color: scheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButtonThemed(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: scheme.onSurface),
              child: Text(
                L10n.get("cancel"),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            TextButtonThemed(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              child: Text(
                L10n.get("group_leave_group"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLeaving = true);
    try {
      await getIt<IListingGroupService>().leaveGroup(
        listingId: widget.listingId,
      );
      if (!mounted) return;
      setState(() {
        if (widget.currentUserId != null) {
          _members.removeWhere((row) => row.userId == widget.currentUserId);
        }
        _isLeaving = false;
      });
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_leave_group_success"),
      );
      widget.onChanged?.call();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLeaving = false);
      ToastTheme.showError(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scheme = Theme.of(context).colorScheme;
        final sortedMembers = _sortedMembers;
        final showPendingRequests = widget.isOwner &&
            (_loadingRequests ||
                _pendingRequests.isNotEmpty ||
                _hasCheckedRequests);
        final maxSheetHeight = math.min(
          _availableSheetHeight(context),
          constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : double.infinity,
        );
        final estimatedSheetHeight = _estimatedSheetHeight(
          sortedMembers: sortedMembers,
          showPendingRequests: showPendingRequests,
        );
        final minSheetHeight = maxSheetHeight < _sheetMinimumHeight
            ? maxSheetHeight
            : _sheetMinimumHeight;
        final wantsFullHeight =
            estimatedSheetHeight + _sheetMeasurementSlack >= maxSheetHeight;
        final sheetHeight = (wantsFullHeight
                ? maxSheetHeight
                : estimatedSheetHeight + _sheetMeasurementSlack)
            .clamp(minSheetHeight, maxSheetHeight)
            .toDouble();
        final shouldScroll = wantsFullHeight;

        return SizedBox(
          height: sheetHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              _MemberProfilesHeader(
                members: sortedMembers,
                currentUserId: widget.currentUserId,
                isGroupFull: _isGroupFull,
                groupProgress: _groupProgress,
                statusLabelKey: widget
                    .groupListingDetail?.groupContext?.progressStatusLabelKey,
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: shouldScroll
                      ? const BouncingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isGroupFull) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await GroupHousingFlow.openShortlistSheet(
                                    context: context,
                                    groupListingId: widget.listingId,
                                    isOwner: widget.isOwner,
                                    groupListingDetail:
                                        widget.groupListingDetail,
                                    onChanged: widget.onChanged,
                                  );
                                },
                                icon: const Icon(Icons.bookmark_outline),
                                label: Text(
                                  GroupHousingFlow.savedListingsLabel(
                                    widget.groupListingDetail?.groupContext
                                            ?.groupShortlistCount ??
                                        GroupShortlistState()
                                            .shortlistCountForGroup(
                                          widget.listingId,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (final member in sortedMembers) ...[
                              if (member != sortedMembers.first)
                                const SizedBox(height: 10),
                              _MemberProfileCard(
                                member: member,
                                ownerUserId: widget.ownerUserId,
                                landlordUserId: _activeLandlordUserId,
                                currentUserId: widget.currentUserId,
                                compatibility:
                                    widget.memberCompatibility[member.userId],
                                canRemove: widget.isOwner &&
                                    member.userId != widget.ownerUserId &&
                                    !_isRemoving,
                                canLeave: !widget.isOwner &&
                                    widget.currentUserId != null &&
                                    member.userId == widget.currentUserId &&
                                    member.userId != widget.ownerUserId &&
                                    !_isLeaving,
                                onTap: () {
                                  HapticFeedbackUtils.impact();
                                  Navigator.of(context).pop();
                                  widget.onMemberTap(member.userId);
                                },
                                onRemove: widget.isOwner &&
                                        member.userId != widget.ownerUserId &&
                                        !_isRemoving
                                    ? () => _confirmRemoveMember(member)
                                    : null,
                                onLeave: !widget.isOwner &&
                                        widget.currentUserId != null &&
                                        member.userId == widget.currentUserId &&
                                        member.userId != widget.ownerUserId &&
                                        !_isLeaving
                                    ? _confirmLeaveGroup
                                    : null,
                              ),
                            ],
                            if (showPendingRequests) ...[
                              const SizedBox(height: 18),
                              Text(
                                L10n.get("group_pending_join_requests"),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              if (_loadingRequests)
                                const SizedBox(
                                  height: _sheetLoadingRequestsHeight,
                                  child: Center(
                                    child: HouseLoadingIndicator(size: 24),
                                  ),
                                )
                              else if (_pendingRequests.isEmpty)
                                SizedBox(
                                  height: _sheetLoadingRequestsHeight,
                                  child: Center(
                                    child: Text(
                                      L10n.get("group_no_pending_requests"),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                )
                              else
                                for (final request in _pendingRequests) ...[
                                  if (request != _pendingRequests.first)
                                    const SizedBox(height: 10),
                                  _PendingJoinRequestCard(
                                    request: request,
                                    compatibility: _pendingRequestCompatibility[
                                        request.applicantUserId],
                                    isBusy:
                                        _busyRequestIds.contains(request.id),
                                    onTap: () {
                                      HapticFeedbackUtils.impact();
                                      Navigator.of(context).pop();
                                      widget
                                          .onMemberTap(request.applicantUserId);
                                    },
                                    onApprove: () => _approveRequest(request),
                                    onReject: () => _rejectRequest(request),
                                  ),
                                ],
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

List<ConversationMemberSummary> _sortMembersForDisplay({
  required List<ConversationMemberSummary> members,
  required int ownerUserId,
  int? landlordUserId,
  int? currentUserId,
}) {
  final sorted = List<ConversationMemberSummary>.from(members);
  sorted.sort((a, b) {
    int rank(ConversationMemberSummary member) {
      if (landlordUserId != null && member.userId == landlordUserId) return 0;
      if (member.userId == ownerUserId) return 1;
      if (currentUserId != null && member.userId == currentUserId) return 2;
      return 3;
    }

    final rankCompare = rank(a).compareTo(rank(b));
    if (rankCompare != 0) return rankCompare;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
  return sorted;
}

class _MemberProfilesHeader extends StatelessWidget {
  const _MemberProfilesHeader({
    required this.members,
    required this.currentUserId,
    required this.isGroupFull,
    this.groupProgress,
    this.statusLabelKey,
  });

  final List<ConversationMemberSummary> members;
  final int? currentUserId;
  final bool isGroupFull;
  final ListingGroupProgress? groupProgress;
  final String? statusLabelKey;

  String _memberNamesLabel() {
    final names = members.map((member) => member.name).toList();
    if (names.length <= 1) return names.join(", ");

    final splitIndex = (names.length / 2).ceil();
    return [
      names.take(splitIndex).join(", "),
      names.skip(splitIndex).join(", "),
    ].where((line) => line.isNotEmpty).join("\n");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLightTheme = ThemeState().isLightTheme;
    final subtitleColor = isLightTheme ? Colors.black : scheme.onSurfaceVariant;
    final membersNeeded = groupProgress != null
        ? (groupProgress!.target - groupProgress!.current)
        : 0;
    final progressLabel = membersNeeded > 0
        ? L10n.plural("group_members_needed", membersNeeded)
        : null;
    final statusLabel = statusLabelKey == null ||
            (isGroupFull && statusLabelKey == "group_status_full")
        ? null
        : L10n.get(statusLabelKey!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isGroupFull) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: [
                  ThemeIcon(
                    CupertinoIcons.checkmark_circle_fill,
                    size: 18,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      L10n.get("group_member_profiles_formed"),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.successDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            L10n.get("view_member_profiles"),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (statusLabel != null) ...[
            const SizedBox(height: 10),
            _GroupMembersProgressPill(label: statusLabel),
          ],
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ChatParticipantAvatarStack(
                participants: members,
                currentUserId: currentUserId,
                avatarSize: 32 * 1.1,
                maxVisible: 5,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _memberNamesLabel(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Text(
                  L10n.getWithParams(
                    "group_compatibility_subtitle",
                    params: {"count": members.length.toString()},
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: subtitleColor,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (progressLabel != null) ...[
                const SizedBox(width: 10),
                _GroupMembersProgressPill(label: progressLabel),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupMembersProgressPill extends StatelessWidget {
  const _GroupMembersProgressPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.72) : Colors.black;
    final textColor = isDark
        ? theme.colorScheme.onSurface.withValues(alpha: 0.90)
        : Colors.black;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _MemberProfileCard extends StatelessWidget {
  const _MemberProfileCard({
    required this.member,
    required this.ownerUserId,
    required this.onTap,
    this.landlordUserId,
    this.currentUserId,
    this.compatibility,
    this.canRemove = false,
    this.canLeave = false,
    this.onRemove,
    this.onLeave,
  });

  final ConversationMemberSummary member;
  final int ownerUserId;
  final int? landlordUserId;
  final int? currentUserId;
  final GroupMemberCompatibilitySummary? compatibility;
  final VoidCallback onTap;
  final bool canRemove;
  final bool canLeave;
  final Future<void> Function()? onRemove;
  final VoidCallback? onLeave;

  bool get _isOwner => member.userId == ownerUserId;

  bool get _isLandlord =>
      landlordUserId != null && member.userId == landlordUserId;

  bool get _isCurrentUser =>
      currentUserId != null && member.userId == currentUserId;

  String? get _roleLabel {
    if (_isLandlord) return L10n.get("role_landlord");
    if (_isOwner) return L10n.get("group_member_role_owner");
    if (_isCurrentUser) return L10n.get("group_member_role_you");
    return L10n.get("group_member_role_member");
  }

  Color _roleColor(ColorScheme scheme) {
    if (_isLandlord) return ListingDetailThemeHelper.iconColor;
    if (_isOwner) return ListingDetailThemeHelper.iconColor;
    if (_isCurrentUser) return AppColors.success;
    if (ThemeState().isLightTheme) return Colors.black;
    return scheme.onSurfaceVariant;
  }

  Color _percentColor(BuildContext context) {
    final percent = compatibility?.percent;
    if (percent == null) return Theme.of(context).colorScheme.onSurfaceVariant;
    if (percent >= 80) {
      return ThemeState().isLightTheme
          ? AppColors.successDark
          : AppColors.success;
    }
    if (percent >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Color _highlightColor(ProfileMatchFieldStatus status) {
    switch (status) {
      case ProfileMatchFieldStatus.match:
        return ThemeState().isLightTheme
            ? AppColors.successDark
            : AppColors.success;
      case ProfileMatchFieldStatus.difference:
        return ThemeState().isLightTheme
            ? AppColors.warningDark
            : AppColors.warning;
      case ProfileMatchFieldStatus.dealbreaker:
        return AppColors.error;
      case ProfileMatchFieldStatus.incomplete:
        return AppColors.iconPrimary;
    }
  }

  String _highlightSemanticsLabel(MemberCompatibilityFieldHighlight highlight) {
    final fieldLabel = L10n.get(highlight.labelKey);
    final statusLabel = switch (highlight.status) {
      ProfileMatchFieldStatus.match => L10n.get("group_member_compat_match"),
      ProfileMatchFieldStatus.difference =>
        L10n.get("group_member_compat_difference"),
      ProfileMatchFieldStatus.dealbreaker =>
        L10n.get("group_member_compat_dealbreaker"),
      ProfileMatchFieldStatus.incomplete => "",
    };
    return "$fieldLabel: $statusLabel";
  }

  Widget _buildRemoveSwipeBackground(BuildContext context) {
    final themeState = ThemeState();
    final foregroundColor =
        themeState.isBlueTheme ? Colors.white : AppColors.error;
    final backgroundColor = themeState.isBlueTheme
        ? AppColors.error.withValues(alpha: 0.38)
        : AppColors.error.withValues(alpha: 0.20);

    return Container(
      alignment: AlignmentDirectional.centerEnd,
      padding: const EdgeInsetsDirectional.only(end: 24),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(Icons.delete_outline_rounded, color: foregroundColor),
          const SizedBox(width: 8),
          Text(
            L10n.get("group_remove_member"),
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldHighlights(BuildContext context) {
    final highlights = compatibility?.fieldHighlights ?? const [];
    if (highlights.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final highlight in highlights)
            Semantics(
              label: _highlightSemanticsLabel(highlight),
              child: Tooltip(
                message: _highlightSemanticsLabel(highlight),
                child: Container(
                  width: 29,
                  height: 29,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _highlightColor(highlight.status)
                        .withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _highlightColor(highlight.status)
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: ThemeIcon(
                    ProfileCompatibilityFieldIcons.iconFor(highlight.labelKey),
                    size: 16,
                    color: _highlightColor(highlight.status),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final themeState = ThemeState();
    const avatarSize = 48.0;
    final avatarUrl = resolveAvatarUrl(member.avatarUrl);
    final initials = StringUtils.extractInitials(member.name);
    final roleColor = _roleColor(scheme);
    final highlightCurrentUser = _isCurrentUser && !_isOwner;

    final avatarFallback = CircleAvatar(
      backgroundColor: themeState.avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          color: themeState.avatarIconColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final card = ThreeDElevatedSurface(
      baseColor: scheme.surface,
      useLiquidGlass: true,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: avatarUrl != null
                    ? NetworkAvatarImage(
                        imageUrl: avatarUrl,
                        size: avatarSize,
                        fallback: SizedBox(
                          width: avatarSize,
                          height: avatarSize,
                          child: avatarFallback,
                        ),
                      )
                    : SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: avatarFallback,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (compatibility?.percent != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            "${compatibility!.percent}%",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _percentColor(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (_roleLabel != null) ...[
                      const SizedBox(height: 6),
                      _RoleBadge(
                        label: _roleLabel!,
                        color: roleColor,
                        isFilled: ThemeState().isLightTheme && _isOwner,
                      ),
                    ],
                    _buildFieldHighlights(context),
                    if (canLeave && onLeave != null) ...[
                      const SizedBox(height: 8),
                      UydoshLinkButton(
                        text: L10n.get("group_leave_group"),
                        onPressed: onLeave!,
                        color: AppColors.error,
                        icon: Icons.logout_rounded,
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ],
                ),
              ),
              ThemeIcon(
                Icons.chevron_right,
                size: 22,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
              ),
            ],
          ),
        ),
      ),
    );

    final visibleCard = highlightCurrentUser
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.45),
                width: 1.5,
              ),
            ),
            child: card,
          )
        : card;

    if (!canRemove || onRemove == null) return visibleCard;

    return Dismissible(
      key: ValueKey("member-remove-swipe-${member.userId}"),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedbackUtils.impact();
        await onRemove!.call();
        return false;
      },
      background: _buildRemoveSwipeBackground(context),
      child: visibleCard,
    );
  }
}

class _PendingJoinRequestCard extends StatelessWidget {
  const _PendingJoinRequestCard({
    required this.request,
    required this.isBusy,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
    this.compatibility,
  });

  final ListingGroupJoinRequest request;
  final GroupMemberCompatibilitySummary? compatibility;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  Color _percentColor(BuildContext context) {
    final percent = compatibility?.percent;
    if (percent == null) return Theme.of(context).colorScheme.onSurfaceVariant;
    if (percent >= 80) {
      return ThemeState().isLightTheme
          ? AppColors.successDark
          : AppColors.success;
    }
    if (percent >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Color _highlightColor(ProfileMatchFieldStatus status) {
    switch (status) {
      case ProfileMatchFieldStatus.match:
        return ThemeState().isLightTheme
            ? AppColors.successDark
            : AppColors.success;
      case ProfileMatchFieldStatus.difference:
        return ThemeState().isLightTheme
            ? AppColors.warningDark
            : AppColors.warning;
      case ProfileMatchFieldStatus.dealbreaker:
        return AppColors.error;
      case ProfileMatchFieldStatus.incomplete:
        return AppColors.iconPrimary;
    }
  }

  String _highlightSemanticsLabel(MemberCompatibilityFieldHighlight highlight) {
    final fieldLabel = L10n.get(highlight.labelKey);
    final statusLabel = switch (highlight.status) {
      ProfileMatchFieldStatus.match => L10n.get("group_member_compat_match"),
      ProfileMatchFieldStatus.difference =>
        L10n.get("group_member_compat_difference"),
      ProfileMatchFieldStatus.dealbreaker =>
        L10n.get("group_member_compat_dealbreaker"),
      ProfileMatchFieldStatus.incomplete => "",
    };
    return "$fieldLabel: $statusLabel";
  }

  Widget _buildFieldHighlights(BuildContext context) {
    final highlights = compatibility?.fieldHighlights ?? const [];
    if (highlights.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final highlight in highlights)
            Semantics(
              label: _highlightSemanticsLabel(highlight),
              child: Tooltip(
                message: _highlightSemanticsLabel(highlight),
                child: Container(
                  width: 29,
                  height: 29,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _highlightColor(highlight.status)
                        .withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _highlightColor(highlight.status)
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  child: ThemeIcon(
                    ProfileCompatibilityFieldIcons.iconFor(highlight.labelKey),
                    size: 16,
                    color: _highlightColor(highlight.status),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final themeState = ThemeState();
    const avatarSize = 48.0;
    final avatarUrl = resolveAvatarUrl(request.applicantAvatar);
    final initials = StringUtils.extractInitials(request.applicantName);
    final message = request.message?.trim();

    final avatarFallback = CircleAvatar(
      backgroundColor: themeState.avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          color: themeState.avatarIconColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      useLiquidGlass: true,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: avatarUrl != null
                    ? NetworkAvatarImage(
                        imageUrl: avatarUrl,
                        size: avatarSize,
                        fallback: SizedBox(
                          width: avatarSize,
                          height: avatarSize,
                          child: avatarFallback,
                        ),
                      )
                    : SizedBox(
                        width: avatarSize,
                        height: avatarSize,
                        child: avatarFallback,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.applicantName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (compatibility?.percent != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            "${compatibility!.percent}%",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _percentColor(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    _RoleBadge(
                      label: L10n.get("group_member_role_pending_request"),
                      color: ThemeState().isLightTheme
                          ? AppColors.warningDark
                          : AppColors.warning,
                    ),
                    _buildFieldHighlights(context),
                    if (message != null && message.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    AbsorbPointer(
                      absorbing: isBusy,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          UydoshLinkButton(
                            text: L10n.get("group_reject_member"),
                            onPressed: onReject,
                            color: AppColors.error,
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                          const SizedBox(width: 16),
                          UydoshLinkButton(
                            text: L10n.get("group_approve_member"),
                            onPressed: onApprove,
                            color: AppColors.success,
                            padding: EdgeInsets.zero,
                            alignment: Alignment.centerLeft,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                ThemeIcon(
                  Icons.chevron_right,
                  size: 22,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.label,
    required this.color,
    this.isFilled = false,
  });

  final String label;
  final Color color;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isFilled ? Colors.black : color.withValues(alpha: 0.12);
    final foregroundColor = isFilled ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isFilled ? Colors.black : color.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.1,
        ),
      ),
    );
  }
}
