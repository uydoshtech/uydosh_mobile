import "dart:async";

import "package:audioplayers/audioplayers.dart";

/// Utility for playing the message send confirmation sound at full volume.
/// Uses a custom sound asset instead of SystemSound for volume control.
class SendSoundUtils {
  static final AudioPlayer _player = AudioPlayer();

  /// Dedicated player for picker/spinner tick sounds.
  /// Uses low-latency mode and throttling for smooth scroll feedback.
  static final AudioPlayer _selectionPlayer = AudioPlayer();
  static DateTime? _lastSelectionSoundAt;
  static const Duration _selectionThrottle = Duration(milliseconds: 60);

  static const String _clickAsset = "sounds/click.wav";

  static bool _selectionPlayerInitialized = false;
  static bool _sendPlayerInitialized = false;

  static void _ensureSelectionPlayerReady() {
    if (_selectionPlayerInitialized) return;
    _selectionPlayerInitialized = true;
    _selectionPlayer.setPlayerMode(PlayerMode.lowLatency);
    _selectionPlayer.setVolume(1.0);
  }

  /// Ensures send player is configured for audioplayers 6.0+ compatibility.
  /// Must await setAudioContext before play to fix Android FileNotFoundException
  /// (see https://github.com/bluefireteam/audioplayers/issues/1786).
  static Future<void> _ensureSendPlayerReady() async {
    if (_sendPlayerInitialized) return;
    _sendPlayerInitialized = true;
    await _player.setPlayerMode(PlayerMode.lowLatency);
    await _player.setVolume(1.0);
    await _player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
        iOS: AudioContextIOS(),
      ),
    );
  }

  /// Plays the send confirmation sound at full volume (1.0).
  /// Fire-and-forget; does not block.
  static void playSendSound() {
    unawaited(_playSendSoundImpl());
  }

  static Future<void> _playSendSoundImpl() async {
    try {
      await _ensureSendPlayerReady();
      await _player.stop();
      await _player.play(AssetSource(_clickAsset));
    } catch (_) {
      // Fire-and-forget: avoid unhandled exceptions; sound is non-critical
    }
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
    _selectionPlayer.play(AssetSource(_clickAsset));
  }
}
