import "dart:async";

import "package:flutter/foundation.dart" show kIsWeb;
import "package:flutter/material.dart";
import "package:model_viewer_plus/model_viewer_plus.dart";
import "package:pointer_interceptor/pointer_interceptor.dart";
import "package:room_scan_kit/room_scan_kit.dart" as kit;
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/room_usdz_viewer_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";

/// Matches the web Telegram mini-app `.roomscan-viewer-wrap` sky gradient
/// (`assets/listing-detail.css` in uydoshtech.github.io) and the fullscreen
/// [RoomGlbViewerScreen] backdrop.
const List<Color> _roomScanSkyGradient = [Color(0xFFBCDCF7), Color(0xFF6FA3E0)];

/// Mini preview height — same as web `.roomscan-viewer-wrap { height: 280px }`.
const double _miniViewerHeight = 280;

/// Matches native 3D viewer: SF `rectangle` → [Icons.rectangle_outlined],
/// `arrow.up.and.down` → [Icons.height], `rectangle.on.rectangle` →
/// [Icons.flip_to_front_outlined] (overlapping rects).
Widget _room3dDimensionMetricRow({
  required BuildContext context,
  required IconData icon,
  required String text,
}) {
  final style = Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
  final iconColor = style?.color ?? Theme.of(context).colorScheme.onSurface;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, size: 18, color: iconColor.withValues(alpha: 0.92)),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: style)),
    ],
  );
}

({String? line1, String? lineHeight, String? line2}) _dimensionLines(
  ListingDetail d,
) {
  final fl = d.roomScanFloorLongM;
  final fs = d.roomScanFloorShortM;
  final h = d.roomScanHeightM;
  final area = d.roomScanFloorAreaM2;
  if (fl == null || fs == null || h == null || area == null) {
    return (line1: null, lineHeight: null, line2: null);
  }
  return (
    line1: L10n.getWithParams(
      "room_3d_dimensions_line1_template",
      params: <String, String>{
        "floorLong": fl.toStringAsFixed(1),
        "floorShort": fs.toStringAsFixed(1),
      },
    ),
    lineHeight: L10n.getWithParams(
      "room_3d_dimensions_height_template",
      params: <String, String>{"height": h.toStringAsFixed(1)},
    ),
    line2: L10n.getWithParams(
      "room_3d_dimensions_line2_template",
      params: <String, String>{"floorArea": area.toStringAsFixed(1)},
    ),
  );
}

/// "View room in 3D" tile on listing details.
///
/// - **iOS:** embeds a native SceneKit USDZ preview ([kit.RoomUsdzPreview]) —
///   WKWebView/`model_viewer` reloads when scrolled in a [SliverList].
/// - **Android / others:** embeds GLB via `model_viewer_plus` when
///   [ListingDetail.roomScanGlbUrl] is present.
/// - Otherwise falls back to a tappable summary row.
class ListingRoom3dTile extends StatefulWidget {
  const ListingRoom3dTile({
    required this.listingDetail,
    required this.onTap,
    this.isLoading = false,
    super.key,
  });

  final ListingDetail listingDetail;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  State<ListingRoom3dTile> createState() => _ListingRoom3dTileState();
}

class _ListingRoom3dTileState extends State<ListingRoom3dTile>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late final AnimationController _rotateController;
  bool _expanded = true;

  String? get _glbUrl {
    final raw = widget.listingDetail.roomScanGlbUrl?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  String? get _usdzUrl {
    final raw = widget.listingDetail.pointCloudUrl?.trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  /// Native SceneKit mini preview — iOS only (avoids WebView scroll reload).
  bool get _useIosUsdzPreview => !kIsWeb && isIOSDevice && _usdzUrl != null;

  bool get _hasMiniScene => _useIosUsdzPreview || _glbUrl != null;

  @override
  bool get wantKeepAlive => _hasMiniScene;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncIconRotation();
  }

  void _syncIconRotation() {
    // Icon spin is only for the CTA-row fallback (no embedded scene).
    if (_hasMiniScene) {
      _rotateController.stop();
      _rotateController.value = 0;
      return;
    }
    final enabled =
        UiPerformancePolicy.decorativeAnimationsEnabled(context) &&
        TickerMode.of(context);
    if (enabled) {
      if (!_rotateController.isAnimating) {
        _rotateController.repeat();
      }
    } else {
      _rotateController.stop();
      _rotateController.value = 0;
    }
  }

  @override
  void didUpdateWidget(covariant ListingRoom3dTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listingDetail.roomScanGlbUrl !=
            widget.listingDetail.roomScanGlbUrl ||
        oldWidget.listingDetail.pointCloudUrl !=
            widget.listingDetail.pointCloudUrl) {
      _syncIconRotation();
      updateKeepAlive();
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  Widget _buildPreview() {
    if (_useIosUsdzPreview) {
      return _MiniUsdzViewer(
        usdzUrl: _usdzUrl!,
        listingId: widget.listingDetail.id,
        isLoadingFullscreen: widget.isLoading,
        onOpenFullscreen: widget.onTap,
      );
    }
    return _MiniGlbViewer(
      glbUrl: _glbUrl!,
      isLoadingFullscreen: widget.isLoading,
      onOpenFullscreen: widget.onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin
    if (_hasMiniScene) {
      return _MiniSceneTile(
        listingDetail: widget.listingDetail,
        expanded: _expanded,
        onToggleExpanded: _toggleExpanded,
        preview: _buildPreview(),
      );
    }
    return _CtaRowTile(
      listingDetail: widget.listingDetail,
      rotateController: _rotateController,
      isLoading: widget.isLoading,
      onTap: widget.onTap,
    );
  }
}

/// Embedded mini 3D scene — mirrors the web `roomscan-section` layout.
class _MiniSceneTile extends StatelessWidget {
  const _MiniSceneTile({
    required this.listingDetail,
    required this.expanded,
    required this.onToggleExpanded,
    required this.preview,
  });

  final ListingDetail listingDetail;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    final dims = _dimensionLines(listingDetail);
    final hasDimensions =
        dims.line1 != null && dims.lineHeight != null && dims.line2 != null;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;

    return SizedBox(
      width: double.infinity,
      child: ListingDetailTileShell(
        useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
        // PlatformView (SceneKit / WebView) dies if BackdropFilter is
        // inserted/removed when FeedScrollScope toggles on scroll.
        lockBackdropBlur: true,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: onToggleExpanded,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
                child: Row(
                  children: [
                    ThemeIcon(
                      Icons.view_in_ar,
                      color: ThemeState().isBlueTheme
                          ? BlueThemeColors.textPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.get("view_room_3d"),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (listingDetail.photogrammetryStatus ==
                              "processing")
                            Text(
                              L10n.get("room_3d_textured_processing"),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: ThemeIcon(Icons.expand_more, color: variant),
                    ),
                  ],
                ),
              ),
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: expanded
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(13, 0, 13, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            preview,
                            if (hasDimensions) ...[
                              const SizedBox(height: 10),
                              _room3dDimensionMetricRow(
                                context: context,
                                icon: Icons.rectangle_outlined,
                                text: dims.line1!,
                              ),
                              const SizedBox(height: 4),
                              _room3dDimensionMetricRow(
                                context: context,
                                icon: Icons.height,
                                text: dims.lineHeight!,
                              ),
                              const SizedBox(height: 4),
                              _room3dDimensionMetricRow(
                                context: context,
                                icon: Icons.flip_to_front_outlined,
                                text: dims.line2!,
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS: download USDZ once, then embed native SceneKit preview.
class _MiniUsdzViewer extends StatefulWidget {
  const _MiniUsdzViewer({
    required this.usdzUrl,
    required this.listingId,
    required this.isLoadingFullscreen,
    required this.onOpenFullscreen,
  });

  final String usdzUrl;
  final int listingId;
  final bool isLoadingFullscreen;
  final VoidCallback? onOpenFullscreen;

  @override
  State<_MiniUsdzViewer> createState() => _MiniUsdzViewerState();
}

class _MiniUsdzViewerState extends State<_MiniUsdzViewer> {
  /// Pins the UiKitView Element across ancestor rebuilds.
  final GlobalKey _previewViewKey = GlobalKey(
    debugLabel: "roomUsdzMiniPreview",
  );

  String? _localPath;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant _MiniUsdzViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.usdzUrl != widget.usdzUrl ||
        oldWidget.listingId != widget.listingId) {
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final absolute = EnvironmentUtil.hostedImageUrl(widget.usdzUrl);
      final file = await RoomUsdzViewerService.downloadUsdToCache(
        absolute,
        listingId: widget.listingId,
      );
      if (!mounted) return;
      if (file == null) {
        setState(() {
          _loading = false;
          _error = "unavailable";
        });
        return;
      }
      setState(() {
        _localPath = file.path;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  void _onFullscreenTap() {
    // Keep the mini PlatformView mounted while fullscreen opens — tearing it
    // down early flashed the logo spinner over an empty sky until the modal
    // covered the listing. Only the fullscreen button shows a busy state.
    if (widget.isLoadingFullscreen || widget.onOpenFullscreen == null) return;
    widget.onOpenFullscreen!();
  }

  @override
  Widget build(BuildContext context) {
    final autoRotate = UiPerformancePolicy.decorativeAnimationsEnabled(context);
    final path = _localPath;
    final showPreview = path != null && _error == null;
    final openingFullscreen = widget.isLoadingFullscreen;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _roomScanSkyGradient,
          ),
        ),
        child: SizedBox(
          height: _miniViewerHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (showPreview)
                kit.RoomUsdzPreview(
                  key: _previewViewKey,
                  filePath: path,
                  autoRotate: autoRotate && !openingFullscreen,
                ),
              if (_loading && !showPreview)
                const ColoredBox(
                  color: Colors.transparent,
                  // Sky gradient is light — force black "U"/chimney mark.
                  child: Center(
                    child: UydoshLogoSpinner(size: 36, onLightBackground: true),
                  ),
                ),
              if (_error != null)
                ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          L10n.get("room_3d_load_error_title"),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PointerInterceptor(
                          child: OutlinedButton(
                            onPressed: () => unawaited(_load()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                            child: Text(L10n.get("retry")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                right: 6,
                bottom: 6,
                child: PointerInterceptor(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: openingFullscreen ? null : _onFullscreenTap,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: openingFullscreen
                              ? const UydoshInlineSpinner(
                                  color: Colors.white,
                                  dimension: 18,
                                )
                              : const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline `<model-viewer>` with web-matching auto-rotate / orbit defaults.
class _MiniGlbViewer extends StatefulWidget {
  const _MiniGlbViewer({
    required this.glbUrl,
    required this.isLoadingFullscreen,
    required this.onOpenFullscreen,
  });

  final String glbUrl;
  final bool isLoadingFullscreen;
  final VoidCallback? onOpenFullscreen;

  @override
  State<_MiniGlbViewer> createState() => _MiniGlbViewerState();
}

enum _MiniLoadStatus { loading, loaded, error }

class _MiniGlbViewerState extends State<_MiniGlbViewer> {
  static const String _elementId = "uydoshRoomGlbMini";
  static const Duration _loadTimeout = Duration(seconds: 25);

  _MiniLoadStatus _status = _MiniLoadStatus.loading;
  Timer? _loadTimeoutTimer;
  int _reloadToken = 0;

  String get _resolvedUrl => EnvironmentUtil.hostedImageUrl(widget.glbUrl);

  bool get _autoRotate =>
      UiPerformancePolicy.decorativeAnimationsEnabled(context);

  @override
  void initState() {
    super.initState();
    _armLoadTimeout();
  }

  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  void _armLoadTimeout() {
    _loadTimeoutTimer?.cancel();
    _loadTimeoutTimer = Timer(_loadTimeout, () {
      if (mounted && _status == _MiniLoadStatus.loading) {
        setState(() => _status = _MiniLoadStatus.error);
      }
    });
  }

  void _onBridgeMessage(String message) {
    if (!mounted) return;
    _loadTimeoutTimer?.cancel();
    setState(() {
      _status = message == "loaded"
          ? _MiniLoadStatus.loaded
          : _MiniLoadStatus.error;
    });
  }

  void _retry() {
    setState(() {
      _status = _MiniLoadStatus.loading;
      _reloadToken++;
    });
    _armLoadTimeout();
  }

  void _onFullscreenTap() {
    // Keep the mini WebView mounted while fullscreen opens so the room does
    // not flash the logo spinner. PointerInterceptor on the button still
    // blocks zoom-through taps.
    if (widget.isLoadingFullscreen || widget.onOpenFullscreen == null) return;
    widget.onOpenFullscreen!();
  }

  @override
  Widget build(BuildContext context) {
    final openingFullscreen = widget.isLoadingFullscreen;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _roomScanSkyGradient,
          ),
        ),
        child: SizedBox(
          height: _miniViewerHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ModelViewer(
                key: ValueKey(_reloadToken),
                id: _elementId,
                src: _resolvedUrl,
                alt: L10n.get("room_3d_viewer_title"),
                backgroundColor: Colors.transparent,
                autoRotate: _autoRotate && !openingFullscreen,
                autoRotateDelay: 0,
                rotationPerSecond: "60deg",
                cameraControls: !openingFullscreen,
                // Pinch/scroll zoom through Flutter overlays is a common
                // PlatformView leak — orbit stays enabled, zoom does not.
                disableZoom: true,
                cameraOrbit: "0deg 45deg 70%",
                minFieldOfView: "20deg",
                maxFieldOfView: "90deg",
                interactionPrompt: InteractionPrompt.none,
                shadowIntensity: 0.9,
                exposure: 1.08,
                ar: false,
                debugLogging: false,
                javascriptChannels: <JavascriptChannel>{
                  JavascriptChannel(
                    "GlbMiniBridge",
                    onMessageReceived: (message) =>
                        _onBridgeMessage(message.message),
                  ),
                },
                relatedJs:
                    """
                  (function() {
                    var mv = document.getElementById('$_elementId');
                    if (!mv || !window.GlbMiniBridge) { return; }
                    mv.addEventListener('load', function() {
                      GlbMiniBridge.postMessage('loaded');
                    });
                    mv.addEventListener('error', function() {
                      GlbMiniBridge.postMessage('error');
                    });
                  })();
                  """,
              ),
              if (_status == _MiniLoadStatus.loading)
                const ColoredBox(
                  color: Colors.transparent,
                  // Sky gradient is light — force black "U"/chimney mark.
                  child: Center(
                    child: UydoshLogoSpinner(size: 36, onLightBackground: true),
                  ),
                ),
              if (_status == _MiniLoadStatus.error)
                ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          L10n.get("room_3d_load_error_title"),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Retry sits over a PlatformView — intercept pointers
                        // so the tap can't zoom the (reloaded) model instead.
                        PointerInterceptor(
                          child: OutlinedButton(
                            onPressed: _retry,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                            ),
                            child: Text(L10n.get("retry")),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                right: 6,
                bottom: 6,
                // Critical: without this, taps on the Flutter fullscreen
                // button also hit the underlying <model-viewer> WebView and
                // zoom the room out (the "model shrinks" bug).
                child: PointerInterceptor(
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: openingFullscreen ? null : _onFullscreenTap,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: openingFullscreen
                              ? const UydoshInlineSpinner(
                                  color: Colors.white,
                                  dimension: 18,
                                )
                              : const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Legacy tappable summary row when only a USDZ scan exists (no GLB yet).
class _CtaRowTile extends StatelessWidget {
  const _CtaRowTile({
    required this.listingDetail,
    required this.rotateController,
    required this.isLoading,
    required this.onTap,
  });

  final ListingDetail listingDetail;
  final AnimationController rotateController;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dims = _dimensionLines(listingDetail);
    final hasDimensions =
        dims.line1 != null && dims.lineHeight != null && dims.line2 != null;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return SizedBox(
      width: double.infinity,
      child: ListingDetailTileShell(
        useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RotationTransition(
                            turns: rotateController,
                            child: ThemeIcon(
                              Icons.view_in_ar,
                              color: ThemeState().isBlueTheme
                                  ? BlueThemeColors.textPrimary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              L10n.get("view_room_3d"),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ],
                      ),
                      ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.hardEdge,
                          child: hasDimensions
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 6),
                                      _room3dDimensionMetricRow(
                                        context: context,
                                        icon: Icons.rectangle_outlined,
                                        text: dims.line1!,
                                      ),
                                      const SizedBox(height: 4),
                                      _room3dDimensionMetricRow(
                                        context: context,
                                        icon: Icons.height,
                                        text: dims.lineHeight!,
                                      ),
                                      const SizedBox(height: 4),
                                      _room3dDimensionMetricRow(
                                        context: context,
                                        icon: Icons.flip_to_front_outlined,
                                        text: dims.line2!,
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  UydoshInlineSpinner(color: variant, dimension: 20)
                else
                  ThemeIcon(Icons.chevron_right, color: variant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
