import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/tokens.dart';
import '../../../domain/enums.dart';
import '../../../domain/quest.dart';
import '../../../l10n/l10n.dart';
import '../../../state/quests_provider.dart';
import '../../../widgets/emoji_picker.dart';

class QuestCreateScreen extends ConsumerStatefulWidget {
  const QuestCreateScreen({super.key});

  @override
  ConsumerState<QuestCreateScreen> createState() => _QuestCreateScreenState();
}

class _QuestCreateScreenState extends ConsumerState<QuestCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _guild = TextEditingController();
  final _xp = TextEditingController(text: '25');
  String _icon = '⚔️';
  QuestType _type = QuestType.task;
  bool _repeatable = false;
  bool _loading = false;

  static const _xpPicks = [5, 10, 25, 50, 100, 250];

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _guild.dispose();
    _xp.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final input = QuestCreate(
      id: const Uuid().v4(),
      name: _name.text.trim(),
      questType: _type,
      xpReward: int.tryParse(_xp.text.trim()) ?? 25,
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      icon: _icon,
      guild: _guild.text.trim().isEmpty ? null : _guild.text.trim(),
      isRepeatable: _repeatable,
    );
    await ref.read(questsProvider.notifier).create(input);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.questCreated)),
    );
    context.pop();
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final guilds = ref.watch(availableGuildsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createQuest)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.createQuestHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.card),
                        onTap: () async {
                          final icon = await showEmojiPicker(context, selected: _icon);
                          if (icon != null && icon.isNotEmpty) {
                            setState(() => _icon = icon);
                          }
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(AppRadii.card),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Text(_icon, style: const TextStyle(fontSize: 30)),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _name,
                          maxLength: 80,
                          autofocus: true,
                          decoration: InputDecoration(
                            labelText: l10n.questName,
                            hintText: l10n.questNameHint,
                            counterText: '',
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? l10n.nameRequired
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _description,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: l10n.questDescription,
                      hintText: l10n.questDescriptionHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _guild,
                    maxLength: 40,
                    decoration: InputDecoration(
                      labelText: l10n.guild,
                      hintText: l10n.guildHint,
                      counterText: '',
                    ),
                  ),
                  if (guilds.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final guild in guilds.take(6))
                            ActionChip(
                              label: Text(guild),
                              onPressed: () => setState(() => _guild.text = guild),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<QuestType>(
                          initialValue: _type,
                          decoration: InputDecoration(labelText: l10n.questType),
                          items: [
                            for (final type in QuestType.values)
                              DropdownMenuItem(
                                value: type,
                                child: Text(_typeLabel(context, type)),
                              ),
                          ],
                          onChanged: (value) => setState(() => _type = value ?? _type),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: TextFormField(
                          controller: _xp,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(labelText: l10n.xpRewardLabel),
                          validator: (value) {
                            final xp = int.tryParse(value?.trim() ?? '');
                            return (xp == null || xp < 1 || xp > 10000)
                                ? l10n.xpInvalid
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.quickPick, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      for (final xp in _xpPicks)
                        ChoiceChip(
                          label: Text('$xp'),
                          selected: _xp.text == '$xp',
                          onSelected: (_) => setState(() => _xp.text = '$xp'),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _repeatable,
                    onChanged: (value) => setState(() => _repeatable = value),
                    title: Text(l10n.repeatable),
                    subtitle: Text(
                      l10n.repeatableHelper,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _loading ? null : () => context.pop(),
                          child: Text(l10n.cancel),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(l10n.createQuestButton),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
