import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/result.dart';
import '../domain/enums.dart';
import '../domain/quest.dart';
import '../services/sound_service.dart';
import 'guilds_provider.dart';
import 'providers.dart';
import 'session_provider.dart';

class QuestsNotifier extends AsyncNotifier<List<Quest>> {
  @override
  Future<List<Quest>> build() async {
    final cached = ref.read(questRepositoryProvider).cached;
    if (cached.isNotEmpty) {
      unawaited(Future<void>.delayed(Duration.zero, refresh));
      return cached;
    }
    final result = await ref.read(questRepositoryProvider).refresh(
          user: ref.read(sessionProvider).user,
        );
    if (result case Success<List<Quest>>(value: final quests)) return quests;
    final failure = result as Failure<List<Quest>>;
    throw StateError(failure.message);
  }

  Future<void> refresh() async {
    final sync = ref.read(syncStatusProvider.notifier);
    final repository = ref.read(questRepositoryProvider);
    if (repository.outbox.isNotEmpty) {
      sync.markSyncing(repository.outbox.length);
    }
    final result = await repository.refresh(user: ref.read(sessionProvider).user);
    ref.read(sessionProvider.notifier).reloadFromCache();
    final connectivity = ref.read(connectivityProvider);
    if (result case Success<List<Quest>>()) {
      connectivity.setOnline(true);
    } else if ((result as Failure<List<Quest>>).isNetwork) {
      connectivity.setOnline(false);
    }
    switch (result) {
      case Success<List<Quest>>(value: final quests):
        state = AsyncData(quests);
        sync.refreshCount();
      case Failure<List<Quest>>(message: final message):
        final previous = state.value;
        if (previous != null && previous.isNotEmpty) {
          state = AsyncData(previous);
          sync.markError(message);
        } else {
          state = AsyncError(message, StackTrace.current);
          sync.markError(message);
        }
    }
    unawaited(ref.read(guildsProvider.notifier).refresh());
  }

  Future<void> create(QuestCreate input) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    await ref.read(questRepositoryProvider).create(input, user);
    _afterMutation();
    ref.read(soundServiceProvider).play(SoundEvent.createQuest);
  }

  Future<void> start(Quest quest) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    await ref.read(questRepositoryProvider).start(quest, user);
    _afterMutation();
    ref.read(soundServiceProvider).play(SoundEvent.startQuest);
  }

  Future<void> complete(Quest quest) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    final beforeLevel = ref.read(levelTableProvider).level(user.totalXp);
    await ref.read(questRepositoryProvider).complete(quest, user);
    _afterMutation();
    final afterXp = ref.read(sessionProvider).user?.totalXp ?? user.totalXp;
    final afterLevel = ref.read(levelTableProvider).level(afterXp);
    final sound = ref.read(soundServiceProvider);
    sound.play(SoundEvent.completeQuest);
    if (afterLevel > beforeLevel) sound.play(SoundEvent.levelUp);
  }

  Future<void> cancel(Quest quest) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    await ref.read(questRepositoryProvider).cancel(quest, user);
    _afterMutation();
  }

  Future<void> edit(Quest quest, QuestUpdate update) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    await ref.read(questRepositoryProvider).update(quest, update, user);
    _afterMutation();
  }

  Future<void> delete(Quest quest) async {
    final user = ref.read(sessionProvider).user;
    if (user == null) return;
    await ref.read(questRepositoryProvider).delete(quest, user);
    _afterMutation();
  }

  void _afterMutation() {
    state = AsyncData(ref.read(questRepositoryProvider).cached);
    ref.read(sessionProvider.notifier).reloadFromCache();
    ref.read(syncStatusProvider.notifier).refreshCount();
    ref.read(guildsProvider.notifier).refreshFromCache();
  }
}

final questsProvider = AsyncNotifierProvider<QuestsNotifier, List<Quest>>(
  QuestsNotifier.new,
);

final questByIdProvider = Provider.family<Quest?, String>((ref, id) {
  final quests = ref.watch(questsProvider).value ?? const <Quest>[];
  for (final quest in quests) {
    if (quest.id == id) return quest;
  }
  return null;
});

final questCountsProvider = Provider<Map<QuestStatus, int>>((ref) {
  final quests = ref.watch(questsProvider).value ?? const <Quest>[];
  final counts = {
    QuestStatus.available: 0,
    QuestStatus.inProgress: 0,
    QuestStatus.completed: 0,
  };
  for (final quest in quests) {
    counts[quest.myStatus] = (counts[quest.myStatus] ?? 0) + 1;
  }
  return counts;
});

final availableGuildsProvider = Provider<List<String>>((ref) {
  final quests = ref.watch(questsProvider).value ?? const <Quest>[];
  final seen = <String, String>{};
  for (final quest in quests) {
    final name = quest.guild?.trim();
    if (name == null || name.isEmpty) continue;
    seen.putIfAbsent(name.toLowerCase(), () => name);
  }
  final names = seen.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return names;
});
