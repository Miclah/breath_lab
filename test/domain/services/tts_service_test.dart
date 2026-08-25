import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:breath_lab/domain/services/tts_service.dart';

/// What a faked plugin call does when invoked: return a value, or throw.
typedef _Responder = dynamic Function();

/// A stand-in for [FlutterTts] that lets each test choose how the plugin
/// answers. `implements` plus [noSuchMethod] keeps this to the seven methods
/// [TtsService] actually calls, rather than the plugin's full surface.
class _FakeTts implements FlutterTts {
  _FakeTts({
    this.onIsLanguageAvailable,
    this.onGetLanguages,
    this.onSetLanguage,
    this.onConfigure,
    this.onSpeak,
  });

  final _Responder? onIsLanguageAvailable;
  final _Responder? onGetLanguages;
  final _Responder? onSetLanguage;
  final _Responder? onConfigure;
  final _Responder? onSpeak;

  /// Tags that actually reached the engine, in order.
  final languagesSet = <String>[];
  final spoken = <String>[];

  @override
  Future<dynamic> isLanguageAvailable(String language) async =>
      (onIsLanguageAvailable ?? () => false)();

  @override
  Future<dynamic> get getLanguages async =>
      (onGetLanguages ?? () => <String>[])();

  @override
  Future<dynamic> setLanguage(String language) async {
    final result = (onSetLanguage ?? () => 1)();
    languagesSet.add(language);
    return result;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async =>
      (onConfigure ?? () => 1)();

  @override
  Future<dynamic> setPitch(double pitch) async => (onConfigure ?? () => 1)();

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    final result = (onSpeak ?? () => 1)();
    spoken.add(text);
    return result;
  }

  @override
  Future<dynamic> stop() async => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<dynamic>.value();
}

MissingPluginException _missing() =>
    MissingPluginException('No implementation found');

PlatformException _platform() => PlatformException(code: 'error');

void main() {
  group('languageSupport', () {
    test('true from the plugin check means available', () async {
      final tts = TtsService(_FakeTts(onIsLanguageAvailable: () => true));
      expect(await tts.languageSupport('sk-SK'), TtsLanguageSupport.available);
    });

    test(
      'an engine answering with 1 rather than true is also available',
      () async {
        final tts = TtsService(_FakeTts(onIsLanguageAvailable: () => 1));
        expect(
          await tts.languageSupport('sk-SK'),
          TtsLanguageSupport.available,
        );
      },
    );

    test('false from the plugin check means unavailable', () async {
      final tts = TtsService(_FakeTts(onIsLanguageAvailable: () => false));
      expect(
        await tts.languageSupport('sk-SK'),
        TtsLanguageSupport.unavailable,
      );
    });

    test('a PlatformException is an answer of no, not a gap', () async {
      final tts = TtsService(
        _FakeTts(onIsLanguageAvailable: () => throw _platform()),
      );
      expect(
        await tts.languageSupport('sk-SK'),
        TtsLanguageSupport.unavailable,
      );
    });

    test('no binding for the check falls back to the language list', () async {
      final tts = TtsService(
        _FakeTts(
          onIsLanguageAvailable: () => throw _missing(),
          // Deliberately a different casing and separator to the requested
          // tag: engines report sk, sk-SK and sk_SK interchangeably.
          onGetLanguages: () => ['en-US', 'sk_sk'],
        ),
      );
      expect(await tts.languageSupport('sk-SK'), TtsLanguageSupport.available);
    });

    test('a language list without the subtag means unavailable', () async {
      final tts = TtsService(
        _FakeTts(
          onIsLanguageAvailable: () => throw _missing(),
          onGetLanguages: () => ['en-US', 'de-DE'],
        ),
      );
      expect(
        await tts.languageSupport('sk-SK'),
        TtsLanguageSupport.unavailable,
      );
    });

    test('no binding for either call is unknown, not unavailable', () async {
      final tts = TtsService(
        _FakeTts(
          onIsLanguageAvailable: () => throw _missing(),
          onGetLanguages: () => throw _missing(),
        ),
      );
      expect(await tts.languageSupport('sk-SK'), TtsLanguageSupport.unknown);
    });
  });

  group('setLanguage', () {
    test('a known-missing voice falls back to English', () async {
      final fake = _FakeTts(onIsLanguageAvailable: () => false);
      final tts = TtsService(fake);

      await tts.setLanguage('sk');

      expect(tts.fellBackToEnglish, isTrue);
      expect(fake.languagesSet, ['en-US']);
    });

    test('an unanswerable check does not pre-empt the Slovak voice', () async {
      final fake = _FakeTts(
        onIsLanguageAvailable: () => throw _missing(),
        onGetLanguages: () => throw _missing(),
      );
      final tts = TtsService(fake);

      await tts.setLanguage('sk');

      expect(tts.fellBackToEnglish, isFalse);
      expect(fake.languagesSet, ['sk-SK']);
    });

    test('a tag that never took is not cached as set', () async {
      var calls = 0;
      final fake = _FakeTts(
        onSetLanguage: () {
          if (calls++ == 0) throw _missing();
          return 1;
        },
      );
      final tts = TtsService(fake);

      await tts.setLanguage('en');
      await tts.setLanguage('en');

      // The first call threw before the engine took the tag; the second must
      // retry rather than short-circuit on a language it never received.
      expect(fake.languagesSet, ['en-US']);
    });
  });

  test('a platform with no rate or pitch binding still constructs', () async {
    final fake = _FakeTts(onConfigure: () => throw _missing());
    final tts = TtsService(fake);

    await tts.speak('one minute');

    expect(fake.spoken, ['one minute']);
  });

  test('a dropped utterance does not surface as an error', () async {
    final tts = TtsService(_FakeTts(onSpeak: () => throw _platform()));
    await expectLater(tts.speak('one minute'), completes);
  });
}
