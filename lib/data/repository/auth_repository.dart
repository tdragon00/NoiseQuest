import '../../core/utils/result.dart';
import '../../domain/user.dart';
import '../local/local_store.dart';
import '../remote/api_client.dart';
import '../remote/auth_api.dart';

class AuthRepository {
  AuthRepository({
    required this.tokens,
    required this.api,
    required this.store,
  });

  final TokenStorage tokens;
  final AuthApi api;
  final LocalStore store;

  Future<void> init() => tokens.load();

  Future<Result<AuthSession>> register({
    required String email,
    required String password,
    String? username,
    String? avatar,
  }) async {
    final result = await api.register(
      email: email,
      password: password,
      username: username,
      avatar: avatar,
    );
    if (result is Success<AuthSession>) {
      await _persist(result.value);
    }
    return result;
  }

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    final result = await api.login(email: email, password: password);
    if (result is Success<AuthSession>) {
      await _persist(result.value);
    }
    return result;
  }

  Future<Result<User>> refreshMe() async {
    final result = await api.me();
    if (result is Success<User>) {
      await store.writeUser(result.value);
    }
    return result;
  }

  Future<Result<User>> updateProfile({
    Object? username = _unset,
    Object? avatar = _unset,
    String? bannerPresetId,
  }) {
    return api.updateProfile(
      username: username,
      avatar: avatar,
      bannerPresetId: bannerPresetId,
    ).then((result) async {
      if (result is Success<User>) {
        await store.writeUser(result.value);
      }
      return result;
    });
  }

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return api.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<Result<Map<String, dynamic>>> exportData() => api.exportData();

  Future<Result<void>> deleteAccount() async {
    final result = await api.deleteAccount();
    if (result is Success<void>) {
      await tokens.clear();
      await store.clearCache();
    }
    return result;
  }

  Future<void> signOut({bool clearCache = false}) async {
    await tokens.clear();
    if (clearCache) await store.clearCache();
    await store.writeUser(null);
    await store.writeQuests(const []);
    await store.writeGuilds(null);
  }

  Future<void> _persist(AuthSession session) async {
    await tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await store.writeUser(session.user);
  }
}

const Object _unset = Object();
