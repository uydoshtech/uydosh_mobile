import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/pending_listing_moderation_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/services/listing_moderation_admin_service.dart";
import "package:uy_dosh/presentation/screens/admin/admin_listing_parser_review_screen.dart";
import "package:uy_dosh/presentation/widgets/common/button_icon_label.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

sealed class _QueueListItem {}

final class _MonthHeaderItem extends _QueueListItem {
  _MonthHeaderItem(this.label);
  final String label;
}

final class _ListingIndexItem extends _QueueListItem {
  _ListingIndexItem(this.index);
  final int index;
}

class AdminListingModerationQueueScreen extends StatefulWidget {
  const AdminListingModerationQueueScreen({super.key});

  @override
  State<AdminListingModerationQueueScreen> createState() =>
      _AdminListingModerationQueueScreenState();
}

class _AdminListingModerationQueueScreenState
    extends State<AdminListingModerationQueueScreen> {
  final IListingModerationAdminService _service =
      getIt<IListingModerationAdminService>();

  static const double _ownerAvatarSize = 36;
  static const int _pageSize = 20;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  final List<PendingModerationListing> _listings = [];
  PendingModerationSummary? _summary;
  int _page = 1;
  int _totalPages = 1;
  final Map<int, bool> _expandedById = {};
  int? _approvingId;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });
    try {
      final res = await _service.getPendingQueue(page: 1, limit: _pageSize);
      setStateIfMounted(() {
        _listings
          ..clear()
          ..addAll(res.listings);
        _summary = res.summary;
        _page = 1;
        _totalPages = res.totalPages;
        _isLoading = false;
      });
      unawaited(PendingListingModerationState().refresh());
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _page >= _totalPages) return;
    setState(() => _isLoadingMore = true);
    final nextPage = _page + 1;
    try {
      final res = await _service.getPendingQueue(
        page: nextPage,
        limit: _pageSize,
      );
      setStateIfMounted(() {
        _listings.addAll(res.listings);
        _summary = res.summary;
        _page = nextPage;
        _totalPages = res.totalPages;
        _isLoadingMore = false;
      });
    } catch (e) {
      setStateIfMounted(() {
        _isLoadingMore = false;
        ToastTheme.showErrorSimple(context, message: e.toString());
      });
    }
  }

  Future<void> _approve(PendingModerationListing listing) async {
    if (_approvingId != null) return;

    final confirmed = await ConfirmationDialog.show(
      context: context,
      titleKey: "admin_listing_moderation_approve_confirm_title",
      messageKey: "admin_listing_moderation_approve_confirm_message",
      confirmButtonKey: "admin_listing_moderation_approve",
      cancelButtonKey: "cancel",
    );
    if (confirmed != true || !mounted) return;

    setState(() => _approvingId = listing.id);
    try {
      await _service.approveListing(listing.id);
      HapticFeedbackUtils.selectionClick();
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("admin_listing_moderation_approved_toast"),
      );
      await _loadFirstPage();
    } catch (e) {
      HapticFeedbackUtils.selectionClick();
      if (!mounted) return;
      ToastTheme.showErrorSimple(context, message: e.toString());
    } finally {
      setStateIfMounted(() => _approvingId = null);
    }
  }

  String _formatIsoDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final d = dt.day.toString().padLeft(2, "0");
      final m = dt.month.toString().padLeft(2, "0");
      return "$d.$m.${dt.year}";
    } catch (_) {
      return iso;
    }
  }

  String _formatModerationPrice(int price) {
    if (price <= 0) return "";
    final raw = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final remaining = raw.length - i;
      buffer.write(raw[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(" ");
      }
    }
    return buffer.toString();
  }

  String _monthLabel(DateTime date) {
    final monthKey = switch (date.month) {
      1 => "january",
      2 => "february",
      3 => "march",
      4 => "april",
      5 => "may",
      6 => "june",
      7 => "july",
      8 => "august",
      9 => "september",
      10 => "october",
      11 => "november",
      12 => "december",
      _ => "january",
    };
    return "${L10n.get(monthKey)} ${date.year}";
  }

  Future<void> _openListingDetail(int listingId) async {
    if (!mounted) return;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) =>
            AdminListingParserReviewScreen(listingId: listingId),
      ),
    );
    // The review screen pops `true` after a successful approval so the queue
    // stays in sync without the admin returning to manually refresh.
    if (result == true) {
      await _loadFirstPage();
    }
  }

  Widget _monthSeparator(BuildContext context, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: ThreeDSurfaceStyle.surfaceGradient(
                context,
                scheme.surface,
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow:
                  ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: scheme.outlineVariant.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    final s = _summary;
    if (s == null) return const SizedBox.shrink();

    final oldest = s.oldestWaitingDays;
    final oldestLabel = oldest == null
        ? "—"
        : "$oldest ${L10n.get("admin_listing_moderation_days_short")}";

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_listing_moderation_summary_total"),
            value: "${s.pendingTotal}",
            icon: Icons.pending_actions_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_listing_moderation_summary_today"),
            value: "${s.pendingSubmittedToday}",
            icon: Icons.today,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            title: L10n.get("admin_listing_moderation_summary_oldest"),
            value: oldestLabel,
            icon: Icons.hourglass_top_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: ThreeDSurfaceStyle.surfaceGradient(
          context,
          colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ThemeIcon(icon, size: 20, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      BuildContext context, String titleKey, IconData icon) {
    return Row(
      children: [
        ThemeIcon(icon,
            size: 22, color: Theme.of(context).colorScheme.onSurface),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            L10n.get(titleKey),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _ownerAvatarForListing(
    BuildContext context,
    PendingModerationListing item, {
    required Color avatarColor,
    required Color avatarIconColor,
  }) {
    final name = item.userName?.trim();
    final email = item.userEmail?.trim();
    final fallbackLabel = (name != null && name.isNotEmpty)
        ? name
        : (email != null && email.isNotEmpty)
            ? email
            : "?";

    final url = resolveAvatarUrl(item.userAvatarUrl);

    Widget fallback() {
      final initials = StringUtils.extractInitials(fallbackLabel);
      return CircleAvatar(
        radius: _ownerAvatarSize / 2,
        backgroundColor: avatarColor,
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: avatarIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              )
            : ThemeIcon(Icons.person, color: avatarIconColor, size: 18),
      );
    }

    if (url != null) {
      return ClipOval(
        child: NetworkAvatarImage(
          imageUrl: url,
          size: _ownerAvatarSize,
          fallback: fallback(),
        ),
      );
    }
    return fallback();
  }

  List<_QueueListItem> _buildGroupedItems() {
    final items = <_QueueListItem>[];
    String? lastMonthKey;
    for (var i = 0; i < _listings.length; i++) {
      final l = _listings[i];
      DateTime? dt;
      try {
        dt = DateTime.parse(l.createdAt);
      } catch (_) {
        dt = null;
      }
      final monthKey = dt != null ? "${dt.year}-${dt.month}" : null;
      if (dt != null && monthKey != null && monthKey != lastMonthKey) {
        items.add(_MonthHeaderItem(_monthLabel(dt)));
        lastMonthKey = monthKey;
      }
      items.add(_ListingIndexItem(i));
    }
    return items;
  }

  Widget _buildListingTile(BuildContext context, int index) {
    final item = _listings[index];
    final scheme = Theme.of(context).colorScheme;
    final expanded = _expandedById[item.id] ?? false;
    final busy = _approvingId == item.id;

    final ownerNameTrimmed = item.userName?.trim();
    final hasOwnerName =
        ownerNameTrimmed != null && ownerNameTrimmed.isNotEmpty;
    final hasEmail =
        item.userEmail != null && item.userEmail!.trim().isNotEmpty;

    final titleText = item.title.isEmpty
        ? "${L10n.get("admin_listing_moderation_id")} #${item.id}"
        : item.title;
    final priceText = _formatModerationPrice(item.price);

    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final useLiquidGlass =
            themeState.isBlueTheme || themeState.isLightTheme;
        final cardColor = themeState.cardColor;
        final textColor = themeState.cardTextColor;
        final secondaryTextColor = themeState.cardSecondaryTextColor;
        final iconColor = themeState.cardIconColor;
        final avatarColor = themeState.avatarColor;
        final avatarIconColor = themeState.avatarIconColor;

        return ThreeDElevatedSurface(
          baseColor: useLiquidGlass ? themeState.primaryColor : cardColor,
          margin: const EdgeInsets.only(bottom: 12),
          useLiquidGlass: useLiquidGlass,
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedbackUtils.impact();
                  setState(() => _expandedById[item.id] = !expanded);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        18,
                        16,
                        18,
                        14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 1),
                                child: ThemeIcon(
                                  Icons.home_work_outlined,
                                  size: 24,
                                  color: iconColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  titleText,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                    height: 1.15,
                                    color: textColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (item.listingTypeLabel != null &&
                              item.listingTypeLabel!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              item.listingTypeLabel!.trim(),
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ThemeIcon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: secondaryTextColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatIsoDate(item.createdAt),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: secondaryTextColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (priceText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ThemeIcon(
                                  Icons.payments,
                                  size: 19,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    priceText,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.green,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: secondaryTextColor.withValues(alpha: 0.18),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        18,
                        14,
                        12,
                        14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _ownerAvatarForListing(
                            context,
                            item,
                            avatarColor: avatarColor,
                            avatarIconColor: avatarIconColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  hasOwnerName
                                      ? ownerNameTrimmed
                                      : hasEmail
                                          ? item.userEmail!
                                          : L10n.get(
                                              "admin_listing_moderation_user",
                                            ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.15,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  [
                                    "${L10n.get("admin_listing_moderation_id")}: ${item.id}",
                                    if (hasOwnerName && hasEmail)
                                      "${L10n.get("admin_listing_moderation_user")}: ${item.userEmail}",
                                  ].join(" · "),
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.2,
                                    color: secondaryTextColor,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          AnimatedRotation(
                            turns: expanded ? 0.25 : 0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: ThemeIcon(
                              Icons.chevron_right_rounded,
                              size: 32,
                              color: iconColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 280),
                sizeCurve: Curves.easeInOut,
                firstCurve: Curves.easeIn,
                secondCurve: Curves.easeOut,
                crossFadeState: expanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity, height: 0),
                secondChild: Column(
                  children: [
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: secondaryTextColor.withValues(alpha: 0.18),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              onPressed: busy
                                  ? null
                                  : () => _openListingDetail(item.id),
                              surfaceGradientBase: scheme.primary,
                              textColor: scheme.onPrimary,
                              borderRadius: BorderRadius.circular(8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              child: ButtonIconLabel(
                                slotWidth: 26,
                                leading: ThemeIcon(
                                  Icons.open_in_new_rounded,
                                  size: 18,
                                  color: scheme.onPrimary,
                                ),
                                label: Text(
                                  L10n.get(
                                    "admin_listing_moderation_open",
                                  ),
                                  style: TextStyle(
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: PrimaryButton(
                              onPressed: busy ? null : () => _approve(item),
                              isLoading: busy,
                              surfaceGradientBase: scheme.primary,
                              textColor: scheme.onPrimary,
                              borderRadius: BorderRadius.circular(8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              child: ButtonIconLabel(
                                slotWidth: 26,
                                leading: ThemeIcon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: scheme.onPrimary,
                                ),
                                label: Text(
                                  L10n.get(
                                    "admin_listing_moderation_approve",
                                  ),
                                  style: TextStyle(
                                    color: scheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_listing_moderation_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, child) {
          if (_hasError) {
            return _buildErrorState(context);
          }
          if (_isLoading && _listings.isEmpty) {
            return CenteredHouseLoadingIndicator(
              text: L10n.get("admin_listing_moderation_loading"),
            );
          }

          if (_listings.isEmpty) {
            return UydoshRefreshIndicator(
              onRefresh: _loadFirstPage,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSummaryCards(context),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            L10n.get("admin_listing_moderation_empty"),
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }

          final grouped = _buildGroupedItems();

          return UydoshRefreshIndicator(
            onRefresh: _loadFirstPage,
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSummaryCards(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(
                        context,
                        "admin_listing_moderation_section_list",
                        Icons.rule_folder_outlined,
                      ),
                      const SizedBox(height: 12),
                    ]),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final it = grouped[index];
                        return switch (it) {
                          _MonthHeaderItem(:final label) =>
                            _monthSeparator(context, label),
                          _ListingIndexItem(:final index) =>
                            _buildListingTile(context, index),
                        };
                      },
                      childCount: grouped.length,
                    ),
                  ),
                ),
                if (_page < _totalPages)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: Center(
                        child: _isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              )
                            : GhostButtonFactory.text(
                                onPressed: _loadMore,
                                text: L10n.get(
                                  "admin_listing_moderation_load_more",
                                ),
                                neumorphicSoftUi: true,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                      ),
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_listing_moderation_error"),
      message: _errorMessage,
      messageMaxLines: 3,
      messageOverflow: TextOverflow.ellipsis,
      padding: const EdgeInsets.all(24),
      spacingAfterTitle: 8,
      spacingBeforeButton: 20,
      onRetry: _loadFirstPage,
      retryLabel: L10n.get("admin_listing_moderation_retry"),
    );
  }
}
