import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/main.dart" show routeObserver;
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
/// This widget renders a lightweight static placeholder until either the user
/// taps it or [autoLoad] is flipped to `true` by the parent. Only then is the
/// live [YandexMapWidget] mounted. If another route covers this one, the native
/// map is temporarily unmounted and restored when the route becomes visible.
///
/// Parents that gate the map behind an expandable section can drive [autoLoad]
/// instead of relying on a manual tap: flip it once the expand animation has
/// settled so the heavy native view doesn't jank the expansion.
class DeferredYandexMap extends StatefulWidget {
  const DeferredYandexMap({
    required this.apiKey,
    super.key,
    this.latitude,
    this.longitude,
    this.title,
    this.listingDetail,
    this.height = 200,
    this.autoLoad = false,
    this.showBrandMark = true,
    this.showZoomControls = true,
  });

  final String apiKey;
  final double? latitude;
  final double? longitude;
  final String? title;
  final double height;
  final ListingDetail? listingDetail;

  /// When `true`, mounts the live map without waiting for a tap.
  final bool autoLoad;
  final bool showBrandMark;
  final bool showZoomControls;

  @override
  State<DeferredYandexMap> createState() => _DeferredYandexMapState();
}

class _DeferredYandexMapState extends State<DeferredYandexMap> with RouteAware {
  bool _loadMap = false;
  bool _routeActive = true;

  @override
  void initState() {
    super.initState();
    _loadMap = widget.autoLoad;
  }

  @override
  void didUpdateWidget(DeferredYandexMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Once the parent signals auto-load (e.g. the section finished expanding),
    // mount the real map. A rebuild is already in flight from this update, so
    // mutating the flag directly is enough — no setState needed.
    if (widget.autoLoad && !_loadMap) {
      _loadMap = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.unsubscribe(this);
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => _setRouteActive(true);

  @override
  void didPopNext() => _setRouteActive(true);

  @override
  void didPushNext() => _setRouteActive(false);

  void _setRouteActive(bool active) {
    if (_routeActive == active || !mounted) return;
    setState(() => _routeActive = active);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadMap && _routeActive) {
      return YandexMapWidget(
        apiKey: widget.apiKey,
        latitude: widget.latitude,
        longitude: widget.longitude,
        title: widget.title,
        listingDetail: widget.listingDetail,
        height: widget.height,
        showBrandMark: widget.showBrandMark,
        showZoomControls: widget.showZoomControls,
      );
    }

    if (_loadMap) {
      return SizedBox(height: widget.height, width: double.infinity);
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // In the blue theme `primary` is a dark navy that is almost identical to
    // the placeholder background, leaving the map icon invisible. Fall back to
    // the lighter teal accent there so the icon reads clearly.
    final accentColor =
        ThemeState().isBlueTheme ? scheme.secondary : scheme.primary;
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
                    ThemeIcon(Icons.map_outlined, size: 48, color: accentColor),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.show_map,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.l10n.tap_to_load_map,
                      style: theme.textTheme.bodyMedium?.copyWith(
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
