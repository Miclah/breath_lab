import '../../data/repositories/settings_repository.dart'
    show SpokenCalloutsMode;

/// Localized phrases for milestone callouts, in the TTS voice language
/// (independent of the app's UI language — callers build this from
/// AppLocalizationsEn/Sk directly, not from BuildContext).
class MilestonePhrases {
  const MilestonePhrases({
    required this.oneMinute,
    required this.oneThirty,
    required this.twoMinutes,
    required this.twoThirty,
    required this.threeMinutes,
    required this.threeThirty,
    required this.fourMinutes,
    required this.halfwayToPb,
    required this.thirtySecondsToPb,
    required this.atPb,
    required this.pastPb,
  });

  final String oneMinute;
  final String oneThirty;
  final String twoMinutes;
  final String twoThirty;
  final String threeMinutes;
  final String threeThirty;
  final String fourMinutes;
  final String halfwayToPb;
  final String thirtySecondsToPb;
  final String atPb;
  final String pastPb;
}

/// Decides which phrase (if any) to speak as a hold's elapsed time crosses
/// configured thresholds, per Design Additions §A1/§9. One instance per
/// hold — construct a fresh one when a new hold begins.
class CalloutScheduler {
  CalloutScheduler({
    required this.mode,
    required this.pbMs,
    required this.phrases,
    required this.language,
  });

  final SpokenCalloutsMode mode;

  /// Current personal best in milliseconds, null if none set yet.
  /// PB-relative events (halfway/30s-to-PB/at-PB/past-PB) are skipped
  /// when null.
  final int? pbMs;

  final MilestonePhrases phrases;

  /// 'en' or 'sk' — selects the interval-mode number words.
  final String language;

  final Set<String> _spokenKeys = {};
  int _lastSpokenMark = 0;

  /// Returns the phrase to speak for [elapsed], or null if nothing is due
  /// yet. Each threshold fires at most once per instance.
  String? check(Duration elapsed) {
    return switch (mode) {
      SpokenCalloutsMode.off => null,
      SpokenCalloutsMode.milestones => _checkMilestones(elapsed),
      SpokenCalloutsMode.every30s => _checkInterval(elapsed, 30),
      SpokenCalloutsMode.every15s => _checkInterval(elapsed, 15),
      SpokenCalloutsMode.dense => _checkDense(elapsed),
    };
  }

  List<(double, String, String)> _milestoneEvents() {
    final events = <(double, String, String)>[
      (60, 'm60', phrases.oneMinute),
      (90, 'm90', phrases.oneThirty),
      (120, 'm120', phrases.twoMinutes),
      (150, 'm150', phrases.twoThirty),
      (180, 'm180', phrases.threeMinutes),
      (210, 'm210', phrases.threeThirty),
      (240, 'm240', phrases.fourMinutes),
    ];
    final pb = pbMs;
    if (pb != null) {
      final pbS = pb / 1000;
      events.add((pbS / 2, 'halfway', phrases.halfwayToPb));
      if (pbS > 30) {
        events.add((pbS - 30, 'thirtyBefore', phrases.thirtySecondsToPb));
      }
      events.add((pbS, 'atPb', phrases.atPb));
      events.add((pbS + 0.001, 'pastPb', phrases.pastPb));
    }
    events.sort((a, b) => a.$1.compareTo(b.$1));
    return events;
  }

  String? _checkMilestones(Duration elapsed) {
    final s = elapsed.inMilliseconds / 1000.0;
    for (final (threshold, key, phrase) in _milestoneEvents()) {
      if (s >= threshold && !_spokenKeys.contains(key)) {
        _spokenKeys.add(key);
        return phrase;
      }
    }
    return null;
  }

  String? _checkInterval(Duration elapsed, int stepSeconds) {
    final s = elapsed.inSeconds;
    final mark = (s ~/ stepSeconds) * stepSeconds;
    if (mark <= 0 || mark <= _lastSpokenMark) return null;
    _lastSpokenMark = mark;
    return _intervalPhrase(mark);
  }

  String? _checkDense(Duration elapsed) {
    final s = elapsed.inSeconds;
    final pb = pbMs;
    final step = (pb != null && s >= (pb / 1000) * 0.9) ? 5 : 15;
    return _checkInterval(elapsed, step);
  }

  String _intervalPhrase(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final minuteWord = _cardinal(minutes, language);
    if (seconds == 0) {
      final unit = language == 'sk'
          ? _minuteUnitSk(minutes)
          : (minutes == 1 ? 'minute' : 'minutes');
      return '$minuteWord $unit';
    }
    return '$minuteWord ${_cardinal(seconds, language)}';
  }
}

const _onesEn = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen',
];
const _tensEn = [
  '',
  '',
  'twenty',
  'thirty',
  'forty',
  'fifty',
  'sixty',
  'seventy',
  'eighty',
  'ninety',
];

const _onesSk = [
  'nula',
  'jeden',
  'dva',
  'tri',
  'štyri',
  'päť',
  'šesť',
  'sedem',
  'osem',
  'deväť',
  'desať',
  'jedenásť',
  'dvanásť',
  'trinásť',
  'štrnásť',
  'pätnásť',
  'šestnásť',
  'sedemnásť',
  'osemnásť',
  'devätnásť',
];
const _tensSk = [
  '',
  '',
  'dvadsať',
  'tridsať',
  'štyridsať',
  'päťdesiat',
  'šesťdesiat',
  'sedemdesiat',
  'osemdesiat',
  'deväťdesiat',
];

String _cardinal(int n, String language) {
  final ones = language == 'sk' ? _onesSk : _onesEn;
  final tens = language == 'sk' ? _tensSk : _tensEn;
  if (n < 20) return ones[n];
  if (n < 100) {
    final ten = tens[n ~/ 10];
    final one = n % 10;
    return one == 0 ? ten : '$ten ${ones[one]}';
  }
  return '$n';
}

String _minuteUnitSk(int n) {
  if (n == 1) return 'minúta';
  if (n >= 2 && n <= 4) return 'minúty';
  return 'minút';
}
