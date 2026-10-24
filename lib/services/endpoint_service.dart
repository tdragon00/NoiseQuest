import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/result.dart';

import '../data/remote/api_client.dart';
import '../data/remote/meta_api.dart';

class EndpointService {
  EndpointService(this.prefs, {required this.tokens});

  static const _kEndpoint = 'settings.endpoint';
  static const _kLaunched = 'settings.launched';

  final SharedPreferences prefs;
  final TokenStorage tokens;

  String get endpoint => prefs.getString(_kEndpoint) ?? kDefaultEndpoint;

  bool get hasLaunched => prefs.getBool(_kLaunched) ?? false;

  Future<void> markLaunched() => prefs.setBool(_kLaunched, true);

  Future<void> setEndpoint(String value) async {
    await prefs.setString(_kEndpoint, normalizeEndpoint(value));
  }

  static String? validate(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return 'invalid';
    if (uri.scheme != 'http' && uri.scheme != 'https') return 'invalid';
    return null;
  }

  Future<Result<HealthInfo>> test(String raw) async {
    final error = validate(raw);
    if (error != null) {
      return const Failure('That does not look like a valid URL.');
    }
    final result = await checkHealth(normalizeEndpoint(raw), tokens);
    return switch (result) {
      Success<HealthInfo>(value: final info) => Success(info),
      Failure<HealthInfo>(
        :final message,
        :final code,
        :final field,
        :final statusCode,
      ) =>
        Failure(message, code: code, field: field, statusCode: statusCode),
    };
  }
}
