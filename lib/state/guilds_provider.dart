import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/result.dart';
import '../domain/guild.dart';
import 'providers.dart';

class GuildsNotifier extends AsyncNotifier<GuildBreakdown?> {
  @override
  Future<GuildBreakdown?> build() async {
    final cached = ref.read(guildRepositoryProvider).cached;
    if (cached != null) {
      unawaited(Future<void>.delayed(Duration.zero, refresh));
      return cached;
    }
    final result = await ref.read(guildRepositoryProvider).refresh();
    if (result case Success<GuildBreakdown>(value: final breakdown)) {
      return breakdown;
    }
    return const GuildBreakdown(totalXp: 0, guilds: []);
  }

  Future<void> refresh() async {
    final result = await ref.read(guildRepositoryProvider).refresh();
    if (result case Success<GuildBreakdown>(value: final breakdown)) {
      state = AsyncData(breakdown);
    }
  }

  void refreshFromCache() {
    state = AsyncData(ref.read(guildRepositoryProvider).cached);
  }

  List<String> get guildNames =>
      (state.value?.guilds ?? const <GuildSummary>[])
          .map((g) => g.name)
          .toList();
}

final guildsProvider = AsyncNotifierProvider<GuildsNotifier, GuildBreakdown?>(
  GuildsNotifier.new,
);

final guildNamesProvider = Provider<List<String>>((ref) {
  final breakdown = ref.watch(guildsProvider).value;
  return (breakdown?.guilds ?? const <GuildSummary>[]).map((g) => g.name).toList();
});
