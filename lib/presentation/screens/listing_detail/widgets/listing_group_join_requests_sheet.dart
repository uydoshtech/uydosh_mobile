import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

Future<void> showListingGroupJoinRequestsSheet({
  required BuildContext context,
  required int listingId,
  required VoidCallback onChanged,
}) async {
  final service = getIt<IListingGroupService>();
  await showAppBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.paddingOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, bottomInset + 12),
        child: GlassBottomSheetSurface(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            type: MaterialType.transparency,
            child: _ListingGroupJoinRequestsSheet(
              listingId: listingId,
              service: service,
              onChanged: onChanged,
            ),
          ),
        ),
      );
    },
  );
}

class _ListingGroupJoinRequestsSheet extends StatefulWidget {
  const _ListingGroupJoinRequestsSheet({
    required this.listingId,
    required this.service,
    required this.onChanged,
  });

  final int listingId;
  final IListingGroupService service;
  final VoidCallback onChanged;

  @override
  State<_ListingGroupJoinRequestsSheet> createState() =>
      _ListingGroupJoinRequestsSheetState();
}

class _ListingGroupJoinRequestsSheetState
    extends State<_ListingGroupJoinRequestsSheet> {
  var _loading = true;
  List<ListingGroupJoinRequest> _requests = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await widget.service.listJoinRequests(
        listingId: widget.listingId,
      );
      if (!mounted) return;
      setState(() {
        _requests = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _approve(ListingGroupJoinRequest request) async {
    HapticFeedbackUtils.impact();
    try {
      await widget.service.approveJoinRequest(
        listingId: widget.listingId,
        requestId: request.id,
      );
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_join_request_approved"),
      );
      widget.onChanged();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Future<void> _reject(ListingGroupJoinRequest request) async {
    HapticFeedbackUtils.impact();
    try {
      await widget.service.rejectJoinRequest(
        listingId: widget.listingId,
        requestId: request.id,
      );
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_join_request_rejected"),
      );
      widget.onChanged();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final themeState = ThemeState();
    final maxHeight = MediaQuery.sizeOf(context).height * 0.72;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
            child: Row(
              children: [
                ThemeIcon(
                  CupertinoIcons.person_2_fill,
                  size: 22,
                  color: scheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    L10n.get("group_manage_requests"),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ThreeDAppBarIconButton(
                  iconData: Icons.close,
                  onPressed: () => Navigator.of(context).pop(),
                  semanticsLabel:
                      MaterialLocalizations.of(context).closeButtonTooltip,
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                ),
              ],
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_requests.isEmpty)
            _EmptyRequestsState(scheme: scheme)
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: _requests.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return _JoinRequestCard(
                    request: _requests[index],
                    avatarColor: themeState.avatarColor,
                    avatarIconColor: themeState.avatarIconColor,
                    onApprove: () => _approve(_requests[index]),
                    onReject: () => _reject(_requests[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyRequestsState extends StatelessWidget {
  const _EmptyRequestsState({required this.scheme});

  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(
            CupertinoIcons.tray,
            size: 40,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 12),
          Text(
            L10n.get("group_no_pending_requests"),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

class _JoinRequestCard extends StatelessWidget {
  const _JoinRequestCard({
    required this.request,
    required this.avatarColor,
    required this.avatarIconColor,
    required this.onApprove,
    required this.onReject,
  });

  final ListingGroupJoinRequest request;
  final Color avatarColor;
  final Color avatarIconColor;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const avatarSize = 44.0;
    final avatarUrl = resolveAvatarUrl(request.applicantAvatar);
    final initials = StringUtils.extractInitials(request.applicantName);
    final message = request.message?.trim();

    final avatarFallback = CircleAvatar(
      backgroundColor: avatarColor,
      child: Text(
        initials,
        style: TextStyle(
          color: avatarIconColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      useLiquidGlass: true,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
                      Text(
                        request.applicantName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (message != null && message.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GhostButtonFactory.iconText(
                    onPressed: onReject,
                    icon: Icons.close_rounded,
                    text: L10n.get("group_reject_member"),
                    iconSize: 16,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PrimaryButtonFactory.iconText(
                    onPressed: onApprove,
                    icon: Icons.check_rounded,
                    text: L10n.get("group_approve_member"),
                    iconSize: 16,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
