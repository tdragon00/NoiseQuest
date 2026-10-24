import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/settings_service.dart';
import 'providers.dart';

class SettingsState {
  const SettingsState({this.languageCode, this.soundEnabled = true});

  /// `null` means "System default".
  final String? languageCode;
  final bool soundEnabled;

  SettingsState copyWith({String? languageCode, bool? soundEnabled, bool clearLanguage = false}) {
    return SettingsState(
      languageCode: clearLanguage ? null : (languageCode ?? this.languageCode),
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

class SettingsNotifier extends Notifier<SettingsState> {
  SettingsService get _service => ref.read(settingsServiceProvider);

  @override
  SettingsState build() {
    final service = ref.watch(settingsServiceProvider);
    return SettingsState(
      languageCode: service.languageCode,
      soundEnabled: service.soundEnabled,
    );
  }

  Future<void> setLanguageCode(String? code) async {
    await _service.setLanguageCode(code);
    state = state.copyWith(languageCode: code, clearLanguage: code == null);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _service.setSoundEnabled(enabled);
    state = state.copyWith(soundEnabled: enabled);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);
