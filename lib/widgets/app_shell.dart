import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/tokens.dart';
import '../domain/enums.dart';
import '../l10n/l10n.dart';
import '../state/providers.dart';
import '../state/quests_provider.dart';
import 'sync_indicator.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child, required this.location});

  final Widget child;
  final String location;

  static const _mobileDestinations = [
    ('/', Icons.grid_view_outlined),
    ('/quests/available', Icons.bolt_outlined),
    ('/leaderboard', Icons.leaderboard_outlined),
    ('/settings', Icons.settings_outlined),
  ];

  static const _desktopDestinations = [
    ('/', Icons.grid_view_outlined),
    ('/quests/available', Icons.bolt_outlined),
    ('/quests/in_progress', Icons.local_fire_department_outlined),
    ('/quests/completed', Icons.check_circle_outline),
    ('/leaderboard', Icons.leaderboard_outlined),
    ('/settings', Icons.settings_outlined),
  ];

  String _label(BuildContext context, String path) {
    final l10n = context.l10n;
    return switch (path) {
      '/' => l10n.guildBoard,
      '/quests/available' => l10n.available,
      '/quests/in_progress' => l10n.inProgress,
      '/quests/completed' => l10n.completed,
      '/leaderboard' => l10n.leaderboards,
      '/settings' => l10n.settings,
      _ => path,
    };
  }

  int _selectedIndex(List<(String, IconData)> destinations) {
    var best = 0;
    for (var i = 0; i < destinations.length; i++) {
      final path = destinations[i].$1;
      if (location == path) return i;
      if (path != '/' && location.startsWith('$path/')) best = i;
    }
    return best;
  }

  Widget _badged(BuildContext context, WidgetRef ref, String path, Widget icon) {
    final counts = ref.watch(questCountsProvider);
    final count = switch (path) {
      '/quests/available' => counts[QuestStatus.available] ?? 0,
      '/quests/in_progress' => counts[QuestStatus.inProgress] ?? 0,
      '/quests/completed' => counts[QuestStatus.completed] ?? 0,
      _ => null,
    };
    if (count == null || count == 0) return icon;
    return Badge(
      backgroundColor: AppColors.secondary,
      textColor: AppColors.bg,
      label: Text('$count'),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    return ValueListenableBuilder<bool>(
      valueListenable: connectivity.online,
      builder: (context, online, _) => _shell(context, ref, online),
    );
  }

  Widget _shell(BuildContext context, WidgetRef ref, bool online) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppBreakpoints.medium) {
      final index = _selectedIndex(_mobileDestinations);
      return Scaffold(
        body: Column(
          children: [
            if (!online) const OfflineStrip(),
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.16),
          selectedIndex: index,
          onDestinationSelected: (value) => context.go(_mobileDestinations[value].$1),
          destinations: [
            for (final destination in _mobileDestinations)
              NavigationDestination(
                icon: _badged(context, ref, destination.$1, Icon(destination.$2)),
                selectedIcon: _badged(
                  context,
                  ref,
                  destination.$1,
                  Icon(destination.$2, color: AppColors.primary),
                ),
                label: _label(context, destination.$1),
              ),
          ],
        ),
      );
    }

    final index = _selectedIndex(_desktopDestinations);
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: AppColors.surface,
            child: NavigationRail(
              extended: width >= 1400,
              selectedIndex: index,
              onDestinationSelected: (value) => context.go(_desktopDestinations[value].$1),
              groupAlignment: -0.9,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Text('⚡', style: Theme.of(context).textTheme.headlineMedium),
              ),
              trailing: const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: SyncIndicator(compact: true),
              ),
              destinations: [
                for (final destination in _desktopDestinations)
                  NavigationRailDestination(
                    icon: _badged(context, ref, destination.$1, Icon(destination.$2)),
                    selectedIcon: _badged(
                      context,
                      ref,
                      destination.$1,
                      Icon(destination.$2, color: AppColors.primary),
                    ),
                    label: Text(_label(context, destination.$1)),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Column(
              children: [
                if (!online) const OfflineStrip(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
