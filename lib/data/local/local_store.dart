import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/guild.dart';
import '../../domain/level.dart';
import '../../domain/quest.dart';
import '../../domain/user.dart';
import '../outbox/outbox.dart';

/// Local cache: last-known server state plus the outbox.
///
/// The cache is deliberately a small JSON document store rather than SQLite:
/// the dataset is bounded by the quest page limit, every platform (including
/// web) supports it without codegen, and the repository boundary keeps a later
/// drift migration local to this class.
class LocalStore {
  LocalStore(this.prefs);

  final SharedPreferences prefs;

  static const _kUser = 'cache.user';
  static const _kQuests = 'cache.quests';
  static const _kGuilds = 'cache.guilds';
  static const _kLevels = 'cache.levels';
  static const _kOutbox = 'cache.outbox';
  static const _kLastSync = 'cache.last_sync';

  User? readUser() {
    final raw = prefs.getString(_kUser);
    return _decodeMap(raw, User.fromJson);
  }

  List<Quest> readQuests() {
    final raw = prefs.getString(_kQuests);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => Quest.fromJson(e.cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  GuildBreakdown? readGuilds() {
    final raw = prefs.getString(_kGuilds);
    return _decodeMap(raw, GuildBreakdown.fromJson);
  }

  LevelConfig? readLevelConfig() {
    final raw = prefs.getString(_kLevels);
    return _decodeMap(raw, LevelConfig.fromJson);
  }

  List<OutboxOp> readOutbox() => decodeOutbox(prefs.getString(_kOutbox));

  String? get lastSync => prefs.getString(_kLastSync);

  Future<void> writeUser(User? user) async {
    if (user == null) {
      await prefs.remove(_kUser);
    } else {
      await prefs.setString(_kUser, jsonEncode(user.toJson()));
    }
  }

  Future<void> writeQuests(List<Quest> quests) async {
    await prefs.setString(_kQuests, jsonEncode(quests.map((q) => q.toJson()).toList()));
  }

  Future<void> writeGuilds(GuildBreakdown? guilds) async {
    if (guilds == null) {
      await prefs.remove(_kGuilds);
    } else {
      await prefs.setString(_kGuilds, jsonEncode(guilds.toJson()));
    }
  }

  Future<void> writeLevelConfig(LevelConfig? config) async {
    if (config == null) {
      await prefs.remove(_kLevels);
    } else {
      await prefs.setString(_kLevels, jsonEncode(config.toJson()));
    }
  }

  Future<void> writeOutbox(List<OutboxOp> ops) async {
    await prefs.setString(
      _kOutbox,
      jsonEncode(ops.map((op) => op.toJson()).toList()),
    );
  }

  Future<void> setLastSync(DateTime value) async {
    await prefs.setString(_kLastSync, value.toUtc().toIso8601String());
  }

  Future<void> clearCache() async {
    await prefs.remove(_kUser);
    await prefs.remove(_kQuests);
    await prefs.remove(_kGuilds);
    await prefs.remove(_kLevels);
    await prefs.remove(_kOutbox);
    await prefs.remove(_kLastSync);
  }

  T? _decodeMap<T>(String? raw, T Function(Map<String, dynamic>) parse) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return parse(decoded.cast<String, dynamic>());
    } catch (_) {
      // Fall through to null: malformed cache degrades to empty state.
    }
    return null;
  }
}
