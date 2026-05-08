import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/pending_gig_bookings_state.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_bookings_bloc.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/presentation/widgets/common/pull_to_refresh_stretch_haptics.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
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
            child: NeumorphicSegmentedSwitch<_BookingRole>(
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
    final statusColor = _statusColor(context);
    final statusChip = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _statusLabel(),
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );

    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
            ),
            const SizedBox(height: 8),
            ListingPaymentsOutlineBadge(
              label:
                  "${IntFormatUtils.withDotThousands(booking.agreedAmount)} ${CurrencyDisplayUtils.isoCode(booking.currencyCode)}",
            ),
            if (_hasActionButtons) ...[
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _BookingActions(
                  booking: booking,
                  sessionUserId: sessionUserId,
                ),
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
  static const BorderRadius _pill =
      BorderRadius.all(Radius.circular(18));
  static const EdgeInsets _pad =
      EdgeInsets.symmetric(horizontal: 14, vertical: 10);

  bool _chatOpening = false;

  GigBooking get booking => widget.booking;

  Future<void> _openChat(BuildContext context) async {
    if (_chatOpening) return;
    if (!AuthenticationState().isAuthenticated) {
      context.pushAuthWizard();
      return;
    }
    final me = widget.sessionUserId;
    if (me == null) return;
    setState(() => _chatOpening = true);
    try {
      final conversation = await getIt<IMessagingService>().createConversation(
        gigBookingId: booking.id,
      );
      if (!mounted) return;
      final otherId =
          booking.isProvider(me) ? booking.clientUserId : booking.providerUserId;
      final rawName = booking.isProvider(me)
          ? booking.clientDisplayName
          : booking.providerDisplayName;
      final trimmed = rawName?.trim();
      final otherName =
          trimmed != null && trimmed.isNotEmpty
              ? trimmed
              : L10n.get("gigs_booking_chat_peer_fallback");
      final otherAvatar = booking.isProvider(me)
          ? booking.clientAvatarUrl
          : booking.providerAvatarUrl;
      await Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          settings:
              RouteSettings(name: ChatScreen.routeName(conversation.id)),
          builder: (_) => ChatScreen(
            conversationId: conversation.id,
            otherUserId: otherId,
            otherUserName: otherName,
            otherUserInitials: StringUtils.extractInitials(otherName),
            otherUserAvatar: otherAvatar,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("conversation_failed"),
      );
    } finally {
      if (mounted) setState(() => _chatOpening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    final me = widget.sessionUserId;
    if (booking.status == GigBookingStatus.pending &&
        me != null &&
        booking.isProvider(me)) {
      actions.add(
        GhostButtonFactory.text(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.accepted,
                ),
              ),
          text: L10n.get("gigs_action_accept_booking"),
          padding: _pad,
          borderRadius: _pill,
          neumorphicSoftUi: true,
          neumorphicFillColor: const Color(0xFF2E7D32),
          textColor: Colors.white,
        ),
      );
    }

    if (_hasBookingChat(booking, me)) {
      actions.add(
        GhostButtonFactory.text(
          onPressed:
              _chatOpening ? null : () => _openChat(context),
          text: L10n.get("gigs_action_chat_booking"),
          padding: _pad,
          borderRadius: _pill,
          neumorphicSoftUi: true,
          neumorphicFillColor: const Color(0xFF43A047),
          textColor: Colors.white,
          isLoading: _chatOpening,
        ),
      );
    }

    final canCancel = booking.status == GigBookingStatus.pending ||
        booking.status == GigBookingStatus.accepted;
    if (canCancel) {
      actions.add(
        GhostButtonFactory.text(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.cancelled,
                ),
              ),
          text: L10n.get("gigs_action_cancel"),
          padding: _pad,
          borderRadius: _pill,
          neumorphicSoftUi: true,
        ),
      );
    }

    if (booking.status == GigBookingStatus.inProgress ||
        booking.status == GigBookingStatus.accepted) {
      actions.add(
        GhostButtonFactory.text(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.completed,
                ),
              ),
          text: L10n.get("gigs_action_mark_complete"),
          padding: _pad,
          borderRadius: _pill,
          neumorphicSoftUi: true,
          neumorphicFillColor: const Color(0xFFE65100),
          textColor: Colors.white,
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: actions,
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
