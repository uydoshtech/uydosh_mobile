import "dart:async" show unawaited;

import "package:audioplayers/audioplayers.dart";
import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import "package:uy_dosh/base/state/sound_effects_state.dart";
import "package:uy_dosh/base/utils/audio_playback_environment.dart";

enum UiSound {
  refresh,
  success,
  error,
  like,
  messageIncoming,
}

class SoundService {
  factory SoundService() => _instance;
  SoundService._internal();
  static final SoundService _instance = SoundService._internal();

  static const String _refreshWhooshAsset = "sounds/whoosh_refresh.m4a";
  static const String _successAsset = "sounds/success.m4a";
  static const String _errorAsset = "sounds/error.m4a";
  static const String _likeAsset = "sounds/like.m4a";
  static const String _messageIncomingAsset = "sounds/like.m4a";

  // Keep separate players so overlapping sounds don't cut each other off.
  final AudioPlayer _refreshPlayer = AudioPlayer();
  final AudioPlayer _uiPlayer = AudioPlayer();
  final AudioPlayer _successPlayer = AudioPlayer();
  final AudioPlayer _errorPlayer = AudioPlayer();

  bool _initialized = false;
  Future<void>? _initFuture;

  final Map<UiSound, DateTime> _lastPlayedAt = <UiSound, DateTime>{};
  final Map<AudioPlayer, Future<void>> _opChainByPlayer =
      <AudioPlayer, Future<void>>{};

  /// Best-effort warm-up of sound assets/players to reduce "first play" latency.
  ///
  /// This does **not** play audio. It only initializes players and primes the
  /// asset sources so the first real user-triggered sound is instant.
  Future<void> preload() async {
    if (!_isEnabled()) return;
    if (kIsWeb) return;
    if (await AudioPlaybackEnvironment.shouldSkipAudioPlayback()) return;
    try {
      await _ensureInitialized();
      await Future.wait([
        _prime(_refreshPlayer, _refreshWhooshAsset),
        _prime(_successPlayer, _successAsset),
        _prime(_errorPlayer, _errorAsset),
        _prime(_uiPlayer, _likeAsset),
        _prime(_uiPlayer, _messageIncomingAsset),
      ]);
    } catch (_) {
      // Ignore warm-up failures (missing assets / platform restrictions).
    }
  }

  Future<void> _prime(AudioPlayer player, String asset) async {
    _opChainByPlayer[player] =
        (_opChainByPlayer[player] ?? Future<void>.value()).then((_) async {
      try {
        await player.setSource(AssetSource(asset));
        // Some platforms keep an internal handle "hot" after stop.
        try {
          await player.stop();
        } catch (_) {}
      } catch (_) {}
    });
    await _opChainByPlayer[player];
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initFuture ??= () async {
      final players = [_refreshPlayer, _uiPlayer, _successPlayer, _errorPlayer];
      for (final p in players) {
        await p.setPlayerMode(PlayerMode.lowLatency);
      }

      // UI sfx must never interrupt or duck other audio the user is listening
      // to (music apps, YouTube, podcasts, calls, etc.).
      //
      // iOS: `AVAudioSessionCategory.playback` + `mixWithOthers` plays along
      // with other audio sessions without pausing them. We deliberately do NOT
      // use `ambient` because it is silenced by the Ring/Silent switch and
      // would cause users to hear no UI sound at all when their phone is on
      // silent (which is a common default).
      //
      // Android: request no audio focus (`AndroidAudioFocus.none`) so we do
      // not duck or pause other players. Keep the stream tagged as `media`
      // (music stream) so it is governed by the normal media volume slider
      // rather than the notification/ring stream.
      final ctx = AudioContext(
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

      for (final p in players) {
        await p.setAudioContext(ctx);
      }

      // Default levels (we'll override per sound).
      await _refreshPlayer.setVolume(0.12);
      await _uiPlayer.setVolume(0.25);
      await _successPlayer.setVolume(0.35);
      await _errorPlayer.setVolume(0.30);

      _initialized = true;
    }();
    await _initFuture;
  }

  bool _isEnabled() => SoundEffectsState().isEnabled;

  bool _throttled(UiSound sound, Duration throttle) {
    final now = DateTime.now();
    final last = _lastPlayedAt[sound];
    if (last != null && now.difference(last) < throttle) return true;
    _lastPlayedAt[sound] = now;
    return false;
  }

  void playRefreshWhoosh() {
    // Pull-to-refresh is user-initiated; keep it very subtle.
    play(
      UiSound.refresh,
      volume: 0.12,
      throttle: const Duration(milliseconds: 900),
    );
  }

  void playSuccess() {
    play(UiSound.success,
        volume: 0.22, throttle: const Duration(milliseconds: 250));
  }

  void playError() {
    // Errors can happen in bursts; throttle harder.
    play(UiSound.error,
        volume: 0.18, throttle: const Duration(milliseconds: 600));
  }

  void playLike() {
    play(UiSound.like,
        volume: 0.10, throttle: const Duration(milliseconds: 80));
  }

  void playIncomingMessage() {
    // Foreground messages can arrive in bursts; keep it subtle + throttled.
    play(
      UiSound.messageIncoming,
      // Use the same timbre as the favorites "like" sound, but ~2x quieter.
      volume: 0.056,
      throttle: const Duration(milliseconds: 500),
    );
  }

  void play(
    UiSound sound, {
    double? volume,
    Duration throttle = const Duration(milliseconds: 80),
  }) {
    if (!_isEnabled()) return;
    if (_throttled(sound, throttle)) return;

    // Avoid noisy failures on web where autoplay can be blocked.
    if (kIsWeb) {
      // Still attempt; if browser blocks, we silently ignore.
    }

    unawaited(_playImpl(sound, volume: volume));
  }

  Future<void> _playImpl(UiSound sound, {double? volume}) async {
    if (await AudioPlaybackEnvironment.shouldSkipAudioPlayback()) return;
    try {
      await _ensureInitialized();
    } catch (_) {
      return;
    }

    final asset = switch (sound) {
      UiSound.refresh => _refreshWhooshAsset,
      UiSound.success => _successAsset,
      UiSound.error => _errorAsset,
      UiSound.like => _likeAsset,
      UiSound.messageIncoming => _messageIncomingAsset,
    };

    final player = switch (sound) {
      UiSound.refresh => _refreshPlayer,
      UiSound.success => _successPlayer,
      UiSound.error => _errorPlayer,
      _ => _uiPlayer,
    };

    // Serialize stop→play per player to avoid "stutter" caused by overlapping
    // refresh triggers or rapid replays.
    _opChainByPlayer[player] =
        (_opChainByPlayer[player] ?? Future<void>.value()).then((_) async {
      try {
        if (volume != null) await player.setVolume(volume);
        try {
          await player.stop();
        } catch (_) {}
        await player.play(AssetSource(asset));
      } catch (_) {
        // If the asset isn't found or the platform blocks playback (web), ignore.
      }
    });
    await _opChainByPlayer[player];

    // Android: if we're not on Android, nothing special. Keeping this branch
    // lets us easily extend platform behavior later.
    if (defaultTargetPlatform == TargetPlatform.android) {
      // no-op
    }
  }
}
