import "dart:io";

import "package:camera/camera.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Full-screen custom camera with a UyDosh logo pinned to the bottom-right,
/// aligned with the shutter button — mirrors the 3D scan scene aesthetic.
///
/// Returns the captured image's absolute file path via [Navigator.pop],
/// or `null` if the user cancels / an error occurs.
class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

enum _CaptureStage { live, review }

class _CustomCameraScreenState extends State<CustomCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  FlashMode _flashMode = FlashMode.off;
  bool _initializing = true;
  bool _capturing = false;
  String? _initError;
  // Optional underlying detail (e.g. CameraException code/message). Surfaced
  // under the friendly error headline so we can diagnose first-run AVFoundation
  // failures without making the user dig through `flutter logs`.
  String? _initErrorDetail;

  _CaptureStage _stage = _CaptureStage.live;
  XFile? _captured;
  // Guards against the lifecycle handler tearing down a controller that
  // `_bootstrap()` is still bringing up — without this, an `inactive`
  // lifecycle event mid-bootstrap leaves the screen stuck on the error
  // state because we never re-run bootstrap after `resumed`.
  bool _bootstrapping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Unlock orientation while the camera screen is mounted so the OS
    // reports physical device tilt correctly to the `camera` plugin. This
    // is the ONLY reliable way to get landscape captures to actually save
    // as landscape — the plugin ties capture orientation to the system's
    // current interface orientation, so if we keep the UI portrait-locked
    // the saved photo always ends up portrait regardless of how the phone
    // was held.
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onControllerValueChanged);
    _controller?.dispose();
    // Restore the app's global orientation policy (see `main.dart`, which
    // locks the whole app to portraitUp).
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  /// Listener on the controller's value so we can trigger a rebuild when
  /// the plugin reports a new device orientation (keeps the capture in
  /// sync even if the user rotates while the preview is running).
  void _onControllerValueChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only react to lifecycle transitions when we already have a fully
    // initialized controller. iOS fires `inactive` while AVFoundation is
    // showing its first-run permission dialog, and tearing down the
    // half-initialized controller during that window is exactly what used
    // to leave the screen stuck on "Camera is unavailable". This mirrors
    // the original (working) implementation from `caa469d`.
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (_bootstrapping) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _tearDownController();
    } else if (state == AppLifecycleState.resumed) {
      if (_stage != _CaptureStage.live) return;
      if (_cameras.isEmpty) return;
      _setUpController(_cameras[_cameraIndex]);
    }
  }

  Future<void> _bootstrap() async {
    if (_bootstrapping) return;
    _bootstrapping = true;
    setStateIfMounted(() {
      _initializing = true;
      _initError = null;
      _initErrorDetail = null;
    });
    try {
      // Don't pre-check camera permission via `permission_handler`: on iOS
      // it requires build-time preprocessor macros (`PERMISSION_CAMERA=1`)
      // in the Podfile, and without them every status read returns `denied`
      // even when iOS has actually granted access — which is exactly how
      // the previous "camera permissions" change broke this screen. The
      // `camera` plugin's iOS implementation calls AVFoundation's
      // `requestAccess(for: .video)` itself inside `initialize()`, which is
      // the source of truth and returns a clean `CameraAccessDenied`
      // `CameraException` if the user actually denied access. Let it.
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setStateIfMounted(() {
          _initializing = false;
          _initError = L10n.get("camera_unavailable");
          _initErrorDetail = "no cameras returned by availableCameras()";
        });
        return;
      }
      // Back-camera only. iOS typically exposes several back cameras
      // (wide, ultra-wide, telephoto, dual, triple) — we just pick the
      // first one marked `back`. Front/selfie camera is intentionally
      // unsupported: listing photos are meant to show the space being
      // rented, not the user.
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _cameras = [back];
      _cameraIndex = 0;
      await _setUpController(_cameras[_cameraIndex]);
    } catch (e, st) {
      logger.e("Failed to init custom camera", error: e, stackTrace: st);
      setStateIfMounted(() {
        _initializing = false;
        _initError = L10n.get("camera_unavailable");
        _initErrorDetail = _describeError(e);
      });
    } finally {
      _bootstrapping = false;
    }
  }

  /// Compact, user-readable rendering of a `CameraException` (or any other
  /// thrown error) for the on-screen detail line.
  String _describeError(Object e) {
    if (e is CameraException) {
      return "${e.code}: ${e.description ?? ""}".trim();
    }
    return e.toString();
  }

  Future<void> _tearDownController() async {
    final previous = _controller;
    if (previous == null) return;
    _controller = null;
    previous.removeListener(_onControllerValueChanged);
    try {
      await previous.dispose();
    } catch (_) {
      // Best-effort dispose; plugin can throw if already disposed.
    }
  }

  Future<void> _setUpController(CameraDescription description) async {
    await _tearDownController();
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      // Important: do NOT assign `_controller = controller` before
      // `initialize()` completes. iOS can fire spurious `inactive`/`paused`
      // lifecycle events while AVCaptureSession spins up (e.g. during the
      // orientation unlock from `setPreferredOrientations` in initState).
      // If the lifecycle handler sees a half-initialized controller in
      // `_controller`, it tears it down mid-init and `initialize()` throws,
      // leaving the screen stuck on "Camera is unavailable". Assign only
      // after we know init succeeded.
      await controller.initialize();
    } catch (e, st) {
      logger.e("Camera controller init failed", error: e, stackTrace: st);
      try {
        await controller.dispose();
      } catch (_) {
        // Best-effort.
      }
      if (!mounted) return;
      setStateIfMounted(() {
        _initializing = false;
        _initError = L10n.get("camera_unavailable");
        _initErrorDetail = _describeError(e);
      });
      return;
    }

    // Screen was disposed (or torn down by lifecycle) while init was in
    // flight. Dispose this orphan controller so we don't leak the AV
    // session.
    if (!mounted || _controller != null) {
      try {
        await controller.dispose();
      } catch (_) {}
      return;
    }

    _controller = controller;
    controller.addListener(_onControllerValueChanged);
    // Intentionally do NOT lock capture orientation here. The preview /
    // UI is pinned to portrait via `setPreferredOrientations` in
    // initState, which keeps the live feed from stretching on rotation.
    // Capture orientation, however, should follow the device's physical
    // tilt so shots taken with the phone held sideways are saved as
    // genuine landscape images (matches Apple's stock Camera behavior).
    try {
      await controller.setFlashMode(_flashMode);
    } catch (e) {
      if (kDebugMode) debugPrint("setFlashMode failed: $e");
    }

    setStateIfMounted(() {
      _initializing = false;
      _initError = null;
    });
  }

  Future<void> _cycleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    const order = [FlashMode.off, FlashMode.auto, FlashMode.always];
    final next = order[(order.indexOf(_flashMode) + 1) % order.length];
    try {
      await controller.setFlashMode(next);
      setStateIfMounted(() => _flashMode = next);
      HapticFeedbackUtils.impact();
    } catch (e) {
      if (kDebugMode) debugPrint("Failed to set flash mode: $e");
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _capturing ||
        controller.value.isTakingPicture) {
      return;
    }
    setState(() => _capturing = true);
    try {
      HapticFeedbackUtils.impact();
      // Freeze capture orientation to whatever the plugin currently reports
      // as the device's physical tilt. This is what lets landscape shots
      // actually save as landscape pixels: without an explicit lock, some
      // platforms fall back to the last interface orientation, which can
      // lag behind a fast rotate-then-shoot.
      try {
        await controller
            .lockCaptureOrientation(controller.value.deviceOrientation);
      } catch (_) {
        // Non-fatal — orientation will fall back to the plugin default.
      }
      final file = await controller.takePicture();
      try {
        await controller.unlockCaptureOrientation();
      } catch (_) {
        // Non-fatal.
      }
      setStateIfMounted(() {
        _captured = file;
        _stage = _CaptureStage.review;
      });
    } catch (e, st) {
      logger.e("takePicture failed", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(context, message: L10n.get("error_picking_photo"));
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  void _retake() {
    HapticFeedbackUtils.impact();
    setState(() {
      _captured = null;
      _stage = _CaptureStage.live;
    });
  }

  void _usePhoto() {
    final file = _captured;
    if (file == null) return;
    HapticFeedbackUtils.impact();
    Navigator.of(context).pop(file.path);
  }

  void _cancel() {
    HapticFeedbackUtils.impact();
    Navigator.of(context).pop();
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildPreviewLayer(),
            _buildLogoWatermark(),
            _buildTopBar(context),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewLayer() {
    if (_initializing) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (_initError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _initError!,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (_initErrorDetail != null && _initErrorDetail!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _initErrorDetail!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _bootstrapping
                    ? null
                    : () {
                        HapticFeedbackUtils.impact();
                        _bootstrap();
                      },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  L10n.get("retake"),
                  style: const TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_stage == _CaptureStage.review && _captured != null) {
      return Center(
        child: Image.file(
          File(_captured!.path),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // `previewSize` is always reported in the camera's sensor orientation
    // (landscape, e.g. 1920x1080). If we hand those raw dims to `SizedBox`
    // on a portrait UI, `CameraPreview`'s internal `AspectRatio` gets tight
    // landscape constraints it can't satisfy → the texture gets stretched
    // into a landscape box (looks like a fish-eye / squashed preview).
    //
    // Swap width/height when the UI is portrait so the box matches the
    // orientation `CameraPreview` actually lays out for. `FittedBox(cover)`
    // then scales that correctly-proportioned box to fill the screen.
    final previewSize = controller.value.previewSize ?? const Size(4, 3);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final boxWidth = isLandscape ? previewSize.width : previewSize.height;
    final boxHeight = isLandscape ? previewSize.height : previewSize.width;

    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: boxWidth,
          height: boxHeight,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildLogoWatermark() {
    // Vertically align with the shutter button inside the bottom bar.
    // Shutter button is 84px tall; centering a ~64px logo on the same line
    // means (shutterCenter - 32) from the screen bottom.
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      right: 24,
      bottom: bottomPadding + 26,
      child: IgnorePointer(
        // Transparent brand mark — no rounded chip / dark backdrop. The PNG
        // already has a transparent background, and a soft drop shadow keeps
        // it legible over varied scenes without competing visual weight.
        child: Image.asset(
          "assets/icon/components/brand_logo_transparent.png",
          width: 64,
          height: 64,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        padding: EdgeInsets.only(top: topPadding + 8, left: 8, right: 8, bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.45),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            _CameraIconButton(
              icon: Icons.close,
              onPressed: _cancel,
              tooltip: L10n.get("close"),
            ),
            const Spacer(),
            if (_stage == _CaptureStage.live)
              _CameraIconButton(
                icon: _flashIcon,
                onPressed: _cycleFlash,
                tooltip: L10n.get("flash"),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: bottomPadding + 20,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: _stage == _CaptureStage.live
            ? _buildLiveControls()
            : _buildReviewControls(),
      ),
    );
  }

  Widget _buildLiveControls() {
    final canShoot = !_initializing &&
        _initError == null &&
        !_capturing &&
        _controller != null &&
        _controller!.value.isInitialized;
    // Shutter button is radially symmetric — no need to rotate it.
    return Center(
      child: _ShutterButton(
        onPressed: canShoot ? _takePicture : null,
        busy: _capturing,
      ),
    );
  }

  Widget _buildReviewControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _CameraTextButton(
          icon: Icons.refresh,
          label: L10n.get("retake"),
          onPressed: _retake,
        ),
        _CameraTextButton(
          icon: Icons.check,
          label: L10n.get("use_photo"),
          filled: true,
          onPressed: _usePhoto,
        ),
      ],
    );
  }
}

class _CameraIconButton extends StatelessWidget {
  const _CameraIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
    final t = tooltip;
    if (t == null) return button;
    return Tooltip(message: t, child: button);
  }
}

class _ShutterButton extends StatefulWidget {
  const _ShutterButton({required this.onPressed, required this.busy});

  final VoidCallback? onPressed;
  final bool busy;

  @override
  State<_ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<_ShutterButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const size = 84.0;
    final enabled = widget.onPressed != null && !widget.busy;
    const base = BlueThemeColors.primary;

    final shadows = _pressed || !enabled
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : [
            ...ThreeDSurfaceStyle.floatingOrbHaloShadows(context, base),
            ...ThreeDSurfaceStyle.elevatedShadows(context),
          ];

    return Semantics(
      label: L10n.get("take_photo"),
      button: true,
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
            boxShadow: shadows,
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Center(
              child: widget.busy
                  ? const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.photo_camera,
                      color: Colors.white,
                      size: 38,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraTextButton extends StatelessWidget {
  const _CameraTextButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bg = filled ? Colors.white : Colors.black.withValues(alpha: 0.45);
    final fg = filled ? Colors.black : Colors.white;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
