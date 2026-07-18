import 'package:flutter_tts/flutter_tts.dart';

/// Speaks time callouts during holds and table sessions via the platform
/// TTS engine. Rate/pitch per Design Additions §9 — slightly slower than
/// default, for a calm voice.
class TtsService {
  TtsService() : _tts = FlutterTts() {
    _tts.setSpeechRate(0.45);
    _tts.setPitch(1.0);
  }

  final FlutterTts _tts;
  String? _languageTag;

  /// Sets the voice language ('sk' or 'en'). No-op if already set.
  Future<void> setLanguage(String languageCode) async {
    final tag = languageCode == 'sk' ? 'sk-SK' : 'en-US';
    if (_languageTag == tag) return;
    _languageTag = tag;
    await _tts.setLanguage(tag);
  }

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> stop() => _tts.stop();

  void dispose() => _tts.stop();
}
