import 'package:equatable/equatable.dart';

import 'enums.dart';

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value)?.toUtc();
  return null;
}

class QuestCompletion extends Equatable {
  const QuestCompletion({
    required this.id,
    required this.questId,
    required this.userId,
    required this.xpAwarded,
    required this.completedAt,
    this.guild,
  });

  final String id;
  final String questId;
  final String userId;
  final String? guild;
  final int xpAwarded;
  final DateTime completedAt;

  factory QuestCompletion.fromJson(Map<String, dynamic> json) => QuestCompletion(
        id: json['id']?.toString() ?? '',
        questId: json['quest_id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        guild: json['guild'] as String?,
        xpAwarded: _asInt(json['xp_awarded']),
        completedAt: _parseDate(json['completed_at']) ?? DateTime.now().toUtc(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'quest_id': questId,
        'user_id': userId,
        'guild': guild,
        'xp_awarded': xpAwarded,
        'completed_at': completedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, questId, userId, guild, xpAwarded, completedAt];
}

class CompletionResult extends Equatable {
  const CompletionResult({
    required this.completion,
    required this.xpAwarded,
    required this.totalXp,
    required this.level,
    required this.title,
    required this.levelUp,
    required this.questStatus,
  });

  final QuestCompletion completion;
  final int xpAwarded;
  final int totalXp;
  final int level;
  final String title;
  final bool levelUp;
  final QuestStatus questStatus;

  factory CompletionResult.fromJson(Map<String, dynamic> json) => CompletionResult(
        completion: QuestCompletion.fromJson(
          (json['completion'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        xpAwarded: _asInt(json['xp_awarded']),
        totalXp: _asInt(json['total_xp']),
        level: _asInt(json['level'], 1),
        title: json['title']?.toString() ?? 'Signal Wanderer',
        levelUp: json['level_up'] == true,
        questStatus: QuestStatus.parse(json['quest_status'] as String?),
      );

  @override
  List<Object?> get props => [
        completion,
        xpAwarded,
        totalXp,
        level,
        title,
        levelUp,
        questStatus,
      ];
}
