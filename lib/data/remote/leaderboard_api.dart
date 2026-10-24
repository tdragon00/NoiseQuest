import 'package:equatable/equatable.dart';

import '../../core/utils/result.dart';
import '../../domain/enums.dart';
import 'api_client.dart';

Future<Result<T>> _guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on Object catch (error) {
    final api = mapDioError(error);
    return Failure(api.message, code: api.code, field: api.field, statusCode: api.statusCode);
  }
}

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.displayName,
    required this.bannerPresetId,
    required this.totalXp,
    required this.xp,
    required this.level,
    required this.title,
    this.avatar,
  });

  final int rank;
  final String userId;
  final String displayName;
  final String? avatar;
  final String bannerPresetId;
  final int totalXp;
  final int xp;
  final int level;
  final String title;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        rank: (json['rank'] as num?)?.toInt() ?? 0,
        userId: json['user_id']?.toString() ?? '',
        displayName: json['display_name']?.toString() ?? 'Unknown',
        avatar: json['avatar'] as String?,
        bannerPresetId: json['banner_preset_id']?.toString() ?? 'neon_grid',
        totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
        xp: (json['xp'] as num?)?.toInt() ?? 0,
        level: (json['level'] as num?)?.toInt() ?? 1,
        title: json['title']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'user_id': userId,
        'display_name': displayName,
        'avatar': avatar,
        'banner_preset_id': bannerPresetId,
        'total_xp': totalXp,
        'xp': xp,
        'level': level,
        'title': title,
      };

  @override
  List<Object?> get props => [
        rank,
        userId,
        displayName,
        avatar,
        bannerPresetId,
        totalXp,
        xp,
        level,
        title,
      ];
}

class LeaderboardPage extends Equatable {
  const LeaderboardPage({
    required this.scope,
    required this.items,
    this.guild,
    this.nextCursor,
  });

  final LeaderboardScope scope;
  final String? guild;
  final List<LeaderboardEntry> items;
  final String? nextCursor;

  factory LeaderboardPage.fromJson(Map<String, dynamic> json) {
    final raw = (json['items'] as List?) ?? const [];
    return LeaderboardPage(
      scope: json['scope'] == 'guild' ? LeaderboardScope.guild : LeaderboardScope.global,
      guild: json['guild'] as String?,
      items: raw
          .whereType<Map>()
          .map((e) => LeaderboardEntry.fromJson(e.cast<String, dynamic>()))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'scope': scope.wire,
        'guild': guild,
        'items': items.map((e) => e.toJson()).toList(),
        'next_cursor': nextCursor,
      };

  @override
  List<Object?> get props => [scope, guild, items, nextCursor];
}

class LeaderboardApi {
  LeaderboardApi(this.client);

  final ApiClient client;

  Future<Result<LeaderboardPage>> fetch({
    LeaderboardScope scope = LeaderboardScope.global,
    String? guild,
    int limit = 50,
  }) {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>(
        '/leaderboard',
        queryParameters: {
          'scope': scope.wire,
          if (scope == LeaderboardScope.guild && guild != null) 'guild': guild,
          'limit': limit,
        },
      );
      return LeaderboardPage.fromJson(response.data ?? const {});
    });
  }
}
