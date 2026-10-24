import 'package:flutter_test/flutter_test.dart';
import 'package:noisequest/domain/guild.dart';

void main() {
  group('guild normalisation', () {
    test('trims and lowercases', () {
      expect(normalizeGuild('  Chores '), 'chores');
      expect(normalizeGuild(''), isNull);
      expect(normalizeGuild(null), isNull);
    });

    test('lookup is case and whitespace insensitive', () {
      const breakdown = GuildBreakdown(
        totalXp: 120,
        guilds: [
          GuildSummary(name: 'Chores', xp: 100, questCount: 4),
          GuildSummary(name: 'Work', xp: 20, questCount: 1),
        ],
      );
      expect(breakdown.xpFor('chores'), 100);
      expect(breakdown.xpFor(' CHORES '), 100);
      expect(breakdown.xpFor('Missing'), 0);
      expect(breakdown.xpFor(null), 0);
    });

    test('guild XP is a subset of total XP', () {
      const breakdown = GuildBreakdown(
        totalXp: 500,
        guilds: [
          GuildSummary(name: 'Chores', xp: 300, questCount: 6),
          GuildSummary(name: 'Work', xp: 100, questCount: 2),
        ],
      );
      final guildTotal = breakdown.guilds.fold<int>(0, (sum, g) => sum + g.xp);
      expect(guildTotal, lessThanOrEqualTo(breakdown.totalXp));
    });
  });
}
