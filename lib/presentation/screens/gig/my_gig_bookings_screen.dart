import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_bookings_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_segmented_switch.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_empty_column.dart";
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
                if (state is GigBookingsError) {
                  return Center(child: Text(state.message));
                }
                if (state is GigBookingsLoaded) {
                  if (state.bookings.isEmpty) {
                    return UydoshEmptyColumn(
                      icon: Icons.event_note_outlined,
                      title: L10n.get("gigs_my_bookings_empty"),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: state.bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) =>
                        _BookingTile(
                          booking: state.bookings[i],
                          sessionUserId: _sessionUserId,
                        ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
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
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      booking.titleSnapshot,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListingPaymentsOutlineBadge(
                      label:
                          "${IntFormatUtils.withDotThousands(booking.agreedAmount)} ${CurrencyDisplayUtils.isoCode(booking.currencyCode)}",
                    ),
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
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  statusChip,
                  if (_hasActionButtons) ...[
                    const SizedBox(height: 18),
                    const Expanded(child: SizedBox.shrink()),
                    _BookingActions(
                      booking: booking,
                      sessionUserId: sessionUserId,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookingActions extends StatelessWidget {
  const _BookingActions({
    required this.booking,
    required this.sessionUserId,
  });
  final GigBooking booking;
  final int? sessionUserId;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    final me = sessionUserId;
    if (booking.status == GigBookingStatus.pending &&
        me != null &&
        booking.isProvider(me)) {
      actions.add(
        PrimaryButtonFactory.text(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.accepted,
                ),
              ),
          text: L10n.get("gigs_action_accept_booking"),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          neumorphicSoftUi: true,
        ),
      );
    }

    if (booking.status == GigBookingStatus.inProgress ||
        booking.status == GigBookingStatus.accepted) {
      actions.add(
        PrimaryButtonFactory.text(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.completed,
                ),
              ),
          text: L10n.get("gigs_action_mark_complete"),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          actions[i],
        ],
      ],
    );
  }
}
