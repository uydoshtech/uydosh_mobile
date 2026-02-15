import "package:audioplayers/audioplayers.dart";

/// Utility for playing the message send confirmation sound at full volume.
/// Uses a custom sound asset instead of SystemSound for volume control.
class SendSoundUtils {
  static final AudioPlayer _player = AudioPlayer();

  static const String _clickAsset = "sounds/click.wav";

  /// Plays the send confirmation sound at full volume (1.0).
  /// Fire-and-forget; does not block.
  static void playSendSound() {
    _player.setVolume(1.0);
    _player.play(AssetSource(_clickAsset));
  }
}
