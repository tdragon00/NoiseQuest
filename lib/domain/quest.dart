import 'package:equatable/equatable.dart';

import 'enums.dart';

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value)?.toUtc();
  return null;
}

int _asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class Quest extends Equatable {
  const Quest({
    required this.id,
    required this.name,
    required this.questType,
    required this.xpReward,
    required this.isRepeatable,
    required this.authorId,
    required this.authorName,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.completionCount,
    required this.myStatus,
    required this.myCompletionCount,
    this.description,
    this.icon,
    this.guild,
    this.completedAt,
    this.completedById,
    this.completedByName,
    this.myProgressId,
    this.pendingSync = false,
  });

  final String id;
  final String name;
  final QuestType questType;
  final String? description;
  final String? icon;
  final String? guild;
  final int xpReward;
  final bool isRepeatable;
  final String authorId;
  final String authorName;
  final QuestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? completedById;
  final String? completedByName;
  final int completionCount;
  final QuestStatus myStatus;
  final String? myProgressId;
  final int myCompletionCount;

  /// Local-only flag: this quest has an unacked mutation in the outbox.
  final bool pendingSync;

  factory Quest.fromJson(Map<String, dynamic> json) {
    final guild = (json['guild'] as String?)?.trim();
    return Quest(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled quest',
      questType: QuestType.parse(json['quest_type'] as String?),
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      guild: guild == null || guild.isEmpty ? null : guild,
      xpReward: _asInt(json['xp_reward'], 1),
      isRepeatable: json['is_repeatable'] == true,
      authorId: json['author_id']?.toString() ?? '',
      authorName: json['author_name']?.toString() ?? 'Unknown',
      status: QuestStatus.parse(json['status'] as String?),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: _parseDate(json['updated_at']) ?? DateTime.now().toUtc(),
      completedAt: _parseDate(json['completed_at']),
      completedById: json['completed_by_id'] as String?,
      completedByName: json['completed_by_name'] as String?,
      completionCount: _asInt(json['completion_count']),
      myStatus: QuestStatus.parse(
        json['my_status'] as String? ?? json['status'] as String?,
      ),
      myProgressId: json['my_progress_id'] as String?,
      myCompletionCount: _asInt(json['my_completion_count']),
      pendingSync: json['pending_sync'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quest_type': questType.wire,
        'description': description,
        'icon': icon,
        'guild': guild,
        'xp_reward': xpReward,
        'is_repeatable': isRepeatable,
        'author_id': authorId,
        'author_name': authorName,
        'status': status.wire,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'completed_by_id': completedById,
        'completed_by_name': completedByName,
        'completion_count': completionCount,
        'my_status': myStatus.wire,
        'my_progress_id': myProgressId,
        'my_completion_count': myCompletionCount,
        'pending_sync': pendingSync,
      };

  Quest copyWith({
    String? name,
    QuestType? questType,
    String? description,
    bool clearDescription = false,
    String? icon,
    bool clearIcon = false,
    String? guild,
    bool clearGuild = false,
    int? xpReward,
    bool? isRepeatable,
    String? authorId,
    String? authorName,
    QuestStatus? status,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? completedById,
    String? completedByName,
    int? completionCount,
    QuestStatus? myStatus,
    String? myProgressId,
    bool clearProgress = false,
    int? myCompletionCount,
    bool? pendingSync,
  }) {
    return Quest(
      id: id,
      name: name ?? this.name,
      questType: questType ?? this.questType,
      description: clearDescription ? null : (description ?? this.description),
      icon: clearIcon ? null : (icon ?? this.icon),
      guild: clearGuild ? null : (guild ?? this.guild),
      xpReward: xpReward ?? this.xpReward,
      isRepeatable: isRepeatable ?? this.isRepeatable,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      completedById: completedById ?? this.completedById,
      completedByName: completedByName ?? this.completedByName,
      completionCount: completionCount ?? this.completionCount,
      myStatus: myStatus ?? this.myStatus,
      myProgressId: clearProgress ? null : (myProgressId ?? this.myProgressId),
      myCompletionCount: myCompletionCount ?? this.myCompletionCount,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  bool get hasGuild => guild != null && guild!.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        name,
        questType,
        description,
        icon,
        guild,
        xpReward,
        isRepeatable,
        authorId,
        authorName,
        status,
        createdAt,
        updatedAt,
        completedAt,
        completedById,
        completedByName,
        completionCount,
        myStatus,
        myProgressId,
        myCompletionCount,
        pendingSync,
      ];
}

class QuestPage {
  const QuestPage({required this.items, this.nextCursor});

  final List<Quest> items;
  final String? nextCursor;

  factory QuestPage.fromJson(Map<String, dynamic> json) {
    final raw = (json['items'] as List?) ?? const [];
    return QuestPage(
      items: raw
          .whereType<Map>()
          .map((e) => Quest.fromJson(e.cast<String, dynamic>()))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }
}

class QuestCreate {
  const QuestCreate({
    required this.id,
    required this.name,
    required this.questType,
    required this.xpReward,
    this.description,
    this.icon,
    this.guild,
    this.isRepeatable = false,
  });

  final String id;
  final String name;
  final QuestType questType;
  final int xpReward;
  final String? description;
  final String? icon;
  final String? guild;
  final bool isRepeatable;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quest_type': questType.wire,
        'description': description,
        'icon': icon,
        'guild': guild,
        'xp_reward': xpReward,
        'is_repeatable': isRepeatable,
      };

  factory QuestCreate.fromJson(Map<String, dynamic> json) => QuestCreate(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        questType: QuestType.parse(json['quest_type'] as String?),
        xpReward: _asInt(json['xp_reward'], 1),
        description: json['description'] as String?,
        icon: json['icon'] as String?,
        guild: json['guild'] as String?,
        isRepeatable: json['is_repeatable'] == true,
      );
}

class QuestUpdate {
  const QuestUpdate({
    this.name,
    this.questType,
    this.description,
    this.icon,
    this.guild,
    this.xpReward,
    this.isRepeatable,
    this.clearDescription = false,
    this.clearIcon = false,
    this.clearGuild = false,
  });

  final String? name;
  final QuestType? questType;
  final String? description;
  final String? icon;
  final String? guild;
  final int? xpReward;
  final bool? isRepeatable;
  final bool clearDescription;
  final bool clearIcon;
  final bool clearGuild;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (questType != null) map['quest_type'] = questType!.wire;
    if (clearDescription) {
      map['description'] = null;
    } else if (description != null) {
      map['description'] = description;
    }
    if (clearIcon) {
      map['icon'] = null;
    } else if (icon != null) {
      map['icon'] = icon;
    }
    if (clearGuild) {
      map['guild'] = null;
    } else if (guild != null) {
      map['guild'] = guild;
    }
    if (xpReward != null) map['xp_reward'] = xpReward;
    if (isRepeatable != null) map['is_repeatable'] = isRepeatable;
    return map;
  }

  factory QuestUpdate.fromJson(Map<String, dynamic> json) => QuestUpdate(
        name: json['name'] as String?,
        questType: json['quest_type'] == null
            ? null
            : QuestType.parse(json['quest_type'] as String?),
        description: json['description'] as String?,
        icon: json['icon'] as String?,
        guild: json['guild'] as String?,
        xpReward: json['xp_reward'] == null ? null : _asInt(json['xp_reward']),
        isRepeatable: json['is_repeatable'] as bool?,
      );
}
