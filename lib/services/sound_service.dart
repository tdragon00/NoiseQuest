import 'package:flutter/services.dart';


enum SoundEvent { createQuest, startQuest, completeQuest, levelUp }

/// Placeholder sound layer (SPEC §5.11, D9). Uses system sounds and haptics so
/// v1 ships no audio assets and carries no desktop audio dependency.
abstract class SoundService {
  bool get enabled;
  set enabled(bool value);

  void play(SoundEvent event);
}

class PlaceholderSoundService implements SoundService {
  PlaceholderSoundService({this.enabled = true});

  @override
  bool enabled;

  @override
  void play(SoundEvent event) {
    if (!enabled) return;
    // Never block the action that triggered the sound (FR-54).
    switch (event) {
      case SoundEvent.createQuest:
        HapticFeedback.selectionClick();
        SystemSound.play(SystemSoundType.click);
      case SoundEvent.startQuest:
        HapticFeedback.lightImpact();
        SystemSound.play(SystemSoundType.click);
      case SoundEvent.completeQuest:
        HapticFeedback.mediumImpact();
        SystemSound.play(SystemSoundType.alert);
      case SoundEvent.levelUp:
        HapticFeedback.heavyImpact();
        SystemSound.play(SystemSoundType.alert);
    }
  }
}
