import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum BannerPattern {
  perspectiveGrid,
  sunset,
  rain,
  canyon,
  horizon,
  rings,
  orbit,
  sweep;

  static BannerPattern parse(String? value) {
    return switch (value) {
      'sunset' => BannerPattern.sunset,
      'rain' => BannerPattern.rain,
      'canyon' => BannerPattern.canyon,
      'horizon' => BannerPattern.horizon,
      'rings' => BannerPattern.rings,
      'orbit' => BannerPattern.orbit,
      'sweep' => BannerPattern.sweep,
      _ => BannerPattern.perspectiveGrid,
    };
  }
}

class BannerPreset extends Equatable {
  const BannerPreset({
    required this.id,
    required this.name,
    required this.accent,
    required this.pattern,
    this.background = const Color(0xFF0A0714),
    this.secondary = const Color(0xFF7C4DFF),
  });

  final String id;
  final String name;
  final Color accent;
  final BannerPattern pattern;
  final Color background;
  final Color secondary;

  @override
  List<Object?> get props => [id, name, accent, pattern, background, secondary];
}

const List<BannerPreset> kBannerPresets = [
  BannerPreset(
    id: 'neon_grid',
    name: 'Neon Grid',
    accent: Color(0xFF00E5FF),
    pattern: BannerPattern.perspectiveGrid,
    secondary: Color(0xFF7C4DFF),
  ),
  BannerPreset(
    id: 'synthwave_sunset',
    name: 'Synthwave Sunset',
    accent: Color(0xFFFF2FB9),
    pattern: BannerPattern.sunset,
    background: Color(0xFF1A0A22),
    secondary: Color(0xFFFFB300),
  ),
  BannerPreset(
    id: 'matrix_rain',
    name: 'Matrix Rain',
    accent: Color(0xFF00FFA3),
    pattern: BannerPattern.rain,
    background: Color(0xFF030F0A),
    secondary: Color(0xFF00E5FF),
  ),
  BannerPreset(
    id: 'chrome_canyon',
    name: 'Chrome Canyon',
    accent: Color(0xFF7C4DFF),
    pattern: BannerPattern.canyon,
    background: Color(0xFF100A24),
    secondary: Color(0xFFC9D6E8),
  ),
  BannerPreset(
    id: 'vapor_horizon',
    name: 'Vapor Horizon',
    accent: Color(0xFFFFB300),
    pattern: BannerPattern.horizon,
    background: Color(0xFF0D1522),
    secondary: Color(0xFF00FFA3),
  ),
  BannerPreset(
    id: 'pulse_wave',
    name: 'Pulse Wave',
    accent: Color(0xFF00E5FF),
    pattern: BannerPattern.rings,
    background: Color(0xFF070A1A),
  ),
  BannerPreset(
    id: 'retro_orbit',
    name: 'Retro Orbit',
    accent: Color(0xFFFF3D71),
    pattern: BannerPattern.orbit,
    background: Color(0xFF05050F),
    secondary: Color(0xFF7C4DFF),
  ),
  BannerPreset(
    id: 'midnight_pulse',
    name: 'Midnight Pulse',
    accent: Color(0xFFA79FC4),
    pattern: BannerPattern.sweep,
    background: Color(0xFF0A0714),
    secondary: Color(0xFF00E5FF),
  ),
];

BannerPreset presetById(String? id) {
  return kBannerPresets.firstWhere(
    (p) => p.id == id,
    orElse: () => kBannerPresets.first,
  );
}
