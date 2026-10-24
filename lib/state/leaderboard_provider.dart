import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/result.dart';
import '../data/remote/leaderboard_api.dart';
import '../domain/enums.dart';
import 'providers.dart';

class LeaderboardQuery extends Equatable {
  const LeaderboardQuery({this.scope = LeaderboardScope.global, this.guild});

  final LeaderboardScope scope;
  final String? guild;

  @override
  List<Object?> get props => [scope, guild];
}

final leaderboardProvider = FutureProvider.family<LeaderboardPage, LeaderboardQuery>(
  (ref, query) async {
    final result = await ref.watch(leaderboardApiProvider).fetch(
          scope: query.scope,
          guild: query.guild,
        );
    if (result case Success<LeaderboardPage>(value: final page)) return page;
    final failure = result as Failure<LeaderboardPage>;
    throw StateError(failure.message);
  },
);
