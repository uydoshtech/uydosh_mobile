import "dart:async";

import "package:flutter/material.dart";
import "package:model_viewer_plus/model_viewer_plus.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";

enum _GlbLoadStatus { loading, loaded, error }

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
    setState(() {
      _status = message == "loaded"
          ? _GlbLoadStatus.loaded
          : _GlbLoadStatus.error;
    });
  }

  void _retry() {
    setState(() {
      _status = _GlbLoadStatus.loading;
      _reloadToken++;
    });
    _armLoadTimeout();
  }

  String get _resolvedUrl => EnvironmentUtil.hostedImageUrl(widget.glbUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ModelViewer(
                key: ValueKey(_reloadToken),
                id: _elementId,
                src: _resolvedUrl,
                alt: L10n.get("room_3d_viewer_title"),
                backgroundColor: Colors.black,
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
                relatedJs:
                    """
                    (function() {
                      var mv = document.getElementById('$_elementId');
                      if (!mv || !window.GlbViewerBridge) { return; }
                      mv.addEventListener('load', function() {
                        GlbViewerBridge.postMessage('loaded');
                      });
                      mv.addEventListener('error', function() {
                        GlbViewerBridge.postMessage('error');
                      });
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
          ],
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
            semanticsLabel: MaterialLocalizations.of(context).closeButtonTooltip,
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

  Widget _errorState() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(
            Icons.view_in_ar_outlined,
            color: Colors.grey[600],
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.get("room_3d_load_error_title"),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
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
