import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "dart:async";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/config/client_listing_contacts_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_group_compatibility_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

/// Data class for a compatibility match (same value).
class CompatibilityMatch {
  const CompatibilityMatch({
    required this.labelKey,
    required this.label,
    required this.value,
  });

  final String labelKey;
  final String label;
  final String value;
}

/// Data class for a compatibility difference (user vs owner).
class CompatibilityDifference {
  const CompatibilityDifference({
    required this.labelKey,
    required this.label,
    required this.currentText,
    required this.ownerText,
  });

  final String labelKey;
  final String label;
  final String currentText;
  final String ownerText;
}

/// Compatibility section widget for listing detail screen.
/// Shows match percentage and expandable list of matches/differences.
class ListingDetailCompatibilitySection extends StatefulWidget {
  const ListingDetailCompatibilitySection({
    required this.listingDetail,
    required this.scrollController,
    required this.sectionKey,
    required this.compatibilityPercent,
    required this.isLoadingCompatibility,
    required this.compatibilityError,
    required this.matches,
    required this.differences,
    required this.dealbreakers,
    required this.scoredFieldCount,
    required this.totalFieldCount,
    required this.telegramHandle,
    required this.phoneNumber,
    required this.onTelegram,
    required this.onPhone,
    required this.onViewProfile,
    required this.onCompleteProfile,
    this.currentUserAvatarUrl,
    this.ownerAvatarUrl,
    this.isGroupCompatibility = false,
    this.groupMembers = const [],
    this.groupFullMatches = const [],
    this.groupPartialMatches = const [],
    this.groupDiscussItems = const [],
    this.currentUserId,
    this.onViewMemberProfile,
    super.key,
  });

  final ListingDetail listingDetail;
  final ScrollController scrollController;
  final GlobalKey sectionKey;
  final int? compatibilityPercent;
  final bool isLoadingCompatibility;
  final String? compatibilityError;
  final List<CompatibilityMatch> matches;
  final List<CompatibilityDifference> differences;
  final List<CompatibilityDifference> dealbreakers;
  final int scoredFieldCount;
  final int totalFieldCount;
  final String? telegramHandle;
  final String? phoneNumber;
  final VoidCallback? onTelegram;
  final VoidCallback? onPhone;
  final VoidCallback onViewProfile;
  final VoidCallback onCompleteProfile;
  final String? currentUserAvatarUrl;
  final String? ownerAvatarUrl;
  final bool isGroupCompatibility;
  final List<ConversationMemberSummary> groupMembers;
  final List<GroupCompatibilityFullMatch> groupFullMatches;
  final List<GroupCompatibilityPartialMatch> groupPartialMatches;
  final List<GroupCompatibilityDiscussItem> groupDiscussItems;
  final int? currentUserId;
  final void Function(int userId)? onViewMemberProfile;

  @override
  State<ListingDetailCompatibilitySection> createState() =>
      _ListingDetailCompatibilitySectionState();
}

class _ListingDetailCompatibilitySectionState
    extends State<ListingDetailCompatibilitySection> {
  Timer? _scrollIntoViewTimer;

  @override
  void dispose() {
    _scrollIntoViewTimer?.cancel();
    super.dispose();
  }

  /// Extra scroll offset so the section header lands below the app bar when
  /// [Scaffold.extendBodyBehindAppBar] is active (blue / light themes).
  static double _listingDetailScrollTopInset(BuildContext ctx) {
    final themeState = ThemeState();
    final useLiquidGlassAppBar =
        themeState.isBlueTheme || themeState.isLightTheme;
    if (!useLiquidGlassAppBar) return 0;
    return MediaQuery.paddingOf(ctx).top + kToolbarHeight;
  }

  static void _maybeAnimateScrollIntoView(
    BuildContext ctx, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    final scrollable = Scrollable.maybeOf(ctx);
    final position = scrollable?.position;
    if (position == null) return;

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final topInset = _listingDetailScrollTopInset(ctx);

    final target = (viewport
                .getOffsetToReveal(renderObject, 0.0)
                .offset -
            topInset)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    if ((target - position.pixels).abs() < 2) return;
    position.animateTo(target, duration: duration, curve: curve);
  }

  static IconData _getLifestyleIcon(String labelKey) {
    switch (labelKey) {
      case "wakeup_time":
        return Icons.wb_sunny;
      case "sleep_time":
        return Icons.bedtime;
      case "work":
      case "employed":
        return Icons.work;
      case "cleanliness":
        return Icons.cleaning_services;
      case "noise_level":
        return Icons.volume_up;
      case "sociability":
        return Icons.people;
      case "guests":
      case "guests_allowed":
        return Icons.group_add;
      case "smoking_preference":
        return Icons.smoking_rooms;
      case "alcohol_preference":
        return Icons.local_bar;
      case "cooking_habits":
        return Icons.restaurant;
      case "pets_preference":
        return Icons.pets;
      case "same_region":
      case "region":
        return Icons.location_on;
      case "language":
        return CupertinoIcons.globe;
      case "same_university":
      case "both_students":
      case "university":
        return Icons.school;
      default:
        return Icons.info_outline;
    }
  }

  String _formatUzbekPhoneDisplay(String raw) {
    final d = raw.replaceAll(RegExp(r"\D"), "");
    // Handle +998XXXXXXXXX, 998XXXXXXXXX, or 9XXXXXXXX
    String? nine;
    if (d.startsWith("998") && d.length >= 12) {
      final rest = d.substring(3);
      if (rest.length >= 9 &&
          RegExp(r"^9[0134679]\d{7}$").hasMatch(rest.substring(0, 9))) {
        nine = rest.substring(0, 9);
      }
    } else if (d.startsWith("9") &&
        d.length >= 9 &&
        RegExp(r"^9[0134679]\d{7}$").hasMatch(d.substring(0, 9))) {
      nine = d.substring(0, 9);
    } else if (d.length == 9 && RegExp(r"^9[0134679]\d{7}$").hasMatch(d)) {
      nine = d;
    } else if (d.length > 9) {
      final m = RegExp(r"(9[0134679]\d{7})$").firstMatch(d);
      nine = m?.group(1);
    }

    if (nine == null || nine.length != 9) return raw.trim();
    return "+998 ${nine.substring(0, 2)} ${nine.substring(2, 5)} "
        "${nine.substring(5, 7)} ${nine.substring(7, 9)}";
  }

  Color _getDescriptionTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87;
    }
  }

  Color _getLocationTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87;
    }
  }

  Color _getIconColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    } else if (ThemeState().isLightTheme) {
      return Colors.black;
    } else {
      return AppColors.iconPrimary;
    }
  }

  Color _getCompatibilityPercentColor() {
    if (widget.compatibilityPercent == null) return _getDescriptionTextColor();
    if (widget.compatibilityPercent! >= 80) {
      return ThemeState().isLightTheme
          ? AppColors.successDark
          : AppColors.success;
    }
    if (widget.compatibilityPercent! >= 60) return AppColors.warning;
    return AppColors.error;
  }

  bool get _useCompactGroupSections => ThemeState().isLightTheme;

  IconData _groupSectionHeaderIcon(_GroupSectionKind kind) {
    switch (kind) {
      case _GroupSectionKind.full:
        return Icons.check;
      case _GroupSectionKind.partial:
        return Icons.waves;
      case _GroupSectionKind.discuss:
        return Icons.warning_amber_rounded;
    }
  }

  int _partialSectionAgreeCount() {
    if (widget.groupPartialMatches.isEmpty) return 0;
    return widget.groupPartialMatches
        .map((item) => item.agreeCount)
        .reduce((a, b) => a > b ? a : b);
  }

  Widget _buildHeaderAvatar(String? avatarUrl, {required double size}) {
    final resolvedUrl = resolveAvatarUrl(avatarUrl);
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ThemeIcon(
        Icons.person_outline,
        size: size * 0.45,
        color: _getIconColor(),
      ),
    );

    if (resolvedUrl == null) {
      return fallback;
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: NetworkAvatarImage(
          imageUrl: resolvedUrl,
          size: size,
          fallback: fallback,
        ),
      ),
    );
  }

  Widget _buildGroupHeaderAvatars() {
    return ChatParticipantAvatarStack(
      participants: widget.groupMembers,
      currentUserId: widget.currentUserId,
      avatarSize: 32,
      maxVisible: 5,
    );
  }

  Widget _buildGroupHeaderTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L10n.get("group_compatibility_title"),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _getDescriptionTextColor(),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          L10n.getWithParams(
            "group_compatibility_subtitle",
            params: {"count": widget.groupMembers.length.toString()},
          ),
          style: TextStyle(
            fontSize: 13,
            color: _getDescriptionTextColor().withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupFieldRow({
    required String labelKey,
    required String label,
    required String value,
  }) {
    final iconColor = _useCompactGroupSections
        ? _getIconColor()
        : _getDescriptionTextColor();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ThemeIcon(
            _getLifestyleIcon(labelKey),
            size: 20,
            color: iconColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(
                fontSize: 14,
                color: _getDescriptionTextColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupSectionHeader({
    required String title,
    required Color accentColor,
    required _GroupSectionKind kind,
  }) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: ThemeIcon(
            _groupSectionHeaderIcon(kind),
            size: 14,
            color: Colors.white,
            useThemeColor: false,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupSection({
    required String title,
    required Color accentColor,
    required _GroupSectionKind kind,
    required List<Widget> children,
  }) {
    if (children.isEmpty) return const SizedBox.shrink();

    final sectionFillAlpha = _useCompactGroupSections ? 0.12 : 0.04;
    final sectionBorderColor = _useCompactGroupSections
        ? accentColor.withValues(alpha: 0.45)
        : _getDescriptionTextColor().withValues(alpha: 0.14);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _useCompactGroupSections
            ? accentColor.withValues(alpha: sectionFillAlpha)
            : _getDescriptionTextColor().withValues(alpha: sectionFillAlpha),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sectionBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroupSectionHeader(
            title: title,
            accentColor: accentColor,
            kind: kind,
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildGroupCompatibilitySummaryBar() {
    final fullCount = widget.groupFullMatches.length;
    final partialCount = widget.groupPartialMatches.length;
    final discussCount = widget.groupDiscussItems.length;
    if (fullCount + partialCount + discussCount == 0) {
      return const SizedBox.shrink();
    }

    Widget statColumn({
      required IconData icon,
      required int count,
      required Color color,
      required String label,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: ThemeIcon(
                  icon,
                  size: 14,
                  color: Colors.white,
                  useThemeColor: false,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: _getDescriptionTextColor(),
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        color: _getDescriptionTextColor().withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final columns = <Widget>[
      if (fullCount > 0)
        statColumn(
          icon: Icons.check,
          count: fullCount,
          color: AppColors.success,
          label: L10n.get("group_compatibility_summary_full"),
        ),
      if (partialCount > 0)
        statColumn(
          icon: Icons.waves,
          count: partialCount,
          color: AppColors.warning,
          label: L10n.get("group_compatibility_summary_partial"),
        ),
      if (discussCount > 0)
        statColumn(
          icon: Icons.warning_amber_rounded,
          count: discussCount,
          color: AppColors.error,
          label: L10n.get("group_compatibility_summary_discuss"),
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: _getDescriptionTextColor().withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getDescriptionTextColor().withValues(alpha: 0.12),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: _getDescriptionTextColor().withValues(alpha: 0.15),
                  ),
                ),
              columns[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCompatibilityBody() {
    final memberCount = widget.groupMembers.length;
    final scoredPreferenceCount = widget.scoredFieldCount > 0
        ? widget.scoredFieldCount
        : widget.groupFullMatches.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.scoredFieldCount > 0 &&
            widget.scoredFieldCount < widget.totalFieldCount)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              L10n.getWithParams(
                "compatibility_based_on_preferences",
                params: {
                  "scored": widget.scoredFieldCount.toString(),
                  "total": widget.totalFieldCount.toString(),
                },
              ),
              style: TextStyle(
                fontSize: 13,
                color: _getDescriptionTextColor().withValues(alpha: 0.85),
              ),
            ),
          ),
        _buildGroupSection(
          title: L10n.getWithParams(
            "group_compatibility_full_matches",
            params: {
              "count": widget.groupFullMatches.length.toString(),
              "total": scoredPreferenceCount.toString(),
            },
          ),
          accentColor: AppColors.success,
          kind: _GroupSectionKind.full,
          children: widget.groupFullMatches
              .map(
                (item) => _buildGroupFieldRow(
                  labelKey: item.labelKey,
                  label: item.label,
                  value: item.value,
                ),
              )
              .toList(),
        ),
        _buildGroupSection(
          title: L10n.getWithParams(
            "group_compatibility_partial_matches",
            params: {
              "count": _partialSectionAgreeCount().toString(),
              "total": memberCount.toString(),
            },
          ),
          accentColor: AppColors.warning,
          kind: _GroupSectionKind.partial,
          children: widget.groupPartialMatches
              .map(
                (item) => _buildGroupFieldRow(
                  labelKey: item.labelKey,
                  label: item.label,
                  value: item.value,
                ),
              )
              .toList(),
        ),
        _buildGroupSection(
          title: L10n.get("group_compatibility_discuss"),
          accentColor: AppColors.error,
          kind: _GroupSectionKind.discuss,
          children: widget.groupDiscussItems
              .map(
                (item) => _buildGroupFieldRow(
                  labelKey: item.labelKey,
                  label: item.label,
                  value: item.summary,
                ),
              )
              .toList(),
        ),
        if (widget.groupFullMatches.isEmpty &&
            widget.groupPartialMatches.isEmpty &&
            widget.groupDiscussItems.isEmpty)
          UydoshLinkButton(
            text: L10n.get("complete_profile"),
            onPressed: widget.onCompleteProfile,
            color: _getIconColor(),
            outlined: true,
            maxLines: 1,
          ),
        if (widget.onViewMemberProfile != null) ...[
          const SizedBox(height: 14),
          GhostButtonFactory.iconText(
            onPressed: () {
              HapticFeedbackUtils.impact();
              _showMemberProfilesSheet(context);
            },
            width: double.infinity,
            icon: Icons.group_outlined,
            iconSize: 18,
            text: L10n.get("view_member_profiles"),
            padding: const EdgeInsets.symmetric(vertical: 12),
            borderColor: _getIconColor(),
            textColor: _getDescriptionTextColor(),
            iconColor: _getIconColor(),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 14),
        _buildGroupCompatibilitySummaryBar(),
      ],
    );
  }

  void _showMemberProfilesSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: widget.groupMembers.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final member = widget.groupMembers[index];
              return ListTile(
                leading: _buildHeaderAvatar(member.avatarUrl, size: 40),
                title: Text(member.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(ctx).pop();
                  widget.onViewMemberProfile?.call(member.userId);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOverlappingHeaderAvatars() {
    const size = 32.0;
    const overlap = 8.0;
    final borderColor = Theme.of(context).colorScheme.surface;

    Widget borderedAvatar(String? avatarUrl) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: _buildHeaderAvatar(avatarUrl, size: size),
      );
    }

    return SizedBox(
      width: size * 2 - overlap,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            child: borderedAvatar(widget.currentUserAvatarUrl),
          ),
          Positioned(
            left: size - overlap,
            child: borderedAvatar(widget.ownerAvatarUrl),
          ),
        ],
      ),
    );
  }

  void _onExpansionChanged(bool isExpanded) {
    HapticFeedbackUtils.impact();
    if (!isExpanded) return;

    // Measure the 350ms from a settled layout (after the tap's frame has
    // flushed), matching the pattern in [ListingDetailMapSection] that fixed
    // the same scroll-jitter there. Starting the Timer mid-frame and then
    // awaiting `endOfFrame` inside it schedules an extra frame that shifts
    // layout *between* our target calculation and the scroll animation,
    // producing the visible "up then back down" jerk.
    //
    // Cancelling the pending Timer still protects against rapid
    // expand/collapse queuing multiple scroll adjustments.
    _scrollIntoViewTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollIntoViewTimer = Timer(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        final ctx = widget.sectionKey.currentContext;
        if (ctx == null || !ctx.mounted) return;
        _maybeAnimateScrollIntoView(ctx);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = AuthenticationState().isAuthenticated;
    final isOwner = UserListingState().isOwner(widget.listingDetail.user.id);
    final isGroupForming =
        ListingGroupProgress.isGroupFormingDetail(widget.listingDetail);

    // One-on-one compatibility is viewer vs owner; group compatibility is about
    // the whole forming group — owners need that section too (including while
    // group scores are still loading and [isGroupCompatibility] is false).
    if (isOwner && !isGroupForming && !widget.isGroupCompatibility) {
      return const SizedBox.shrink();
    }

    final percentText = widget.compatibilityPercent == null
        ? null
        : AppStrings.getWithParams(
            "compatibility_match_percentage",
            LanguageState().currentLanguage,
            params: {"percent": widget.compatibilityPercent!.toString()},
          );
    final headerPercentText = widget.compatibilityPercent == null
        ? L10n.get("na")
        : "${widget.compatibilityPercent}%";

    final isProfileComplete = ProfileCompletionState().isProfileComplete;

    final chevronColor = ListingDetailThemeHelper.locationTextColor;

    return ListingDetailTileShell(
      useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          initiallyExpanded: !isAuthenticated || !isProfileComplete,
          onExpansionChanged: _onExpansionChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.transparent),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.transparent),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: chevronColor,
          collapsedIconColor: chevronColor,
          title: KeyedSubtree(
            key: widget.sectionKey,
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isAuthenticated) ...[
                if (widget.isGroupCompatibility)
                  _buildGroupHeaderAvatars()
                else
                  _buildOverlappingHeaderAvatars(),
                const SizedBox(width: 10),
              ] else
                ThemeIcon(
                  ThemeState().isBlueTheme
                      ? CupertinoIcons.group_solid
                      : CupertinoIcons.group,
                  size: 24,
                  color: ThemeState().isBlueTheme
                      ? Colors.white
                      : ThemeState().isLightTheme
                          ? Colors.black
                          : _getIconColor(),
                ),
              if (!isAuthenticated) const SizedBox(width: 8),
              Expanded(
                child: widget.isGroupCompatibility && isAuthenticated
                    ? _buildGroupHeaderTitle()
                    : Text(
                        L10n.get("compatibility_title"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getDescriptionTextColor(),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              if (isAuthenticated) ...[
                const SizedBox(width: 8),
                Text(
                  headerPercentText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _getCompatibilityPercentColor(),
                  ),
                ),
              ],
            ],
            ),
          ),
          children: [
            if (!isAuthenticated)
              Text(
                L10n.get("compatibility_sign_in"),
                style: TextStyle(
                  fontSize: 14,
                  color: _getDescriptionTextColor(),
                ),
              )
            else if (widget.isLoadingCompatibility)
              Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _getIconColor(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    L10n.get("compatibility_calculating"),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getDescriptionTextColor(),
                    ),
                  ),
                ],
              )
            else if (widget.compatibilityError != null || percentText == null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UydoshLinkButton(
                    text: L10n.get("complete_profile"),
                    onPressed: widget.onCompleteProfile,
                    color: _getIconColor(),
                    outlined: true,
                    maxLines: 1,
                  ),
                ],
              )
            else
              ValueListenableBuilder<bool>(
                valueListenable:
                    ClientListingContactsConfig.showListingContacts,
                builder: (context, showContacts, _) {
                  if (widget.isGroupCompatibility) {
                    return _buildGroupCompatibilityBody();
                  }

                  final hasPhone = showContacts &&
                      (widget.phoneNumber?.trim().isNotEmpty ?? false) &&
                      widget.onPhone != null;
                  final phoneDisplay =
                      hasPhone
                          ? _formatUzbekPhoneDisplay(widget.phoneNumber!)
                          : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.scoredFieldCount > 0 &&
                          widget.scoredFieldCount < widget.totalFieldCount)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            L10n.getWithParams(
                              "compatibility_based_on_preferences",
                              params: {
                                "scored": widget.scoredFieldCount.toString(),
                                "total": widget.totalFieldCount.toString(),
                              },
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: _getDescriptionTextColor().withValues(
                                alpha: 0.85,
                              ),
                            ),
                          ),
                        ),
                      if (widget.dealbreakers.isNotEmpty) ...[
                        Text(
                          L10n.get("compatibility_critical_differences"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.dealbreakers.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ThemeIcon(
                                  _getLifestyleIcon(item.labelKey),
                                  size: 20,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.error,
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${item.label}: ${item.currentText} ",
                                        ),
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: ThemeIcon(
                                            Icons.compare_arrows,
                                            size: 16,
                                            color: AppColors.error,
                                          ),
                                        ),
                                        TextSpan(text: " ${item.ownerText}"),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (widget.matches.isNotEmpty) ...[
                        Text(
                          L10n.get("compatibility_matches"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getLocationTextColor(),
                            decoration: TextDecoration.underline,
                            decorationColor: _getLocationTextColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.matches.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ThemeIcon(
                                  _getLifestyleIcon(item.labelKey),
                                  size: 20,
                                  color: _getDescriptionTextColor(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "${item.label}: ${item.value}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _getDescriptionTextColor(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (widget.differences.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          L10n.get("compatibility_differences"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _getLocationTextColor(),
                            decoration: TextDecoration.underline,
                            decorationColor: _getLocationTextColor(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...widget.differences.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ThemeIcon(
                                  _getLifestyleIcon(item.labelKey),
                                  size: 20,
                                  color: _getDescriptionTextColor(),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _getDescriptionTextColor(),
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${item.label}: ${item.currentText} ",
                                        ),
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: ThemeIcon(
                                            Icons.compare_arrows,
                                            size: 16,
                                            color: _getDescriptionTextColor(),
                                          ),
                                        ),
                                        TextSpan(text: " ${item.ownerText}"),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (widget.matches.isEmpty &&
                          widget.differences.isEmpty &&
                          widget.dealbreakers.isEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UydoshLinkButton(
                              text: L10n.get("complete_profile"),
                              onPressed: widget.onCompleteProfile,
                              color: _getIconColor(),
                              outlined: true,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      // Telegram / in-app chat CTAs live in the sticky
                      // [ListingDetailContactActionBar] at the bottom of the
                      // screen (always reachable). Phone stays here because
                      // it's a compat-adjacent conditional contact channel
                      // (gated by admin flag + handle presence) and it's the
                      // only inline contact we still surface in-section.
                      if (hasPhone) ...[
                        const SizedBox(height: 16),
                        GhostButton(
                          onPressed: () {
                            HapticFeedbackUtils.impact();
                            widget.onPhone?.call();
                          },
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          borderWidth: 1.5,
                          borderColor: _getIconColor(),
                          textColor: _getDescriptionTextColor(),
                          iconColor: _getIconColor(),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ThemeIcon(
                                Icons.phone,
                                size: 18,
                                color: _getIconColor(),
                              ),
                              const SizedBox(width: 8),
                              Text(phoneDisplay ?? L10n.get("contact_user")),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      GhostButtonFactory.iconText(
                        onPressed: () {
                          HapticFeedbackUtils.impact();
                          widget.onViewProfile();
                        },
                        width: double.infinity,
                        icon: Icons.person_outline,
                        iconSize: 18,
                        text: L10n.get("view_profile"),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        borderColor: _getIconColor(),
                        textColor: _getDescriptionTextColor(),
                        iconColor: _getIconColor(),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

enum _GroupSectionKind { full, partial, discuss }
