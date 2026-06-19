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
