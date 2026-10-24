import '../../core/utils/result.dart';
import '../../domain/guild.dart';
import '../local/local_store.dart';
import '../remote/quest_api.dart';

class GuildRepository {
  GuildRepository({required this.store, required this.api});

  final LocalStore store;
  final QuestApi api;

  GuildBreakdown? get cached => store.readGuilds();

  Future<Result<GuildBreakdown>> refresh() async {
    final result = await api.guilds();
    if (result is Success<GuildBreakdown>) {
      await store.writeGuilds(result.value);
    }
    return result;
  }

  /// Optimistically credit guild XP after a local completion.
  Future<GuildBreakdown?> applyLocalCompletion(String? guild, int xp) async {
    final current = store.readGuilds();
    if (current == null) return null;
    final key = normalizeGuild(guild);
    if (key == null) return current;
    final updated = <GuildSummary>[];
    var found = false;
    for (final g in current.guilds) {
      if (normalizeGuild(g.name) == key) {
        found = true;
        updated.add(GuildSummary(name: g.name, xp: g.xp + xp, questCount: g.questCount));
      } else {
        updated.add(g);
      }
    }
    if (!found && guild != null) {
      updated.add(GuildSummary(name: guild, xp: xp, questCount: 0));
    }
    updated.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final breakdown = GuildBreakdown(totalXp: current.totalXp + xp, guilds: updated);
    await store.writeGuilds(breakdown);
    return breakdown;
  }
}
