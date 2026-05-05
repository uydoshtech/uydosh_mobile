import "dart:async";

import "package:audioplayers/audioplayers.dart";
import "package:flutter/foundation.dart" show TargetPlatform, defaultTargetPlatform;
import "package:flutter/services.dart";

/// Utility for playing the message send confirmation sound at full volume.
/// Uses custom asset when possible; falls back to SystemSound on Android.
class SendSoundUtils {
  static final AudioPlayer _player = AudioPlayer();

  /// Dedicated player for picker/spinner tick sounds.
  /// Uses low-latency mode and throttling for smooth scroll feedback.
  static final AudioPlayer _selectionPlayer = AudioPlayer();
  static DateTime? _lastSelectionSoundAt;
  static const Duration _selectionThrottle = Duration(milliseconds: 60);

  static const String _clickAsset = "sounds/click.m4a";

  static bool _selectionPlayerInitialized = false;

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
        await _player.play(AssetSource(_clickAsset));
      } catch (_) {
        // Ignore AbortError and similar (e.g. play interrupted by pause on web).
      }
    });
    await _sendPlayerOperationFuture;
  }

  /// Plays the click sound for spinner/picker selection feedback.
  /// Throttled to avoid overlap during rapid scroll; uses low-latency mode.
  static void playSelectionSound() {
    final now = DateTime.now();
    if (_lastSelectionSoundAt != null &&
        now.difference(_lastSelectionSoundAt!) < _selectionThrottle) {
      return;
    }
    _lastSelectionSoundAt = now;
    _ensureSelectionPlayerReady();
    unawaited(
      _selectionPlayer
          .play(AssetSource(_clickAsset))
          .catchError((_) { /* Ignore AbortError on web */ }),
    );
  }
}
