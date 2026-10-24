import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  SettingsService(this.prefs);

  static const _kLanguage = 'settings.language';
  static const _kSound = 'settings.sound';

  final SharedPreferences prefs;

  /// `null` means "System default".
  String? get languageCode {
    final value = prefs.getString(_kLanguage);
    return value == null || value.isEmpty || value == 'system' ? null : value;
  }

  bool get soundEnabled => prefs.getBool(_kSound) ?? true;

  Future<void> setLanguageCode(String? code) async {
    if (code == null || code.isEmpty) {
      await prefs.setString(_kLanguage, 'system');
    } else {
      await prefs.setString(_kLanguage, code);
    }
  }

  Future<void> setSoundEnabled(bool enabled) => prefs.setBool(_kSound, enabled);
}
