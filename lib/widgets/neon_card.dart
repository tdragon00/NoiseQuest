import 'package:flutter/material.dart';

import '../core/theme/tokens.dart';

class NeonBackground extends StatelessWidget {
  const NeonBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bg, AppColors.bgGradientEnd],
        ),
      ),
      child: child,
    );
  }
}

class NeonCard extends StatelessWidget {
  const NeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.accent,
    this.radius = AppRadii.card,
    this.selected = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? accent;
  final double radius;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final borderColor = accent?.withValues(alpha: 0.85) ??
        (selected ? AppColors.primary : AppColors.outline);
    final content = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        boxShadow: accent == null
            ? null
            : [
                BoxShadow(
                  color: accent!.withValues(alpha: 0.18),
                  blurRadius: 8,
                ),
              ],
      ),
      child: Padding(padding: padding, child: child),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
