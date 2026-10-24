import '../../core/utils/result.dart';
import '../../domain/enums.dart';
import '../../domain/guild.dart';
import '../../domain/quest.dart';
import '../../domain/quest_completion.dart';
import '../../domain/quest_progress.dart';
import 'api_client.dart';

Future<Result<T>> _guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on Object catch (error) {
    final api = mapDioError(error);
    return Failure(api.message, code: api.code, field: api.field, statusCode: api.statusCode);
  }
}

class QuestApi {
  QuestApi(this.client);

  final ApiClient client;

  Future<Result<QuestPage>> list({
    QuestStatus? status,
    String? guild,
    String? q,
    SortOption? sort,
    String? order,
    DateTime? since,
    int limit = 200,
    String? cursor,
  }) {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>(
        '/quests',
        queryParameters: {
          'status': ?status?.wire,
          if (guild != null && guild.isNotEmpty) 'guild': guild,
          if (q != null && q.isNotEmpty) 'q': q,
          if (sort != null) 'sort': sort.wire,
          'order': ?order,
          if (since != null) 'since': since.toUtc().toIso8601String(),
          'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      return QuestPage.fromJson(response.data ?? const {});
    });
  }

  Future<Result<Quest>> get(String id) {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>('/quests/$id');
      return Quest.fromJson(response.data ?? const {});
    });
  }

  Future<Result<Quest>> create(QuestCreate quest) {
    return _guard(() async {
      final response = await client.dio.post<Map<String, dynamic>>(
        '/quests',
        data: quest.toJson(),
      );
      return Quest.fromJson(response.data ?? const {});
    });
  }

  Future<Result<Quest>> update(String id, QuestUpdate update) {
    return _guard(() async {
      final response = await client.dio.patch<Map<String, dynamic>>(
        '/quests/$id',
        data: update.toJson(),
      );
      return Quest.fromJson(response.data ?? const {});
    });
  }

  Future<Result<void>> deleteQuest(String id) {
    return _guard(() async {
      await client.dio.delete<void>('/quests/$id');
    });
  }

  Future<Result<QuestProgress>> start(String id) {
    return _guard(() async {
      final response = await client.dio.post<Map<String, dynamic>>('/quests/$id/start');
      return QuestProgress.fromJson(response.data ?? const {});
    });
  }

  Future<Result<CompletionResult>> complete(String questId, String completionId) {
    return _guard(() async {
      final response = await client.dio.post<Map<String, dynamic>>(
        '/quests/$questId/complete',
        data: {'id': completionId},
      );
      return CompletionResult.fromJson(response.data ?? const {});
    });
  }

  Future<Result<void>> cancel(String id) {
    return _guard(() async {
      await client.dio.post<void>('/quests/$id/cancel');
    });
  }

  Future<Result<GuildBreakdown>> guilds() {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>('/guilds');
      return GuildBreakdown.fromJson(response.data ?? const {});
    });
  }
}
