import "dart:async";

import "package:audioplayers/audioplayers.dart";
import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import "package:flutter/services.dart";
import "package:uy_dosh/base/state/sound_effects_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// Utility for playing the message send confirmation sound at full volume.
/// Uses custom asset when possible; falls back to SystemSound on Android.
class SendSoundUtils {
  static final AudioPlayer _player = AudioPlayer();

  /// Dedicated player for picker/spinner tick sounds.
  /// Uses low-latency mode and throttling for smooth scroll feedback.
  static final AudioPlayer _selectionPlayer = AudioPlayer();
  static DateTime? _lastBundledClickAt;
  /// Short taps / sliders: keep responsive.
  static const Duration _bundledClickMinInterval =
      Duration(milliseconds: 60);
  /// Wheels often settle in bursts; a longer gap avoids clicks piling up.
  static const Duration _wheelBundledClickMinInterval =
      Duration(milliseconds: 120);

  static const String _clickAssetNative = "sounds/click.m4a";
  static const String _clickAssetWebBundle = "assets/sounds/click_web.wav";

  /// Web: load PCM via [BytesSource] so playback uses a `data:` URL. Asset URLs
  /// hit `HTMLAudioElement` with `crossOrigin = anonymous` (see
  /// audioplayers_web [WrappedPlayer]); missing CORS on static hosting yields
  /// `MEDIA_ELEMENT_ERROR` even for valid MP3/M4A.
  static Future<Uint8List>? _webClickSoundBytesFuture;

  static Future<Source> _clickSource() async {
    if (!kIsWeb) return AssetSource(_clickAssetNative);
    _webClickSoundBytesFuture ??=
        rootBundle.load(_clickAssetWebBundle).then((bd) => bd.buffer.asUint8List());
    final bytes = await _webClickSoundBytesFuture!;
    return BytesSource(bytes, mimeType: "audio/wav");
  }

  static bool _selectionPlayerInitialized = false;

  /// Shared future so concurrent calls wait for init to complete.
  static Future<void>? _sendPlayerInitFuture;

  /// Serializes send-player operations to avoid play() interrupted by pause()
  /// (AbortError on web when stop/play race).
  static Future<void> _sendPlayerOperationFuture = Future<void>.value();

  /// One bundled click at a time on [_selectionPlayer] (avoids overlapping
  /// plays that get louder with rapid spins).
  static Future<void> _selectionAssetChain = Future<void>.value();

  /// Audio context that mixes with other audio instead of interrupting it.
  /// Ensures UI click/send sounds don't pause music, YouTube, or podcasts,
  /// while still playing when the phone is on silent (iOS) and using the
  /// standard media volume slider (Android).
  static AudioContext _mixingContext() => AudioContext(
        android: const AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {AVAudioSessionOptions.mixWithOthers},
        ),
      );

  static void _ensureSelectionPlayerReady() {
    if (_selectionPlayerInitialized) return;
    _selectionPlayerInitialized = true;
    _selectionPlayer.setPlayerMode(PlayerMode.lowLatency);
    _selectionPlayer.setVolume(1.0);
    unawaited(_selectionPlayer.setAudioContext(_mixingContext()));
  }

  /// Ensures send player is configured for audioplayers 6.0+ compatibility.
  static Future<void> _ensureSendPlayerReady() async {
    _sendPlayerInitFuture ??= () async {
      await _player.setPlayerMode(PlayerMode.lowLatency);
      await _player.setVolume(1.0);
      await _player.setAudioContext(_mixingContext());
    }();
    await _sendPlayerInitFuture;
  }

  /// Plays the send confirmation sound at full volume (1.0).
  /// Uses SystemSound (reliable on Android) with audioplayers fallback for iOS.
  static void playSendSound() {
    if (!SoundEffectsState().isEnabled) return;
    unawaited(_playSendSoundImpl());
  }

  static Future<void> _playSendSoundImpl() async {
    // SystemSound works reliably on Android; no-op on iOS
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        await SystemSound.play(SystemSoundType.click);
        return;
      } catch (_) {}
    }

    // Custom asset via audioplayers (iOS, desktop, or Android fallback).
    // Serialize operations to avoid AbortError on web (play interrupted by pause).
    _sendPlayerOperationFuture = _sendPlayerOperationFuture.then((_) async {
      try {
        await _ensureSendPlayerReady();
        try {
          await _player.stop();
        } catch (_) {}
        await _player.play(await _clickSource());
      } catch (_) {
        // Ignore AbortError and similar (e.g. play interrupted by pause on web).
      }
    });
    await _sendPlayerOperationFuture;
  }

  /// Plays the bundled click for taps, sliders, [RotationSpinner], etc.
  /// Throttled; serialized stop→play so rapid triggers do not stack volume.
  static void playSelectionSound() {
    if (!SoundEffectsState().isEnabled) return;
    _enqueueBundledSelectionClick(
      minInterval: _bundledClickMinInterval,
      volume: 1.0,
    );
  }

  /// For [CupertinoPicker] wheels: on iOS there is no bundled click (picker
  /// uses system tick while scrolling); still give [HapticFeedbackUtils.impact]
  /// at settle. On other platforms, plays the bundled click with the same light
  /// impact fired immediately before [AudioPlayer.play] so taptic and audio
  /// stay aligned.
  static void playCupertinoWheelSound() {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      HapticFeedbackUtils.impact();
      return;
    }
    if (!SoundEffectsState().isEnabled) {
      HapticFeedbackUtils.impact();
      return;
    }
    _enqueueBundledSelectionClick(
      minInterval: _wheelBundledClickMinInterval,
      volume: 0.82,
      hapticImpactImmediatelyBeforePlay: true,
    );
  }

  static void _enqueueBundledSelectionClick({
    required Duration minInterval,
    required double volume,
    bool hapticImpactImmediatelyBeforePlay = false,
  }) {
    final now = DateTime.now();
    if (_lastBundledClickAt != null &&
        now.difference(_lastBundledClickAt!) < minInterval) {
      return;
    }
    _lastBundledClickAt = now;
    _ensureSelectionPlayerReady();
    _selectionAssetChain = _selectionAssetChain.then((_) async {
      try {
        try {
          await _selectionPlayer.stop();
        } catch (_) {}
        await _selectionPlayer.setVolume(volume);
        final src = await _clickSource();
        if (hapticImpactImmediatelyBeforePlay) {
          HapticFeedbackUtils.impact();
        }
        await _selectionPlayer.play(src);
      } catch (_) {
        /* Ignore AbortError / web decode failures */
      }
    });
    unawaited(_selectionAssetChain);
  }
}
