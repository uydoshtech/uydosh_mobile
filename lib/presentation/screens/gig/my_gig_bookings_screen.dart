import "dart:async";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/pending_gig_bookings_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/presentation/utils/conversation_entry_flow.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_bookings_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_refresh_indicator.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";

/// Which role filter is currently applied to "My bookings".
enum _BookingRole { all, client, provider }

extension on _BookingRole {
  String get apiValue => switch (this) {
        _BookingRole.all => "all",
        _BookingRole.client => "client",
        _BookingRole.provider => "provider",
      };
}

_BookingRole _bookingRoleFromApi(String raw) {
  switch (raw) {
    case "client":
      return _BookingRole.client;
    case "provider":
      return _BookingRole.provider;
    default:
      return _BookingRole.all;
  }
}

/// Picks a label color that stays readable on the neumorphic status chip (dark
/// accents such as [ColorScheme.primary] on a dark blue theme were nearly
/// identical to the chip fill).
Color _statusChipLabelColor(Color accent, Color chipBackground) {
  final bgL = chipBackground.computeLuminance();
  final fgL = accent.computeLuminance();
  if ((bgL - fgL).abs() >= 0.28) return accent;
  return bgL < 0.5
      ? Color.lerp(accent, Colors.white, 0.62)!
      : Color.lerp(accent, Colors.black87, 0.42)!;
}

class MyGigBookingsScreen extends StatefulWidget {
  const MyGigBookingsScreen({
    super.key,
    this.initialRoleFilter = 'all',
  });

  /// Passed to [FetchMyGigBookings] as `all`, `client`, or `provider`.
  final String initialRoleFilter;

  @override
  State<MyGigBookingsScreen> createState() => _MyGigBookingsScreenState();
}

class _MyGigBookingsScreenState extends State<MyGigBookingsScreen> {
  late _BookingRole _role;
  int? _sessionUserId;

  @override
  void initState() {
    super.initState();
    _role = _bookingRoleFromApi(widget.initialRoleFilter);
    SessionManager.getUserId().then((id) {
      if (mounted) setState(() => _sessionUserId = id);
    });
    context
        .read<GigBookingsBloc>()
        .add(FetchMyGigBookings(role: _role.apiValue));
  }

  void _onRoleChanged(_BookingRole next) {
    if (next == _role) return;
    setState(() => _role = next);
    context
        .read<GigBookingsBloc>()
        .add(FetchMyGigBookings(role: next.apiValue));
  }

  Future<void> _onPullRefresh() async {
    context.read<GigBookingsBloc>().add(
          FetchMyGigBookings(
            role: _role.apiValue,
            silentRefresh: true,
          ),
        );
    await PendingGigBookingsState().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(L10n.get("gigs_my_bookings_title")),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: ListenableBuilder(
              listenable: ThemeState(),
              builder: (context, _) {
                final themeState = ThemeState();
                return NeumorphicSegmentedSwitch<_BookingRole>(
                  liquidGlass:
                      themeState.isBlueTheme || themeState.isLightTheme,
                  value: _role,
                  onChanged: _onRoleChanged,
                  intrinsicWidthFirstSegment: true,
                  firstSegmentWidthScale: 1.2,
                  // Short "All" label is still much narrower than the other tabs by
                  // intrinsic measure; keep a minimum share of the bar so the thumb
                  // does not look like a tiny sliver.
                  firstSegmentMinFractionOfBar: 0.26,
                  entries: [
                    SegmentedSwitchEntry(
                      value: _BookingRole.all,
                      label: L10n.get("gigs_my_bookings_tab_all"),
                      icon: Icons.list_alt_rounded,
                    ),
                    SegmentedSwitchEntry(
                      value: _BookingRole.client,
                      label: L10n.get("gigs_my_bookings_tab_client"),
                      icon: Icons.person_outline_rounded,
                    ),
                    SegmentedSwitchEntry(
                      value: _BookingRole.provider,
                      label: L10n.get("gigs_my_bookings_tab_provider"),
                      icon: Icons.handyman_outlined,
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<GigBookingsBloc, GigBookingsState>(
              builder: (context, state) {
                if (state is GigBookingsLoading ||
                    state is GigBookingsInitial) {
                  return const Center(child: HouseLoadingIndicator());
                }
                return UydoshRefreshIndicator(
                  onRefresh: _onPullRefresh,
                  child: PullToRefreshStretchHaptics(
                    child: _BookingsRefreshScrollable(
                      state: state,
                      sessionUserId: _sessionUserId,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsRefreshScrollable extends StatelessWidget {
  const _BookingsRefreshScrollable({
    required this.state,
    required this.sessionUserId,
  });

  final GigBookingsState state;
  final int? sessionUserId;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case GigBookingsError(:final message):
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(message),
                  ),
                ),
              ),
            );
          },
        );
      case GigBookingsLoaded(:final bookings):
        if (bookings.isEmpty) {
          return UydoshEmptyColumn(
            icon: Icons.event_note_outlined,
            title: L10n.get("gigs_my_bookings_empty"),
            fillViewportForRefresh: true,
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, i) => _BookingTile(
            booking: bookings[i],
            sessionUserId: sessionUserId,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({
    required this.booking,
    required this.sessionUserId,
  });
  final GigBooking booking;
  final int? sessionUserId;

  String _counterpartyDisplayName(int me) {
    final raw = booking.isProvider(me)
        ? booking.clientDisplayName
        : booking.providerDisplayName;
    final trimmed = raw?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return L10n.get("gigs_booking_chat_peer_fallback");
  }

  Color _statusColor(BuildContext context) {
    switch (booking.status) {
      case GigBookingStatus.pending:
        return Colors.orange;
      case GigBookingStatus.accepted:
        return Theme.of(context).colorScheme.primary;
      case GigBookingStatus.inProgress:
        return Colors.blueGrey;
      case GigBookingStatus.completed:
        return Colors.green;
      case GigBookingStatus.cancelled:
        return Colors.grey;
      case GigBookingStatus.disputed:
        return Colors.redAccent;
    }
  }

  bool get _hasActionButtons {
    switch (booking.status) {
      case GigBookingStatus.pending:
      case GigBookingStatus.accepted:
      case GigBookingStatus.inProgress:
        return true;
      case GigBookingStatus.completed:
      case GigBookingStatus.cancelled:
      case GigBookingStatus.disputed:
        return false;
    }
  }

  String _statusLabel() {
    switch (booking.status) {
      case GigBookingStatus.pending:
        return L10n.get("gigs_status_pending");
      case GigBookingStatus.accepted:
        return L10n.get("gigs_status_accepted");
      case GigBookingStatus.inProgress:
        return L10n.get("gigs_status_in_progress");
      case GigBookingStatus.completed:
        return L10n.get("gigs_status_completed");
      case GigBookingStatus.cancelled:
        return L10n.get("gigs_status_cancelled");
      case GigBookingStatus.disputed:
        return L10n.get("gigs_status_disputed");
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final me = sessionUserId;
    final statusColor = _statusColor(context);
    final statusBase = Color.lerp(
      scheme.surfaceContainerHighest,
      statusColor,
      0.26,
    )!;
    final statusChip = Padding(
      padding: const EdgeInsets.only(left: 3, top: 2, bottom: 5, right: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, statusBase),
          boxShadow: ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
        ),
        child: Text(
          _statusLabel(),
          style: TextStyle(
            color: _statusChipLabelColor(statusColor, statusBase),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );

    final titleStatusRow = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            booking.titleSnapshot,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        statusChip,
      ],
    );

    final Widget topHeader;
    if (me == null) {
      topHeader = titleStatusRow;
    } else {
      final peerLabel = _counterpartyDisplayName(me);
      topHeader = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookingPeerAvatar(
            displayName: peerLabel,
            avatarUrl: booking.isProvider(me)
                ? booking.clientAvatarUrl
                : booking.providerAvatarUrl,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleStatusRow,
                const SizedBox(height: 6),
                Text(
                  peerLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            topHeader,
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: PriceDisplaySettingsState(),
              builder: (context, _) {
                final display = CurrencyDisplayUtils.gigAmountForDisplay(
                  amount: booking.agreedAmount,
                  currencyCode: booking.currencyCode,
                );
                return ListingPaymentsOutlineBadge(
                  label: CurrencyDisplayUtils.stripEmptyCurrencyArtifacts(
                    "${IntFormatUtils.withDotThousands(display.amount)} ${CurrencyDisplayUtils.isoCodeForBadge(display.currencyCode)}",
                  ),
                );
              },
            ),
            if (_hasActionButtons) ...[
              const SizedBox(height: 12),
              _BookingActions(
                booking: booking,
                sessionUserId: sessionUserId,
              ),
            ],
            if (booking.scheduledStartAt != null) ...[
              const SizedBox(height: 4),
              Text(
                L10n.getWithParams(
                  "gigs_scheduled_at",
                  params: {"when": booking.scheduledStartAt!},
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingActions extends StatefulWidget {
  const _BookingActions({
    required this.booking,
    required this.sessionUserId,
  });
  final GigBooking booking;
  final int? sessionUserId;

  @override
  State<_BookingActions> createState() => _BookingActionsState();
}

class _BookingActionsState extends State<_BookingActions> {
  static const BorderRadius _pill = BorderRadius.all(Radius.circular(18));
  static const EdgeInsets _padRow =
      EdgeInsets.symmetric(horizontal: 8, vertical: 10);
  static const Color _colorAccept = Color(0xFF2E7D32);
  static const Color _colorChat = Color(0xFF0277BD);
  static const Color _colorComplete = Color(0xFFE65100);
  static const Color _colorCancel = Color(0xFFC62828);
  static const double _rowIconSize = 18;

  bool _chatOpening = false;

  GigBooking get booking => widget.booking;

  Future<void> _confirmAndCancelBooking(BuildContext context) async {
    final confirmed = await ConfirmationDialog.show(
      context: context,
      titleKey: "gigs_booking_cancel_confirm_title",
      messageKey: "gigs_booking_cancel_confirm_message",
      confirmButtonKey: "gigs_action_cancel",
      cancelButtonKey: "cancel",
      confirmButtonColor: Theme.of(context).colorScheme.error,
    );
    if (!mounted || confirmed != true) return;
    context.read<GigBookingsBloc>().add(
          TransitionGigBooking(
            bookingId: booking.id,
            toStatus: GigBookingStatus.cancelled,
          ),
        );
  }

  Future<void> _openChat(BuildContext context) async {
    if (_chatOpening) return;
    if (!AuthFlow.requireAuth(context)) return;
    final me = widget.sessionUserId;
    if (me == null) return;
    setState(() => _chatOpening = true);
    try {
      final otherId = booking.isProvider(me)
          ? booking.clientUserId
          : booking.providerUserId;
      final rawName = booking.isProvider(me)
          ? booking.clientDisplayName
          : booking.providerDisplayName;
      final trimmed = rawName?.trim();
      final otherName = trimmed != null && trimmed.isNotEmpty
          ? trimmed
          : L10n.get("gigs_booking_chat_peer_fallback");
      final otherAvatar = booking.isProvider(me)
          ? booking.clientAvatarUrl
          : booking.providerAvatarUrl;

      await ConversationEntryFlow.openGigBookingChat(
        context: context,
        gigBookingId: booking.id,
        buildChat: (conversation) => ChatScreen(
          conversationId: conversation.id,
          conversationContextType: "gig_booking",
          conversationParticipantId: booking.providerUserId,
          otherUserId: otherId,
          otherUserName: otherName,
          otherUserInitials: StringUtils.extractInitials(otherName),
          otherUserAvatar: otherAvatar,
        ),
      );
    } finally {
      if (mounted) setState(() => _chatOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = widget.sessionUserId;
    final buttons = <Widget>[];

    // Cancel (left) → Accept or Mark complete → Chat (right).
    final canCancel = booking.status == GigBookingStatus.pending ||
        booking.status == GigBookingStatus.accepted;
    if (canCancel) {
      buttons.add(
        GhostButtonFactory.iconTextCentered(
          onPressed: () => unawaited(_confirmAndCancelBooking(context)),
          icon: Icons.event_busy_rounded,
          text: L10n.get("gigs_action_cancel"),
          padding: _padRow,
          borderRadius: _pill,
          width: double.infinity,
          iconSize: _rowIconSize,
          neumorphicSoftUi: true,
          neumorphicFillColor: _colorCancel,
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
      );
    }

    if (booking.status == GigBookingStatus.pending &&
        me != null &&
        booking.isProvider(me)) {
      buttons.add(
        GhostButtonFactory.iconTextCentered(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.accepted,
                ),
              ),
          icon: Icons.check_circle_outline_rounded,
          text: L10n.get("gigs_action_accept_booking"),
          padding: _padRow,
          borderRadius: _pill,
          width: double.infinity,
          iconSize: _rowIconSize,
          neumorphicSoftUi: true,
          neumorphicFillColor: _colorAccept,
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
      );
    }

    if (booking.status == GigBookingStatus.inProgress ||
        booking.status == GigBookingStatus.accepted) {
      buttons.add(
        GhostButtonFactory.iconTextCentered(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.completed,
                ),
              ),
          icon: Icons.task_alt_rounded,
          text: L10n.get("gigs_action_mark_complete"),
          padding: _padRow,
          borderRadius: _pill,
          width: double.infinity,
          iconSize: _rowIconSize,
          neumorphicSoftUi: true,
          neumorphicFillColor: _colorComplete,
          textColor: Colors.white,
          iconColor: Colors.white,
        ),
      );
    }

    if (_hasBookingChat(booking, me)) {
      buttons.add(
        GhostButtonFactory.iconTextCentered(
          onPressed: _chatOpening ? null : () => _openChat(context),
          icon: Icons.chat_bubble_outline_rounded,
          text: L10n.get("gigs_action_chat_booking"),
          padding: _padRow,
          borderRadius: _pill,
          width: double.infinity,
          iconSize: _rowIconSize,
          neumorphicSoftUi: true,
          neumorphicFillColor: _colorChat,
          textColor: Colors.white,
          iconColor: Colors.white,
          isLoading: _chatOpening,
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    // Neumorphic shadows extend past the layout box; pad so they are not clipped.
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(child: buttons[i]),
          ],
        ],
      ),
    );
  }

  bool _hasBookingChat(GigBooking b, int? me) {
    if (me == null) return false;
    switch (b.status) {
      case GigBookingStatus.pending:
      case GigBookingStatus.accepted:
      case GigBookingStatus.inProgress:
        return true;
      case GigBookingStatus.completed:
      case GigBookingStatus.cancelled:
      case GigBookingStatus.disputed:
        return false;
    }
  }
}

class _BookingPeerAvatar extends StatelessWidget {
  const _BookingPeerAvatar({
    required this.displayName,
    required this.avatarUrl,
  });

  final String displayName;
  final String? avatarUrl;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolved = resolveAvatarUrl(avatarUrl);
    final cacheExtent =
        (_size * MediaQuery.devicePixelRatioOf(context)).round();
    final initials = StringUtils.extractInitials(displayName);

    Widget fallback() {
      return CircleAvatar(
        radius: _size / 2,
        backgroundColor: scheme.surfaceContainerHighest,
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              )
            : Icon(
                Icons.person_outline_rounded,
                color: scheme.onSurfaceVariant,
                size: 24,
              ),
      );
    }

    if (resolved == null) return fallback();

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: resolved,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        memCacheWidth: cacheExtent,
        memCacheHeight: cacheExtent,
        placeholder: (_, __) => fallback(),
        errorWidget: (_, __, ___) => fallback(),
      ),
    );
  }
}
