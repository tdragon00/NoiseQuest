import 'package:flutter/material.dart';

/// Design tokens from SPEC §11.1 and §11.5.
abstract final class AppColors {
  static const bg = Color(0xFF0A0714);
  static const bgGradientEnd = Color(0xFF171034);
  static const surface = Color(0xFF16112C);
  static const surfaceRaised = Color(0xFF1F1840);
  static const outline = Color(0xFF2E2560);
  static const primary = Color(0xFF00E5FF);
  static const secondary = Color(0xFFFF2FB9);
  static const tertiary = Color(0xFF7C4DFF);
  static const success = Color(0xFF00FFA3);
  static const warning = Color(0xFFFFB300);
  static const danger = Color(0xFFFF3D71);
  static const textPrimary = Color(0xFFF2F0FF);
  static const textSecondary = Color(0xFFA79FC4);
  static const gold = Color(0xFFFFD166);
  static const silver = Color(0xFFC9D6E8);
  static const bronze = Color(0xFFD98A5B);
}

abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

abstract final class AppRadii {
  static const chip = 8.0;
  static const card = 12.0;
  static const banner = 16.0;
  static const pill = 999.0;
}

abstract final class AppBreakpoints {
  static const compact = 600.0;
  static const medium = 1024.0;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < medium;
  static bool isExpanded(double width) => width >= medium;
}
