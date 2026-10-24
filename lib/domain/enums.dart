enum QuestStatus {
  available('available'),
  inProgress('in_progress'),
  completed('completed');

  const QuestStatus(this.wire);
  final String wire;

  static QuestStatus parse(String? value, [QuestStatus fallback = QuestStatus.available]) {
    return QuestStatus.values.firstWhere(
      (s) => s.wire == value,
      orElse: () => fallback,
    );
  }
}

enum QuestType {
  task('task'),
  challenge('challenge'),
  raid('raid'),
  event('event'),
  bounty('bounty');

  const QuestType(this.wire);
  final String wire;

  static QuestType parse(String? value) {
    return QuestType.values.firstWhere(
      (t) => t.wire == value,
      orElse: () => QuestType.task,
    );
  }
}

enum SortOption {
  guild,
  newest,
  recentlyCompleted,
  xp,
  name;

  String get wire => switch (this) {
        SortOption.guild => 'guild',
        SortOption.newest => 'created_at',
        SortOption.recentlyCompleted => 'completed_at',
        SortOption.xp => 'xp_reward',
        SortOption.name => 'name',
      };
}

enum SyncStatus { idle, pending, syncing, error }

enum LeaderboardScope {
  global('global'),
  guild('guild');

  const LeaderboardScope(this.wire);
  final String wire;
}
