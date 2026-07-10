import "dart:async";

import "package:flutter/foundation.dart" show kDebugMode;
import "package:flutter/material.dart";
import "package:model_viewer_plus/model_viewer_plus.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";
import "package:webview_flutter/webview_flutter.dart";

enum _GlbLoadStatus { loading, loaded, error }

/// Light-blue sky backdrop for the 3D scene, matching the web app's
/// `.roomscan-viewer-wrap` / `.roomscan-backdrop` gradient (see
/// `assets/listing-detail.css` in the uydoshtech.github.io repo) so the
/// Android viewer looks consistent with web and the native iOS sky gradient.
const List<Color> _roomScanSkyGradient = [
  Color(0xFFBCDCF7),
  Color(0xFF6FA3E0),
];

/// Mirrors the web viewer's `ROOM_SCAN_MODE_SEQUENCE` (see listing-detail.js)
/// and the native iOS viewer's `DisplayMode` (see
/// RoomUsdzViewerViewController.swift): tapping the layers button advances
/// full room → floor + furniture → floor only → full room.
enum _RoomScanDisplayMode { fullRoom, floorAndFurniture, floorOnly }

/// Android room-scan 3D viewer: renders the server-side USDZ→GLB conversion
/// (`room_scan_glb_url`) via Google's `<model-viewer>` web component inside a
/// WebView. iOS instead presents a native SceneKit viewer on the original
/// USDZ — see [RoomUsdzViewerService] — since ARKit-authored USDZ isn't
/// directly renderable there either without conversion, but the SceneKit
/// route is lighter weight and already ships that platform's full
/// floor-plan/materials UI.
class RoomGlbViewerScreen extends StatefulWidget {
  const RoomGlbViewerScreen({required this.glbUrl, super.key});

  /// Relative or absolute URL to the `.glb` file (`room_scan_glb_url`).
  final String glbUrl;

  @override
  State<RoomGlbViewerScreen> createState() => _RoomGlbViewerScreenState();
}

class _RoomGlbViewerScreenState extends State<RoomGlbViewerScreen> {
  static const String _elementId = "uydoshRoomGlbViewer";
  static const Duration _loadTimeout = Duration(seconds: 25);

  _GlbLoadStatus _status = _GlbLoadStatus.loading;
  Timer? _loadTimeoutTimer;
  int _reloadToken = 0;
  WebViewController? _webViewController;
  _RoomScanDisplayMode _displayMode = _RoomScanDisplayMode.fullRoom;
  // Diagnostic only (not shown to end users) — surfaces *why* the WebView
  // reported an error (bad URL, a network/HTTP failure, or model-viewer
  // itself rejecting the file) since the bridge previously collapsed every
  // failure into an opaque "error" with no detail, making reports of
  // "can't load on Android" impossible to act on.
  String? _lastErrorDetail;

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
      if (mounted && _status == _GlbLoadStatus.loading) {
        setState(() => _status = _GlbLoadStatus.error);
      }
    });
  }

  void _onBridgeMessage(String message) {
    if (!mounted) return;
    _loadTimeoutTimer?.cancel();
    final isLoaded = message == "loaded";
    if (!isLoaded) {
      // message is "error" (no detail) or "error:<detail>" from the
      // window.onerror / model-viewer 'error' listeners below.
      _lastErrorDetail = message == "error" ? null : message;
      debugPrint(
          "RoomGlbViewerScreen: load failed — $message (url=$_resolvedUrl)");
    }
    setState(() {
      _status = isLoaded ? _GlbLoadStatus.loaded : _GlbLoadStatus.error;
    });
  }

  void _retry() {
    setState(() {
      _status = _GlbLoadStatus.loading;
      _reloadToken++;
      _lastErrorDetail = null;
      // The ModelViewer below is rebuilt from scratch on reload (new
      // ValueKey), so its underlying page reloads too — reset to match.
      _displayMode = _RoomScanDisplayMode.fullRoom;
      _webViewController = null;
    });
    _armLoadTimeout();
  }

  String get _resolvedUrl => EnvironmentUtil.hostedImageUrl(widget.glbUrl);

  static const List<_RoomScanDisplayMode> _modeSequence = [
    _RoomScanDisplayMode.fullRoom,
    _RoomScanDisplayMode.floorAndFurniture,
    _RoomScanDisplayMode.floorOnly,
  ];

  void _cycleDisplayMode() {
    final nextIndex =
        (_modeSequence.indexOf(_displayMode) + 1) % _modeSequence.length;
    setState(() => _displayMode = _modeSequence[nextIndex]);
    unawaited(
      _webViewController?.runJavaScript(
        "window.uydoshApplyRoomScanMode && "
        "window.uydoshApplyRoomScanMode('${_displayMode.name}');",
      ),
    );
  }

  IconData _modeIcon(_RoomScanDisplayMode mode) {
    switch (mode) {
      case _RoomScanDisplayMode.fullRoom:
        return Icons.house_rounded;
      case _RoomScanDisplayMode.floorAndFurniture:
        return Icons.bed_rounded;
      case _RoomScanDisplayMode.floorOnly:
        return Icons.crop_square_rounded;
    }
  }

  String _modeLabel(_RoomScanDisplayMode mode) {
    switch (mode) {
      case _RoomScanDisplayMode.fullRoom:
        return L10n.get("room_3d_mode_full_room");
      case _RoomScanDisplayMode.floorAndFurniture:
        return L10n.get("room_3d_mode_floor_and_furniture");
      case _RoomScanDisplayMode.floorOnly:
        return L10n.get("room_3d_mode_floor_only");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _roomScanSkyGradient.last,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _roomScanSkyGradient,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: ModelViewer(
                  key: ValueKey(_reloadToken),
                  id: _elementId,
                  src: _resolvedUrl,
                  alt: L10n.get("room_3d_viewer_title"),
                  // Transparent so the gradient behind (set above) shows
                  // through the WebView, mirroring the web viewer's approach
                  // of a transparent `<model-viewer>` over a CSS gradient.
                  backgroundColor: Colors.transparent,
                  autoRotate: true,
                  cameraControls: true,
                  debugLogging: false,
                  javascriptChannels: <JavascriptChannel>{
                    JavascriptChannel(
                      "GlbViewerBridge",
                      onMessageReceived: (message) =>
                          _onBridgeMessage(message.message),
                    ),
                  },
                  onWebViewCreated: (controller) =>
                      _webViewController = controller,
                  relatedJs: """
                    (function() {
                      var mv = document.getElementById('$_elementId');
                      if (!mv) { return; }
                      if (window.GlbViewerBridge) {
                        mv.addEventListener('load', function() {
                          GlbViewerBridge.postMessage('loaded');
                        });
                        mv.addEventListener('error', function(event) {
                          var detail = event && event.detail;
                          var reason = (detail && (detail.sourceError ? String(detail.sourceError.message || detail.sourceError) : detail.type)) || 'model-viewer error event';
                          GlbViewerBridge.postMessage('error:' + reason);
                        });
                        // Catches failures model-viewer's own 'error' event misses entirely
                        // (e.g. model-viewer.min.js itself failing to load/parse), which
                        // otherwise left Android reports of "can't load 3D model" with zero
                        // diagnostic detail — this is the only signal we get in that case.
                        window.addEventListener('error', function(event) {
                          GlbViewerBridge.postMessage('error:window:' + (event && event.message || 'unknown script error'));
                        });
                      }

                      // Mirrors the web viewer (listing-detail.js) and the native iOS
                      // viewer (RoomUsdzViewerViewController.swift): classifies each
                      // material by the backend's naming convention (Wall0_color,
                      // Floor0_color, Chair0_color, ... — see uydosh_backend's
                      // applyRoomScanStylizedMaterials.ts) and hides "wall"/"furniture"
                      // materials by driving their base color alpha to 0 via
                      // model-viewer's Scene Graph API, since it has no per-node
                      // visibility toggle. Invoked on demand from Flutter via
                      // WebViewController.runJavaScript.
                      function classifyMaterialName(name) {
                        var n = (name || '').toLowerCase();
                        if (!n) return 'other';
                        if (n.indexOf('wall') === 0 || n.indexOf('ceiling') !== -1 ||
                            n.indexOf('door') !== -1 || n.indexOf('window') !== -1 ||
                            n.indexOf('opening') !== -1) {
                          return 'wall';
                        }
                        if (n.indexOf('floor') === 0 || n.indexOf('ground') !== -1) return 'floor';
                        return 'furniture';
                      }

                      function setMaterialHidden(material, hidden) {
                        try {
                          var pbr = material.pbrMetallicRoughness;
                          if (!pbr) return;
                          if (hidden) {
                            if (!material.__uydoshOriginalColor) {
                              material.__uydoshOriginalColor = pbr.baseColorFactor.slice();
                              material.__uydoshOriginalAlphaMode = material.getAlphaMode();
                            }
                            var base = material.__uydoshOriginalColor;
                            material.setAlphaMode('BLEND');
                            pbr.setBaseColorFactor([base[0], base[1], base[2], 0]);
                          } else if (material.__uydoshOriginalColor) {
                            pbr.setBaseColorFactor(material.__uydoshOriginalColor);
                            material.setAlphaMode(material.__uydoshOriginalAlphaMode || 'OPAQUE');
                          }
                        } catch (err) {}
                      }

                      window.uydoshApplyRoomScanMode = function(mode) {
                        var model = mv.model;
                        if (!model || !model.materials) return;
                        model.materials.forEach(function(material) {
                          var kind = classifyMaterialName(material.name);
                          var hidden = false;
                          if (mode === 'floorAndFurniture') hidden = kind === 'wall';
                          else if (mode === 'floorOnly') hidden = kind === 'wall' || kind === 'furniture';
                          setMaterialHidden(material, hidden);
                        });
                      };
                    })();
                    """,
                ),
              ),
              if (_status == _GlbLoadStatus.loading)
                const Positioned.fill(
                  child: Center(child: UydoshLogoSpinner(size: 40)),
                ),
              if (_status == _GlbLoadStatus.error)
                Positioned.fill(child: _errorState()),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _topBar(context),
              ),
              if (_status == _GlbLoadStatus.loaded)
                Positioned(
                  right: 16,
                  bottom: 24,
                  child: _modeButton(context),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          ThreeDAppBarIconButton(
            iconData: Icons.close,
            onPressed: () => Navigator.of(context).pop(),
            semanticsLabel:
                MaterialLocalizations.of(context).closeButtonTooltip,
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            iconSize: 20,
            contentSlotSize: 24,
            padding: const EdgeInsets.all(6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              L10n.get("room_3d_viewer_title"),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(BuildContext context) {
    return Semantics(
      label: L10n.get("room_3d_view_mode_label"),
      hint: L10n.get("room_3d_view_mode_hint"),
      value: _modeLabel(_displayMode),
      button: true,
      child: Material(
        color: Colors.black.withValues(alpha: 0.5),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _cycleDisplayMode,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(
              _modeIcon(_displayMode),
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _roomScanSkyGradient,
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(
            Icons.view_in_ar_outlined,
            color: Colors.white,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.get("room_3d_load_error_title"),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          if (kDebugMode && _lastErrorDetail != null) ...[
            const SizedBox(height: 8),
            SelectableText(
              _lastErrorDetail!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: _retry,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            child: Text(L10n.get("retry")),
          ),
        ],
      ),
    );
  }
}
