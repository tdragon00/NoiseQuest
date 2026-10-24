import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';

class GuildChip extends StatelessWidget {
  const GuildChip({
    super.key,
    required this.name,
    this.onTap,
    this.selected = false,
    this.dense = false,
  });

  final String name;
  final VoidCallback? onTap;
  final bool selected;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : AppSpacing.md,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.16)
            : AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppRadii.chip),
        border: Border.all(
          color: selected ? AppColors.primary : AppColors.outline,
        ),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontSize: dense ? 11 : 12,
            ),
      ),
    );
    if (onTap == null) return child;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.chip),
      onTap: onTap,
      child: child,
    );
  }
}
