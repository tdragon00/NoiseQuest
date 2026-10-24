import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/result.dart';
import '../data/repository/auth_repository.dart';
import '../domain/anonymous_name.dart';
import '../domain/user.dart';
import 'providers.dart';

enum SessionStatus { signedOut, signedIn }

class SessionState {
  const SessionState({required this.status, this.user});

  final SessionStatus status;
  final User? user;

  bool get isSignedIn => status == SessionStatus.signedIn && user != null;

  SessionState copyWith({SessionStatus? status, User? user, bool clearUser = false}) {
    return SessionState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  AuthRepository get _auth => ref.read(authRepositoryProvider);

  @override
  SessionState build() {
    final cached = ref.watch(localStoreProvider).readUser();
    return SessionState(
      status: cached == null ? SessionStatus.signedOut : SessionStatus.signedIn,
      user: cached,
    );
  }

  Future<Result<void>> register({
    required String email,
    required String password,
    String? username,
    String? avatar,
  }) async {
    final result = await _auth.register(
      email: email,
      password: password,
      username: username,
      avatar: avatar,
    );
    return _apply(result);
  }

  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _auth.login(email: email, password: password);
    return _apply(result);
  }

  Future<void> signOut({bool clearCache = false}) async {
    await _auth.signOut(clearCache: clearCache);
    state = const SessionState(status: SessionStatus.signedOut);
  }

  Future<void> refresh() async {
    final result = await _auth.refreshMe();
    if (result case Success<User>(value: final user)) {
      state = SessionState(status: SessionStatus.signedIn, user: user);
    }
  }

  void reloadFromCache() {
    final user = ref.read(localStoreProvider).readUser();
    state = SessionState(
      status: user == null ? SessionStatus.signedOut : SessionStatus.signedIn,
      user: user,
    );
  }

  void setUser(User user) {
    state = SessionState(status: SessionStatus.signedIn, user: user);
  }

  Future<Result<User>> updateProfile({
    String? username,
    bool clearUsername = false,
    String? avatar,
    bool clearAvatar = false,
    String? bannerPresetId,
  }) async {
    final result = await _auth.updateProfile(
      username: clearUsername ? null : username,
      avatar: clearAvatar ? null : avatar,
      bannerPresetId: bannerPresetId,
    );
    if (result case Success<User>(value: final serverUser)) {
      var user = serverUser;
      if (bannerPresetId != null) {
        user = user.copyWith(bannerPresetId: bannerPresetId);
      }
      if (clearAvatar) {
        user = user.copyWith(clearAvatar: true);
      } else if (avatar != null) {
        user = user.copyWith(avatar: avatar);
      }
      if (clearUsername) {
        user = user.copyWith(
          clearUsername: true,
          displayName: anonymousDisplayName(seed: user.id),
        );
      } else if (username != null) {
        user = user.copyWith(username: username, displayName: username);
      }
      await ref.read(localStoreProvider).writeUser(user);
      state = SessionState(status: SessionStatus.signedIn, user: user);
      return Success(user);
    }
    return result;
  }

  Future<Result<void>> deleteAccount() async {
    final result = await _auth.deleteAccount();
    if (result is Success<void>) {
      state = const SessionState(status: SessionStatus.signedOut);
    }
    return result;
  }

  Result<void> _apply(Result<AuthSession> result) {
    switch (result) {
      case Success<AuthSession>(value: final session):
        state = SessionState(status: SessionStatus.signedIn, user: session.user);
        return const Success(null);
      case Failure<AuthSession>(
          :final message,
          :final code,
          :final field,
          :final statusCode,
        ):
        return Failure(message, code: code, field: field, statusCode: statusCode);
    }
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
