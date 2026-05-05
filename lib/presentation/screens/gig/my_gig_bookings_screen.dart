import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/domain/models/gig/gig_booking.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_bookings_bloc.dart";

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("My bookings"),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: "All"),
            Tab(text: "As client"),
            Tab(text: "As provider"),
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
              return const Center(child: Text("No bookings yet."));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: state.bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
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
        return "Pending";
      case GigBookingStatus.accepted:
        return "Accepted";
      case GigBookingStatus.inProgress:
        return "In progress";
      case GigBookingStatus.completed:
        return "Completed";
      case GigBookingStatus.cancelled:
        return "Cancelled";
      case GigBookingStatus.disputed:
        return "Disputed";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(context).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                      color: _statusColor(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("${booking.agreedAmount} ${booking.currencyCode}"),
            if (booking.scheduledStartAt != null) ...[
              const SizedBox(height: 4),
              Text(
                "Scheduled: ${booking.scheduledStartAt}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          child: const Text("Cancel"),
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
          child: const Text("Mark complete"),
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
