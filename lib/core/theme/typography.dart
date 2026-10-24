import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class AppTypography {
  static const display = 'Orbitron';
  static const body = 'Rajdhani';
  static const mono = 'Share Tech Mono';

  static TextTheme textTheme() {
    const base = Colors.white;
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: display,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        color: base,
      ),
      displayMedium: TextStyle(
        fontFamily: display,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: base,
      ),
      displaySmall: TextStyle(
        fontFamily: display,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: base,
      ),
      headlineMedium: TextStyle(
        fontFamily: display,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: base,
      ),
      headlineSmall: TextStyle(
        fontFamily: display,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: base,
      ),
      titleLarge: TextStyle(
        fontFamily: body,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: base,
      ),
      titleMedium: TextStyle(
        fontFamily: body,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleSmall: TextStyle(
        fontFamily: body,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      bodyLarge: TextStyle(
        fontFamily: body,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: body,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontFamily: body,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontFamily: body,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: base,
      ),
      labelMedium: TextStyle(
        fontFamily: body,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontFamily: body,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      ),
    );
  }

  static const monoStyle = TextStyle(
    fontFamily: mono,
    fontSize: 15,
    color: AppColors.primary,
  );
}
