import 'package:audioplayers/audioplayers.dart';

/// Plays short audio cues for guided table sessions. Respects [enabled] and
/// [volume] (0.0-1.0), kept in sync with Settings → Sound & haptics.
class AudioService {
  AudioService({this.enabled = true, this.volume = 1.0})
    : _player = AudioPlayer();

  final AudioPlayer _player;
  bool enabled;
  double volume;

  Future<void> playHoldStart() => _play('hold_start.wav');
  Future<void> playRestStart() => _play('rest_start.wav');
  Future<void> playCountdownTick() => _play('countdown_tick.wav');
  Future<void> playRoundDone() => _play('round_done.wav');
  Future<void> playPbAchieved() => _play('pb_achieved.wav');

  Future<void> _play(String fileName) async {
    if (!enabled) return;
    await _player.stop();
    await _player.play(AssetSource('audio/$fileName'), volume: volume);
  }

  void dispose() => _player.dispose();
}
