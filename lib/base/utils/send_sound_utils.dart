import "dart:async";

import "package:audioplayers/audioplayers.dart";
import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import "package:flutter/services.dart";
import "package:uy_dosh/base/state/sound_effects_state.dart";

/// Utility for playing the message send confirmation sound at full volume.
/// Uses custom asset when possible; falls back to SystemSound on Android.
class SendSoundUtils {
  static final AudioPlayer _player = AudioPlayer();

  /// Dedicated player for generic picker/spinner tick sounds.
  /// Uses low-latency mode and throttling for smooth scroll feedback.
  static final AudioPlayer _selectionPlayer = AudioPlayer();
  /// Metro line + station wheels (search + listing forms). Separate from
  /// the location wheel so mutually exclusive metro/location filters do not
  /// share one player/throttle and sound identical or drop ticks.
  static final AudioPlayer _metroWheelPlayer = AudioPlayer();
  /// Dedicated to the district/location wheel only.
  static final AudioPlayer _locationWheelPlayer = AudioPlayer();
  static DateTime? _lastSelectionSoundAt;
  static DateTime? _lastMetroWheelSoundAt;
  static DateTime? _lastLocationWheelSoundAt;
  static const Duration _selectionThrottle = Duration(milliseconds: 60);

  static const String _clickAssetNative = "sounds/click.m4a";
  static const String _clickAssetWebBundle = "assets/sounds/click_web.wav";
  static const String _locationTickAssetNative = "sounds/like.m4a";

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

  /// Softer Kenney “select” tick for the location wheel on mobile/desktop;
  /// web falls back to [ _clickSource ] (WAV bytes) so hosting CORS stays safe.
  static Future<Source> _locationWheelSource() async {
    if (!kIsWeb) return AssetSource(_locationTickAssetNative);
    return _clickSource();
  }

  static bool _selectionPlayerInitialized = false;
  static bool _metroWheelPlayerInitialized = false;
  static bool _locationWheelPlayerInitialized = false;

  /// Shared future so concurrent calls wait for init to complete.
  static Future<void>? _sendPlayerInitFuture;

  /// Serializes send-player operations to avoid play() interrupted by pause()
  /// (AbortError on web when stop/play race).
  static Future<void> _sendPlayerOperationFuture = Future<void>.value();

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

  static void _ensureMetroWheelPlayerReady() {
    if (_metroWheelPlayerInitialized) return;
    _metroWheelPlayerInitialized = true;
    _metroWheelPlayer.setPlayerMode(PlayerMode.lowLatency);
    _metroWheelPlayer.setVolume(1.0);
    unawaited(_metroWheelPlayer.setAudioContext(_mixingContext()));
  }

  static void _ensureLocationWheelPlayerReady() {
    if (_locationWheelPlayerInitialized) return;
    _locationWheelPlayerInitialized = true;
    _locationWheelPlayer.setPlayerMode(PlayerMode.lowLatency);
    _locationWheelPlayer.setVolume(1.0);
    unawaited(_locationWheelPlayer.setAudioContext(_mixingContext()));
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

  /// Plays the click sound for spinner/picker selection feedback.
  /// Throttled to avoid overlap during rapid scroll; uses low-latency mode.
  static void playSelectionSound() {
    if (!SoundEffectsState().isEnabled) return;
    final now = DateTime.now();
    if (_lastSelectionSoundAt != null &&
        now.difference(_lastSelectionSoundAt!) < _selectionThrottle) {
      return;
    }
    _lastSelectionSoundAt = now;
    _ensureSelectionPlayerReady();
    _playOnSelectionPlayer(_selectionPlayer, volume: 1.0);
  }

  /// Metro line and station wheels — full-volume tick, independent of location.
  static void playMetroWheelSound() {
    if (!SoundEffectsState().isEnabled) return;
    final now = DateTime.now();
    if (_lastMetroWheelSoundAt != null &&
        now.difference(_lastMetroWheelSoundAt!) < _selectionThrottle) {
      return;
    }
    _lastMetroWheelSoundAt = now;
    _ensureMetroWheelPlayerReady();
    _playOnSelectionPlayer(_metroWheelPlayer, volume: 1.0);
  }

  /// Location / district wheel — softer tick (`like.m4a` / Kenney select) on
  /// native; web uses the same short click WAV at lower gain.
  static void playLocationWheelSound() {
    if (!SoundEffectsState().isEnabled) return;
    final now = DateTime.now();
    if (_lastLocationWheelSoundAt != null &&
        now.difference(_lastLocationWheelSoundAt!) < _selectionThrottle) {
      return;
    }
    _lastLocationWheelSoundAt = now;
    _ensureLocationWheelPlayerReady();
    _playOnPlayer(
      _locationWheelPlayer,
      source: _locationWheelSource(),
      volume: kIsWeb ? 0.78 : 0.14,
    );
  }

  static void _playOnSelectionPlayer(AudioPlayer player, {required double volume}) {
    _playOnPlayer(player, source: _clickSource(), volume: volume);
  }

  static void _playOnPlayer(
    AudioPlayer player, {
    required Future<Source> source,
    required double volume,
  }) {
    unawaited(
      () async {
        try {
          await player.setVolume(volume);
          await player.play(await source);
        } catch (_) {
          /* Ignore AbortError / web decode failures */
        }
      }(),
    );
  }
}
