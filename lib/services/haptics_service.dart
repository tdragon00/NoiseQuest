import 'package:flutter/services.dart';

class HapticsService {
  const HapticsService();

  void selection() => HapticFeedback.selectionClick();

  void success() => HapticFeedback.mediumImpact();

  void error() => HapticFeedback.heavyImpact();
}
