import '../../domain/user.dart';
import '../local/local_store.dart';
import 'auth_repository.dart';

class UserRepository {
  UserRepository({required this.store, required this.auth});

  final LocalStore store;
  final AuthRepository auth;

  User? get cached => store.readUser();

  int get cachedTotalXp => cached?.totalXp ?? 0;

  Future<User?> refresh() async {
    final result = await auth.refreshMe();
    return result.valueOrNull;
  }
}
