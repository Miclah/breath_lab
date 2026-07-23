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

  /// Whether the last [setLanguage] call had to fall back to English
  /// because the requested voice wasn't available on this device.
  bool fellBackToEnglish = false;

  /// Sets the voice language ('sk' or 'en'). No-op if already set. Falls
  /// back to English silently for this session if the requested voice
  /// isn't installed, per PRD §11.
  Future<void> setLanguage(String languageCode) async {
    var tag = languageCode == 'sk' ? 'sk-SK' : 'en-US';
    fellBackToEnglish = false;
    if (tag != 'en-US' && !(await isLanguageAvailable(tag))) {
      tag = 'en-US';
      fellBackToEnglish = true;
    }
    if (_languageTag == tag) return;
    _languageTag = tag;
    await _tts.setLanguage(tag);
  }

  /// Whether the given voice tag (e.g. 'sk-SK') is available on this device.
  Future<bool> isLanguageAvailable(String tag) async {
    final result = await _tts.isLanguageAvailable(tag);
    return result == true || result == 1;
  }

  Future<void> speak(String text) => _tts.speak(text);

  Future<void> stop() => _tts.stop();

  void dispose() => _tts.stop();
}
