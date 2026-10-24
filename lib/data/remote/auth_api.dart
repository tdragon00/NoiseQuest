import '../../core/utils/result.dart';
import '../../domain/user.dart';
import 'api_client.dart';

Future<Result<T>> _guard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on Object catch (error) {
    final api = mapDioError(error);
    return Failure(api.message, code: api.code, field: api.field, statusCode: api.statusCode);
  }
}

class AuthApi {
  AuthApi(this.client);

  final ApiClient client;

  Future<Result<AuthSession>> register({
    required String email,
    required String password,
    String? username,
    String? avatar,
  }) {
    return _guard(() async {
      final response = await client.dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          if (username != null && username.trim().isNotEmpty) 'username': username.trim(),
          if (avatar != null && avatar.isNotEmpty) 'avatar': avatar,
        },
      );
      return AuthSession.fromJson(response.data ?? const {});
    });
  }

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) {
    return _guard(() async {
      final response = await client.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthSession.fromJson(response.data ?? const {});
    });
  }

  Future<Result<User>> me() {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>('/auth/me');
      return User.fromJson(response.data ?? const {});
    });
  }

  Future<Result<User>> updateProfile({
    Object? username = _unset,
    Object? avatar = _unset,
    String? bannerPresetId,
  }) {
    return _guard(() async {
      final body = <String, dynamic>{};
      if (!identical(username, _unset)) body['username'] = username;
      if (!identical(avatar, _unset)) body['avatar'] = avatar;
      if (bannerPresetId != null) body['banner_preset_id'] = bannerPresetId;
      final response = await client.dio.patch<Map<String, dynamic>>(
        '/users/me',
        data: body,
      );
      return User.fromJson(response.data ?? const {});
    });
  }

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _guard(() async {
      await client.dio.post<void>(
        '/users/me/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    });
  }

  Future<Result<void>> deleteAccount() {
    return _guard(() async {
      await client.dio.delete<void>(
        '/users/me',
        data: {'confirmation': 'DELETE MY ACCOUNT'},
      );
    });
  }

  Future<Result<Map<String, dynamic>>> exportData() {
    return _guard(() async {
      final response = await client.dio.get<Map<String, dynamic>>('/me/export');
      return response.data ?? const {};
    });
  }
}

const Object _unset = Object();
