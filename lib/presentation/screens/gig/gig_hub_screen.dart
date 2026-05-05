import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";

/// Entry point into the gig economy module: browse offers, post a task,
/// or open the bookings tab. Reachable from the main app via
/// `context.pushGigHub()` (see `gig_navigation.dart`).
class GigHubScreen extends StatelessWidget {
  const GigHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gigs")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HubTile(
            icon: Icons.search,
            title: "Browse services",
            subtitle: "Find people who can help with tasks",
            onTap: () => context.pushGigOffersList(),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.post_add,
            title: "Post a task",
            subtitle: "Describe what you need; let people bid",
            onTap: () => context.pushPostGigRequest(),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.event_note,
            title: "My bookings",
            subtitle: "Tasks you booked or accepted",
            onTap: () => context.pushMyGigBookings(),
          ),
          const SizedBox(height: 12),
          _HubTile(
            icon: Icons.list_alt,
            title: "Open requests",
            subtitle: "Tasks people are looking to get done",
            onTap: () => context.pushGigRequestsList(),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
