import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'domain/enums.dart';
import 'features/auth/auth_screen.dart';
import 'features/banner/banner_screen.dart';
import 'features/board/board_screen.dart';
import 'features/connect/connect_screen.dart';
import 'features/language/language_screen.dart';
import 'features/leaderboard/leaderboard_screen.dart';
import 'features/quests/create/quest_create_screen.dart';
import 'features/quests/detail/quest_detail_screen.dart';
import 'features/quests/list/quest_list_screen.dart';
import 'features/settings/settings_screen.dart';
import 'state/providers.dart';
import 'state/session_provider.dart';
import 'widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(onboardingProvider, (_, _) => refresh.value++);
  ref.listen(sessionProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final onboardingDone = ref.read(onboardingProvider);
      final signedIn = ref.read(sessionProvider).isSignedIn;
      final path = state.uri.path;

      if (!onboardingDone) {
        return path == '/connect' || path == '/language' ? null : '/connect';
      }
      if (!signedIn) {
        return path == '/auth' ? null : '/auth';
      }
      if (path == '/connect' || path == '/language' || path == '/auth') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/connect',
        builder: (context, state) => const ConnectScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const BoardScreen(),
          ),
          GoRoute(
            path: '/quests/available',
            builder: (context, state) =>
                const QuestListScreen(status: QuestStatus.available),
          ),
          GoRoute(
            path: '/quests/in_progress',
            builder: (context, state) =>
                const QuestListScreen(status: QuestStatus.inProgress),
          ),
          GoRoute(
            path: '/quests/completed',
            builder: (context, state) =>
                const QuestListScreen(status: QuestStatus.completed),
          ),
          GoRoute(
            path: '/leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/quests/new',
        builder: (context, state) => const QuestCreateScreen(),
      ),
      GoRoute(
        path: '/quests/:id',
        builder: (context, state) =>
            QuestDetailScreen(questId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: '/banner',
        builder: (context, state) => const BannerScreen(),
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
