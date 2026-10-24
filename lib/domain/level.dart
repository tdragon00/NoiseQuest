import 'package:equatable/equatable.dart';

/// Level curve and titles from SPEC §9.
class LevelEntry extends Equatable {
  const LevelEntry({required this.level, required this.minXp, required this.title});

  final int level;
  final int minXp;
  final String title;

  factory LevelEntry.fromJson(Map<String, dynamic> json) => LevelEntry(
        level: (json['level'] as num?)?.toInt() ?? 1,
        minXp: (json['min_xp'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [level, minXp, title];
}

class LevelConfig extends Equatable {
  const LevelConfig({required this.version, required this.levels});

  final String version;
  final List<LevelEntry> levels;

  factory LevelConfig.fromJson(Map<String, dynamic> json) {
    final raw = (json['levels'] as List?) ?? const [];
    final levels = raw
        .whereType<Map>()
        .map((e) => LevelEntry.fromJson(e.cast<String, dynamic>()))
        .where((e) => e.level > 0)
        .toList()
      ..sort((a, b) => a.level.compareTo(b.level));
    return LevelConfig(
      version: json['version']?.toString() ?? 'default',
      levels: levels,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'levels': levels
            .map((e) => {'level': e.level, 'min_xp': e.minXp, 'title': e.title})
            .toList(),
      };

  @override
  List<Object?> get props => [version, levels];
}

abstract final class LevelMath {
  static const int maxLevel = 50;

  /// Cumulative XP required to reach [level]: `50 * (L - 1) * L`.
  static int cumulativeXp(int level) {
    final capped = level.clamp(1, maxLevel);
    return 50 * (capped - 1) * capped;
  }

  static int levelForXp(int totalXp) {
    var level = 1;
    while (level < maxLevel && totalXp >= cumulativeXp(level + 1)) {
      level++;
    }
    return level;
  }

  static int xpIntoLevel(int totalXp) {
    final level = levelForXp(totalXp);
    return totalXp - cumulativeXp(level);
  }

  static int xpForNextLevel(int totalXp) {
    final level = levelForXp(totalXp);
    if (level >= maxLevel) return 0;
    return cumulativeXp(level + 1) - cumulativeXp(level);
  }

  static double progress(int totalXp) {
    if (levelForXp(totalXp) >= maxLevel) return 1;
    final span = xpForNextLevel(totalXp);
    if (span <= 0) return 1;
    return (xpIntoLevel(totalXp) / span).clamp(0.0, 1.0);
  }

  static String defaultTitle(int level) {
    final capped = level.clamp(1, maxLevel);
    const titles = <int, String>{
      1: 'Signal Wanderer',
      2: 'Neon Novice',
      3: 'Grid Scout',
      4: 'Chrome Adept',
      5: 'Voltage Runner',
      6: 'Alley Hacker',
      7: 'Pulse Weaver',
      8: 'Data Drifter',
      9: 'Neon Monk',
      10: 'Signal Hunter',
      11: 'Arcade Ranger',
      12: 'Cyber Knight',
      13: 'Plasma Warden',
      14: 'Chrome Lancer',
      15: 'Neon Arcanist',
      16: 'Quantum Ranger',
      17: 'Twilight Vigil',
      18: 'Starlight Seeker',
      19: 'Grid Sovereign',
      20: 'Neon Paladin',
      21: 'Arcade Ascendant',
      22: 'Chrome Hierophant',
      23: 'Pulse Sovereign',
      24: 'Voltage Champion',
      25: 'Synthetica Sage',
      26: 'Obsidian Vanguard',
      27: 'Starlit Archmage',
      28: 'Circuit Overlord',
      29: 'Grid Deity',
      30: 'Legend of the Neon Spire',
    };
    if (titles.containsKey(capped)) return titles[capped]!;
    if (capped <= 40) return 'Ascendant ${_roman(capped - 30)}';
    return 'Sovereign ${_roman(capped - 40)}';
  }

  static const _romanNumerals = [
    'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X',
  ];

  static String _roman(int n) =>
      n >= 1 && n <= 10 ? _romanNumerals[n - 1] : n.toString();
}

class LevelTable {
  LevelTable(this.config);

  final LevelConfig? config;

  List<LevelEntry> get entries => config?.levels ?? const [];

  int levelForXp(int totalXp) {
    if (entries.isEmpty) return LevelMath.levelForXp(totalXp);
    var level = 1;
    for (final entry in entries) {
      if (totalXp >= entry.minXp) level = entry.level;
    }
    return level.clamp(1, LevelMath.maxLevel);
  }

  String titleForLevel(int level) {
    if (entries.isEmpty) return LevelMath.defaultTitle(level);
    String? best;
    for (final entry in entries) {
      if (entry.level <= level && entry.title.isNotEmpty) best = entry.title;
    }
    return best ?? LevelMath.defaultTitle(level);
  }

  int cumulativeXp(int level) {
    if (entries.isEmpty) return LevelMath.cumulativeXp(level);
    final match = entries.where((e) => e.level == level);
    if (match.isNotEmpty) return match.first.minXp;
    // Interpolate from the nearest lower entry, else default curve.
    final lower = entries.where((e) => e.level < level).toList();
    if (lower.isEmpty) return 0;
    return lower.last.minXp;
  }

  int xpForNextLevel(int totalXp) {
    final level = levelForXp(totalXp);
    if (level >= LevelMath.maxLevel) return 0;
    return (cumulativeXp(level + 1) - cumulativeXp(level)).clamp(0, 1 << 30);
  }

  int xpIntoLevel(int totalXp) {
    final level = levelForXp(totalXp);
    return (totalXp - cumulativeXp(level)).clamp(0, 1 << 30);
  }

  double progress(int totalXp) {
    if (levelForXp(totalXp) >= LevelMath.maxLevel) return 1;
    final span = xpForNextLevel(totalXp);
    if (span <= 0) return 1;
    return (xpIntoLevel(totalXp) / span).clamp(0.0, 1.0);
  }

  String title(int totalXp) => titleForLevel(levelForXp(totalXp));
  int level(int totalXp) => levelForXp(totalXp);
}
