import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/constants/banner_presets.dart';

class NeonBannerPainter extends CustomPainter {
  NeonBannerPainter({required this.preset});

  final BannerPreset preset;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          preset.background,
          Color.lerp(preset.background, preset.secondary, 0.35)!,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    canvas.save();
    canvas.clipRect(rect);
    switch (preset.pattern) {
      case BannerPattern.perspectiveGrid:
        _grid(canvas, size);
      case BannerPattern.sunset:
        _sunset(canvas, size);
      case BannerPattern.rain:
        _rain(canvas, size);
      case BannerPattern.canyon:
        _canyon(canvas, size);
      case BannerPattern.horizon:
        _horizon(canvas, size);
      case BannerPattern.rings:
        _rings(canvas, size);
      case BannerPattern.orbit:
        _orbit(canvas, size);
      case BannerPattern.sweep:
        _sweep(canvas, size);
    }
    canvas.restore();
  }

  void _grid(Canvas canvas, Size size) {
    final horizon = size.height * 0.62;
    final glow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          preset.secondary.withValues(alpha: 0.38),
          preset.accent.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, horizon));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, horizon), glow);

    final line = Paint()
      ..color = preset.accent.withValues(alpha: 0.42)
      ..strokeWidth = 1;
    for (var i = -8; i <= 8; i++) {
      final x = size.width / 2 + i * size.width / 8;
      canvas.drawLine(Offset(size.width / 2, horizon), Offset(x, size.height), line);
    }
    for (var i = 0; i < 8; i++) {
      final t = i / 8;
      final y = horizon + math.pow(t, 2.1) * (size.height - horizon);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
    canvas.drawLine(
      Offset(0, horizon),
      Offset(size.width, horizon),
      Paint()
        ..color = preset.accent.withValues(alpha: 0.7)
        ..strokeWidth = 1.4,
    );
  }

  void _sunset(Canvas canvas, Size size) {
    final horizon = size.height * 0.72;
    final disc = Paint()..color = preset.secondary.withValues(alpha: 0.65);
    canvas.drawCircle(Offset(size.width * 0.72, horizon - size.height * 0.12), size.height * 0.3, disc);
    final cut = Paint()..color = preset.background.withValues(alpha: 0.85);
    for (var i = 0; i < 7; i++) {
      final y = horizon - size.height * 0.36 + i * size.height * 0.07;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, size.height * 0.012 + i * 1.2), cut);
    }
    final line = Paint()..color = preset.accent.withValues(alpha: 0.35);
    for (var i = 0; i < 5; i++) {
      final y = horizon + i * size.height * 0.065;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  void _rain(Canvas canvas, Size size) {
    final random = math.Random(7);
    final paint = Paint()..strokeWidth = 1.2;
    for (var i = 0; i < 34; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 6 + random.nextDouble() * 22;
      paint.color = (random.nextBool() ? preset.accent : preset.secondary)
          .withValues(alpha: 0.12 + random.nextDouble() * 0.35);
      canvas.drawLine(Offset(x, y), Offset(x, y + length), paint);
    }
    final band = Paint()..color = preset.accent.withValues(alpha: 0.05);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.4, size.width, size.height * 0.2), band);
  }

  void _canyon(Canvas canvas, Size size) {
    final random = math.Random(19);
    for (var i = 0; i < 9; i++) {
      final path = Path();
      final top = random.nextDouble() * size.height;
      final bottom = top + 6 + random.nextDouble() * 22;
      path.moveTo(0, top);
      path.lineTo(size.width * (0.3 + random.nextDouble() * 0.3), top - 10);
      path.lineTo(size.width, bottom);
      path.lineTo(size.width, bottom + 14);
      path.lineTo(0, top + 16);
      path.close();
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            preset.accent.withValues(alpha: 0.10 + random.nextDouble() * 0.16),
            preset.secondary.withValues(alpha: 0.05),
          ],
        ).createShader(Offset.zero & size);
      canvas.drawPath(path, paint);
    }
  }

  void _horizon(Canvas canvas, Size size) {
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.35 + i * 0.1);
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            (i.isEven ? preset.accent : preset.secondary).withValues(alpha: 0.28),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(0, y, size.width, 8));
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 8), paint);
    }
  }

  void _rings(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.08, size.height * 0.5);
    for (var i = 1; i <= 7; i++) {
      final radius = size.width * 0.09 * i;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = preset.accent.withValues(alpha: 0.28 / i + 0.03),
      );
    }
  }

  void _orbit(Canvas canvas, Size size) {
    final random = math.Random(3);
    final star = Paint()..color = Colors.white.withValues(alpha: 0.65);
    for (var i = 0; i < 40; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        random.nextDouble() * 1.2 + 0.3,
        star,
      );
    }
    final center = Offset(size.width * 0.75, size.height * 0.55);
    final planet = Paint()..color = preset.secondary.withValues(alpha: 0.55);
    canvas.drawCircle(center, size.height * 0.22, planet);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.35);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: size.height * 1.1, height: size.height * 0.28),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = preset.accent.withValues(alpha: 0.55),
    );
    canvas.restore();
  }

  void _sweep(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(-size.width * 0.2, size.height)
      ..lineTo(size.width * 0.35, 0)
      ..lineTo(size.width * 0.62, 0)
      ..lineTo(size.width * 0.07, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            preset.accent.withValues(alpha: 0.04),
            preset.accent.withValues(alpha: 0.22),
          ],
        ).createShader(Offset.zero & size),
    );
    final line = Paint()
      ..color = preset.accent.withValues(alpha: 0.25)
      ..strokeWidth = 1;
    for (var i = 0; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant NeonBannerPainter oldDelegate) =>
      oldDelegate.preset.id != preset.id;
}
