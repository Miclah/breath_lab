import 'package:audioplayers/audioplayers.dart';

/// Plays short audio cues for guided table sessions.
class AudioService {
  AudioService() : _player = AudioPlayer();

  final AudioPlayer _player;

  Future<void> playHoldStart() => _play('hold_start.wav');
  Future<void> playRestStart() => _play('rest_start.wav');
  Future<void> playCountdownTick() => _play('countdown_tick.wav');
  Future<void> playRoundDone() => _play('round_done.wav');
  Future<void> playPbAchieved() => _play('pb_achieved.wav');

  Future<void> _play(String fileName) async {
    await _player.stop();
    await _player.play(AssetSource('audio/$fileName'));
  }

  void dispose() => _player.dispose();
}
