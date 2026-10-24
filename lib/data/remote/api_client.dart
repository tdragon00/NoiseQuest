import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const kDefaultEndpoint = 'http://127.0.0.1:4010';

String normalizeEndpoint(String raw) {
  var value = raw.trim();
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  if (value.endsWith('/api/v1')) {
    value = value.substring(0, value.length - '/api/v1'.length);
  }
  return value;
}

String apiBaseFor(String endpoint) => '${normalizeEndpoint(endpoint)}/api/v1';

class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;
  String? _access;
  String? _refresh;

  String? get accessToken => _access;
  String? get refreshToken => _refresh;

  Future<void> load() async {
    _access = await _storage.read(key: _accessKey);
    _refresh = await _storage.read(key: _refreshKey);
  }

  Future<void> save({required String accessToken, required String refreshToken}) async {
    _access = accessToken;
    _refresh = refreshToken;
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.code,
    this.field,
    this.statusCode,
  });

  final String message;
  final String? code;
  final String? field;
  final int? statusCode;

  bool get isNetwork => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isConflict => statusCode == 409;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

ApiException mapDioError(Object error) {
  if (error is ApiException) return error;
  if (error is DioException) {
    final response = error.response;
    if (response != null) {
      final data = response.data;
      if (data is Map) {
        final payload = data['error'];
        if (payload is Map) {
          return ApiException(
            payload['message']?.toString() ?? 'Request failed.',
            code: payload['code']?.toString(),
            field: payload['field']?.toString(),
            statusCode: response.statusCode,
          );
        }
      }
      return ApiException(
        'Request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
    return const ApiException('Could not reach the server.');
  }
  return ApiException(error.toString());
}

class ApiClient {
  ApiClient({required String endpoint, required this.tokens})
      : endpoint = normalizeEndpoint(endpoint) {
    dio = Dio(
      BaseOptions(
        baseUrl: apiBaseFor(this.endpoint),
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        contentType: 'application/json',
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokens.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          if (status == 401 && !path.contains('/auth/refresh')) {
            final refreshed = await _refresh();
            if (refreshed) {
              final retry = await _retry(error.requestOptions);
              if (retry != null) {
                handler.resolve(retry);
                return;
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final String endpoint;
  final TokenStorage tokens;
  late final Dio dio;

  Completer<bool>? _refreshLock;

  Future<bool> _refresh() async {
    if (_refreshLock != null) return _refreshLock!.future;
    final completer = Completer<bool>();
    _refreshLock = completer;
    try {
      final refresh = await _readRefresh();
      if (refresh == null || refresh.isEmpty) {
        completer.complete(false);
        return false;
      }
      final plain = Dio(BaseOptions(baseUrl: apiBaseFor(endpoint)));
      final response = await plain.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final body = response.data;
      final access = body?['access_token']?.toString();
      final nextRefresh = body?['refresh_token']?.toString() ?? refresh;
      if (access == null || access.isEmpty) {
        completer.complete(false);
        return false;
      }
      await tokens.save(accessToken: access, refreshToken: nextRefresh);
      completer.complete(true);
      return true;
    } catch (_) {
      await tokens.clear();
      completer.complete(false);
      return false;
    } finally {
      _refreshLock = null;
    }
  }

  Future<String?> _readRefresh() async {
    // TokenStorage keeps the refresh token in secure storage; expose it via a
    // refresh call that reads the backing store directly.
    return tokens.refreshToken;
  }

  Future<Response<dynamic>?> _retry(RequestOptions options) async {
    try {
      final clone = Options(
        method: options.method,
        headers: Map<String, dynamic>.from(options.headers),
        contentType: options.contentType,
        responseType: options.responseType,
      );
      return await dio.request<dynamic>(
        options.path,
        data: options.data,
        queryParameters: options.queryParameters,
        options: clone,
      );
    } catch (_) {
      return null;
    }
  }
}
