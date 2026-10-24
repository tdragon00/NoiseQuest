import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/tokens.dart';
import '../../domain/enums.dart';
import '../../l10n/l10n.dart';
import '../../state/guilds_provider.dart';
import '../../state/leaderboard_provider.dart';
import '../../state/session_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/neon_card.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.global;
  String? _guild;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final guilds = ref.watch(guildNamesProvider);
    if (_scope == LeaderboardScope.guild && _guild == null && guilds.isNotEmpty) {
      _guild = guilds.first;
    }
    final query = LeaderboardQuery(scope: _scope, guild: _guild);
    final async = ref.watch(leaderboardProvider(query));
    final me = ref.watch(sessionProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.leaderboards),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: () => ref.invalidate(leaderboardProvider(query)),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    SegmentedButton<LeaderboardScope>(
                      segments: [
                        ButtonSegment(
                          value: LeaderboardScope.global,
                          icon: const Icon(Icons.public),
                          label: Text(l10n.global),
                        ),
                        ButtonSegment(
                          value: LeaderboardScope.guild,
                          icon: const Icon(Icons.shield_outlined),
                          label: Text(l10n.guildScope),
                        ),
                      ],
                      selected: {_scope},
                      onSelectionChanged: (value) {
                        setState(() {
                          _scope = value.first;
                          if (_scope == LeaderboardScope.guild && _guild == null) {
                            _guild = guilds.isNotEmpty ? guilds.first : null;
                          }
                        });
                      },
                    ),
                    if (_scope == LeaderboardScope.guild) ...[
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        initialValue: _guild,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.chooseGuild,
                          isDense: true,
                        ),
                        items: [
                          for (final guild in guilds)
                            DropdownMenuItem(value: guild, child: Text(guild)),
                        ],
                        onChanged: (value) => setState(() => _guild = value),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _scope == LeaderboardScope.global
                          ? l10n.leaderboardGlobalHint
                          : l10n.leaderboardGuildHint,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: async.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => ErrorState(
                    message: '$error',
                    onRetry: () => ref.invalidate(leaderboardProvider(query)),
                  ),
                  data: (page) {
                    if (page.items.isEmpty) {
                      return EmptyState(
                        icon: Icons.leaderboard_outlined,
                        title: l10n.noLeaderboard,
                        body: l10n.noGuildXp,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(leaderboardProvider(query)),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: page.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final entry = page.items[index];
                          final isMe = me != null && entry.userId == me.id;
                          return NeonCard(
                            accent: isMe ? AppColors.primary : null,
                            selected: isMe,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  child: Text(
                                    '#${entry.rank}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: entry.rank <= 3
                                              ? AppColors.secondary
                                              : AppColors.textSecondary,
                                        ),
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor: AppColors.surfaceRaised,
                                  child: Text(entry.avatar ?? '✦'),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              entry.displayName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: AppSpacing.sm),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.16),
                                                borderRadius:
                                                    BorderRadius.circular(AppRadii.chip),
                                              ),
                                              child: Text(
                                                l10n.you,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(color: AppColors.primary),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        '${entry.title} · ${l10n.levelShort(entry.level)}',
                                        style: Theme.of(context).textTheme.labelSmall,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${entry.xp} XP',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: AppColors.primary),
                                    ),
                                    Text(
                                      '${entry.totalXp} ${l10n.totalXp}',
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
