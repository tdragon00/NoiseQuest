import '../../core/utils/result.dart';
import '../../domain/level.dart';
import 'api_client.dart';

Future<Result<T>> _guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on Object catch (error) {
    final api = mapDioError(error);
    return Failure(api.message, code: api.code, field: api.field, statusCode: api.statusCode);
  }
}

class HealthInfo {
  const HealthInfo({required this.status, required this.version});

  final String status;
  final String version;
}

class MetaApi {
  MetaApi(this.client);

  final ApiClient client;

  Future<Result<HealthInfo>> health() {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>('/health');
      final data = response.data ?? const {};
      return HealthInfo(
        status: data['status']?.toString() ?? 'ok',
        version: data['version']?.toString() ?? 'unknown',
      );
    });
  }

  Future<Result<LevelConfig>> levels() {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>('/meta/levels');
      return LevelConfig.fromJson(response.data ?? const {});
    });
  }

  Future<Result<List<Map<String, dynamic>>>> bannerPresets() {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>('/meta/banner-presets');
      final raw = (response.data?['items'] as List?) ?? const [];
      return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    });
  }
}

Future<Result<HealthInfo>> checkHealth(String endpoint, TokenStorage tokens) {
  final client = ApiClient(endpoint: endpoint, tokens: tokens);
  return MetaApi(client).health();
}
