import '../../core/utils/result.dart';
import '../../domain/enums.dart';
import '../../domain/quest.dart';
import '../../domain/user.dart';
import '../local/local_store.dart';
import '../outbox/outbox.dart';
import '../remote/quest_api.dart';

class SyncOutcome {
  const SyncOutcome({
    this.processed = 0,
    this.remaining = 0,
    this.error,
    this.unauthorized = false,
  });

  final int processed;
  final int remaining;
  final String? error;
  final bool unauthorized;
}

class _SyncFailure implements Exception {
  const _SyncFailure(this.failure);
  final Failure<dynamic> failure;
}

class SyncService {
  SyncService({required this.store, required this.questApi});

  final LocalStore store;
  final QuestApi questApi;

  Future<SyncOutcome> drain(User? signedInUser) async {
    final ops = List<OutboxOp>.from(store.readOutbox());
    if (ops.isEmpty) return const SyncOutcome();

    final byId = {for (final q in store.readQuests()) q.id: q};
    var user = signedInUser ?? store.readUser();
    var processed = 0;
    var unauthorized = false;
    String? error;

    for (final op in List<OutboxOp>.from(ops)) {
      try {
        switch (op.type) {
          case OutboxOpType.createQuest:
            final created = _ensure(await questApi.create(QuestCreate.fromJson(op.payload)));
            byId[created.id] = created;
          case OutboxOpType.startQuest:
            final id = op.questId;
            if (id == null) break;
            final started = _ensure(await questApi.start(id));
            final quest = byId[id];
            if (quest != null) {
              byId[id] = quest.copyWith(
                myStatus: QuestStatus.inProgress,
                myProgressId: started.id,
                status: quest.status == QuestStatus.available
                    ? QuestStatus.inProgress
                    : quest.status,
                updatedAt: DateTime.now().toUtc(),
              );
            }
          case OutboxOpType.completeQuest:
            final id = op.questId;
            final completionId = op.payload['completion_id']?.toString();
            if (id == null || completionId == null) break;
            final result = _ensure(await questApi.complete(id, completionId));
            if (user != null) {
              user = user.copyWith(totalXp: result.totalXp);
              await store.writeUser(user);
            }
            final quest = byId[id];
            if (quest != null) {
              final repeatable = quest.isRepeatable;
              byId[id] = quest.copyWith(
                status: result.questStatus,
                myStatus: repeatable
                    ? QuestStatus.available
                    : QuestStatus.completed,
                clearProgress: repeatable,
                myCompletionCount: quest.myCompletionCount + 1,
                completionCount: quest.completionCount + 1,
                completedAt: result.completion.completedAt,
                completedById: result.completion.userId,
                completedByName: user?.displayName,
                updatedAt: DateTime.now().toUtc(),
              );
            }
          case OutboxOpType.cancelQuest:
            final id = op.questId;
            if (id == null) break;
            _ensure(await questApi.cancel(id));
            final quest = byId[id];
            if (quest != null) {
              byId[id] = quest.copyWith(
                myStatus: QuestStatus.available,
                clearProgress: true,
                status: QuestStatus.available,
                updatedAt: DateTime.now().toUtc(),
              );
            }
          case OutboxOpType.updateQuest:
            final id = op.questId;
            if (id == null) break;
            final body =
                (op.payload['body'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
            final updated = _ensure(await questApi.update(id, QuestUpdate.fromJson(body)));
            byId[id] = updated;
          case OutboxOpType.deleteQuest:
            final id = op.questId;
            if (id == null) break;
            _ensure(await questApi.deleteQuest(id));
            byId.remove(id);
        }
        ops.remove(op);
        processed++;
      } on _SyncFailure catch (failure) {
        final api = failure.failure;
        error = api.message;
        if (api.isUnauthorized) {
          unauthorized = true;
          break;
        }
        if (api.isNetwork) break;
        // Permanent (4xx): drop the op so the queue cannot wedge forever.
        ops.remove(op);
        processed++;
      }
    }

    final pendingQuestIds = ops.map((e) => e.questId).whereType<String>().toSet();
    final merged = byId.values
        .map((q) => q.copyWith(pendingSync: pendingQuestIds.contains(q.id)))
        .toList();
    await store.writeQuests(merged);
    await store.writeOutbox(ops);

    return SyncOutcome(
      processed: processed,
      remaining: ops.length,
      error: error,
      unauthorized: unauthorized,
    );
  }

  T _ensure<T>(Result<T> result) {
    if (result is Success<T>) return result.value;
    throw _SyncFailure(result as Failure<T>);
  }
}
