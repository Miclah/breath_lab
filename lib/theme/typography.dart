import 'package:flutter/material.dart';

const _inter = 'Inter';
const _jetBrainsMono = 'JetBrainsMono';

class BreathLabTypography {
  const BreathLabTypography._();

  // JetBrains Mono - timer and all numerical data
  static const TextStyle timerDisplay = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 48,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -1,
  );

  static const TextStyle statHero = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -0.5,
  );

  static const TextStyle statMd = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static const TextStyle statSm = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  // Inter - all UI text
  static const TextStyle headingLg = TextStyle(
    fontFamily: _inter,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle headingMd = TextStyle(
    fontFamily: _inter,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle headingSm = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle label = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _inter,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const TextStyle badge = TextStyle(
    fontFamily: _inter,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: 0.5,
  );

  // -------------------------------------------------------------------------
  // Revised scale — Design Revision §1
  //
  // The old scale put eight of its fourteen styles between 10 and 22 px and
  // capped weight at 500, so nothing could be emphatic and section headers
  // had to be tinted teal just to be findable. The contrast moves into the
  // numbers instead: this is a training log, and the reader is looking for a
  // duration. A 40 px figure beside a 12 px label is a ratio of more than
  // three; 22 px beside 18 px is not a ratio at all.
  //
  // Weight still stops at 500 and nothing is smaller than 11 px.
  // -------------------------------------------------------------------------

  /// The OLED hold screen. 128 on desktop; callers drop to 96 on compact.
  static const TextStyle displayXl = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 128,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -4,
  );

  /// The timer during a hold — the largest thing on any ordinary screen.
  static const TextStyle displayLg = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 72,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -2.5,
  );

  /// Result duration, stat values, the last-session figure.
  static const TextStyle displayMd = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 40,
    fontWeight: FontWeight.w500,
    height: 1.0,
    letterSpacing: -1.5,
  );

  /// Secondary metrics, table round times, list durations.
  static const TextStyle numericMd = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// Inline data: hold chips, keycaps, dense rows.
  static const TextStyle numericSm = TextStyle(
    fontFamily: _jetBrainsMono,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  /// Screen title. One per screen.
  static const TextStyle title = TextStyle(
    fontFamily: _inter,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Every section header, everywhere.
  ///
  /// Rendered uppercase — the style cannot do that itself, so callers pass
  /// `title.toUpperCase()`. The tracking and the small caps are what make it
  /// findable, which is why it no longer needs an accent colour.
  static const TextStyle section = TextStyle(
    fontFamily: _inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    // 0.09em at 12 px.
    letterSpacing: 1.08,
  );

  /// Body copy, descriptions, safety text.
  static const TextStyle body = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  /// Captions, timestamps, helper lines, badges.
  static const TextStyle micro = TextStyle(
    fontFamily: _inter,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.3,
    // 0.04em at 11 px.
    letterSpacing: 0.44,
  );

  static const TextStyle tabLabel = TextStyle(
    fontFamily: _inter,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.0,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );
}
