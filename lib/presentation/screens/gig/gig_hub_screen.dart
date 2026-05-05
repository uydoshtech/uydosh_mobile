import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";

/// Entry point into the gig economy module: browse offers, post a task,
/// or open the bookings tab. Reachable from the main app via
/// `context.pushGigHub()` (see `gig_navigation.dart`).
class GigHubScreen extends StatelessWidget {
  const GigHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.get("gigs_hub_title"))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _HubTile(
            icon: Icons.search_rounded,
            title: L10n.get("gigs_hub_browse_title"),
            subtitle: L10n.get("gigs_hub_browse_subtitle"),
            onTap: () {
              HapticFeedbackUtils.lightImpact();
              context.pushGigOffersList();
            },
          ),
          const SizedBox(height: 14),
          _HubTile(
            icon: Icons.post_add_rounded,
            title: L10n.get("gigs_hub_post_title"),
            subtitle: L10n.get("gigs_hub_post_subtitle"),
            onTap: () {
              HapticFeedbackUtils.lightImpact();
              context.pushPostGigRequest();
            },
          ),
          const SizedBox(height: 14),
          _HubTile(
            icon: Icons.event_note_rounded,
            title: L10n.get("gigs_hub_my_bookings_title"),
            subtitle: L10n.get("gigs_hub_my_bookings_subtitle"),
            onTap: () {
              HapticFeedbackUtils.lightImpact();
              context.pushMyGigBookings();
            },
          ),
          const SizedBox(height: 14),
          _HubTile(
            icon: Icons.list_alt_rounded,
            title: L10n.get("gigs_hub_open_requests_title"),
            subtitle: L10n.get("gigs_hub_open_requests_subtitle"),
            onTap: () {
              HapticFeedbackUtils.lightImpact();
              context.pushGigRequestsList();
            },
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
    final scheme = Theme.of(context).colorScheme;
    // In the blue theme `scheme.surface` and `scheme.primary` are both the
    // same dark navy, so a `primary.withValues(alpha: 0.12)` chip / icon would
    // vanish into the tile. Use `secondary` (the brand's light-teal accent in
    // dark themes; falls back to a contrasty value in light themes) so the
    // icon pops on every theme.
    final accent = scheme.secondary;
    return ThreeDElevatedSurface(
      baseColor: scheme.surface,
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurface.withValues(alpha: 0.65),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: scheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
