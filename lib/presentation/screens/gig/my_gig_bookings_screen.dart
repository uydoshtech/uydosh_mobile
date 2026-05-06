import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/localization/l10n.dart";
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

/// Which role filter is currently applied to "My bookings".
enum _BookingRole { all, client, provider }

extension on _BookingRole {
  String get apiValue => switch (this) {
        _BookingRole.all => "all",
        _BookingRole.client => "client",
        _BookingRole.provider => "provider",
      };
}

class MyGigBookingsScreen extends StatefulWidget {
  const MyGigBookingsScreen({super.key});

  @override
  State<MyGigBookingsScreen> createState() => _MyGigBookingsScreenState();
}

class _MyGigBookingsScreenState extends State<MyGigBookingsScreen> {
  _BookingRole _role = _BookingRole.all;

  @override
  void initState() {
    super.initState();
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
                        _BookingTile(booking: state.bookings[i]),
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
  const _BookingTile({required this.booking});
  final GigBooking booking;

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
    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Container(
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
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${IntFormatUtils.withDotThousands(booking.agreedAmount)} ${booking.currencyCode}",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
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
            const SizedBox(height: 12),
            _BookingActions(booking: booking),
          ],
        ),
      ),
    );
  }
}

class _BookingActions extends StatelessWidget {
  const _BookingActions({required this.booking});
  final GigBooking booking;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (final a in actions) ...[a, const SizedBox(width: 8)],
      ],
    );
  }
}
