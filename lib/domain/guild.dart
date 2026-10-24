import 'package:equatable/equatable.dart';

class GuildSummary extends Equatable {
  const GuildSummary({
    required this.name,
    required this.xp,
    required this.questCount,
  });

  final String name;
  final int xp;
  final int questCount;

  factory GuildSummary.fromJson(Map<String, dynamic> json) => GuildSummary(
        name: (json['name'] as String?)?.trim() ?? '',
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        questCount: (json['quest_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'xp': xp,
        'quest_count': questCount,
      };

  @override
  List<Object?> get props => [name, xp, questCount];
}

class GuildBreakdown extends Equatable {
  const GuildBreakdown({required this.totalXp, required this.guilds});

  final int totalXp;
  final List<GuildSummary> guilds;

  factory GuildBreakdown.fromJson(Map<String, dynamic> json) {
    final raw = (json['guilds'] as List?) ?? const [];
    return GuildBreakdown(
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      guilds: raw
          .whereType<Map>()
          .map((e) => GuildSummary.fromJson(e.cast<String, dynamic>()))
          .where((g) => g.name.isNotEmpty)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_xp': totalXp,
        'guilds': guilds.map((g) => g.toJson()).toList(),
      };

  int xpFor(String? guild) {
    final key = normalizeGuild(guild);
    if (key == null) return 0;
    for (final g in guilds) {
      if (normalizeGuild(g.name) == key) return g.xp;
    }
    return 0;
  }

  @override
  List<Object?> get props => [totalXp, guilds];
}

String? normalizeGuild(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed.toLowerCase();
}

class GuildRef extends Equatable {
  const GuildRef({required this.name, required this.xp, this.questCount = 0});

  final String name;
  final int xp;
  final int questCount;

  @override
  List<Object?> get props => [name, xp, questCount];
}
