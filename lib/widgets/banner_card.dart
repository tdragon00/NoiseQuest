import 'package:flutter/material.dart';

import '../core/constants/banner_presets.dart';
import '../core/theme/tokens.dart';
import '../core/theme/typography.dart';
import '../domain/level.dart';
import '../l10n/l10n.dart';
import 'banner_painter.dart';
import 'xp_bar.dart';

class BannerView extends StatelessWidget {
  const BannerView({
    super.key,
    required this.displayName,
    required this.avatar,
    required this.level,
    required this.title,
    required this.totalXp,
    required this.presetId,
    required this.levelTable,
    this.onTap,
    this.compact = false,
    this.highlighted = false,
  });

  final String displayName;
  final String? avatar;
  final int level;
  final String title;
  final int totalXp;
  final String presetId;
  final LevelTable levelTable;
  final VoidCallback? onTap;
  final bool compact;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final preset = presetById(presetId);
    final nextXp = levelTable.cumulativeXp(level + 1);
    final intoXp = (totalXp - levelTable.cumulativeXp(level)).clamp(0, 1 << 30);
    final span = level >= LevelMath.maxLevel ? 0 : (nextXp - levelTable.cumulativeXp(level));
    final progress = level >= LevelMath.maxLevel
        ? 1.0
        : (span <= 0 ? 1.0 : (intoXp / span).clamp(0.0, 1.0));

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(compact ? AppRadii.card : AppRadii.banner),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: NeonBannerPainter(preset: preset))),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.bg.withValues(alpha: compact ? 0.72 : 0.6),
                    AppColors.bg.withValues(alpha: compact ? 0.35 : 0.25),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? AppRadii.card : AppRadii.banner),
              border: Border.all(
                color: highlighted ? AppColors.primary : preset.accent.withValues(alpha: 0.9),
                width: highlighted ? 2 : 1.5,
              ),
            ),
            padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
            child: compact ? _compact(context, preset) : _full(context, preset, progress, intoXp, span),
          ),
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? AppRadii.card : AppRadii.banner),
        onTap: onTap,
        child: content,
      ),
    );
  }

  Widget _avatar(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.bg.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textPrimary.withValues(alpha: 0.35)),
      ),
      child: Text(avatar ?? '✦', style: TextStyle(fontSize: size * 0.5)),
    );
  }

  Widget _compact(BuildContext context, BannerPreset preset) {
    return Row(
      children: [
        _avatar(38),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: preset.accent,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.levelShort(level),
              style: TextStyle(
                fontFamily: AppTypography.display,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: preset.accent,
              ),
            ),
            Text(
              '${_format(totalXp)} XP',
              style: AppTypography.monoStyle.copyWith(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _full(
    BuildContext context,
    BannerPreset preset,
    double progress,
    int intoXp,
    int span,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _avatar(52),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: preset.accent,
                          letterSpacing: 0.4,
                        ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bg.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadii.chip),
                border: Border.all(color: preset.accent.withValues(alpha: 0.7)),
              ),
              child: Text(
                level >= LevelMath.maxLevel
                    ? context.l10n.maxLevel
                    : context.l10n.levelShort(level),
                style: TextStyle(
                  fontFamily: AppTypography.display,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: preset.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        XpBar(progress: progress, color: preset.accent),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            level >= LevelMath.maxLevel
                ? '${_format(totalXp)} XP'
                : context.l10n.xpProgress(
                    _format(intoXp),
                    _format(span),
                  ),
            style: AppTypography.monoStyle.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _format(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
