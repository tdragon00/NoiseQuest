import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../domain/enums.dart';
import '../domain/quest.dart';
import '../l10n/l10n.dart';
import 'guild_chip.dart';

String questStatusLabel(BuildContext context, QuestStatus status) => switch (status) {
      QuestStatus.available => context.l10n.available,
      QuestStatus.inProgress => context.l10n.inProgress,
      QuestStatus.completed => context.l10n.completed,
    };

class QuestRow extends StatelessWidget {
  const QuestRow({
    super.key,
    required this.quest,
    this.onTap,
    this.showStatus = false,
  });

  final Quest quest;
  final VoidCallback? onTap;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final meta = quest.myStatus == QuestStatus.completed
        ? [
            if (quest.completedByName != null)
              context.l10n.completedBy(quest.completedByName!),
            if (quest.completedAt != null)
              DateFormat.yMMMd(Localizations.localeOf(context).toString())
                  .format(quest.completedAt!.toLocal()),
          ].join(' · ')
        : context.l10n.byAuthor(quest.authorName);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: quest.pendingSync ? AppColors.warning : AppColors.outline,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppRadii.chip),
                ),
                child: Text(quest.icon ?? '✦', style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quest.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (quest.pendingSync) ...[
                              const Icon(
                                Icons.cloud_upload_outlined,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '${quest.xpReward} XP',
                              style: AppTypography.monoStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (quest.hasGuild) ...[
                          GuildChip(name: quest.guild!, dense: true),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        if (showStatus) ...[
                          QuestStatusBadge(status: quest.myStatus),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestStatusBadge extends StatelessWidget {
  const QuestStatusBadge({super.key, required this.status});

  final QuestStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      QuestStatus.available => AppColors.primary,
      QuestStatus.inProgress => AppColors.warning,
      QuestStatus.completed => AppColors.success,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        questStatusLabel(context, status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class QuestTableRow extends StatelessWidget {
  const QuestTableRow({
    super.key,
    required this.quest,
    this.onTap,
    this.selected = false,
  });

  final Quest quest;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final date = quest.myStatus == QuestStatus.completed
        ? quest.completedAt
        : quest.createdAt;
    final dateText = date == null
        ? '—'
        : DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .format(date.toLocal());
    return Material(
      color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.outline)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(quest.icon ?? '✦', style: const TextStyle(fontSize: 20)),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  quest.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Expanded(
                flex: 2,
                child: quest.hasGuild
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: GuildChip(name: quest.guild!, dense: true),
                      )
                    : const Text('—', style: TextStyle(color: AppColors.textSecondary)),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  '${quest.xpReward} XP',
                  style: AppTypography.monoStyle,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  quest.authorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  dateText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SizedBox(
                width: 120,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: QuestStatusBadge(status: quest.myStatus),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestTableHeader extends StatelessWidget {
  const QuestTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    Widget cell(String text, int flex, {bool center = false}) => Expanded(
          flex: flex,
          child: Text(text, style: style, textAlign: center ? TextAlign.right : TextAlign.left),
        );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 36),
          cell(context.l10n.questName, 4),
          cell(context.l10n.guild, 2),
          cell(context.l10n.xpReward, 2),
          cell(context.l10n.author, 3),
          cell(context.l10n.created, 2),
          Expanded(
            flex: 3,
            child: Text(
              context.l10n.completed,
              style: style,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
