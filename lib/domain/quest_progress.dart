import 'package:equatable/equatable.dart';

import 'enums.dart';

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value)?.toUtc();
  return null;
}


class QuestProgress extends Equatable {
  const QuestProgress({
    required this.id,
    required this.questId,
    required this.userId,
    required this.status,
    required this.startedAt,
    required this.updatedAt,
    this.completedAt,
  });

  final String id;
  final String questId;
  final String userId;
  final QuestStatus status;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  factory QuestProgress.fromJson(Map<String, dynamic> json) => QuestProgress(
        id: json['id']?.toString() ?? '',
        questId: json['quest_id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        status: QuestStatus.parse(json['status'] as String?, QuestStatus.inProgress),
        startedAt: _parseDate(json['started_at']) ?? DateTime.now().toUtc(),
        updatedAt: _parseDate(json['updated_at']) ?? DateTime.now().toUtc(),
        completedAt: _parseDate(json['completed_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'quest_id': questId,
        'user_id': userId,
        'status': status.wire,
        'started_at': startedAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, questId, userId, status, startedAt, updatedAt, completedAt];
}
