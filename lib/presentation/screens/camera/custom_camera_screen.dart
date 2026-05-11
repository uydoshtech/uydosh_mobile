import "dart:io";
import "dart:math" as math;

import "package:camera/camera.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:image/image.dart" as img;
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/watermark_service.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/presentation/screens/camera/photo_review_screen.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Payload for the background-isolate crop job in [_cropJpegToAspect].
@immutable
class _CropJob {
  const _CropJob({required this.sourcePath, required this.targetAspect});

  final String sourcePath;

  /// Desired output aspect ratio, expressed as `width / height` after the
  /// image's EXIF orientation has been baked in. For example, a portrait
  /// phone screen (1179×2556) passes ~0.461 and we center-crop the sides of
  /// a landscape 16:9 capture to hit that.
  final double targetAspect;
}

/// Center-crops [job.sourcePath] to the given aspect ratio and returns the
/// path of the new JPEG written next to the source. Returns `null` if the
/// file can't be decoded, if its aspect ratio already matches (within a
/// small tolerance), or if writing the output fails — callers fall back to
/// the original file in that case.
///
/// Runs on a background isolate via [compute] because decoding/encoding a
/// ~2 MP JPEG on the UI thread visibly stutters the shutter animation.
String? _cropJpegToAspect(_CropJob job) {
  try {
    final bytes = File(job.sourcePath).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;
    // Bake any EXIF orientation into pixels so our center-crop math lines up
    // with what the UI will actually display. Mirrors what
    // `watermark_service.dart` does for the same reason.
    final oriented = img.bakeOrientation(decoded);

    final srcW = oriented.width;
    final srcH = oriented.height;
    if (srcW <= 0 || srcH <= 0) return null;
    final srcAspect = srcW / srcH;

    // Aspect ratios within ~0.5% — treat as already-matching and skip the
    // re-encode entirely. Avoids needlessly re-compressing a JPEG that
    // would lose a tiny bit of quality for a sub-pixel crop.
    if ((srcAspect - job.targetAspect).abs() / job.targetAspect < 0.005) {
      return null;
    }

    int cropW;
    int cropH;
    if (srcAspect > job.targetAspect) {
      // Source is wider than target → crop the sides (left/right).
      cropH = srcH;
      cropW = (srcH * job.targetAspect).round().clamp(1, srcW);
    } else {
      // Source is taller than target → crop the top/bottom.
      cropW = srcW;
      cropH = (srcW / job.targetAspect).round().clamp(1, srcH);
    }
    final cropX = ((srcW - cropW) / 2).round();
    final cropY = ((srcH - cropH) / 2).round();

    final cropped = img.copyCrop(
      oriented,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );

    // Write a sibling file instead of overwriting: the plugin's temp file
    // name encodes the capture timestamp and we want to keep the original
    // around for debugging / in case some downstream code already retained
    // the path before our crop finished.
    final dotIdx = job.sourcePath.lastIndexOf(".");
    final outPath = dotIdx <= job.sourcePath.lastIndexOf("/")
        ? "${job.sourcePath}_cropped.jpg"
        : "${job.sourcePath.substring(0, dotIdx)}_cropped"
            "${job.sourcePath.substring(dotIdx)}";
    File(outPath).writeAsBytesSync(img.encodeJpg(cropped, quality: 92));
    return outPath;
  } catch (_) {
    return null;
  }
}

/// Full-screen custom camera with a UyDosh logo pinned to the bottom-right,
/// aligned with the shutter button — mirrors the 3D scan scene aesthetic.
///
/// Returns the captured image's absolute file path via [Navigator.pop],
/// or `null` if the user cancels / an error occurs.
class CustomCameraScreen extends StatefulWidget {
  const CustomCameraScreen({super.key});

  static const double _kReviewBottomBarExtraReserve = 0;

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
      // it requires the `PERMISSION_CAMERA=1` Podfile macro and even when
      // the macro is set, `request()` has well-documented races where it
      // resolves with stale `.denied` while AVFoundation is still flipping
      // the underlying status. The `camera` plugin's iOS implementation
      // calls AVFoundation's `requestAccess(for: .video)` itself inside
      // `initialize()` (below, via `_setUpController`), which is the
      // source of truth and returns a clean `CameraAccessDenied`
      // exception if the user actually denies — we let it.
      //
      // The pre-permission **rationale** screen (see
      // [CameraPermissionGate] in `photo_picker.dart`) still runs before
      // this screen is pushed; it only shows our brand explanation, then
      // returns. The OS-level dialog therefore fires from `initialize()`
      // here on first run. The `_bootstrapping` guard in
      // [didChangeAppLifecycleState] is what keeps the spurious
      // `inactive` event during that dialog from tearing down the
      // half-initialized controller and leaving the preview frozen.
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
    // Snapshot the visible viewport aspect ratio *before* awaiting anything,
    // so we crop the capture to exactly what the user was framing in the
    // preview. The live preview uses `BoxFit.cover` to fill the Scaffold
    // body (see `_buildPreviewLayer`), so the Scaffold body's aspect is the
    // what-you-see-is-what-you-get framing. We must capture this synchronously
    // because by the time `takePicture()` resolves, the user may have rotated
    // the device and MediaQuery would report a different orientation.
    final viewportSize = MediaQuery.sizeOf(context);
    final viewportAspect = viewportSize.width / viewportSize.height;
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
      // Crop the sensor-sized JPEG down to the viewport's aspect ratio so
      // the review screen shows exactly the frame the user composed. The
      // live preview fills the screen via `BoxFit.cover`, which crops parts
      // of the sensor frame that don't fit — without this step, the review
      // stage would then show those previously-hidden pixels as black-bar
      // letterboxing (see `PhotoReviewWithLogo`, which uses `AspectRatio`
      // at the image's real dimensions). Runs on a background isolate so a
      // ~2 MP decode/encode doesn't jank the capture animation.
      XFile outputFile = file;
      try {
        final croppedPath = await compute(
          _cropJpegToAspect,
          _CropJob(sourcePath: file.path, targetAspect: viewportAspect),
        );
        if (croppedPath != null) outputFile = XFile(croppedPath);
      } catch (e, st) {
        // Never block the user on crop failure: fall back to the full-frame
        // capture. They'll just see the letterboxed review as before.
        logger.w("Viewport crop failed; using uncropped capture",
            error: e, stackTrace: st);
      }
      setStateIfMounted(() {
        _captured = outputFile;
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
            // Live preview shows the brand mark in the same proportional
            // spot it'll land on the saved photo (driven by
            // [WatermarkPlacement]), so the user sees a true preview of
            // the watermark while framing the shot. The review stage
            // draws its own photo-bounds-anchored copy inside
            // [_PhotoReviewWithLogo], so we skip the screen-level one
            // then.
            if (_stage == _CaptureStage.live) _buildLogoWatermark(),
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
      // Same widget the standalone [PhotoReviewScreen] uses, so the camera
      // path and the image_picker fallback path render identically.
      // Reserve room at the bottom so the photo's bottom-right brand
      // logo finishes above the Retake / Use-photo buttons instead of
      // sitting behind them. Must stay in sync with the review-stage
      // bottom padding in [_buildBottomBar].
      final topInset = MediaQuery.paddingOf(context).top;
      final bottomInset = MediaQuery.paddingOf(context).bottom;
      return Padding(
        padding: EdgeInsets.only(
          top: topInset,
          bottom: bottomInset + CustomCameraScreen._kReviewBottomBarExtraReserve,
        ),
        child: PhotoReviewWithLogo(path: _captured!.path),
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
    // Match [WatermarkPlacement] exactly so the live preview is a true
    // preview of where the watermark will land on the saved photo. We
    // measure against the screen's shorter side here (the viewfinder
    // fills the screen via `BoxFit.cover`); on the post-capture image
    // [WatermarkService] does the same against the photo's shorter side.
    final mq = MediaQuery.of(context);
    final shorter = math.min(mq.size.width, mq.size.height);
    final logoSize = shorter * WatermarkPlacement.sizeFraction;
    final margin = shorter * WatermarkPlacement.marginFraction;
    return Positioned(
      right: margin,
      bottom: margin,
      width: logoSize,
      height: logoSize,
      child: IgnorePointer(
        child: Image.asset(
          "assets/icon/components/brand_logo_transparent.png",
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
    final isReview = _stage == _CaptureStage.review;
    // The review stage shows glassy translucent pills over the captured
    // photo, and we want the bottom-right brand mark to stay visible
    // underneath them. A heavy black gradient defeats that, so we use a
    // gentler wash here. The live stage keeps a slightly darker gradient
    // to anchor the white shutter button against bright scenes.
    final bottomGradientAlpha = isReview ? 0.28 : 0.5;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          // In the review stage, lift the Retake / Use-photo buttons so
          // they no longer overlap the bottom-right brand logo baked
          // into the captured photo (kept in sync with the photo
          // reserve in [_buildPreviewLayer]). The live stage keeps the
          // tighter spacing under the shutter button.
          // Reduced by 20 so the buttons sit closer to the bottom edge.
          bottom: bottomPadding + (isReview ? 16 : 20),
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: bottomGradientAlpha),
              Colors.transparent,
            ],
          ),
        ),
        child: isReview ? _buildReviewControls() : _buildLiveControls(),
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
        UyDoshReviewPillButton(
          icon: Icons.refresh,
          label: L10n.get("retake"),
          onPressed: _retake,
        ),
        UyDoshReviewPillButton(
          icon: Icons.check,
          label: L10n.get("use_photo"),
          onPressed: _usePhoto,
          primary: true,
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
