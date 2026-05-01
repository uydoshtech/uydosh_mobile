import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_map_widget.dart";

/// Tap-to-load wrapper around [YandexMapWidget].
///
/// Yandex MapKit is a heavy native component: as soon as the platform view is
/// instantiated it allocates GPU surfaces, kicks off tile-fetching network
/// activity, and starts an OpenGL render loop — even before the user has
/// looked at the map. On the listing-detail screen most users never scroll to
/// or interact with the map at all, so paying that cost up front is pure
/// battery/heat drain.
///
/// This widget renders a lightweight static placeholder until the user
/// explicitly taps it. Only then is the live [YandexMapWidget] mounted (and
/// from then on it stays mounted for the rest of the screen's lifetime).
class DeferredYandexMap extends StatefulWidget {
  const DeferredYandexMap({
    required this.apiKey,
    super.key,
    this.latitude,
    this.longitude,
    this.title,
    this.listingDetail,
    this.height = 200,
  });

  final String apiKey;
  final double? latitude;
  final double? longitude;
  final String? title;
  final double height;
  final ListingDetail? listingDetail;

  @override
  State<DeferredYandexMap> createState() => _DeferredYandexMapState();
}

class _DeferredYandexMapState extends State<DeferredYandexMap> {
  bool _loadMap = false;

  @override
  Widget build(BuildContext context) {
    if (_loadMap) {
      return YandexMapWidget(
        apiKey: widget.apiKey,
        latitude: widget.latitude,
        longitude: widget.longitude,
        title: widget.title,
        listingDetail: widget.listingDetail,
        height: widget.height,
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedbackUtils.lightImpact();
            setState(() => _loadMap = true);
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.surfaceContainerHighest,
                  Color.lerp(
                        scheme.surfaceContainerHighest,
                        scheme.primary,
                        0.06,
                      ) ??
                      scheme.surfaceContainerHighest,
                ],
              ),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Faint diagonal "map-ish" pattern so the placeholder reads as
                // a map without spinning up the real Yandex tiles.
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(painter: MapPatternPainter()),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThemeIcon(
                      Icons.map_outlined,
                      size: 40,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      L10n.get("show_map", fallback: "Show map"),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      L10n.get(
                        "tap_to_load_map",
                        fallback: "Tap to load",
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
