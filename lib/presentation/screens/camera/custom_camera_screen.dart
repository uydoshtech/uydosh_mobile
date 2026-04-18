import "dart:async";
import "dart:io";

import "package:camera/camera.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
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

  _CaptureStage _stage = _CaptureStage.live;
  XFile? _captured;

  // Tracks the device's physical tilt (reported by the camera plugin even
  // while the UI is orientation-locked). Drives in-place rotation of the
  // control icons so they stay upright for the user. Apple-Camera style.
  DeviceOrientation _deviceOrientation = DeviceOrientation.portraitUp;

  void _onControllerValueChanged() {
    final value = _controller?.value;
    if (value == null || !value.isInitialized) return;
    final next = value.deviceOrientation;
    if (next != _deviceOrientation) {
      setState(() => _deviceOrientation = next);
    }
  }

  /// Quarter-turn rotation (in turns, where 1.0 = 360°) that brings an
  /// upright widget into the user's physical frame of reference.
  double get _controlsRotationTurns {
    switch (_deviceOrientation) {
      case DeviceOrientation.portraitUp:
        return 0;
      case DeviceOrientation.landscapeLeft:
        return 0.25;
      case DeviceOrientation.portraitDown:
        return 0.5;
      case DeviceOrientation.landscapeRight:
        return -0.25;
    }
  }

  /// Wraps [child] in an [AnimatedRotation] driven by device tilt so the
  /// control stays upright in the user's frame of reference.
  Widget _rotateWithDevice(Widget child) {
    return AnimatedRotation(
      turns: _controlsRotationTurns,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      child: child,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Lock the camera screen to portrait. The `camera` plugin's preview is
    // pinned to the orientation active at `initialize()` time and doesn't
    // rotate reliably on Android, so letting the UI rotate produces a
    // stretched / mis-rotated frame. Standard camera-app UX is to stay in
    // portrait.
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setUpController(_cameras[_cameraIndex]);
    }
  }

  Future<void> _bootstrap() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _initializing = false;
          _initError = L10n.get("camera_unavailable");
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
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _initError = L10n.get("camera_unavailable");
      });
    }
  }

  Future<void> _setUpController(CameraDescription description) async {
    final previous = _controller;
    previous?.removeListener(_onControllerValueChanged);
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;

    try {
      await controller.initialize();
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
    } catch (e, st) {
      logger.e("Camera controller init failed", error: e, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _initError = L10n.get("camera_unavailable");
      });
      return;
    } finally {
      await previous?.dispose();
    }

    if (!mounted) return;
    setState(() {
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
      if (!mounted) return;
      setState(() => _flashMode = next);
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
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() {
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
          child: Text(
            _initError!,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
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

    // `controller.value.aspectRatio` is width / height in the camera's native
    // (landscape) orientation. On a portrait phone we need to fill the screen
    // without distorting the preview → scale it up with Transform.scale using
    // the canonical `size.aspectRatio * cameraAspectRatio` recipe.
    final size = MediaQuery.sizeOf(context);
    final cameraAspectRatio = controller.value.aspectRatio;
    var scale = size.aspectRatio * cameraAspectRatio;
    if (scale < 1) scale = 1 / scale;

    return ClipRect(
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.center,
        child: Center(
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildLogoWatermark() {
    // Vertically align with the shutter button inside the bottom bar.
    // Bottom bar: padding bottom = bottomPadding + 20, top = 16,
    // shutter button height = 76 → shutter center sits
    // (bottomPadding + 20 + 38) from the screen bottom. The logo badge
    // is ~64px tall (48 icon + 8 padding on each side), so to center it
    // on the same line we offset it by (shutterCenter - 32).
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      right: 24,
      bottom: bottomPadding + 26,
      child: IgnorePointer(
        child: _rotateWithDevice(
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: Image.asset(
              "assets/icon/app_logo.png",
              width: 48,
              height: 48,
              fit: BoxFit.contain,
            ),
          ),
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
            _rotateWithDevice(
              _CameraIconButton(
                icon: Icons.close,
                onPressed: _cancel,
                tooltip: L10n.get("close"),
              ),
            ),
            const Spacer(),
            if (_stage == _CaptureStage.live)
              _rotateWithDevice(
                _CameraIconButton(
                  icon: _flashIcon,
                  onPressed: _cycleFlash,
                  tooltip: L10n.get("flash"),
                ),
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
        _rotateWithDevice(
          _CameraTextButton(
            icon: Icons.refresh,
            label: L10n.get("retake"),
            onPressed: _retake,
          ),
        ),
        _rotateWithDevice(
          _CameraTextButton(
            icon: Icons.check,
            label: L10n.get("use_photo"),
            filled: true,
            onPressed: _usePhoto,
          ),
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

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onPressed, required this.busy});

  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: L10n.get("take_photo"),
      button: true,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: busy ? 30 : 58,
              height: busy ? 30 : 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onPressed == null
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.white,
              ),
              child: busy
                  ? const Padding(
                      padding: EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : null,
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
