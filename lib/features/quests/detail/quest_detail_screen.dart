import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/tokens.dart';
import '../../../core/theme/typography.dart';
import '../../../domain/enums.dart';
import '../../../domain/quest.dart';
import '../../../l10n/l10n.dart';
import '../../../state/providers.dart';
import '../../../state/quests_provider.dart';
import '../../../state/session_provider.dart';
import '../../../widgets/guild_chip.dart';
import '../../../widgets/neon_card.dart';
import '../../../widgets/quest_row.dart';

class QuestDetailScreen extends ConsumerWidget {
  const QuestDetailScreen({super.key, required this.questId});

  final String questId;

  String _typeLabel(BuildContext context, QuestType type) {
    final l10n = context.l10n;
    return switch (type) {
      QuestType.task => l10n.questTypeTask,
      QuestType.challenge => l10n.questTypeChallenge,
      QuestType.raid => l10n.questTypeRaid,
      QuestType.event => l10n.questTypeEvent,
      QuestType.bounty => l10n.questTypeBounty,
    };
  }

  String _date(BuildContext context, DateTime value) =>
      DateFormat.yMMMd(Localizations.localeOf(context).toString())
          .add_Hm()
          .format(value.toLocal());

  Future<void> _start(BuildContext context, WidgetRef ref, Quest quest) async {
    await ref.read(questsProvider.notifier).start(quest);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.questStarted)));
  }

  Future<void> _complete(BuildContext context, WidgetRef ref, Quest quest) async {
    final before = ref.read(sessionProvider).user?.totalXp ?? 0;
    await ref.read(questsProvider.notifier).complete(quest);
    if (!context.mounted) return;
    final after = ref.read(sessionProvider).user?.totalXp ?? before;
    final table = ref.read(levelTableProvider);
    final beforeLevel = table.level(before);
    final afterLevel = table.level(after);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.questCompleted)),
    );
    if (afterLevel > beforeLevel) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(context.l10n.levelUp(afterLevel)),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  Future<void> _cancel(BuildContext context, WidgetRef ref, Quest quest) async {
    await ref.read(questsProvider.notifier).cancel(quest);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.questCancelled)));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Quest quest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteConfirmTitle),
        content: Text(context.l10n.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(questsProvider.notifier).delete(quest);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.questDeleted)));
    context.pop();
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Quest quest) async {
    final result = await showModalBottomSheet<QuestUpdate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => _QuestEditSheet(quest: quest),
    );
    if (result == null) return;
    await ref.read(questsProvider.notifier).edit(quest, result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.questUpdated)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final quest = ref.watch(questByIdProvider(questId));
    if (quest == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.notFoundTitle)),
      );
    }
    final user = ref.watch(sessionProvider).user;
    final isOwner = user != null && user.id == quest.authorId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questDetails),
        actions: [
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _edit(context, ref, quest);
                if (value == 'delete') _delete(context, ref, quest);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(l10n.editQuest),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline, color: AppColors.danger),
                    title: Text(l10n.deleteQuest),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NeonCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(AppRadii.card),
                            ),
                            child: Text(
                              quest.icon ?? '✦',
                              style: const TextStyle(fontSize: 32),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  quest.name,
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.xs,
                                  children: [
                                    QuestStatusBadge(status: quest.myStatus),
                                    if (quest.hasGuild)
                                      GuildChip(name: quest.guild!),
                                    Text(
                                      l10n.questTypeLabel(
                                        _typeLabel(context, quest.questType),
                                      ),
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    if (quest.isRepeatable)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.loop,
                                            size: 14,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            l10n.repeatable,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(color: AppColors.secondary),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${quest.xpReward}',
                                style: AppTypography.monoStyle.copyWith(
                                  fontSize: 30,
                                  color: AppColors.primary,
                                ),
                              ),
                              Text('XP', style: Theme.of(context).textTheme.labelSmall),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(l10n.description, style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        quest.description?.trim().isNotEmpty == true
                            ? quest.description!
                            : l10n.noDescription,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                      _MetaRow(label: l10n.author, value: quest.authorName),
                      _MetaRow(
                        label: l10n.created,
                        value: _date(context, quest.createdAt),
                      ),
                      if (quest.completedAt != null)
                        _MetaRow(
                          label: l10n.completedLabel,
                          value: _date(context, quest.completedAt!),
                        ),
                      if (quest.completedByName != null)
                        _MetaRow(
                          label: l10n.completedByLabel,
                          value: quest.completedByName!,
                        ),
                      if (quest.pendingSync)
                        _MetaRow(label: l10n.pendingSync, value: '⏳'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (quest.myStatus == QuestStatus.available ||
                    quest.myStatus == QuestStatus.inProgress)
                  Row(
                    children: [
                      if (quest.myStatus == QuestStatus.available)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _start(context, ref, quest),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l10n.start),
                          ),
                        ),
                      if (quest.myStatus == QuestStatus.inProgress) ...[
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _complete(context, ref, quest),
                            icon: const Icon(Icons.check),
                            label: Text(l10n.markComplete),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _cancel(context, ref, quest),
                            icon: const Icon(Icons.close),
                            label: Text(l10n.cancelQuest),
                          ),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _QuestEditSheet extends StatefulWidget {
  const _QuestEditSheet({required this.quest});

  final Quest quest;

  @override
  State<_QuestEditSheet> createState() => _QuestEditSheetState();
}

class _QuestEditSheetState extends State<_QuestEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _guild;
  late final TextEditingController _xp;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.quest.name);
    _description = TextEditingController(text: widget.quest.description ?? '');
    _guild = TextEditingController(text: widget.quest.guild ?? '');
    _xp = TextEditingController(text: '${widget.quest.xpReward}');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _guild.dispose();
    _xp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.editQuest, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.questName),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? l10n.nameRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _description,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(labelText: l10n.questDescription),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _guild,
                decoration: InputDecoration(labelText: l10n.guild),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _xp,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.xpRewardLabel),
                validator: (value) {
                  final xp = int.tryParse(value?.trim() ?? '');
                  return (xp == null || xp < 1 || xp > 10000) ? l10n.xpInvalid : null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.of(context).pop(
                    QuestUpdate(
                      name: _name.text.trim(),
                      description: _description.text.trim(),
                      clearDescription: _description.text.trim().isEmpty,
                      guild: _guild.text.trim(),
                      clearGuild: _guild.text.trim().isEmpty,
                      xpReward: int.parse(_xp.text.trim()),
                    ),
                  );
                },
                child: Text(l10n.saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
