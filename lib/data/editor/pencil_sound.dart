import 'dart:async';
import 'dart:math';

import 'package:audio_session/audio_session.dart';
import 'package:audioplayers/audioplayers.dart' hide AVAudioSessionCategory;
import 'package:saber/data/prefs.dart';
import 'package:saber/service/log/log.dart';

/// Emulates the scratchy sound of pencil on paper.
abstract class PencilSound {
  static const _source = 'audio/white-noise-8117.ogg';
  static final _player = AudioPlayer(playerId: 'pencilSoundEffect')
    ..setSourceAsset(_source)
    ..setPlayerMode(PlayerMode.lowLatency)
    ..setVolume(0.1)
    ..setReleaseMode(ReleaseMode.loop);

  /// A timer that fades out the sound when the user stops drawing,
  /// instead of abruptly stopping it.
  static Timer? _pauseTimer;

  /// Loads the audio file into the audio cache
  /// and sets the audio context.
  ///   static Future<void> preload() => Future.wait([
  //         stows.pencilSoundEffect.waitUntilRead().then((_) => setAudioContext()),
  //         _player.audioCache.loadPath(_source),
  //       ]);
  static Future<void> preload() async {
    await stows.pencilSoundEffect.waitUntilRead();
    Log.w('PencilSound setting audio context');

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      // 环境音频。与其他音频混合播放：遵循静音开关；不阻止屏幕锁定；不争夺音频焦点
      avAudioSessionCategory: AVAudioSessionCategory.ambient,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
        flags: AndroidAudioFlags.audibilityEnforced,
      ),
      ohosAudioAttributes: OhosAudioAttributes(
        streamUsage: StreamUsage.music,
      ),
    ));

    Log.w('PencilSound loading audio source');
    _player.audioCache.loadPath(_source);
  }

  // static Future<void> setAudioContext() =>
  //     AudioPlayer.global.setAudioContext(AudioContextConfig(
  //       // Prevents the pencil sound interrupting other audio, like music.
  //       focus: Platform.isIOS
  //           ? AudioContextConfigFocus.gain
  //           : AudioContextConfigFocus.mixWithOthers,
  //       // Doesn't play the sound when the device is in silent mode.
  //       respectSilence: stows.pencilSound.value.respectSilence,
  //     ).build());
  
  /// setAudioContext 在鸿蒙平台会卡住，改用 audio_session 设置
  // static Future<void> setAudioContext() async {
  //   // audioplayers v6.1.0 的 API, do not support respectSilence param
  //   const config = AudioContext(
  //     iOS: AudioContextIOS(
  //       category: AVAudioSessionCategory.playback,  // 忽略静音模式
  //       options: [
  //         AVAudioSessionOptions.mixWithOthers,  // 与其他音频混合播放
  //       ],
  //     ),
  //     android: AudioContextAndroid(
  //       isSpeakerphoneOn: false,
  //       stayAwake: false,
  //       contentType: AndroidContentType.music,
  //       usageType: AndroidUsageType.media,
  //       // AndroidAudioFocus.none,  // 不抢占音频焦点 this option is incompatible with audioplayers 6.1
  //       // 短暂获得焦点，允许其他音频降低音量
  //       audioFocus: AndroidAudioFocus.gainTransientMayDuck,
  //     ),
  //     ohos: AudioContextOhos(
  //       isSpeakerphoneOn: false,
  //       stayAwake: false,
  //       usageType: OhosUsageType.music,
  //     ),
  //   );
  //
  //   await AudioPlayer.global.setAudioContext(config);
  // }

  static void resume() {
    _pauseTimer?.cancel();
    _limitPlaybackRate();
    _player.setVolume(0);
    
    // 添加异常处理，避免音频焦点问题
    try {
      _player.resume();
    } catch (e) {
      Log.w('PencilSound resume failed: $e');
    }
  }

  static void pause() {
    if (_player.state == PlayerState.paused) return;

    const numTicks = 4;
    var tick = 0;
    _limitPlaybackRate();
    _pauseTimer?.cancel();
    _pauseTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      tick++;
      _setVolume(0);
      if (tick >= numTicks) {
        _player.pause();
        _pauseTimer?.cancel();
      }
    });
  }

  /// Called when the pointer moves.
  /// [distance] is the distance travelled by the pointer this frame.
  static void update(double distance) {
    const maxVolume = 0.5;
    final speed = min(1, distance / 100);
    _setVolume(speed * maxVolume);
    _player.setPlaybackRate(1 - (1 - speed) * 0.5);
  }

  static bool get isPlaying => _player.state == PlayerState.playing;

  /// Sets the volume to the average of the current volume and the new volume,
  /// to smooth out sudden jumps in volume.
  static void _setVolume(double volume) {
    volume = (volume + _player.volume) / 2;
    _player.setVolume(volume);
  }

  /// Limits the playback rate to prevent the sound being too crackly
  /// when starting and stopping a stroke.
  static void _limitPlaybackRate([double limit = 0.7]) {
    if (_player.playbackRate > limit) _player.setPlaybackRate(limit);
  }
}

// enum PencilSoundSetting {
//   /// Pencil sound effect is disabled
//   off(icon: FontAwesomeIcons.bellSlash),
//
//   /// Pencil sound effect is enabled
//   on(icon: FontAwesomeIcons.solidBell);
//
//   const PencilSoundSetting({required this.icon});
//
//   final IconData icon;
//
//   String get description => switch (this) {
//         PencilSoundSetting.off =>
//           t.settings.prefDescriptions.pencilSoundSetting.off,
//         PencilSoundSetting.on =>
//           t.settings.prefDescriptions.pencilSoundSetting.onAlways,
//       };
//
//   // bool get respectSilence => switch (this) {
//   //       PencilSoundSetting.off => true,
//   //       PencilSoundSetting.onButNotInSilentMode => true,
//   //       PencilSoundSetting.onAlways => false,
//   //     };
//
//   static const codec = EnumCodec(values);
// }
