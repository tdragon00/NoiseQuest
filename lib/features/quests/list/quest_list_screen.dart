import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/utils/result.dart';
import '../../../domain/enums.dart';
import '../../../domain/quest.dart';
import '../../../domain/quest_query.dart';
import '../../../l10n/l10n.dart';
import '../../../state/quests_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/quest_row.dart';

class QuestListScreen extends ConsumerStatefulWidget {
  const QuestListScreen({super.key, required this.status});

  final QuestStatus status;

  @override
  ConsumerState<QuestListScreen> createState() => _QuestListScreenState();
}

class _QuestListScreenState extends ConsumerState<QuestListScreen> {
  final _search = TextEditingController();
  String _guild = '';
  SortOption _sort = SortOption.newest;
  bool _descending = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _title(BuildContext context) {
    final l10n = context.l10n;
    return switch (widget.status) {
      QuestStatus.available => l10n.available,
      QuestStatus.inProgress => l10n.inProgress,
      QuestStatus.completed => l10n.completed,
    };
  }

  String _sortLabel(BuildContext context, SortOption option) {
    final l10n = context.l10n;
    return switch (option) {
      SortOption.guild => l10n.sortGuild,
      SortOption.newest => l10n.sortNewest,
      SortOption.recentlyCompleted => l10n.sortRecentlyCompleted,
      SortOption.xp => l10n.sortXp,
      SortOption.name => l10n.sortName,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final questsAsync = ref.watch(questsProvider);
    final guilds = ref.watch(availableGuildsProvider);
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(title: Text(_title(context))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/quests/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.newQuest),
      ),
      body: questsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: error is Failure ? error.message : l10n.errorGeneric,
          onRetry: () => ref.read(questsProvider.notifier).refresh(),
        ),
        data: (all) {
          final filtered = sortQuests(
            filterQuests(
              all,
              status: widget.status,
              guild: _guild,
              query: _search.text,
            ),
            _sort,
            descending: _descending,
          );
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l10n.searchQuests,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _search.clear();
                                  setState(() {});
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _guild.isEmpty ? null : _guild,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.filterByGuild,
                              isDense: true,
                            ),
                            items: [
                              DropdownMenuItem(value: '', child: Text(l10n.all)),
                              for (final guild in guilds)
                                DropdownMenuItem(value: guild, child: Text(guild)),
                            ],
                            onChanged: (value) => setState(() => _guild = value ?? ''),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: DropdownButtonFormField<SortOption>(
                            initialValue: _sort,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.sortBy,
                              isDense: true,
                            ),
                            items: [
                              for (final option in SortOption.values)
                                DropdownMenuItem(
                                  value: option,
                                  child: Text(_sortLabel(context, option)),
                                ),
                            ],
                            onChanged: (value) => setState(() => _sort = value ?? _sort),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.sortBy,
                          onPressed: () => setState(() => _descending = !_descending),
                          icon: Icon(
                            _descending ? Icons.arrow_downward : Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Text(
                          l10n.questCount(filtered.length),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        icon: _search.text.isNotEmpty
                            ? Icons.search_off
                            : Icons.inbox_outlined,
                        title: _search.text.isNotEmpty
                            ? l10n.emptySearch
                            : l10n.noQuestsTitle,
                        body: l10n.noQuestsBody,
                        actionLabel: _search.text.isEmpty ? l10n.createFirstQuest : null,
                        onAction: _search.text.isEmpty
                            ? () => context.push('/quests/new')
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(questsProvider.notifier).refresh(),
                        child: width >= AppBreakpoints.medium
                            ? _wideList(filtered)
                            : ListView.separated(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSpacing.lg,
                                  AppSpacing.md,
                                  AppSpacing.lg,
                                  AppSpacing.xxxl * 2,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm),
                                itemBuilder: (context, index) => QuestRow(
                                  quest: filtered[index],
                                  showStatus: true,
                                  onTap: () => context.push('/quests/${filtered[index].id}'),
                                ),
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _wideList(List<Quest> quests) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxxl * 2,
      ),
      children: [
        const QuestTableHeader(),
        for (final quest in quests)
          QuestTableRow(
            quest: quest,
            onTap: () => context.push('/quests/${quest.id}'),
          ),
      ],
    );
  }
}
