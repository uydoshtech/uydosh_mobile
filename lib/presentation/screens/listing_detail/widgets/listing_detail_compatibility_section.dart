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
import "package:uy_dosh/presentation/screens/listing_detail/profile_compatibility_field_icons.dart";
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
    this.groupPreferenceMatrix = const [],
    this.currentUserId,
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
  final List<GroupPreferenceMatrixRow> groupPreferenceMatrix;
  final int? currentUserId;

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

    final target =
        (viewport.getOffsetToReveal(renderObject, 0.0).offset - topInset)
            .clamp(position.minScrollExtent, position.maxScrollExtent);

    if ((target - position.pixels).abs() < 2) return;
    position.animateTo(target, duration: duration, curve: curve);
  }

  static IconData _getLifestyleIcon(String labelKey) =>
      ProfileCompatibilityFieldIcons.iconFor(labelKey);

  static Widget? _buildMatrixValueIcon(
    String iconKey, {
    required Color color,
  }) {
    final parts = iconKey.split(":");
    if (parts.length != 2) return null;
    final category = parts.first;
    final value = parts.last;

    Widget singleIcon(IconData icon) => Icon(icon, size: 18, color: color);

    Widget repeatedIcon(IconData icon, int count) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: [
          for (var i = 0; i < count; i++) Icon(icon, size: 12, color: color),
        ],
      );
    }

    Widget ratingDots(int count) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 1; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(
                Icons.circle,
                size: 10,
                color: color.withValues(alpha: i <= count ? 0.9 : 0.25),
              ),
            ),
        ],
      );
    }

    int? ratingValue() {
      final parsed = int.tryParse(value);
      if (parsed == null) return null;
      return parsed.clamp(1, 5).toInt();
    }

    switch (category) {
      case "day":
        switch (value) {
          case "morning":
            return singleIcon(Icons.wb_sunny);
          case "evening":
            return singleIcon(Icons.schedule);
          case "night":
            return singleIcon(Icons.nights_stay);
        }
        return null;
      case "smoking":
        switch (value) {
          case "non-smoker":
            return singleIcon(Icons.smoke_free);
          case "occasional":
            return singleIcon(Icons.smoking_rooms);
          case "regular":
            return repeatedIcon(Icons.smoking_rooms, 2);
        }
        return null;
      case "pets":
        switch (value) {
          case "dont_like_pets":
            return singleIcon(Icons.block);
          case "like_pets":
          case "have_cat":
          case "have_dog":
            return singleIcon(Icons.pets);
        }
        return null;
      case "cleanliness":
      case "noise":
      case "sociability":
        final count = ratingValue();
        return count == null ? null : ratingDots(count);
      case "alcohol":
        switch (value) {
          case "non-drinker":
            return singleIcon(Icons.block);
          case "occasional":
            return singleIcon(Icons.local_bar);
          case "regular":
            return repeatedIcon(Icons.local_bar, 2);
        }
        return null;
      case "guests":
        return singleIcon(value == "yes" ? Icons.check : Icons.close);
      case "cooking":
        return singleIcon(value == "yes" ? Icons.restaurant : Icons.close);
    }

    return null;
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
        const SizedBox(height: 6),
        _buildGroupHeaderAvatars(),
      ],
    );
  }

  Widget _buildGroupPreferenceMatrix() {
    if (widget.groupMembers.length < 3 ||
        widget.groupPreferenceMatrix.isEmpty) {
      return const SizedBox.shrink();
    }

    final textColor = _getDescriptionTextColor();
    final borderColor = textColor.withValues(alpha: 0.12);
    final isLightTheme = ThemeState().isLightTheme;
    final notSpecifiedLabel = L10n.get("not_specified");
    final fallbackUserLabel = L10n.get("user");
    final orderedUserIds = widget.groupMembers
        .map((member) => member.userId)
        .toList(growable: false);
    final memberByUserId = {
      for (final member in widget.groupMembers) member.userId: member,
    };
    final cellsByRowAndUserId = {
      for (final row in widget.groupPreferenceMatrix)
        row: {
          for (final cell in row.cells) cell.userId: cell,
        },
    };

    ConversationMemberSummary? memberFor(int userId) {
      return memberByUserId[userId];
    }

    String memberName(int userId) {
      final member = memberFor(userId);
      final name = member?.name.trim();
      if (name == null || name.isEmpty) return fallbackUserLabel;

      final parts = name.split(RegExp(r"\s+"));
      if (parts.length < 2) return name;

      return "${parts.first} ${parts.last.characters.first}.";
    }

    Widget tableCell({
      required Widget child,
      bool isHeader = false,
      bool isLast = false,
      Alignment alignment = Alignment.center,
      Color? fillColor,
    }) {
      return Expanded(
        child: Container(
          constraints: BoxConstraints(minHeight: isHeader ? 76 : 48),
          alignment: alignment,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            color: fillColor,
            border: Border(
              right: isLast ? BorderSide.none : BorderSide(color: borderColor),
              bottom: BorderSide(color: borderColor),
            ),
          ),
          child: child,
        ),
      );
    }

    Color? statusColor(GroupPreferenceMatrixCellStatus status) {
      switch (status) {
        case GroupPreferenceMatrixCellStatus.fullMatch:
        case GroupPreferenceMatrixCellStatus.partialMatch:
          return isLightTheme ? AppColors.successDark : AppColors.success;
        case GroupPreferenceMatrixCellStatus.mismatch:
          return isLightTheme ? AppColors.warningDark : AppColors.warning;
        case GroupPreferenceMatrixCellStatus.conflict:
          return AppColors.error;
        case GroupPreferenceMatrixCellStatus.missing:
          return null;
      }
    }

    GroupPreferenceMatrixCellStatus resolveRowStatus(
      GroupPreferenceMatrixRow row,
    ) {
      var hasStatus = false;
      var hasPartialMatch = false;
      for (final cell in row.cells) {
        final status = cell.status;
        if (status == GroupPreferenceMatrixCellStatus.missing) continue;
        hasStatus = true;
        if (status == GroupPreferenceMatrixCellStatus.conflict) {
          return GroupPreferenceMatrixCellStatus.conflict;
        }
        if (status == GroupPreferenceMatrixCellStatus.mismatch) {
          return GroupPreferenceMatrixCellStatus.mismatch;
        }
        if (status == GroupPreferenceMatrixCellStatus.partialMatch) {
          hasPartialMatch = true;
        }
      }

      if (!hasStatus) return GroupPreferenceMatrixCellStatus.missing;
      if (hasPartialMatch) {
        return GroupPreferenceMatrixCellStatus.partialMatch;
      }
      return GroupPreferenceMatrixCellStatus.fullMatch;
    }

    final rowStatusByRow = {
      for (final row in widget.groupPreferenceMatrix)
        row: resolveRowStatus(row),
    };

    GroupPreferenceMatrixCell? cellFor(
      GroupPreferenceMatrixRow row,
      int userId,
    ) {
      return cellsByRowAndUserId[row]?[userId];
    }

    GroupPreferenceMatrixCellStatus rowStatus(GroupPreferenceMatrixRow row) {
      return rowStatusByRow[row] ?? GroupPreferenceMatrixCellStatus.missing;
    }

    Widget valueText(
      String value, {
      GroupPreferenceMatrixCellStatus status =
          GroupPreferenceMatrixCellStatus.missing,
    }) {
      final isMissing = value == notSpecifiedLabel;
      final accentColor = statusColor(status);
      return Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: orderedUserIds.length >= 5 ? 11 : 12,
          fontWeight: isMissing ? FontWeight.w400 : FontWeight.w600,
          color: isMissing
              ? textColor.withValues(alpha: 0.55)
              : (accentColor ?? textColor).withValues(alpha: 0.9),
        ),
      );
    }

    Widget iconValueCell(
      GroupPreferenceMatrixRow row,
      int userId, {
      GroupPreferenceMatrixCell? cell,
    }) {
      cell ??= cellFor(row, userId);
      final value = cell?.value ?? notSpecifiedLabel;
      final status = cell?.status ?? GroupPreferenceMatrixCellStatus.missing;
      final iconKey = cell?.valueIconKey;
      if (iconKey == null || value == notSpecifiedLabel) {
        return valueText(value, status: status);
      }

      final visual = _buildMatrixValueIcon(
        iconKey,
        color: textColor.withValues(alpha: 0.9),
      );
      if (visual == null) return valueText(value, status: status);

      return Tooltip(
        message: value,
        child: Semantics(
          label: "${row.label}: $value",
          child: ExcludeSemantics(child: visual),
        ),
      );
    }

    Widget matrixRowHeader(GroupPreferenceMatrixRow row) {
      final accentColor = statusColor(rowStatus(row));

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: accentColor?.withValues(alpha: 0.08),
          border: Border(
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Row(
          children: [
            ThemeIcon(
              _getLifestyleIcon(row.labelKey),
              size: 18,
              color: (accentColor ?? textColor).withValues(
                alpha: 0.85,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor ?? textColor,
                    ),
                  ),
                  if (row.alignmentSummary != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      row.alignmentSummary!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: (accentColor ?? textColor).withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget matrixValueTableCell(
      GroupPreferenceMatrixRow row,
      int index,
    ) {
      final userId = orderedUserIds[index];
      final cell = cellFor(row, userId);
      final status =
          cell?.status ?? GroupPreferenceMatrixCellStatus.missing;
      final accentColor = statusColor(status);

      return tableCell(
        isLast: index == orderedUserIds.length - 1,
        fillColor: accentColor?.withValues(alpha: 0.08),
        child: iconValueCell(row, userId, cell: cell),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ThemeIcon(
                Icons.table_chart_outlined,
                size: 20,
                color: textColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L10n.get("group_preference_matrix_title"),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            L10n.get("group_preference_matrix_subtitle"),
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < orderedUserIds.length; i++)
                        tableCell(
                          isHeader: true,
                          isLast: i == orderedUserIds.length - 1,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHeaderAvatar(
                                memberFor(orderedUserIds[i])?.avatarUrl,
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                memberName(orderedUserIds[i]),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize:
                                      orderedUserIds.length >= 5 ? 11 : 12,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  for (final row in widget.groupPreferenceMatrix) ...[
                    matrixRowHeader(row),
                    Row(
                      children: [
                        for (var i = 0; i < orderedUserIds.length; i++)
                          matrixValueTableCell(row, i),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
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
                        color:
                            _getDescriptionTextColor().withValues(alpha: 0.75),
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
          icon: Icons.warning_amber_rounded,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupPreferenceMatrix(),
        if (widget.groupPreferenceMatrix.isEmpty)
          UydoshLinkButton(
            text: L10n.get("complete_profile"),
            onPressed: widget.onCompleteProfile,
            color: _getIconColor(),
            outlined: true,
            maxLines: 1,
          ),
        const SizedBox(height: 14),
        _buildGroupCompatibilitySummaryBar(),
      ],
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
                  if (!widget.isGroupCompatibility)
                    _buildOverlappingHeaderAvatars(),
                  if (!widget.isGroupCompatibility) const SizedBox(width: 10),
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
                  final phoneDisplay = hasPhone
                      ? _formatUzbekPhoneDisplay(widget.phoneNumber!)
                      : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
