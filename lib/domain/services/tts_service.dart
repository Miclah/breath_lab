import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Whether a voice language can be used on this device.
///
/// [unknown] is not a synonym for [unavailable]. It means the platform gave
/// us no way to ask — `flutter_tts` has no Windows binding for
/// `isLanguageAvailable`, so the call throws rather than answering. Treating
/// that silence as a "no" would mean Windows never speaks Slovak even with a
/// Slovak voice installed.
enum TtsLanguageSupport { available, unavailable, unknown }

/// Speaks time callouts during holds and table sessions via the platform
/// TTS engine. Rate/pitch per Design Additions §9 — slightly slower than
/// default, for a calm voice.
///
/// Every call into `flutter_tts` is guarded, because the plugin implements
/// different subsets of its own API per platform. On Windows several methods
/// have no binding at all and throw [MissingPluginException] — which is what
/// made switching the UI to Slovak crash the app.
class TtsService {
  /// [tts] is injectable so tests can drive the failure branches; production
  /// callers pass nothing.
  TtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts() {
    _configure();
  }

  final FlutterTts _tts;
  String? _languageTag;

  /// Whether the last [setLanguage] call had to fall back to English
  /// because the requested voice wasn't available on this device.
  bool fellBackToEnglish = false;

  /// Applies the calm rate/pitch. Awaited inside a guarded body rather than
  /// fired and forgotten from the constructor — an unawaited platform throw
  /// escapes as an unhandled Future error with no call site to blame.
  Future<void> _configure() async {
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
    } on MissingPluginException {
      // Rate and pitch aren't tunable on this platform. The voice still
      // speaks; it just speaks at the system default.
    } on PlatformException {
      // Same outcome, different cause. Not worth surfacing to the user.
    }
  }

  /// Sets the voice language ('sk' or 'en'). No-op if already set. Falls
  /// back to English for this session if the requested voice is known to be
  /// missing, per PRD §11 — but not when we merely failed to ask.
  Future<void> setLanguage(String languageCode) async {
    var tag = languageCode == 'sk' ? 'sk-SK' : 'en-US';
    fellBackToEnglish = false;

    if (tag != 'en-US' &&
        await languageSupport(tag) == TtsLanguageSupport.unavailable) {
      tag = 'en-US';
      fellBackToEnglish = true;
    }

    if (_languageTag == tag) return;
    try {
      await _tts.setLanguage(tag);
      _languageTag = tag;
    } on MissingPluginException {
      // The tag never took, so don't cache it — otherwise the next call
      // short-circuits on a language the engine was never given.
      _languageTag = null;
    } on PlatformException {
      _languageTag = null;
    }
  }

  /// Whether the given voice tag (e.g. 'sk-SK') can be used on this device.
  ///
  /// Asks the plugin's own check first, and falls back to scanning
  /// [FlutterTts.getLanguages] on platforms where that check has no binding
  /// but the list does.
  Future<TtsLanguageSupport> languageSupport(String tag) async {
    try {
      final result = await _tts.isLanguageAvailable(tag);
      return (result == true || result == 1)
          ? TtsLanguageSupport.available
          : TtsLanguageSupport.unavailable;
    } on MissingPluginException {
      // No binding on this platform — fall through to the language list.
    } on PlatformException {
      // The check ran and said no. That is an answer, not a gap.
      return TtsLanguageSupport.unavailable;
    }

    try {
      final languages = await _tts.getLanguages;
      if (languages is List) {
        final wanted = _subtag(tag);
        final matched = languages.any((l) => _subtag('$l') == wanted);
        return matched
            ? TtsLanguageSupport.available
            : TtsLanguageSupport.unavailable;
      }
    } on MissingPluginException {
      // Nothing left to ask with.
    } on PlatformException {
      return TtsLanguageSupport.unavailable;
    }

    return TtsLanguageSupport.unknown;
  }

  /// The language subtag of a BCP-47 tag, lowercased: 'sk-SK' → 'sk'.
  /// Matching on the subtag lets an engine that reports 'sk_SK', 'sk-SK' or
  /// plain 'sk' all answer for the same request.
  static String _subtag(String tag) {
    final separator = tag.indexOf(RegExp('[-_]'));
    return (separator == -1 ? tag : tag.substring(0, separator)).toLowerCase();
  }

  Future<void> speak(String text) async {
    try {
      await _tts.speak(text);
    } on MissingPluginException {
      // No speech on this platform. Callouts are an ambient nicety, never
      // the only feedback a session has.
    } on PlatformException {
      // Engine refused this utterance. Dropping it beats interrupting a hold
      // with an error.
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } on MissingPluginException {
      // Nothing was speaking.
    } on PlatformException {
      // Nothing we can do about it either.
    }
  }

  void dispose() {
    stop();
  }
}
