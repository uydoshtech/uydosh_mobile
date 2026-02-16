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

  static void _ensureSelectionPlayerReady() {
    if (_selectionPlayerInitialized) return;
    _selectionPlayerInitialized = true;
    _selectionPlayer.setPlayerMode(PlayerMode.lowLatency);
    _selectionPlayer.setVolume(1.0);
  }

  /// Plays the send confirmation sound at full volume (1.0).
  /// Fire-and-forget; does not block.
  static void playSendSound() {
    _player.setVolume(1.0);
    _player.play(AssetSource(_clickAsset));
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
