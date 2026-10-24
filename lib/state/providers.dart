import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/banner_presets.dart';
import '../core/utils/result.dart';
import '../data/local/local_store.dart';
import '../data/outbox/sync_service.dart';
import '../data/remote/api_client.dart';
import '../data/remote/auth_api.dart';
import '../data/remote/leaderboard_api.dart';
import '../data/remote/meta_api.dart';
import '../data/remote/quest_api.dart';
import '../data/repository/auth_repository.dart';
import '../data/repository/guild_repository.dart';
import '../data/repository/quest_repository.dart';
import '../data/repository/user_repository.dart';
import '../domain/enums.dart';
import '../domain/level.dart';
import '../services/connectivity_service.dart';
import '../services/endpoint_service.dart';
import '../services/haptics_service.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import 'settings_provider.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => throw UnimplementedError('tokenStorageProvider must be overridden'),
);

final localStoreProvider = Provider<LocalStore>(
  (ref) => LocalStore(ref.watch(sharedPreferencesProvider)),
);

final endpointServiceProvider = Provider<EndpointService>(
  (ref) => EndpointService(
    ref.watch(sharedPreferencesProvider),
    tokens: ref.watch(tokenStorageProvider),
  ),
);

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(ref.watch(sharedPreferencesProvider)),
);

class EndpointNotifier extends Notifier<String> {
  @override
  String build() => ref.watch(endpointServiceProvider).endpoint;

  Future<void> setEndpoint(String value, {required bool markLaunched}) async {
    final service = ref.read(endpointServiceProvider);
    await service.setEndpoint(value);
    if (markLaunched) await service.markLaunched();
    state = service.endpoint;
  }

  void refresh() {
    state = ref.read(endpointServiceProvider).endpoint;
  }
}

final endpointProvider = NotifierProvider<EndpointNotifier, String>(EndpointNotifier.new);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    endpoint: ref.watch(endpointProvider),
    tokens: ref.watch(tokenStorageProvider),
  );
});

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(apiClientProvider)),
);

final questApiProvider = Provider<QuestApi>(
  (ref) => QuestApi(ref.watch(apiClientProvider)),
);

final metaApiProvider = Provider<MetaApi>(
  (ref) => MetaApi(ref.watch(apiClientProvider)),
);

final leaderboardApiProvider = Provider<LeaderboardApi>(
  (ref) => LeaderboardApi(ref.watch(apiClientProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    tokens: ref.watch(tokenStorageProvider),
    api: ref.watch(authApiProvider),
    store: ref.watch(localStoreProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    store: ref.watch(localStoreProvider),
    auth: ref.watch(authRepositoryProvider),
  );
});

final guildRepositoryProvider = Provider<GuildRepository>((ref) {
  return GuildRepository(
    store: ref.watch(localStoreProvider),
    api: ref.watch(questApiProvider),
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    store: ref.watch(localStoreProvider),
    questApi: ref.watch(questApiProvider),
  );
});

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return QuestRepository(
    api: ref.watch(questApiProvider),
    store: ref.watch(localStoreProvider),
    outboxSync: ref.watch(syncServiceProvider),
    guilds: ref.watch(guildRepositoryProvider),
  );
});

final connectivityProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

final hapticsProvider = Provider<HapticsService>((ref) => const HapticsService());

final soundServiceProvider = Provider<SoundService>((ref) {
  final settings = ref.watch(settingsServiceProvider);
  final service = PlaceholderSoundService(enabled: settings.soundEnabled);
  ref.listen(settingsProvider, (_, next) {
    service.enabled = next.soundEnabled;
  });
  return service;
});

final bannerPresetsProvider = Provider((ref) => kBannerPresets);

class LevelTableNotifier extends Notifier<LevelTable> {
  @override
  LevelTable build() {
    final cached = ref.watch(localStoreProvider).readLevelConfig();
    return LevelTable(cached);
  }

  Future<void> load() async {
    final result = await ref.read(metaApiProvider).levels();
    if (result case Success<LevelConfig>(value: final config)) {
      await ref.read(localStoreProvider).writeLevelConfig(config);
      state = LevelTable(config);
    }
  }
}

final levelTableProvider = NotifierProvider<LevelTableNotifier, LevelTable>(
  LevelTableNotifier.new,
);

class SyncState {
  const SyncState({
    this.status = SyncStatus.idle,
    this.pendingCount = 0,
    this.error,
  });

  final SyncStatus status;
  final int pendingCount;
  final String? error;

  SyncState copyWith({SyncStatus? status, int? pendingCount, String? error}) {
    return SyncState(
      status: status ?? this.status,
      pendingCount: pendingCount ?? this.pendingCount,
      error: error,
    );
  }
}

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() {
    final pending = ref.watch(localStoreProvider).readOutbox().length;
    return SyncState(
      status: pending == 0 ? SyncStatus.idle : SyncStatus.pending,
      pendingCount: pending,
    );
  }

  void markSyncing(int count) {
    state = SyncState(status: SyncStatus.syncing, pendingCount: count);
  }

  void refreshCount() {
    final pending = ref.read(localStoreProvider).readOutbox().length;
    state = SyncState(
      status: pending == 0 ? SyncStatus.idle : SyncStatus.pending,
      pendingCount: pending,
    );
  }

  void markError(String message) {
    final pending = ref.read(localStoreProvider).readOutbox().length;
    state = SyncState(
      status: SyncStatus.error,
      pendingCount: pending,
      error: message,
    );
  }

  void markIdle() {
    state = const SyncState();
  }
}

final syncStatusProvider = NotifierProvider<SyncNotifier, SyncState>(SyncNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => ref.watch(endpointServiceProvider).hasLaunched;

  Future<void> complete() async {
    await ref.read(endpointServiceProvider).markLaunched();
    state = true;
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, bool>(
  OnboardingNotifier.new,
);
