import 'package:collection/collection.dart';

import '../domain/enums.dart';
import '../domain/quest.dart';

/// Pure query helpers shared by the UI and the unit tests (SPEC §12.3, §21.2).
List<Quest> filterQuests(
  List<Quest> quests, {
  QuestStatus? status,
  String guild = '',
  String query = '',
}) {
  final guildKey = guild.trim().toLowerCase();
  final needle = query.trim().toLowerCase();
  return quests.where((quest) {
    if (status != null && quest.myStatus != status) return false;
    if (guildKey.isNotEmpty && normalizeQuestGuild(quest.guild) != guildKey) {
      return false;
    }
    if (needle.isEmpty) return true;
    final haystack = [
      quest.name,
      quest.description ?? '',
      quest.guild ?? '',
      quest.authorName,
      quest.icon ?? '',
    ].join('\n').toLowerCase();
    return haystack.contains(needle);
  }).toList();
}

String normalizeQuestGuild(String? guild) => (guild ?? '').trim().toLowerCase();

List<Quest> sortQuests(List<Quest> quests, SortOption sort, {bool descending = false}) {
  final copy = List<Quest>.from(quests);
  copy.sort((a, b) {
    final result = switch (sort) {
      SortOption.guild => _compareGuild(a.guild, b.guild),
      SortOption.newest => a.createdAt.compareTo(b.createdAt),
      SortOption.recentlyCompleted => _compareNullableDate(a.completedAt, b.completedAt),
      SortOption.xp => a.xpReward.compareTo(b.xpReward),
      SortOption.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    };
    return descending ? -result : result;
  });
  return copy;
}

int _compareGuild(String? a, String? b) {
  final left = normalizeQuestGuild(a);
  final right = normalizeQuestGuild(b);
  if (left.isEmpty && right.isEmpty) return 0;
  if (left.isEmpty) return 1;
  if (right.isEmpty) return -1;
  return left.compareTo(right);
}

int _compareNullableDate(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

List<String> guildsFromQuests(List<Quest> quests) {
  final seen = <String, String>{};
  for (final quest in quests) {
    final name = quest.guild?.trim();
    if (name == null || name.isEmpty) continue;
    final key = name.toLowerCase();
    seen.putIfAbsent(key, () => name);
  }
  final names = seen.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return names;
}

List<String> guildsFromCompletions(Iterable<String?> guilds) {
  return guilds
      .whereType<String>()
      .map((g) => g.trim())
      .where((g) => g.isNotEmpty)
      .toSet()
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
}

Map<String, List<Quest>> groupByGuild(List<Quest> quests) {
  return groupBy(quests, (q) => q.guild?.trim() ?? '');
}
