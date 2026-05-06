import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_bookings_bloc.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";

class MyGigBookingsScreen extends StatefulWidget {
  const MyGigBookingsScreen({super.key});

  @override
  State<MyGigBookingsScreen> createState() => _MyGigBookingsScreenState();
}

class _MyGigBookingsScreenState extends State<MyGigBookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      _refreshForTab(_tabs.index);
    });
    context.read<GigBookingsBloc>().add(const FetchMyGigBookings(role: "all"));
  }

  void _refreshForTab(int index) {
    final role = switch (index) {
      0 => "all",
      1 => "client",
      2 => "provider",
      _ => "all",
    };
    context.read<GigBookingsBloc>().add(FetchMyGigBookings(role: role));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get("gigs_my_bookings_title")),
        bottom: TabBar(
          controller: _tabs,
          labelColor: scheme.onPrimary,
          unselectedLabelColor: scheme.onPrimary.withValues(alpha: 0.7),
          indicatorColor: scheme.onPrimary,
          tabs: [
            Tab(text: L10n.get("gigs_my_bookings_tab_all")),
            Tab(text: L10n.get("gigs_my_bookings_tab_client")),
            Tab(text: L10n.get("gigs_my_bookings_tab_provider")),
          ],
        ),
      ),
      body: BlocBuilder<GigBookingsBloc, GigBookingsState>(
        builder: (context, state) {
          if (state is GigBookingsLoading || state is GigBookingsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GigBookingsError) {
            return Center(child: Text(state.message));
          }
          if (state is GigBookingsLoaded) {
            if (state.bookings.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(L10n.get("gigs_my_bookings_empty")),
                ),
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
              "${booking.agreedAmount} ${booking.currencyCode}",
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
        OutlinedButton(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.cancelled,
                ),
              ),
          child: Text(L10n.get("gigs_action_cancel")),
        ),
      );
    }

    if (booking.status == GigBookingStatus.inProgress ||
        booking.status == GigBookingStatus.accepted) {
      actions.add(
        ElevatedButton(
          onPressed: () => context.read<GigBookingsBloc>().add(
                TransitionGigBooking(
                  bookingId: booking.id,
                  toStatus: GigBookingStatus.completed,
                ),
              ),
          child: Text(L10n.get("gigs_action_mark_complete")),
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
