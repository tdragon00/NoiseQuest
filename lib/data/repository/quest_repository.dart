import 'package:uuid/uuid.dart';

import '../../core/utils/result.dart';
import '../../domain/enums.dart';
import '../../domain/guild.dart';
import '../../domain/quest.dart';
import '../../domain/user.dart';
import '../local/local_store.dart';
import '../outbox/outbox.dart';
import '../outbox/sync_service.dart';
import '../remote/quest_api.dart';
import 'guild_repository.dart';

class QuestRepository {
  QuestRepository({
    required this.api,
    required this.store,
    required this.outboxSync,
    required this.guilds,
  });

  final QuestApi api;
  final LocalStore store;
  final SyncService outboxSync;
  final GuildRepository guilds;

  List<Quest> get cached => store.readQuests();

  List<OutboxOp> get outbox => store.readOutbox();

  Future<SyncOutcome> sync(User? user) async {
    final outcome = await outboxSync.drain(user);
    if (outcome.remaining == 0) {
      await store.setLastSync(DateTime.now().toUtc());
    }
    return outcome;
  }

  Future<Result<List<Quest>>> refresh({User? user}) async {
    final outcome = await sync(user);
    final listed = await api.list(limit: 200);
    if (listed is Success<QuestPage>) {
      final pending = store.readOutbox();
      final pendingById = {for (final op in pending) if (op.questId != null) op.questId!: op};
      final deleted = pending
          .where((op) => op.type == OutboxOpType.deleteQuest)
          .map((op) => op.questId)
          .whereType<String>()
          .toSet();
      final cachedById = {for (final q in store.readQuests()) q.id: q};
      final merged = <String, Quest>{};
      for (final quest in listed.value.items) {
        if (deleted.contains(quest.id)) continue;
        final pendingOp = pendingById[quest.id];
        final cachedQuest = cachedById[quest.id];
        if (pendingOp != null && cachedQuest != null) {
          merged[quest.id] = cachedQuest.copyWith(pendingSync: true);
        } else {
          merged[quest.id] = quest;
        }
      }
      for (final op in pending) {
        if (op.type != OutboxOpType.createQuest) continue;
        final local = cachedById[op.questId];
        if (local != null) merged[local.id] = local.copyWith(pendingSync: true);
      }
      final result = merged.values.toList();
      await store.writeQuests(result);
      if (outcome.unauthorized) {
        return const Failure('Your session has expired.', statusCode: 401);
      }
      return Success(result);
    }
    final failure = listed as Failure<QuestPage>;
    final cached = store.readQuests();
    if (cached.isNotEmpty && failure.isNetwork) {
      return Failure(failure.message, code: failure.code, statusCode: failure.statusCode);
    }
    return Failure(failure.message, code: failure.code, statusCode: failure.statusCode);
  }

  Future<Result<GuildBreakdown>> refreshGuilds() async {
    return guilds.refresh();
  }

  Future<void> create(QuestCreate input, User user) async {
    final now = DateTime.now().toUtc();
    final quest = Quest(
      id: input.id,
      name: input.name,
      questType: input.questType,
      description: input.description,
      icon: input.icon,
      guild: input.guild,
      xpReward: input.xpReward,
      isRepeatable: input.isRepeatable,
      authorId: user.id,
      authorName: user.displayName,
      status: QuestStatus.available,
      createdAt: now,
      updatedAt: now,
      completionCount: 0,
      myStatus: QuestStatus.available,
      myCompletionCount: 0,
      pendingSync: true,
    );
    final quests = [quest, ...store.readQuests()];
    await store.writeQuests(quests);
    await _enqueue(OutboxOp.create(OutboxOpType.createQuest, input.toJson()));
    await sync(user);
  }

  Future<void> start(Quest quest, User user) async {
    final quests = _replace(
      quest.copyWith(myStatus: QuestStatus.inProgress, pendingSync: true),
    );
    await store.writeQuests(quests);
    await _enqueue(
      OutboxOp.create(OutboxOpType.startQuest, {'quest_id': quest.id}),
    );
    await sync(user);
  }

  Future<void> cancel(Quest quest, User user) async {
    final quests = _replace(
      quest.copyWith(
        myStatus: QuestStatus.available,
        clearProgress: true,
        pendingSync: true,
      ),
    );
    await store.writeQuests(quests);
    await _enqueue(
      OutboxOp.create(OutboxOpType.cancelQuest, {'quest_id': quest.id}),
    );
    await sync(user);
    await guilds.refresh();
  }

  Future<Quest?> complete(Quest quest, User user) async {
    final completionId = const Uuid().v4();
    final completedAt = DateTime.now().toUtc();
    final repeatable = quest.isRepeatable;
    final updatedQuest = quest.copyWith(
      status: repeatable ? QuestStatus.available : QuestStatus.completed,
      myStatus: repeatable ? QuestStatus.available : QuestStatus.completed,
      clearProgress: repeatable,
      myCompletionCount: quest.myCompletionCount + 1,
      completionCount: quest.completionCount + 1,
      completedAt: completedAt,
      completedById: user.id,
      completedByName: user.displayName,
      updatedAt: completedAt,
      pendingSync: true,
    );
    await store.writeQuests(_replace(updatedQuest));
    await store.writeUser(user.copyWith(totalXp: user.totalXp + quest.xpReward));
    await guilds.applyLocalCompletion(quest.guild, quest.xpReward);
    await _enqueue(
      OutboxOp.create(OutboxOpType.completeQuest, {
        'quest_id': quest.id,
        'completion_id': completionId,
        'guild': quest.guild,
        'xp_awarded': quest.xpReward,
        'completed_at': completedAt.toIso8601String(),
      }),
    );
    await sync(user);
    return updatedQuest;
  }

  Future<void> update(Quest quest, QuestUpdate update, User user) async {
    final patched = quest.copyWith(
      name: update.name,
      questType: update.questType,
      description: update.description,
      clearDescription: update.clearDescription,
      icon: update.icon,
      clearIcon: update.clearIcon,
      guild: update.guild?.trim(),
      clearGuild: update.clearGuild,
      xpReward: update.xpReward,
      isRepeatable: update.isRepeatable,
      pendingSync: true,
      updatedAt: DateTime.now().toUtc(),
    );
    await store.writeQuests(_replace(patched));
    await _enqueue(
      OutboxOp.create(OutboxOpType.updateQuest, {
        'quest_id': quest.id,
        'body': update.toJson(),
      }),
    );
    await sync(user);
  }

  Future<void> delete(Quest quest, User user) async {
    await store.writeQuests(
      store.readQuests().where((q) => q.id != quest.id).toList(),
    );
    await _enqueue(
      OutboxOp.create(OutboxOpType.deleteQuest, {'quest_id': quest.id}),
    );
    await sync(user);
  }

  Future<void> _enqueue(OutboxOp op) async {
    final ops = [...store.readOutbox(), op];
    await store.writeOutbox(ops);
  }

  List<Quest> _replace(Quest quest) {
    final current = store.readQuests();
    final index = current.indexWhere((q) => q.id == quest.id);
    if (index == -1) return [quest, ...current];
    final copy = List<Quest>.from(current);
    copy[index] = quest;
    return copy;
  }
}
