import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/tokens.dart';
import '../../core/utils/result.dart';
import '../../domain/enums.dart';
import '../../domain/guild.dart';
import '../../domain/level.dart';
import '../../domain/quest.dart';
import '../../domain/user.dart';
import '../../l10n/l10n.dart';
import '../../state/guilds_provider.dart';
import '../../state/providers.dart';
import '../../state/quests_provider.dart';
import '../../state/session_provider.dart';
import '../../widgets/banner_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/guild_chip.dart';
import '../../widgets/neon_card.dart';
import '../../widgets/quest_row.dart';
import '../../widgets/sync_indicator.dart';
import '../../widgets/xp_bar.dart';

class BoardScreen extends ConsumerWidget {
  const BoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionProvider);
    final quests = ref.watch(questsProvider);
    final guilds = ref.watch(guildsProvider);
    final table = ref.watch(levelTableProvider);
    final user = session.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Future<void> refresh() async {
      await ref.read(questsProvider.notifier).refresh();
      await ref.read(guildsProvider.notifier).refresh();
    }

    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= AppBreakpoints.medium;
    final level = table.level(user.totalXp);
    final title = table.title(user.totalXp);
    final breakdown = guilds.value?.guilds ?? const <GuildSummary>[];
    final questList = quests.value ?? const <Quest>[];
    final done = questList.where((q) => q.myStatus == QuestStatus.completed).length;

    final banner = BannerView(
      displayName: user.displayName,
      avatar: user.avatar,
      level: level,
      title: title,
      totalXp: user.totalXp,
      presetId: user.bannerPresetId,
      levelTable: table,
      onTap: () => context.push('/banner'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.guildBoard),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Center(child: SyncIndicator()),
          ),
          IconButton(
            tooltip: l10n.refresh,
            onPressed: refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/quests/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.createQuest),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xxxl * 2,
          ),
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: banner),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 2,
                    child: _ProfileCard(
                      user: user,
                      level: level,
                      title: title,
                      table: table,
                      completed: done,
                      guildXp: breakdown.fold<int>(0, (sum, g) => sum + g.xp),
                    ),
                  ),
                ],
              )
            else ...[
              banner,
              const SizedBox(height: AppSpacing.md),
              _ProfileCard(
                user: user,
                level: level,
                title: title,
                table: table,
                completed: done,
                guildXp: breakdown.fold<int>(0, (sum, g) => sum + g.xp),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Text(l10n.guilds, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                guilds.when(
                  data: (value) => Text(
                    l10n.guildCount(value?.guilds.length ?? 0),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            guilds.when(
              data: (items) {
                final list = items?.guilds ?? const <GuildSummary>[];
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.shield_outlined,
                    title: l10n.noGuilds,
                    body: l10n.noGuildsHint,
                  );
                }
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final guild in list)
                      GuildChip(
                        name: '${guild.name} · ${guild.xp} XP',
                        onTap: () => context.go('/leaderboard'),
                      ),
                  ],
                );
              },
              error: (error, _) => ErrorState(
                message: error is Failure ? error.message : l10n.errorGeneric,
                onRetry: () => ref.read(guildsProvider.notifier).refresh(),
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: LinearProgressIndicator(),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            quests.when(
              data: (page) => _QuestColumns(page: page, wide: isWide),
              error: (error, _) => ErrorState(
                message: error is Failure ? error.message : l10n.errorGeneric,
                onRetry: refresh,
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestColumns extends StatelessWidget {
  const _QuestColumns({required this.page, required this.wide});

  final List<Quest> page;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final available = page.where((q) => q.myStatus == QuestStatus.available).toList();
    final active = page.where((q) => q.myStatus == QuestStatus.inProgress).toList();
    final completed = page.where((q) => q.myStatus == QuestStatus.completed).toList();

    Widget column({
      required String title,
      required IconData icon,
      required Color color,
      required List<Quest> items,
      required String empty,
      required String route,
    }) {
      return NeonCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        accent: color.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color),
                  ),
                ),
                Text('${items.length}', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text(
                  empty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              for (final quest in items.take(5)) ...[
                QuestRow(
                  quest: quest,
                  onTap: () => context.push('/quests/${quest.id}'),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            TextButton(
              onPressed: () => context.go(route),
              child: Text(l10n.viewAll),
            ),
          ],
        ),
      );
    }

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: column(
              title: l10n.available,
              icon: Icons.bolt,
              color: AppColors.primary,
              items: available,
              empty: l10n.noAvailableQuests,
              route: '/quests/available',
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: column(
              title: l10n.inProgress,
              icon: Icons.local_fire_department,
              color: AppColors.warning,
              items: active,
              empty: l10n.noActiveQuests,
              route: '/quests/in_progress',
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: column(
              title: l10n.completed,
              icon: Icons.check_circle,
              color: AppColors.success,
              items: completed,
              empty: l10n.noCompletedQuests,
              route: '/quests/completed',
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        column(
          title: l10n.inProgress,
          icon: Icons.local_fire_department,
          color: AppColors.warning,
          items: active,
          empty: l10n.noActiveQuests,
          route: '/quests/in_progress',
        ),
        const SizedBox(height: AppSpacing.lg),
        column(
          title: l10n.available,
          icon: Icons.bolt,
          color: AppColors.primary,
          items: available,
          empty: l10n.noAvailableQuests,
          route: '/quests/available',
        ),
        const SizedBox(height: AppSpacing.lg),
        column(
          title: l10n.completed,
          icon: Icons.check_circle,
          color: AppColors.success,
          items: completed,
          empty: l10n.noCompletedQuests,
          route: '/quests/completed',
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.user,
    required this.level,
    required this.title,
    required this.table,
    required this.completed,
    required this.guildXp,
  });

  final User user;
  final int level;
  final String title;
  final LevelTable table;
  final int completed;
  final int guildXp;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final into = table.xpIntoLevel(user.totalXp);
    final span = table.xpForNextLevel(user.totalXp);
    return NeonCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      accent: AppColors.secondary.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.levelTitle(level),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.primary,
                          ),
                    ),
                    Text(title, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Text(
                '@${user.username ?? user.displayName}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          XpBar(progress: table.progress(user.totalXp)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            level >= LevelMath.maxLevel ? l10n.maxLevel : l10n.xpProgress('$into', '$span'),
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _Stat(label: l10n.totalXp, value: '${user.totalXp}'),
              _Stat(label: l10n.questsDone, value: '$completed'),
              _Stat(label: l10n.guildXp, value: '$guildXp'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
