import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'router.dart';
import 'state/providers.dart';
import 'state/settings_provider.dart';

class QuestboardApp extends ConsumerStatefulWidget {
  const QuestboardApp({super.key});

  @override
  ConsumerState<QuestboardApp> createState() => _QuestboardAppState();
}

class _QuestboardAppState extends ConsumerState<QuestboardApp> {
  @override
  void initState() {
    super.initState();
    ref.read(levelTableProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    final locale = settings.languageCode == null
        ? null
        : Locale(settings.languageCode!);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
    );
  }
}
