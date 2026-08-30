import 'package:breath_lab/data/db/app_database.dart' hide Hold;
import 'package:breath_lab/data/repositories/settings_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('breathing ratio — the §4 S2 safety clamp', () {
    test('isValidBreathingRatio: exhale must be >= inhale and cycle >= 6s', () {
      expect(SettingsRepository.isValidBreathingRatio(4, 6), isTrue);
      expect(SettingsRepository.isValidBreathingRatio(4, 4), isTrue);
      expect(SettingsRepository.isValidBreathingRatio(3, 3), isTrue);
      // exhale shorter than inhale
      expect(SettingsRepository.isValidBreathingRatio(6, 4), isFalse);
      // cycle under 6s
      expect(SettingsRepository.isValidBreathingRatio(2, 2), isFalse);
      expect(SettingsRepository.isValidBreathingRatio(2, 3), isFalse);
    });

    late AppDatabase db;
    late SettingsRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = SettingsRepository(db);
    });

    tearDown(() => db.close());

    test('setBreathingRatio refuses an invalid ratio outright', () async {
      await repo.setBreathingRatio(4, 6);
      await repo.setBreathingRatio(8, 2); // exhale < inhale — refused
      expect(await repo.getBreathingRatio(), (4, 6));

      await repo.setBreathingRatio(2, 2); // cycle 4s — refused
      expect(await repo.getBreathingRatio(), (4, 6));
    });

    test('setBreathingRatio persists a valid ratio', () async {
      await repo.setBreathingRatio(4, 8);
      expect(await repo.getBreathingRatio(), (4, 8));
    });

    test('a stored invalid ratio reads back as the default', () async {
      // Simulate a value written by an older build with no clamp.
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: 'breathing_ratio_inhale_s',
              value: '10',
              updatedAt: 1,
            ),
          );
      await db
          .into(db.settings)
          .insert(
            SettingsCompanion.insert(
              key: 'breathing_ratio_exhale_s',
              value: '2',
              updatedAt: 1,
            ),
          );
      expect(await repo.getBreathingRatio(), (4, 6));
    });
  });
}
