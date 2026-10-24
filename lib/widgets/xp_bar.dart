import 'package:flutter/material.dart';

import '../core/theme/typography.dart';
import '../core/theme/tokens.dart';

class XpBar extends StatelessWidget {
  const XpBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.color = AppColors.primary,
    this.trackColor = AppColors.outline,
  });

  final double progress;
  final double height;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        height: height,
        color: trackColor,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, AppColors.tertiary]),
            ),
          ),
        ),
      ),
    );
  }
}

class XpLabel extends StatelessWidget {
  const XpLabel({super.key, required this.text, this.color = AppColors.primary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.monoStyle.copyWith(
        fontSize: 13,
        color: color,
      ),
    );
  }
}
