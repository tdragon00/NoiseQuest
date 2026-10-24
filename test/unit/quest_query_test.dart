import 'package:flutter_test/flutter_test.dart';
import 'package:noisequest/domain/enums.dart';
import 'package:noisequest/domain/quest.dart';
import 'package:noisequest/domain/quest_query.dart';

Quest quest({
  required String id,
  required String name,
  QuestStatus status = QuestStatus.available,
  String? guild,
  int xp = 10,
  DateTime? createdAt,
  DateTime? completedAt,
}) {
  final created = createdAt ?? DateTime.utc(2026, 1, 1);
  return Quest(
    id: id,
    name: name,
    questType: QuestType.task,
    xpReward: xp,
    isRepeatable: false,
    authorId: 'u1',
    authorName: 'Ada',
    status: status,
    createdAt: created,
    updatedAt: created,
    completionCount: 0,
    myStatus: status,
    myCompletionCount: 0,
    guild: guild,
    completedAt: completedAt,
  );
}

void main() {
  final data = [
    quest(id: '1', name: 'Clean kitchen', guild: 'Chores', xp: 10),
    quest(id: '2', name: 'Fix printer', guild: 'Work', xp: 50, status: QuestStatus.inProgress),
    quest(id: '3', name: 'Buy milk', guild: 'Errands', xp: 5, status: QuestStatus.completed),
    quest(id: '4', name: 'Water plants', guild: 'chores', xp: 25),
  ];

  test('filters by status', () {
    expect(filterQuests(data, status: QuestStatus.available).map((q) => q.id), ['1', '4']);
    expect(filterQuests(data, status: QuestStatus.inProgress).map((q) => q.id), ['2']);
  });

  test('filters by guild case-insensitively', () {
    expect(filterQuests(data, guild: 'CHORES').map((q) => q.id), ['1', '4']);
  });

  test('searches name, guild and author', () {
    expect(filterQuests(data, query: 'printer').map((q) => q.id), ['2']);
    expect(filterQuests(data, query: 'ada').length, 4);
    expect(filterQuests(data, query: 'zzz'), isEmpty);
  });

  test('sorts by XP descending and name ascending', () {
    expect(sortQuests(data, SortOption.xp, descending: true).map((q) => q.id),
        ['2', '4', '1', '3']);
    expect(sortQuests(data, SortOption.name).first.name, 'Buy milk');
  });

  test('newest sort honours createdAt', () {
    final list = [
      quest(id: 'old', name: 'Old', createdAt: DateTime.utc(2026, 1, 1)),
      quest(id: 'new', name: 'New', createdAt: DateTime.utc(2026, 2, 1)),
    ];
    expect(sortQuests(list, SortOption.newest, descending: true).first.id, 'new');
  });

  test('collects unique guild names', () {
    expect(guildsFromQuests(data), ['Chores', 'Errands', 'Work']);
  });

  test('groups by guild', () {
    final grouped = groupByGuild(data);
    expect(grouped['Chores']?.length, 1);
    expect(grouped['chores']?.length, 1);
  });
}
