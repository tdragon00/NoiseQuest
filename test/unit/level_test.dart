import 'package:flutter_test/flutter_test.dart';
import 'package:noisequest/domain/level.dart';

void main() {
  group('LevelMath', () {
    test('cumulative XP follows 50*(L-1)*L', () {
      expect(LevelMath.cumulativeXp(1), 0);
      expect(LevelMath.cumulativeXp(2), 100);
      expect(LevelMath.cumulativeXp(3), 300);
      expect(LevelMath.cumulativeXp(10), 4500);
    });

    test('caps at level 50', () {
      expect(LevelMath.cumulativeXp(51), LevelMath.cumulativeXp(50));
      expect(LevelMath.levelForXp(1 << 30), LevelMath.maxLevel);
    });

    test('level boundaries are inclusive of the threshold', () {
      expect(LevelMath.levelForXp(0), 1);
      expect(LevelMath.levelForXp(99), 1);
      expect(LevelMath.levelForXp(100), 2);
      expect(LevelMath.levelForXp(299), 2);
      expect(LevelMath.levelForXp(300), 3);
    });

    test('progress within level and XP to next', () {
      expect(LevelMath.xpIntoLevel(150), 50);
      expect(LevelMath.xpForNextLevel(150), 200);
      expect(LevelMath.progress(150), closeTo(0.25, 1e-9));
      expect(LevelMath.progress(0), 0);
      expect(LevelMath.xpForNextLevel(LevelMath.cumulativeXp(50)), 0);
    });

    test('titles cover the whole curve', () {
      for (var level = 1; level <= LevelMath.maxLevel; level++) {
        expect(LevelMath.defaultTitle(level), isNotEmpty);
      }
      expect(LevelMath.defaultTitle(1), 'Signal Wanderer');
    });

    test('LevelTable can be built without server config', () {
      final table = LevelTable(null);
      expect(table.level(150), 2);
      expect(table.title(0), 'Signal Wanderer');
    });
  });
}
